<?xml version="1.0" encoding="UTF-8"?>
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
	<title>Report List</title>
	<xsl:element name="link">
		<xsl:attribute name="rel">stylesheet</xsl:attribute>
		<xsl:attribute name="href"><xsl:value-of select="CampaignList/StyleSheet"/></xsl:attribute>
		<xsl:attribute name="type">text/css</xsl:attribute>
	</xsl:element>
	<xsl:element name="link">
			<xsl:attribute name="rel">stylesheet</xsl:attribute>
			<xsl:attribute name="href">http://datatables.net/release-datatables/media/css/demo_table_jui.css</xsl:attribute>
			<xsl:attribute name="type">text/css</xsl:attribute>
	</xsl:element>
	<xsl:element name="link">
			<xsl:attribute name="rel">stylesheet</xsl:attribute>
			<xsl:attribute name="href">http://datatables.net//media/css/jui_themes/smoothness/jquery-ui-1.7.2.custom.css</xsl:attribute>
			<xsl:attribute name="type">text/css</xsl:attribute>
	</xsl:element>
	
	<SCRIPT src="/cms/ui/js/scripts.js"></SCRIPT>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	
<script language="javascript">

	function PrepSubmit(Act)
	{
		var ListId='';
                var indUpdateNotAllowed = 0;
                var tempListId='';
                var ListString = '';
		FT.UpdList.value = '';
		FT.CompList.value = '';
		FT.ExpList.value = '';
		var numChecks = 0;
                
                // Act = Export
		if (Act == '3')
		{
			if (FT.UCheck.length == undefined)
			{
				if (FT.UCheck.checked)
				{
                                        indUpdateNotAllowed = FT.UCheck.value.indexOf(';DoNotAllowUpdate'); 
                                        if (indUpdateNotAllowed > 0) 
                                        {
                                            FT.UCheck.value= FT.UCheck.value.slice(0,indUpdateNotAllowed);
                                        }
					FT.ExpList.value += FT.UCheck.value + ",";
					if (ListId !='') ListId += ',';
					ListId += FT.UCheck.value;
					numChecks++;
				}
			}
			else
			{
				for (i=0; i &lt; FT.UCheck.length; i++)
				{
					if (FT.UCheck[i].checked)
					{
                                                indUpdateNotAllowed = FT.UCheck[i].value.indexOf(';DoNotAllowUpdate'); 
                                                if (indUpdateNotAllowed > 0) 
                                                {
                                                    FT.UCheck[i].value = FT.UCheck[i].value.slice(0,indUpdateNotAllowed);
                                                }
						FT.ExpList.value += FT.UCheck[i].value + ",";
						if (ListId !='') ListId += ',';
						ListId += FT.UCheck[i].value;
						numChecks++;
					}
				}
			}
			if (ListId != '')
			{
				FT.action = "report_export.jsp?id=" + ListId;
				FT.submit();
				return;
			}
			else
			{
				alert("Choose at least one report to export.");
			}
		}
                
		// Act = Update
		if (Act == '2')
		{ 
                        // if the status of the report = 10 (queued) do not allow the report to be re-queued. 
                        // if the UpdateAutoReportEnabled flag is not on and the report is selected to be updated, do not queue up this report.
			if (FT.UCheck.length == undefined)
			{
				if (FT.UCheck.checked)
				{
                                            indUpdateNotAllowed = 0;
                                            indUpdateNotAllowed = FT.UCheck.value.indexOf(';DoNotAllowUpdate'); 
                                            if (indUpdateNotAllowed > 0) 
                                            {
                                               // skip over any auto update reports and do not add to the report_update.jsp list.
                                            }
                                            else 
                                            {
                                              FT.UpdList.value += FT.UCheck.value + ",";
                                              if (ListId !='') ListId += ',';
                                              ListId += FT.UCheck.value;
                                              numChecks++;
                                            }
                                        
          			}
			}
			else
			{
				for (i=0; i &lt; FT.UCheck.length; i++)
				{
					if (FT.UCheck[i].checked)
					{
                                        
                                            indUpdateNotAllowed = 0;
                                            indUpdateNotAllowed = FT.UCheck[i].value.indexOf(';DoNotAllowUpdate'); 
                                                          
                                            if (indUpdateNotAllowed > 0) 
                                            {
                                              continue;  // skip over any auto update reports and do not add to the report_update.jsp list.
                                            }
                                            else 
                                            {
                                              FT.UpdList.value += FT.UCheck[i].value + ",";
                                              if (ListId !='') ListId += ',';
                                              ListId += FT.UCheck[i].value;
                                              numChecks++;
                                            }
                                        
  					}
				}
			}

			if (ListId != '')
			{
				FT.action = "report_update.jsp?id=" + ListId;
				FT.submit();
				return;
			}
			else
			{
				alert("Choose at least one report to update or choose at least one report whose status is not Auto-Update nor Queued");
			}
		}
		// Act = Compare Reports
		if (Act == '1')
		{
			if (FT.UCheck.length == undefined)
			{
				if (FT.UCheck.checked)
				{
                                        indUpdateNotAllowed = FT.UCheck.value.indexOf(';DoNotAllowUpdate'); 
                                        if (indUpdateNotAllowed > 0) 
                                        {
                                            FT.UCheck.value = FT.UCheck.value.slice(0,indUpdateNotAllowed);
                                        }
					FT.CompList.value += FT.UCheck.value + ",";
					if (ListId !='') ListId += ',';
					ListId += FT.UCheck.value;
					numChecks++;
				}
			}
			else
			{
				for (i=0; i &lt; FT.UCheck.length; i++)
				{
					if (FT.UCheck[i].checked)
					{
                                                indUpdateNotAllowed = FT.UCheck[i].value.indexOf(';DoNotAllowUpdate'); 
                                                if (indUpdateNotAllowed > 0) 
                                                {
                                                    FT.UCheck[i].value = FT.UCheck[i].value.slice(0,indUpdateNotAllowed);
                                                }
						FT.CompList.value += FT.UCheck[i].value + ",";
						if (ListId !='') ListId += ',';
						ListId += FT.UCheck[i].value;
						numChecks++;
					}
				}
			}

			if (ListId != '')
			{
				FT.action += "?act=VIEW&amp;id=" + ListId;
				FT.submit();
			}
			else
			{
				alert("Choose at least one report to view.");
			}
		}
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
	FT.action = "report_list.jsp";
	FT.method = "get";
	FT.submit();
}


</script>

	<SCRIPT src="../../js/jquery.js"></SCRIPT>
	<SCRIPT src="http://datatables.net/release-datatables/media/js/jquery.dataTables.min.js"></SCRIPT>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#checkboxall").click(function() 
			{ 
				var checked_status = this.checked;  
				$(".check_me").each(function(){
					this.checked = checked_status;
				});				
			}); 
			
			$('#example tbody td').hover( function() {
				$(this).siblings().addClass('highlighted');
				$(this).addClass('highlighted');
			}, function() {
				$(this).siblings().removeClass('highlighted');
				$(this).removeClass('highlighted');
			} );
			$('#example2 tbody td').hover( function() {
				$(this).siblings().addClass('highlighted');
				$(this).addClass('highlighted');
			}, function() {
				$(this).siblings().removeClass('highlighted');
				$(this).removeClass('highlighted');
			} );
			oTable = $('#example').dataTable( {
										"bJQueryUI": true,
										"sPaginationType": "full_numbers"
				} );
			oTable2 = $('#example2').dataTable({
				"sDom": "tlrip",
				"aoColumns": [null,null,null,null,null,null,null],
				"aaSorting": [[ 0, "desc" ]]
			});
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 2);
				filter_string = $('#filter').val();
				oTable2.fnFilter( filter_string , 3);
			});
		} );
	</script>
</head>
<body class="paging_body">
<div class="page_header">Reporting</div>
<div class="page_desc">See the results of your campaigns.</div>
<xsl:element name="form">
	<xsl:attribute name="name">FT</xsl:attribute>
	<xsl:attribute name="id">FT</xsl:attribute>
	<xsl:attribute name="method">post</xsl:attribute>
	<xsl:attribute name="style">display:inline;</xsl:attribute>
	<xsl:attribute name="action"><xsl:value-of select="CampaignList/CampaignView"/></xsl:attribute>

	<input type="hidden" name="CompList" value=""/>
	<input type="hidden" name="UpdList" value=""/>
	<input type="hidden" name="ExpList" value=""/>

	<!-- <input type="hidden" name="Retrieve" value=""/> -->
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">Retrieve</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/ActionGet"/></xsl:attribute>
	</xsl:element>

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
		<xsl:attribute name="name">CurrentCategoryID</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/CurrentCategoryID"/></xsl:attribute>
	</xsl:element>

	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">rowCount</xsl:attribute>
		<xsl:attribute name="id">rowCount</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/CampRowCount"/></xsl:attribute>
	</xsl:element>
        
        <xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">updateAutoReportEnabled</xsl:attribute>
		<xsl:attribute name="id">updateAutoReportEnabled</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/UpdateAutoReportEnabled"/></xsl:attribute>
	</xsl:element>

<div id="info">
<div id="xsnazzy">

<div class="xboxcontent">
		
			<table class="listTable" cellSpacing="0" cellPadding="2" width="100%" style="padding-top: 4px;">
				<tbody>
					<tr>
						<td  nowrap="true" align="left" style="padding-left:10px; width:5%;">
							<a class="newbutton" href="#1" OnClick="PrepSubmit('1');">
							&#160;Compare</a>
						</td>
						<td vAlign="middle" align="left" nowrap="true">
							<a class="newbutton" href="#1" OnClick="PrepSubmit('2');">
							&#160;Update</a>
						</td>
						<td vAlign="middle" align="left" nowrap="true">
							<a class="newbutton" href="#1" OnClick="PrepSubmit('3');">
							&#160;Export to Excel</a>
						</td>
						<td nowrap="true" valign="middle" align="right" width="100%">
						<!--
							<table class="filterList" cellspacing="1" cellpadding="0" border="0">
								<tr>
									<td align="right" valign="middle" nowrap="true"><a class="filterHeading" href="#" onclick="filterReveal(30,event);">Filter:</a></td>
									<td align="right" valign="middle" nowrap="true">&#160;Category: <span id="cat_1"></span>&#160;</td>
									<td align="right" valign="middle" nowrap="true">&#160;Records / Page: <span id="rec_1"></span>&#160;</td>
								</tr>
							</table>
							-->
						</td>
						<TD nowrap="true" align="right" style="padding-right:10px;">
							<A class="newbutton" href="report_list.jsp">Refresh</A>
						</TD>
					</tr>
				</tbody>
			</table>
			
			<div class="list-headers">Reports</div>
			
			<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"/></th>
					<th></th>
					<th valign="middle" nowrap="true">Campaign Name</th>
					<th valign="middle" nowrap="true">Type</th>
					<th valign="middle" nowrap="true">Start Date</th>
					<th valign="middle" nowrap="true">Size</th>
					<th valign="middle" nowrap="true">Reads</th>
					<th valign="middle" nowrap="true">Clicks</th>
					<th valign="middle" nowrap="true">Bounce Backs</th>
					<th valign="middle" nowrap="true">Unsubs</th>
					<th valign="middle" nowrap="true">Update Date</th>
					<th valign="middle" nowrap="true">Update Status</th>
				</thead>
				<tbody>

				<xsl:for-each select="CampaignList/Campaigns/Row">
					<tr>
						<xsl:variable name="status_id" select="UpdateStatusId"/>
						
						<!-- Update -->
						<!-- Release 5.9 Update for auto report enabled -->
						<!--
						<xsl:if test="/CampaignList/UpdateAutoReportEnabled = 'true'">
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:attribute name="align">center</xsl:attribute>
							<xsl:choose>
								<xsl:when test="UpdateStatusId &lt; 10">
								<xsl:element name="input">
									<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
									<xsl:attribute name="value"><xsl:value-of select="Id"/></xsl:attribute>
								</xsl:element>
								</xsl:when>
								
								<xsl:when test="UpdateStatusId = 11">
									<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/></xsl:attribute>
						</xsl:element>
								</xsl:when>
								
								<xsl:when test="UpdateStatusId &gt; 19">
									<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/></xsl:attribute>
									</xsl:element>
								</xsl:when>
								<xsl:otherwise>
									&#160;
								</xsl:otherwise>
							</xsl:choose>&#160;
						</xsl:element>
						</xsl:if>
						-->
						<!-- Update -->
                                                <!-- LW 12/1/2006 display check box in all cases of campaign status but add a string to not allow Update Box to be checked if UpdateAutoReportEnable = false -->
						<xsl:if test="/CampaignList/UpdateAutoReportEnabled = 'true'">
                                                <xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:attribute name="align">center</xsl:attribute>
                                                        <xsl:attribute name="align">center</xsl:attribute>
                                                         <xsl:choose>
                                                         <xsl:when test="UpdateStatusId = 10">
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="class">check_me</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/>;DoNotAllowUpdate</xsl:attribute>
                                                                    </xsl:element>
							</xsl:when>
                                                        <xsl:otherwise>
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="class">check_me</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/></xsl:attribute>
								</xsl:element>
							</xsl:otherwise>
							</xsl:choose>&#160;
						</xsl:element>
                                                </xsl:if>
                                                
						<xsl:if test="/CampaignList/UpdateAutoReportEnabled = 'false'">
                                                <xsl:element name="td">  
                                                <xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
						<xsl:attribute name="align">center</xsl:attribute>
                                                <xsl:choose>
                                                    <xsl:when test="UpdateStatusId = 10">
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="class">check_me</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/>;DoNotAllowUpdate</xsl:attribute>
                                                                    </xsl:element>
							</xsl:when>
		    					<xsl:when test="UpdateStatusId = 11">
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="class">check_me</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/>;DoNotAllowUpdate</xsl:attribute>
                                                                    </xsl:element>
							</xsl:when>
                                                        <xsl:otherwise>
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="class">check_me</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/></xsl:attribute>
								</xsl:element>
							</xsl:otherwise>
							</xsl:choose>&#160;
                                                </xsl:element>
                                                </xsl:if>   
                                                <!--  End of Action Check Box -->
												<!-- icon start -->
							<xsl:element name="td">	
								<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>	
								<img alt="image" src="../../images/icon_report_18_18.png"/>
								
							</xsl:element>	
												<!-- icon end -->
						<xsl:element name="td">
                                                
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<!-- <a href=Campaign name> -->
							<xsl:choose>
								<xsl:when test="UpdateStatusId &lt; 10">
									<xsl:value-of select="Name"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="a">
										<xsl:attribute name="href">
										<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/></xsl:attribute>
										<xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:value-of select="Name"/>
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
							&#160;
						</xsl:element>
						
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:if test="TypeId = 2">Standard</xsl:if>
							<xsl:if test="TypeId = 3">S2F</xsl:if>
							<xsl:if test="TypeId = 4">Automated</xsl:if>
							<xsl:if test="TypeId = 5">Web/DM/Call</xsl:if>
							&#160;
							<xsl:if test="/CampaignList/PrintEnabled = 'true'">
							<xsl:if test="MediaTypeId = 1">(Email)</xsl:if>
							<xsl:if test="MediaTypeId = 2">(Print)</xsl:if>
							&#160;
							</xsl:if>
						</xsl:element>

						<!-- Start Date -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="StartDate"/>
						</xsl:element>

						<!-- Size (Number of recipients) -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="Size"/>&#160;
						</xsl:element>

						<!-- Reads -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 5">N/A</xsl:if>
                            <xsl:if test="TypeId != 5">                              
							    <xsl:value-of select="TReads"/>&#160;(<xsl:value-of select="TReadsPrc"/>%)&#160;
                            </xsl:if>
                        </xsl:element>
						
						<!-- Click Throughs -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 5">N/A</xsl:if>
                            <xsl:if test="TypeId != 5">                              
							    <xsl:value-of select="Clicks"/>&#160;(<xsl:value-of select="ClickPrc"/>%)&#160;
                            </xsl:if>
                        </xsl:element>
						
						<!-- Bounce Backs -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 5">N/A</xsl:if>
                            <xsl:if test="TypeId != 5">                              
                                <xsl:value-of select="BBacks"/>&#160;(<xsl:value-of select="BBackPrc"/>%)&#160;
                            </xsl:if>
						</xsl:element>

						<!-- Unsubscribes -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 5">N/A</xsl:if>
                            <xsl:if test="TypeId != 5">                              
							    <xsl:value-of select="Unsubs"/>&#160;(<xsl:value-of select="UnsubPrc"/>%)&#160;
                            </xsl:if>
						</xsl:element>
						
						<!-- Last Update Date -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<nobr><xsl:value-of select="UpdateDate"/>&#160;</nobr>
						</xsl:element>

						<!-- Update Status -->
						<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:if test="StartDate  = UpdateDate">
								<xsl:value-of select="UpdateStatus"/>&#160;
							</xsl:if>
                            <xsl:if test="StartDate != UpdateDate">                              
							    <xsl:value-of select="UpdateStatus"/>&#160;<font color="red">*<xsl:value-of select="UpdateStatusId"/></font>&#160;
                            </xsl:if>
						</xsl:element>
						
						<!-- Cache -->
			<!--		<xsl:element name="td">
							<xsl:attribute name="class">list_row<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:attribute name="align">center</xsl:attribute>
							<xsl:attribute name="width">80</xsl:attribute>
							<xsl:choose>
								<xsl:when test="Cache &gt; 0">
									<xsl:element name="a">
										<xsl:attribute name="href"><xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;Z=<xsl:value-of select="Cache"/></xsl:attribute>
										View
									</xsl:element>
								</xsl:when>
								<xsl:otherwise>
									&#160;
								</xsl:otherwise>
							</xsl:choose>&#160;
						</xsl:element> -->
					</tr>

				</xsl:for-each>
				</tbody>
			</table>
</div>

</div></div>
</xsl:element>
</body>
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

</html>

</xsl:template>
</xsl:stylesheet>
