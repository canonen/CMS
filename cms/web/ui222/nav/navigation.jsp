<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.net.*,java.io.*,
			java.sql.*,java.util.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../jsp/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../jsp/header.jsp" %>
<%@ include file="../jsp/validator.jsp"%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
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
			bFeat = ui.getFeatureAccess(Feature.WS_CAMPAIGN);
			if (!bFeat) showCamp6 = 0;
		
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
		String sHome = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Home&sec=" + defHome + "\" target=\"_parent\">Home</a>";
		String sCamp = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Camp&sec=" + defCamp + "\" target=\"_parent\">Campaigns</a>";
		String sData = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Data&sec=" + defData + "\" target=\"_parent\">Database</a>";
		String sCont = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Cont&sec=" + defCont + "\" target=\"_parent\">Content</a>";
		String sRept = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Rept&sec=" + defRept + "\" target=\"_parent\">Reporting</a>";
		String sAdmn = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Admn&sec=" + defAdmn + "\" target=\"_parent\">Administration</a>";
		String sHelp = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Help&sec=" + defHelp + "\" target=\"_parent\">Support</a>";
	
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
<HTML>
<HEAD>
<TITLE></TITLE>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<style>

td
{
	padding:0px;
}

</style>
</HEAD>
<BODY  marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" >
<table width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td align="left" valign="top">
		<!-- Above Nav --->
			<table border="0" cellpadding="0" cellspacing="0" width="650">
				<tr>
					<td width="200"><img src="../images/logo.gif"></td>
					<td width="450" align="right" valign="bottom">
						<IFRAME src="../jsp/cust/session_info.jsp" width="400" height="50" scrolling="no" frameborder="0">
						[Your user agent does not support frames or is currently configured
						not to display frames. However, you may visit
						<A href="foo.html">the related document.</A>]
						</IFRAME>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" valign="top">
		<!----- ----->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td align="left" valign="top">
					<!-- Main Nav --->
						<table width="100%" cellpadding="0" cellspacing="0" class="navmain">
							<tr>
								<td<%= (showHome == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iHome == 1)?"on":"off" %>"><%= sHome %></td>
								<td<%= (showCamp == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iCamp == 1)?"on":"off" %>"><%= sCamp %></td>
								<td<%= (showData == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iData == 1)?"on":"off" %>"><%= sData %></td>
								<td<%= (showCont == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iCont == 1)?"on":"off" %>"><%= sCont %></td>
								<td<%= (showRept == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iRept == 1)?"on":"off" %>"><%= sRept %></td>
								<td<%= (showAdmn == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iAdmn == 1)?"on":"off" %>"><%= sAdmn %></td>
								<td<%= (showHelp == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iHelp == 1)?"on":"off" %>"><%= sHelp %></td>
								<td width="100%" class="navmainoff">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<!-- Sub Nav --->
						<% if (iHome == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="5" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=1"  target="_parent">Welcome</a></td>
								<td<%= (showHome2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=2"  target="_parent">User Notes</a></td>
								<td<%= (showHome3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=3"  target="_parent">Admin Notes</a></td>
								<td<%= (showHome4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=4"  target="_parent">Approval</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHome2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHome3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHome4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iCamp == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="6" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showCamp1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Camp&sec=1"  target="_parent">My Campaigns</a></td>
								<td<%= (showCamp2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Camp&sec=2"  target="_parent">Testing Lists</a></td>
								<td<%= (showCamp3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Camp&sec=3"  target="_parent">Exclusion Lists</a></td>
								<td<%= (showCamp4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Camp&sec=4"  target="_parent">Notification Lists</a></td>
								<td<%= (showCamp5 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("5"))?"on":"off" %>" href="../jsp/index.jsp?tab=Camp&sec=5"  target="_parent">Quick Campaign</a></td>
								<td<%= (showCamp6 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("6"))?"on":"off" %>" href="../jsp/index.jsp?tab=Camp&sec=6"  target="_parent">Web Service Campaign</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showCamp1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCamp2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCamp3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCamp4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCamp5 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("5"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCamp6 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("6"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iData == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="6" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showData1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Data&sec=1"  target="_parent">My Database</a></td>
								<td<%= (showData2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Data&sec=2"  target="_parent">Target Groups</a></td>
								<td<%= (showData3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Data&sec=3"  target="_parent">Exports</a></td>
								<td<%= (showData4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Data&sec=4"  target="_parent">Recipient Search</a></td>
								<td<%= (showData5 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("5"))?"on":"off" %>" href="../jsp/index.jsp?tab=Data&sec=5"  target="_parent">BriteConnect</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showData1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showData2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showData3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showData4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showData5 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("5"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iCont == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="7" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showCont1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cont&sec=1"  target="_parent">My Content</a></td>
								<td<%= (showCont2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cont&sec=2"  target="_parent">Dynamic Elements</a></td>
								<td<%= (showCont3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cont&sec=3"  target="_parent">Templates</a></td>
								<td<%= (showCont4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cont&sec=4"  target="_parent">External Content</a></td>
								<td<%= (showCont5 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("5"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cont&sec=5"  target="_parent">Auto Link Names</a></td>
								<td<%= (showCont6 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("6"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cont&sec=6"  target="_parent">Image Library</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showCont1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCont2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCont3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCont4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCont5 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("5"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCont6 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("6"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iRept == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="5" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showRept1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Rept&sec=1"  target="_parent">My Reports</a></td>
								<td<%= (showRept2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Rept&sec=2"  target="_parent">Super Reports</a></td>
								<td<%= (showRept3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Rept&sec=3"  target="_parent">Global Reports</a></td>
								<td<%= (showRept4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Rept&sec=4"  target="_parent">Customize Reports</a></td>
								<td<%= (showRept5 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("5"))?"on":"off" %>" href="../jsp/index.jsp?tab=Rept&sec=5"  target="_parent">Delivery Auditing</a></td>
								<td<%= (showRept6 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("6"))?"on":"off" %>" href="../jsp/index.jsp?tab=Rept&sec=6"  target="_parent">Delivery Auditing Usage</a></td>
								<td<%= (showRept7 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("7"))?"on":"off" %>" href="../jsp/index.jsp?tab=Rept&sec=7"  target="_parent">Report Filters</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showRept1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showRept2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showRept3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showRept4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showRept5 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("5"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showRept6 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("6"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showRept7 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("7"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iAdmn == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="8" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showAdmn1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=1"  target="_parent">Account Setup</a></td>
								<td<%= (showAdmn2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=2"  target="_parent">From Address</a></td>
								<td<%= (showAdmn3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=3"  target="_parent">Subscription Form</a></td>
								<td<%= (showAdmn4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=4"  target="_parent">Custom Fields</a></td>
								<td<%= (showAdmn5 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("5"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=5"  target="_parent">Categories</a></td>
								<td<%= (showAdmn6 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("6"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=6"  target="_parent">Bounce Back Settings</a></td>
								<td<%= (showAdmn7 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("7"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=7"  target="_parent">Content Fields</a></td>
								<td<%= (showAdmn8 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("8"))?"on":"off" %>" href="../jsp/index.jsp?tab=Admn&sec=8"  target="_parent">Unsubscribe Messages</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showAdmn1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showAdmn2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showAdmn3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showAdmn4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showAdmn5 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("5"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showAdmn6 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("6"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showAdmn7 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("7"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showAdmn8 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("8"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iHelp == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="5" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showHelp1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Help&sec=1"  target="_parent">Help & Support</a></td>
								<td<%= (showHelp2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Help&sec=2"  target="_parent">Help Document</a></td>
								<td<%= (showHelp3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Help&sec=3"  target="_parent">Frequently Asked Questions</a></td>
								<td<%= (showHelp4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Help&sec=4"  target="_parent">Contact Support</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showHelp1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHelp2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHelp3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHelp4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>
