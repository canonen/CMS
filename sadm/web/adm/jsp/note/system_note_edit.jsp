<%@ page
	language="java"
	import="com.britemoon.*,com.britemoon.sas.*,java.util.*,java.sql.*,java.net.*,java.text.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>

<%
String sNoteId = request.getParameter("note_id");
String sAction = request.getParameter("action");
String sSubject = request.getParameter("subject");
String sBody = request.getParameter("body");

SystemNote note = new SystemNote();

if (sAction != null) {
	note.s_note_id = sNoteId;
	
	
	sSubject = ((sSubject!=null) && (sSubject.trim().length()>0))?new String(sSubject.getBytes("ISO-8859-1"), "UTF-8"):null;
	note.s_subject = sSubject;
	
	
	
	
    // reformat space character so that it can be properly displayed
    char data[] = {194,160};
    String rep = new String(data);
	sBody = sBody.replaceAll(rep, "&nbsp;");
	sBody = ((sBody!=null) && (sBody.trim().length()>0))?new String(sBody.getBytes("ISO-8859-1"), "UTF-8"):null;
	note.s_body = sBody;
	if (sAction.equals("save")) {
		note.s_published = "0";
		note.save();
		int rc = note.retrieve();
	}
	else if (sAction.equals("delete")) {
		note.delete();
        %>        
          <html>
             <script>
                 parent.frames("left_01").location.href = "system_note_list.jsp";
                 parent.frames("main_01").location.href = "../w_left.jsp";
             </script>
          </html>
        <%
        return;
        
	}
	else if (sAction.equals("setdraft")) {
		note.s_published = "0";
		note.save();
        %>        
          <html>
             <script>
					parent.frames("left_01").location.href = "system_note_list.jsp";
					parent.frames("main_01").location.href = "system_note_edit.jsp?note_id=<%= sNoteId %>";
             </script>
          </html>
        <%
		return;
	}
	else if (sAction.equals("publish")) {
		note.s_published = "1";
		note.save();
        %>        
          <html>
             <script>
					parent.frames("left_01").location.href = "system_note_list.jsp";
					parent.frames("main_01").location.href = "system_note_edit.jsp?note_id=<%= sNoteId %>";
             </script>
          </html>
        <%
		return;
	}
}
else {
	if (sNoteId != null) {
		note.s_note_id = sNoteId;
		int nRetrieve = note.retrieve();
	}
	else {
		java.util.Date d = new java.util.Date();
		SimpleDateFormat formatter = null;
		formatter = new SimpleDateFormat("MMM d yyyy hh:mm a");
		String dateStamp = new String(formatter.format(d));	
		note.s_modify_date = dateStamp;
		note.s_published = "0";
	}
}

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
    <script language="Javascript1.2"><!-- // load htmlarea
        _editor_url = "/sadm/ui/js/editor/"; // URL to htmlarea files
        var win_ie_ver = parseFloat(navigator.appVersion.split("MSIE")[1]);
        if (navigator.userAgent.indexOf('Mac')        >= 0) { win_ie_ver = 0; }
        if (navigator.userAgent.indexOf('Windows CE') >= 0) { win_ie_ver = 0; }
        if (navigator.userAgent.indexOf('Opera')      >= 0) { win_ie_ver = 0; }
        if (win_ie_ver >= 5.5) {
            document.write('<script src="' +_editor_url+ 'editor.js"');
            document.write(' language="Javascript1.2"></script>');  
        } 
        else { 
            document.write('<script>function editor_generate() { return false; }</script>'); 
        }// -->
    </script>
    <script language="Javascript">
		function saveNote()
		{
            FT.action.value = "save";
			FT.submit();
		}	
			
		function publishNote()
		{
            if (FT.note_id.value == null || FT.note_id.value == "") {
                alert("Please save before publishing");
                return;
            }
			if ( confirm('Are you sure?') ) {
				FT.action.value = "publish";
				FT.submit();
			}
		}	
		
		function setDraft()
		{
            if (FT.note_id.value == null || FT.note_id.value == "") {
                alert("Please save before publishing");
                return;
            }
			if ( confirm('Are you sure?') ) {
				FT.action.value = "setdraft";
				FT.submit();
			}
		}
			
		function deleteNote()
		{
			if ( confirm('Are you sure?') ) {
				FT.action.value = "delete";
				FT.submit();                
			}
		}	
    	
    	function previewNote()
	    {
            if (FT.note_id.value == null || FT.note_id.value == "") {
                alert("Please save before previewing");
                return;
            }
    		var newWin;
            var url = 'system_note_get.jsp?note_id='+FT.note_id.value;
            var windowName = 'preview_note';
	    	var windowFeatures = 'depedent=yes, scrollbars=yes, resizable=yes, toolbar=no, location=no, menubar=no, height=500, width=650';
    		newWin = window.open(url, windowName, windowFeatures);
	    }
	    	
	</script>
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="system_note_edit.jsp" TARGET="_self">
    <input type=hidden name="action" value="save">
    <input type=hidden name="note_id" value="<%=(note.s_note_id!=null?note.s_note_id:"")%>">
	<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
		<col>
		<tr height="30">
			<td>
				<table cellspacing="0" cellpadding="4" border="0">
					<tr>
						<% if (note.s_published.equals("0") ) { %>
						<td align="left" valign="middle">
							<a class="savebutton" href="javascript:saveNote();">Save</a>
						</td>
						<% } %>
						<% if (note.s_published.equals("0") ) { %>
						<td align="left" valign="middle">
							<a class="savebutton" href="javascript:publishNote();">Publish</a>
						</td>
						<% } %>
						<% if (note.s_published.equals("1") ) { %>
						<td align="left" valign="middle">
							<a class="savebutton" href="#" onclick="setDraft();">Set As Draft</a>
						</td>
						<% } %>
						<td align="left" valign="middle">
							<a class="deletebutton" href="javascript:deleteNote();">Delete</a>
						</td>
						<td align="left" valign="middle">
							<a class="resourcebutton" href="javascript:previewNote();">Preview</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr height="30">
			<td>
				<!--- Step 1 Header----->
				<TABLE cellpadding="0" cellspacing="0" class="main" width="100%">
					<TR>
						<TD class="sectionheader"><B class="sectionheader">Step 1:</B> Edit Admin Note</TD>
					</TR>
				</TABLE>
			</td>
		</tr>
		<tr>
			<td>
				<!--- Step 1 Info----->
				<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
					<col>
					<tr height="2">
						<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
					</tr>
					<tr height="2">
						<td class="fillTabbuffer" valign="top" align="left"><img height="2" src="../../images/blank.gif" width="1"></td>
					</tr>
					<tr>
						<td class="fillTab">
							<table class="main layout" border="0" cellspacing="1" cellpadding="2" style="width:100%; height:100%;">
								<col width="150">
								<col>
								<tr height="25">
									<td align="left" valign="middle">Date</td>
									<td align="left" valign="middle"><%= note.s_modify_date %></td>
								</tr>
								<tr height="25">
									<td align="left" valign="middle">Subject</td>
									<td align="left" valign="middle"><input type=text name="subject" value="<%=(note.s_subject!=null?note.s_subject:"")%>" style="width:100%;"></td>
								</tr>
								<tr>
									<td colspan="2" align="left" valign="middle">
										<script language="JavaScript1.2" defer>editor_generate('body');</script><textarea style="width:100%; height:100%;" rows="18" cols="15" name="body"><%=(note.s_body!=null?note.s_body:"")%></textarea>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</FORM>
</BODY>
</HTML>
