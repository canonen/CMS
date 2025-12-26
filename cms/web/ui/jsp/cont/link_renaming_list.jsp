<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.util.Vector,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if (!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

%>
<%
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("ccnt_link_renaming.jsp");
	stmt = conn.createStatement();	
	String link_id, link_name, link_type_id, link_type, link_definition;
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
function launchURL()
{
	var oElem = window.event.srcElement;
	while (oElem.tagName != "A") oElem = oElem.parentElement;
	var newURL = oElem.innerText;
	CheckURLWin = window.open(newURL, "CheckURL","scrollbars=yes,resizable=yes,location=yes,toolbar=yes,status=yes,menubar=yes,height=400,width=600");
}
</script>
</HEAD>
<BODY>
<%
if (can.bWrite) {
%>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="newbutton" href="link_renaming_new.jsp">New Auto Link Name</a>
		</td>
	</tr>
</table>
<br>
<%
}
%>
<FORM  METHOD="POST" NAME="FT" ACTION="">
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Auto Link Names&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Auto Name</th>
					<th>Match Type</th>
					<th>URL To Match</th>
				</tr>
			<%
			String sSql = "EXEC usp_ccnt_link_renaming_list_get " + cust.s_cust_id;
									
			rs = stmt.executeQuery(sSql);
				
			String sClassAppend = "";
			int i = 0;
			
			while( rs.next() ) {
				
				if (i % 2 != 0)	sClassAppend = "_Alt";
				else sClassAppend = "";

				i++;
				
				link_id = rs.getString(1);
				link_name = new String(rs.getBytes(2),"UTF-8");
				link_type_id = rs.getString(3);
				link_type = new String(rs.getBytes(4),"UTF-8");
				link_definition = new String(rs.getBytes(5),"UTF-8");

				if (link_type_id.equals("1")) {
					link_definition = "<div style=\"overflow:hidden; text-overflow:ellipsis; width:400px;\"><a title=\"Click here to verify that your link is valid.\" href=\"javascript:void(0);\" onclick=\"launchURL();\">"+HtmlUtil.escape(link_definition)+"</a></div>";
				}

				%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>"><a HREF="link_renaming_edit.jsp?link_id=<%= link_id %>"><%= link_name %></a></td>
					<td class="listItem_Title<%= sClassAppend %>"><%= link_type %></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= link_definition %></td>
				</tr>
				<%
			}
			rs.close();
				
			if (i == 0)
			{
				%>
				<tr>
					<td class="listItem_Data" colspan="2">There are currently no Auto Link Names</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</FORM>
</BODY>
</HTML>
<%
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn  != null) cp.free(conn); 
}
%>
