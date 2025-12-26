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
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String topic = "0";
String faq_id = "0";
String findCriteria = "";
String gotoSearch = "no";
String helpContentsURL = "help_display.jsp";

topic = request.getParameter("topic");
faq_id = request.getParameter("faq_id");
findCriteria = request.getParameter("findCriteria");
gotoSearch = request.getParameter("gotoSearch");

if (faq_id == null)
{
	faq_id = "0";
}

if (findCriteria == null)
{
	findCriteria = "";
}

if (gotoSearch == null)
{
	gotoSearch = "no";
}

if (gotoSearch.compareTo("yes") == 0)
{
	helpContentsURL = "faq_search.jsp?findCriteria=" + findCriteria + "&topic=" + topic;
}
else
{
	helpContentsURL = "faq_display.jsp?faq_id=" + faq_id + "&findCriteria=" + findCriteria + "&topic=" + topic;
}

%>
<html>
<head>
<title>Frequently Asked Questions</title>
</head>
<frameset name="contentArea" cols="260,*" framespacing="0" border="0" frameborder="0" style="border-top:1px solid #676767;">
	<frameset name="contentArea" rows="55,*" framespacing="0" border="0" frameborder="0" style="border:0px;">
		<frame name="findBar" scrolling="no" src="faq_Find.jsp?findCriteria=<%= findCriteria %>" style="border-bottom:1px solid #676767; border-right:1px solid #676767;" noresize></frame>
		<frame name="helpTOC" scrolling="auto" src="faq_toc.jsp?topic=<%= topic %>&faq_id=<%= faq_id %>" style="border-right:1px solid #676767;"></frame>
	</frameset>
	<frame name="helpContents" scrolling="auto" src="<%= helpContentsURL %>"></frame>
</frameset>
</html>
