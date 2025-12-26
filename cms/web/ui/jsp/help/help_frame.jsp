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

String winState = "inDoc";
String topic = "0";
String help_doc_id = "0";
String findCriteria = "";
String gotoSearch = "no";
String helpContentsURL = "help_display.jsp";
String displaySize = "*";

winState = request.getParameter("winState");
topic = request.getParameter("topic");
help_doc_id = request.getParameter("help_doc_id");
findCriteria = request.getParameter("findCriteria");
gotoSearch = request.getParameter("gotoSearch");

if (help_doc_id == null)
{
	help_doc_id = "0";
}

if (findCriteria == null)
{
	findCriteria = "";
}

if (gotoSearch == null)
{
	gotoSearch = "no";
}

if (winState == null)
{
	winState = "inDoc";
}

if (topic == null)
{
	topic = "";
}

if (gotoSearch.compareTo("yes") == 0)
{
	helpContentsURL = "help_search.jsp?findCriteria=" + findCriteria + "&winState=" + winState + "&topic=" + topic;
}
else
{
	helpContentsURL = "help_display.jsp?help_doc_id=" + help_doc_id + "&findCriteria=" + findCriteria + "&winState=" + winState + "&topic=" + topic;
}

if (!("inDoc".equals(winState)))
{
	displaySize = "365";
}

%>
<html>
<head>
<title>Help Document</title>
</head>
<frameset cols="260,<%= displaySize %>" framespacing="0" border="0" frameborder="0" style="border-top:1px solid #676767;">
<%
if ("inDoc".equals(winState))
{
	%>
	<frameset name="contentArea" rows="55,*" framespacing="0" border="0" frameborder="0" style="border:0px;">
		<frame name="findBar" scrolling="no" src="help_Find.jsp?findCriteria=<%= findCriteria %>" style="border-bottom:1px solid #676767; border-right:1px solid #676767;" noresize></frame>
		<frame name="helpTOC" scrolling="auto" src="help_toc.jsp?topic=<%= topic %>&help_doc_id=<%= help_doc_id %>&winState=<%= winState %>" style="border-right:1px solid #676767;"></frame>
	</frameset>
	<%
}
else
{
	%>
	<frame name="helpTOC" scrolling="auto" src="help_toc.jsp?topic=<%= topic %>&help_doc_id=<%= help_doc_id %>&winState=<%= winState %>" style="border-right:1px solid #676767;"></frame>
	<%
}
%>
	<frame name="helpContents" scrolling="no" src="<%= helpContentsURL %>"></frame>
</frameset>
</html>