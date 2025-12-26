<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- <xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl"> -->

<xsl:template match="/">

<html>
<head>
<META HTTP-EQUIV="Expires" CONTENT="0"/>
<META HTTP-EQUIV="Caching" CONTENT=""/>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache"/>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"/>
<title>Super Report List</title>
<xsl:element name="link">
<xsl:attribute name="rel">stylesheet</xsl:attribute>
<xsl:attribute name="href"><xsl:value-of select="CampaignList/StyleSheet"/></xsl:attribute>
<xsl:attribute name="type">text/css</xsl:attribute>
</xsl:element>
<SCRIPT src="/ccps/ui/js/scripts.js"></SCRIPT>
<script language="javascript">

function createReport()
{
	var obj = FT.category_id;
	location.href = "super_camp_edit.jsp?category_id=" + obj[obj.selectedIndex].value;
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
	FT.action = "super_camp_report_list.jsp";
	FT.method = "get";
	FT.submit();
}

</script>
</head>

<body onLoad="innerFramOnLoad()">
<xsl:element name="form">
	<xsl:attribute name="name">FT</xsl:attribute>
	<xsl:attribute name="method">post</xsl:attribute>
	<xsl:attribute name="style">display:inline;</xsl:attribute>
	<xsl:attribute name="action"><xsl:value-of select="CampaignList/CampaignView"/></xsl:attribute>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">pageCount</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="0"/></xsl:attribute>
	</xsl:element>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">curPage</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/CurrentPage"/></xsl:attribute>
	</xsl:element>

	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">rowCount</xsl:attribute>
		<xsl:attribute name="id">rowCount</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/CampRowCount"/></xsl:attribute>
	</xsl:element>

	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">CurrentCategoryID</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/CurrentCategoryID"/></xsl:attribute>
	</xsl:element>
		
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<td vAlign="middle" align="left" nowrap="true">
			<a class="newbutton" href="#" onClick="createReport();">New Super Campaign</a>&#160;&#160;&#160;
		</td>
		<td nowrap="true" valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap="true"><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap="true">&#160;Category: <span id="cat_1"></span>&#160;</td>
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
		<xsl:element name="tr">
			<xsl:if test="1 = /CampaignList/CategoryReadDisable">
				<xsl:attribute name="style">display:'none'</xsl:attribute>
			</xsl:if>
			<td valign="middle" align="right">Category:&#160;</td>
			<td valign="middle" align="left">
				<xsl:element name="select">
					<xsl:attribute name="name">category_id</xsl:attribute>
					<xsl:attribute name="size">1</xsl:attribute>
					<xsl:if test="1 = /CampaignList/CategoryDisable">
						<xsl:attribute name="disabled">true</xsl:attribute>
					</xsl:if>
					<xsl:for-each select="CampaignList/Categories/Category">
						<xsl:element name="option">
							<xsl:attribute name="value"><xsl:value-of select="CategoryID"/></xsl:attribute>
							<xsl:if test="CategoryID = /CampaignList/CurrentCategoryID">
								<xsl:attribute name="selected">SELECTED</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="CategoryName"/>
						</xsl:element>
					</xsl:for-each>
			</xsl:element>
			</td>
			<td valign="middle" align="right">&#160;</td>
		</xsl:element>
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

<table cellspacing="0" cellpadding="0" width="95%" border="0">
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
			Super Reports&#160;
			<br /><br />
			<!-- List of the Compaigns -->
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Edit</th>
					<th>Super Campaign Name</th>
					<th>Size</th>
					<th>Bounce Backs</th>
					<th>Click Throughs</th>
					<th>Unsubscribes</th>
					<th>Update</th>
					<th>Last Update Date</th>
					<th>Update Status</th>
				</tr>

				<xsl:for-each select="CampaignList/Campaigns/Row">
					
					<tr>
						<xsl:variable name="status_id" select="UpdateStatusId"/>

						<!-- Edit -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="class">subactionbutton</xsl:attribute>
								<xsl:attribute name="href">super_camp_object.jsp?super_camp_id=<xsl:value-of select="Id"/>&#38;category_id=<xsl:value-of select="/CampaignList/CurrentCategoryID"/></xsl:attribute>
								Edit
							</xsl:element>
							&#160;
						</xsl:element>

						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
							<!-- <a href=Campaign name> -->
							<xsl:choose>
								<xsl:when test="UpdateStatusId &lt; 10">
									<xsl:value-of select="Name"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="a">
										<xsl:attribute name="href"><xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/></xsl:attribute>
										<xsl:value-of select="Name"/>
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
							&#160;
						</xsl:element>

						<!-- Size (Number of recipients) -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="Size"/>
							&#160;
						</xsl:element>

						<!-- Bounce Backs -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="BBacks"/>
							&#160;(<xsl:value-of select="BBackPrc"/>%)
							&#160;
						</xsl:element>

						<!-- Click Throughs -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="Clicks"/>
							&#160;(<xsl:value-of select="ClickPrc"/>%)
							&#160;
						</xsl:element>

						<!-- Unsubscribes -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="Unsubs"/>
							&#160;(<xsl:value-of select="UnsubPrc"/>%)
							&#160;
						</xsl:element>

						<!-- Update -->
                                                <!-- LW 12/5/2006 Team Track 5215: If UpdateAutoReportEnabled = false do not allow updates on Auto-Update super reports. -->
                                                <!-- If the report status = Queued, do not allow updates -->
                              
                               <!--                 
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="UpdateStatusId &lt; 10">
									<xsl:element name="a">
										<xsl:attribute name="class">subactionbutton</xsl:attribute>
										<xsl:attribute name="href">
											<xsl:value-of select="/CampaignList/CampaignUpdate"/>?id=<xsl:value-of select="Id"/>
										</xsl:attribute>
										Update
									</xsl:element>
								</xsl:when>
								<xsl:when test="UpdateStatusId &gt; 19">
									<xsl:element name="a">
										<xsl:attribute name="class">subactionbutton</xsl:attribute>
										<xsl:attribute name="href">
											<xsl:value-of select="/CampaignList/CampaignUpdate"/>?id=<xsl:value-of select="Id"/>
										</xsl:attribute>
										Update
									</xsl:element>
								</xsl:when>
								<xsl:otherwise>
									&#160;
								</xsl:otherwise>
							</xsl:choose>&#160;&#160;&#160;
						</xsl:element>
                                -->                
                                                <xsl:if test="/CampaignList/UpdateAutoReportEnabled = 'true'">
                                                <xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="UpdateStatusId = 10">
									&#160;
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="a">
										<xsl:attribute name="class">subactionbutton</xsl:attribute>
										<xsl:attribute name="href">
											<xsl:value-of select="/CampaignList/CampaignUpdate"/>?id=<xsl:value-of select="Id"/>
										</xsl:attribute>
										Update
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>&#160;&#160;&#160;
						</xsl:element>
                                                </xsl:if>   
                                                
						<xsl:if test="/CampaignList/UpdateAutoReportEnabled = 'false'">
                                                <xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="UpdateStatusId = 10">
									&#160;
								</xsl:when>
								<xsl:when test="UpdateStatusId = 11">
									&#160;
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="a">
										<xsl:attribute name="class">subactionbutton</xsl:attribute>
										<xsl:attribute name="href">
											<xsl:value-of select="/CampaignList/CampaignUpdate"/>?id=<xsl:value-of select="Id"/>
										</xsl:attribute>
										Update
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>&#160;&#160;&#160;
						</xsl:element>
                                                </xsl:if>   

						<!-- Last Update Date -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<nobr><xsl:value-of select="UpdateDate"/></nobr>
							&#160;
						</xsl:element>

						<!-- Update Status -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="UpdateStatus"/>
							&#160;
						</xsl:element>

					</tr>

				</xsl:for-each>
				
			</table>
		</td>
	</tr>
</table>
<br /><br />

<!-- </form> -->
</xsl:element>

<script language="javascript">
function innerFramOnLoad()
{
	
	FT.amount.value = "<xsl:value-of select="CampaignList/PageAmount"/>";
	var perPage = new Number("<xsl:value-of select="CampaignList/PageAmount"/>");
	
	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");
	
	var catName = FT.category_id[FT.category_id.selectedIndex].text;
	
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
	
	document.getElementById("cat_1").innerHTML = catName;
	document.getElementById("rec_1").innerHTML = perPage;
	document.getElementById("page_1").innerHTML = finalMessage;
}
</script>
</body>

</html>

</xsl:template>
</xsl:stylesheet>
