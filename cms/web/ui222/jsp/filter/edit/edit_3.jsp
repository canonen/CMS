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
	<TITLE><%= sTargetGroupDisplay %>: Recipients who were imported into a Batch</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		function validate_form()
		{
			filter_form.action = "save.jsp?usage_type_id=<%= sUsageTypeId %>";
			return true;
		}
		
		function setFilterName(obj)
		{
			var ops = obj.options;
			var si = obj.selectedIndex;		
			filter_form.filter_name.value = '(BATCH) ' + ops[si].text;
			display_name.innerText = "(BATCH) " + ops[si].text;

			id_val = ops[si].value;
			if((id_val == null)||(id_val == '')) filter_form.done.disabled = true;
			else  filter_form.done.disabled = false;
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

String sBatchId = null;
String sFilterName = null;
if(sFilterId != null)
{
	com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
	sFilterName = f.s_filter_name;
	FilterParams fps = new FilterParams();
	fps.s_filter_id = sFilterId;
	fps.retrieve();
	sBatchId = fps.getIntegerValue("batch_id");
	%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
	<%
}
%>
<INPUT type=hidden name=type_id value="<%=FilterType.BATCH%>">


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
			<table class=main cellspacing=1 cellpadding=2 width="100%">
<%
String sSql = null;
if (sCategoryId == null)
{
	sSql =
		" SELECT b.batch_id, b.batch_name" +
		" FROM cupd_batch b" + 
		" WHERE ( (b.type_id = 1" + 
		" AND b.batch_id IN" +
			" (SELECT DISTINCT i.batch_id" +
			" FROM cupd_import i, cupd_batch b" +
			" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
			" AND i.batch_id = b.batch_id" +
			" AND b.cust_id = " + cust.s_cust_id + "))" +
		" OR (b.type_id > 1) )" +
		" AND b.cust_id = " + cust.s_cust_id +
		" ORDER BY type_id, batch_name";
}
else
{
	sSql =
		" SELECT b.batch_id, b.batch_name" +
		" FROM cupd_batch b" + 
		" WHERE ( (b.type_id = 1" + 
		" AND b.batch_id IN" +
			" (SELECT DISTINCT i.batch_id" +
			" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
			" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
			" AND i.batch_id = b.batch_id" +
			" AND b.cust_id = " + cust.s_cust_id + 
			" AND oc.object_id = i.import_id" +
			" AND oc.type_id = " + ObjectType.IMPORT +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = "+sCategoryId + "))" +
		" OR (b.type_id > 1) )" +
		" AND b.cust_id = " + cust.s_cust_id +
		" ORDER BY type_id, batch_name";
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
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						Recipients who were imported into a Batch<br>
						Select a Batch:<br>
						<input type=hidden name=param_name value=batch_id>
						<input type=hidden name=string_value value="">
						<input type=hidden name=date_value value="">
						<select size=1 name=integer_value onchange="setFilterName(this);">
							<option></option>
						<%
						while (rs.next())
						{
							sId = rs.getString(1);
							b = rs.getBytes(2);
							sName = (b==null)?null:new String(b, "UTF-8");
							%>
								<option value="<%=sId%>"<%=((sId.equals(sBatchId))?" selected":"")%>><%= HtmlUtil.escape(sName) %></option>
							<%
						}
						rs.close();
						%>
						</select>
					</td>
				</tr>
		<%
	}
	catch(Exception ex) { throw ex; }
	finally { if(pstmt != null) pstmt.close(); }
}
catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
finally { if(conn != null) cp.free(conn); }
%>
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						Name, as it will appear in <%= sTargetGroupDisplay %> Edit: <input type="hidden" name="filter_name" value="<%=HtmlUtil.escape(sFilterName)%>">
						<br>
						<b><span id="display_name"><%=HtmlUtil.escape(sFilterName)%></span></b>
					</td>
				</tr>
			</table>
			<br>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<input type="button" class="subactionbutton" onclick="history.back();" value="<< Back">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" onclick="window.close();" value="Cancel">&nbsp;&nbsp;
						<input type="submit" class="subactionbutton" name="done" value="Save >>" disabled>&nbsp;&nbsp;
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
