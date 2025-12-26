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
<%@ include file="../../header.jsp" %>

<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
Customer cust = new Customer(sCustId);
if( cust.s_cust_id == null) {
	logger.error(this.getClass().getName() + ": cust_id is null");
	throw new Exception(this.getClass().getName() + ": cust_id is null");
}
%>
<HTML>

<HEAD>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>

<BODY>
<br><br><br>
<table class="listTable" width="260" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap colspan=2>Img Cust File Extensions</th>
	</tr>
<%
ImgCustFileExtensions icfes = new ImgCustFileExtensions();
icfes.s_cust_id = sCustId;
int iCount = icfes.retrieve();

ImgCustFileExtension icfe = null;
for (Enumeration e = icfes.elements() ; e.hasMoreElements() ;)
{
	icfe = (ImgCustFileExtension)e.nextElement();
%>
	<tr>
		<TD width="99%"><%=HtmlUtil.escape(icfe.s_file_extension)%></TD>
		<TD align="right"><a href="img_cust_file_extension_delete.jsp?cust_id=<%=icfe.s_cust_id%>&file_extension=<%=icfe.s_file_extension%>">Delete</a></td>
	</tr>
<%
}
if (iCount == 0)
{
%>
	<tr>
		<td class="listItem_Data" colspan=2>There are currently no  Image File Extensions</td>
	</tr>
<%
}
%>
</table>
<BR>
<FORM action="img_cust_file_extension_save.jsp">
<INPUT type="hidden" name="cust_id" value=<%=sCustId%>>
<table class="listTable" width="260" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap colspan=2>Add New Img Cust File Extension</th>
	</tr>
	<tr>
		<TD width="99%"><INPUT type="text" name="file_extension"></TD>
		<TD align="right"><INPUT type=submit value=Add></td>
	</tr>
</table>
</FORM>	
</BODY>
</HTML>
