<%@ page 
	language="java"
	import="org.apache.log4j.*"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<jsp:useBean id="tbean" class="com.britemoon.cps.ctm.TemplateBean" scope="session" />
<% 
BNetPageBean pbean = (BNetPageBean)session.getAttribute("pbean");

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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Edit <%= tbean.getSectionLabel(section) %></title>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="../default.css" TYPE="text/css">
	<script type="text/javascript" src="/cms/ui/js/CKEditor/ckeditor.js"></script>
	<SCRIPT LANGUAGE="Javascript" SRC="../../../js/AnchorPosition.js"></SCRIPT>
	<SCRIPT LANGUAGE="Javascript" SRC="../../../js/PopupWindow.js"></SCRIPT>
	<SCRIPT LANGUAGE="Javascript" SRC="../../../js/ColorPicker.js"></SCRIPT>

	<SCRIPT LANGUAGE="JavaScript">
	// Runs when a color is clicked
	function pickColor(color) 
    {
		field.value = color;
	}

	var field;
	</SCRIPT>
	
</head>
<body style="margin:0;background-color:#FFFFFF">
		
<a href="selecttemplate.jsp" class="zbuttons zbuttons-normal zbuttons-black mta5">
	<span class="zicon zicon-white zicon-return"></span>
	<span class="zlabel">Şablonlara Geri Dön</span>
</a>

<a href="pageedit.jsp?isEdit=true<%=sContentParm%><%=sTemplateParm%>" class="zbuttons zbuttons-normal zbuttons-light-gray">
	<span class="zicon zicon-black zicon-edit"></span>
	<span class="zlabel">Şablonu Düzenle</span>
</a>
		
<a href="#" onclick="javascript:document.forms['FT'].submit();" class="zbuttons zbuttons-normal zbuttons-green mta5">
	<span class="zicon zicon-white zicon-save"></span>
	<span class="zlabel">Şablonu Kaydet</span>
</a>

<form method="POST" name="FT" action="sectionedit2.jsp" enctype="multipart/form-data">
<input type="hidden" name="section" value="<%= section %>">


<table class="section-table" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td colspan="2"><b><%= tbean.getSectionLabel(section) %></b></td>
	</tr>
	<%= pbean.createSectionForm(section, application.getInitParameter("ImageURL")) %>
</table>
		
</form>
<script type="text/javascript">
//<![CDATA[

CKEDITOR.replaceAll(function( textarea, config )
{
		config.fullPage = false,
		config.height = '200',
		config.autoParagraph  = false,
		config.theme = 'default',
		config.uiColor = '#F4F4F4',
		//config.docType  = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
        config.filebrowserUploadUrl = 'upload.jsp',
		config.filebrowserBrowseUrl = 'browse.jsp',
		config.filebrowserWindowWidth = '500',
        config.filebrowserWindowHeight = '350',
		config.toolbar =
		[
			['Source','Preview','Templates'],	
			['Undo','Redo','Cut','Copy','Paste','PasteText','PasteFromWord','RemoveFormat'],
			['Image','Table','HorizontalRule','SpecialChar', 'Link','Unlink'],	
			'/',
			[ 'Bold','Italic','Underline','Strike','Outdent','Indent','NumberedList','BulletedList','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','TextColor','BGColor','Format','Font','FontSize'],
		];



});

//]]>
</script>
</body>
</html>