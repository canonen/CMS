<%@page import="com.britemoon.*"%>
<%@page import="com.britemoon.cps.*"%>
<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

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
<html>
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
					<a href="javascript:void(null);" class="heading camps">Campaigns</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/camp/camp_list.jsp">Email</a></li>
						<li <%= (showCamp5 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/wizard/wizard_list.jsp">Quick Campaigns</a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>							
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/camp/camp_list_rss.jsp">RSS</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/camp/camp_list_sms.jsp">SMS</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/camp/camp_list_dmail.jsp">Direct Mail</a></li>
	<%
}
%>					
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
				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading database">Database</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/email_list/list_list.jsp?typeID=2&amount=999999">Testing Lists</a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>						
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/email_list/list_list.jsp?typeID=3&amount=999999">Exclusion Lists</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/email_list/list_list.jsp?typeID=4&amount=999999">Notification Lists</a></li>
						
<%
}
%>						
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/import/import_list.jsp?amount=999999">Import Lists</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/filter/filter_list.jsp?amount=999999">Segmentation</a></li>

<%
if (!STANDARD_UI && !isPrintCampaign) {
%>						
							<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/export/export_list.jsp?amount=999999">Data Export</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/edit/recip_search.jsp">Contact Search</a></li>

<%
}
%>	

					</ul>
				</li>
				
				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading contents">Contents</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/cont/cont_list.jsp?amount=999999">Content</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/ctm/index.jsp">Templates</a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>							
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/cont/logic_block_list.jsp">Dynamic</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/cont/link_renaming_list.jsp">Auto Link Names</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/image/image_list.jsp">Image Library</a></li>
	<%
}
%>
					</ul>
				</li>

				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading reports">Reports</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/report_list.jsp?amount=999999">My Reports</a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>						
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/super_camp_report_list.jsp">Super Reports</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/report_settings_edit.jsp">Customize Reports</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/cust_report_list_frame.jsp">Global Reports</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/report/filter_list.jsp">Report Filters</a></li>

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
				
				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading settings">Settings</a>
					<ul style="display:none;" class="subItems">

						<li <%= (showAdmn2 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/form/form_list.jsp?amount=999999">Subscription Form</a></li>
<%
if (!STANDARD_UI && !isPrintCampaign) {
%>
						<li <%= (showAdmn1 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/from_addresses/from_address_list.jsp?amount=999999">From Address</a></li>
						<li <%= (showAdmn3 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/cust_attrs/cust_attr_list.jsp?amount=999999">Custom Fields</a></li>
						<li <%= (showAdmn4 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/categories/category_list.jsp?amount=999999">Categories</a></li>
						<li <%= (showAdmn5 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/bbacks/bback_settings_edit.jsp">Bounceback Settings</a></li>
						<li <%= (showAdmn6 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/cont_attrs/cont_attr_list.jsp">Content Settings</a></li>
						<li <%= (showAdmn7 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/webview_msgs/webview_msg_list.jsp">Web View Messages</a></li>
						<li <%= (showAdmn8 == 0)?" style=\"display:none;\"":"" %> class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/webview_msgs/webview_msg_list.jsp">Unsub Messages</a></li>
	<%
}
%>
					</ul>
				</li>

<%
if (!STANDARD_UI && !isPrintCampaign) {
%>					
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading users">Users & Help</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/setup/users/user_list.jsp?amount=999999">Users</a></li>
					</ul>					
				</li>
				
				
				<li class="sliding-element">
					<a href="javascript:void(null);" class="heading som">Social Media</a>
					<ul style="display:none;" class="subItems">
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/som/dofilter?redirect_url=index.jsp">Home</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/som/dofilter?redirect_url=campaigns.jsp">Campaigns</a></li>
						<li class="sliding-element"><a target="detail" class="loader" href="/cms/ui/jsp/som/dofilter?redirect_url=reporting.jsp">Reporting</a></li>
						<li class="sliding-element"><a target="detail" href="/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp">Accounts</a></li>
					</ul>
				</li>
<%
}				
%>
            </ul>
        </div>
	</body>
</html>
