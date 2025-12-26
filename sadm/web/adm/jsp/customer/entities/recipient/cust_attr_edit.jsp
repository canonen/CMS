<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="/adm/jsp/header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
String sAttrId = BriteRequest.getParameter(request, "attr_id");

Attribute a = null;
CustAttr ca = null;
AttrCalcProps acp = null;

boolean bIsOwnwer = false;

if( sAttrId == null)
{
	a = new Attribute();
	ca = new CustAttr();
	acp = new AttrCalcProps();
	bIsOwnwer = true;
}
else
{
	a = new Attribute(sAttrId);
	ca = new CustAttr(sCustId, sAttrId);
	if(ca.s_display_name == null)
	{
		ca = new CustAttr(a.s_cust_id,a.s_attr_id);
		ca.s_display_seq = "1";
		//ca.s_sync_flag = null;
	}
	acp = new AttrCalcProps(sCustId, sAttrId);	
}

if(a.s_type_id==null) a.s_type_id = String.valueOf(DataType.VARCHAR_255);
if(a.s_scope_id==null) a.s_scope_id = String.valueOf(AttrScope.PUBLIC);

%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">
</HEAD>

<BODY>

<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="checkAttr();">Save</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
				<col width="200">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Custom Attribute Info</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form method="POST" action="cust_attr_save.jsp" name="cust_attr" onsubmit="alert(cust_attr.calc_values_flag); return true;">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="100">Cust Id</td>
								<td><input type="text" name="cust_id" size="50" readonly value="<%=sCustId%>"></td>
							</tr>
						<% if(ca.s_attr_id != null) { %>
							<tr>
								<td width="100">Attr Id</td>
								<td><input type="text" name="attr_id" size="50" readonly value="<%=ca.s_attr_id%>"></td>
							</tr>
						<% } %>
							<tr>
								<td width="100">Attr Name</td>
								<td><input type="text" name="attr_name" size="50" <%=(a.s_attr_id==null)?"":"disabled"%> value="<%=(a.s_attr_name==null)?"":a.s_attr_name%>"></td>
							</tr>
							<tr>
								<td width="100">Display Name</td>
								<td><input type="text" name="display_name" size="50" value="<%=(ca.s_display_name==null)?"":ca.s_display_name%>"></td>
							</tr>
							<tr>
								<td width="100">Type</td>
								<td>
									<select size="1" name="type_id" <%=(a.s_attr_id == null)?"":"disabled"%>>
										<%=DataType.toHtmlOptions(a.s_type_id)%>
 									</select>
								</td>
							</tr>
							<tr>
								<td width="100">Scope</td>
								<td>
									<select size="1" name="scope_id" <%=(a.s_attr_id == null)?"":"disabled"%>>
										<%=AttrScope.toHtmlOptions(a.s_scope_id)%>
 									</select>
								</td>
							</tr>
							<tr>
								<td width="100">Multi-Value</td>
								<td><input type="checkbox" name="value_qty" type="checkbox" <%=(a.s_value_qty==null)?"":"checked"%> <%=(ca.s_attr_id == null)?"":"disabled"%>></td>
							</tr>
							<tr>
								<td width="100">Fingerprint</td>
								<td><input type="checkbox" name="fingerprint_seq" disabled <%=(ca.s_fingerprint_seq==null)?"":"checked"%>></td>
							</tr>
							<tr>
								<td width="100">Internal</td>
								<td><input type="checkbox" value="1" name="internal_flag" <%=(a.s_internal_flag==null)?"":"checked"%>></td>
							</tr>
						<!--
							<tr>
								<td width="100">Create values list</td>
								<td>
									<select size="1" name="calc_values_flag">
										<option value="0" <%=("0".equals(acp.s_calc_values_flag))?"selected":""%>>No</option>			
										<option value="-1" <%=("-1".equals(acp.s_calc_values_flag))?"selected":""%>>Never</option>
										<option value="1" <%=("1".equals(acp.s_calc_values_flag))?"selected":""%>>Yes</option>			
									</select>			
								</td>
							</tr>
						-->
							<tr>
								<td width="100">Display seq</td>
								<td><input type="text" name="display_seq" size="50" value="<%=(ca.s_display_seq==null)?"":ca.s_display_seq%>"></td>
							</tr>
							<tr>
								<td width="100">Description</td>
								<td>
									<textarea rows="5" name="descrip" cols="40"<%=((sCustId.equals(a.s_cust_id))?"":" disabled")%>><%=(a.s_descrip==null)?"":a.s_descrip%></textarea>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="100">Synchronize</td>
								<td><input type="checkbox" name="sync_flag" value="1" <%=(ca.s_sync_flag==null || ca.s_sync_flag.equals("0"))?"":"checked"%>></td>
							</tr>
							<tr>
								<td width="100">Keep update history</td>
								<td><input type="checkbox" name="hist_flag" value="1" <%=(ca.s_hist_flag==null || ca.s_hist_flag.equals("0"))?"":"checked"%>></td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
<SCRIPT>
function checkAttr ()
{
	cust_attr.attr_name.value = cust_attr.attr_name.value.replace(/(^\s*)|(\s*$)/g, '');
	cust_attr.display_name.value = cust_attr.display_name.value.replace(/(^\s*)|(\s*$)/g, '');

	if (cust_attr.attr_name.value.length == 0) { alert("You must include an attr_name"); return false; }
	if (cust_attr.display_name.value.length == 0) { alert("You must include a display_name"); return false; }
	if (!cust_attr.display_name.value.substring(0,1).match("[a-z]|[A-Z]")) { alert("Field Name should start with letter (a-z).") }
	if (cust_attr.attr_name.value.match(/\W/)) { alert("attr_name can only contain alphanumeric characters (a-z, 0-9) and underscores (_) with no spaces."); return false; }
	
	cust_attr.submit()
}
</SCRIPT>

</BODY>
</HTML>
