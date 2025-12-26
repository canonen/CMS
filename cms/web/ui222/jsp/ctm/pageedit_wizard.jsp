<%@ page
    language="java"
	import="org.apache.log4j.*"
    import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="java.util.*"
	import="java.sql.*"
    errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%-- Page requires a templateID parameter, contentID parameter is optional --%>
<%

int custID = Integer.parseInt(cust.s_cust_id);

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}

//Grab pbean and tbean from either the session or create a new one
PageBean pbean = (PageBean)session.getAttribute("pbean");
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
	pbean = new PageBean(custID, tbean);

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
	response.sendRedirect("pagesave.jsp");
	return;
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
<html>
<head>
<title>Edit <%= pbean.getPageName() %></title>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript" >
	
	function moveSteps(stepNum)
	{
		var frm = parent.top.document.FT.step.value = stepNum;
	}
	
</script>
</head>
<body>
<table cellpadding="0" cellspacing="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="50">
		<td>
			<table cellpadding="3" cellspacing="0" border="0" width="100%">
		<%	if (!"locked".equals(status)) { %>
				<tr>
					<td vAlign="middle" align="left" colspan="5">
						<a class="subactionbutton" href="commit.jsp?templateID=<%= templateID %><%= contentID %>"><b>Save And Continue >></b></a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
		<% } %>
				<tr>
			<%
			if (isEdit)
			{
				%>
					<td nowrap align="left" valign="middle"><a class="resourcebutton" href="pageedit.jsp?isEdit=false&templateID=<%= templateID %><%= contentID %>">Preview</a>&nbsp;&nbsp;&nbsp;</td>
					<td nowrap align="left" valign="middle">
			<%	if (!"locked".equals(status)) { %>
					<a class="subactionbutton" href="pagesave.jsp?rename=true"><%=(isHyatt.equals("1")?"Rename":"Rename/Change Send Type")%></a>
			<%	} %>
					&nbsp;&nbsp;&nbsp;
					</td>
			<%
			}
			else
			{
				//Can be html or txt
				if (previewType.equals("html"))
				{
					%>
					<td nowrap align="left" valign="middle"><a class="disabledbutton" href="#">HTML</a>&nbsp;</td>
					<td nowrap align="left" valign="middle"><a class="resourcebutton" href="pageedit.jsp?previewType=txt&isEdit=false&templateID=<%= templateID %><%= contentID %>">Text</a>&nbsp;&nbsp;&nbsp;</td>
					<%
				}
				else
				{
					%>
					<td nowrap align="left" valign="middle"><a class="resourcebutton" href="pageedit.jsp?previewType=html&isEdit=false&templateID=<%= templateID %><%= contentID %>">HTML</a>&nbsp;</td>
					<td nowrap align="left" valign="middle"><a class="disabledbutton" href="#">Text</a>&nbsp;&nbsp;&nbsp;</td>
					<%	
				}
				%>
					<td nowrap align="left" valign="middle">
			<%	if (!"locked".equals(status)) { %>
					<a class="subactionbutton" href="pageedit.jsp?isEdit=true&templateID=<%= templateID %><%= contentID %>">Edit Template</a>
			<%	} %>
					&nbsp;&nbsp;&nbsp;
					</td>
				<%
			}
			%>
					<td nowrap valign="middle" align="right" width="100%">
		<%	if (!"locked".equals(status)) { %>
					<a class="subactionbutton" href="index.jsp"><< Return to Templates</a>
		<%	} %>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<iframe style="width:100%; height:100%;" frameborder="0" border="0" scrolling="auto" name="template" src="pageedit2.jsp?previewType=<%= previewType %>&isEdit=<%= isEdit %>&templateID=<%= templateID %><%= contentID %>"></iframe>
		</td>
	</tr>
</table>
</body>
</html>


