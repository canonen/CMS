<%@ page 
	language="java"
	import="org.apache.log4j.*"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbean" class="com.britemoon.cps.ctm.TemplateBean" scope="session" />
<% 
PageBean pbean = (PageBean)session.getAttribute("pbean");

int section = (new Integer(request.getParameter("section"))).intValue();

String sContentParm = "";
String sTemplateParm = "";
if (pbean.getContentID() != 0) {
     sContentParm = "&contentID=" + pbean.getContentID();
}
if (tbean.getTemplateID() != 0) {
     sTemplateParm = "&templateID=" + tbean.getTemplateID();
}

%>

<%-- Create the form --%>
<html>
<head>
<title>Edit <%= tbean.getSectionLabel(section) %></title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">

	<SCRIPT LANGUAGE="Javascript" SRC="../../js/AnchorPosition.js"></SCRIPT>
	<SCRIPT LANGUAGE="Javascript" SRC="../../js/PopupWindow.js"></SCRIPT>
	<SCRIPT LANGUAGE="Javascript" SRC="../../js/ColorPicker.js"></SCRIPT>

	<SCRIPT LANGUAGE="JavaScript">
	// Runs when a color is clicked
	function pickColor(color) 
    {
		field.value = color;
	}

	var field;
	</SCRIPT>
    <script>_editor_url = "../../js/editor/"; </script>
    <script language="Javascript1.2" SRC="../../js/editor/editor_ctm.js"></script>
	<script language="Javascript1.2">
       function window.onload()
       {
           initEditorInputHooks();
       }
       function initEditorInputHooks() 
       {
               <%= pbean.createSectionFormHtmlEditorHooks(section) %>
       }
    </script>
</head>
<body>
<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle"><a class="savebutton" href="javascript:FT.submit();">Save</a>&nbsp;&nbsp;&nbsp;</td>
		<td nowrap align="left" valign="middle"><a class="subactionbutton" href="pageedit.jsp?isEdit=true<%=sContentParm%><%=sTemplateParm%>">< Return to Edit Template</a>&nbsp;&nbsp;&nbsp;</td>
		<td nowrap valign="middle" align="right" width="100%"><a class="subactionbutton" href="index.jsp"><< Return to Templates</a></td>
	</tr>
</table>
<br>
<form method="POST" name="FT" action="sectionedit2.jsp" enctype="multipart/form-data">
<input type="hidden" name="section" value="<%= section %>">
<table cellpadding="0" cellspacing="0" class="main" width="90%">
	<tr>
		<td class="sectionheader"><b class="sectionheader"><%= tbean.getSectionLabel(section) %></b>&nbsp;</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="90%" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTab">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<%= pbean.createSectionForm(section, application.getInitParameter("ImageURL")) %>
			</table>
		</td>
	</tr>
</table>
<br><br>
</form>
</body>
</html>