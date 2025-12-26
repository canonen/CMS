<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.cps.*, java.net.*, java.io.*, java.sql.*, java.util.*, java.util.*, java.sql.*, org.w3c.dom.*"
	errorPage="../jsp/error_page.jsp"

%>
<%@ include file="../jsp/header.jsp" %><%@ include file="../jsp/validator.jsp"%>

<%
	//grab query strings
		String sNavTab = request.getParameter("tab");
		String sNavSection = request.getParameter("sec");
	
	//set default values for querystrings
		if ((null == sNavTab) || ("" == sNavTab))
		{
			sNavTab = "Hoxme";
		}
		
		if ((null == sNavSection) || ("" == sNavSection))
		{
			sNavSection = "1";
		}
	
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
	
	//set default values to show or hide sections
		int showCamp1 = 1;
		int showCamp2 = 1;
		int showCamp3 = 1;
		int showCamp4 = 1;
		int showCamp5 = 1;
		
		int showData1 = 1;
		int showData2 = 1;
		int showData3 = 1;
		int showData4 = 1;
		
		int showCont1 = 1;
		int showCont2 = 1;
		int showCont3 = 1;
		
		int showAdmn1 = 1;
		int showAdmn2 = 1;
		int showAdmn3 = 1;
		int showAdmn4 = 1;
		int showAdmn5 = 1;
		int showAdmn6 = 1;
	
	//set default values for the nav styles
		String sNavHome1 = "navsuboff";
		
		String sNavCamp1 = "navsuboff";
		String sNavCamp2 = "navsuboff";
		String sNavCamp3 = "navsuboff";
		String sNavCamp4 = "navsuboff";
		String sNavCamp5 = "navsuboff";
		
		String sNavData1 = "navsuboff";
		String sNavData2 = "navsuboff";
		String sNavData3 = "navsuboff";
		String sNavData4 = "navsuboff";
		
		String sNavCont1 = "navsuboff";
		String sNavCont2 = "navsuboff";
		String sNavCont3 = "navsuboff";
		
		String sNavRept1 = "navsuboff";
		String sNavRept2 = "navsuboff";
		String sNavRept3 = "navsuboff";
		
		String sNavAdmn1 = "navsuboff";
		String sNavAdmn2 = "navsuboff";
		String sNavAdmn3 = "navsuboff";
		String sNavAdmn4 = "navsuboff";
		String sNavAdmn5 = "navsuboff";
		String sNavAdmn6 = "navsuboff";
		
		String sNavHelp1 = "navsuboff";
		String sNavHelp2 = "navsuboff";
		String sNavHelp3 = "navsuboff";
		String sNavHelp4 = "navsuboff";
		
	//Standard UI Check
		boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
		if (STANDARD_UI)
		{
			showCamp3 = 0;
			showCamp4 = 0;
			showCont2 = 0;
		}
		
	//check access levels per section
		AccessPermission can;
	
	//Campaigns -- check access levels
		can = user.getAccessPermission(ObjectType.CAMPAIGN);
		
		if(!can.bRead)
		{
			showCamp = 0;
		}
		
	//Database -- check access levels
		can = user.getAccessPermission(ObjectType.IMPORT);
		
		if(!can.bRead)
		{
			showData1 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.FILTER);
		
		if(!can.bRead)
		{
			showData2 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.EXPORT);
		
		if(!can.bRead)
		{
			showData3 = 0;
		}
		
		if (showData1 == 0 && showData2 == 0 && showData3 == 0)
		{
			showData = 0;
		}
			
	//Content -- check access levels
		can = user.getAccessPermission(ObjectType.CONTENT);
		
		if(!can.bRead)
		{
			showCont1 = 0;
			showCont2 = 0;
		}
		
		if(!can.bWrite)
		{
			showCont3 = 0;
		}
		
		if (showCont1 == 0 && showCont3 == 0)
		{
			showCont = 0;
		}
		
	//Reporting -- check access levels
		can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
		
		if(!can.bRead)
		{
			showRept = 0;
		}
	
	//Administration -- check access levels
		can = user.getAccessPermission(ObjectType.USER);
		
		if(!can.bRead)
		{
			showAdmn1 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
		
		if(!can.bRead)
		{
			showAdmn4 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.CATEGORY);
		
		if(!can.bRead)
		{
			showAdmn5 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
		
		if(!can.bRead)
		{
			showAdmn6 = 0;
		}
		
	//check tab and set variables
		if (sNavTab.equals("Home"))
		{
			//set variables
				//iHome = 1;
				iCamp = 1;
				if (sNavSection.equals("1")) sNavHome1 = "navsubon";
		}
		else if (sNavTab.equals("Camp"))
		{
			//set variables
				iCamp = 1;
				if (sNavSection.equals("1")) sNavCamp1 = "navsubon";
				if (sNavSection.equals("2")) sNavCamp2 = "navsubon";
				if (sNavSection.equals("3")) sNavCamp3 = "navsubon";
				if (sNavSection.equals("4")) sNavCamp4 = "navsubon";
				if (sNavSection.equals("5")) sNavCamp5 = "navsubon";
		}
		else if (sNavTab.equals("Data"))
		{
			//set variables
				iData = 1;
				if (sNavSection.equals("1")) sNavData1 = "navsubon";
				if (sNavSection.equals("2")) sNavData2 = "navsubon";
				if (sNavSection.equals("3")) sNavData3 = "navsubon";
				if (sNavSection.equals("4")) sNavData4 = "navsubon";
		}
		else if (sNavTab.equals("Cont"))
		{
			//set variables
				iCont = 1;
				if (sNavSection.equals("1")) sNavCont1 = "navsubon";
				if (sNavSection.equals("2")) sNavCont2 = "navsubon";
				if (sNavSection.equals("3")) sNavCont3 = "navsubon";
		}
		else if (sNavTab.equals("Rept"))
		{
			//set variables
				//iRept = 1;
				iCamp = 1;
				if (sNavSection.equals("1")) sNavRept1 = "navsubon";
				if (sNavSection.equals("2")) sNavRept2 = "navsubon";
				if (sNavSection.equals("3")) sNavRept3 = "navsubon";
		}
		else if (sNavTab.equals("Admn"))
		{
			//set variables
				iAdmn = 1;
				if (sNavSection.equals("1")) sNavAdmn1 = "navsubon";
				if (sNavSection.equals("2")) sNavAdmn2 = "navsubon";
				if (sNavSection.equals("3")) sNavAdmn3 = "navsubon";
				if (sNavSection.equals("4")) sNavAdmn4 = "navsubon";
				if (sNavSection.equals("5")) sNavAdmn5 = "navsubon";
				if (sNavSection.equals("6")) sNavAdmn6 = "navsubon";
		}
		else if (sNavTab.equals("Help"))
		{
			//set variables
				iHelp = 1;
				if (sNavSection.equals("1")) sNavHelp1 = "navsubon";
				if (sNavSection.equals("2")) sNavHelp2 = "navsubon";
				if (sNavSection.equals("3")) sNavHelp3 = "navsubon";
		}
		else
		{
			//set variables
				//iHome = 1;
				iCamp = 1;
				if (sNavSection.equals("1")) sNavHome1 = "navsubon";
		}
%>
<html><head>
	<title>Console Navigation</title>
</head>

<body topmargin="5" leftmargin="5" rightmargin="0" bottommargin="0" marginwidth="0" marginheight="0">

<SCRIPT SRC="../ui/framework/resources/ftiens4.js"></SCRIPT>
<SCRIPT SRC="../ui/framework/resources/JS_functions.js"></SCRIPT>
<script>
	//foldersTree = gFld('root', '')
	foldersTree = gFld('Root', '')
<% if(showHome==1) { %>	
fldrsystem_server_settings_menu = insFld(foldersTree, gFld('Campaigns', '#', '_self'))
insDoc(fldrsystem_server_settings_menu, gLnk('bodyFrame', 'My Campaigns', 'body.jsp?title=My Campaigns&url=<%=URLEncoder.encode("../jsp/camp/camp_list.jsp")%>'))
insDoc(fldrsystem_server_settings_menu, gLnk('bodyFrame', 'Test Lists', 'body.jsp?title=Test Lists&url=<%=URLEncoder.encode("../jsp/email_list/list_list.jsp?typeID=2")%>'))
insDoc(fldrsystem_server_settings_menu, gLnk('bodyFrame', 'Exclusion Lists', 'body.jsp?title=Exclusion Lists&url=<%=URLEncoder.encode("../jsp/email_list/list_list.jsp?typeID=3")%>'))
insDoc(fldrsystem_server_settings_menu, gLnk('bodyFrame', 'Notification Lists', 'body.jsp?title=Notification Lists&url=<%=URLEncoder.encode("../jsp/email_list/list_list.jsp?typeID=4")%>'))
<% } %>
fldrsystem_components_menu = insFld(foldersTree, gFld('Database', '#', '_self'))
insDoc(fldrsystem_components_menu, gLnk('bodyFrame', 'Imports', 'body.jsp?title=Imports&url=<%=URLEncoder.encode("../jsp/import/import_list.jsp")%>'))
insDoc(fldrsystem_components_menu, gLnk('bodyFrame', 'Target Groups', 'body.jsp?title=Target Groups&url=<%=URLEncoder.encode("../jsp/filter/filter_list.jsp")%>'))
insDoc(fldrsystem_components_menu, gLnk('bodyFrame', 'Exports', 'body.jsp?title=Exports&url=<%=URLEncoder.encode("../jsp/export/export_list.jsp")%>'))
insDoc(fldrsystem_components_menu, gLnk('bodyFrame', 'Contact Search', 'body.jsp?title=Contact Search&url=<%=URLEncoder.encode("../jsp/edit/recip_edit_frame.jsp")%>'))

fldrsystem_components_menu3 = insFld(foldersTree, gFld('Content Creation', '#', '_self'))
insDoc(fldrsystem_components_menu3, gLnk('bodyFrame', 'My Content', 'body.jsp?title=My Content&url=<%=URLEncoder.encode("../jsp/cont/cont_list.jsp")%>'))
insDoc(fldrsystem_components_menu3, gLnk('bodyFrame', 'Dynamic Elements', 'body.jsp?title=Dynamic Elements&url=<%=URLEncoder.encode("../jsp/cont/dynamic_elements.jsp")%>'))

fldrsystem_components_menu4 = insFld(foldersTree, gFld('Administration', '#', '_self'))
insDoc(fldrsystem_components_menu4, gLnk('bodyFrame', 'Account Setup', 'body.jsp?title=Account Setup&url=<%=URLEncoder.encode("../jsp/setup/users/user_list.jsp")%>'))
insDoc(fldrsystem_components_menu4, gLnk('bodyFrame', 'From Address', 'body.jsp?title=From Address&url=<%=URLEncoder.encode("../jsp/setup/from_addresses/from_address_list.jsp")%>'))
insDoc(fldrsystem_components_menu4, gLnk('bodyFrame', 'Subscription Form', 'body.jsp?title=Subscription Form&url=<%=URLEncoder.encode("../jsp/form/form_list.jsp")%>'))
insDoc(fldrsystem_components_menu4, gLnk('bodyFrame', 'Custom Fields', 'body.jsp?title=Custom Fields&url=<%=URLEncoder.encode("../jsp/setup/cust_attrs/cust_attr_list.jsp")%>'))
insDoc(fldrsystem_components_menu4, gLnk('bodyFrame', 'Categories', 'body.jsp?title=Categories&url=<%=URLEncoder.encode("../jsp/setup/categories/category_list.jsp")%>'))

fldrsystem_components_menu5 = insFld(foldersTree, gFld('Report', '#', '_self'))
insDoc(fldrsystem_components_menu5, gLnk('bodyFrame', 'My Reports', 'body.jsp?title=My Reports&url=<%=URLEncoder.encode("../jsp/report/report_list.jsp")%>'))
insDoc(fldrsystem_components_menu5, gLnk('bodyFrame', 'Super Reports', 'body.jsp?title=Super Reports&url=<%=URLEncoder.encode("../jsp/report/super_camp_report_list.jsp")%>'))
insDoc(fldrsystem_components_menu5, gLnk('bodyFrame', 'Customize Reports', 'body.jsp?title=Customize Reports&url=<%=URLEncoder.encode("../jsp/report/cust_report_list.jsp")%>'))


</script>
<SCRIPT>
imagePath = "../ui/framework/resources/";
initializeDocument()
</SCRIPT>

</body>
</html>