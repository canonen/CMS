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
				filter_form.action = "save.jsp";
				filter_form.submit();
				return true;
			}
		}

		function validate_params()
		{
//			val = filter_form.integer_value[0].value;
//			if((val == null)||(val == ''))
//			{
//				filter_form.save.disabled = true;
//				return;
//			}
//			val = filter_form.integer_value[1].value;
//			if((val == null)||(val == ''))
//			{
//				filter_form.save.disabled = true;
//				return;
//			}
//			filter_form.save.disabled = false;
//			
//			var filName = "";
//			var selItem = 0;
//			
//			selItem = filter_form.integer_value[0].selectedIndex;
//			var val1 = filter_form.integer_value[0][selItem].text;
//			
//			selItem = filter_form.integer_value[1].selectedIndex;
//			var val2 = filter_form.integer_value[1][selItem].text;
//			
//			filter_form.filter_name.value = "(CAMPAIGN-FORM) " + val1 + " - " + val2;
//			display_name.innerText = "(CAMPAIGN-FORM) " + val1 + " - " + val2;
		}
		
		function doOptionChange(obj, id)
		{
			input = document.getElementById("entity_input_id_" + id + "_value2");
			if(obj.value == 'between')
			{
				input.style.display = '';
			}
			else
			{
				input.style.display = 'none';
			}
		}
		
		function resizeWin()
		{
			top.window.resizeTo(850, 300);
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
	String sFilterId = request.getParameter("filter_id");
	String sEntityId = request.getParameter("entity_id");	
	String sFilterName = null;
	FilterParams fps = new FilterParams();
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		fps.s_filter_id = sFilterId;
		fps.retrieve();
		sEntityId = fps.getIntegerValue("entity_id");
%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
<%
	}
%>
<INPUT type=hidden name="type_id" value="<%=FilterType.ENTITY%>">
<INPUT type=hidden name="usage_type_id" value="<%=sUsageTypeId%>">

<input type=hidden name="param_name" value="entity_id">
<input type=hidden name=integer_value value="<%=sEntityId%>">				
<input type=hidden name=string_value value="">
<input type=hidden name=date_value value="">

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
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						Filter name: <INPUT type=text size=50 name="filter_name" value="<%=HtmlUtil.escape(sFilterName)%>">
					</td>
				</tr>
			</table>
			<br>
			
<!-- === === === -->

<table class=main cellspacing=1 cellpadding=2 width="100%">
<%
	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	
	try
	{
		String sSql =
			" SELECT attr_id, attr_name," +
			" CASE" +
			"	WHEN type_id = 10 THEN 'INTEGER'" +
			"	WHEN type_id = 20 THEN 'STRING'" +
			"	WHEN type_id = 30 THEN 'DATETIME'" +
			"	WHEN type_id = 40 THEN 'IMAGE'" +
			"	WHEN type_id = 50 THEN 'MONEY'" +
			"	ELSE 'UMNKNOWN'" +
			" END" +
			" FROM cntt_entity_attr" +
			" WHERE entity_id = " + sEntityId +
			" AND type_id < 100" +
			" AND ISNULL(internal_id_flag,0)=0" +
			" ORDER BY attr_id";

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		pstmt = conn.prepareStatement(sSql);
		ResultSet rs = pstmt.executeQuery();

		String sId = null;
		String sName = null;
		String sTypeName = null;
		String sCompareOperation = null;
		String sAttrValue = null;
		String sParamName = null;
		String sInputId = null;
				
		byte[] b = null;

		while (rs.next())
		{
			sId = rs.getString(1);
			b = rs.getBytes(2);
			sName = (b==null)?null:new String(b, "UTF-8");
			sTypeName = rs.getString(3);
%>
	<tr>
		<td align="center" valign="middle" style="padding:10px;" nowrap>
			<%sParamName = "entity_attr_id";%>
			<input type=hidden name="param_name" value="<%=sParamName%>">
			<input type=hidden name=integer_value value="<%=sId%>">				
			<input type=hidden name=string_value value="">
			<input type=hidden name=date_value value="">
			<%=sName%> (<%=sTypeName%>)
		</td>
		<td>
			<%sParamName = "entity_attr_id_" + sId + "_compare_operation";%>
			<input type=hidden name="param_name" value="<%=sParamName%>">
			<input type=hidden name=integer_value value="">
			<input type=hidden name=date_value value="">
			<%sCompareOperation = fps.getStringValue(sParamName);%>				
			<select size=1 name=string_value onchange="doOptionChange(this, <%=sId%>)">
				<option value="="<%=("=".equals(sCompareOperation)?" selected":"")%>>Equal To (=)</option>
				<option value="&gt;"<%=(">".equals(sCompareOperation)?" selected":"")%>>Greater Than (&gt;)</option>
				<option value="&gt;="<%=(">=".equals(sCompareOperation)?" selected":"")%>>Greater Than Or Equal To (&gt;=)</option>
				<option value="&lt;"<%=("<".equals(sCompareOperation)?" selected":"")%>>Less Than (&lt;)</option>
				<option value="&lt;="<%=("<=".equals(sCompareOperation)?" selected":"")%>>Less Than Or Equal To (&lt;=)</option>
				<option value="between"<%=("between".equals(sCompareOperation)?" selected":"")%>>Between</option>
				<option value="like"<%=("like".equals(sCompareOperation)?" selected":"")%>>LIKE</option>
			</select>
		</td>
		<td>
			<%sParamName = "entity_attr_id_" + sId + "_value";%>
			<input type=hidden name="param_name" value="<%=sParamName%>">
			<input type=hidden name=integer_value value="">
			<input type=hidden name=date_value value="">
			<%sAttrValue = fps.getStringValue(sParamName);%>			
			<INPUT type=text size=40 name="string_value" value="<%=HtmlUtil.escape(sAttrValue)%>"/>
			<%sParamName = "entity_attr_id_" + sId + "_value2";%>
			<%sInputId = "entity_input_id_" + sId + "_value2";%>
			<input type=hidden name="param_name" value="<%=sParamName%>">
			<input type=hidden name=integer_value value="">
			<input type=hidden name=date_value value="">
			<%sAttrValue = fps.getStringValue(sParamName);%>			
			<INPUT id="<%=sInputId%>" type=text size=40 name="string_value" value="<%=HtmlUtil.escape(sAttrValue)%>" style="display: <%=("between".equals(sCompareOperation)?"":"none")%>"/>	
		</td>
	</tr>
<%
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		if(pstmt != null) pstmt.close();
		if(conn != null) cp.free(conn);
	}
%>		
</table>

<!-- === === === --->

			<br>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
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
