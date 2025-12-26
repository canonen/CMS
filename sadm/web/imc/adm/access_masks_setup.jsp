<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.io.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
try
{
	Element eAccessMasks = XmlUtil.getRootElement(request);
	AccessMasks ams = new AccessMasks(eAccessMasks);

	ams.save();
	out.println(ams.toXml());
}
catch(Exception ex)
{ 
	logger.error("Exception: ",ex);
	ex.printStackTrace(new PrintWriter(out));
}
finally
{
	out.flush();
}
%>