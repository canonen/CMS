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
	<BASE target="main_03">
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
	<a class="savebutton" href="#" onclick="validate_and_submit(); return false;">Save</a>&nbsp;&nbsp;&nbsp;
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
		<td nowrap>
			<select name="scope_id" disabled>
				<option>public</option>				
			</select>
			&nbsp;entity&nbsp;
			<input type="text" name="entity_name" value="<%=e.s_entity_name%>">
<!--
			&nbsp;extends&nbsp;
			<select name="parent_entity_id" disabled>
				<option>nothing for now</option>
			</select>
-->
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
		<td></td>		
		<th>Type</th>
		<td></td>		
		<th>Name</th>
		<td></td>
		<th>fp</th>			
	</tr>
<%
	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	try
	{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();

			String sAttrId = null;
			String sScopeName = null;
			String sEntityName = null;
			String sAttrName = null;			
			String sInternalIdFlag = null;
			String sFingerprintSeq = null;

			String sSQL =
				" SELECT" +
				" 	attr_id," +
				" 	scope_name, " +				
				" 	entity_name," +
				" 	attr_name," +
				" 	internal_id_flag," +
				" 	fingerprint_seq" +
				" FROM" +
				" 	sntt_entity_attr ea," +
				" 	sntt_entity e," +
				" 	sntt_scope es" +
				" WHERE" +
				" 	ea.type_id = e.entity_id AND" +
				" 	ea.scope_id = es.scope_id AND" +
				"	ea.entity_id = " + sEntityId +				
				" ORDER BY attr_id";

			ResultSet rs = stmt.executeQuery(sSQL);

			byte[] b = null;
			while(rs.next())
			{
				sAttrId = rs.getString(1);

				b = rs.getBytes(2);
				sScopeName = (b==null)?null:new String(b, "UTF-8");

				b = rs.getBytes(3);
				sEntityName = (b==null)?null:new String(b, "UTF-8");

				b = rs.getBytes(4);
				sAttrName = (b==null)?null:new String(b, "UTF-8");
				
				sInternalIdFlag = rs.getString(5);
				sFingerprintSeq = rs.getString(6);				
%>
	<tr>
		<td nowrap><%=sScopeName%></td>
		<td></td>		
		<td nowrap><%=sEntityName%></td>
		<td></td>		
		<td nowrap><a href="entity_attr_edit.jsp?attr_id=<%=sAttrId%>"><%=sAttrName%></td>
		<td></td>
		<td><input type="checkbox"<%=((sFingerprintSeq == null)?"":" checked")%>></td>		
	</tr>
<%
			}
			rs.close();
	}
	catch(Exception ex) { logger.error("Exception: ",ex); }
	finally
	{
		if(stmt!=null) stmt.close();
		if(conn!=null) cp.free(conn);
	}
%>
</table>
<BR>
<a class="subactionbutton" href="entity_attr_edit.jsp?entity_id=<%=e.s_entity_id%>">Add entity attribute</a>
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

	entity_form.submit();
}

</SCRIPT>

</BODY>
</HTML>
