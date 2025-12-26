<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
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

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
String sScrapeId = request.getParameter("scrape_id");

Scrape scrape = new Scrape();
scrape.s_scrape_id = sScrapeId;
int nRetrieve = scrape.retrieve();
if(nRetrieve < 1) return;
if ((nRetrieve > 0) && !(cust.s_cust_id.equals(scrape.s_cust_id))) return;

ScrapeUrls urls = new ScrapeUrls();
urls.s_scrape_id = sScrapeId;
urls.retrieve();

ConnectionPool cp	= null;
Connection conn		= null;
Statement stmt		= null;
ResultSet rs		= null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="scrape_url_save.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="scrape_id" value="<%=HtmlUtil.escape(scrape.s_scrape_id)%>">
<INPUT TYPE="hidden" NAME="num_urls" value="<%=HtmlUtil.escape(scrape.s_num_urls)%>">

<table cellspacing="0" cellpadding="4" border="0">
	<tr>
	<%
	if( can.bWrite)
	{
		%>
		<td align="left" valign="middle">
			<a class="savebutton" href="javascript:FT.submit();">Save</a>
		</td>
			<%
		}
		%>
		<td align="left" valign="middle">
			<a class="subactionbutton" href="scrape_edit.jsp?scrape_id=<%= HtmlUtil.escape(scrape.s_scrape_id) %>"><< Back to Scrape</a>
		</td>
	</tr>
</table>
<br>

<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Scrape URLs</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<%

			int numUrls = Integer.parseInt(scrape.s_num_urls);
			Enumeration e = urls.elements();

			for (int i = 1; i <= numUrls; i++) {
				ScrapeUrl url = (e.hasMoreElements())?(ScrapeUrl)e.nextElement():new ScrapeUrl();

			%>
			<INPUT TYPE="hidden" NAME="url_id<%=i%>" value="<%=HtmlUtil.escape(url.s_url_id)%>">
				
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<th colspan="2">URL #<%=i%></th>
				</tr>
				<!-- Title -->
				<tr>
					<td width="150" height="25">HTML Title: </td>
					<td height="25" nowrap>
						<input type="text" size="35" name="title_html<%=i%>" value="<%= HtmlUtil.escape(url.s_title_html) %>">
					</td>
				</tr>
				<tr>
					<td width="150" height="25">Text Title: </td>
					<td height="25" nowrap>
						<input type="text" size="35" name="title_text<%=i%>" value="<%= HtmlUtil.escape(url.s_title_text) %>">
					</td>
				</tr>
				<!-- Url -->
				<tr>
					<td width="150" height="25">Url: </td>
					<td height="25" nowrap>
						<input type="text" size="40" name="url<%=i%>" value="<%= HtmlUtil.escape(url.s_url) %>">
					</td>
				</tr>
				<!-- Filter -->
				<tr>
					<td width="150" height="25">Logic Element: </td>
					<td height="25" nowrap>
						<select NAME="filter_id<%=i%>" SIZE="1">
							<option <%=(url.s_filter_id == null)?"SELECTED":""%> VALUE="">-------Select Logic Element-------</OPTION>
					<%
					rs = stmt.executeQuery(""+
						"SELECT filter_id, filter_name " +
						"FROM ctgt_filter WHERE cust_id = "+cust.s_cust_id+" AND origin_filter_id IS NULL " +
						" AND filter_name IS NOT NULL " +
						" AND type_id = 0 " +
						" AND status_id < " + FilterStatus.DELETED +
						" AND usage_type_id = " + FilterUsageType.CONTENT +
						" ORDER BY filter_name");
					if (url.s_filter_id == null) {
						while (rs.next())
							out.print("<option value="+rs.getString(1)+">"+new String(rs.getBytes(2),"ISO-8859-1")+"</option>\n");
					} else {
						String tmpFilterID;
						while (rs.next()) {
							tmpFilterID = rs.getString(1);
							if (tmpFilterID.equals(url.s_filter_id)) {
								out.print("<option selected value="+tmpFilterID+">"+new String(rs.getBytes(2),"ISO-8859-1")+"</option>\n");
							} else {
								out.print("<option value="+tmpFilterID+">"+new String(rs.getBytes(2),"ISO-8859-1")+"</option>\n");
							}
						}
					}
					rs.close();
					%>
						</select>
					</td>
				</tr>
			</table>
			<br>
			<% } %>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<%

} catch(Exception ex)	{
	throw ex;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
</FORM>
</BODY>
</HTML>
