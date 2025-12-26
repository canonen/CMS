<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.io.*,
			java.text.DateFormat,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
Scrape sc = new Scrape();

sc.s_scrape_id = BriteRequest.getParameter(request, "scrape_id");
sc.s_cust_id = cust.s_cust_id;
sc.s_scrape_name = BriteRequest.getParameter(request, "scrape_name");
sc.s_num_entries = BriteRequest.getParameter(request, "num_entries");
sc.s_num_urls = BriteRequest.getParameter(request, "num_urls");
sc.s_base_url = BriteRequest.getParameter(request, "base_url");
sc.s_status_id = String.valueOf(ScrapeStatus.NEW);

// === === ===

String sSql = "DELETE ccnt_scrape_tag "
		+ " WHERE scrape_id = "+sc.s_scrape_id;
BriteUpdate.executeUpdate(sSql);

int numTags = Integer.parseInt(request.getParameter("num_tags"));

ScrapeTags tags = new ScrapeTags();

int count = 0;
for (int i = 1; i <= numTags; i++) {
	ScrapeTag tag = new ScrapeTag();

	tag.s_tag_name = BriteRequest.getParameter(request, "tag_name"+i);
	if (tag.s_tag_name != null) {
		count++;
		tag.s_tag_id = String.valueOf(count);
		tag.s_scrape_id = sc.s_scrape_id;
		tag.s_level = BriteRequest.getParameter(request, "level"+i);

		tags.add(tag);
	}
}

sc.m_ScrapeTags = tags;
sc.save();

// === === ===

//response.sendRedirect("scrape_url_edit.jsp?scrape_id=" + sc.s_scrape_id);
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
		<td class=sectionheader>&nbsp;<b class=sectionheader>Scrape:</b> Saved</td>
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
						<p align="center"><b>The scrape was saved.</b></p>
						<p align="center"><a href="scrape_list.jsp">Back to List</a></p>
						<p align="center"><a href="scrape_edit.jsp?scrape_id=<%= sc.s_scrape_id %>">Back to Edit</a></p>
						<p align="center"><a href="scrape_url_edit.jsp?scrape_id=<%= sc.s_scrape_id %>">Edit URLs</a></p>
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
