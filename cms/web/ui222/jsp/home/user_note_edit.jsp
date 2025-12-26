<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.hom.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
			org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.USER_NOTES);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// === === ===

AccessPermission admCan = user.getAccessPermission(ObjectType.USER);
boolean isAdmin = admCan.bWrite;
boolean isMine = false;

// === === ===

String sNoteId = request.getParameter("note_id");
String sAction = request.getParameter("action");
String sSubject = request.getParameter("subject");
String sBody = request.getParameter("body");

UserNote note = new UserNote();

if (sAction != null)
{
	note.s_cust_id = cust.s_cust_id;
	note.s_user_id = user.s_user_id;
	note.s_note_id = sNoteId;
	note.s_subject = sSubject;
	// reformat space character so that it can be properly displayed
	char data[] = {194,160};
	String rep = new String(data);
	sBody = sBody.replaceAll(rep, "&nbsp;");
	note.s_body = sBody;
	note.s_admin = "0";	
	isMine = true;
	if (sAction.equals("save"))
	{
		note.s_published = "0";
		note.save();
		int rc = note.retrieve();
	}
	else if (sAction.equals("delete"))
	{
		note.delete();
%>
<html>
	<head>
		<script language="javascript">
			location.href = "user_note_list.jsp";
		</script>
	</head>
	<body></body>
</html>
<%
		return;

	}
	else if (sAction.equals("setdraft"))
	{
		note.s_published = "0";
		note.save();
%>
<html>
	<head>
		<script language="javascript">
			location.href = "user_note_edit.jsp?note_id=<%= sNoteId %>";
		</script>
	</head>
	<body></body>
</html>
<%
		return;
	}
	else if (sAction.equals("publish"))
	{
		note.s_published = "1";
		note.save();
%>
<html>
	<head>
		<script language="javascript">
			location.href = "user_note_edit.jsp?note_id=<%= sNoteId %>";
		</script>
	</head>
	<body></body>
</html>
<%
		return;
	}
}
else
{
	if (sNoteId != null)
	{
		note.s_note_id = sNoteId;
		int nRetrieve = note.retrieve();
		if ((nRetrieve > 0) && !(cust.s_cust_id.equals(note.s_cust_id))) note = new UserNote();
		if (note.s_user_id.equals(user.s_user_id))
		{
			isMine = true;
		}
	}
	else
	{
		note.s_cust_id = cust.s_cust_id;
		note.s_user_id = user.s_user_id;
		note.s_user_name = user.s_user_name; 
		java.util.Date d = new java.util.Date();
		SimpleDateFormat formatter = null;
		formatter = new SimpleDateFormat("MMM d yyyy hh:mm a");
		String dateStamp = new String(formatter.format(d));	
		note.s_modify_date = dateStamp;
		note.s_admin = "0";
		note.s_published = "0";
		isMine = true;
	}
}

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="Javascript1.2">
		<!-- // load htmlarea
        _editor_url = "/cms/ui/js/editor/"; // URL to htmlarea files
        var win_ie_ver = parseFloat(navigator.appVersion.split("MSIE")[1]);
        if (navigator.userAgent.indexOf('Mac')        >= 0) { win_ie_ver = 0; }
        if (navigator.userAgent.indexOf('Windows CE') >= 0) { win_ie_ver = 0; }
        if (navigator.userAgent.indexOf('Opera')      >= 0) { win_ie_ver = 0; }
        if (win_ie_ver >= 5.5)
		{
            document.write('<script src="' +_editor_url+ 'editor.js"');
            document.write(' language="Javascript1.2"></script>');  
        } 
        else
		{ 
            document.write('<script>function editor_generate() { return false; }</script>'); 
        }// -->
	</script>
	<script language="Javascript">
		
		function saveNote()
		{
			if (FT.subject.value == null || FT.subject.value == "")
			{
				alert("Please enter a subject for the message");
				return;
			}
			
			FT.action.value = "save";
			FT.submit();
		}
		
		function publishNote()
		{
			if (FT.note_id.value == null || FT.note_id.value == "")
			{
				alert("Please save before publishing");
				return;
			}
			
			if ( confirm('Are you sure?') )
			{
				FT.action.value = "publish";
				FT.submit();
			}
		}
		
		function setDraft()
		{
			if (FT.note_id.value == null || FT.note_id.value == "")
			{
				alert("Please save before publishing");
				return;
			}
			
			if ( confirm('Are you sure?') )
			{
				FT.action.value = "setdraft";
				FT.submit();
			}
		}
				
		function deleteNote()
		{
			if ( confirm('Are you sure?') )
			{
				FT.action.value = "delete";
				FT.submit();
			}
		}		
	</script>
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="user_note_edit.jsp" TARGET="_self">
<%
if (isAdmin || can.bRead || can.bWrite || can.bDelete)
{
%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
<% if (note.s_published.equals("0") && (isAdmin || (isMine && can.bWrite)) ) { %>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onclick="saveNote();">Save</a>
			</td>
<% } %>
<% if (note.s_published.equals("0") && (isAdmin || (isMine && can.bWrite)) ) { %>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onclick="publishNote();">Publish</a>
			</td>
<% } %>
<% if (note.s_published.equals("1") && (isAdmin || (isMine && can.bWrite)) ) { %>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onclick="setDraft();">Set As Draft</a>
			</td>
<% } %>
<% if (isAdmin || (isMine && can.bDelete)) { %>
			<td align="left" valign="middle">
				<a class="deletebutton" href="#" onclick="deleteNote();">Delete</a>
			</td>
<% } %>
		</tr>
	</table>
	<br>
	<input type=hidden name="action" value="save">
	<input type=hidden name="note_id" value="<%=(note.s_note_id!=null?note.s_note_id:"")%>">
	<!--- Step 1 Header----->
	<TABLE cellpadding="0" cellspacing="0" class="main" width="650">
		<TR>
			<TD class="sectionheader"><B class="sectionheader">Step 1:</B> Edit User Note</TD>
		</TR>
	</TABLE>
	<br>
	<!--- Step 1 Info----->
	<table cellspacing=0 cellpadding=0 width=650 border=0>
		<tr>
			<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tr>
			<td class=fillTabbuffer valign=top align=left width=100% colspan=2><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tr>
			<td class=fillTab>
				<table width=100% class=main border="0" cellspacing="1" cellpadding="2">
					<tr>
						<td width="150" align="left" valign="middle">From</td>
						<td align="left" valign="middle"><%=note.s_user_name%></td>
					</tr>
					<tr>
						<td width="150" align="left" valign="middle">Date</td>
						<td align="left" valign="middle"><%=note.s_modify_date%></td>
					</tr>
					<tr>
						<td width="150" align="left" valign="middle">Subject</td>
						<td align="left" valign="middle"><input type=text name="subject" value="<%=(note.s_subject!=null?note.s_subject:"")%>" size=100></td>
					</tr>
					<tr>
						<td colspan="2" align="left" valign="middle">&nbsp;</td>
					</tr>
					<tr>
						<td colspan="2" align="left" valign="middle">
							<script language="JavaScript1.2" defer>editor_generate('body');</script>
							<textarea rows=18 cols=75 name="body"><%=(note.s_body!=null?note.s_body:"")%></textarea>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br><br>
<%
}
%>
</FORM>
</BODY>
</HTML>