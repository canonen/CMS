<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
int custID = Integer.parseInt(cust.s_cust_id);

String contentID = request.getParameter("contentID");
if (contentID != null)
	PageBean.delete(custID, Integer.parseInt(contentID),application.getInitParameter("ImagePath"),user.s_user_id);

response.sendRedirect("index.jsp");
%>


