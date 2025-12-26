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
				filter_form.action = "save.jsp?usage_type_id=<%= sUsageTypeId %>";
				filter_form.submit();
				return true;
			}
		}

		function validate_params()
		{
			val = filter_form.integer_value[0].value;
			if((val == null)||(val == ''))
			{
				filter_form.save.disabled = true;
				return;
			}
			val = filter_form.integer_value[1].value;
			if((val == null)||(val == ''))
			{
				filter_form.save.disabled = true;
				return;
			}
			filter_form.save.disabled = false;
			
			var filName = "";
			var selItem = 0;
			
			selItem = filter_form.integer_value[0].selectedIndex;
			var val1 = filter_form.integer_value[0][selItem].text;
			
			selItem = filter_form.integer_value[1].selectedIndex;
			var val2 = filter_form.integer_value[1][selItem].text;
			
			filter_form.filter_name.value = "(CAMPAIGN-FORM) " + val1 + " - " + val2;
			display_name.innerText = "(CAMPAIGN-FORM) " + val1 + " - " + val2;
		}
	</SCRIPT>
</HEAD>

<BODY>
<FORM name=filter_form method="POST">
<%
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
%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
<%
	}
%>
<INPUT type=hidden name=type_id value="<%=FilterType.CAMPAIGN_FORM%>">


<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>

	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td  valign=top align=center width=100%>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
			<tr>
				<th>Recipients who submitted a Form in association with a Campaign<th>
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
					<td align="center" valign="middle">
						Recipients who submitted a Form ...<br>
						Select a Form:<br>
						<input type=hidden name=param_name value=form_id>
						<input type=hidden name=string_value value="">
						<input type=hidden name=date_value value="">
						<select size=1 name=integer_value onchange="validate_params();">
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
		
		// === === ===
		
		try
		{
			if (sCategoryId == null)
			{
				sSql  =
					" SELECT camp_id, camp_name" +
					" FROM cque_campaign" +
					" WHERE origin_camp_id IS NULL" +
					" AND cust_id = " + cust.s_cust_id +
					" ORDER BY camp_name";
			}
			else
			{
				sSql  =
					" SELECT c.camp_id, c.camp_name" +
					" FROM cque_campaign c, ccps_object_category oc" +
					" WHERE c.origin_camp_id IS NULL" +
					" AND c.cust_id = " + cust.s_cust_id +
					" AND c.camp_id = oc.object_id" +
					" AND oc.type_id = " + ObjectType.CAMPAIGN +
					" AND oc.cust_id = " + cust.s_cust_id +
					" AND oc.category_id = " + sCategoryId +
					" ORDER BY c.camp_name";
			}

			pstmt = conn.prepareStatement(sSql);
			ResultSet rs = pstmt.executeQuery();

			String sId = null;
			String sName = null;

			byte[] b = null;
			%>
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						... where that form submission is associated with a Campaign<br>
						Select a Campaign:<br>
						<input type=hidden name=param_name value=camp_id>
						<input type=hidden name=string_value value="">
						<input type=hidden name=date_value value="">
						<select size=1 name=integer_value onchange="validate_params();">
							<option></option>
						<%
						while (rs.next())
						{
							sId = rs.getString(1);
							b = rs.getBytes(2);
							sName = (b==null)?null:new String(b, "UTF-8");
							%>
								<option value="<%=sId%>"<%=((sId.equals(sCampId))?" selected":"")%>><%= HtmlUtil.escape(sName) %></option>
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
					<td align="center" valign="middle">
						Name, as it will appear in <%= sTargetGroupDisplay %> Edit: <input type="hidden" name="filter_name" value="<%=HtmlUtil.escape(sFilterName)%>">
						<br>
						<b><span id="display_name"><%=HtmlUtil.escape(sFilterName)%></span></b>
					</td>
				</tr>

				<tr>
					<td align="center" valign="middle" >
						<input type="button" class="subactionbutton" onclick="history.back();" value="<< Back">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" onclick="window.close();" value="Cancel">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" name="save" value="Save >>" disabled onclick="do_submit();">&nbsp;&nbsp;
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
