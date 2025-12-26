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
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sFAQID = request.getParameter("faq_id");
String findCriteria = request.getParameter("findCriteria");

String sDisplayHeading = "Welcome";
String sAskQuestion = "Browse the FAQ navigation to the left.";
String sGivenAnswer = "";

String sRequest = null;

if ((null == findCriteria) || ("".equals(findCriteria)) || ("0".equals(findCriteria)) || ("null".equals(findCriteria)))
{
	sRequest = new String("<request><action>faqview</action><faq_id>" + sFAQID + "</faq_id><criteria></criteria></request>");
}
else
{
	sRequest = new String("<request><action>faqview</action><faq_id>" + sFAQID + "</faq_id><criteria><![CDATA[" + findCriteria + "]]></criteria></request>");
}

try
{
	String sResponse = Service.communicate(ServiceType.SADM_HELP_DOC_INFO, cust.s_cust_id, sRequest);      
	Element eRoot = XmlUtil.getRootElement(sResponse);
	//System.out.println("xml=" + sResponse);
	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
	{
		sDisplayHeading = XmlUtil.getChildCDataValue(eRoot, "DisplayHeading");
		sAskQuestion = XmlUtil.getChildCDataValue(eRoot, "AskQuestion");
		sGivenAnswer = XmlUtil.getChildCDataValue(eRoot, "GivenAnswer");
%>
<html>
<head>
<title><%= sDisplayHeading %></title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<style type="text/css">
	
	BODY
	{
		line-height: 160%;
	}
	
	.tip
	{
		border: 1px solid #FFBB77;
		background-color: #FFFFEE;
		padding: 3px;
	}
	
</style>
</head>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" style="padding:0px;">
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="35">
		<td style="padding:5px;"><div class="HelpHeading"><%= sDisplayHeading %></div></td>
	</tr>
	<% if (sGivenAnswer!=null && !"<P>&nbsp;</P>".equals(sGivenAnswer)) { %>
	<tr height="30">
		<td style="padding:5px;"><div class="HelpSubHeading">Issue:<%= sGivenAnswer %></div></td>
	</tr>
	<% } %>
	<tr height="50">
		<td>
	<div class="HelpContent">
		<%= sAskQuestion %>
	</div>
		</td>
	</tr>
	<% if (sGivenAnswer!=null && !"<P>&nbsp;</P>".equals(sGivenAnswer)) { %>
	<tr height="30">
		<td style="padding:5px;"><div class="HelpSubHeading">Resolution:</div></td>
	</tr>
	<% } %>
	<tr>
		<td>
	<div class="HelpContent">
		<%= (sGivenAnswer==null)?"":sGivenAnswer %>
	</div>
		</td>
	</tr>
</table>
</body>
</html>
<%
	}
	else
	{
		%>ERROR<%
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
