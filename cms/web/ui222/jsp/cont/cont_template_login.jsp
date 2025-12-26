<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.io.*"
    import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>

<%
String enter_wizard = request.getParameter("enter_wizard");
	String isWizard = "0";
	if (enter_wizard != null && enter_wizard.equals("1")) isWizard = "1";

	boolean HYATTADMIN = (ui.n_ui_type_id == UIType.HYATT_ADMIN);
	String isAdmin = "0";
	if (HYATTADMIN) isAdmin = "1";
	
	boolean HYATTSYS = ui.getFeatureAccess(Feature.HYATT);
	String isHyatt = "0";
	if (HYATTSYS) isHyatt = "1";
	
	boolean TEMPLATEADMIN = ui.getFeatureAccess(Feature.TEMPLATE_ADMIN);
	if (TEMPLATEADMIN) isAdmin = "1";

	// Set session scope attributes
	session.setAttribute("isAdmin", isAdmin);
	session.setAttribute("isHyatt", isHyatt);
	session.setAttribute("isWizard", isWizard);
	
    if (isWizard.equals("1")) {
	    response.sendRedirect("../ctm/index.jsp");
    }
    else {
	    response.sendRedirect("../ctm/index.jsp");
    }

%>
