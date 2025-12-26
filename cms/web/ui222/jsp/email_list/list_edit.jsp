<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		java.util.*,java.sql.*,
		java.net.*,org.apache.log4j.*"
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
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String listID = request.getParameter("listID");
if (!can.bWrite && listID == null)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// === === ===

ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null; 

String sSql = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("list_edit.jsp");
	stmt = conn.createStatement();

	int maxSize = 40;
	int listSize = 0;
	String listTypeID = "2", listType = "QA Test";
	String listName = "";
	String listStatusID = String.valueOf(EmailListStatus.ACTIVE);

	if( listID == null )
	{
		listName = "New list";
		listTypeID = request.getParameter("typeID");
		if (listTypeID == null) listTypeID = "2";
	}
	else
	{
		sSql =
			" SELECT list_name, type_id, status_id" +
			" FROM cque_email_list" +
			" WHERE cust_id = "+cust.s_cust_id+
			" AND list_id = "+listID;

		rs = stmt.executeQuery(sSql);
		if( rs.next() )
		{
			listName = new String(rs.getBytes(1),"UTF-8");
			listTypeID = rs.getString(2);
			listStatusID = rs.getString(3);
		}
		rs.close();

		// === === ===

		sSql =
			" SELECT count(*) FROM cque_email_list_item" +
			" WHERE list_id = "+listID;

		rs = stmt.executeQuery(sSql);
		if (rs.next()) listSize = rs.getInt(1);
		rs.close();
	}

	boolean isDisabled = ((listSize > maxSize) && (("1".equals(listTypeID)) || ("3".equals(listTypeID))));

	String sFingerSeq = "";
	if (listTypeID.equals("1")) listType = "Global Exclusion";
	else if (listTypeID.equals("3")) listType = "Exclusion";
	else if (listTypeID.equals("4") || listTypeID.equals("6")) listType = "Auto-Respond Notification";
	else if (listTypeID.equals("5"))
	{ 
		listType = "Specified Test Recipient";

		sSql = 
			" SELECT isnull(ca.display_name,a.attr_name)" +
			" FROM ccps_attribute a, ccps_cust_attr ca" +
			" WHERE ca.cust_id = " + cust.s_cust_id +
			" AND ca.fingerprint_seq IS NOT NULL" +
			" AND a.attr_id = ca.attr_id" +
			" ORDER BY ca.fingerprint_seq";
			
		rs = stmt.executeQuery(sSql);
		while (rs.next()) sFingerSeq += ((sFingerSeq.length() > 0)?" + ":"")+rs.getString(1);
		rs.close();
	}
	else if (listTypeID.equals("7")) listType = "Dynamic Content";
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
<!--

function validateFields()
{
	var message = 'Please enter ' + "<%= listType %>" + ' list Name';
	var fieldValue = FT.name.value;
	// replace the places
	fieldValue = fieldValue.replace( /^\s+/g,'').replace(/\s+$/g,''); 
	if(fieldValue.length==0)
	{
		alert(message);
		return false;
	}
	return true;
}	


function setHiddenFields()
{
	var emails;
	var types;
	var i = 0;
	var x = 0;
	var createHidden = "";

	if(!validateFields())
		return;
	emails = document.getElementsByName("email_addr");
	
	for (i = 0; i < emails.length; i++)
	{
		if (emails[i].value != "")
		{
		<% if (listTypeID.equals("3")) { %>
			createHidden += "<input type=hidden name=f" + x + " value=" + emails[i].value + ">";
			createHidden += "<input type=hidden name=t" + x + " value=1>";
			x++;
		<% } else { %>
			types = document.getElementsByName("type" + i);
			
			if (types[0].checked == true)
			{
				createHidden += "<input type=hidden name=f" + x + " value=" + emails[i].value + ">";
				createHidden += "<input type=hidden name=t" + x + " value=" + types[0].value + ">";
				x++;
			}
			
			if (types[1].checked == true)
			{
				createHidden += "<input type=hidden name=f" + x + " value=" + emails[i].value + ">";
				createHidden += "<input type=hidden name=t" + x + " value=" + types[1].value + ">";
				x++;
			}
			
			if (types[2].checked == true)
			{
				createHidden += "<input type=hidden name=f" + x + " value=" + emails[i].value + ">";
				createHidden += "<input type=hidden name=t" + x + " value=" + types[2].value + ">";
				x++;
			}
			
			if (types[3].checked == true)
			{
				createHidden += "<input type=hidden name=f" + x + " value=" + emails[i].value + ">";
				createHidden += "<input type=hidden name=t" + x + " value=" + types[3].value + ">";
				x++;
			}
		<% } %>
		}
	}
	
	document.getElementById("insertHidden").innerHTML = createHidden;
	FT.submit();
}

function setChecks(ord)
{
	var emails;
	var i = 0;
	
	emails = document.getElementsByName("email_addr");
	
	for (i = 0; i < emails.length; i++)
	{
		if (emails[i].value != "")
		{
			document.getElementsByName("type" + i)[ord].checked = true;
		}
	}
}

function disable_forms()
{
	var l = document.forms.length;
	for(var i=0; i < l; i++)
	{
		document.forms[i].action = null;
		var m = document.forms[i].elements.length;
		for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = true;
	}
}

//-->
</script>
</HEAD>

<BODY<%=(!can.bWrite || isDisabled)?" onload='disable_forms()'":""%>>

<% if(can.bWrite && !isDisabled) { %>

	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="javascript:setHiddenFields();">Save</a>
			</td>
			
	<% if (listID != null) { %>
	
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="FT.listID.value=''; FT.clone.value='true';setHiddenFields();">Clone</a> 		
			</td>

	<% } %>
	<% if (can.bDelete && listID != null) { %>

			<td align="left" valign="middle">
				<a class="deletebutton" href="#" onClick="if( confirm('Are you sure?') ) location.href='list_delete.jsp?typeID=<%= listTypeID %>&listID=<%= listID %>'">Delete</a>	
			</td>

	<% } %>

		</tr>
	</table>
	<br>

<% } %>

<FORM  METHOD="POST" NAME="FT" ACTION="list_save.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="listID" VALUE="<%= HtmlUtil.escape(listID) %>">
<INPUT TYPE="hidden" NAME="status_id" VALUE="<%= HtmlUtil.escape(listStatusID) %>">

<% if (!listTypeID.equals("4") && !listTypeID.equals("6")) { %>
<INPUT TYPE="hidden" NAME="type" VALUE="<%= HtmlUtil.escape(listTypeID) %>">
<% } %>

<INPUT TYPE="hidden" NAME="clone" VALUE="false">

<!--- Step 1 Header----->

<table width=475 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader >&nbsp;<b class=sectionheader>Step 1:</b> Name your <%= listType %> List</td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=475 border="0">
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=475><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=475><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; PADDING-TOP: 5px" valign=top align=center width=475>
			<table class=main cellspacing=1 cellpadding=1 width="450">
				<TR>
					<TD WIDTH="150">Name</TD>
					<TD WIDTH="300"><INPUT TYPE="text" NAME="name"	VALUE="<%=HtmlUtil.escape(listName)%>" SIZE="50" MAXLENGTH="50"></TD>
				</TR>
<% if (listTypeID.equals("4") || listTypeID.equals("6")) { %>
				<TR>
					<TD WIDTH="150">List Type</TD>
					<TD WIDTH="300">
						<SELECT NAME=type SIZE=1>
							<OPTION VALUE=4 <%=listTypeID.equals("4")?"selected":""%>>One email on list chosen at random for each subscriber</OPTION>
							<OPTION VALUE=6 <%=listTypeID.equals("6")?"selected":""%>>Everyone on list is sent to for each subscriber</OPTION>
						</SELECT>
					</TD>
				</TR>
<% } %>
			</table>
		</td>
	</tr>
	</tbody>
</table>

<br><br>
<table width=475 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader >&nbsp;<b class=sectionheader>Step 2:</b> Enter <%= listType %> <%= (!listTypeID.equals("5")?"Email Addresses":"Fingerprints ( "+sFingerSeq+" )") %></td>
	</tr>
</table>
<br>
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=475 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=475><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=475><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab style="PADDING-RIGHT: 5px; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; PADDING-TOP: 5px" valign=top align=center width=475>
			<%=(isDisabled)?"First "+maxSize+" entries shown. Click <a href=\"list_view.jsp?list_id="+listID+"\">here</a> to view full list.<BR>":""%>
			<table class="listTable" cellspacing="0" cellpadding="2" width="450">
				<tr>
					<th><%= (!listTypeID.equals("5")?"Email":"Fingerprint") %></th>
<%= ((!listTypeID.equals("3"))?"<th style=\"cursor:hand;\" title=\"Check All\" onclick=\"setChecks(0);\">HTML</th><th style=\"cursor:hand;\" title=\"Check All\" onclick=\"setChecks(1);\">Text</th><th style=\"cursor:hand;\" title=\"Check All\" onclick=\"setChecks(2);\">Multipart</th><th style=\"cursor:hand;display:none;\" title=\"Check All\" onclick=\"setChecks(3);\">AOL</th>":"") %>
				</tr>
<%
String sClassAppend = "";
				
for( int i = 0; i < maxSize; ++i )
{
	if (i % 2 != 0) sClassAppend = "_Alt";
	else sClassAppend = "";
%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><INPUT TYPE="text" NAME="email_addr" id="email_addr" VALUE="" SIZE="50"></TD>
					<td class="listItem_Data<%= sClassAppend %>"<%= ((listTypeID.equals("3"))?" style=\"display:none\"":"") %> align="center" valign="middle"><input type="checkbox" name="type<%=i%>" value="1" id="type<%=i%>"></TD>
					<td class="listItem_Data<%= sClassAppend %>"<%= ((listTypeID.equals("3"))?" style=\"display:none\"":"") %> align="center" valign="middle"><input type="checkbox" name="type<%=i%>" value="2" id="type<%=i%>"></TD>
					<td class="listItem_Data<%= sClassAppend %>"<%= ((listTypeID.equals("3"))?" style=\"display:none\"":"") %> align="center" valign="middle"><input type="checkbox" name="type<%=i%>" value="3" id="type<%=i%>"></TD>
					<td class="listItem_Data<%= sClassAppend %>" style="display:none;" align="center" valign="middle"><input type="checkbox" name="type<%=i%>" value="4" id="type<%=i%>"></TD>
				</tr>
<%
}
%>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<div id="insertHidden"></div>
<SCRIPT>
<%	
	String	dic = "";	
  	rs = stmt.executeQuery("SELECT email_type_id, email_type_name FROM ccps_email_type WHERE email_type_id <> 0");
	while(rs.next())
	{
		dic += ((dic.length() > 0 ) ? "," : "") + rs.getString(1) + ", '" + rs.getString(2) + "'";
	}
	rs.close();
%>

var emailAddress = document.getElementsByName("email_addr");
var typeIDs;

<%
int i = -1;
int x = 0;
	  	
sSql = "EXEC usp_cque_email_list_get " + listID;
rs = stmt.executeQuery(sSql);

String rowEmail = "";
int icountHTML = 0;
int icountText = 0;
int icountMulti = 0;
int icountAOL = 0;
int imaxCount = 0;

byte[] b = null;

while(rs.next())
{ 	
	b = rs.getBytes(2);
	rowEmail = ((b==null)?null:new String(b,"UTF-8"));
	icountHTML = rs.getInt(3);
	icountText = rs.getInt(4);
	icountMulti = rs.getInt(5);
	icountAOL = rs.getInt(6);
	
	imaxCount = icountHTML;
	
	if (icountText > imaxCount) imaxCount = icountText;
	if (icountMulti > imaxCount) imaxCount = icountMulti;
	if (icountAOL > imaxCount) imaxCount = icountAOL;
	
	for (x = 0; x < imaxCount; x++)
	{
		i++;
%>
		if (emailAddress[<%= i %>] != window.undefined)
		{
			emailAddress[<%= i %>].value = "<%= rowEmail %>";
			typeIDs = document.getElementsByName("type<%= i %>");
<%
		if ((icountHTML - 1) >= x)
		{
%>
			typeIDs[0].checked = true;
<%
		}
		if ((icountText - 1) >= x)
		{
%>
			typeIDs[1].checked = true;
<%
		}
		if ((icountMulti - 1) >= x)
		{
%>
			typeIDs[2].checked = true;
<%
		}
		if ((icountAOL - 1) >= x)
		{
%>
			typeIDs[3].checked = true;
<%
		}
%>
		}
<%
	}
}
rs.close();
%>

<!-- %@ include file="../../js/scripts.js" % -->

</SCRIPT>
</FORM>
<BR><BR>
</BODY>
</HTML>
<%
} catch(Exception ex) { 
	ErrLog.put(this,ex,"list_edit.jsp",out,1);
} finally {
	if (stmt != null) stmt.close();
	if (conn != null ) cp.free(conn); 
}
%>
