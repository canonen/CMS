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

<%-- Loads the tbeans application scope hashtable --%>

<%

Enumeration eAttrNames = application.getAttributeNames();
String names = "";
while (eAttrNames.hasMoreElements()) names += eAttrNames.nextElement() + "<br>\n";

Hashtable tbeans;
tbeans = TemplateBean.loadAllTemplates();
application.setAttribute("tbeans", tbeans);

%>

<html>
<body>
The bean has been loaded!!<br><br>

<%
Enumeration keys = tbeans.keys();
Enumeration values = tbeans.elements();

TemplateBean tbean;
while (keys.hasMoreElements())
{
	tbean = (TemplateBean)values.nextElement();
%>
	<li><a href=pageedit.jsp?templateID=<%= keys.nextElement() %>><%= tbean.getTemplateName() %></a>	
<%
}
%>

<br><br>
<hr>
Number of Template(s) = <%= tbeans.size() %>
<hr>
<%= names %>

</body>
</html>


