<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">

<html> 
<head> 
<META HTTP-EQUIV="Expires" CONTENT="0"/>
<META HTTP-EQUIV="Caching" CONTENT=""/>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache"/>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"/>
<title>Customer Reports</title> 
<xsl:element name="link">
<xsl:attribute name="rel">stylesheet</xsl:attribute>
<xsl:attribute name="href"><xsl:value-of select="ReportList/StyleSheet"/></xsl:attribute>
<xsl:attribute name="type">text/css</xsl:attribute>
</xsl:element>
<SCRIPT src="/ccps/ui/js/scripts.js"></SCRIPT>

<script language="javascript">

function createReport()
{
	location.href = "cust_report_create.jsp";
}

function updateReport(id, start, end)
{
	location.href = "cust_report_save.jsp?report_id=" + id +
						"&amp;start_date=" + start +
						"&amp;end_date=" + end;
}

function GO(parm)
{
	switch( parm )
	{
		case 0:
				FT.curPage.value = 1;
				break;
		case 1:
				FT.curPage.value = "<xsl:value-of select="CampaignList/NextPage"/>";
				break;
		case 2:
				break;
		case -1:
				FT.curPage.value = "<xsl:value-of select="CampaignList/PrevPage"/>";
				break;
		case 99:
				FT.curPage.value = FT.pageCount.value;
				break;
	}
	FT.action = "cust_report_list.jsp";
	FT.method = "get";
	FT.submit();
}

function toggleInfo(obj)
{
	var addData = document.getElementById("data_" + obj);
	var addLink = document.getElementById("link_" + obj);
	
	if (addData.style.display == "none")
	{
		addData.style.display = "";
		addLink.innerText = "Hide Additional Data";
	}
	else
	{
		addData.style.display = "none";
		addLink.innerText = "Additional Data";
	}
}

</script>
</head> 

<body onLoad="innerFramOnLoad()"> 

<xsl:element name="form">
	<xsl:attribute name="name">FT</xsl:attribute>
	<xsl:attribute name="method">post</xsl:attribute>
	<xsl:attribute name="style">display:inline;</xsl:attribute>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">pageCount</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="0"/></xsl:attribute>
	</xsl:element>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">curPage</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="ReportList/CurrentPage"/></xsl:attribute>
	</xsl:element>

	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">rowCount</xsl:attribute>
		<xsl:attribute name="id">rowCount</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="ReportList/CampRowCount"/></xsl:attribute>
	</xsl:element>
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<td vAlign="middle" align="left" nowrap="true">
			<a class="newbutton" href="#" onclick="createReport();">New Global Report</a>&#160;&#160;&#160;
		</td>
		<td nowrap="true" valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap="true"><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap="true">&#160;Records / Page: <span id="rec_1"></span>&#160;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Reports</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&#160;<b>X</b>&#160;</th>
		</tr>
		<tr>
			<td valign="middle" align="right">&#160;Paging:&#160;</td>
			<td valign="middle" align="left">
				<select name="amount" size="1">
					<option value="1000">All</option>
					<option value="10">10</option>
					<option value="25">25</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
			</td>
			<td valign="middle" align="right">&#160;</td>
		</tr>
		<tr>
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(2);">Filter</a></td>
			<td valign="middle" align="right">&#160;</td>
		</tr>
	</table>
</div>
<br />

<table width="95%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap="true" align="left">
			<table class="main" cellspacing="1" cellpadding="2" border="0" align="right">
				<tr>
					<td align="right" valign="middle" nowrap="true">&#160;&#160;<a class="resourcebutton" href="javascript:GO(2)">Refresh List</a>&#160;&#160;</td>
					<td align="right" valign="middle" nowrap="true">&#160;<span id="page_1"></span></td>
					<td align="center" valign="middle">
						<table class="main" cellspacing="0" cellpadding="5" border="0">
							<tr>
								<td align="right" valign="middle" nowrap="true" id="first_page" style="display:none"><a href="javascript:GO(0)">&lt;&lt; First</a></td>
								<td align="right" valign="middle" nowrap="true" id="prev_page" style="display:none"><a href="javascript:GO(-1)">&lt; Previous</a></td>
								<td align="right" valign="middle" nowrap="true" id="next_page" style="display:none"><a href="javascript:GO(1)">Next &gt;</a></td>
								<td align="right" valign="middle" nowrap="true" id="last_page" style="display:none"><a href="javascript:GO(99)">Last &gt;&gt;</a></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			Global Reports&#160;
			<br /><br />
			<!-- List of the contents -->
			<xsl:for-each select="ReportList/Reports/Row">
				<table class="listTable" width="100%" cellpadding="2" cellspacing="0" id="reportTable">
					<tr>
						<xsl:if test="not(ReportList/Viewer)">
							<td valign="top" nowrap="true">
								<table border="0" cellpadding="2" cellspacing="0">
									<tr>
										<td nowrap="true">
											<xsl:element name="a">
												<xsl:attribute name="class">subactionbutton</xsl:attribute>
												<xsl:attribute name="href">#</xsl:attribute>
												<xsl:attribute name="border">0</xsl:attribute>
												<xsl:attribute name="style">cursor:hand</xsl:attribute>
												<xsl:attribute name="onclick">updateReport(<xsl:value-of select="report_id"/>,'<xsl:value-of select="start_date"/>','<xsl:value-of select="end_date"/>')</xsl:attribute>
												Update
											</xsl:element>&#160;&#160;&#160;
										</td>
									</tr>
								</table>
							</td>
						</xsl:if>
						<td width="100%" class="listItem_Data" valign="top" nowrap="true">
							<table width="100%" border="0" cellpadding="2" cellspacing="0">
								<tr>
									<th nowrap="true"><b>Start Date: </b></th>
									<th nowrap="true"><b>End Date: </b></th>
									<th nowrap="true"><b>Last Update Date: </b></th>
									<th nowrap="true"><b>Report Status: </b></th>
								</tr>
								<tr>
									<td nowrap="true" class="listItem_Data" width="25%"><xsl:value-of select="start_date_display"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="25%"><xsl:value-of select="end_date_display"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="25%"><xsl:value-of select="update_date"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="25%"><xsl:value-of select="status"/>&#160;</td>
								</tr>
							</table>
							<br />
							<table width="100%" border="0" cellpadding="2" cellspacing="0">
								<tr>
									<td nowrap="true" class="subsectionheader"><b># of Campaigns: </b></td>
									<td nowrap="true" class="subsectionheader"><b># Messages Sent: </b></td>
									<td nowrap="true" class="subsectionheader"><b># Messages Not Sent: </b></td>
								</tr>
								<tr>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="camp_qty"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="sent"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="34%"><xsl:value-of select="not_sent"/>&#160;</td>
								</tr>
								<tr>
									<td nowrap="true" class="subsectionheader"><b>Detected HTML: </b></td>
									<td nowrap="true" class="subsectionheader"><b>Detected Text: </b></td>
									<td nowrap="true" class="subsectionheader"><b>Unconfirmed: </b></td>
								</tr>
								<tr>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="detect_html"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="detect_text"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="34%"><xsl:value-of select="unconfirmed"/>&#160;</td>
								</tr>
								<tr>
									<td nowrap="true" class="subsectionheader"><b>Are Active: </b></td>
									<td nowrap="true" class="subsectionheader"><b>Have Bounced Back: </b></td>
									<td nowrap="true" class="subsectionheader"><b>Status of Bounced Back: </b></td>
								</tr>
								<tr>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="active"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="have_bback"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="34%"><xsl:value-of select="are_bback"/>&#160;</td>
								</tr>
								<tr>
									<td nowrap="true" class="subsectionheader"><b>Have Unsubscribed: </b></td>
									<td nowrap="true" class="subsectionheader"><b>Have Clicked Links: </b></td>
									<td nowrap="true" class="subsectionheader"><b>Clicked Multiple Links: </b></td>
								</tr>
								<tr>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="unsub"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="33%"><xsl:value-of select="click"/>&#160;</td>
									<td nowrap="true" class="listItem_Data" width="34%"><xsl:value-of select="multi_click"/>&#160;</td>
								</tr>
								<tr>
									<td nowrap="true" class="listItem_Data" colspan="3" style="padding:10px;">
										<a class="resourcebutton">
											<xsl:attribute name="id">link_<xsl:value-of select="report_id"/></xsl:attribute>
											<xsl:attribute name="href">javascript:toggleInfo('<xsl:value-of select="report_id"/>');</xsl:attribute>
											Additional Data
										</a>
									</td>
								</tr>
								<tr>
									<td nowrap="true" class="listItem_Data" colspan="3" style="display:none;">
										<xsl:attribute name="id">data_<xsl:value-of select="report_id"/></xsl:attribute>
										<table width="100%" border="0" cellpadding="2" cellspacing="0">
											<tr>
												<th colspan="3" nowrap="true">Bounceback Categories:</th>
											</tr>
											<tr>
												<td nowrap="true" class="subsectionheader"><b>Category</b></td>
												<td nowrap="true" class="subsectionheader"><b>Bouncebacks</b></td>
											</tr>
											<xsl:for-each select="BounceBacks">
												<tr>
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="CategoryName"/>
													</xsl:element>
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="BBacks"/>
															(<xsl:value-of select="BBackPrc"/>%)
													</xsl:element>
												</tr> 
											</xsl:for-each>
										</table>
										<br />
										<table width="100%" border="0" cellpadding="2" cellspacing="0">
											<tr>
												<th colspan="7" nowrap="true">Domain Deliverability:</th>
											</tr>
											<tr>
												<td nowrap="true" class="subsectionheader"><b>Domain</b></td>
												<td nowrap="true" class="subsectionheader"><b>Sent</b></td>
												<td nowrap="true" class="subsectionheader"><b>Bounced back</b></td>
												<td nowrap="true" class="subsectionheader"><b>Read</b></td>
												<td nowrap="true" class="subsectionheader"><b>Clicked</b></td>
												<td nowrap="true" class="subsectionheader"><b>Total Unsubscribed</b></td>
												<td nowrap="true" class="subsectionheader"><b>Unsubscribe - Spam Complaints</b></td>
											</tr>
											<xsl:for-each select="Domains">
												<tr>
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="Domain"/>
													</xsl:element>
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="Sent"/> 
													</xsl:element>
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="BBacks"/>
															(<xsl:value-of select="BBackPrc"/>%)
													</xsl:element>
													<!-- added for release 5.9 , Domain Deliverability changes -->
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="Reads"/> 
															(<xsl:value-of select="ReadPrc"/>%)
													</xsl:element>
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="Clicks"/> 
															(<xsl:value-of select="ClickPrc"/>%)
													</xsl:element>
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="Unsubs"/> 
															(<xsl:value-of select="UnsubPrc"/>%)
													</xsl:element>
													<!-- end release 5.9 changes -->
													<!-- Release 6.1: Spam Complaints -->
													<xsl:element name="td">
														<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
														<xsl:attribute name="nowrap">true</xsl:attribute>
															<xsl:value-of select="UnsubsSpam"/> 
															(<xsl:value-of select="UnsubsSpamPrc"/>%)
													</xsl:element>						
													<!-- end -->							
												</tr> 
											</xsl:for-each>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				<br/>
			</xsl:for-each>
			<!-- End of block -->
		</td>
	</tr>
</table>
<br /><br />

</xsl:element>

</body>

<script language="javascript">
function innerFramOnLoad(){

FT.amount.value = "<xsl:value-of select="ReportList/PageAmount"/>";
var perPage = new Number("<xsl:value-of select="ReportList/PageAmount"/>");

var prevPage = document.getElementById("prev_page");
var firstPage = document.getElementById("first_page");
var nextPage = document.getElementById("next_page");
var lastPage = document.getElementById("last_page");

var pageAmount = new Number(perPage);

var recCount = new Number(FT.rowCount.value);
var thisPage = new Number(FT.curPage.value);

if (thisPage > 1)
{
	prevPage.style.display = "";
	firstPage.style.display = "";
}

if (recCount > (thisPage*pageAmount))
{
	nextPage.style.display = "";
	lastPage.style.display = "";
}

var pageCount = new Number(Math.ceil(recCount / perPage));

if (pageCount == 0) pageCount = 1;
FT.pageCount.value = pageCount;

var startRec = ((thisPage - 1) * perPage) + 1;
var endRec = ((thisPage - 1) * perPage) + perPage;

if (endRec >= recCount) endRec = recCount;
if (perPage == 1000) perPage = "ALL";

if (thisPage == 1)
{
	firstPage.style.display = "none";
	prevPage.style.display = "none";
}

if (thisPage >= pageCount)
{
	lastPage.style.display = "none";
	nextPage.style.display = "none";
}

var finalMessage = "";

if (recCount == 0) finalMessage = "0 records";
else
{
	finalMessage =
		"Page " + thisPage + " of " + pageCount +
		" (records " + startRec + " to " + endRec + " of " + recCount + " records)";
}

document.getElementById("rec_1").innerHTML = perPage;
document.getElementById("page_1").innerHTML = finalMessage;
}
</script>


</html>

</xsl:template>
</xsl:stylesheet>
