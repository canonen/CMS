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
String src="cont_preview_2.jsp?cont_id="+contID;
 
if (iType == ContType.PRINT)
{
	src="cont_preview_3.jsp?cont_id"+contID;
	response.sendRedirect(src);
}
	response.sendRedirect(src);
%>


	<FRAME name="select" src="cont_preview_1.jsp?<%=sRequestString%>">