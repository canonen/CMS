<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.net.*,
			org.apache.log4j.*"
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

%>

<%
	String contID = request.getParameter("cont_id");
	String from = URLEncoder.encode(request.getParameter("from"),"UTF-8");
	String subjText = URLEncoder.encode(request.getParameter("subjText"),"UTF-8");
	String subjHtml = URLEncoder.encode(request.getParameter("subjHtml"),"UTF-8");
	String subjAol = URLEncoder.encode(request.getParameter("subjAol"),"UTF-8");
	String sRequestString=(contID==null)?"":"cont_id=" + contID + "&from=" + from + "&subjText=" + subjText + "&subjHtml=" + subjHtml + "&subjAol=" + subjAol;
 %>

<HTML>
<HEAD>
	<TITLE>RevoScore</TITLE>
	<%@ include file="../header.html" %>
</HEAD>
<FRAMESET rows="320,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="select" src="cont_score_1.jsp?<%=sRequestString%>">
	<FRAME name="score"  src="cont_score_2.jsp">
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
	</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>
