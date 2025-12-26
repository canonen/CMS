<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			java.net.*, java.io.*, 
			java.sql.*, java.util.*, 
			java.util.*, java.sql.*, 
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
		
		int showAdmn1 = 1;
		int showAdmn2 = 1;
		int showAdmn3 = 1;
		int showAdmn4 = 1;
		int showAdmn5 = 1;
		int showAdmn6 = 1;
		int showAdmn7 = 1;
		
		int showHelp1 = 1;
		int showHelp2 = 1;
		int showHelp3 = 1;
		int showHelp4 = 1;
	
	//set default values for tab navigation links
		String sHome = "Revotas: Home";
		String sCamp = "Revotas: Campaigns";
		String sData = "Revotas: Database";
		String sCont = "Revotas: Content";
		String sRept = "Revotas: Reporting";
		String sAdmn = "Revotas: Administration";
		String sHelp = "Revotas: Support";
		
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
		
		boolean showSubCamps = false;
		boolean showSubCamp1 = false;
		boolean showSubCamp2 = false;
		boolean showSubCamp3 = false;
		boolean showSubCamp4 = false;

		boolean canS2F = ui.getFeatureAccess(Feature.S2F_CAMP);
		boolean canAutoCamp = ui.getFeatureAccess(Feature.AUTO_CAMP);
		boolean canWebDMCall = ui.getFeatureAccess(Feature.WEB_DM_CALL);

		if (canS2F)
		{
			showSubCamp1 = true;
			showSubCamp2 = true;
		}
		if (canAutoCamp)
		{
			showSubCamp1 = true;
			showSubCamp3 = true;
		}
		if (canWebDMCall)
		{
			showSubCamp1 = true;
			showSubCamp4 = true;
		}

		if (showSubCamp1)
		{
			showSubCamps = true;
		}
%>
<html>
<head>
<title></title>
<link rel="stylesheet" href="menu.css" TYPE="text/css">
<script language="javascript">
	
	function goToNav(tab, sec, url)
	{
		parent.location.href = "../jsp/index.jsp?tab=" + tab + "&sec=" + sec + "&url=" + url;
	}
	
</script>
<link rel="stylesheet" href="D:\Revotas\ccps\web\ui\css\style.css" TYPE="text/css"/>
</head>
<body>
<table width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td height="50" class="title" nowrap>Revotas for MS CRM</td>
		<td class="title" align="right" valign="middle" width="100%" style="padding:0px;">
			<IFRAME src="../jsp/cust/session_info.jsp" width="400" height="50" scrolling="no" frameborder="0">
			[Your user agent does not support frames or is currently configured
			not to display frames. However, you may visit
			<A href="foo.html">the related document.</A>]
			</IFRAME>
		</td>
	</tr>
	<tr>
		<td colspan="2" height="25" id="tdMenuContainer">
			<table cellspacing=0 cellpadding=0 class="mnubar" id="mnuBar1">
				<tr>
					<td width=9><img src="/cms/ui/mscrm/images/mnu_vSpacer.gif" hspace=3></td>
					<td class="icMenu" noWrap>
						<span tabIndex=0 class="menu" accessKey="M" menu="mnuhome"<%= (showHome == 0)?" style=\"display:none;\"":"" %>>
							Ho<u>m</u>e
							<table id="mnuhome" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<col width="20" align="right">
								<tr action="goToNav('Home', '1', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Welcome</td>
								</tr>
								<tr class="mnuSpacer"<%= (showHome2 == 0 || showHome3 == 0)?" style=\"display:none;\"":"" %>>
									<td><br></td>
									<td colspan="2"><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Home', '2', '');"<%= (showHome2 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">User Notes</td>
								</tr>
								<tr action="goToNav('Home', '3', '');"<%= (showHome3 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Admin Notes</td>
								</tr>
								<tr class="mnuSpacer">
									<td><br></td>
									<td colspan="2"><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Home', '4', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Approval</td>
								</tr>
							</table>
						</span>
						<span tabIndex=0 class="menu" accessKey="C" menu="mnucamp"<%= (showCamp == 0)?" style=\"display:none;\"":"" %>>
							<u>C</u>ampaigns
							<table id="mnucamp" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<col width="20" align="right">
								<% if (showSubCamps) { %>
								<tr menu="subcamp"<%= (showCamp1 == 0)?" style=\"display:none;\"":"" %>>
									<td><br></td>
									<td noWrap>My Campaigns</td>
									<td><img src="/cms/ui/mscrm/images/mnu_rArrow.gif" align="top"></td>
								</tr>
								<% } else { %>
								<tr action="goToNav('Camp', '1', '');"<%= (showCamp1 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">My Campaigns</td>
								</tr>
								<% } %>
								<tr class="mnuSpacer"<%= (showCamp1 == 0)?" style=\"display:none;\"":"" %>>
									<td><br></td>
									<td colspan="2"><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Camp', '2', '');"<%= (showCamp2 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Testing Lists</td>
								</tr>
								<tr action="goToNav('Camp', '3', '');"<%= (showCamp3 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Exclusion Lists</td>
								</tr>
								<tr action="goToNav('Camp', '4', '');"<%= (showCamp4 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Notification Lists</td>
								</tr>
								<tr class="mnuSpacer"<%= (showCamp5 == 0)?" style=\"display:none;\"":"" %>>
									<td><br></td>
									<td colspan="2"><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Camp', '5', '');"<%= (showCamp5 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Quick Campaign</td>
								</tr>
							</table>
							<table id="subcamp" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<tr action="goToNav('Camp', '1', '<%= URLEncoder.encode("camp/camp_list.jsp?type_id=2","UTF-8") %>');"<%= (!showSubCamp1)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Standard</td>
								</tr>
								<tr action="goToNav('Camp', '1', '<%= URLEncoder.encode("camp/camp_list.jsp?type_id=3","UTF-8") %>');"<%= (!showSubCamp2)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Send To Friend</td>
								</tr>
								<tr action="goToNav('Camp', '1', '<%= URLEncoder.encode("camp/camp_list.jsp?type_id=4","UTF-8") %>');"<%= (!showSubCamp3)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Automated</td>
								</tr>
								<tr action="goToNav('Camp', '1', '<%= URLEncoder.encode("camp/camp_list.jsp?type_id=5","UTF-8") %>');"<%= (!showSubCamp4)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Web / DM / Call</td>
								</tr>
							</table>
						</span>
						<span tabIndex=0 class="menu" accessKey="D" menu="mnudata"<%= (showData == 0)?" style=\"display:none;\"":"" %>>
							<u>D</u>atabase
							<table id="mnudata" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<col width="20" align="right">
								<tr action="goToNav('Data', '1', '');"<%= (showData1 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Imports</td>
								</tr>
								<tr action="goToNav('Data', '2', '');"<%= (showData2 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Target Groups</td>
								</tr>
								<tr action="goToNav('Data', '3', '');"<%= (showData3 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Exports</td>
								</tr>
								<tr action="goToNav('Data', '4', '');"<%= (showData4 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Contact/Lead Search</td>
								</tr>
							</table>
						</span>
						<span tabIndex=0 class="menu" accessKey="N" menu="mnucont"<%= (showCont == 0)?" style=\"display:none;\"":"" %>>
							Co<u>n</u>tent
							<table id="mnucont" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<col width="20" align="right">
								<tr action="goToNav('Cont', '1', '');"<%= (showCont1 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">My Content</td>
								</tr>
								<tr menu="subdyn"<%= (showCont2 == 0)?" style=\"display:none;\"":"" %>>
									<td><br></td>
									<td noWrap>Dynamic Elements</td>
									<td><img src="/cms/ui/mscrm/images/mnu_rArrow.gif" align="top"></td>
								</tr>
								<tr class="mnuSpacer"<%= (showCont3 == 0)?" style=\"display:none;\"":"" %>>
									<td><br></td>
									<td colspan="2"><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Cont', '3', '');"<%= (showCont3 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Templates</td>
								</tr>
								<tr class="mnuSpacer"<%= (showCont4 == 0 && showCont5 == 0 && showCont6 == 0)?" style=\"display:none;\"":"" %>>
									<td><br></td>
									<td colspan="2"><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Cont', '4', '');"<%= (showCont4 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">External Content</td>
								</tr>
								<tr action="goToNav('Cont', '5', '');"<%= (showCont5 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Auto Link Names</td>
								</tr>
								<tr action="goToNav('Cont', '6', '');"<%= (showCont6 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Image Library</td>
								</tr>
							</table>
							<table id="subdyn" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<tr action="goToNav('Cont', '2', 'cont/cont_block_list_frame.jsp');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Content Elements</td>
								</tr>
								<tr action="goToNav('Cont', '2', 'cont/filter_list_frame.jsp');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Logic Elements</td>
								</tr>
								<tr action="goToNav('Cont', '2', 'cont/logic_block_list_frame.jsp');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Logic Blocks</td>
								</tr>
							</table>
						</span>
						<span tabIndex=0 accessKey="R" class="menu" menu="mnurept"<%= (showRept == 0)?" style=\"display:none;\"":"" %>>
							<u>R</u>eports
							<table id="mnurept" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<tr action="goToNav('Rept', '1', '');"<%= (showRept1 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap>Campaign Reports</td>
								</tr>
								<tr class="mnuSpacer"<%= (showRept2 == 0 && showRept3 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Rept', '2', '');"<%= (showRept2 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap>Super Reports</td>
								</tr>
								<tr action="goToNav('Rept', '3', '');"<%= (showRept3 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap>Global Reports</td>
								</tr>
								
								
								<tr class="mnuSpacer"<%= (showRept4 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td><hr class="mnuSpacer"></td>
								</tr>
								<tr action="goToNav('Rept', '4', '');"<%= (showRept4 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap>Report Settings</td>
								</tr>
							</table>
						</span>
						<span tabIndex=0 class="menu" accessKey="A" menu="mnuadmn"<%= (showAdmn == 0)?" style=\"display:none;\"":"" %>>
							<u>A</u>dministration
							<table id="mnuadmn" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<col width="20" align="right">
								<tr action="goToNav('Admn', '1', '');"<%= (showAdmn1 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">User Accounts</td>
								</tr>
								<tr action="goToNav('Admn', '2', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">From Addresses</td>
								</tr>
								<tr action="goToNav('Admn', '3', '');"<%= (showAdmn3 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Subscription Forms</td>
								</tr>
								<tr action="goToNav('Admn', '4', '');"<%= (showAdmn4 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Custom Fields</td>
								</tr>
								<tr action="goToNav('Admn', '5', '');"<%= (showAdmn5 == 0)?" style=\"display:none;\"":"" %>>
									<td>&nbsp;</td>
									<td noWrap colspan="2">Categories</td>
								</tr>
								<tr action="goToNav('Admn', '6', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Bounce Back Settings</td>
								</tr>
							</table>
						</span>
						<span tabIndex=0 class="menu" accessKey="H" menu="mnuhelp"<%= (showHelp == 0)?" style=\"display:none;\"":"" %>>
							<u>H</u>elp
							<table id="mnuhelp" class="mnuList" cellspacing=0 cellpadding=3>
								<col class="mnuLeft">
								<col class="mnuItm">
								<col width="20" align="right">
								<tr action="goToNav('Help', '1', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Help &amp; Support</td>
								</tr>
								<tr action="goToNav('Help', '2', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Help Document</td>
								</tr>
								<tr action="goToNav('Help', '3', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Frequently Asked Questions</td>
								</tr>
								<tr action="goToNav('Help', '4', '');">
									<td>&nbsp;</td>
									<td noWrap colspan="2">Contact Support</td>
								</tr>
							</table>
						</span>
					</td>
					<td>
						<table class="stdTable">
							<tr>
								<%
								String sTitle = "";
								if (iHome == 1) {
									if (sNavSection.equals("1")) sTitle = "Welcome";
									if (sNavSection.equals("2")) sTitle = "User Notes";
									if (sNavSection.equals("3")) sTitle = "Admin Notes";
									if (sNavSection.equals("4")) sTitle = "Workflow";
								}
								
								if (iCamp == 1) {
									if (sNavSection.equals("1")) sTitle = "My Campaigns";
									if (sNavSection.equals("2")) sTitle = "Campaigns: Testing Lists";
									if (sNavSection.equals("3")) sTitle = "Campaigns: Exclusion Lists";
									if (sNavSection.equals("4")) sTitle = "Campaigns: Notification Lists";
									if (sNavSection.equals("5")) sTitle = "Quick Campaign";
								}
								
								if (iData == 1) {
									if (sNavSection.equals("1")) sTitle = "Database: Imports";
									if (sNavSection.equals("2")) sTitle = "Database: Target Groups";
									if (sNavSection.equals("3")) sTitle = "Database: Exports";
									if (sNavSection.equals("4")) sTitle = "Database: Contact/Lead Search";
									if (sNavSection.equals("5")) sTitle = "Database: Synchronization";
								}
								
								if (iCont == 1) {
									if (sNavSection.equals("1")) sTitle = "My Content";
									if (sNavSection.equals("2")) sTitle = "Content: Dynamic Elements";
									if (sNavSection.equals("3")) sTitle = "Content: Templates";
									if (sNavSection.equals("4")) sTitle = "External Content";
									if (sNavSection.equals("5")) sTitle = "Auto Link Names";
									if (sNavSection.equals("6")) sTitle = "Image Library";
								}
								
								if (iRept == 1) {
									if (sNavSection.equals("1")) sTitle = "Campaign Reports";
									if (sNavSection.equals("2")) sTitle = "Super Reports";
									if (sNavSection.equals("3")) sTitle = "Global Reports";
									if (sNavSection.equals("4")) sTitle = "Customize Reports";
								}
								
								if (iAdmn == 1) {
									if (sNavSection.equals("1")) sTitle = "Admin: User Accounts";
									if (sNavSection.equals("2")) sTitle = "Admin: From Addresses";
									if (sNavSection.equals("3")) sTitle = "Admin: Subscription Forms";
									if (sNavSection.equals("4")) sTitle = "Admin: Custom Fields";
									if (sNavSection.equals("5")) sTitle = "Admin: Categories";
									if (sNavSection.equals("6")) sTitle = "Admin: Bounce Back Settings";
								}
								
								if (iHelp == 1) {
									if (sNavSection.equals("1")) sTitle = "Support";
									if (sNavSection.equals("2")) sTitle = "Support: Help Doc";
									if (sNavSection.equals("3")) sTitle = "Support: FAQs";
									if (sNavSection.equals("4")) sTitle = "Support: Contact";
								}
								%>
								<td class="mnuTitle mnuRight"><nobr id="mnuTitle" class="mnuTitle" style="cursor:hand;" onclick="goToNav('<%= sNavTab %>', '<%= sNavSection %>', '');" title="Return to '<%= sTitle %>'"><%= sTitle %></nobr></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<div style="border-top:1px solid #969693;border-bottom:1px solid #C2C2BF;"></div>
		</td>
	</tr>
</table>
</body>
</html>
