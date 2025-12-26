<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*,
			java.net.*,java.io.*,
			java.sql.*,java.util.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp" %>
<%@ include file="validator.jsp"%>
<%
	//grab query strings
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	String sMainUrl = "";

	//set default values for querystrings

	if ((null == sNavTab) || ("".equals(sNavTab))) sNavTab = "Home";
	if ((null == sNavSection) || ("".equals(sNavSection))) sNavSection = "1";
	
	//check tab and set variables

	if (sNavTab.equals("Home"))
	{
		sMainUrl = "home/welcome_frame.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "home/welcome_frame.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "home/user_note_list_frame.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "home/admin_note_list_frame.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "workflow/pending_assets.jsp";
	}
	else if (sNavTab.equals("Camp"))
	{
		sMainUrl = "camp/camp_list_frame.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "camp/camp_list_frame.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "email_list/list_list.jsp?typeID=2";
		else if (sNavSection.equals("3")) sMainUrl = "email_list/list_list.jsp?typeID=3";
		else if (sNavSection.equals("4")) sMainUrl = "email_list/list_list.jsp?typeID=4";
		else if (sNavSection.equals("5")) sMainUrl = "wizard/wizard_list_frame.jsp";
		else if (sNavSection.equals("6")) sMainUrl = "wscamp/wscamp_list_frame.jsp";
	}
	else if (sNavTab.equals("Data"))
	{
		sMainUrl = "import/import_list_frame.jsp";

		if (sNavSection.equals("1")) sMainUrl = "import/import_list_frame.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "filter/filter_list_frame.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "export/export_list_frame.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "edit/recip_edit_frame.htm";
		else if (sNavSection.equals("5")) sMainUrl = "report/briteconnect_daily.jsp";
	}
	else if (sNavTab.equals("Cont"))
	{
		sMainUrl = "cont/cont_list_frame.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "cont/cont_list_frame.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "cont/dynamic_elements.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "cont/cont_template_login.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "scrape/content_scrapes.jsp";
		else if (sNavSection.equals("5")) sMainUrl = "cont/link_renaming_list.jsp";
		else if (sNavSection.equals("6")) sMainUrl = "image/image_list_frame.jsp";
	}
	else if (sNavTab.equals("Rept"))
	{
		sMainUrl = "report/report_list_frame.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "report/report_list_frame.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "report/super_camp_report_list_frame.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "report/cust_report_list_frame.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "report/report_settings_edit_frame.jsp";
		else if (sNavSection.equals("5")) sMainUrl = "report/pv_login.jsp";
		else if (sNavSection.equals("6")) sMainUrl = "report/pv_usage.jsp";
		else if (sNavSection.equals("7")) sMainUrl = "report/filter_list.jsp";
	}
	else if (sNavTab.equals("Admn"))
	{
		sMainUrl = "setup/users/user_list.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "setup/users/user_list.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "setup/from_addresses/from_address_list.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "form/form_list.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "setup/cust_attrs/cust_attr_list.jsp";
		else if (sNavSection.equals("5")) sMainUrl = "setup/categories/category_list.jsp";
		else if (sNavSection.equals("6")) sMainUrl = "setup/bbacks/bback_settings_edit.jsp";
		else if (sNavSection.equals("7")) sMainUrl = "setup/cont_attrs/cont_attr_list.jsp";
		else if (sNavSection.equals("8")) sMainUrl = "setup/unsub_msgs/unsub_msg_frame.jsp";
	}
	else if (sNavTab.equals("Help"))
	{
		sMainUrl = "help/index.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "help/index.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "help/help_link.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "help/faq_frame.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "help/support_contact.jsp?support_id=0";
	}

	{
		sNavTab = "Home";
		sNavSection = "1";
		sMainUrl = "home/welcome_frame.jsp";
	}

	//check for alternate url
	if ((null != sAltURL) && (!"".equals(sAltURL))) sMainUrl = sAltURL;

	String sRedirectUrl = "?tab=" + sNavTab + "&sec=" + sNavSection + "&url=" + URLEncoder.encode(sMainUrl, "UTF-8");
		
	if((ui.s_frame_dir == null) || ("".equals(ui.s_frame_dir)))
	{
		sRedirectUrl = "/cms/ui/nav/index.jsp" + sRedirectUrl;
	}
	else
	{
		sRedirectUrl = ui.s_frame_dir + sRedirectUrl;
	}
	
	response.sendRedirect(sRedirectUrl);
%>
