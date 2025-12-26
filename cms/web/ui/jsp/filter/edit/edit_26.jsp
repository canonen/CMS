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
<%! static Logger logger = null;%>
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
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}
	
%>

<HTML>

<HEAD>
	<TITLE><%= sTargetGroupDisplay %>: Campaign Form</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		function do_submit()
		{
			filter_name = filter_form.filter_name.value;
			if((filter_name==null)||(filter_name.length==0))
			{
				alert('Invalid name.')
				filter_form.filter_name.focus();
				return false;
			}
			else
			{
				filter_form.action = "save_calc.jsp?usage_type_id=<%= sUsageTypeId %>";
				filter_form.submit();
				return true;
			}
		}

		function validate_params()
		{
			val = filter_form.form_select.value;
			if((val == null)||(val == ''))
			{
				filter_form.save.disabled = true;
				return;
			}
			filter_form.form_id.value = val;
			filter_form.save.disabled = false;
		}
		
		function resizeWin()
		{
			top.window.resizeTo(700,365);
		}

		function resetWin()
		{
			top.window.resizeTo(700,300);
		}
	</SCRIPT>
</HEAD>

<BODY onload="resizeWin();" onunload="resetWin();">
<FORM name=filter_form method="POST">
<%
	String sStartDate = null;
	String sFinishDate = null;
	
	String sFilterId = request.getParameter("filter_id");	
	
	String sCategoryId = request.getParameter("category_id");
	if ((sCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sCategoryId = ui.s_category_id;
	if("0".equals(sCategoryId)) sCategoryId = null;

	String sCampId = null;
	String sFormId = null;	
	String sFilterName = null;
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();
		sCampId = fps.getIntegerValue("camp_id");
		sFormId = fps.getIntegerValue("form_id");
		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");
%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
<%
	}
	
	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";
%>
<INPUT type=hidden name=type_id value="<%=FilterType.FORM_SUBMIT_DURING_TIME_INTERVAL%>">


<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>

		<tbody class=EditBlock id=block1_Step1>
		<tr>
			<td  valign=top align=center width=100%>
				<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th colspan=2>
						Form Submissions
					</th>
				</tr>
	<%
	String sSql = null;

	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		PreparedStatement pstmt = null;
		
		// === === ===
		
		try
		{
			sSql =
				" SELECT form_id, form_name" +
				" FROM csbs_form" +
				" WHERE cust_id = " + cust.s_cust_id +
				" ORDER BY form_name";

			pstmt = conn.prepareStatement(sSql);
			ResultSet rs = pstmt.executeQuery();

			String sId = null;
			String sName = null;

			byte[] b = null;
			%>
				<tr>
					<td align="center" valign="middle" style="padding:10px;" colspan=2>
						Recipients who submitted the Form ...<br>
						Select the Form:<br>
						<input type=hidden name=form_id value="<%=sFormId%>">
						<select size=1 name=form_select onchange="validate_params();">
							<option></option>
						<%
						while (rs.next())
						{
							sId = rs.getString(1);
							b = rs.getBytes(2);
							sName = (b==null)?null:new String(b, "UTF-8");
							%>
								<option value="<%=sId%>"<%=((sId.equals(sFormId))?" selected":"")%>><%= HtmlUtil.escape(sName) %></option>
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
		%>
		
				<tr>
					<td align="center" valign="middle" width="100%" colspan="2">Specify the date ranges during which the Form was submitted</td>
				</tr>
				<tr>
					<td align="center" valign="top" width="100%" colspan="2">
						<table cellspacing="0" cellpadding="2" border="0" width="100%">
							<colgroup>
								<col width="50%">
								<col width="50%">
							</colgroup>
							<tr>
								<td align="center" valign="middle" colspan="2">
									Where the form was submitted 
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle">
									between:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle">
									<input type="text" name="start_date" value="<%= HtmlUtil.escape(sStartDate) %>" onfocus="this.select();">
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle">
									and:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle">
									<input type="text" name="finish_date" value="<%=HtmlUtil.escape(sFinishDate)%>" onfocus="this.select();">
								</td>
							</tr>
						</table>
					</td>
				</tr>
		<tr>
			<td align="center" valign="middle" colspan="2">Finally, enter a name for this calculation</td>
		</tr>
		<tr>
			<td align="center" valign="middle" colspan="2"><input type="text" name="filter_name" size="80" value="<%= HtmlUtil.escape(sFilterName) %>"></td>
		</tr>
	<%
	}
	catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
	finally { if(conn != null) cp.free(conn); }
	%>
		
			
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<input type="button" class="subactionbutton" onclick="history.back();" value="<< Back">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" onclick="window.close();" value="Cancel">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" name="save" value="Save >>" onclick="do_submit();">&nbsp;&nbsp;
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
