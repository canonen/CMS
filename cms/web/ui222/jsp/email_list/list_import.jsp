<%@ page
	language="java"
	import="com.britemoon.cps.*,
		com.britemoon.*,
		java.util.*,java.sql.*,
		java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

// === === ===

String listTypeID = request.getParameter("typeID");
String listType = null;
String listName = "New list";

if (listTypeID == null) listTypeID = "2";

if (listTypeID.equals("1")) listType = "Global Exclusion";
if (listTypeID.equals("2")) listType = "QA Test";
if (listTypeID.equals("3")) listType = "Exclusion";
if (listTypeID.equals("4") || listTypeID.equals("6")) listType = "Auto-Respond Notification";

String sFingerSeq = "";
if (listTypeID.equals("5"))
{
	listType = "Specified Test Recipient";

	ConnectionPool	cp= null;
	Connection conn = null;
	Statement stmt = null;	

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		String sSql = 
			" SELECT ISNULL(ca.display_name,a.attr_name)" +
			" FROM ccps_attribute a, ccps_cust_attr ca" +
			" WHERE ca.attr_id = a.attr_id" +
			" AND ca.cust_id = " + cust.s_cust_id +
			" AND ca.fingerprint_seq IS NOT NULL" +
			" ORDER BY fingerprint_seq";
			
		ResultSet rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			sFingerSeq += ((sFingerSeq.length() > 0)?" + ":"");
			sFingerSeq += new String(rs.getBytes(1), "UTF-8");
		}
		rs.close();
	}
	catch (Exception ex) { ErrLog.put(this,ex, "Problem with Import.",out,1); }
	finally
	{
		try { if ( stmt != null ) stmt.close(); }
		catch (Exception exx) {}
		if ( conn  != null ) cp.free(conn); 
	}
}
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT>
function try_submit ()
{
	FT.list_name.value = FT.list_name.value.replace(/(^\s*)|(\s*$)/g, '');
	if(FT.list_name.value == "" ){ alert("You have to type list name ...");	return false; }
	if(FT.recipient_file.value == "" )	{ alert("You have to choose File ...");		return false; }
	FT.submit();
}
</SCRIPT>
</HEAD>

<BODY>
<% if(can.bWrite) { %>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="savebutton" href="javascript:try_submit();">Save</a>
		</td>
	</tr>
</table>
<br>
<% } %>

<FORM  METHOD="POST" NAME="FT" ENCTYPE="multipart/form-data" ACTION="list_download.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="type_id" VALUE="<%= listTypeID %>">

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class="sectionheader"><b class=sectionheader>Step 1:</b> Name your <%= listType %> List</td>
	</tr>
</table>
<br>

<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class="main" WIDTH="100%" cellspacing="1" cellpadding="2">
				<tr>
					<td width="150">Name</td>
					<td width="400"><input type="text" name="list_name" value="<%=listName%>" size="50" maxlength="255"></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader><b class=sectionheader>Step 2:</b> Select Your File</td>
	</tr>
</table>
<br>

<!---- Step 2 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td width="150">Select Your File</TD>
					<td width="400"><input type="file" name="recipient_file" size="30"<%=((!bCanWrite)?" disabled":"")%>></td>
				</tr>
			</table>
			<br>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td>This file can only contain a list of  <%= (!listTypeID.equals("5")?"Email Addresses":"Fingerprints ( "+sFingerSeq+" )") %> </td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</FORM>	
</BODY>
</HTML>
