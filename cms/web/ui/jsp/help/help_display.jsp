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

String winState = request.getParameter("winState");
String topic = request.getParameter("topic");
String sHelpDocID = request.getParameter("help_doc_id");
String findCriteria = request.getParameter("findCriteria");

String sDisplayHeading = "Welcome";
String sContentText = "Browse the Help navigation to the left or search for Help topics in the search bar above.";

String sRequest = null;

if ((null == findCriteria) || ("" == findCriteria) || ("0" == findCriteria))
{
	sRequest = new String("<request><action>helpview</action><help_doc_id>" + sHelpDocID + "</help_doc_id><criteria></criteria></request>");
}
else
{
	sRequest = new String("<request><action>helpview</action><help_doc_id>" + sHelpDocID + "</help_doc_id><criteria><![CDATA[" + findCriteria + "]]></criteria></request>");
}

if ((winState == null) || ("".equals(winState)))
{
	winState = "inDoc";
}

if ((topic == null) || ("".equals(topic)))
{
	winState = "inDoc";
	topic = "";
}
else
{
	if (topic.indexOf("-pg") <= 0)
	{
		//topic += "-pg" + sHelpDocID;
	}
}

String showToc = "";

if ("pop".equals(winState))
{
	showToc = "<< Show Table of Contents";
}
else
{
	showToc = "Hide Table of Contents >>";
}

try
{
	String sResponse = Service.communicate(ServiceType.SADM_HELP_DOC_INFO, cust.s_cust_id, sRequest);      
	Element eRoot = XmlUtil.getRootElement(sResponse);
	//System.out.println("xml=" + sResponse);        
	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
	{
		sDisplayHeading = XmlUtil.getChildCDataValue(eRoot, "DisplayHeading");
		sContentText = XmlUtil.getChildCDataValue(eRoot, "ContentText");
		
		XmlElementList xelDocs = null;
		Element eDoc = null;
		int nCount = 0;

%>
<html>
<head>
<title><%= sDisplayHeading %></title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
<style type="text/css">
	
	BODY, TD, DIV
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
<script language="javascript">
	
	function toggleTOC()
	{
	<%
	if ("pop".equals(winState))
	{
		%>
		top.location.href = "help_frame.jsp?topic=<%= topic %>&help_doc_id=<%= sHelpDocID %>&winState=withTOC";
		<%
	}
	else
	{
		%>
		top.location.href = "help_display.jsp?topic=<%= topic %>&help_doc_id=<%= sHelpDocID %>&winState=pop";
		<%
	}
	%>
		resizeWin('<%= winState %>');
	}
	
	function window.onload()
	{
		resizeWin('<%= winState %>');
		self.focus();
	}
	
	function resizeWin(winState)
	{
		if ("pop" == winState)
		{
			top.window.resizeTo(324, window.screen.availHeight - 50);
			var nWidth = window.screen.availWidth - 10;
			top.window.moveTo(nWidth, 0);
			
			top.window.resizeTo(325, window.screen.availHeight - 50);
			var nWidth = window.screen.availWidth - 340;
			top.window.moveTo(nWidth, 0);
		}
		else if ("withTOC" == winState)
		{
			top.window.resizeTo(624, window.screen.availHeight - 50);
			var nWidth = window.screen.availWidth - 10;
			top.window.moveTo(nWidth, 0);
			
			top.window.resizeTo(625, window.screen.availHeight - 50);
			var nWidth = window.screen.availWidth - 640;
			top.window.moveTo(nWidth, 0);
		}
	}
	
	function gotoPage(help_doc_id, topic)
	{
		location.href = "help_display.jsp?help_doc_id=" + help_doc_id + "&findCriteria=&winState=<%= winState %>&topic=" + topic;
	}
	
</script>
</head>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" style="padding:0px;">
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
<%
if (("pop".equals(winState)) || ("withTOC".equals(winState)))
{
	%>
	<tr height="30">
		<td class="MenuBar" align="left" valign="middle" style="padding:5px;">
			<a href="#" onclick="toggleTOC();" class="resourcebutton"><%= showToc %></a>
		</td>
	</tr>
	<%
}
%>
	<tr height="35">
		<td style="padding:5px;"><div class="HelpHeading"><%= sDisplayHeading %></div></td>
	</tr>
	<tr>
		<td>
			<div class="HelpContent">
				<%= sContentText %>
			</div>
		</td>
	</tr>
<%
String sChildID = null;
String sChildHeading = null;
	
XmlElementList xelTopics = XmlUtil.getChildrenByName(eRoot, "SubTopics");
Element eTopic = null;
int tCount = xelTopics.getLength();

if (tCount > 0)
{
	for (int t=0; t < tCount; t++)
	{
		eTopic = (Element) xelTopics.item(t);
		
		xelDocs = XmlUtil.getChildrenByName(eTopic, "HelpDocPage");
		eDoc = null;
		nCount = xelDocs.getLength();
		
		if (nCount > 0)
		{
			%>
	<tr height="30">
		<td style="padding:5px;"><div class="HelpSubHeading">Related Topics:</div></td>
	</tr>
	<tr height="150">
		<td>
			<div style="width:100%; height:100%; overflow:auto; padding:10px;">
			<%
			for (int n=0; n < nCount; n++)
			{
				eDoc = (Element) xelDocs.item(n);
				sChildID = XmlUtil.getChildTextValue(eDoc, "HelpDocID");
				sChildHeading = XmlUtil.getChildCDataValue(eDoc, "DisplayHeading");
			%>
				<%=((sHelpDocID != null) && (sHelpDocID.equals(sChildID)))?"<li>" + sChildHeading + "</li>":"<li><a href=\"help_display.jsp?help_doc_id=" + sChildID + "&findCriteria=&winState=" + winState + "&topic=" + topic + "\">" + sChildHeading + "</a></li>"%>
			<%
			}
			%>
			</div>
		</td>
	</tr>
			<%
		}
	}
}
%>
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