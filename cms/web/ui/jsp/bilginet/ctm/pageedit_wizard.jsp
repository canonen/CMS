<%@ page
    language="java"
	import="org.apache.log4j.*"
    import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="java.util.*"
	import="java.sql.*"
    errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%-- Page requires a templateID parameter, contentID parameter is optional --%>
<%

int custID = Integer.parseInt(cust.s_cust_id);

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}

//Grab pbean and tbean from either the session or create a new one
BNetPageBean pbean = (BNetPageBean)session.getAttribute("pbean");
TemplateBean tbean = null;

String sTemplateID = request.getParameter("templateID");
String contentID = request.getParameter("contentID");
contentID = ( (contentID != null) && (contentID.length() > 0) )?contentID:null;

//Grab this customer's pages from the db
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

String status = null;
try {
	connPool = ConnectionPool.getInstance();
	conn = connPool.getConnection("index.jsp");
	stmt = conn.createStatement();

	if (contentID != null && !contentID.equals("null")) {
		rs = stmt.executeQuery("select template_id " +
					   "  from ctm_pages " +
					   " where content_id = '"+ contentID +"' " +
					   "   and status <> 'deleted'");

		while (rs.next()) {
			sTemplateID = rs.getString(1);
		}
	}

	rs = stmt.executeQuery(
		"SELECT status" +
		" FROM ctm_pages p" +
		" WHERE p.template_id = " + sTemplateID +
		" AND p.content_id = " + contentID +
		" AND p.customer_id = " + custID);
	
	if (rs.next()) status = rs.getString(1);
	rs.close();

} 
catch (SQLException e) 
{
	throw e;
} finally {
	stmt.close();
	if (conn != null) connPool.free(conn);
}

if (sTemplateID == null || !tbeans.containsKey(new Integer(sTemplateID))) {
	//templateID is null
	%> templateID is null <%
	return;
}

int templateID = Integer.parseInt(sTemplateID);

//if pbean doesn't exist or it is a different template (different templateID)
//or contentID is different
boolean refreshed = false;
if (pbean == null || (pbean.getTemplateBean()).getTemplateID() != templateID ||
   (contentID != null && !contentID.equals(String.valueOf(pbean.getContentID())))) {

	//Grab a tbean from the Hashtable using the templateID key
	tbean = (TemplateBean)tbeans.get(new Integer(templateID));
	boolean ok = false;
	if (isHyatt.equals("1")) {
		ok = tbean.isGlobal(); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
	}	
	else {
		ok = (tbean.getCustID() == 0);
	}	
	if (!ok && tbean.getCustID() != custID && !tbean.inChildCustList(custID+"")) {
		//Do not let him use other customer's private Templates
		//response.sendRedirect("login.jsp");
		%> Bad CustID For TemplateID: <%= sTemplateID %> <%
		return;
	}
	pbean = new BNetPageBean(custID, tbean);

	//See if there is a contentID in the request
	if (contentID != null) {
		//load it from the db
		try {
			pbean.load(Integer.parseInt(contentID));
			if (pbean.getCustID() != custID) {
				//User is not allowed to see this page
				//response.sendRedirect("login.jsp");
				%> Really Bad ClientID For TemplateID: <%= sTemplateID %> <%
				return;
			}
		} catch (SQLException e) {
			throw e;
		}
	} else {
		//set the hidden values to the default values
		pbean.setHiddenValues();
	}
	session.setAttribute("pbean", pbean);
	session.setAttribute("tbean", tbean);

	refreshed = true;
} else {
	tbean = (TemplateBean)session.getAttribute("tbean");
}
if (request.getParameter("clone") != null) {
	//set pageName to "" and contentID to 0 and redirect to savepage.jsp
	pbean.setPageName("");
	int oldContentID = pbean.getContentID();
	pbean.setContentID(0);
	response.sendRedirect("pagesave.jsp?oldContentID="+oldContentID);
	return;
}

if (pbean.getPageName().length() == 0) {
	//redirect to the save page
	
	if (request.getParameter("skipstep") != null) {
		response.sendRedirect("pagesave.jsp?skipstep=1");
		return;
	}
	else 
	{
		response.sendRedirect("pagesave.jsp");
		return;
	}
}

if (contentID == null)
{
	try
	{
		contentID = String.valueOf(pbean.getContentID());
		contentID = "&contentID="+contentID;
	}
	catch (Exception ex)
	{
		contentID = "";
	}
	
	if (contentID == null)
	{
		contentID = "";
	}
}
else
{
	contentID = "&contentID="+contentID;
}

boolean isEdit;
String sIsEdit = request.getParameter("isEdit");
if ((sIsEdit != null && sIsEdit.equals("false")) || "locked".equals(status)) {
	isEdit = false;
} else {
	isEdit = true;
}
String previewType = request.getParameter("previewType");
if (previewType == null) previewType = "html";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Edit <%= pbean.getPageName() %></title>
<link rel="stylesheet" href="../default.css" TYPE="text/css">
<script language="javascript" >
	
	function moveSteps(stepNum)
	{
		var frm = parent.top.document.FT.step.value = stepNum;
	}
	
</script>
</head>
<body style="margin:0;background-color:#FFFFFF">
<table cellpadding="5" cellspacing="0" width="100%">
<tr>
	<td>
		<%	if (!"locked".equals(status)) { %>			
				<a href="selecttemplate.jsp" class="zbuttons zbuttons-normal zbuttons-black mta5">
					<span class="zicon zicon-white zicon-return"></span>
					<span class="zlabel">Şablonlara Geri Dön</span>
				</a>
				
		<%	} 
	
		if (isEdit)
		{
		%>
				<a href="pageedit.jsp?isEdit=false&templateID=<%= templateID %><%= contentID %>" class="zbuttons zbuttons-normal zbuttons-light-gray">
							<span class="zicon zicon-black zicon-eye"></span>
							<span class="zlabel">Önizleme</span>
						</a>
			
			<%	if (!"locked".equals(status)) { %>
			<!--<a class="subactionbutton" href="pagesave.jsp?rename=true"><%//(isHyatt.equals("1")?"Rename":"Rename/Change Send Type")%></a>-->
			<%	} %>

		<%	
		} 
		else
		{
			if (previewType.equals("html"))
			{
				%>
				<!--<a class="btn-small btn-warning" href="#">HTML</a>-->
				<!--<a class="btn-small btn-gray" href="pageedit.jsp?previewType=txt&isEdit=false&templateID=<%//templateID %><%//contentID %>">Text</a>-->
				<%
			}
			else
			{
				%>
				<!--<a class="btn-small btn-gray" href="pageedit.jsp?previewType=html&isEdit=false&templateID=<%//templateID %><%//contentID %>">HTML</a>
				<!--<a class="btn-small btn-warning" href="#">Text</a>-->
				<%	
			}
			%>
				
		<%	if (!"locked".equals(status)) { %>
				
				<a href="pageedit.jsp?isEdit=true&templateID=<%= templateID %><%= contentID %>" class="zbuttons zbuttons-normal zbuttons-light-gray">
					<span class="zicon zicon-black zicon-edit"></span>
					<span class="zlabel">Şablonu Düzenle</span>
				</a>
				
		<%	} %>
				
			<%
		}
		if (!"locked".equals(status)) { %>
							
				<a href="commit.jsp?templateID=<%= templateID %><%= contentID %>" class="zbuttons zbuttons-normal zbuttons-green mta5">
					<span class="zicon zicon-white zicon-save"></span>
					<span class="zlabel">Şablonu Kaydet ve Devam Et</span>
				</a>
		<% } 
		%>
</td>
</tr>
</table>					

<iframe style="width:100%; height:450px;overflow-y:scroll;overflow-x:hidden" frameborder="0" border="0" scrolling="auto" name="template" src="pageedit2.jsp?previewType=<%= previewType %>&isEdit=<%= isEdit %>&templateID=<%= templateID %><%= contentID %>"></iframe>
		
</body>
</html>


