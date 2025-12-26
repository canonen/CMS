<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
boolean HYATTUSER = (ui.n_ui_type_id == UIType.HYATT_USER);

if(!can.bRead && !HYATTUSER)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String contID = request.getParameter("cont_id");
String sRequestString=(contID==null)?"":"cont_id=" + contID;

Content cont = new Content(contID);
String sTypeID = cont.s_type_id;
int iType = Integer.parseInt(sTypeID);

if (iType == ContType.PRINT)
{
	response.sendRedirect("../print/login.jsp?cont_id=" + contID + "&action=ViewDocument");
	return;
}
%>

<HTML>

<HEAD>
	<TITLE>Content Preview</TITLE>
	<%@ include file="../header.html" %>
</HEAD>

<FRAMESET rows="300,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="select" src="cont_preview_1.jsp?<%=sRequestString%>">
	<FRAME name="preview" src="cont_preview_2.jsp">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
