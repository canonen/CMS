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
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<%

BNetPageBean pbean = (BNetPageBean)session.getAttribute("pbean");
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

if(request.getParameter("skipstep") != null) 
{
	returnURL += "&skipstep=1";
}

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
	
	if(request.getParameter("skipstepdone") != null) 
	{
		response.sendRedirect("sectionedit.jsp?section=0");
		return;
	}
	else
	{
		response.sendRedirect(returnURL);
		return;
	}
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
	if(curID != 9) continue;
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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Page Name</title>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="../default.css" TYPE="text/css">
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html;charset=UTF-8">
</head>
<body onLoad="FT.pageName.focus();" style="margin:0;background-color:#FFFFFF">
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle">
				
				<a href="selecttemplate.jsp" class="zbuttons zbuttons-normal zbuttons-black mta5">
					<span class="zicon zicon-white zicon-return"></span>
					<span class="zlabel">Şablonlara Geri Dön</span>
				</a>
				
				<a href="#" onclick="javascript:FT.submit();" class="zbuttons zbuttons-normal zbuttons-green mta5">
					<span class="zicon zicon-white zicon-save"></span>
					<span class="zlabel">Şablonu Kaydet ve Devam Et</span>
				</a>
			<%
			if (rename != null)
			{
			%>
				<a class="btn btn-small btn-info" href="<%=returnURL%><%=sContentParm%>">
					<i class="icon-edit icon-white"></i> Şablonu Düzenle</a>
				<%
			}
			%>
			
		</td>
	</tr>
</table>
<br>
<form name="FT" method="POST" action="pagesave.jsp">

<input type="hidden" name="returnURL" value="<%= returnURL %>">
<% if (oldContentID != null) { %>
     <input type="hidden" name="oldContentID" value="<%= oldContentID %>">
<% } 
	
	if(request.getParameter("skipstep") != null) 
	{
%>	
		 <input type="hidden" name="skipstepdone" value="1">
<%
	 }
	
%>
<table cellpadding="0" cellspacing="0" class="list-table list-table noborder-p8" width="100%">
	<tr>
		<td colspan="2" class="desc-texts" style="border:none;">Şablonunuzu düzenlemeye başlamadan önce onda bir ad verin.</td>
	</tr>
	<tr>
		<td class="htexts">Şablon Adı</td>
		<td>
			<input type="text" class="inputtexts" name="pageName" size="50" value="<%= nameValue %>">
			<select name="sendType" style="display:none;">
				<%= sendTypeSelectBox %>
			</select>
		</td>
	</tr>
</table>
<br>
</form>
</body>
</html>
