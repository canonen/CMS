<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool		cp				= null;
Connection			conn 			= null;

boolean isDisable = false;

String WizardID = request.getParameter("wizard_id");
String putContID = "";
String CUSTOMER_ID = cust.s_cust_id;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("wizard_content.jsp");
	stmt = conn.createStatement();
	rs = stmt.executeQuery(	"SELECT c.cont_id, c.cont_name, cei.wizard_id" +
							" FROM ccnt_content c, ccnt_cont_edit_info cei" +
							" WHERE c.cust_id = " + CUSTOMER_ID +
							" AND c.status_id = 20" +
							" AND c.type_id = 20" +
							" AND c.origin_cont_id IS NULL" +
							" AND c.cont_id = cei.cont_id" +
							" AND cei.wizard_id = " + WizardID +
							" ORDER BY c.cont_id DESC");

	while( rs.next() )
	{
		putContID = rs.getString(1);
	}
	rs.close();
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"wizard_content.jsp",out,1);

}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn); 
}
%>

<html>
<head>
<title></title>
</head>
<body onload="window.parent.document.FT.cont_id.value = '<%= putContID %>';window.parent.moveSteps('4');">
</body>
</html>
