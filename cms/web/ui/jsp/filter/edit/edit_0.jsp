<%@ page
	language="java"
	import="com.britemoon.*,
			 com.britemoon.cps.*,
			 com.britemoon.cps.tgt.*,
			 java.io.*,java.sql.*,
			 java.util.*,org.w3c.dom.*,
			 org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

//KU: Added for content logic ui
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}
	
%>
<HTML>
<HEAD>
	<TITLE><%= sTargetGroupDisplay %>: Recipients who are in a Target Group</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		
		function validate_form()
		{
			if (filter_form.new_filter_id[filter_form.new_filter_id.selectedIndex].text == "")
			{
				alert("Please select a Target Group");
			}
			else
			{
				filter_form.action = "save_0.jsp?usage_type_id=<%= sUsageTypeId %>";
				return true;
			}
		}
		
	</SCRIPT>
</HEAD>

<BODY>
<FORM name=filter_form onsubmit="validate_form()" method="POST">
<%
	String sFilterId = request.getParameter("filter_id");	
	
	String sCategoryId = request.getParameter("category_id");
	if ((sCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sCategoryId = ui.s_category_id;
	if("0".equals(sCategoryId)) sCategoryId = null;

	String sImportId = null;
	String sFilterName = null;
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
%>
	<INPUT type=hidden name=old_filter_id value=<%=sFilterId%>>
<%
	}
%>
<INPUT type=hidden name=type_id value="<%=FilterType.MULTIPART%>">

<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
						
<%
	String sSql = null;
	
	if (sCategoryId == null)
	{
		sSql  =
			" SELECT distinct filter_id, filter_name" +
			" FROM ctgt_filter" +
			" WHERE" +
			" ("+
			" origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +
			" AND type_id = " + FilterType.MULTIPART +
			" AND cust_id = " + cust.s_cust_id +
			" AND status_id != " + FilterStatus.DELETED +
			" AND ISNULL(usage_type_id,500) = " + FilterUsageType.REGULAR +
			" ) OR ( filter_id = " + sFilterId + " )"+
			" ORDER BY filter_name";
	}
	else
	{
		sSql  =
			" SELECT distinct f.filter_id, f.filter_name" +
			" FROM ctgt_filter f, ccps_object_category oc" +
			" WHERE" +
			" ("+
			" f.origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +			
			" AND f.type_id = " + FilterType.MULTIPART +
			" AND f.cust_id = " + cust.s_cust_id +
			" AND f.status_id != " + FilterStatus.DELETED +
			" AND ISNULL(f.usage_type_id,500) = " + FilterUsageType.REGULAR +
			" AND f.filter_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sCategoryId +
			" ) OR ( filter_id = " + sFilterId + " )"+
			" ORDER BY f.filter_name";
	}

	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		PreparedStatement pstmt = null;
		try
		{
			pstmt = conn.prepareStatement(sSql);
			ResultSet rs = pstmt.executeQuery();

			String sId = null;
			String sName = null;

			byte[] b = null;
%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						Recipients who are in a Target Group<br>
						Select a Target Group:<br>
						<select size=1 name=new_filter_id>
							<option></option>
<%
			while (rs.next())
			{
				sId = rs.getString(1);
				b = rs.getBytes(2);
				sName = (b==null)?null:new String(b, "UTF-8");
%>
							<option value="<%=sId%>"<%=((sId.equals(sFilterId))?" selected":"")%>>
								<%=HtmlUtil.escape(sName)%>
							</option>
<%
			}
			rs.close();
%>
						</select>
					</td>
				</tr>
			</table>
			<br>
<%
		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }
	}
	catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
	finally { if(conn != null) cp.free(conn); }
	%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<input type="button" class="subactionbutton" onclick="history.back();" value="<< Back">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" onclick="window.close();" value="Cancel">&nbsp;&nbsp;
						<input type="submit" class="subactionbutton" value="Save >>">&nbsp;&nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</FORM>
</BODY>
</HTML>
