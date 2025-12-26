<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.util.Date,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<SCRIPT language="javascript">
	function PrepSubmit(Act)
	{
		var CampId = FT.CampID.value;
		var CacheId='';
		FT.UpdList.value = '';
		FT.CompList.value = '';
		var numChecks = 0;

		if (Act == '1')
		{
			if (FT.CCheck.length == undefined)
			{
				if (FT.CCheck.checked)
				{
					FT.CompList.value += FT.CCheck.value + ",";
					if (CacheId !='') CacheId += ',';
					CacheId += FT.CCheck.value;
					numChecks++;
				}
			}
			else
			{
				for (i=0; i < FT.CCheck.length; i++)
				{
					if (FT.CCheck[i].checked)
					{
						FT.CompList.value += FT.CCheck[i].value + ",";
						if (CacheId !='') CacheId += ',';
						CacheId += FT.CCheck[i].value;
						numChecks++;
					}
				}
			}

			if (CacheId != '')
			{
				FT.action += "?act=VIEW&id=" + CampId + "&Z=1&C=" + CacheId;
				FT.submit();
			}
			else
			{
				alert("Choose at least one report to compare.");
			}
		}
		else if (Act == '2')
		{
			if (FT.UCheck.length == undefined)
			{
				if (FT.UCheck.checked)
				{
					FT.UpdList.value += FT.UCheck.value + ",";
					if (CacheId !='') CacheId += ',';
					CacheId += FT.UCheck.value;
					numChecks++;
				}
			}
			else
			{
				for (i=0; i < FT.UCheck.length; i++)
				{
					if (FT.UCheck[i].checked)
					{
						FT.UpdList.value += FT.UCheck[i].value + ",";
						if (CacheId !='') CacheId += ',';
						CacheId += FT.UCheck[i].value;
						numChecks++;
					}
				}
			}
			
			if (CacheId != '')
			{
				FT.action = "report_cache_update.jsp?get_cache_info=1&camp_id=" + CampId+ "&cache_id=" + CacheId;
				FT.submit();
				return;
			}
			else
			{
				alert("Choose at least one report to update.");
			}
		}
		else if (Act == '3')
		{
			FT.action = "report_cache_list.jsp?Q=" + CampId;
			FT.submit();
			return;
		}
	}
</SCRIPT>
<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

String sCampID = request.getParameter("Q");

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_cache_list.jsp");
	stmt = conn.createStatement();

	int numRecs = 0;
	if ((sCampID != null) && (sCampID != "")) {
		rs = stmt.executeQuery("SELECT count(camp_id) FROM cque_campaign c"
				+ " WHERE c.cust_id="+cust.s_cust_id+" and c.camp_id="+sCampID); 
		while(rs.next()) {
			numRecs = rs.getInt(1);
		}
		rs.close();
	}

	//Customize deliveryTracker report Feature (part of release 5.9)
	int showTrackerRpt = 0;
	boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
	if (bFeat)
	{
 		int nCount = getSeedListCount(stmt,cust.s_cust_id, sCampID);
		if (nCount > 0)
			showTrackerRpt = 1;
	}
	// end release 5.9
	
	if ((sCampID == null) || (sCampID == "") || (numRecs < 1))
	{
		%>
		<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
			<tr>
				<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tr>
				<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tbody class=EditBlock id=block1_Step1>
			<tr>
				<td class=fillTab valign=top align=center width=650>
					<table class=main cellspacing=1 cellpadding=2 width="100%">
						<tr>
							<td align="center" valign="middle" style="padding:10px;">
								<b>No Campaign for that ID</b>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			</tbody>
		</table>
		<br><br>
		<%	
	}
	else
	{
		String sTime = null;
		rs = stmt.executeQuery("SELECT CONVERT(varchar(25), getdate(), 0)");
		if (rs.next()) sTime = rs.getString(1);
		rs.close();
		sTime = (sTime == null)?"":sTime;


		boolean bCacheExists = false;
		rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_summary_cache WHERE camp_id = "+sCampID);
		
		if (rs.next())
		{
			int nCnt = rs.getInt(1);
			bCacheExists = (nCnt > 0);
		}
		
		//KU 2004-02-20
		int nPos = 0;
		String reportName = "";
		String reportDate = "";
		byte[] bVal = new byte[255];
		
		rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_pos WHERE camp_id IN ("+sCampID+")");
		
		if (rs.next())
		{
			nPos = rs.getInt(1);
		}
		rs.close();
		
		rs = stmt.executeQuery("Exec usp_crpt_camp_list @camp_id="+sCampID+", @cust_id="+cust.s_cust_id+", @cache=0");
		
		while( rs.next() )
		{
			bVal = rs.getBytes("CampName");
			reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
			reportDate = rs.getString("StartDate");
		}
		rs.close();
		%>
<BODY>

<form name="FT" id="FT" method="post" action="report_object.jsp">
<input type="hidden" name="CampID" value="<%= sCampID %>"/>	
<input type="hidden" name="CompList" value=""/>
<input type="hidden" name="UpdList" value=""/>	
<table width=95% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Report:</b> <%= reportName %></td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'report_redirect.jsp?act=VIEW&id=<%=sCampID%>';">Campaign Results</td>
		<td class="EditTabOn" width="200" valign="center" nowrap="true" align="middle">Demographic Or Time Report</td>
		<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'report_time.jsp?Q=<%=sCampID%>';">Activity vs. Time Report</td>

		<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->
		<% if (showTrackerRpt == 1) { %>
			<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'eTrackerReport.jsp?Q=<%=sCampID%>';">Delivery Tracking</td>
		<%}%>
		<!--  END (part of release 5.9) -->

		<% if (nPos > 0) { %><td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'report_track.jsp?Q=<%=sCampID%>&#38;Z=0';">BriteTrack Results</td><% } %>
		<td class="EmptyTab" valign="center" nowrap="true" align="middle" width="200" ><img height="2" src="../../images/blank.gif" width="1" /></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="left" colspan="6">
			<table width="100%" cellspacing="0" cellpadding="0" border="0">
				<tr>
					<td>
						<a href="report_cache_edit.jsp?Q=<%= sCampID %>&C=0" class="newbutton">New Demographic or Time Report</a>&#160;&#160;&#160;
						<a href="#1" OnClick="PrepSubmit('1');" class="newbutton">Compare Reports</a>&#160;&#160;&#160;
						<a href="#1" OnClick="PrepSubmit('2');" class="newbutton">Update Reports</a>
					</td>
					<td>
						<a href="#1" OnClick="PrepSubmit('3');" class="resourcebutton" >Refresh List</a>&#160;&#160;
					</td>
				</tr>
			</table>		
			<br><br>
			<table class="listTable" width="100%" cellspacing="0" cellpadding="2">
				<tr>
					<th align="left" width="20" nowrap>&nbsp;</th>
					<th align="left" width="40" nowrap>Compare</th>
					<th align="left" width="50" nowrap>Start Date</th>
					<th align="left" width="50" nowrap>End Date</th>
					<th align="left" nowrap>Criteria</th>
					<th align="left" width="50" nowrap>User Owned</th>
					<th align="left" width="40" nowrap>Update</th>
					<th align="left" width="50" nowrap>Update Date</th>
					<th align="left" width="50" nowrap>Update Status</th>
					<th align="left" width="20" nowrap>&nbsp;</th>
				</tr>
			<%
			String sSQL = "";
			
			if ("1".equals(user.s_recip_owner))
			{
				sSQL = "SELECT distinct cache_id, convert(varchar(30),c.cache_start_date,100), convert(varchar(30),c.cache_end_date,100),"
						+ " c.user_id, c.attr_id, a.display_name, c.attr_value1, c.attr_value2, o.sql_name, f.filter_name, convert(varchar(30),c.last_update_date,100), s.display_name"
						+ " FROM crpt_camp_summary_cache c"
						+ " LEFT OUTER JOIN ccps_cust_attr a ON a.attr_id = c.attr_id AND a.cust_id = " +  cust.s_cust_id
						+ " LEFT OUTER JOIN ctgt_compare_operation o ON o.operation_id = c.attr_operator"
						+ " LEFT OUTER JOIN ctgt_filter f ON f.filter_id = c.filter_id"
						+ " LEFT OUTER JOIN crpt_report_status s ON s.status_id = ISNULL(c.last_status_id, 20)"
						+ " WHERE c.camp_id = " + sCampID
						+ " AND c.user_id = " + user.s_user_id;
						/*
						+ " AND c.cache_id NOT IN (" 
						+ " SELECT cache_id FROM crpt_camp_summary_cache"
						+ " WHERE camp_id = " + sCampID
						+ " AND cache_start_date IS NULL"
						+ " AND cache_end_date IS NULL"
						+ " AND attr_id IS NULL"
						+ " AND attr_value1 IS NULL"
						+ " AND attr_value2 IS NULL"
						+ " AND attr_operator IS NULL"
						+ " AND user_id = " + user.s_user_id
						+ " )";
						*/
			}
			else
			{
				sSQL = "SELECT distinct cache_id, convert(varchar(30),c.cache_start_date,100), convert(varchar(30),c.cache_end_date,100),"
						+ " c.user_id, c.attr_id, a.display_name, c.attr_value1, c.attr_value2, o.sql_name, f.filter_name, convert(varchar(30),c.last_update_date,100), s.display_name"
						+ " FROM crpt_camp_summary_cache c"
						+ " LEFT OUTER JOIN ccps_cust_attr a ON a.attr_id = c.attr_id AND a.cust_id = " +  cust.s_cust_id
						+ " LEFT OUTER JOIN ctgt_compare_operation o ON o.operation_id = c.attr_operator"
						+ " LEFT OUTER JOIN ctgt_filter f ON f.filter_id = c.filter_id"
						+ " LEFT OUTER JOIN crpt_report_status s ON s.status_id = ISNULL(c.last_status_id, 20)"
						+ " WHERE c.camp_id = " + sCampID;
			}
			
			rs = stmt.executeQuery(sSQL);
			
			String sCacheID = null;
			String sStartDate = null;
			String sEndDate = null;
			String sAttrID = null;
			String sAttrName = null;
			String sAttrValue1 = "";
			String sAttrValue2 = "";
			String sAttrOperator = null;
			String sUserID = null;
			String sFilterName = null;
			String sLastUpdateDate = null;
			String sLastStatus = null;
			boolean canUpdate = false;
			int iCount = 0;

			String sClassAppend = "";
			boolean isOwningReport = false;

			while( rs.next() )
			{
				if (iCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";
				
				sCacheID = rs.getString(1);
				sStartDate = rs.getString(2);
				sEndDate = rs.getString(3);
				sUserID = rs.getString(4);
				sAttrID = rs.getString(5);
				
				bVal = rs.getBytes(6);
				sAttrName=(bVal!=null?new String(bVal,"UTF-8"):"--None Selected--");
				
				bVal = rs.getBytes(7);
				sAttrValue1=(bVal!=null?new String(bVal,"UTF-8"):"");
				
				bVal = rs.getBytes(8);
				sAttrValue2=(bVal!=null?new String(bVal,"UTF-8"):"");
				
				sAttrOperator = rs.getString(9);
				sFilterName = rs.getString(10);
				sLastUpdateDate = rs.getString(11);
				sLastStatus = rs.getString(12);
				
				isOwningReport = false;
				
				if ((sStartDate == null) && (sEndDate == null) && (sAttrID == null))
				{
					isOwningReport = true;
				}
				
				sStartDate = (sStartDate != null)?sStartDate:"--None Selected--";
				sEndDate = (sEndDate != null)?sEndDate:"--None Selected--";
				sUserID = (!"0".equals(sUserID))?"Yes":"No";
				sAttrID = (sAttrID != null)?sAttrID:"--None Selected--";
				sAttrOperator = (sAttrOperator != null)?sAttrOperator:"";

				String sCriteria = sFilterName;
				if (sCriteria == null)
				{
					sCriteria = sAttrName + "&nbsp;" + sAttrOperator + "&nbsp;" + sAttrValue1 + "&nbsp;" + sAttrValue2;
				}
				canUpdate = false;
				if (sLastStatus != null && sLastStatus.equals("Completed")) {
					canUpdate = true;
				}
				//Page logic
				iCount++;
				%>
				<tr>
					<td align="left" width="20" class="listItem_Data<%= sClassAppend %>"><a href="report_object.jsp?act=VIEW&id=<%= sCampID %>&Z=1&C=<%= sCacheID %>" class="subactionbutton">View</a></td>
					<td align="left" width="40" class="listItem_Data<%= sClassAppend %>" nowrap><input type="checkbox" name="CCheck" value="<%= sCacheID %>"></td>
					<td align="left" width="50" class="listItem_Data<%= sClassAppend %>" nowrap><%= sStartDate %></td>
					<td align="left" width="50" class="listItem_Title<%= sClassAppend %>" nowrap><%= sEndDate %></td>
					<td align="left" class="listItem_Title<%= sClassAppend %>" nowrap><%= sCriteria %></td>
					<td align="left" width="50" class="listItem_Title<%= sClassAppend %>" nowrap><%= sUserID %></td>
					<td align="left" width="40" class="listItem_Data<%= sClassAppend %>" nowrap>
					<% if (canUpdate) { %>
					    <input type="checkbox" name="UCheck" value="<%= sCacheID %>">
					<% } else { %>
					    &nbsp;
					<% } %>
					</td>
					<td align="left" width="50" class="listItem_Title<%= sClassAppend %>" nowrap><%= sLastUpdateDate %></td>
					<td align="left" width="50" class="listItem_Title<%= sClassAppend %>" nowrap><%= sLastStatus %></td>
					<td align="left" width="20" class="listItem_Data<%= sClassAppend %>">
					<% if (canUpdate) { %>
					    <a href="report_cache_edit.jsp?Q=<%= sCampID %>&C=<%= sCacheID %>" class="subactionbutton">Edit</a>
					<% } else { %>
					    &nbsp;
					<% } %>
					</td>
				</tr>
				<%
			}
			if (iCount == 0)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="6">There are currently no Demographic or Time Reports.</td>
				</tr>
				<%
			}
			rs.close();
			%>
			</table>
			<br><br><br><br><br><br>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</form>
</BODY>

<%
	}

%>
</HTML>
<%
} catch(Exception ex) { 
	ErrLog.put(this, ex, "Report Error.",out,1);
} finally {

	try { 	
		if( stmt != null ) stmt.close(); 
	} catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>
