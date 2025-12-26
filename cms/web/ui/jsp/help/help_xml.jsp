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
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try
{
	String sRequest = new String("<request><action>helpdoc</action></request>");
	String sResponse = Service.communicate(ServiceType.SADM_HELP_DOC_INFO, cust.s_cust_id, sRequest);      
	//System.out.println("xml=" + sResponse);
	Element eRoot = XmlUtil.getRootElement(sResponse);        
	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
	{
		%>
		<?xml version="1.0" encoding="UTF-8"?>
		<%= sResponse %>
		<%
	}
}
catch(Exception ex)
{
	throw ex;
}
finally
{
	//nothing
}
%>