<%@ page import="com.britemoon.*"
		 import="com.britemoon.cps.*"
		 import="com.britemoon.cps.ctm.*"
		 import="org.apache.log4j.*"
		 import="java.util.*"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%

int custID = Integer.parseInt(cust.s_cust_id);

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}

String isAdmin = request.getParameter("admin");
if (isAdmin == null) isAdmin = "";

String isParent = request.getParameter("parent");
if (isParent == null) isParent = "";

Hashtable tbeans = (Hashtable)application.getAttribute("tbeans");
Enumeration elements = tbeans.elements();

TemplateBean tbean = null;
%>

<html>
<head>
<title>Administer Templates</title>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body>
<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle"><a class="newbutton" href="templatenew.jsp<%=(isParent.equals("true")?"?parent=true":"")%>">New Master Template</a>&nbsp;&nbsp;&nbsp;</td>
		<td nowrap valign="middle" align="right" width="100%">
			<a class="subactionbutton" href="/cms/ui/jsp/ctm/index.jsp"><< Return to Templates</a>
		</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class="listHeading" width="100%" valign="center" nowrap align="left">
			Current Master Templates
			<br><br>			
			<table class="listTable" width="100%" cellspacing="0" cellpadding="2">
				<tr>
					<th align="left" nowrap>Name</th>
					<th align="left" nowrap>Type</th>
					<th align="left" nowrap>Category</th>
					<th align="left" nowrap>Actions</th>
				</tr>

<%
int count=0;
String curCategory = "", altColor;
StringTokenizer allCategories = new StringTokenizer(application.getInitParameter("CategoryList"), ";");
for (int x=0;x<Integer.parseInt(application.getInitParameter("NumCategories"));++x) {
	curCategory = allCategories.nextToken();
	while (elements.hasMoreElements()) {
		tbean = (TemplateBean)elements.nextElement();
		if ( !tbean.isActive() ) {
			continue;
		}
		if ( isAdmin.equals("true") || tbean.getCustID() == custID ) {

			if (curCategory.equals(tbean.getCategory())) {
				++count;
				if (count % 2 != 0) {
					altColor = "_Alt";
				} else {
					altColor = "";
				}
			
				%>
				<tr>
					<td class="listItem_Data<%= altColor %>"><a href="templatenew.jsp?<%=(isParent.equals("true")?"parent=true&":"")%>templateID=<%= tbean.getTemplateID() %>"><%= tbean.getTemplateName() %></a></td>
					<td class="listItem_Data<%= altColor %>"><%= (tbean.getCustID() == 0)?"site-wide":"custom" %></td>
					<td class="listItem_Data<%= altColor %>"><%= tbean.getCategory() %></td>
					<td class="listItem_Data<%= altColor %>">
						<a class="deletebutton" href="#" onClick="if( confirm('Are you sure?') ) href='templatedelete.jsp?templateID=<%= tbean.getTemplateID() %>'">Delete</a>
						&nbsp;&nbsp;&nbsp;
						<a class="resourcebutton" target="_blank" href="/cctm/ui/images/templates/<%= tbean.getImageURL(1) %>">Preview</a>
						&nbsp;&nbsp;&nbsp;
						<a class="resourcebutton" href="templateview.jsp?templateID=<%= tbean.getTemplateID() %>">View Spec</a>
					</td>
				</tr>
				<%
			}
		}
	}
	//Reset the enumeration
	elements = tbeans.elements();
}

if (tbean == null)
{
	%>
				<tr>
					<td class="listItem_Data" colspan="4">There are currently no templates</td>
				</tr>
	<%
}
%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</body>
</html>
