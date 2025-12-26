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
if ((nRetrieve > 0) && !(cust.s_cust_id.equals(scrape.s_cust_id))) scrape = new Scrape();

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function gotoURLs()
	{
		if (confirm("Click OK if you want to edit the URLs with out saving any changes to the scrape, otherwise click Cancel and Save the scrape before defining URLs."))
		{
			location.href = "scrape_url_edit.jsp?scrape_id=<%= HtmlUtil.escape(scrape.s_scrape_id) %>";
		}
	}
	
	function scrapeSites()
	{
		if (confirm("Click OK if you have entered the URLs or want to scrape the web sites with out saving any changes, otherwise click Cancel and Save the scrape and define the URLs before scraping the web sites."))
		{
			location.href = "scrape_urls.jsp?scrape_id=<%= HtmlUtil.escape(scrape.s_scrape_id) %>";
		}
	}
	
	function setXML()
	{
		var xmlText = "";
		var xmlCanvas = document.getElementById("canvas_xml");
		var tTable = document.getElementById("tagTable");
		var topTag = tTable.rows[0].cells[0].children[0].value;
		var sTag = "";
		
		if (topTag != "")
		{
			xmlText = "&lt;" + topTag + "&gt;<br>";

			for (i=1; i<tTable.rows.length; i++)
			{
				sTag = "";
				sTag = tTable.rows[i].cells[1].children[0].value;

				if (sTag != "")
				{
					xmlText += "&nbsp;&nbsp;&nbsp;&lt;" + sTag + "&gt;<i> Content Here </i>&lt;/" + sTag + "&gt;<br>";
				}
			}

			xmlText += "&lt;/" + topTag + "&gt;<br>";

			xmlCanvas.innerHTML = xmlText;
		}
	}
	
	function addTag()
	{
		var tTable = document.getElementById("tagTable");
		var oRow, oCell;
		
		oRow = tTable.insertRow();
		oCell = oRow.insertCell();
		oCell.width = "15";
		
		oCell = oRow.insertCell();
		oCell.align = "left";
		oCell.vAlign = "middle";
		oCell.innerHTML = "<input type=\"text\" name=\"tag_value\" id=\"tag_value\" tabindex=\"" + (oRow.rowIndex + 1) + "\" size=\"35\" value=\"\" onkeyup=\"setXML();\">";
		
		oCell = oRow.insertCell();
		oCell.width = "65";
		oCell.align = "right";
		oCell.vAlign = "middle";
		oCell.innerHTML = "<a href=\"#\" onclick=\"removeTag();\" class=\"subactionbutton\">X</a>"
	}
	
	function removeTag()
	{
		var srcElem = window.event.srcElement;
		var trElem = srcElem;
		var tTable = document.getElementById("tagTable");
		
		while (trElem.tagName != "TR")
		{
			trElem = trElem.parentElement;
		}
		
		tTable.deleteRow(trElem.rowIndex);
		
		setXML();
	}
	
	function submitScrape()
	{
		var tTable = document.getElementById("tagTable");
		var hDiv = document.getElementById("hiddenInputs");
		var topTag = tTable.rows[0].cells[0].children[0].value;
		var sTags = "";
		var iTag = "";
		var y = 2;
		
		if (topTag == "")
		{
			alert("You must enter a top-level tag name");
			return;
		}
		
		sTags += "<input type=hidden name=tag_id1 value=1>";
		sTags += "<input type=hidden name=tag_name1 value=\"" + topTag + "\">";
		sTags += "<input type=hidden name=level1 value=0>";

		for (i=1; i<tTable.rows.length; i++)
		{
			iTag = "";
			iTag = tTable.rows[i].cells[1].children[0].value;
			
			if (iTag != "")
			{
				sTags += "<input type=hidden name=tag_id" + y + " value=" + y + ">";
				sTags += "<input type=hidden name=tag_name" + y + " value=\"" + iTag + "\">";
				sTags += "<input type=hidden name=level" + y + " value=1>";
				y++;
			}
			else
			{
				alert("You have added a tag with out entering a tag name. Please enter a tag name or delete the text box by clicking the 'X' button.");
				return;
			}
		}
		
		hDiv.innerHTML = sTags;
		FT.num_tags.value = (y - 1);
		FT.submit();
	}
	
</script>
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="scrape_save.jsp" TARGET="_self">
<%
if( can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="javascript:submitScrape();">Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>

<INPUT TYPE="hidden" NAME="scrape_id" value="<%=HtmlUtil.escape(scrape.s_scrape_id)%>">
<INPUT TYPE="hidden" NAME="num_tags" value="0">

<div style="display:none;" id="hiddenInputs">
</div>

<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Scrape Information</td>
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
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<!-- Name -->
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Scrape name: </td>
					<td align="left" valign="middle">
						<input type="text" size="35" name="scrape_name" value="<%= HtmlUtil.escape(scrape.s_scrape_name) %>">
					</td>
				</tr>
				<!-- Number of Urls -->
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Number of URLs to scrape: </td>
					<td align="left" valign="middle">
						<input type="text" size="3" name="num_urls" value="<%= HtmlUtil.escape(scrape.s_num_urls) %>">
					</td>
				</tr>
				<!-- Number of entries to scrape -->
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Number of entries to scrape per URL: </td>
					<td align="left" valign="middle">
						<input type="text" size="3" name="num_entries" value="<%= HtmlUtil.escape(scrape.s_num_entries) %>">
					</td>
				</tr>
				<!-- Base Url -->
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Base URL to append to Links: </td>
					<td align="left" valign="middle">
						<input type="text" size="35" name="base_url" value="<%= HtmlUtil.escape(scrape.s_base_url) %>">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Define Content Tags</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="3" border="0" width="100%">
				<tr>
					<th>Enter Tags</th>
					<th>Sample XML</th>
				</tr>
				<tr>
					<td width="50%" align="left" valign="top">
						<table class="main" cellspacing="1" cellpadding="2" width="100%" id="tagTable">
							<col width="15">
							<col>
							<col width="65">
							<%
							String sampXML = "";
								
							if (!"".equals(HtmlUtil.escape(scrape.s_scrape_id)))
							{
								int hasTop = 0;
								String topTag = "";
								String iTag = "";
								
								ScrapeTags tags = new ScrapeTags();
								tags.s_scrape_id = sScrapeId;
								tags.s_level = "0";
								tags.retrieve();

								int numTags = tags.size();
								Enumeration e = tags.elements();
								ScrapeTag tag;

								for (int i = 1; i <= numTags; i++) {
									tag = (e.hasMoreElements())?(ScrapeTag)e.nextElement():new ScrapeTag();
									hasTop = 1;
									topTag = HtmlUtil.escape(tag.s_tag_name);
									sampXML += "&lt;" + topTag + "&gt;<br>";

								%>
								<tr>
									<td colspan="2" align="left" valign="middle">
										<input type="text" name="tag_top" id="tag_top" tabindex="0" size="35" value="<%= topTag %>" onkeyup="setXML();">
									</td>
									<td align="right" valign="middle">
										<a href="javascript:addTag();" class="subactionbutton">Add Tag</a>
									</td>
								</tr>
								<%
								}
								
								if (hasTop == 0) {
								%>
								<tr>
									<td colspan="2" align="left" valign="middle">
										<input type="text" name="tag_top" id="tag_top" tabindex="0" size="35" value="" onkeyup="setXML();">
									</td>
									<td align="right" valign="middle">
										<a href="javascript:addTag();" class="subactionbutton">Add Tag</a>
									</td>
								</tr>
								<%
								}
								
								tags = new ScrapeTags();
								tags.s_scrape_id = sScrapeId;
								tags.s_level = "1";
								tags.retrieve();

								numTags = tags.size();
								e = tags.elements();

								for (int i = 1; i <= numTags; i++) {
									tag = (e.hasMoreElements())?(ScrapeTag)e.nextElement():new ScrapeTag();
									iTag = "";
									iTag = HtmlUtil.escape(tag.s_tag_name);
									sampXML += "&nbsp;&nbsp;&nbsp;&lt;" + iTag + "&gt; <i>Content Here</i> &lt;/" + iTag + "&gt;<br>";

								%>
								<tr>
									<td align="left" valign="middle"></td>
									<td align="left" valign="middle"><input type="text" name="tag_value" id="tag_value" tabindex="<%= i %>" size="35" value="<%= iTag %>" onkeyup="setXML();"></td>
									<td align="right" valign="middle"><a href="#" onclick="removeTag();" class="subactionbutton">X</a></td>
								</tr>
								<%
								}
								
								if (!"".equals(topTag)) sampXML += "&lt;/" + topTag + "&gt;<br>";
							}
							else
							{
								%>
								<tr>
									<td colspan="2" align="left" valign="middle">
										<input type="text" name="tag_top" id="tag_top" tabindex="0" size="35" value="" onkeyup="setXML();">
									</td>
									<td align="right" valign="middle">
										<a href="javascript:addTag();" class="subactionbutton">Add Tag</a>
									</td>
								</tr>
								<%
							}
							%>
						</table>
					</td>
					<td width="50%" align="left" valign="top">
						<table cellspacing="0" cellpadding="2" style="table-layout:fixed; width:100%; height:100%;">
							<tr>
								<td align="left" valign="top" id="canvas_xml"><%= sampXML %></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<% if (!"".equals(HtmlUtil.escape(scrape.s_scrape_id))) { %>
<!--- Step 3 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Specify URLs</td>
	</tr>
</table>
<br>
<!---- Step 3 Info----->
<table id="Tabs_Table3" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block3_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<!-- Name -->
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<a href="javascript:gotoURLs();" class="subactionbutton">Edit URLs</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<!--- Step 4 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 4:</b> Scrape URLs</td>
	</tr>
</table>
<br>
<!---- Step 4 Info----->
<table id="Tabs_Table4" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block4_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<!-- Name -->
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<a href="javascript:scrapeSites();" class="subactionbutton">Scrape Web Sites</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<% } %>
</FORM>
</BODY>
</HTML>
