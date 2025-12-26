<%@ page 
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.sql.*"
	import="java.util.*" 
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
PageBean pbean = (PageBean)session.getAttribute("pbean");
/*
String isWizard = (String)session.getAttribute("isWizard");
if ("1".equals(isWizard)) {
	response.sendRedirect("pagesave_wizard.jsp?" + request.getQueryString());
	return;
}
*/
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

String sContentParm = "";
if (pbean.getContentID() != 0) {
          sContentParm = "&contentID=" + pbean.getContentID(); 
} 
//If no name in pbean and no name supplied by user, ask for a name

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}
%>

<html>
<head>
<title>Page Name</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body onLoad="FT.pageName.focus();">
<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle"><a class="savebutton" href="javascript:FT.submit();">Save</a>&nbsp;&nbsp;&nbsp;</td>
	<%
	if (rename != null)
	{
		// only display the following if this is a rename, DON'T display if this is a new Template
		%>
		<td nowrap align="left" valign="middle"><a class="subactionbutton" href="<%=returnURL%><%=sContentParm%>">< Return to Edit Template</a>&nbsp;&nbsp;&nbsp;</td>
		<%
	}
	%>
		<td nowrap valign="middle" align="right" width="100%"><a class="subactionbutton" href="index.jsp"><< Return to Templates</a></td>
	</tr>
</table>
<br>
<form name="FT" method="POST" action="pagesave.jsp">
<input type="hidden" name="returnURL" value="<%= returnURL %>">
<% if (oldContentID != null) { %>
     <input type="hidden" name="oldContentID" value="<%= oldContentID %>">
<% } %>
<table cellpadding="0" cellspacing="0" class="listTable" width="650">
	<tr>
		<th class="sectionheader"><b class="sectionheader">Step 1:</b>&nbsp;Template Information</th>
	</tr>
	<tr>
		<td class="">
		<% if (pageName != null && pageName.length() == 0) { %>
		     <h3>Please enter a name for the content.</h3>
<% } %>
			<table class="" cellspacing="1" cellpadding="2" width="100%">
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
<br>
</form>
</body>
</html>
