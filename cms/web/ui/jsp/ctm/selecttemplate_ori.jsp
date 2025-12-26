<%@ page 
          language="java"
          import="org.apache.log4j.*"
          import="com.britemoon.cps.*"
          import="com.britemoon.cps.ctm.*"
          import="java.util.*" 
          errorPage="../error_page.jsp"
          contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%
//Make sure these are gone
session.removeAttribute("pbean");
session.removeAttribute("tbean");

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) isHyatt = "0";

int numPerPage = 6;
String sNumPerPage = application.getInitParameter("NumTemplatesPerPage");
if (sNumPerPage != null) numPerPage = Integer.parseInt(sNumPerPage);

String isWizard = (String)session.getAttribute("isWizard");
if ("1".equals(isWizard)) {
    numPerPage = 100;
}

String sCurPage = request.getParameter("page");
int curPage, nextPage, prevPage;
if (sCurPage == null)
{
	curPage = 1;
	nextPage = 2;
	prevPage = 0;
}
else
{
	curPage = Integer.parseInt(sCurPage);
	nextPage = curPage + 1;
	prevPage = curPage - 1;
}

int custID = Integer.parseInt(cust.s_cust_id);

TemplateBean tbean;

//No next page if there aren't any more to show
int actualNumTemplates = 0;
for(Enumeration tb = tbeans.elements(); tb.hasMoreElements();)
{
	tbean = (TemplateBean)tb.nextElement();
	if (!tbean.isActive()) continue;
	boolean ok = false;
	if (isHyatt.equals("1"))
	{
		// this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id	
		ok = (tbean.isGlobal() && (tbean.getCustID() != 0));
	}	
	else
	{
		ok = (tbean.getCustID() == 0);
	}	
	if (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) ++actualNumTemplates;
}

if (curPage*numPerPage >= actualNumTemplates) nextPage = 0;
%>

<html>
<body>
<head>
<title>Select a Template</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body>
<table cellpadding="3" cellspacing="0" border="0">
	<tr>
		<td nowrap valign="middle" align="left"><a class="subactionbutton" href="index.jsp"><< Return to Templates</a></td>
	</tr>
</table>
<br>
<table cellpadding="0" cellspacing="0" class="main" width="650">
	<tr>
		<td class="sectionheader">Select a Template</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" width="100%" valign="center" nowrap align="left">
			<% if ((prevPage != 0) || (nextPage != 0)) { %>
			<table class="main" cellspacing="1" cellpadding="2" border="0" align="right">
				<tr>
					<td align="center" valign="middle">
						<table class="main" cellspacing="0" cellpadding="5" border="0">
							<tr>
							<% if (prevPage != 0) { %>
								<td align="right" valign="middle" nowrap id="prev_page" style="display:inline"><a href="selecttemplate.jsp?page=<%= prevPage %>">< Previous</a></td>
							<% } %>
							<% if (nextPage != 0) { %>
								<td align="right" valign="middle" nowrap id="next_page" style="display:inline"><a href="selecttemplate.jsp?page=<%= nextPage %>">Next ></a></td>
							<% } %>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			&nbsp;
			<br><br>
			<% } %>
			<table class="listTable" width="100%" cellspacing="0" cellpadding="2">
				<tr>
<%
Vector vKeys = new Vector();
Enumeration keys = tbeans.keys();

while (keys.hasMoreElements()) vKeys.add(keys.nextElement());

Collections.sort(vKeys);
Iterator sortedKeys = vKeys.iterator();

int rowCount = 0, count = 0;
boolean hasOneRow = false;

int iCount = 0;
String sClassAppend = "_Alt";

// skip the ones displayed in previous pages
int numToSkip = curPage*numPerPage-numPerPage;
while (numToSkip > 0)
{
	if (!sortedKeys.hasNext()) break;
	Integer key = (Integer) sortedKeys.next();
	tbean = (TemplateBean)tbeans.get(key);

	if (!tbean.isActive()) continue;
	boolean ok = false;
	if (isHyatt.equals("1"))
	{
		ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
	}	
	else
	{
		ok = (tbean.getCustID() == 0);
	}	
	
	if ( tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) )
	{
		numToSkip--;
	}
}

// display the next page
while (sortedKeys.hasNext() && count < numPerPage)
{
	Integer key = (Integer) sortedKeys.next();
	tbean = (TemplateBean)tbeans.get(key);
	boolean ok = false;
	if (isHyatt.equals("1"))
	{
		ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
	}	
	else
	{
		ok = (tbean.getCustID() == 0);
	}	
	if ( tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) )
	{
		hasOneRow = true;
		++rowCount;
		++count;
		if (rowCount == 4)
		{
			rowCount = 1;
%>
				</tr>
				<tr>
<%
			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
			
			++iCount;
		}
		%>
					<td class="listItem_Data<%=sClassAppend%>" width="33%" valign="top" align="center">
						<a href="pageedit.jsp?templateID=<%= tbean.getTemplateID() %>">
						<img border="0" src="/cctm/ui/images/templates/<%= tbean.getImageURL(0) %>"><br>
						<%= tbean.getTemplateName() %>
						</a>
						<br><br>
						<a class="resourcebutton" target="_blank" href="/cctm/ui/images/templates/<%= tbean.getImageURL(1) %>">Preview</a>
					</td>
		<%
	}
}

for (int x=rowCount+1;x<4;++x)
{
	%><td class="listItem_Data<%=sClassAppend%>" width="33%"></td><%
}

if (!hasOneRow)
{
	%><td colspan="3" class="listItem_Data">There are currently no templates to choose from.</td><%
}
%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
