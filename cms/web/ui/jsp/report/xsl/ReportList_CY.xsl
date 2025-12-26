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
	<SCRIPT src="/ccps/ui/js/scripts.js"></SCRIPT>

<script language="javascript">
   
   var Domain="Alls";
   var TimeFrame="1";
   var ColumnName="Alls";
   var ShortBy="1"; 
   
   function Descending(tagno1)
   {
  	 FT.ColName.value="";
     FT.AscDes.value="";
    
     switch( tagno1 )
	 {
		case 1:
		        
				FT.camUpDown.value= "2";
				FT.listno.value='2';
				break;
		
		case 2:
		       
				FT.camtypeUpDown.value="4";
				FT.listno.value='4';
				break;
		case 3:
				FT.sizeUpDown.value= "6";
				FT.listno.value='6';
				break;
		
		case 4:
				FT.bouncebUpDown.value="8";
				FT.listno.value='8';
				break;		
		case 5:
				FT.clicktUpDown.value="10";
				FT.listno.value='10';
				break;
		case 6:
				FT.unsubscribUpDown.value="12";
				FT.listno.value='12';
				break;	
	    case 7:
				FT.updatedUpDown.value="14";
				FT.listno.value='14';
				break;	
		case 8:
		        FT.openUpDown.value="16";
				FT.listno.value='16';
				break;							
						
	}
	  
	  FT.action = "report_list_cy.jsp";
	  FT.method = "get";
	  FT.submit();
    
    
	
   }
   function Ascending(tagno2)
   {
  	 FT.ColName.value="";
     FT.AscDes.value="";

     switch( tagno2)
	  {
		  case 1:
				 FT.camUpDown.value= "1";
				 FT.listno.value='1';
				 break;
		  case 2:
				 FT.camtypeUpDown.value="3";
				 FT.listno.value='3';
				 break;
		  case 3:
				FT.sizeUpDown.value="5";
				FT.listno.value='5';
				break;				
		  case 4:
				 FT.bouncebUpDown.value="7";
				 FT.listno.value='7';
				 break;
		  case 5:
				FT.clicktUpDown.value="9";
				FT.listno.value='9';
				break;
		 case 6:
				FT.unsubscribUpDown.value="11";
				FT.listno.value='11';
				break;
		 case 7:
				FT.updatedUpDown.value="13";
				FT.listno.value='13';
				break;	
		case 8:
		     FT.openUpDown.value="15";
				FT.listno.value='15';
				break;					
	  }
	 
	  FT.action = "report_list_cy.jsp";
	  FT.method = "get";
	  FT.submit();
   } 
	
	
	
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
	
	FT.listno.value="<xsl:value-of select="CampaignList/ListNo"/>";
	
	FT.AscDes.value=FT.order.value;
	FT.ColName.value=FT.columnname.value;
	FT.TimeFrame.value=FT.timeframe.value;
	FT.Domain.value=FT.domains.value;
    FT.action = "report_list_cy.jsp";
	FT.method = "get";
	FT.submit();
}
function SetDomainName(domain)
{
  FT.listno.value="0";
  Domain=domain.value;
  FT.Domain.value=Domain;
     
   FT.AscDes.value=FT.order.value;
   FT.ColName.value=FT.columnname.value;
   FT.TimeFrame.value=FT.timeframe.value;
	
   FT.action = "report_list_cy.jsp";
   FT.method = "get";
   FT.submit();          

}
function SetTimeFrame(timeframe)
{
  FT.listno.value="0";
  TimeFrame=timeframe.value;
  FT.TimeFrame.value=TimeFrame;
   
   FT.AscDes.value=FT.order.value;
   FT.ColName.value=FT.columnname.value;
   FT.Domain.value=FT.domains.value;

   FT.action = "report_list_cy.jsp";
   FT.method = "get";
   FT.submit();
       
 }
 
function SetColumnName(columnname)
{
  FT.listno.value="0";
  ColumnName=columnname.value; 
  FT.ColName.value=ColumnName;

   FT.AscDes.value=FT.order.value;
   FT.TimeFrame.value=FT.timeframe.value;
   FT.Domain.value=FT.domains.value;

   FT.action = "report_list_cy.jsp";
   FT.method = "get";
   FT.submit();
  
  
  
}

function SetAscDes(sortby)
 {
   ShortBy=sortby.value;
   FT.listno.value="0";
   FT.AscDes.value=ShortBy;
  
   FT.ColName.value=FT.columnname.value;
   FT.TimeFrame.value=FT.timeframe.value;
   FT.Domain.value=FT.domains.value;

   FT.action = "report_list_cy.jsp";
   FT.method = "get";
   FT.submit();
}

</script>

</head>
<body onLoad="innerFramOnLoad();">

<xsl:element name="form">
	<xsl:attribute name="name">FT</xsl:attribute>
	<xsl:attribute name="id">FT</xsl:attribute>
	<xsl:attribute name="method">post</xsl:attribute>
	<xsl:attribute name="style">display:inline;</xsl:attribute>
	<xsl:attribute name="action"><xsl:value-of select="CampaignList/CampaignView"/></xsl:attribute>

	<input type="hidden" name="CompList" value=""/>
	<input type="hidden" name="UpdList" value=""/>
	<input type="hidden" name="ExpList" value=""/>
    
    <!--<input type="hidden" name="AscDes" value=""/>-->
    <xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">AscDes</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/AscDes"/></xsl:attribute>
	</xsl:element>
    
    <input type="hidden" name="ColumnName" value=""/>
    <xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">ColName</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/ColName"/></xsl:attribute>
	</xsl:element>
    
	<!--<input type="hidden" name="TimeFrame" value=""/>-->
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">TimeFrame</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/TimeFrame"/></xsl:attribute>
	</xsl:element>
	
	
	<!--<input type="hidden" name="Domain" value=""/>-->
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">Domain</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/Domain"/></xsl:attribute>
	</xsl:element>
	
	
    
    <!--<input type="hidden" name="camUpDown" value=""/> -->
    <xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">camUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/CampaignUpDown"/></xsl:attribute>
	</xsl:element>
    
    <xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">camtypeUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/CampaignTypeUpDown"/></xsl:attribute>
	</xsl:element>
    
    <xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">sizeUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/SizeUpDown"/></xsl:attribute>
	</xsl:element>
    
   <!-- <input type="hidden" name="startdUpDown" value=""/>-->
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">startdUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/StartDateUpDown"/></xsl:attribute>
	</xsl:element>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">bouncebUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/bouncebUpDown"/></xsl:attribute>
	</xsl:element>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">clicktUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/ClickThrougsUpDown"/></xsl:attribute>
	</xsl:element>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">openUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/OpenUpDown"/></xsl:attribute>
	</xsl:element>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">unsubscribUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/UnsubscribesUpDown"/></xsl:attribute>
	</xsl:element>
	
	<xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">updatedUpDown</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/UpdateDateUpDown"/></xsl:attribute>
	</xsl:element>
	
	 <xsl:element name="input">
		<xsl:attribute name="type">hidden</xsl:attribute>
		<xsl:attribute name="name">listno</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="CampaignList/ListNo"/></xsl:attribute>
	</xsl:element>
	
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
	
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<td vAlign="middle" align="left" nowrap="true">
			<a class="subactionbutton" href="#1" OnClick="PrepSubmit('1');">Compare Reports</a>&#160;&#160;&#160;
		</td>
		<td vAlign="middle" align="left" nowrap="true">
			<a class="subactionbutton" href="#1" OnClick="PrepSubmit('2');">Update Reports</a>&#160;&#160;&#160;
		</td>
		<td vAlign="middle" align="left" nowrap="true">
			<a class="subactionbutton" href="#1" OnClick="PrepSubmit('3');">Export to Excel</a>&#160;&#160;&#160;
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
<table cellspacing="0" cellpadding="0" border="0" width="95%">
	<tr>
		<td class="EmptyTab" valign="center" align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1" /></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%" colspan="2"><img height="2" src="../../images/blank.gif" width="1" /></td>
	</tr>
	<tr>
		<td class="fillTab">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p>To update a report check the ACTION check box for that report below, then click the UPDATE REPORTS button.
						<br />
						To compare a report check the ACTION check box for that report below, then click the COMPARE REPORTS button.
						<br />
						The status of the report will change to "Queued", and once it returns to "Completed", the most recent activity will be viewable.
						<br />
						The <font color="red">*</font> after the Update Status means the report may be the initial report and should be updated.
						</p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br />
<table cellspacing="0" cellpadding="0" border="0" width="95%">
	<tr>
		<td class="EmptyTab" valign="center" align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1" /></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%" colspan="2"><img height="2" src="../../images/blank.gif" width="1" /></td>
	</tr>
	<tr>
		<td class="fillTab">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td class="listHeading" align="left" valign="middle" style="padding:10px;">
                        Sort by: <select name="order" size="1" onchange="javascript:SetAscDes(this);">
                        <xsl:if test="'Descending' =CampaignList/CurrentAscDes">
							<option value="1">Ascending</option>
							<option selected="selected" value="2" >Descending</option>
					   </xsl:if>
					    <xsl:if test="'Ascending' =CampaignList/CurrentAscDes">
							<option selected="selected" value="1">Ascending</option>
							<option  value="2" >Descending</option>
					   </xsl:if>
					   <xsl:if test="'AscenDescen' =CampaignList/CurrentAscDes">
					       <option value="1">Ascending</option>
					       <option value="2">Descending</option>
					   </xsl:if>   
						   </select>&#160;&#160;&#160;&#160;
                           <select name="columnname" size="1">
                           <xsl:attribute name="onchange">javascript:SetColumnName(this);</xsl:attribute>
					       <xsl:for-each select="CampaignList/ReportDColumns/ReportColumnsDropdown">
					          <xsl:element name="option">
					              <xsl:attribute name="value"><xsl:value-of select="ColumnName"/></xsl:attribute>
					              <xsl:if test="ColumnName = /CampaignList/CurrentColumnName">
								    <xsl:attribute name="selected">SELECTED</xsl:attribute>
							     </xsl:if>
					               <xsl:value-of select="ColumnName"/>
					         </xsl:element>
					       </xsl:for-each>      
					       </select>     
					       &#160;&#160;&#160;&#160;
					   Timeframe: &#160;
                           <select name="timeframe" size="1" onchange="javascript:SetTimeFrame(this);">
					       <xsl:if test="'Last 3 days' = /CampaignList/CurrentTimeFrame">
								 <option value="1">All</option>
					             <option selected="selected" value="3">Last 3 days</option>
					       		 <option value="7">Last 7 days</option>       
					       		 <option value="14">Last 14 days</option>       
					       		 <option value="30">Last 30 days</option>       
					             <option value="90">Last 90 Days</option>       
					       		 <option value="365">Year to Date</option> 
					             <option value="0">Life to Date</option>    
						   </xsl:if>
						   <xsl:if test="'Last 7 days' = /CampaignList/CurrentTimeFrame">
								 <option value="1">All</option>
					             <option value="3">Last 3 days</option>
					       		 <option selected="selected" value="7">Last 7 days</option>       
					       		 <option value="14">Last 14 days</option>       
					       		 <option value="30">Last 30 days</option>       
					             <option value="90">Last 90 Days</option>       
					       		 <option value="365">Year to Date</option> 
					             <option value="0">Life to Date</option>    
						   </xsl:if>
						   <xsl:if test="'Last 14 days' = /CampaignList/CurrentTimeFrame">
								 <option value="1">All</option>
					             <option value="3">Last 3 days</option>
					       		 <option  value="7">Last 7 days</option>       
					       		 <option selected="selected" value="14">Last 14 days</option>       
					       		 <option value="30">Last 30 days</option>       
					             <option value="90">Last 90 Days</option>       
					       		 <option value="365">Year to Date</option> 
					             <option value="0">Life to Date</option>    
						   </xsl:if>
						   <xsl:if test="'Last 30 days' = /CampaignList/CurrentTimeFrame">
								 <option value="1">All</option>
					             <option value="3">Last 3 days</option>
					       		 <option value="7">Last 7 days</option>       
					       		 <option value="14">Last 14 days</option>       
					       		 <option selected="selected" value="30">Last 30 days</option>       
					             <option value="90">Last 90 Days</option>       
					       		 <option value="365">Year to Date</option> 
					             <option value="0">Life to Date</option>    
						   </xsl:if>
						    <xsl:if test="'Last 90 Days' = /CampaignList/CurrentTimeFrame">
								 <option value="1">All</option>
					             <option value="3">Last 3 days</option>
					       		 <option value="7">Last 7 days</option>       
					       		 <option value="14">Last 14 days</option>       
					       		 <option  value="30">Last 30 days</option>       
					             <option selected="selected" value="90">Last 90 Days</option>       
					       		 <option value="365">Year to Date</option> 
					             <option value="0">Life to Date</option>    
						   </xsl:if>
						   <xsl:if test="'Year to Date' = /CampaignList/CurrentTimeFrame">
								 <option value="1">All</option>
					             <option value="3">Last 3 days</option>
					       		 <option value="7">Last 7 days</option>       
					       		 <option value="14">Last 14 days</option>       
					       		 <option value="30">Last 30 days</option>       
					             <option value="90">Last 90 Days</option>       
					       		 <option selected="selected" value="365">Year to Date</option> 
					             <option value="0">Life to Date</option>    
						   </xsl:if>
						   <xsl:if test="'Life to Date' = /CampaignList/CurrentTimeFrame">
								 <option value="1">All</option>
					             <option value="3">Last 3 days</option>
					       		 <option value="7">Last 7 days</option>       
					       		 <option value="14">Last 14 days</option>       
					       		 <option value="30">Last 30 days</option>       
					             <option value="90">Last 90 Days</option>       
					       		 <option  value="365">Year to Date</option> 
					             <option selected="selected" value="0">Life to Date</option>    
						   </xsl:if>
						   <xsl:if test="'All' = /CampaignList/CurrentTimeFrame">
					       		<option value="1">All</option>
					       		<option value="3">Last 3 days</option>
					       		<option value="7">Last 7 days</option>       
					       		<option value="14">Last 14 days</option>       
					       		<option value="30">Last 30 days</option>       
					       		<option value="90">Last 90 Days</option>       
					       		<option value="365">Year to Date</option> 
					       		<option value="0">Life to Date</option>       
					       	</xsl:if>	
					       </select>
					   &#160;&#160;&#160;&#160;
					   Across: &#160;
                           <select name="domains" size="1">
					       <xsl:attribute name="onchange">javascript:SetDomainName(this);</xsl:attribute>
					       <option value="Alls">All</option>
					       <xsl:for-each select="CampaignList/Domain/DomainListDropdown">
					         <xsl:element name="option">
					              <xsl:attribute name="value"><xsl:value-of select="DomainName"/></xsl:attribute>
					               <xsl:if test="DomainName = /CampaignList/CurrentDomainName">
								    <xsl:attribute name="selected">SELECTED</xsl:attribute>
							      </xsl:if>
					             <xsl:value-of select="DomainName"/>
					       </xsl:element> 
					       </xsl:for-each>      
					       </select>     
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
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
			Reports&#160;
			<br /><br />
			<!-- List of the Campaigns -->
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0" id="reportTable">
				<tr>
					<th>Action</th>
					<xsl:for-each select="CampaignList/ReportDColumns/ReportColumnsDropdown">
						<xsl:if test="'Campaign ID' = ColumnName">
							<xsl:if test="1 = /CampaignList/CampaignUpDown">
								<th>Campaign ID <img  src="../../images/tab_down.jpg" alt="order" style="cursor:hand" OnClick="Descending(1);"  /></th>
							</xsl:if>
							<xsl:if test="2 = /CampaignList/CampaignUpDown">
					    		<th>Campaign ID <img  src="../../images/tab_up.jpg" alt="order" style="cursor:hand" OnClick="Ascending(1);" /></th>
					    	</xsl:if>
					   </xsl:if>
					   		<xsl:if test="'Campaign Name' = ColumnName">
	                        <th>Campaign Name</th>
	                  </xsl:if>
					   <xsl:if test="'Campaign Type' = ColumnName">
					   		<xsl:if test="3 = /CampaignList/CampaignTypeUpDown">
						    	<th>Campaign Type <img  src="../../images/tab_down.jpg" alt="order" style="cursor:hand" OnClick="Descending(2);"  /></th>
					        </xsl:if>
					        <xsl:if test="4 = /CampaignList/CampaignTypeUpDown">
					        	<th>Campaign Type  <img  src="../../images/tab_up.jpg" alt="order" style="cursor:hand" OnClick="Ascending(2);" /></th>
					        </xsl:if>
				      </xsl:if>
				      <xsl:if test="'Start Date' = ColumnName">
	                        <th>Start Date</th>
	                  </xsl:if>
	                  <xsl:if test="'Subject Line' = ColumnName">
	                        <th>Subject Line</th>
	                  </xsl:if>
	                  <xsl:if test="'Content Name' = ColumnName">
	                        <th>Content Name</th>
	                  </xsl:if>
	                  <xsl:if test="'Target Group Name' = ColumnName">
	                        <th>Target Group Name</th>
	                  </xsl:if>
	                  <xsl:if test="'Campaign Code' = ColumnName">
	                        <th>Campaign Code</th>
	                  </xsl:if>
	                  <xsl:if test="'Sent' = ColumnName">      
	                      <xsl:if test="5 = /CampaignList/SizeUpDown">
						     <th>Sent <img  src="../../images/tab_down.jpg" alt="order" style="cursor:hand" OnClick="Descending(3);"  /></th>
					      </xsl:if>
					      <xsl:if test="6 = /CampaignList/SizeUpDown">
					         <th>Sent  <img  src="../../images/tab_up.jpg" alt="order" style="cursor:hand" OnClick="Ascending(3);" /></th>
					      </xsl:if>
	                 </xsl:if>
	                 <xsl:if test="'Bounce Backs' = ColumnName"> 
	                     <xsl:if test="7 = /CampaignList/BounceBacksUpDown">
							<th>Bounce Backs  <img  src="../../images/tab_down.jpg" alt="order" style="cursor:hand" OnClick="Descending(4);"  /></th>
						</xsl:if>
						<xsl:if test="8 = /CampaignList/BounceBacksUpDown">
					    	<th>Bounce Backs  <img  src="../../images/tab_up.jpg" alt="order" style="cursor:hand" OnClick="Ascending(4);" /></th>
						</xsl:if>
	                 </xsl:if>
	                 <xsl:if test="'Open' = ColumnName"> 
	               		
	               		<xsl:if test="15 = /CampaignList/OpenUpDown">
							<th>Open  <img  src="../../images/tab_down.jpg"  alt="order" style="cursor:hand" OnClick="Descending(8);"  /></th>
						 </xsl:if>
						 <xsl:if test="16 = /CampaignList/OpenUpDown">
					    	<th>Open  <img  src="../../images/tab_up.jpg" alt="order" style="cursor:hand" OnClick="Ascending(8);" /></th>
						 </xsl:if>
	                 </xsl:if>
	                 <xsl:if test="'Click Through' = ColumnName"> 
	               		 <xsl:if test="9 = /CampaignList/ClickThrougsUpDown">
							<th>Click Through  <img  src="../../images/tab_down.jpg"  alt="order" style="cursor:hand" OnClick="Descending(5);"  /></th>
						 </xsl:if>
						 <xsl:if test="10 = /CampaignList/ClickThrougsUpDown">
					    	<th>Click Through  <img  src="../../images/tab_up.jpg" alt="order" style="cursor:hand" OnClick="Ascending(5);" /></th>
						 </xsl:if>
	                 </xsl:if>
	                 <xsl:if test="'Unsubscribes' = ColumnName">  
	               		 <xsl:if test="11 = /CampaignList/UnsubscribesUpDown">
							<th>Unsubscribes  <img  src="../../images/tab_down.jpg"  alt="order" style="cursor:hand" OnClick="Descending(6);"  /></th>
						 </xsl:if>
						 <xsl:if test="12 = /CampaignList/UnsubscribesUpDown">
					    	<th>Unsubscribes  <img  src="../../images/tab_up.jpg" alt="order" style="cursor:hand" OnClick="Ascending(6);" /></th>
						 </xsl:if>
	                 </xsl:if>  
	                 <xsl:if test="'Orders' = ColumnName"> 
	                       <th>Orders</th>
	                 </xsl:if>
                     <xsl:if test="'Sales' = ColumnName"> 
                          <th>Sales</th>
	                 </xsl:if>
                </xsl:for-each>
					
					<!--<th>Update Date</th>-->
					 <xsl:if test="13 = /CampaignList/UpdateDateUpDown">
						<th>Update Date  <img  src="../../images/tab_down.jpg"   alt="order" style="cursor:hand" OnClick="Descending(7);"  /></th>
					 </xsl:if>
					 <xsl:if test="14 = /CampaignList/UpdateDateUpDown">
					    <th>Update Date  <img  src="../../images/tab_up.jpg"  alt="order" style="cursor:hand"  OnClick="Ascending(7);" /></th>
					 </xsl:if>
					 <th>Update Status</th>
				</tr>
				<tr>
					<td class="listItem_Title_Alt">
						<b>Your Benchmark for Selected Period (Avg)</b>
					</td>
					<xsl:for-each select="CampaignList/ReportDColumns/ReportColumnsDropdown">
						<xsl:if test="'Sent' = ColumnName"> 
							<xsl:element name="td">
								<xsl:attribute name="class">listItem_Data_Alt<xsl:value-of select="StyleClass"/></xsl:attribute>
								<b><xsl:value-of select="/CampaignList/CampSentCount"/>&#160;</b>
							</xsl:element>
						</xsl:if>
						<xsl:if test="'Bounce Backs' = ColumnName">
							<xsl:element name="td">
								<xsl:attribute name="class">listItem_Data_Alt<xsl:value-of select="StyleClass"/></xsl:attribute>
								<b><xsl:value-of select="/CampaignList/CampBBackCount"/>&#160;</b>
							</xsl:element>
						</xsl:if>
						<xsl:if test="'Open' = ColumnName"> 
							<xsl:element name="td">
								<xsl:attribute name="class">listItem_Data_Alt<xsl:value-of select="StyleClass"/></xsl:attribute>
								<b><xsl:value-of select="/CampaignList/CampOpenCount"/>&#160;</b>
							</xsl:element>
						</xsl:if>
						<xsl:if test="'Click Through' = ColumnName">
							<xsl:element name="td">
								<xsl:attribute name="class">listItem_Data_Alt<xsl:value-of select="StyleClass"/></xsl:attribute>
								<b><xsl:value-of select="/CampaignList/CampClicksCount"/>&#160;</b>
							</xsl:element>
						</xsl:if>
						<xsl:if test="'Click Through' != ColumnName">
							<xsl:if test="'Open' != ColumnName">
								<xsl:if test="'Bounce Backs' != ColumnName">
									<xsl:if test="'Sent' != ColumnName">
										<xsl:element name="td">
											<xsl:attribute name="class">listItem_Data_Alt<xsl:value-of select="StyleClass"/></xsl:attribute>&#160;
										</xsl:element>
									</xsl:if>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
					<xsl:element name="td">
						<xsl:attribute name="colspan">2</xsl:attribute>
						<xsl:attribute name="class">listItem_Data_Alt<xsl:value-of select="StyleClass"/></xsl:attribute>
						&#160;
					</xsl:element>
				</tr>
			    
				<xsl:for-each select="CampaignList/Campaigns/Row">
					<tr>
						<xsl:variable name="status_id" select="UpdateStatusId"/>
						
						<!-- Update -->
						<!-- Release 5.9 Update for auto report enabled -->
						<!--
						<xsl:if test="/CampaignList/UpdateAutoReportEnabled = 'true'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
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
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:attribute name="align">center</xsl:attribute>
                                                        <xsl:attribute name="align">center</xsl:attribute>
                                                         <xsl:choose>
                                                         <xsl:when test="UpdateStatusId = 10">
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/>;DoNotAllowUpdate</xsl:attribute>
                                                                    </xsl:element>
							</xsl:when>
                                                        <xsl:otherwise>
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/></xsl:attribute>
								</xsl:element>
							</xsl:otherwise>
							</xsl:choose>&#160;
						</xsl:element>
                                                </xsl:if>
                                                
						<xsl:if test="/CampaignList/UpdateAutoReportEnabled = 'false'">
                                                <xsl:element name="td">  
                                                <xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
						                        <xsl:attribute name="align">center</xsl:attribute>
                                                <xsl:choose>
                                                    <xsl:when test="UpdateStatusId = 10">
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/>;DoNotAllowUpdate</xsl:attribute>
                                                                    </xsl:element>
							</xsl:when>
		    					<xsl:when test="UpdateStatusId = 11">
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/>;DoNotAllowUpdate</xsl:attribute>
                                                                    </xsl:element>
							</xsl:when>
                                                        <xsl:otherwise>
								<xsl:element name="input">
										<xsl:attribute name="type">checkbox</xsl:attribute>
										<xsl:attribute name="name">UCheck</xsl:attribute>
										<xsl:attribute name="value"><xsl:value-of select="Id"/></xsl:attribute>
								</xsl:element>
							</xsl:otherwise>
							</xsl:choose>&#160;
                                                </xsl:element>
                                                </xsl:if>   
                          
                                                <!--  End of Action Check Box -->
                                                
                         
                         <!-- Campaign ID -->
                         <xsl:if test="/CampaignList/campaignId = 'Campaign ID'">
						 <xsl:element name="td">
							<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
							<nobr><xsl:value-of select="Id"/>&#160;</nobr>
						</xsl:element> 
						</xsl:if>
						
						<!-- Campaign Name -->
						<xsl:element name="td">
                                                
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<!-- <a href=Campaign name> -->
							<xsl:choose>
								<xsl:when test="UpdateStatusId &lt; 10">
									<xsl:value-of select="Name"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="a">
										<xsl:attribute name="href">
										<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/></xsl:attribute>
										<xsl:value-of select="Name"/>
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
							&#160;
						</xsl:element>
						
					<!-- Campaign Type-->
					   <xsl:if test="/CampaignList/campaignType = 'Campaign Type'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:if test="TypeId = 6">Standard</xsl:if>
							<xsl:if test="TypeId = 5">S2F</xsl:if>
							<xsl:if test="TypeId = 2">Automated</xsl:if>
							<xsl:if test="TypeId = 7">Web/DM/Call</xsl:if>
							&#160;
							<xsl:if test="/CampaignList/PrintEnabled = 'true'">
							<xsl:if test="MediaTypeId = 3">(Email)</xsl:if>
							<xsl:if test="MediaTypeId = 4">(Print)</xsl:if>
							&#160;
							</xsl:if>
						</xsl:element>
						</xsl:if>      
						
						<!-- Start Date -->
						<xsl:if test="/CampaignList/startDate = 'Start Date'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
							<nobr><xsl:value-of select="StartDate"/>&#160;</nobr>
						</xsl:element>
						</xsl:if>
						
						<!--Subject Line-->
						<xsl:if test="/CampaignList/subjectLine = 'Subject Line'">
						<xsl:element name="td">
                               <xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							   <xsl:choose>
								<xsl:when test="UpdateStatusId &lt; 10">
									<xsl:value-of select="SubjectLine"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="a">
										<xsl:value-of select="SubjectLine"/>
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
							&#160;
						</xsl:element>
						</xsl:if>
						
						<!--Content Name-->
						<xsl:if test="/CampaignList/contentName = 'Content Name'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="ContentName"/>&#160;
						</xsl:element>
                        </xsl:if>
                        
                          
						<!--TargetGroupName-->
						<xsl:if test="/CampaignList/targetGroupName = 'Target Group Name'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="TargetGroupName"/>&#160;
						</xsl:element>
						</xsl:if>
						
						<!--CampCode-->
						<xsl:if test="/CampaignList/campCode = 'Campaign Code'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							 <nobr>&#160;&#160;&#160;<xsl:value-of select="CampCode"/>&#160;</nobr>
						</xsl:element>
						</xsl:if>
						
						<!-- Sent (Number of recipients) -->
						<xsl:if test="/CampaignList/sent = 'Sent'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="Sent"/>&#160;
						</xsl:element>
                        </xsl:if> 
						
						<!-- Bounce Backs -->
						<xsl:if test="/CampaignList/bounceBacks = 'Bounce Backs'">
						<xsl:if test="BBackColor = 'red'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 7">N/A</xsl:if>
                            <xsl:if test="TypeId != 7">
                                <font color="red"><xsl:value-of select="BBacks"/>&#160;(<xsl:value-of select="BBackPrc"/>%)&#160;</font>
                            </xsl:if>
						</xsl:element>
						</xsl:if>
						
						<xsl:if test="BBackColor = 'none'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 7">N/A</xsl:if>
                            <xsl:if test="TypeId != 7">                              
                                <xsl:value-of select="BBacks"/>&#160;(<xsl:value-of select="BBackPrc"/>%)&#160;
                            </xsl:if>
						</xsl:element>
						</xsl:if>
						</xsl:if>

                        <!-- Open (Number of recipients) -->
                        <xsl:if test="/CampaignList/open = 'Open'">
                        <xsl:if test="OpenColor = 'red'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<font color="red"><xsl:value-of select="Open"/>&#160;(<xsl:value-of select="OpenPrc"/>%)&#160;</font>
						</xsl:element>
						</xsl:if>
						
                        <xsl:if test="OpenColor = 'none'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:value-of select="Open"/>&#160;(<xsl:value-of select="OpenPrc"/>%)&#160;
						</xsl:element>
						</xsl:if>
						</xsl:if>
                        
						<!-- Click Throughs -->
						<xsl:if test="/CampaignList/clickThrough = 'Click Through'">
						<xsl:if test="ClickColor = 'red'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 7">N/A</xsl:if>
                            <xsl:if test="TypeId != 7">                              
							    <font color="red"><xsl:value-of select="Clicks"/>&#160;(<xsl:value-of select="ClickPrc"/>%)&#160;</font>
                            </xsl:if>
                        </xsl:element>
                        </xsl:if>
                        
                        <xsl:if test="ClickColor = 'none'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 7">N/A</xsl:if>
                            <xsl:if test="TypeId != 7">                              
							    <xsl:value-of select="Clicks"/>&#160;(<xsl:value-of select="ClickPrc"/>%)&#160;
                            </xsl:if>
                        </xsl:element>
                        </xsl:if>
                        </xsl:if>
                        
						<!-- Unsubscribes -->
						<xsl:if test="/CampaignList/unsubscribes = 'Unsubscribes'">
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
                            <xsl:if test="TypeId  = 7">N/A</xsl:if>
                            <xsl:if test="TypeId != 7">                              
							    <xsl:value-of select="Unsubs"/>&#160;(<xsl:value-of select="UnsubPrc"/>%)&#160;
                            </xsl:if>
						</xsl:element>
						</xsl:if>
						
					   <xsl:if test="/CampaignList/CheckSalesAOrders = '1'">	
						<!-- Orders -->
                          <xsl:if test="/CampaignList/orders = 'Orders'">
						   <xsl:element name="td">
							<xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
							<nobr>&#160;&#160;&#160;&#160;<xsl:value-of select="Orders"/>&#160;(<xsl:value-of select="OrdersPrc"/>%)&#160;</nobr>
						  </xsl:element> 
						  </xsl:if>
						
						  <!-- Sales -->
                           <xsl:if test="/CampaignList/sales = 'Sales'">
						   <xsl:element name="td">
							  <xsl:attribute name="class">listItem_Title<xsl:value-of select="StyleClass"/></xsl:attribute>
							  <nobr>&#160;&#160;&#160;<xsl:value-of select="Sales"/>&#160;&#160;</nobr>
						  </xsl:element> 
						  </xsl:if>
						</xsl:if>
						<!-- Last Update Date -->
						 <xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<nobr><xsl:value-of select="UpdateDate"/>&#160;</nobr>
						</xsl:element>

						<!-- Update Status -->
						<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
							<xsl:if test="StartDate  != UpdateDate">
								<xsl:value-of select="UpdateStatus"/>&#160;
							</xsl:if>
                            <xsl:if test="StartDate  = UpdateDate">                              
							    <xsl:value-of select="UpdateStatus"/>&#160;<font color="red">*</font>&#160;
                            </xsl:if>
						</xsl:element>
						
						<!-- Cache -->
			<!--		<xsl:element name="td">
							<xsl:attribute name="class">listItem_Data<xsl:value-of select="StyleClass"/></xsl:attribute>
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
			</table>
		</td>
	</tr>
</table>
<br /><br />
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
