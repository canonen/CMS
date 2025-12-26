<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.upd.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
    System.out.println("my test");
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

ServletInputStream in = request.getInputStream();
HashMap aImportParameters = ImportUtil.downloadImport(in, cust.s_cust_id);
String sImportName = request.getParameter("import_name").toString().trim();
String sBatchId = request.getParameter("batch_id").toString().trim();
out.print("hello world1");
%>