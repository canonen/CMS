<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, java.net.*, java.io.*, java.sql.*, java.util.*, java.util.*, java.sql.*, org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="header.jsp" %>
<%@ include file="validator.jsp"%>
<%
	//grab query strings
	
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
		sMainUrl = "briteservice/index.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "briteservice/user_modules.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "briteservice/servers.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "briteservice/session_monitor.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "briteservice/campaign_monitor.jsp";
		else if (sNavSection.equals("5")) sMainUrl = "briteservice/host_monitor.jsp";
	}
	else if (sNavTab.equals("Cust"))
	{
		sMainUrl = "customer/cust_list.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "customer/cust_list.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "customer/cust_unique_ids/cust_unique_ids_monitor.jsp";
	}
	else if (sNavTab.equals("Serv"))
	{
		sMainUrl = "software/machine_list.jsp";

		if (sNavSection.equals("1")) sMainUrl = "software/machine_list.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "software/mod_version_list.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "software/mod_inst_list.jsp";
	}
	else if (sNavTab.equals("Help"))
	{
		sMainUrl = "help/help_list.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "help/help_frame.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "help/faq_frame.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "help/support_frame.jsp";
	}
	else if (sNavTab.equals("Bill"))
	{
		sMainUrl = "bill/bill_form.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "bill/bill_form.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "bill/bill_plan.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "bill/bill_rate.jsp";
	}
	else if (sNavTab.equals("Syst"))
	{
		sMainUrl = "setup/system_users/system_user_list.jsp";
		
		if (sNavSection.equals("1")) sMainUrl = "setup/admin_system_users/user_list.jsp";
		else if (sNavSection.equals("2")) sMainUrl = "setup/partners/partner_list.jsp";
		else if (sNavSection.equals("3")) sMainUrl = "note/system_note_frame.jsp";
		else if (sNavSection.equals("4")) sMainUrl = "hm/w_frame.jsp";
		else if (sNavSection.equals("5")) sMainUrl = "registry.jsp";
		else if (sNavSection.equals("6")) sMainUrl = "delivery/delivery_monitor.jsp";
	}
	else
	{
		sNavTab = "Home";
		sNavSection = "1";
		sMainUrl = "briteservice/index.jsp";
	}

	//check for alternate url
	if ((null != sAltURL) && (!"".equals(sAltURL))) sMainUrl = sAltURL;

	String sRedirectUrl = "?tab=" + sNavTab + "&sec=" + sNavSection + "&url=" + URLEncoder.encode(sMainUrl);
	
	sRedirectUrl = "/sadm/adm/nav/index.jsp" + sRedirectUrl;

	response.sendRedirect(sRedirectUrl);
%>
