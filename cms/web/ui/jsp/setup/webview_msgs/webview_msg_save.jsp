<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.cnt.*"
	import="java.sql.*,java.io.*"
	import="javax.servlet.*"
	import="javax.servlet.http.*"
	import="org.w3c.dom.*"
	import="org.xml.sax.*"
	import="javax.xml.transform.*"
	import="javax.xml.transform.stream.*"
	import="org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	
	if(!can.bWrite)
	{
		response.sendRedirect("../../access_denied.jsp");
		return;
	}

	String customer_id = cust.s_cust_id;
	String msgID = BriteRequest.getParameter(request, "WebviewmsgID");
	String msgText = BriteRequest.getParameter(request, "WebviewMessageText");
	String msgHTML = BriteRequest.getParameter(request, "WebviewMessageHTML");
	String msgName = BriteRequest.getParameter(request, "MessageName");
	
	WebviewMsg wm = null;

	if( msgID== null || msgID.toLowerCase().equals("null"))
	{
		wm = new WebviewMsg();
		wm.s_cust_id = customer_id;
	}
	else 
	{
		wm = new WebviewMsg(msgID);
	}
// lw 5/2009 - added line breaks to the web text and html because if the last character of the web message is part of the url, the 
// url will elide into the content and so break the link.
	wm.s_msg_name = msgName;
	wm.s_html_msg = msgHTML + "<br/>";
	wm.s_text_msg = msgText + "\r\n";
	
	wm.save();
%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Header----->
<table width=650 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader><b class=sectionheader>Webview Message:</b> Processing</th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width=650>
			<table cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center">The Webview message has been saved.</p>
						<p align="center"><a href="webview_msg_list.jsp">Back to List</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>