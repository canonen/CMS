<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			com.britemoon.cps.rpt.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
	response.setContentType("text/html; charset=UTF-8");
%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	CustDomains domains = new CustDomains(cust.s_cust_id);
	if (domains.size() == 0) domains = new CustDomains("0");
%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);
// release 5.9 Auto-Update Report Controls
boolean isUpdateRptEnabled = ui.getFeatureAccess(Feature.UPDATE_AUTO_REPORT);
System.out.println("isUpdateRptEnabled = " + isUpdateRptEnabled);

boolean canRecipView = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
String sRecipView = "0";
if (canRecipView) sRecipView = "1";

boolean SalesAndOrder=false;
ReportUtil    reportUtil=new ReportUtil();
SalesAndOrder= reportUtil.isMbsRevenueReportcustomer(cust.s_cust_id);

System.out.println("SalesAndOrder = " + SalesAndOrder);

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ResultSet		rs1		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list_cy.jsp");
	stmt = conn.createStatement();
    	ArrayList SelectedRDColumns= new ArrayList();
     
	String sSQL=null;
	
	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");
	
	String      ascdes      = request.getParameter("AscDes");
	String      columnname  = request.getParameter("ColName");
	String      timeframe   = request.getParameter("TimeFrame");
	String      domain      = request.getParameter("Domain");
	
	String      cUpDown     = request.getParameter("camUpDown");
	String      ctUpDown    = request.getParameter("camtypeUpDown");
	String      sUpDown     = request.getParameter("sizeUpDown");
	String      bUpDown     = request.getParameter("bouncebUpDown");
	String      clUpDown    = request.getParameter("clicktUpDown");
	String      oUpDown     = request.getParameter("openUpDown");
	String      unUpDown    = request.getParameter("unsubscribUpDown");
	String      upUpDown    = request.getParameter("updatedUpDown");
	String      listno      = request.getParameter("listno");

	String      curAscDesc   = ascdes;
	String		curColName	= columnname;
	    	
System.out.println("sSQL = " + sSQL);
System.out.println("curColName = " + curColName);

	int			curPage			= 1;
	int			amount			= 0;

	int			ilist = 0;	
	int         camupdown = 1;        
	int         camtypeupDown = 3;
	int	        sizeupDown = 5;
	int         bouncebupDown = 7;
	int         clicktupDown = 9; 
	int         unsubscribupDown = 11; 
	int         updatedupDown = 13;
	int         openupDown = 15;


	if ((listno != null) && !("null".equals(listno)) && !("".equals(listno)))
	{
		ilist = Integer.parseInt(listno);
	}

	if(timeframe.equals("1"))
	{
	 timeframe="0";
	}

	if ("Campaign ID".equals(columnname) || "undefined".equals(columnname))
	{
  		camupdown	= ("2".equals(ascdes)) ? 2 : 1;
	} 
	else
	{    
		camupdown	= ("2".equals(listno)) ? 2 : 1;
		if (ilist > 0) {
			curColName = (camupdown > 0) ? "Campaign ID" : curColName;
			curAscDesc = ("2".equals(listno)) ? "2" : "1";
		}
		
    }
	
	if ("Campaign Type".equals(columnname))
	{
  		camtypeupDown	= ("2".equals(ascdes)) ? 4 : 3;
	} 
	else if (ilist > 2)
	{
		camtypeupDown	= ("4".equals(listno)) ? 4 : 3;
		curColName = (camtypeupDown > 2) ? "Campaign Type" : curColName;
		curAscDesc = ("4".equals(listno)) ? "2" : "1";
	}

	if("Sent".equals(columnname))
	{
		sizeupDown	= ("2".equals(ascdes)) ? 6 : 5;
	}
    else
	{
		sizeupDown	= ("6".equals(listno)) ? 6 : 5;
		 if (ilist > 4) {
		 	curColName = (sizeupDown > 4) ? "Sent" : curColName;
			curAscDesc = ("6".equals(listno)) ? "2" : "1";
		}
	}
	
	if("Bounce Backs".equals(columnname))
	{
		bouncebupDown	= ("2".equals(ascdes)) ? 8 : 7;
 	}
	else
	{
		bouncebupDown	= ("8".equals(listno)) ? 8 : 7;
		if (ilist > 6) {
			curColName = (bouncebupDown > 6) ? "Bounce Backs" : curColName;
			curAscDesc = ("8".equals(listno)) ? "2" : "1";
		}
    }	

	if("Click Through".equals(columnname))
	{
		clicktupDown 	= ("2".equals(ascdes)) ? 10 : 9;
	}
	else
	{
		clicktupDown 	= ("10".equals(listno)) ? 10 : 9;
		if (ilist > 8) {
			curColName = (clicktupDown > 8) ? "Click Through" : curColName;
			curAscDesc = ("10".equals(listno)) ? "2" : "1";
		}
	}


	if("Unsubscribes".equals(columnname))
	{
		unsubscribupDown 	= ("2".equals(ascdes)) ? 12 : 11;
	}
 	else
	{
		unsubscribupDown 	= ("12".equals(listno)) ? 12 : 11;
		if (ilist > 10) {
			curColName = (unsubscribupDown > 10) ? "Unsubscribes" : curColName;
			curAscDesc = ("12".equals(unUpDown)) ? "2" : "1";
		}
	}

	updatedupDown= ("14".equals(listno)) ? 14 : 13;

	if("Open".equals(columnname))
	{
		openupDown		= ("2".equals(ascdes)) ? 16 : 15;
	}
	else
	{
		openupDown = ("16".equals(listno)) ? 16 : 15;
		if (ilist > 14) {
			curColName ="Open";
			curAscDesc = ("16".equals(listno)) ? "2" : "1";
		}
	}


	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

	if (samount == null) samount = ui.getSessionProperty("rept_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("rept_list_page_size", samount);
	
	String sSelectedCategoryID = request.getParameter("category_id");
	if ((sSelectedCategoryID == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryID = ui.s_category_id;

	String XSLDir = Registry.getKey("report_xsl_dir");
	String XSLFile= XSLDir + "ReportList_CY.xsl";
	
	String sXML="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	sXML+="<CampaignList>\n";
	sXML+="<StyleSheet>" + ui.s_css_filename + "</StyleSheet>\n";
	sXML+="<PageAmount>" + samount + "</PageAmount>\n";
	sXML+="<CurrentPage>" + String.valueOf(curPage) + "</CurrentPage>\n";
	sXML+="<PrevPage>" + String.valueOf(curPage - 1) + "</PrevPage>\n";
	sXML+="<NextPage>" + String.valueOf(curPage + 1) + "</NextPage>\n";
	sXML+="<RecipView>" + sRecipView + "</RecipView>\n";
	sXML+="<RecipOwner>" + user.s_recip_owner + "</RecipOwner>\n";
//	sXML+="<CampaignView>report_object.jsp</CampaignView>\n";
	sXML+="<CampaignView>report_redirect.jsp</CampaignView>\n";
	sXML+="<CampaignUpdate>report_update.jsp</CampaignUpdate>\n";
	sXML+="<PrintEnabled>" + String.valueOf(isPrintEnabled) + "</PrintEnabled>";
	sXML+="<UpdateAutoReportEnabled>" + String.valueOf(isUpdateRptEnabled) + "</UpdateAutoReportEnabled>";	
	
	sXML+="<CampaignUpDown>" + camupdown + "</CampaignUpDown>";
	sXML+="<CampaignTypeUpDown>" + camtypeupDown + "</CampaignTypeUpDown>";
	sXML+="<SizeUpDown>" + sizeupDown + "</SizeUpDown>";		
	sXML+="<BounceBacksUpDown>" + bouncebupDown + "</BounceBacksUpDown>";
	sXML+="<ClickThrougsUpDown>" +  clicktupDown + "</ClickThrougsUpDown>";
	sXML+="<OpenUpDown>" +  openupDown + "</OpenUpDown>";
	sXML+="<UnsubscribesUpDown>" +  unsubscribupDown + "</UnsubscribesUpDown>";
	sXML+="<UpdateDateUpDown>" +  updatedupDown  + "</UpdateDateUpDown>";
	sXML+="<ListNo>" + listno + "</ListNo>";
	sXML+="<AscDes>" + (((listno == null) || ("0".equals(listno)))?ascdes:curAscDesc)  + "</AscDes>";
	sXML+="<ColName>" + columnname + "</ColName>";
	sXML+="<TimeFrame>" +timeframe  + "</TimeFrame>";
	sXML+="<Domain>" +domain  + "</Domain>";
    if(SalesAndOrder)
	 sXML+="<CheckSalesAOrders>" +"1"  + "</CheckSalesAOrders>";
    
	 
	 // Display only select column
	rs = stmt.executeQuery("EXEC usp_crpt_report_settings_column_get @cust_id = "+cust.s_cust_id);
	if (rs.next()) 
	{
		if(rs.getInt(1)==1)
		{
			SelectedRDColumns.add(new String("Campaign ID"));
			sXML+="<campaignId>" + "Campaign ID" + "</campaignId>";
		}
		if(1==1)
		{
			SelectedRDColumns.add(new String("Campaign Name"));
			sXML+="<campaignName>" + "Campaign Name" + "</campaignName>";
		}
		if(rs.getInt(2)==1)
		{
			SelectedRDColumns.add(new String("Campaign Type"));
			sXML+="<campaignType>" + "Campaign Type" + "</campaignType>";
		}	
		if(rs.getInt(3)==1)
		{
			SelectedRDColumns.add(new String("Start Date"));
			sXML+="<startDate>" + "Start Date" + "</startDate>";
		}	
		if(rs.getInt(4)==1)
		{
			SelectedRDColumns.add(new String("Subject Line"));
			sXML+="<subjectLine>" + "Subject Line" + "</subjectLine>";
		}	
		if(rs.getInt(5)==1)
		{
			SelectedRDColumns.add(new String("Content Name"));
			sXML+="<contentName>" + "Content Name" + "</contentName>";
		}	
		if(rs.getInt(6)==1)
		{
			SelectedRDColumns.add(new String("Target Group Name"));
			sXML+="<targetGroupName>" + "Target Group Name" + "</targetGroupName>";
		}	
		if(rs.getInt(7)==1)
		{
			SelectedRDColumns.add(new String("Campaign Code"));
			sXML+="<campCode>" + "Campaign Code" + "</campCode>";
		}	
		if(rs.getInt(8)==1)
		{
			SelectedRDColumns.add(new String("Sent"));
			sXML+="<sent>" + "Sent" + "</sent>";
		}	
		if(rs.getInt(9)==1)
		{
			SelectedRDColumns.add(new String("Bounce Backs"));
			sXML+="<bounceBacks>" + "Bounce Backs" + "</bounceBacks>";
		}	
		if(rs.getInt(10)==1)
		{
			SelectedRDColumns.add(new String("Open"));
			sXML+="<open>" + "Open" + "</open>";
		}	
		if(rs.getInt(11)==1)
		{
			SelectedRDColumns.add(new String("Click Through"));
			sXML+="<clickThrough>" + "Click Through" + "</clickThrough>";
		}	
		if(rs.getInt(12)==1)
		{
			SelectedRDColumns.add(new String("Unsubscribes"));
			sXML+="<unsubscribes>" + "Unsubscribes" + "</unsubscribes>";
		}	
		if(rs.getInt(13)==1)
		{
			SelectedRDColumns.add(new String("Orders"));
			sXML+="<orders>" + "Orders" + "</orders>";
		}	
		if(rs.getInt(14)==1)
		{
			SelectedRDColumns.add(new String("Sales"));
			sXML+="<sales>" + "Sales" + "</sales>";
		}	
	}
	rs.close();
	sXML+="<Domain>\n";
	
	StringWriter swdomainList=new StringWriter();
	for (Enumeration e = domains.elements();e.hasMoreElements();) 
	{
	    
		CustDomain cd = (CustDomain)e.nextElement();
		swdomainList.write("<DomainListDropdown>\n");
		swdomainList.write("<DomainName>"+cd.s_domain+"</DomainName>\n");
		swdomainList.write("</DomainListDropdown>\n");
	}
	sXML+=swdomainList.toString()+"</Domain>\n";

	sXML+="<ReportDColumns>\n";
	
	StringWriter swselectColumns=new StringWriter();
	
	
	for( int i=0;i<SelectedRDColumns.size();i++)
	{
		swselectColumns.write("<ReportColumnsDropdown>\n");
		
		String AddcolumName=(String)SelectedRDColumns.get(i);
		if((AddcolumName.equals("Orders"))||(AddcolumName.equals("Sales")))
		{
		 if(SalesAndOrder)
		 {
		  swselectColumns.write("<ColumnName>"+AddcolumName+"</ColumnName>\n");
		 } 
		}
		else
		{
		  swselectColumns.write("<ColumnName>"+AddcolumName+"</ColumnName>\n");
		}
		swselectColumns.write("</ReportColumnsDropdown>\n");
	
	}
	 sXML+=swselectColumns.toString()+"</ReportDColumns>\n";
	
	if(sSelectedCategoryID!= null)
		sXML+="<CurrentCategoryID>" +sSelectedCategoryID+ "</CurrentCategoryID>\n";
	if(curColName!=null)
	    sXML+="<CurrentColumnName>" +curColName+ "</CurrentColumnName>\n";
	if(domain!=null)
	    sXML+="<CurrentDomainName>" +domain+ "</CurrentDomainName>\n";
	if(timeframe!=null)
	{   
		if(timeframe.equals("3"))
	    sXML+="<CurrentTimeFrame>" +"Last 3 days"+ "</CurrentTimeFrame>\n";   
	    else if(timeframe.equals("7"))
	    sXML+="<CurrentTimeFrame>" +"Last 7 days"+ "</CurrentTimeFrame>\n";   
	    else if(timeframe.equals("14"))
	    sXML+="<CurrentTimeFrame>" +"Last 14 days"+ "</CurrentTimeFrame>\n";   
	    else if(timeframe.equals("30"))
	    sXML+="<CurrentTimeFrame>" +"Last 30 days"+ "</CurrentTimeFrame>\n";   
	    else if(timeframe.equals("90"))
	    sXML+="<CurrentTimeFrame>" +"Last 90 Days"+ "</CurrentTimeFrame>\n"; 
		else if(timeframe.equals("365"))
		sXML+="<CurrentTimeFrame>" +"Year to Date"+ "</CurrentTimeFrame>\n";
	    else if(timeframe.equals("0"))
	    sXML+="<CurrentTimeFrame>" +"Life to Date"+ "</CurrentTimeFrame>\n";
	    else if(timeframe.equals("1"))
	    sXML+="<CurrentTimeFrame>" +"All"+ "</CurrentTimeFrame>\n";
	    else
	    sXML+="<CurrentTimeFrame>" +"All"+ "</CurrentTimeFrame>\n";
	}
	else
	{
	  sXML+="<CurrentTimeFrame>" +"All"+ "</CurrentTimeFrame>\n";
	} 
	if(curAscDesc!=null)
	{
		if(curAscDesc.equals("1"))
	    	sXML+="<CurrentAscDes>" +"Ascending"+ "</CurrentAscDes>\n";
		else if(curAscDesc.equals("2")) 
			sXML+="<CurrentAscDes>" +"Descending"+ "</CurrentAscDes>\n";
	    else if (("null".equals(curAscDesc)) || ("".equals(curAscDesc))) 
			sXML+="<CurrentAscDes>" +"AscenDescen"+ "</CurrentAscDes>\n";  
	}
	else
	{  
		sXML+="<CurrentAscDes>" +"AscenDescen"+ "</CurrentAscDes>\n";
	}
	     
	if(!canCat.bExecute)
		sXML+="<CategoryDisable>1</CategoryDisable>\n";
	if(!canCat.bRead)
		sXML+="<CategoryReadDisable>1</CategoryReadDisable>\n";

	sSQL = "SELECT category_id, category_name"
		+ " FROM ccps_category"
		+ " WHERE cust_id = "+cust.s_cust_id
		+ " ORDER BY category_name ";
	rs = stmt.executeQuery(sSQL);
	
	sXML+="<Categories>\n";
	sXML += "<Category>\r\n <CategoryID>0</CategoryID>\r\n";
	sXML += " <CategoryName>All</CategoryName>\r\n</Category>\r\n";
	String sCategoryID = null;
	String sCategoryName = null;
	
	while (rs.next())
	{
		sCategoryID = rs.getString(1);
		sCategoryName = new String(rs.getBytes(2), "UTF-8");
		sXML += "<Category>\r\n <CategoryID>" + sCategoryID + "</CategoryID>\r\n";
		sXML += " <CategoryName><![CDATA[" + sCategoryName + "]]></CategoryName>\r\n</Category>\r\n";
	}
	rs.close();
	sXML+="</Categories>\n";
	
	rs = stmt.executeQuery("EXEC usp_crpt_report_threshold_levels_get @cust_id = " + cust.s_cust_id);
	
	sXML+="<Thresholds>\n";
	float nBBackThreshold=0;
	float nOpenThreshold=0;
 	float nClickThroughThreshold=0;
	
	while (rs.next())
	{
		nBBackThreshold = rs.getFloat(1);
		nOpenThreshold = rs.getFloat(2);
		nClickThroughThreshold = rs.getFloat(3);
			
		sXML += "<BBackThresholdPercent>" + nBBackThreshold + "</BBackThresholdPercent>\n";
		sXML += "<OpenThresholdPercent>" + nOpenThreshold + "</OpenThresholdPercent>\n";
		sXML += "<ClickThresholdPercent>" + nClickThroughThreshold + "</ClickThresholdPercent>\n";
	}
	rs.close();
	sXML+="</Thresholds>\n";
	
	// ********* KU
	int iCount = 0;
	float fBBackCount = 0.0f;
	float fSentCount = 0.0f;
	float fOpenCount = 0.0f;
	float fClicksCount = 0.0f;
	float avgValue = 0.0f;
	// lw add percentValue in order to do percents of values over # sent emails.
	double percentValue = 0.0f;
	double avgSent = 0.0f;
	double avgBback = 0.0f;
	String sClassAppend = "_Alt";


	// Fields description for (already sent campaign) stored procedure: ????
	//
	// <Id>          - Campaign Id
	// <TypeId>      - Campaign Type Id
	// <StartDate>   - Date when the campaign started
	// <SubjectLine> - Campaign Name
	// <ContentName> -Content Name
	// <TargetGroupName> - Filter Name
	// <CampCode>    -
	// <Sent>        - Number of recipients for that campaign
	// <BBacks>      - Number of Bounce Backs
	// <Open>        -Are Active 
	// <BBackPrc>    - % of Bounce Backs = (<BBacks> / <Size>) * 100
	// <Clicks>      - Number of Click Throughs
	// <ClickPrc>    - % of Click Throughs = (<CThrough> / <Size>) * 100
	// <Unsubs>      - Number of unsubscribers
	// <UnsubsPrc>   - % of unsubscribers = (<Unsubscr> / <Size>) * 100
	// <UpdateDate>     - date when report last updated
	// <UpdateStatusId> - status of report update
	// <UpdateStatus>   - status of report update
	
	if(ascdes!=null)
	{   
		String		colname	= columnname;
		if(!("null".equals(ascdes)) && !("".equals(ascdes)))
		{   
	    	if(columnname.equals("Campaign Type"))
	    	{
	      		colname="TypeId";
	    	}
        	if((columnname.equals("Campaign ID"))||(columnname.equals("undefined")))
	    	{
	      		colname="Id";
	    	}
	    	if(columnname.equals("Campaign Name"))
	    	{
	      		colname="CampaignName";
	    	}
	    	
	    	if(columnname.equals("Start Date"))
	    	{
	      		colname="StartDate";
	    	}
	    	if(columnname.equals("Subject Line"))
	    	{
	      		colname="SubjectLine";
	    	}
	    	if(columnname.equals("Content Name"))
	    	{
	      		colname="ContentName";
	    	}
        	if(columnname.equals("Target Group Name"))
	    	{
	      		colname="TargetGroupName";
	    	}
	    	if(columnname.equals("Campaign Code"))
	    	{
	      		colname="CampCode";
	    	}
	    	if(columnname.equals("Bounce Backs"))
	    	{
	      		colname="BBacks";
	    	}
	    	if(columnname.equals("Open"))
	    	{
	      		colname="OpenA";
	    	}
	    	if(columnname.equals("Click Through"))
	    	{
	      		colname="Clicks";
	    	}
	    	if(columnname.equals("Unsubscribes"))
	    	{
	      		colname="Unsubs";
	    	}
	    	if(timeframe.equals("1"))
	    	{
	    	 timeframe="0";
	    	}
	     if(domain.equals("Alls")) 
         {
         	sSQL="EXEC usp_crpt_camp_new_list @cust_id="+cust.s_cust_id +
         		", @ascdes=" + Integer.parseInt(ascdes)+
         		", @columnname='" + colname +
         		"',@domainname='"+ domain +
         		"',@timeframe ="+ Integer.parseInt(timeframe);
         }		
         else
         {
           sSQL="EXEC usp_crpt_camp_new_list_domain @cust_id="+cust.s_cust_id +
         		", @ascdes=" + Integer.parseInt(ascdes)+
         		", @columnname='" + colname +
         		"',@domainname='"+ domain +
         		"',@timeframe ="+ Integer.parseInt(timeframe);
         
         }
         		
        //System.out.println(sSQL);
       }
       else
       {
         sSQL="EXEC usp_crpt_camp_new_list @cust_id="+cust.s_cust_id;
       }  
	}	
    else
    {
 	   sSQL="EXEC usp_crpt_camp_new_list @cust_id="+cust.s_cust_id;
    }
	
	if(!(listno == null))
	{
	    if(!("null".equals(listno)) && !("".equals(listno)))
		  {
		    if(!("0".equals(listno)))
		     {
		     	sSQL=null;
		     	
		     	if(timeframe.equals("1"))
	    	    {
	    	      timeframe="0";
	    	    }
	    	   
	    	    if(!("null".equals(domain)))
	    	    {
	    	      if(domain.equals("Alls")) 
	    	      	{
	   		 			sSQL="EXEC usp_crpt_camp_new_list @cust_id="+cust.s_cust_id+
	   		 			",@domainname='"+ domain +"'";
	   		      	}
	   		   	  else
	   		      	{
	   		        sSQL="EXEC usp_crpt_camp_new_list_domain @cust_id="+cust.s_cust_id+
	   		 		",@domainname='"+ domain +"'";
	   		      	}
	   		    }
	   		    else
	   		    {
	   		      sSQL="EXEC usp_crpt_camp_new_list @cust_id="+cust.s_cust_id;
	   		     
	   		    }  	
	   		     sSQL +=",@sortby=" + Integer.parseInt(listno);
	   		    
		         if(!("null".equals(timeframe)) && !("".equals(timeframe)))	  
	   		     sSQL +=",@timeframe=" + Integer.parseInt(timeframe); 
	   		     
	   		      
	   		  }
	   	  }	 	
	}

	if (sSelectedCategoryID!=null)
		sSQL +=",@category_id=" + sSelectedCategoryID;
	
   // System.out.println(sSQL);
    if (stmt.execute(sSQL))
	{
		rs=stmt.getResultSet();
		sXML+="<Campaigns>\n";	
		StringWriter swRow=new StringWriter();
		
		while (rs.next())
		{
			if (iCount % 2 != 0)
			{
				sClassAppend = "_Alt";
			}
			else
			{
				sClassAppend = "";
			}
			
			iCount++;
			
			//Page logic
			if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
		     
		    swRow.write("<Row>\n");
			swRow.write("<Id>"+rs.getString(1)+"</Id>\n");
			swRow.write("<Name><![CDATA["+new String(rs.getBytes(2), "UTF-8")+"]]></Name>\n");
			swRow.write("<TypeId>"+rs.getString(3)+"</TypeId>\n");
			swRow.write("<MediaTypeId>"+rs.getString(4)+"</MediaTypeId>\n");
			swRow.write("<StartDate>"+rs.getString(5)+"</StartDate>\n");
			swRow.write("<SubjectLine><![CDATA["+new String(rs.getBytes(6), "UTF-8")+"]]></SubjectLine>\n");
			swRow.write("<ContentName><![CDATA["+rs.getString(7)+"]]></ContentName>\n");
			swRow.write("<TargetGroupName><![CDATA["+rs.getString(8)+"]]></TargetGroupName>\n");
			
			String campcode=rs.getString(9);
			if(campcode==null)
			   swRow.write("<CampCode>"+"-"+"</CampCode>\n");
			else 
			   swRow.write("<CampCode><![CDATA["+campcode+"]]></CampCode>\n");
			
			swRow.write("<Sent>"+rs.getString(10)+"</Sent>\n");
			swRow.write("<BBacks>" +rs.getString(11)+ "</BBacks>\n");
			swRow.write("<Open>"+rs.getString(12)+"</Open>\n");
			swRow.write("<Clicks>"+rs.getString(13)+"</Clicks>\n");
			swRow.write("<Unsubs>"+rs.getString(14)+"</Unsubs>\n");
			
			String order=rs.getString(15);
			if(order==null)
			  swRow.write("<Orders>"+"-"+"</Orders>\n");
			else
			  swRow.write("<Orders>"+order+"</Orders>\n");
			
			String sales=rs.getString(16);
			if(sales==null)
			   swRow.write("<Sales>"+"-"+"</Sales>\n");
			else
			  swRow.write("<Sales>"+sales+"</Sales>\n");
			swRow.write("<UpdateDate>"+rs.getString(17)+"</UpdateDate>\n");
			swRow.write("<UpdateStatusId>"+rs.getString(18)+"</UpdateStatusId>\n");
			swRow.write("<UpdateStatus>"+rs.getString(19)+"</UpdateStatus>\n");

			String sMetricValue = rs.getString(20);
			//int nMetricValue = (int)Float.parseFloat(sMetricValue);
			int bMetricValue = (int)(Float.parseFloat(sMetricValue) * 10);
			float bdMetricValue = (float) (bMetricValue/10.0);
			swRow.write("<BBackPrc>"+sMetricValue+"</BBackPrc>\n");
			if (bdMetricValue >= nBBackThreshold)
				swRow.write("<BBackColor>"+ "red" +"</BBackColor>\n");
			else
				swRow.write("<BBackColor>"+ "none" +"</BBackColor>\n");

			sMetricValue = rs.getString(21);
			//nMetricValue = (int)Float.parseFloat(sMetricValue);
			int oMetricValue = (int)(Float.parseFloat(sMetricValue) * 10);
			float odMetricValue = (float) (oMetricValue/10.0);
			swRow.write("<OpenPrc>"+sMetricValue+"</OpenPrc>\n");
			if (odMetricValue < nOpenThreshold)
				swRow.write("<OpenColor>"+ "red" +"</OpenColor>\n");
			else
				swRow.write("<OpenColor>"+ "none" +"</OpenColor>\n");

			sMetricValue = rs.getString(22);
			//nMetricValue = (int)Float.parseFloat(sMetricValue);
			int cMetricValue = (int)(Float.parseFloat(sMetricValue) * 10);
			float cdMetricValue = (float)(cMetricValue/10.0);
			swRow.write("<ClickPrc>"+sMetricValue+"</ClickPrc>\n");
			if (cdMetricValue < nClickThroughThreshold)
				swRow.write("<ClickColor>"+ "red" +"</ClickColor>\n");
			else
				swRow.write("<ClickColor>"+ "none" +"</ClickColor>\n");

			swRow.write("<UnsubPrc>"+rs.getString(23)+"</UnsubPrc>\n");
			String orderprc=rs.getString(24);
			if(orderprc==null)
			  swRow.write("<Orders>"+"-"+"</Orders>\n");
			else
			  swRow.write("<OrdersPrc>"+orderprc+"</OrdersPrc>\n");
			swRow.write("<Cache>"+rs.getString(25)+"</Cache>\n");
			swRow.write("<StyleClass>"+sClassAppend+"</StyleClass>\n");
			swRow.write("</Row>\n");
		 }
		sXML+=swRow.toString()+"</Campaigns>\n";
	}
				
	sXML+="<CampRowCount>" + iCount + "</CampRowCount>\n";
	 if (stmt.execute(sSQL))
	{
		rs1=stmt.getResultSet();
	}
	while (rs1.next()){
		    String stMetricValue = rs1.getString(10);
		    int nMetricValue = Integer.parseInt(stMetricValue);
		    fSentCount = fSentCount + nMetricValue;
		    
		    stMetricValue = rs1.getString(11);
		    nMetricValue = Integer.parseInt(stMetricValue);
		    fBBackCount = fBBackCount + nMetricValue;
		    
		    stMetricValue = rs1 .getString(12);
		    nMetricValue = Integer.parseInt(stMetricValue);
		    fOpenCount = fOpenCount + nMetricValue;
		    
		    stMetricValue = rs1 .getString(13);
		    nMetricValue = Integer.parseInt(stMetricValue);
		    fClicksCount = fClicksCount + nMetricValue;
		 }
	rs1.close();	
	
	// lw added percentValue calculations.
	if(iCount!=0)
	avgValue = fSentCount / iCount;
	double avgValue1=Math.round(avgValue*10.0)/10.0;
	sXML+="<CampSentCount>" + avgValue1 + "</CampSentCount>\n";
	avgSent = avgValue1; 
	avgValue = 0.0f;
	percentValue = 0.0f;
	if(iCount!=0)
	avgValue = fBBackCount / iCount;
	avgValue1=Math.round(avgValue*10.0)/10.0;
	percentValue = Math.round((avgValue1/avgSent)*1000.0)/10.0;
	sXML+="<CampBBackCount>" + avgValue1 + "("+ percentValue +"%)" +"</CampBBackCount>\n";
	avgBback = avgValue1; 
	avgValue = 0.0f;
	percentValue = 0.0f;
	if(iCount!=0)
	avgValue = fOpenCount / iCount;
	avgValue1=Math.round(avgValue*10.0)/10.0;
	percentValue = Math.round((avgValue1/(avgSent-avgBback))*1000.0)/10.0;
	sXML+="<CampOpenCount>" + avgValue1 + "("+ percentValue +"%)" + "</CampOpenCount>\n";
	avgValue = 0.0f;
	percentValue = 0.0f;
	if(iCount!=0)
	avgValue = fClicksCount / iCount;	
	avgValue1=Math.round(avgValue*10.0)/10.0;
	percentValue = Math.round((avgValue1/(avgSent-avgBback))*1000.0)/10.0;
	sXML+="<CampClicksCount>" + avgValue1 + "("+ percentValue +"%)" +"</CampClicksCount>\n";
	sXML+="</CampaignList>\n";
	
	// end lw changes to add percentValue calculations.

	//System.out.println(sXML);

	File fxsl=new File(XSLFile);		
    
	TransformerFactory tfactory = TransformerFactory.newInstance();
	Templates templates = tfactory.newTemplates(new StreamSource(fxsl));
	Transformer transformer = templates.newTransformer();
	StringReader srXML = new StringReader(sXML);
	transformer.transform(new StreamSource(srXML), new StreamResult(out));

	srXML.close();
	srXML = null;
}
catch(Exception ex)
{
	ErrLog.put(this,ex,"Error: "+ex.getMessage(),out,1);
}
finally
{
	if (stmt!=null) stmt.close();
	if (conn!=null) cp.free(conn);
	out.flush();
}

%>
