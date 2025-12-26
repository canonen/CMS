<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			java.text.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// === === ===

String sCampId = request.getParameter("camp_id");
String sCampType = request.getParameter("type_id");
String sMediaType = request.getParameter("media_type_id");
String sSelectedCategoryId = request.getParameter("category_id");

String sRedirectURL = "camp_edit_single.jsp";

CampSampleset camp_sampleset = new CampSampleset();
camp_sampleset.s_camp_id = sCampId;
if(camp_sampleset.retrieve() > 0) sRedirectURL = "camp_edit_with_samples.jsp";

response.sendRedirect(sRedirectURL + "?" + request.getQueryString());

%>