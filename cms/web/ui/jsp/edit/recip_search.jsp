<%@ page

	language="java"
	import="com.britemoon.cps.*,
		com.britemoon.*,
		java.util.*,java.sql.*,
		java.net.*,org.apache.log4j.*"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
boolean bCanRead = can.bRead;

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;


try	{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("recip_search.jsp");
	stmt = srvConnection.createStatement();

%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<HTML>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>		
</HEAD>
<BODY class="paging_body">

<div class="page_header"><fmt:message key="header_contact"/></div>
<div class="page_desc"><fmt:message key="header_contact_desc"/></div>


<FORM  METHOD="POST" NAME="FT" ACTION="recip_edit_list.jsp" TARGET="result" style="display:inline;">
<INPUT TYPE="hidden" NAME="num_recips" VALUE="100">

<table cellspacing="0" cellpadding="0" width="90%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			
			<table class=listTable cellspacing=0 cellpadding=0>
				<tr>
					<th align="left" valign="middle" nowrap><fmt:message key="search_by_email"/> </th>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>
						<input class="inputtexts" type="text" name="email" value="" size="42" <%=(!bCanRead)?"disabled":""%>> 
						<a class="button_res" href="#" onClick="try_submit(FT.email.value, '');" <%=(!bCanRead)?"disabled":""%>>Search</a>
					</td>
				</tr>
			</table>
			</br>
				<table class=listTable cellspacing=0 cellpadding=0>
				<tr>
					<th align="left" valign="middle" nowrap><fmt:message key="search_by_lastname"/></th>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>
						<input class="inputtexts" type="text" name="lastname" value="" size="42" <%=(!bCanRead)?"disabled":""%>>
						<a class="button_res" href="#" onClick="try_submit('', FT.lastname.value);" <%=(!bCanRead)?"disabled":""%>>Search</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</FORM>
</HTML>
</BODY>
</fmt:bundle>
<SCRIPT>

function try_submit (param1, param2) {

 param1 = param1.replace(/(^\s*)|(\s*$)/g, '');
 param2 = param2.replace(/(^\s*)|(\s*$)/g, '');

 if (param1 == "" && param2 == "") {
	alert ("Field is empty - nothing to look for");  	return 0;
 }

 if( param1 == "" ) FT.email.value	= "";
 if( param2 == "" ) FT.lastname.value	= "";

 FT.submit ();
}
</SCRIPT>
<%
} catch(Exception ex) { 
	ErrLog.put(this,ex,"Problem with Recipient Search",out,1);
} finally {

	if ( srvConnection  != null ) 
		connectionPool.free (srvConnection); 
}
%>

