<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,
			java.io.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

String CATEGORY_ID = BriteRequest.getParameter(request,"category_id");
String CAMP_ID     = BriteRequest.getParameter(request,"camp_id");
String MODE        = BriteRequest.getParameter(request,"mode");
String CUR_STEP    = BriteRequest.getParameter(request,"step");

// Save Main Campaign
boolean bDoClone = ("clone".equals(MODE));
Campaign camp = saveCamp(cust, user, request, bDoClone);
CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CAMPAIGN, camp.s_camp_id, request);

// Save Sampleset
boolean bHasSampleSet = false;
if(!bDoClone)
{
	CampSampleset camp_sampleset = new CampSampleset();
	camp_sampleset.s_camp_id = camp.s_camp_id;
	if (camp_sampleset.retrieve() > 0)
	{
		bHasSampleSet = true;
		saveCampSamples(camp_sampleset,request);
	}
}

if (MODE.equals("send_test")) {
	String sRedirectUrl = "/cms/ui/jsp/camp/bnet_camp_send.jsp?wizard_mode=true&camp_id=" + camp.s_camp_id + "&mode=test";
	response.sendRedirect(sRedirectUrl);
}
else if (MODE.equals("send_camp"))
{
	String sRedirectUrl = "/cms/ui/jsp/camp/bnet_camp_send_confirm.jsp?camp_id=" + camp.s_camp_id;
	//String sRedirectUrl = "/cms/ui/jsp/camp/camp_send.jsp?wizard_mode=true&camp_id=" + camp.s_camp_id + "&approval_flag=1";
	response.sendRedirect(sRedirectUrl);
}
else if (MODE.equals("save_n_exit"))
{
	String sRedirectUrl = "campaigns.jsp?a=campaigns";
	response.sendRedirect(sRedirectUrl);
}

%>

<HTML>
<HEAD>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY onload="location.href = 'wizard.jsp?step=<%= CUR_STEP %>&camp_id=<%= camp.s_camp_id %><%=(CATEGORY_ID!=null)?"&category_id="+CATEGORY_ID:""%>&a=campaigns';">
</BODY>
</HTML>


<%@ include file="../camp/camp_save_functions.inc"%>
