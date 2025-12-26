<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.util.regex.*,
			java.sql.*,java.net.*,
			java.io.*,java.text.DateFormat,
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
String sScrapeId = request.getParameter("scrape_id");
Scrape scrape = new Scrape();
scrape.s_scrape_id = sScrapeId;
if(scrape.retrieve() < 1) return;

int nEntries = Integer.parseInt(scrape.s_num_entries);

ScrapeUrls urls = new ScrapeUrls();
urls.s_scrape_id = sScrapeId;
if (urls.retrieve() < 1) return;

String sSql = "DELETE ccnt_scrape_attr "
		+ " FROM ccnt_scrape_attr a, ccnt_scrape_url u"
		+ " WHERE a.url_id = u.url_id"
		+ " AND u.scrape_id = "+sScrapeId;
BriteUpdate.executeUpdate(sSql);

String sHtmlOut = "<table width=100% class=main cellspacing=1 cellpadding=2><tr><th colspan=2>Scrape Results</th></tr>\r\n";

for (Enumeration e = urls.elements() ;e.hasMoreElements(); ) {
	ScrapeUrl url = (ScrapeUrl) e.nextElement();
	try {
		int count = url.scrape (nEntries);
		
		sHtmlOut += "<tr><td align=left valign=middle>"+url.s_url+"</td><td align=right valign=middle>Found "+count+" entries</td></tr>\r\n";

		sSql = "UPDATE ccnt_scrape_url"
				+ " SET status_id = "+ScrapeStatus.COMPLETE+", scrape_date = getdate()"
				+ " WHERE url_id = "+url.s_url_id;
		BriteUpdate.executeUpdate(sSql);
	} catch (Exception ex) {
		sHtmlOut += "<tr><td align=left valign=middle>"+url.s_url+"</td><td align=right valign=middle>Error! "+ex.toString()+"</td></tr>\r\n";

		sSql = "UPDATE ccnt_scrape_url"
				+ " SET status_id = "+ScrapeStatus.ERROR+", scrape_date = getdate()"
				+ " WHERE url_id = "+url.s_url_id;
		BriteUpdate.executeUpdate(sSql);
	}
}
sHtmlOut += "</table><br>\r\n";

// === === ===

sSql = "UPDATE ccnt_scrape"
		+ " SET status_id = "+ScrapeStatus.COMPLETE+", scrape_date = getdate()"
		+ " WHERE scrape_id = "+sScrapeId;
BriteUpdate.executeUpdate(sSql);


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
		<td class=sectionheader>&nbsp;<b class=sectionheader>URLs:</b> Scraped</td>
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
			<%=sHtmlOut%>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><a href="scrape_list.jsp">Back to List</a></p>
						<p align="center"><a href="scrape_edit.jsp?scrape_id=<%= sScrapeId %>">Edit Scrape</a></p>
						<p align="center"><a href="scrape_url_edit.jsp?scrape_id=<%= sScrapeId %>">Edit URLs</a></p>
						<p align="center"><a href="scrape_urls.jsp?scrape_id=<%= sScrapeId %>"><b>Re-Scrape URLs</b></a></p>
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
