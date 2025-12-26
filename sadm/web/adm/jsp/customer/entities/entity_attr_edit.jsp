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
String sEntityId = BriteRequest.getParameter(request, "entity_id");
String sAttrId = BriteRequest.getParameter(request, "attr_id");

EntityAttr ea = new EntityAttr();

if( sAttrId == null)
{
	ea.s_entity_id = sEntityId;
}
else
{
	ea.s_attr_id = sAttrId;
	ea.retrieve();
}

if(ea.s_type_id==null) ea.s_type_id = "20";
if(ea.s_scope_id==null) ea.s_scope_id = "300";

Entity e = new Entity(ea.s_entity_id);

%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../css/style.css" TYPE="text/css">
</HEAD>

<BODY>

<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="validate_and_submit();">Save</a>&nbsp;&nbsp;&nbsp;
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Entityom Attribute Info</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">

<!-- === === === -->

<form method="POST" action="entity_attr_save.jsp" name="entity_attr_form">
<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
	<tr>
		<td width="100">Entity Id</td>
		<td><input type="text" name="entity_id" size="50" readonly value="<%=ea.s_entity_id%>"></td>
	</tr>
<% if(ea.s_attr_id != null) { %>
	<tr>
		<td width="100">Attr Id</td>
		<td><input type="text" name="attr_id" size="50" readonly value="<%=ea.s_attr_id%>"></td>
	</tr>
<% } %>
	<tr>
		<td width="100">Attr Name</td>
		<td><input type="text" name="attr_name" size="50" value="<%=HtmlUtil.escape(ea.s_attr_name)%>"></td>
	</tr>
	<tr>
		<td width="100">Type</td>
		<td>
			<select size="1" name="type_id">
				<%=getEntityOptions(e.s_cust_id, ea.s_type_id)%>
			</select>
		</td>
	</tr>
	<tr>
		<td width="100">Scope</td>
		<td>
			<select size="1" name="scope_id">
				<OPTION value=300>public</OPTION>			
				<OPTION value=0<%=(("0".equals(ea.s_scope_id))?" selected":"")%>>system internal</OPTION>
			</select>
		</td>
	</tr>
	<tr>
		<td width="100">Fingerprint</td>
		<td><input type="checkbox" name="fingerprint_seq" value="1"<%=(ea.s_fingerprint_seq==null)?"":" checked"%>></td>
	</tr>
	<tr>
		<td width="100">Internal id flag</td>
		<td><input type="checkbox" name="internal_id_flag" value="1"<%=(ea.s_internal_id_flag==null)?"":" checked"%>></td>
	</tr>
</table>
</form>

<!-- === === === -->

					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>

<SCRIPT>

function validate_and_submit()
{
	entity_attr_form.attr_name.value = entity_attr_form.attr_name.value.replace(/(^\s*)|(\s*$)/g, '');

	if (entity_attr_form.attr_name.value.length == 0)
	{
		alert("You must include an attr_name");
		return false;
	}
	
	if (!entity_attr_form.attr_name.value.substring(0,1).match("[a-z]|[A-Z]"))
	{
		alert("attr_name should start with letter (a-z).")
		return false;		
	}
	
	if (entity_attr_form.attr_name.value.match(/\W/))
	{
		alert("attr_name can only contain alphanumeric characters (a-z, 0-9) and underscores (_) with no spaces.");
		return false;
	}

	entity_attr_form.submit()
}
</SCRIPT>

</BODY>
</HTML>

<%!
private String getEntityOptions(String sCustId, String sSelectedEntityId) throws Exception
{
	String sOptions = "";

	Entities entities = new Entities();

	entities.s_cust_id = "0";
	entities.retrieve();

	entities.s_cust_id = sCustId;
	entities.retrieve();

	Entity entity = null;
	boolean bSelected = false;
	for (Enumeration e = entities.elements() ; e.hasMoreElements() ;)
	{
		entity = (Entity)e.nextElement();
		bSelected = entity.s_entity_id.equals(sSelectedEntityId);
		sOptions +=
			"<OPTION value=" + entity.s_entity_id + ((bSelected)?" selected":"") + ">" +
			entity.s_entity_name +
			"</OPTION>";
	}

	return sOptions;
}
%>