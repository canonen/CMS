<%@page import="com.britemoon.*"%>
<%@page import="com.britemoon.cps.*"%>
<%@page import="com.britemoon.cps.imc.*"%>
<%@page import="com.britemoon.cps.rpt.*"%>
<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>
<%@ page import="java.util.*, java.net.*, java.io.*" %>
<%@ include file="../jsp/validator.jsp"%>
<%

	//CY 08/04/2013
	//Is it the standard ui?
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	boolean isPrintCampaign = false;

	//grab query strings
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");

	//set default values for querystrings
	if ((null == sNavTab) || ("" == sNavTab))		sNavTab = "Home";
	if ((null == sNavSection) || ("" == sNavSection))	sNavSection = "1";
	
	boolean bFeat = false;
	
	//set default values for selected Tab
		int iHome = 0;
		int iCamp = 0;
		int iData = 0;
		int iCont = 0;
		int iRept = 0;
		int iAdmn = 0;
		int iHelp = 0;

		//Performance center
		int iPerf = 1;

	
	//set default values to show or hide tabs
		int showHome = 1;
		int showCamp = 1;
		int showData = 1;
		int showCont = 1;
		int showRept = 1;
		int showAdmn = 1;
		int showHelp = 1;
		
	//default sec for tabs
		String defHome = "1";
		String defCamp = "1";
		String defData = "1";
		String defCont = "1";
		String defRept = "1";
		String defAdmn = "1";
		String defHelp = "1";
	
	//set default values to show or hide sections
		int showHome1 = 1;
		int showHome2 = 1;
		int showHome3 = 1;
		int showHome4 = 1;
		
		int showCamp1 = 1;
		int showCamp2 = 1;
		int showCamp3 = 1;
		int showCamp4 = 1;
		int showCamp5 = 1;
		int showCamp6 = 1;
		
		int showData1 = 1;
		int showData2 = 1;
		int showData3 = 1;
		int showData4 = 1;
		int showData5 = 1;
		
		int showCont1 = 1;
		int showCont2 = 1;
		int showCont3 = 1;
		int showCont4 = 1;
		int showCont5 = 1;
		int showCont6 = 1;
		
		int showRept1 = 1;
		int showRept2 = 1;
		int showRept3 = 1;
		int showRept4 = 1;
		int showRept5 = 1;
		int showRept6 = 1;
		int showRept7 = 1;
		
		int showAdmn1 = 1;
		int showAdmn2 = 1;
		int showAdmn3 = 1;
		int showAdmn4 = 1;
		int showAdmn5 = 1;
		int showAdmn6 = 1;
		int showAdmn7 = 1;
		//Release 6.1: Direct control over unsubscribe messages.
		int showAdmn8 = 1;
		
		int showHelp1 = 1;
		int showHelp2 = 1;
		int showHelp3 = 1;
		int showHelp4 = 1;
			
	//check access levels per section
		AccessPermission can;
	
	//==================
	//HOME
	//==================
		can = user.getAccessPermission(ObjectType.USER_NOTES);
		
		if(!can.bRead) showHome2 = 0;
		if(!can.bRead) showHome3 = 0;
	
	//==================
	//CAMPAIGNS
	//==================
		//My Campaigns
		//--------------
			can = user.getAccessPermission(ObjectType.CAMPAIGN);
			if(!can.bRead) showCamp = 0;
			
		//Exclusion Lists
		//--------------
			bFeat = ui.getFeatureAccess(Feature.EXCLUSION_LIST);
			if (!bFeat) showCamp3 = 0;
			
		//Notification Lists
		//--------------
			bFeat = ui.getFeatureAccess(Feature.NOTIFICATION_LIST);
			if (!bFeat) showCamp4 = 0;
		
		//Quick Campaign Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.QUICK_CAMPAIGN);
			if (!bFeat) showCamp5 = 0;
			
		//Web Service Campaign Feature
		//--------------
			showCamp6 = 0;
		
	//==================
	//DATABASE
	//==================
		//My Database (Imports)
		//--------------
			can = user.getAccessPermission(ObjectType.IMPORT);
			if(!can.bRead) showData1 = 0;
			if("1".equals(defData) && showData1 == 0) defData = "2";
		
		//My Database Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.MY_DATABASE);
			if (!bFeat) showData1 = 0;
			if("1".equals(defData) && showData1 == 0) defData = "2";
		
		//Target Groups
		//--------------
			can = user.getAccessPermission(ObjectType.FILTER);
			if(!can.bRead) showData2 = 0;
			if("2".equals(defData) && showData2 == 0) defData = "3";

		//Exports
		//--------------
			can = user.getAccessPermission(ObjectType.EXPORT);
			if(!can.bRead) showData3 = 0;
			if("3".equals(defData) && showData3 == 0) defData = "4";
		
		//Export Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.EXPORTS);
			if (!bFeat) showData3 = 0;
			if("3".equals(defData) && showData3 == 0) defData = "4";
		
		//Recipient Search
		//--------------
			can = user.getAccessPermission(ObjectType.RECIPIENT);
			if(!can.bRead) showData4 = 0;
			if("4".equals(defData) && showData4 == 0) defData = "5";
		
		//Recipient Search Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.RECIPIENT_SEARCH);
			if (!bFeat) showData4 = 0;
			if("4".equals(defData) && showData4 == 0) defData = "5";
		
		//BriteConnect Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.BRITE_CONNECT);
			if (!bFeat) showData5 = 0;
		
		//Database Tab
		//--------------
			if (showData1 == 0 && showData2 == 0 && showData3 == 0 && showData4 == 0 && showData5 == 0) showData = 0;
			
	//==================
	//CONTENT
	//==================
		//My Content
		//--------------
			can = user.getAccessPermission(ObjectType.CONTENT);
			if(!can.bRead) showCont1 = 0;
		
		//My Content Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.MY_CONTENT);
			if (!bFeat) showCont1 = 0;
			if("1".equals(defCont) && showCont1 == 0) defCont = "2";
					
		//Dynamic Content Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);
			if (!bFeat) showCont2 = 0;
			if("2".equals(defCont) && showCont2 == 0) defCont = "3";
		
		//External Content Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.EXTERNAL_CONTENT);
			if (!bFeat) showCont4 = 0;
			if("4".equals(defCont) && showCont4 == 0) defCont = "5";
		
		//Auto Link Names Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.AUTO_LINK_NAMES);
			if (!bFeat) showCont5 = 0;
			if("5".equals(defCont) && showCont5 == 0) defCont = "6";
		
		//Image Library
		//--------------
			can = user.getAccessPermission(ObjectType.IMAGE);
			if(!can.bRead) showCont6 = 0;
		
		//Image Library Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.IMAGE_LIBRARY);
			if (!bFeat) showCont6 = 0;
		
		//Content Tab
		//--------------
			if (showCont1 == 0 && showCont3 == 0 && showCont6 == 0) showCont = 0;
		
	//==================
	//REPORTING
	//==================
		//My Reports
		//--------------
			can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
			if(!can.bRead) showRept = 0;
		
		//Super Reports Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.SUPER_REPORTS);
			if (!bFeat) showRept2 = 0;
		
		//Global Reports Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.GLOBAL_REPORTS);
			if (!bFeat) showRept3 = 0;
		
		//Customize Reports Feature
		//--------------
			bFeat = ui.getFeatureAccess(Feature.CUSTOMIZE_REPORTS);
			if (!bFeat) showRept4 = 0;
	

		//Customize Delivery Auditing
		//--------------
			AccessPermission canUserPvDesignOptimizer = user.getAccessPermission(ObjectType.PV_DESIGN_OPTIMIZER);
			AccessPermission canUserPvContentScorer = user.getAccessPermission(ObjectType.PV_CONTENT_SCORER);
			AccessPermission canUserPvDeliveryTracker = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);		
			bFeat = ui.getFeatureAccess(Feature.PV_LOGIN) && (canUserPvDeliveryTracker.bRead || canUserPvContentScorer.bRead || canUserPvDesignOptimizer.bRead);
			if (!bFeat) showRept5 = 0;
			//showRept5 = 1;
			
		//Delivery Auditing Usage
		//--------------
			bFeat = ((ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER) && canUserPvDeliveryTracker.bRead) || 
					 (ui.getFeatureAccess(Feature.PV_CONTENT_SCORER) && canUserPvContentScorer.bRead) || 
					 (ui.getFeatureAccess(Feature.PV_DESIGN_OPTIMIZER) && canUserPvDesignOptimizer.bRead));
			if (!bFeat) showRept6 = 0;
			//showRept6 = 1;

		//Report Filter
		//--------------
			bFeat = ui.getFeatureAccess(ObjectType.CAMPAIGN_REPORT);
			if (!bFeat) showRept7 = 0;
			//showRept7 = 1;

	//==================
	//ADMINISTRATION
	//==================
		//Account Setup (Users)
		//--------------
			can = user.getAccessPermission(ObjectType.USER);
			if(!can.bRead) showAdmn1 = 0;
			if("1".equals(defAdmn) && showAdmn1 == 0) defAdmn = "2";
		
		//Subscription Form
		//--------------
			can = user.getAccessPermission(ObjectType.FORM);
			if(!can.bRead) showAdmn3 = 0;
			if("3".equals(defAdmn) && showAdmn3 == 0) defAdmn = "4";
		
		//Custom Fields (Recipient Attributes)
		//--------------
			can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
			if(!can.bRead) showAdmn4 = 0;
			if("4".equals(defAdmn) && showAdmn4 == 0) defAdmn = "5";
		
		//Categories
		//--------------
			can = user.getAccessPermission(ObjectType.CATEGORY);
			if(!can.bRead) showAdmn5 = 0;
			if("5".equals(defAdmn) && showAdmn5 == 0) defAdmn = "6";
		
		//Unsubscribe Messages
		//--------------
			can = user.getAccessPermission(ObjectType.UNSUB_EDIT);
			if(!can.bRead) showAdmn8 = 0;
			if("8".equals(defAdmn) && showAdmn8 == 0) defAdmn = "7";
		
		//Feature Access to Unsubscribe Messages
		//--------------
			bFeat = ui.getFeatureAccess(Feature.UNSUB_EDIT);
			if (!bFeat) showAdmn8 = 0;
			
		//Administration Tab
		//--------------
			if (showAdmn1 == 0 && showAdmn3 == 0 && showAdmn4 == 0 && showAdmn5 == 0) showAdmn = 0;
		

		//PERFORMANCE CENTER
		//--------------
			bFeat = ui.getFeatureAccess(Feature.GOOD_MAIL);
			if (!bFeat) iPerf = 0;
		// out.print(bFeat); 

	//==================
	//SUPPORT
	//==================
		//Help Doc
		//--------------
			bFeat = ui.getFeatureAccess(Feature.HELP_DOC);
			if (!bFeat) showHelp2 = 0;
			
		//FAQs
		//--------------
			bFeat = ui.getFeatureAccess(Feature.FAQS);
			if (!bFeat) showHelp3 = 0;	
		
	//set default values for tab navigation links
		String sHome = "<a class=\"navmain\" href=\"../../jsp/index.jsp?tab=Home&sec=" + defHome + "\" target=\"_parent\">Home</a>";
		String sCamp = "<a class=\"navmain\" href=\"../../jsp/index.jsp?tab=Camp&sec=" + defCamp + "\" target=\"_parent\">Campaigns</a>";
		String sData = "<a class=\"navmain\" href=\"../../jsp/index.jsp?tab=Data&sec=" + defData + "\" target=\"_parent\">Database</a>";
		String sCont = "<a class=\"navmain\" href=\"../../jsp/index.jsp?tab=Cont&sec=" + defCont + "\" target=\"_parent\">Content</a>";
		String sRept = "<a class=\"navmain\" href=\"../../jsp/index.jsp?tab=Rept&sec=" + defRept + "\" target=\"_parent\">Reporting</a>";
		String sAdmn = "<a class=\"navmain\" href=\"../../jsp/index.jsp?tab=Admn&sec=" + defAdmn + "\" target=\"_parent\">Administration</a>";
		String sHelp = "<a class=\"navmain\" href=\"../../jsp/index.jsp?tab=Help&sec=" + defHelp + "\" target=\"_parent\">Support</a>";
	
	//check tab and set variables
		if (sNavTab.equals("Home"))
		{
				iHome = 1;
				sHome = "Home";
		}
		else if (sNavTab.equals("Camp"))
		{
				iCamp = 1;
				sCamp = "Campaigns";
		}
		else if (sNavTab.equals("Data"))
		{
				iData = 1;
				sData = "Database";
		}
		else if (sNavTab.equals("Cont"))
		{
				iCont = 1;
				sCont = "Content";
		}
		else if (sNavTab.equals("Rept"))
		{
				iRept = 1;
				sRept = "Reporting";
		}
		else if (sNavTab.equals("Admn"))
		{
				iAdmn = 1;
				sAdmn = "Administration";
		}
		else if (sNavTab.equals("Help"))
		{
				iHelp = 1;
				sHelp = "Support";
		}
		else
		{
				iHome = 1;
				sHome = "Home";
		}
		
		
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">

<%

	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
	service = (Service) services.get(0); 


	String nextLine;
    	URL url = null;
    	URL url_mobile = null;
    	URL url_dbgrowth = null;
    	URL url_activity = null;
	URL url_rpt_ecommerce = null;
	URL url_ecommerce = null;
    	URL url_ecommerce_month = null;
    	
	//CY 12/29/2015
	URL url_cj_demo = null;
	URL url_cj_main_dash = null;
	URL url_cj_dash = null;
	URL url_cj_lead = null;
	URL url_cj_cust = null;

	//CY 06/22/2018
	URL url_webpush_dash = null;
	URL url_webpush_campaigns = null;
	URL url_webpush_campaigns_list = null;
	URL url_webpush_segment = null;
	URL url_webpush_reports = null;
	
    	URLConnection urlConn = null;
    	InputStreamReader  inStream = null;
    	BufferedReader buff = null;
	
	String cid = cust.s_cust_id;


	try{
          url  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/cust_report_daily_activity.jsp?cust_id="+cid);
          url_mobile  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/mobile_report.jsp?cust_id="+cid);
          url_dbgrowth  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/report_db_growth.jsp?cust_id="+cid);
          url_activity  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/report_activity.jsp?cust_id="+cid);
          url_rpt_ecommerce  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/rpt_ecommerce.jsp?cust_id="+cid);
          url_ecommerce  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/ecommerce_report.jsp?cust_id="+cid);
          url_ecommerce_month  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/report_ecommerce_month.jsp?cust_id="+cid);
          
          //CY 12/29/2015
          url_cj_demo  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/cl_demo.jsp?cust_id="+cid);
          url_cj_main_dash  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/cl_main_dash.jsp?cust_id="+cid);
          url_cj_dash  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/cl_dash.jsp?cust_id="+cid);
          url_cj_lead  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/cl_lead.jsp?cust_id="+cid);
          url_cj_cust  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/rpt/cl_customer.jsp?cust_id="+cid);
  
	    //CY 06/22/2018
	    url_webpush_dash  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/webpush/dashboard.jsp?cust_id="+cid);
	    url_webpush_campaigns  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/webpush/create_notification.jsp?cust_id="+cid);
	    url_webpush_campaigns_list  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/webpush/campaign_list.jsp?cust_id="+cid);
	    url_webpush_segment  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/webpush/segment_list.jsp?cust_id="+cid);
	    url_webpush_reports  = new URL("http://" + service.getURL().getHost() +"/rrcp/imc/webpush/report.jsp?cust_id="+cid);

          
          
          //url = "http://rcp2.revotas.com/rrcp/imc/home/stats.jsp?opt="+opt+"&custid="+cid;
			
	} catch(MalformedURLException e){
		System.out.println("Please check the URL:" + e.toString() );
	} catch(IOException  e1){
			System.out.println("Can't read  from the Internet: "+ e1.toString() ); 
	}
%>
	<head>
		<title>Revotas Left Navigation</title>
		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
		<link rel="stylesheet" href="../css/newstyle.css" TYPE="text/css">
		<style>
			html, body {
				background-color:#2f2f2f;
			}
</style>
	</head>
	<body>
<input type="hidden" name="locale" value="${loc}"/>	
			<script type="text/javascript">
			$(document).ready(function()
			{
				$(".heading").click(function () { 
					$(".heading").next('ul').slideUp('700');
					$(".heading").css('backgroundColor','#373737');
					
					var inst = $(this);
					
					var nextElement = inst.next('ul');

					if (nextElement.css('display') != 'none') {
					    
					    nextElement.slideUp('700');
					    
					} else {
						nextElement.slideDown('700');	
						$(this).css('backgroundColor','#00759b');
					    
					}										
				});
				
				$(".sliding-element .subItems a").click(function(){
					$(".sliding-element .subItems a").css('color','#8E8D8D');
					$(".sliding-element .subItems a").css('backgroundColor','#3E3D3D');
					$(this).css('backgroundColor','#f9f9f9');
					$(this).css('color','#333333');
				});
			});
</script>
		<div id="navigation-block">
            <ul id="sliding-navigation">				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading camps"><fmt:message key="campaigns"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/camp/camp_list.jsp?locale=${loc}">Email</a></li>
						<li <%= (showCamp5 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/wizard/wizard_list.jsp">Quick Campaigns</a></li>
					<%
						if(cust.s_cust_id.equals("181"))
						{
						%>
							<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/wizard/wizard_list.jsp">Campaign Wizard</a></li>
						<%
						}
					%>
					
					</ul>
				</li>

				<% 
				
				if(cust.s_cust_id.equals("194") ||
				 cust.s_cust_id.equals("299") ||
				 cust.s_cust_id.equals("646") ||
				 cust.s_cust_id.equals("614") ||
				  cust.s_cust_id.equals("676") ||
				 cust.s_cust_id.equals("723")
				 
				 ){ %>
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading webpush">WebPush Campaigns</a>
					<ul style="display:none;" class="subItems">
					
						<li class="sliding-element"><a target="detail" href="<%= url_webpush_dash %>">Dashboard</a></li>
						<li class="sliding-element"><a target="detail" href="<%= url_webpush_campaigns %>">Send Notifications</a></li>
						<li class="sliding-element"><a target="detail" href="<%= url_webpush_campaigns_list %>">Campaign List</a></li>
						<li class="sliding-element"><a target="detail" href="<%= url_webpush_segment %>">Segmentation</a></li>
						<li class="sliding-element"><a target="detail" href="<%= url_webpush_reports %>">Reports</a></li>
					
					</ul>
					
					
				</li>
				
					<%
					}
					%>
					
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading database"><fmt:message key="database"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/email_list/list_list.jsp?typeID=2&amount=999999&locale=${loc}"><fmt:message key="testing_lists"/></a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>						
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/email_list/list_list.jsp?typeID=3&amount=999999&locale=${loc}"><fmt:message key="exclusion_lists"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/email_list/list_list.jsp?typeID=4&amount=999999&locale=${loc}"><fmt:message key="notification_lists"/></a></li>
						
<%
}
%>						
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/import/import_list.jsp?amount=999999&locale=${loc}"><fmt:message key="import_lists"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/filter/filter_list.jsp?amount=999999&locale=${loc}"><fmt:message key="segmentation"/></a></li>

<%
if (!STANDARD_UI && !isPrintCampaign) {
%>						
							<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/export/export_list.jsp?amount=999999&locale=${loc}"><fmt:message key="data_export"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/edit/recip_search.jsp?locale=${loc}"><fmt:message key="contact_search"/></a></li>

<%
}
%>	

					</ul>
				</li>
				
				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading contents"><fmt:message key="contents"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/cont/cont_list.jsp?amount=999999&locale=${loc}"><fmt:message key="content"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/ctm/index.jsp?locale=${loc}"><fmt:message key="templates"/></a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>							
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/cont/logic_block_list.jsp?locale=${loc}"><fmt:message key="dynamic"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/cont/link_renaming_list.jsp?locale=${loc}"><fmt:message key="auto_link"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/image/image_list.jsp?locale=${loc}"><fmt:message key="image_library"/></a></li>
	<%
}
%>
					</ul>
				</li>

				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading reports"><fmt:message key="reports"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/report_list.jsp?amount=999999&locale=${loc}"><fmt:message key="my_reports"/></a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
						
							if(cust.s_cust_id.equals("171") || 
							   cust.s_cust_id.equals("214") ||
							   cust.s_cust_id.equals("435") || 
							   cust.s_cust_id.equals("376") ||
							   cust.s_cust_id.equals("158") ||
							   cust.s_cust_id.equals("316") ||
							   cust.s_cust_id.equals("342") ||
							   cust.s_cust_id.equals("423") ||
							   cust.s_cust_id.equals("486") ||
							   cust.s_cust_id.equals("458") ||
							   cust.s_cust_id.equals("459") ||							
							   cust.s_cust_id.equals("429") ||
							   cust.s_cust_id.equals("416") ||
							   cust.s_cust_id.equals("449") ||
							   cust.s_cust_id.equals("457") ||
							   cust.s_cust_id.equals("412") ||
							   cust.s_cust_id.equals("375") ||
							   cust.s_cust_id.equals("399") ||
							   cust.s_cust_id.equals("429") || 
							   cust.s_cust_id.equals("474") || 
							   cust.s_cust_id.equals("146") || 
							   cust.s_cust_id.equals("363") || 
							   cust.s_cust_id.equals("316") || 
							   cust.s_cust_id.equals("460") || 
							   cust.s_cust_id.equals("483") ||
							   cust.s_cust_id.equals("423") ||
							   cust.s_cust_id.equals("471") ||
							   cust.s_cust_id.equals("475") ||
							   cust.s_cust_id.equals("291") ||							
							   cust.s_cust_id.equals("465") ||							
							   cust.s_cust_id.equals("339") ||							
							   cust.s_cust_id.equals("427") ||							
							   cust.s_cust_id.equals("428") ||					
							   cust.s_cust_id.equals("484") ||
							   cust.s_cust_id.equals("485") ||							
							   cust.s_cust_id.equals("488") ||
							   cust.s_cust_id.equals("494") ||
							   cust.s_cust_id.equals("527") ||
							   cust.s_cust_id.equals("572") ||
							   cust.s_cust_id.equals("574") ||
							   cust.s_cust_id.equals("575") ||
							   cust.s_cust_id.equals("576") ||
							   cust.s_cust_id.equals("577") ||
							   cust.s_cust_id.equals("581") ||
							   cust.s_cust_id.equals("594") ||
							   cust.s_cust_id.equals("595") ||
							   cust.s_cust_id.equals("593")	||
							   cust.s_cust_id.equals("597")	||
							   cust.s_cust_id.equals("612")	||
							   cust.s_cust_id.equals("613")	||
							   cust.s_cust_id.equals("614")	||
							   cust.s_cust_id.equals("615")	||
							   cust.s_cust_id.equals("616")	||
							   cust.s_cust_id.equals("617")	||
							   cust.s_cust_id.equals("625")	||
							   cust.s_cust_id.equals("627")	||
							   cust.s_cust_id.equals("628")	||
							   cust.s_cust_id.equals("629")	||
							   cust.s_cust_id.equals("645")	||
							   cust.s_cust_id.equals("646") ||
							   cust.s_cust_id.equals("647") ||
							   cust.s_cust_id.equals("649") ||
							   cust.s_cust_id.equals("650") ||
							   cust.s_cust_id.equals("655") ||
							   cust.s_cust_id.equals("670") ||
							   cust.s_cust_id.equals("672") ||
							   cust.s_cust_id.equals("676") ||
							   cust.s_cust_id.equals("694") ||
							   cust.s_cust_id.equals("695") ||
							   cust.s_cust_id.equals("696") ||
							   cust.s_cust_id.equals("698") || 
							   cust.s_cust_id.equals("702") ||
							   cust.s_cust_id.equals("705") ||
							   cust.s_cust_id.equals("715") ||
							   cust.s_cust_id.equals("716") ||
							   cust.s_cust_id.equals("718") ||
							   cust.s_cust_id.equals("720") ||
							   cust.s_cust_id.equals("727")
							   
							) 
							{
							%>						
						<li class="sliding-element"><a target="detail" href="<%= url %>"><fmt:message key="schedule_advisor"/></a></li>
						<li class="sliding-element"><a target="detail" href="<%= url_mobile %>"><fmt:message key="mobile_reporting"/></a></li>
						<% } %>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/super_camp_report_list.jsp?locale=${loc}"><fmt:message key="super_reports"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/report_settings_edit.jsp?locale=${loc}"><fmt:message key="customize_reports"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/cust_report_list_frame.jsp?locale=${loc}"><fmt:message key="global_reports"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/filter_list.jsp?locale=${loc}"><fmt:message key="report_filters"/></a></li>

	<%
}
							if(cust.s_cust_id.equals("146")) 
							{
							%>
								<li class="sliding-element"><a target="detail" href="http://rcp1.revotas.com/rrcp/imc/home/game_stats.jsp?custid=146">Game Scores</a></li>
							<%
							}
%>

					</ul>
				</li>
				
<%
	if (!STANDARD_UI && !isPrintCampaign) {
					
		if(
			cust.s_cust_id.equals("194") ||
			cust.s_cust_id.equals("460") ||
			cust.s_cust_id.equals("497") ||
			cust.s_cust_id.equals("523") ||
			cust.s_cust_id.equals("594") ||
			cust.s_cust_id.equals("577") ||
			cust.s_cust_id.equals("617")
			
		){
%>
							
			<li class="sliding-element">
				<a href="javascript:void(null);" class="heading customer_journey">Customer Journey</a>
				<ul style="display:none;" class="subItems">
				<li class="sliding-element"><a target="detail" href="<%= url_cj_main_dash %>">Dashboard</a></li>
				<li class="sliding-element"><a target="detail" href="<%= url_cj_demo %>">Demographic Data</a></li>				
				<li class="sliding-element"><a target="detail" href="<%= url_cj_dash %>">Lifecycle Time</a></li>
				<li class="sliding-element"><a target="detail" href="<%= url_cj_lead %>">Lead</a></li>		
				<li class="sliding-element"><a target="detail" href="<%= url_cj_cust %>">Customer</a></li>
				
				<%
				
				if(cust.s_cust_id.equals("594")){
				%>
				
				<li class="sliding-element"><a target="detail" href="http://rcp2.revotas.com/rrcp/imc/rpt/rpt_store.jsp?cust_id=594">Store</a></li>
				<li class="sliding-element"><a target="detail" href="http://rcp2.revotas.com/rrcp/imc/rpt/rpt_store_month.jsp?cust_id=594">Store by Time</a></li>
				<%
				}
				%>

				<%
				
				if(cust.s_cust_id.equals("194")){
				%>
				
				<li class="sliding-element"><a target="detail" href="http://rcp2.revotas.com/rrcp/imc/rpt/rpt_store.jsp?cust_id=594">Store</a></li>
				<li class="sliding-element"><a target="detail" href="http://rcp2.revotas.com/rrcp/imc/rpt/rpt_store_month.jsp?cust_id=594">Store by Time</a></li>
				<%
				}
				%>
				
				</ul>
			</li>
	
<%		}
	}
			
	if (!STANDARD_UI && !isPrintCampaign) {
					
		if(
			cust.s_cust_id.equals("146") ||
			cust.s_cust_id.equals("194") ||
			cust.s_cust_id.equals("214") ||
			cust.s_cust_id.equals("287") ||
			cust.s_cust_id.equals("299") ||			
			cust.s_cust_id.equals("316") ||
			cust.s_cust_id.equals("342") ||
			cust.s_cust_id.equals("366") ||
			cust.s_cust_id.equals("375") ||
			cust.s_cust_id.equals("399") ||
			cust.s_cust_id.equals("416") ||
			cust.s_cust_id.equals("420") ||
			cust.s_cust_id.equals("429") ||
			cust.s_cust_id.equals("449") ||
			cust.s_cust_id.equals("457") ||
			cust.s_cust_id.equals("460") ||
			cust.s_cust_id.equals("464") ||
			cust.s_cust_id.equals("475") ||
			cust.s_cust_id.equals("483") ||
			cust.s_cust_id.equals("484") ||
			cust.s_cust_id.equals("485") ||			
			cust.s_cust_id.equals("488") ||
			cust.s_cust_id.equals("490") ||
			cust.s_cust_id.equals("494") ||
			cust.s_cust_id.equals("496") ||
			cust.s_cust_id.equals("497") ||
			cust.s_cust_id.equals("523") ||
			cust.s_cust_id.equals("524") ||
			cust.s_cust_id.equals("525") ||
			cust.s_cust_id.equals("526") ||
			cust.s_cust_id.equals("527") ||
			cust.s_cust_id.equals("537") ||
			cust.s_cust_id.equals("538") ||
			cust.s_cust_id.equals("539") ||
			cust.s_cust_id.equals("540") ||
			cust.s_cust_id.equals("542") ||
			cust.s_cust_id.equals("563") ||
			cust.s_cust_id.equals("564") ||
			cust.s_cust_id.equals("565") ||
			cust.s_cust_id.equals("566") ||
			cust.s_cust_id.equals("567") ||
			cust.s_cust_id.equals("568") ||
			cust.s_cust_id.equals("569") ||
			cust.s_cust_id.equals("570") ||
			cust.s_cust_id.equals("571") ||
			cust.s_cust_id.equals("572") ||
			cust.s_cust_id.equals("574") ||
			cust.s_cust_id.equals("575") ||
			cust.s_cust_id.equals("576") ||
			cust.s_cust_id.equals("577") ||
			cust.s_cust_id.equals("581") ||
			cust.s_cust_id.equals("594") ||
			cust.s_cust_id.equals("595") ||
			cust.s_cust_id.equals("597") ||
			cust.s_cust_id.equals("593") ||
			cust.s_cust_id.equals("609") ||
			cust.s_cust_id.equals("612") ||
			cust.s_cust_id.equals("613") ||
			cust.s_cust_id.equals("614") ||
			cust.s_cust_id.equals("615") ||
			cust.s_cust_id.equals("616") ||
			cust.s_cust_id.equals("617") ||
			cust.s_cust_id.equals("625") ||
			cust.s_cust_id.equals("627") ||
			cust.s_cust_id.equals("628") ||
			cust.s_cust_id.equals("629") ||
			cust.s_cust_id.equals("645") ||
			cust.s_cust_id.equals("646") ||
			cust.s_cust_id.equals("647") ||
			cust.s_cust_id.equals("649") ||
			cust.s_cust_id.equals("650") ||
			cust.s_cust_id.equals("651") ||
			cust.s_cust_id.equals("655") ||
			cust.s_cust_id.equals("670") ||
			cust.s_cust_id.equals("671") ||
			cust.s_cust_id.equals("672") ||
			cust.s_cust_id.equals("673") ||
			cust.s_cust_id.equals("676") ||
			cust.s_cust_id.equals("694") ||
			cust.s_cust_id.equals("695") ||
			cust.s_cust_id.equals("696") ||
		        cust.s_cust_id.equals("698") ||
		        cust.s_cust_id.equals("699") ||
		        cust.s_cust_id.equals("705") ||
			cust.s_cust_id.equals("702") ||
			cust.s_cust_id.equals("707") ||
			cust.s_cust_id.equals("708") ||
			cust.s_cust_id.equals("715") ||
			cust.s_cust_id.equals("716") ||
			cust.s_cust_id.equals("718") ||
			cust.s_cust_id.equals("720") ||
			cust.s_cust_id.equals("727")
		){
	%>
							
	<li class="sliding-element">
		<a href="javascript:void(null);" class="heading performance">Performance HUB</a>
		<ul style="display:none;" class="subItems">
		<li class="sliding-element"><a target="detail" href="<%= url_dbgrowth %>">DB Growth</a></li>
		<li class="sliding-element"><a target="detail" href="<%= url_activity %>">List Activity</a></li>
		<li class="sliding-element"><a target="detail" href="<%= url %>">Schedule Advisor</a></li>
		<li class="sliding-element"><a target="detail" href="<%= url_mobile %>">Mobile Reporting</a></li>		
		<li class="sliding-element"><a target="detail" href="<%= url_rpt_ecommerce %>">Revotrack</a></li>
		<li class="sliding-element"><a target="detail" href="<%= url_ecommerce_month %>">Revotrack Time</a></li>	
		</ul>
	</li>
				
					<%
					}
	
	}

%>

<%
if (!STANDARD_UI && !isPrintCampaign) {
						
							if(
							cust.s_cust_id.equals("146") || 
							cust.s_cust_id.equals("299") ||
							cust.s_cust_id.equals("342") || 
							cust.s_cust_id.equals("368") ||
							cust.s_cust_id.equals("399") || 
							cust.s_cust_id.equals("485") || 
							cust.s_cust_id.equals("457") || 
							cust.s_cust_id.equals("435") || 
							cust.s_cust_id.equals("416") || 
							cust.s_cust_id.equals("449") ||
							cust.s_cust_id.equals("459") || 
							cust.s_cust_id.equals("460") ||
							cust.s_cust_id.equals("464") ||
							cust.s_cust_id.equals("475") ||
							cust.s_cust_id.equals("477") ||
							cust.s_cust_id.equals("484") ||
							cust.s_cust_id.equals("488") ||
							cust.s_cust_id.equals("489") ||
							cust.s_cust_id.equals("490") ||
							cust.s_cust_id.equals("483") ||
							cust.s_cust_id.equals("494") ||
							cust.s_cust_id.equals("496") ||
							cust.s_cust_id.equals("497") ||
							cust.s_cust_id.equals("523") ||
							cust.s_cust_id.equals("524") ||
							cust.s_cust_id.equals("525") ||
							cust.s_cust_id.equals("526") ||
							cust.s_cust_id.equals("527") ||
							cust.s_cust_id.equals("538") ||
							cust.s_cust_id.equals("539") ||
							cust.s_cust_id.equals("542") ||
							cust.s_cust_id.equals("563") ||
							cust.s_cust_id.equals("565") ||
							cust.s_cust_id.equals("566") ||
							cust.s_cust_id.equals("567") ||
							cust.s_cust_id.equals("568") ||
							cust.s_cust_id.equals("572") ||
							cust.s_cust_id.equals("574") ||
							cust.s_cust_id.equals("575") ||
							cust.s_cust_id.equals("576") ||
							cust.s_cust_id.equals("577") ||
							cust.s_cust_id.equals("581") ||
							cust.s_cust_id.equals("594") ||
							cust.s_cust_id.equals("595") ||
							cust.s_cust_id.equals("597") ||
							cust.s_cust_id.equals("593") ||
							cust.s_cust_id.equals("613") ||
							cust.s_cust_id.equals("614") ||
							cust.s_cust_id.equals("615") ||
							cust.s_cust_id.equals("617") ||
							cust.s_cust_id.equals("627") ||
							cust.s_cust_id.equals("628") ||
							cust.s_cust_id.equals("629") ||
							cust.s_cust_id.equals("637") ||
							cust.s_cust_id.equals("648") ||
							cust.s_cust_id.equals("645") ||
							cust.s_cust_id.equals("646") ||
							cust.s_cust_id.equals("647") ||
							cust.s_cust_id.equals("649") ||
							cust.s_cust_id.equals("650") ||
							cust.s_cust_id.equals("653") ||
							cust.s_cust_id.equals("654") ||
							cust.s_cust_id.equals("655") ||
							cust.s_cust_id.equals("667") ||
							cust.s_cust_id.equals("670") ||
							cust.s_cust_id.equals("672") ||
							cust.s_cust_id.equals("673") ||
							cust.s_cust_id.equals("694") ||
							cust.s_cust_id.equals("695") ||
							cust.s_cust_id.equals("696") ||
							cust.s_cust_id.equals("676") ||
							cust.s_cust_id.equals("698") ||
							cust.s_cust_id.equals("701") ||
							cust.s_cust_id.equals("705") ||
							cust.s_cust_id.equals("707") ||
							cust.s_cust_id.equals("708") ||
							cust.s_cust_id.equals("709") ||
							cust.s_cust_id.equals("713") ||
							cust.s_cust_id.equals("715") ||
							cust.s_cust_id.equals("716") ||
							cust.s_cust_id.equals("718") ||
							cust.s_cust_id.equals("724") ||
							cust.s_cust_id.equals("725") ||
							cust.s_cust_id.equals("720") ||
							cust.s_cust_id.equals("721") ||
							cust.s_cust_id.equals("727")
							
						
							
						
							
							) 
							{
							%>						

				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading ecommerce"><fmt:message key="ecommerce"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="<%= url_rpt_ecommerce %>">	Revotrack</a></li>
						<li class="sliding-element"><a target="detail" href="<%= url_ecommerce_month %>">Revotrack Time</a></li>
				<%
				
				if(
				cust.s_cust_id.equals("526") ||
				cust.s_cust_id.equals("613") ||
				cust.s_cust_id.equals("673") ||
				cust.s_cust_id.equals("629") ||
				cust.s_cust_id.equals("670")
				){
				%>
				<li class="sliding-element"><a target="detail" href="http://cms.revotas.com/cms/ui/jsp/report/report_revotrack.jsp">Revotrack Full</a></li>
				<%
				}
				%>
				
					</ul>
				</li>
				<%
				}
}
%>

<!------HYBRID---->
<%
if (STANDARD_UI && !isPrintCampaign) {
						
							if(
							cust.s_cust_id.equals("368") ||
							cust.s_cust_id.equals("637") ||
							cust.s_cust_id.equals("653") ||
							cust.s_cust_id.equals("654") ||
							cust.s_cust_id.equals("667") ||
							cust.s_cust_id.equals("701") ||
							cust.s_cust_id.equals("709") ||
							cust.s_cust_id.equals("713") ||
							cust.s_cust_id.equals("724") ||
							cust.s_cust_id.equals("720") ||
							cust.s_cust_id.equals("725")
							)
								
							%>						

				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading ecommerce"><fmt:message key="ecommerce"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="<%= url_rpt_ecommerce %>">	Revotrack</a></li>
						<li class="sliding-element"><a target="detail" href="<%= url_ecommerce_month %>">Revotrack Time</a></li>
					</ul>
				</li>
				<%
}
%>
<!------HYBRID---->



<%
if (!STANDARD_UI && !isPrintCampaign) {
						
							if(
							cust.s_cust_id.equals("497") || 
							cust.s_cust_id.equals("523") ||
							cust.s_cust_id.equals("299") || 
							cust.s_cust_id.equals("540") || 
							cust.s_cust_id.equals("399") || 
							cust.s_cust_id.equals("593") || 
							cust.s_cust_id.equals("460") || 
							cust.s_cust_id.equals("574") || 
							cust.s_cust_id.equals("575") || 
							cust.s_cust_id.equals("576") ||
							cust.s_cust_id.equals("570") || 
							cust.s_cust_id.equals("572") ||
							cust.s_cust_id.equals("575") ||
							cust.s_cust_id.equals("576") ||
							cust.s_cust_id.equals("577") ||
							cust.s_cust_id.equals("581") ||
							cust.s_cust_id.equals("594") ||
							cust.s_cust_id.equals("595") ||
							cust.s_cust_id.equals("564") ||
							cust.s_cust_id.equals("612") ||
							cust.s_cust_id.equals("613") ||
							cust.s_cust_id.equals("614") ||
							cust.s_cust_id.equals("615") ||
							cust.s_cust_id.equals("616") ||
							cust.s_cust_id.equals("617") ||
							cust.s_cust_id.equals("625")
							
							) 
							{
							%>						

				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading camps">SMTP</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/smtp/smtp.jsp">DashBoard</a></li>
					</ul>
				</li>
				<%
				}
}
%>





				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading settings"><fmt:message key="settings"/></a>
					<ul style="display:none;" class="subItems">

						<li <%= (showAdmn2 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/form/form_list.jsp?amount=999999&locale=${loc}"><fmt:message key="subscription_form"/></a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>
						<li <%= (showAdmn1 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/from_addresses/from_address_list.jsp?amount=999999&locale=${loc}"><fmt:message key="from_address"/></a></li>
						<li <%= (showAdmn3 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/cust_attrs/cust_attr_list.jsp?amount=999999&locale=${loc}"><fmt:message key="custom_fields"/></a></li>
						<li <%= (showAdmn4 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/categories/category_list.jsp?amount=999999&locale=${loc}"><fmt:message key="categories"/></a></li>
						<li <%= (showAdmn5 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/bbacks/bback_settings_edit.jsp?locale=${loc}"><fmt:message key="bounceback_settings"/></a></li>
						<li <%= (showAdmn6 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/cont_attrs/cont_attr_list.jsp?locale=${loc}"><fmt:message key="content_settings"/></a></li>
						<li <%= (showAdmn7 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/webview_msgs/webview_msg_list.jsp?locale=${loc}"><fmt:message key="web_view"/></a></li>
						<!--<li <%= (showAdmn8 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/webview_msgs/webview_msg_list.jsp?locale=${loc}"><fmt:message key="web_view"/></a></li>-->
	<%
}
%>
					</ul>
				</li>

<%
if (!STANDARD_UI && !isPrintCampaign) {
%>					
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading users"><fmt:message key="users"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/users/user_list.jsp?amount=999999&locale=${loc}"><fmt:message key="users"/></a></li>
					</ul>					
				</li>
				
				
				<!--<li class="sliding-element">
					<a href="javascript:void(null);" class="heading som"><fmt:message key="som"/></a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/som/dofilter?redirect_url=index.jsp&locale=${loc}"><fmt:message key="social_home"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/som/dofilter?redirect_url=campaigns.jsp&locale=${loc}"><fmt:message key="social_campaigns"/></a></li>
						<li class="sliding-element"><a target="detail" class="loader" href="/cms/ui/jsp/som/dofilter?redirect_url=reporting.jsp&locale=${loc}"><fmt:message key="social_reporting"/></a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp&locale=${loc}"><fmt:message key="social_accounts"/></a></li>
					</ul>
				</li>
				-->
				
<%
}				
%>

<%
if (!STANDARD_UI && !isPrintCampaign) {
						
							if(
							cust.s_cust_id.equals("420")

							
							) 
							{
							%>						

				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading camps">Contact Support</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/hellp/help.jsp">Help</a></li>
					</ul>
				</li>
				<%
				}
}
%>



            </ul>
        </div>
</body>
</fmt:bundle>
</html>
