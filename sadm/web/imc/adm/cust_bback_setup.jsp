<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
Customer cust = null;
Customer cTemp = null;

String sSql = null;
boolean bAutoCommit = true;
String sErrMsg = null;

try
{
	Element eBBack = XmlUtil.getRootElement(request);
	Element eCust = XmlUtil.getChildByName(eBBack, "customer");
	cTemp = new Customer(eCust);
	cust = new Customer(cTemp.s_cust_id);
	cust.s_max_bbacks = cTemp.s_max_bbacks;
	cust.s_max_bback_days = cTemp.s_max_bback_days;
	cust.s_max_consec_bbacks = cTemp.s_max_consec_bbacks;
	cust.s_max_consec_bback_days = cTemp.s_max_consec_bback_days;	
	cust.save();
	
}
catch(Exception ex)
{ 
	logger.error("Exception: ", ex);
	
	StringWriter sw = new StringWriter();
	ex.printStackTrace(new PrintWriter(sw));
	sErrMsg = sw.toString();
}
finally
{
	if (sErrMsg == null) {
		String sXml =
			"<cust_bback_setup>" +
				"<ok>ok</ok>" +
			"</cust_bback_setup>";
		out.println(sXml);
	} else out.println(sErrMsg);
}
out.flush();
%>
