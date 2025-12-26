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
String sEntityId = BriteRequest.getParameter(request, "entity_id");

Entity e = new Entity();

if( sEntityId == null)
{
	e.s_cust_id = sCustId;
	e.s_entity_name = "entity_name";
}
else
{
	e.s_entity_id = sEntityId;
	e.retrieve();
}
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
<% if(sEntityId == null) { %>
						<a class="savebutton" href="#" onclick="validate_and_submit();">Save</a>&nbsp;&nbsp;&nbsp;
<% } %>	
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Entity definition</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
<!-- === === == -->					

<form method="POST" action="entity_save.jsp" name="entity_form">
<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
	<tr>
		<td>
			<H5>
			<BR>
			WARNING!<BR>
			This UI is not "idiot proof" (for now).<BR>
			So YOU are responsible for what you are doing.<BR>
			All names in ASCI only! Use lower case - underscore notation!<BR>
			Renaming entities and attributes will screw everyting up!<BR>
			No reserved words!<BR>
			For right now Entity can handle only one attribute of type recipient (what is enough for MBS),<BR>
			so do not create something 'fancy', till special anouncement.<BR>
			Good luck.
			</H5>
		</td>
	</tr>
</table>
<hr>
<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
	<tr>
		<td>Cust Id</td>
		<td><input type="text" name="cust_id" readonly value="<%=e.s_cust_id%>"></td>
	</tr>
<% if(e.s_entity_id != null) { %> 
	<tr>
		<td>Entity Id</td>
		<td><input type="text" name="entity_id" readonly value="<%=e.s_entity_id%>"></td>
	</tr>
<% } %>
</table>
<hr>
<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
	<tr>
		<td>
			<select name="scope_id" disabled>
				<option value="0">system internal</option>
				<option value="100">private</option>
				<option value="300" selected>public</option>				
			</select>
			&nbsp;entity&nbsp;
			<input type="text" name="entity_name" value="<%=e.s_entity_name%>">
			&nbsp;extends&nbsp;
			<select name="parent_entity" disabled>
				<option>nothing for now</option>
			</select>
		</td>
	</tr>
<% if(e.s_entity_id != null) { %> 
<tr>	
		<td>
<H2>{</H2>
<BLOCKQUOTE>
<table class="main" border="0" cellspacing="1" cellpadding="3">
	<tr>
		<th>Scope</th>
		<th>Type</th>
		<th>Name</th>
		<td></td>	
		<th>fp</th>			
	</tr>
<%
EntityAttrs eas = new EntityAttrs();
eas.s_entity_id = e.s_entity_id;
eas.retrieve();

EntityAttr ea = null;
for (Enumeration en = eas.elements() ; en.hasMoreElements() ;)
{
	ea = (EntityAttr) en.nextElement();
%>
	
	<tr>
		<td>
			<select size="1" name="scope_id" <%=(ea.s_attr_id == null)?"":"disabled"%>>
				<option value="0" selected>system internal</option>			
				<%=AttrScope.toHtmlOptions()%>
			</select>
		</td>
		<td>		
			<select size="1" name="type_id" <%=(ea.s_attr_id == null)?"":"disabled"%>>
				<%=DataType.toHtmlOptions()%>
			</select>
		</td>
		<td>		
			<input type="text" name="attr_name" value="<%=ea.s_attr_name%>">
		</td>
		<td></td>
		<td><input type="checkbox" name="finerprint_seq" value="<%=ea.s_fingerprint_seq%>"></td>		
	</tr>
<%
}
%>
	<tr>
		<td colspan=5>
<a class="subactionbutton" href="javascript:add_attr();">Add entity attribute</a>		
		</td>				
	</tr>
</table>
</BLOCKQUOTE>
<H2>}</H2>
<% } %>
</form>

<!-- === === == -->

					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
<SCRIPT>

function add_attr()
{
	alert("add_attr!");
}

function validate_and_submit()
{
	entity_form.entity_name.value = entity_form.entity_name.value.replace(/(^\s*)|(\s*$)/g, '');

	if (entity_form.entity_name.value.length == 0)
	{
		alert("You must include an entity_name");
		return false;
	}
	
	if (!entity_form.entity_name.value.substring(0,1).match("[a-z]|[A-Z]"))
	{
		alert("Field Name should start with letter (a-z).")
		return false;		
	}
	
	if (entity_form.entity_name.value.match(/\W/))
	{
		alert("attr_name can only contain alphanumeric characters (a-z, 0-9) and underscores (_) with no spaces.");
		return false;
	}
	
	entity_form.submit()
}
</SCRIPT>

</BODY>
</HTML>
