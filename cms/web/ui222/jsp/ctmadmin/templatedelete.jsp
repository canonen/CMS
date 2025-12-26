<%@ page import="java.util.*"
		 import="com.britemoon.*"
 		 import="com.britemoon.cps.*"
		 import="com.britemoon.cps.ctm.*"
		 import="org.apache.log4j.*" 
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />

<%

String templateID = request.getParameter("templateID");

//get it from the hashtable
TemplateBean tbean = (TemplateBean)tbeans.get(new Integer(templateID));

//delete it from the db
if (tbean.delete()) {
	//Remove it from the Hashtable
	tbeans.remove(new Integer(templateID));
	response.sendRedirect("index.jsp");
}

%>

<html>
<head>
<title>Can't Delete Template</title>
</head>
<body>

Can't delete <%= tbean.getTemplateName() %>.  There are pages using this template.
<br><br>
Please delete all of the pages that use this template before deleting this template.
<br><br>
<b>Deleted pages are only marked as deleted.  <br>You must go into the database and manually
delete all of the pages.</b>
</body>
</html>
