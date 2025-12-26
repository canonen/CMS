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

String sDynamicElementsSection = ui.getSessionProperty("dynamic_elements_section");

if (goToSection == null)
{
	if ((null != sDynamicElementsSection) && ("" != sDynamicElementsSection))
	{
		goToSection = sDynamicElementsSection;
	}
	else
	{
		goToSection = "1";
	}
}

ui.setSessionProperty("dynamic_elements_section", goToSection);

if (goToSection.equals("1"))
{
	//1 -- Logic Blocks
	response.sendRedirect("logic_block_list.jsp");
}
else if (goToSection.equals("2"))
{
	//2 -- Content Elements
	response.sendRedirect("cont_block_list.jsp");
}
else
{
	//3 -- Logic Blocks
	response.sendRedirect("filter_list.jsp");
}

%>