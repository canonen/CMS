<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.imc.*,
			java.util.*,java.util.Date,
			java.text.DateFormat,
			java.sql.*,java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	// === === ===

	EmailListItems elis = new EmailListItems();
	String sEmail = null;
	
	for( int k = 0; k < 9999; ++k )
	{
		sEmail = request.getParameter("f" + k);
		if( sEmail == null ) break;		
		sEmail = sEmail.trim();
		if(sEmail.equals("")) continue;
		sEmail = new String(sEmail.getBytes("ISO-8859-1"), "UTF-8");
		EmailListItem eli = new EmailListItem();		
		eli.s_email = sEmail;
		eli.s_email_type_id = request.getParameter("t" + k);
		elis.add(eli);
	}

	// === === ===

	EmailList el = new EmailList();

	String isCloned = BriteRequest.getParameter(request,"clone");
	if (isCloned == null) isCloned = "false";
	if ("false".equals(isCloned))
	{
		el.s_list_id = BriteRequest.getParameter(request,"listID");
	}
	
	el.s_cust_id = cust.s_cust_id;
	el.s_list_name = BriteRequest.getParameter(request,"name");
	el.s_type_id = BriteRequest.getParameter(request,"type");
	el.s_status_id = BriteRequest.getParameter(request,"status_id");
	el.m_EmailListItems = elis;
	el.save();

	// === === ===

	boolean bRcpSyncErr = false;

	try
	{
		String sRequest = el.toXml();
		String sResponse = Service.communicate(ServiceType.RQUE_LIST_SETUP, cust.s_cust_id, sRequest);
		XmlUtil.getRootElement(sResponse);
	}
	catch(Exception ex)
	{
		bRcpSyncErr = true;
	}

	// === === ===

	String listID = el.s_list_id;
	String listType = el.s_type_id;
	if (listType.equals("6")) listType = "4";
%>
<HTML>

<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<% if(bRcpSyncErr) { %>
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td>
			<H4><FONT color="#FF0000">
There was a communication problem while saving the list.<BR>
Please return to the list later and resave it even if you see the correct list.<BR>
Otherwise changes you made may not take effect when you send your campaign<BR>
Sorry for the inconvenience.
			</FONT></H4>
		</td>
	</tr>
</table>
<% } %>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>List:</b> <%= (isCloned.equals("true"))?"Cloned":"Saved" %></td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><b>The list was <%= (isCloned.equals("true"))?"cloned":"saved" %>.</b></p>
						<p align="center"><a href="list_list.jsp?typeID=<%= ((!listType.equals("5")&&!listType.equals("7"))?listType:"2") %>">Back to List</a></p>
						<p align="center"><a href="list_edit.jsp?listID=<%= listID %>"><%= (isCloned.equals("true"))?"Edit New Copy":"Back to Edit" %></a></p>
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
