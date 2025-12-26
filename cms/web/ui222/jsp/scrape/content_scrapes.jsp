<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.util.Vector,
			org.w3c.dom.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}


String goToSection = request.getParameter("deSec");

String sContentScrapeSection = ui.getSessionProperty("content_scrape_section");

if (goToSection == null)
{
	if ((null != sContentScrapeSection) && ("" != sContentScrapeSection))
	{
		goToSection = sContentScrapeSection;
	}
	else
	{
		goToSection = "1";
	}
}

ui.setSessionProperty("content_scrape_section", goToSection);

if (goToSection.equals("1"))
{
	//1 -- Content Scrapes
	response.sendRedirect("scrape_list.jsp");
}
else
{
	//2 -- Scrape Formats
	response.sendRedirect("scrape_format_list.jsp");
}

%>