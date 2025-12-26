<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			org.xml.sax.*,javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.w3c.dom.*,javax.xml.parsers.*,
			org.apache.log4j.*"
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

	String strFormXSL = request.getParameter("form_source");

	try
	{
		TransformerFactory tfactory = TransformerFactory.newInstance();
		StringReader srXSL = new StringReader(strFormXSL);

		Templates templates = tfactory.newTemplates(new StreamSource(srXSL));

		Transformer transformer = templates.newTransformer();

		StringReader srXML = new StringReader("<?xml version=\"1.0\"?><SubscriptionInfo/>");
		transformer.transform(new StreamSource(srXML), new StreamResult(out));

		srXSL.close();
		srXML.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		out.flush();
		out.close();
	}
	
%>
