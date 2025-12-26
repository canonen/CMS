<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.net.*,java.util.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,javax.mail.*,javax.mail.internet.*,
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

boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);
boolean canSearchHelp = ui.getFeatureAccess(Feature.HELP_SEARCH);
boolean canFAQs = ui.getFeatureAccess(Feature.FAQS);
boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

%>
<html>
<head>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
</head>
<body topmargin="0" leftmargin="0" marginheight="0" marginwidth="0">
<% if (canSupReq) { %>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="../index.jsp?tab=Help&sec=4" target="_parent">New Support Request</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<% } %>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="left" valign="top" width="50%">
			<table class=listTable cellspacing="0" cellpadding="0" width="100%" border="0">
			<tr>
				<th>Help Documentation</th>
			</tr>
				<tr>
					<td class="listHeading" valign="center" nowrap align="left">
						
						
						<table class="" cellpadding="2" cellspacing="1" border="0" width="100%">
							<tr>
								<td align="left" valign="top" style="padding:10px;">
									<% if (isHyatt) { %>
									Discover how to utilize Hyatt's campaign management platform software to the best of it's abilities.<br><br>
									<li>Learn how to enter content and create campaigns</li>
									<li>Select images from the image library</li>
									<li>Test campaigns</li>
									<li>Request Approval</li>
									<br><br>
									<table class="listTable" cellspacing="0" cellpadding="5" border="0" width="100%">
										<tr>
											<td align="left" valign="middle" class="listItem_Data" style="padding-left:10px;" width="100%">Download the Help Document to print or read offline</td>
											<td align="center" valign="middle" class="listItem_Data" nowrap style="padding:5px;"><a class="subactionbutton" href="http://www.revotas.com/products/52Help/hyatt_help.pdf">Go >></a>&nbsp;&nbsp;&nbsp;</td>
										</tr>
									</table>
									<% } else { %>
									Discover how to utilize your campaign management platform software to the best of it's abilities.<br><br>
									<li>Learn how to create campaigns, import lists, and enter your content</li>
									<li>Create more effective marketing messages</li>
									<li>Provide personalized greetings</li>
									<li>Use dynamic content to display recipient-specific content for powerful messaging</li>
									<li>Create SampleSet campaigns to test subject lines and content</li>
									<br><br>
									<table class="listTable" cellspacing="0" cellpadding="5" border="0" width="100%">
										<tr>
											<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" width="100%">Read the Help Document to learn more about the system</td>
											<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a class="subactionbutton" href="http://www.revotas.com/products/60help/help.htm">Go >></a>&nbsp;&nbsp;&nbsp;</td>
										</tr>
									</table>
									<% } %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
		<td align="left" valign="top">&nbsp;</td>
		<td align="left" valign="top" width="50%">
		<% if (canFAQs) { %>
			<table cellspacing="0" class=listTable cellpadding="0" width="100%" border="0">
			<tr>
							<th>Frequently Asked Questions</th>
			</tr>
				<tr>
					<td class="listHeading" valign="center" nowrap align="left">
						
						
						<table class="" cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
								<td align="left" valign="top" style="padding:10px;">
									Find answers to the most commonly asked questions and problems that users encounter.<br><br>
									<table class="listTable" cellspacing="0" cellpadding="5" border="0" width="100%">
										<tr>
											<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" width="100%">Check out the Frequently Asked Questions</td>
											<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a target="_parent" class="subactionbutton" href="../index.jsp?tab=Help&sec=3">Go >></a>&nbsp;&nbsp;&nbsp;</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<br>
		<% } %>
			<table cellspacing="0" class=listTable cellpadding="0" width="100%" border="0">
			<tr>
										<th>Contact Support</th>
			</tr>
				<tr>
					<td class="listHeading" valign="center" nowrap align="left">
						
						
						<table class="" cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
								<td align="left" valign="top" style="padding:10px;">
									Our Technical Support staff is on duty from 8:30AM to 6:00PM EST, Monday-Friday.<br><br>
									<table class="listTable" cellspacing="0" cellpadding="5" border="0" width="100%">
										<tr>
											<td align="left" valign="middle" class="listItem_Data_Alt" style="padding-left:10px;" width="100%">Have your questions answered or give us feedback</td>
											<td align="center" valign="middle" class="listItem_Data_Alt" nowrap style="padding:5px;"><a target="_parent" class="subactionbutton" href="../index.jsp?tab=Help&sec=4">Go >></a>&nbsp;&nbsp;&nbsp;</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>