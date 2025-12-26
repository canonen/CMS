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
<%! static Logger logger = null;%>
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
String sScrapeId = request.getParameter("scrape_id");
int numUrls = Integer.parseInt(request.getParameter("num_urls"));

int count = 0;
for (int i = 1; i <= numUrls; i++) {
	ScrapeUrl url = new ScrapeUrl();
	
	url.s_url_id = BriteRequest.getParameter(request, "url_id"+i);
	url.s_url = BriteRequest.getParameter(request, "url"+i);
	if (url.s_url != null) {
		count++;
		url.s_scrape_id = sScrapeId;
		url.s_title_text = BriteRequest.getParameter(request, "title_text"+i);
		url.s_title_html = BriteRequest.getParameter(request, "title_html"+i);
		url.s_filter_id = BriteRequest.getParameter(request, "filter_id"+i);
		url.s_seq = String.valueOf(count);
		
		url.save();
	} else {
		if (url.s_url_id != null) url.delete();
	}
}
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
		<td class=sectionheader>&nbsp;<b class=sectionheader>Scrape URLs:</b> Saved</td>
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
						<p align="center"><b>The scrape URLs were saved.</b></p>
						<p align="center"><a href="scrape_list.jsp">Back to List</a></p>
						<p align="center"><a href="scrape_url_edit.jsp?scrape_id=<%= sScrapeId %>">Back to Edit URLs</a></p>
						<p align="center"><a href="scrape_edit.jsp?scrape_id=<%= sScrapeId %>">Edit Scrape</a></p>
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
