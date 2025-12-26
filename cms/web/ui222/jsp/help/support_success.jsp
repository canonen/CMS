<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	Customer user_cust = new Customer(user.s_cust_id);
	Customer cSuper = ui.getSuperiorCustomer();
	String New_Support_ID = "";
	String Further_Info = "";
	
		if (request.getParameterValues("cor_type_id") != null)
		{
		
		int iLoop = 0;
		int n = request.getParameterValues("cor_id").length;
		int iType = 0;
		String sName = "";
		String sID = "";
		
		for(iLoop = 0; iLoop < n; iLoop++)
		{
			
			iType = Integer.parseInt(request.getParameterValues("cor_type_id")[iLoop]);
			sName = request.getParameterValues("cor_name")[iLoop];
			sID = request.getParameterValues("cor_id")[iLoop];
			
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
		}
		
		}
		
		String s_ticket_id = "";
		
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
		
		String sRequest = null;
		sRequest = "<request>" + 
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
		     
		if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
		{
			s_ticket_id = XmlUtil.getChildCDataValue(eRoot, "ticket_id");
		}
		else
		{
			%>ERROR<%
		}

%>
<html>
<head>
	<title>Contact Technical Support</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
</head>
<body>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Thank You</b></td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="left" valign="middle" style="padding:10px;">
						Your inquiry has been sent to the Technical Support Team.<br><br>
						For your reference, the Ticket Number is: <%= s_cust_id %>-<%= s_ticket_id %>.<br><br>
						<a href="support_contact.jsp">Click here</a> if you would like to send another request.
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</body>
</html>