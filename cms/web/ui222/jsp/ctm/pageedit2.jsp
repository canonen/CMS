<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.sql.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
PageBean pbean = (PageBean)session.getAttribute("pbean");

int custID = Integer.parseInt(cust.s_cust_id);

ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

String status = null;
try
{
	connPool = ConnectionPool.getInstance();
	conn = connPool.getConnection("index.jsp");
	stmt = conn.createStatement();

	rs = stmt.executeQuery(
		"SELECT status" +
		" FROM ctm_pages p" +
		" WHERE p.template_id = " + (pbean.getTemplateBean()).getTemplateID() +
		" AND p.content_id = " + pbean.getContentID() +
		" AND p.customer_id = " + custID);
	
	if (rs.next()) status = rs.getString(1);
	rs.close();
}
catch (SQLException e) 
{ 
	throw e; 
}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) connPool.free(conn);
}

boolean isEdit = (Boolean.valueOf(request.getParameter("isEdit")).booleanValue() && (!"locked".equals(status)));
String imageURL = application.getInitParameter("ImageURL");
String previewType = request.getParameter("previewType");
if (previewType.equals("txt")) {
	%>
	<textarea cols=80 rows=40>
<%= WebUtils.removeHTMLtags2(pbean.createTemplateForm(previewType, "sectionedit.jsp", imageURL, isEdit)) %>
	</textarea>
	<%
} else {
	%>
	<%-- pbean.getTemplateBean().getTemplate("html") --%>
<%= pbean.createTemplateForm(previewType, "sectionedit.jsp", imageURL, isEdit) %>
	<%
}
%>
