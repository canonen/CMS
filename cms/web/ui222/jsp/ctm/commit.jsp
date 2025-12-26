<%@ page 
          language="java"
          import="com.britemoon.*"
          import="com.britemoon.cps.*"
          import="com.britemoon.cps.ctm.*" 
          import="org.apache.log4j.*"
          import="java.io.*"
          import="java.util.*"
          import="java.sql.*"
          import="java.net.*" 
          errorPage="../error_page.jsp"
          contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
String isWizard = (String)session.getAttribute("isWizard");
if (isWizard == null || isWizard.length() == 0) {
    isWizard = "0";
}
int custID = Integer.parseInt(cust.s_cust_id);
int userID = Integer.parseInt(user.s_user_id);

String contentID = request.getParameter("contentID");
if (contentID == null) {
%>
Need to supply a contentID
<%
	return;
}

ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

connPool = ConnectionPool.getInstance();
conn = connPool.getConnection("commit.jsp");
stmt = conn.createStatement();

//commit content 
String sPath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
String sUrl = sPath + "/imc/cont_setup.jsp";
URL uContSetup = new URL(sUrl+"?contentID="+contentID+"&customerID="+custID+"&userID="+userID+"&scanLink=1");
logger.info("Committing..." + uContSetup.toString());

BufferedReader brResponse = new BufferedReader(new InputStreamReader(uContSetup.openStream()));
String inputLine, inputText = "";
while ((inputLine = brResponse.readLine()) != null)
	    inputText += inputLine+"\n";
brResponse.close();

if (inputText.indexOf("ERROR") != -1) {  // an error occurred during cont_setup.jsp
     throw new Exception("Error occurred during cont_setup.jsp.");
} else {
     if (stmt.executeUpdate("UPDATE ctm_pages set status = 'committed' WHERE content_id =" + contentID) != 1) {
          throw new Exception("Error setting template status from commit.jsp.");
     }
}
stmt.close();
if (conn != null) connPool.free(conn);

if ("1".equals(isWizard)) {
%>
<html>
<head>
<title></title>
</head>
<body onload="location.href='/cms/ui/jsp/wizard/wizard_content.jsp?wizard_id=<%= contentID %>';"></body>
</html>
<%
}
else {
	response.sendRedirect("index.jsp");
}
%>
