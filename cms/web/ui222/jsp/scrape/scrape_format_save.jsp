<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.io.*,
			java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%

ScrapeFormat format = new ScrapeFormat();
format.s_format_id = BriteRequest.getParameter(request, "format_id");
format.retrieve();

format.s_scrape_id = BriteRequest.getParameter(request, "scrape_id");
format.s_format_name = BriteRequest.getParameter(request, "format_name");
format.s_cont_text = BriteRequest.getParameter(request, "cont_text");
format.s_cont_html = BriteRequest.getParameter(request, "cont_html");
format.s_charset_id = BriteRequest.getParameter(request, "charset_id");

format.save();

// === === ===

%>

<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Scrape Format:</b> Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><b>The scrape format was saved.</b></p>
						<p align="center"><a href="scrape_format_list.jsp">Back to List</a></p>
						<p align="center"><a href="scrape_format_edit.jsp?format_id=<%= format.s_format_id %>">Back to Edit</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
