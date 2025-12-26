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

AccessPermission can = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
if(!can.bRead || !can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

%>

<html>
	<head>
		<title>Auto Login to pvIQ</title>
		<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">	
	  
	</head>
	<%
	// Get Connection
	Statement		stmt	= null;
	ResultSet		rs		= null; 
	ConnectionPool	cp		= null;
	Connection		conn	= null;
	
	String sCampID = request.getParameter("Q");
	String sTypeID = "10";
	try	
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("eTrackerReport.jsp");
		stmt = conn.createStatement();
	
		int numRecs = 0;
		int nPos = 0;
		String reportName = "";
		String reportDate = "";
		byte[] bVal = new byte[255];
		if ((sCampID != null) && (sCampID != ""))
		{
			rs = stmt.executeQuery("SELECT count(camp_id) FROM cque_campaign c"
			+ " WHERE c.cust_id="+cust.s_cust_id+" and c.camp_id="+sCampID);	
			while(rs.next())
			{
				numRecs = rs.getInt(1);
			}
			rs.close();
			
			rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_pos WHERE camp_id IN ("+sCampID+")");
			if ( rs.next() )
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
		}

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
		%>
		<body>
			<table width=95% class=main cellspacing=0 cellpadding=0>
			<tr>
				<td class=sectionheader>&nbsp;<b class=sectionheader>Report:</b> <%= reportName %></td>
			</tr>
			</table>
			<br>

			<table id="Tabs_Table" cellspacing="0" cellpadding="0" width="95%" border="0">

			<tr height="20">
				<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'report_object.jsp?id=<%=sCampID%>';">Campaign Results</td>
				<td class="EditTabOff" valign="center" nowrap align="middle" onclick="location.href = 'report_cache_edit.jsp?Q=<%=sCampID%>';">Demographic Or Time Report</td>
				<td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'report_time.jsp?Q=<%=sCampID%>';">Activity vs. Time Report</td>
				<td class="EditTabOn" width="200" valign="center" nowrap="true" align="middle">Delivery Tracking</td>
				<% if (nPos > 0) { %><td class="EditTabOff" width="200" valign="center" nowrap="true" align="middle" onclick="location.href = 'report_track.jsp?Q=<%=sCampID%>&#38;Z=0';">BriteTrack Results</td><% } %>
				<td class="EmptyTab" valign="center" nowrap="true" align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1" /></td>
			</tr>

			<tbody class="EditBlock" id="block1_Step1">
			<tr height="100">
			<td class="fillTab" valign="top" align="center" width="100%" colspan="6">
			<table>
			<tr>
				<td width="100" height="25">Seed List	</td>
				<td width="400" colspan="2" height="25">
					<select name="seedList_id">
						<option value="">-----  Choose Seed List  -----</option>
						<%=getSeedListOptionsHtml(stmt, cust.s_cust_id,sCampID)%>
					</select>
				</td>
			</tr>
			<tr>
				<td align="center" colspan="2" >
				<input type=button value='Get Report' name=submitbutton onClick="loadReport();">
				</td>
				</tr>
				</table>
				</td>
			</tr>
			<tr height="800">
				<td class="fillTab" valign="top" align="center" width="100%" colspan="6">
					<IFRAME src="" NAME="ifrm" width="100%" height="100%">
					</IFRAME>
				</td>
			</tr>
		</tbody>
		</table>
			
		<SCRIPT LANGUAGE="JavaScript">
		function loadReport()
		{
			 var a = document.all.item('seedList_id')[document.all.item('seedList_id').selectedIndex].value;
			 if(a == "" || a == null)
			 {
			 	alert('Please select valid Seed list');
			 	return;
			 }
			 var url = "viewer_iframe.jsp?CampID=" + <%=sCampID%>;
			 url = url + "&ListID=";
			 url = url + document.all.item('seedList_id')[document.all.item('seedList_id').selectedIndex].value;
			 document.ifrm.location.href=url;
		}
		</SCRIPT>
	
	</body>
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