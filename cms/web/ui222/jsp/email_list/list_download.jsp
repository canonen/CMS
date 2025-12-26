<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			javax.servlet.http.*,
			javax.servlet.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%!
	static Logger logger = null;
	protected static String getParameterName (String sSource)	throws Exception
	{
		String sParamName = null;
		String sSearch = "name=\"";
		int nBeginning = sSource.indexOf (sSearch) + sSearch.length();
		int nEnd = sSource.indexOf ("\"", nBeginning);
		sParamName = sSource.substring (nBeginning, nEnd);
		return sParamName;
	}
%>
<%
	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

	if(!can.bExecute)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	// === === ===
	
	// This is homemade code to parse form data
	// there should be a standard way to do that
	// no time right now to rewrite it
		
	Hashtable htParams = new Hashtable();
		
	BufferedReader in =
		new BufferedReader(new InputStreamReader(request.getInputStream(), "UTF-8"));
				
	String sRequestDelimiter = in.readLine();
	
	while(true)
	{
		String sHeaderString = in.readLine();
		String sParamName = getParameterName(sHeaderString);

		if(sParamName.equals("recipient_file")) break;
		
		String sParamValue = null;
		for(String sLine = in.readLine(); !(sLine.equals("")); sLine = in.readLine());
		for(String sLine = in.readLine(); !(sLine.startsWith(sRequestDelimiter)); sLine = in.readLine())
		{
			if(sParamValue == null) sParamValue = sLine;
			else sParamValue += "\r\n" + sLine;
		}
		htParams.put(sParamName, sParamValue);
	}
	
	EmailListItems elis = new EmailListItems();

	for(String sLine = in.readLine(); !(sLine.equals("")); sLine = in.readLine());
	for(String sLine = in.readLine(); !(sLine.startsWith(sRequestDelimiter)); sLine = in.readLine())
	{
		sLine = sLine.trim();
		if(sLine.equals("")) continue;
		EmailListItem eli = new EmailListItem();		
		eli.s_email = sLine;
		eli.s_email_type_id = "1";
		elis.add(eli);
	}

	// === === ===

	EmailList el = new EmailList();
	el.s_cust_id = cust.s_cust_id;
	el.s_list_name = htParams.get("list_name").toString().trim();
	el.s_type_id = htParams.get("type_id").toString().trim();
	el.s_status_id = String.valueOf(EmailListStatus.ACTIVE);
	el.m_EmailListItems = elis;
	el.save();

	// === === ===
	
	try
	{
		String sRequest = el.toXml();
		String sResponse = Service.communicate(ServiceType.RQUE_LIST_IMPORT_SETUP, cust.s_cust_id, sRequest);
		XmlUtil.getRootElement(sResponse);
	}
	catch(Exception ex)
	{
		el.delete();
		throw ex;
	}
	
	// === === ===	

	String sListID = el.s_list_id;
	String sTypeID = el.s_type_id;
%>

<HTML>

<HEAD>
	<BASE target="_self">
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>List:</b> Downloaded</td>
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
						<p align="center"><b>The file was transmitted and uploaded.</b></p>
						<p align="center"><a href="list_list.jsp?typeID=<%= (!sTypeID.equals("5")?sTypeID:"2") %>">Back to List</a></p>
						<p align="center"><a href="list_edit.jsp?listID=<%= sListID %>">View List</a></p>
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
