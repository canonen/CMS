<%@ page language="java"
		 import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%
	response.setHeader("Cache-Control", "no-store, no-cache"); //, max-age=0");
	response.setContentType("text/html;charset=UTF-8");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Headers", "x-requested-with, content-type");
	response.setHeader("Access-Control-Allow-Origin","https://cms.revotas.com:3001");
	response.setHeader("Access-Control-Allow-Credentials", "true");
	response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	Customer user_cust = new Customer(user.s_cust_id);
	Customer cSuper = ui.getSuperiorCustomer();
	String New_Support_ID = "";
	String Further_Info = "";

	String[] corTypeIds = request.getParameterValues("cor_type_id");
	String[] corNames = request.getParameterValues("cor_name");
	String[] corIds = request.getParameterValues("cor_id");
	String ticketId = request.getParameter("ticket_id");

	if (corTypeIds != null) {
		int n = corTypeIds.length;
		for (int iLoop = 0; iLoop < n; iLoop++) {
			try {
				int iType = Integer.parseInt(corTypeIds[iLoop]);
				String sName = corNames[iLoop];
				String sID = corIds[iLoop];

				switch(iType )
				{
					case FilterType.MULTIPART:
					{
						Further_Info += "Target Group: " + sName + " (Filter_ID=" + sID + ")\n\n";
						break;
					}
					case FilterType.CAMPAIGN:
					{
						Further_Info += "Campaign: " + sName + " (Origin_Camp_ID=" + sID + ")\n\n";
						break;
					}
					case FilterType.CAMPAIGN_FORM:
					{
						Further_Info += "Campaign Form: " + sName + " (Camp_Form_ID=" + sID + ")\n\n";
						break;
					}
					case FilterType.BATCH:
					{
						Further_Info += "Batches: " + sName + " (Batch_ID=" + sID + ")\n\n";
						break;
					}
					case FilterType.LINK_CLICK:
					{
						Further_Info += "Links: " + sName + " (Link_ID=" + sID + ")\n\n";
						break;
					}
					case FilterType.UPLOAD:
					{
						Further_Info += "Imports of Batches: " + sName + " (Import_ID=" + sID + ")\n\n";
						break;
					}
					case FilterType.FORM_SUBMIT:
					{
						Further_Info += "Subscription Form: " + sName + " (Form_ID=" + sID + ")\n\n";
						break;
					}
					default:
					{
						Further_Info += "No items selected.\n";
						break;
					}
				}
			} catch (NumberFormatException e) {
				e.printStackTrace();
			}
		}
	}  else {
		out.println("Exception: cor_type_id is null! ");
	}
	String s_ticket_id = (ticketId != null) ? ticketId : "";
	String s_cust_id = "";
	String s_cust_name = "";
	String s_user_id = "";
	String s_user_name = "";
	String s_email_from = "";
	String s_email_to = "";
	String s_email_cc = "";
	String s_phone = "";
	String s_subject = "";
	String s_original_issue = "";
	String s_further_info = "";
	String s_resolution_info = "";
	String s_browser_info = "";
	s_cust_id		= user.s_cust_id;
	s_cust_name		= cSuper.s_cust_name;
	s_user_id		= user.s_user_id;
	s_user_name		= user.s_user_name + " " + user.s_last_name;
	s_phone			= user.s_phone;
	s_email_from	= user.s_email;
	s_email_to 		= ui.getProp("sup_level_1");
	s_email_cc 		= ui.getProp("sup_level_2");
	s_subject = request.getParameter("selAreas");
	s_original_issue = request.getParameter("txtProblem");
	s_further_info = Further_Info;
	s_browser_info = request.getHeader("user-agent");
	String sRequest = "";
	sRequest += "<request>" +
			"<action>supportcreate</action>" +
			"<ticket_id><![CDATA[" + s_ticket_id + "]]></ticket_id>" +
			"<cust_id><![CDATA[" + s_cust_id + "]]></cust_id>" +
			"<cust_name><![CDATA[" + s_cust_name + "]]></cust_name>" +
			"<user_id><![CDATA[" + s_user_id + "]]></user_id>" +
			"<user_name><![CDATA[" + s_user_name + "]]></user_name>" +
			"<phone><![CDATA[" + s_phone + "]]></phone>" +
			"<email_from><![CDATA[" + s_email_from + "]]></email_from>" +
			"<email_to><![CDATA[" + s_email_to + "]]></email_to>" +
			"<email_cc><![CDATA[" + s_email_cc + "]]></email_cc>" +
			"<subject><![CDATA[" + s_subject + "]]></subject>" +
			"<original_issue><![CDATA[" + s_original_issue + "]]></original_issue>" +
			"<further_info><![CDATA[" + s_further_info + "]]></further_info>" +
			"<resolution_info><![CDATA[" + s_resolution_info + "]]></resolution_info>" +
			"<browser_info><![CDATA[" + s_browser_info + "]]></browser_info>" +
			"</request>";
	String sResponse = Service.communicate(ServiceType.SADM_HELP_DOC_INFO, cust.s_cust_id, sRequest);
	Element eRoot = XmlUtil.getRootElement(sResponse);
	JsonObject json = new JsonObject();
	JsonArray arr = new JsonArray();

	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
	{
		s_ticket_id = XmlUtil.getChildCDataValue(eRoot, "ticket_id");
		json.put("cust_id", s_cust_id);
		json.put("ticket_id", s_ticket_id);
		arr.put(json);
		out.print(arr);
	}
	else
	{
%>ERROR<%
	}
%>
