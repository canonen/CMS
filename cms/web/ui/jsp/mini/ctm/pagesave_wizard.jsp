<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.sql.*"
	import="java.util.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<%
BNetPageBean pbean = (BNetPageBean)session.getAttribute("pbean");

int custID = Integer.parseInt(cust.s_cust_id);
int userID = Integer.parseInt(user.s_user_id);

String returnURL = request.getParameter("returnURL");
if (returnURL == null) returnURL = "pageedit.jsp?templateID="+pbean.getTemplateBean().getTemplateID();

String pageName = request.getParameter("pageName");
String sendType = request.getParameter("sendType");

String rename = request.getParameter("rename");

if ((pbean.getPageName().length() != 0 || (pageName != null && pageName.length() != 0)) && rename == null) {
	if (pageName != null && pageName.length() != 0) {
		pbean.setPageNameAndType(pageName, Integer.parseInt(sendType));
	}

	pbean.save(userID, (String)session.getAttribute("userName"), -1);
	
	String oldContentID = request.getParameter("oldContentID");
	if (oldContentID != null) {
		WebUtils.copyImages(application.getInitParameter("ImagePath")+pbean.getCustID()+"\\", Integer.parseInt(oldContentID), pbean.getContentID());
	}

	response.sendRedirect(returnURL);
	return;
}

String nameValue = "";
if (rename != null) {
	nameValue = WebUtils.htmlEncode(pbean.getPageName());
}

String oldContentID = request.getParameter("oldContentID");

//Grab this customer's pages from the db
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

connPool = ConnectionPool.getInstance();
conn = connPool.getConnection("pagesave.jsp");
stmt = conn.createStatement();


rs = stmt.executeQuery("SELECT send_type_id, send_type_name FROM ctm_send_type");

String sendTypeSelectBox = "";
String isSelected = "";
int curID;
while (rs.next()) {
	curID = rs.getInt(1);
	if (curID == pbean.getSendType()) isSelected = " selected";
	else isSelected = "";

	sendTypeSelectBox += "<option value=\""+curID+"\""+isSelected+">"+rs.getString(2)+"</option>\n";
}

//Free the db connection
rs.close();
stmt.close();
if (conn != null) connPool.free(conn);

//If no name in pbean and no name supplied by user, ask for a name

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}
%>

<html>
<head>
<title>Page Name</title>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>

<body>
<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle"><a class="savebutton" href="javascript:FT.submit();">Save</a>&nbsp;&nbsp;&nbsp;</td>
		<td nowrap valign="middle" align="right" width="100%"><a class="subactionbutton" href="index.jsp"><< Return to Templates</a></td>
	</tr>
</table>
<br>
<form name="FT" method="POST" action="pagesave.jsp">
<input type="hidden" name="returnURL" value="<%= returnURL %>">
<%
if (pageName != null && pageName.length() == 0) {
	%><h3>You must enter a name for your page.</h3><%
}
%>
<table cellpadding="0" cellspacing="0" class="main" width="650">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 1:</b>&nbsp;Template Information</td>
	</tr>
</table>
<br>

<%
if (oldContentID != null) {
	%><input type=hidden name=oldContentID value=<%= oldContentID %>><%
}
%>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTab">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td width="150">Name: </td>
					<td><input type="text" name="pageName" size="50" value="<%= nameValue %>"></td>
				</tr>
				<tr<%= ("1".equals(isHyatt))?" style=\"display:none;\"":"" %>>
					<td width="150">Send Type: </td>
					<td>
						<select name="sendType">
						<%= sendTypeSelectBox %>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>
</form>
</body>
</html>
