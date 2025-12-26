<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.sas.*,
			com.britemoon.sas.imc.*,
			java.sql.*,
			java.io.*,
			java.util.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"	
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp" %>
<%
	try
	{
		UnsubMsg unsubObj = new UnsubMsg(XmlUtil.getRootElement(request));
		unsubObj.save();
		System.out.println("messageid in unsub_msg_setup = " + unsubObj.s_msg_id);
		
		//Send back the id of the unsubscribe message

		String returnXml = "<unsub_msg>\n<msg_id>" + unsubObj.s_msg_id + "</msg_id>\n</unsub_msg>\n";
		out.print(returnXml);
	}
	catch (Exception e)
	{
		logger.error("Exception: ", e);

		String returnXml = "<unsub_msg>\n<error><![CDATA["+e.getMessage()+"]]></error>\n</unsub_msg>";
		
		out.print(returnXml);
	}
%>