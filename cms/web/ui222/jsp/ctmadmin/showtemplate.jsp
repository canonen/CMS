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
String tempID = request.getParameter("temp_id");
TemplateBean tbean = (TemplateBean)tbeans.get(Integer.valueOf(tempID));
%>

<html>
<body>

<table border=1>
<tr>
<th>HTML:</th>
<td><textarea rows=10 cols=80 wrap=off><%= tbean.getTemplate("html") %></textarea></td>
</tr>
<tr>
<th>Text:</th>
<td><textarea rows=10 cols=80 wrap=off><%= tbean.getTemplate("txt") %></textarea></td>
</tr>
</table>

</body>
</html>