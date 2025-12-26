<%@ page contentType="text/html;charset=UTF-8" 
		 import="java.util.*"
		 import="java.io.*"
		 import="com.oreilly.servlet.multipart.*"
 		 import="com.britemoon.*"
 		 import="com.britemoon.cps.*"
 		 import="com.britemoon.cps.ctm.*"
		 import="org.apache.log4j.*" 
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%-- Get the uploaded files and the params --%>
<%

byte[] buf = new byte[1024*5]; //5K buffer
InputStream in;

//Have a 1 Meg limit
MultipartParser mp = new MultipartParser(request, 1000000);

//Parts will arrive in the following order:
//templateID, templateName, approval_checkbox(always set to 1), approvalFlag, category, htmlFile, txtFile, large_image, small_image
Part myPart = mp.readNextPart();
int templateID = Integer.parseInt(((ParamPart)myPart).getStringValue());
logger.info("template id = " + templateID);

myPart = mp.readNextPart();
String templateName = ((ParamPart)myPart).getStringValue();
logger.info("template name = " + templateName);

myPart = mp.readNextPart();
String category = ((ParamPart)myPart).getStringValue();
logger.info("category = " + category);

boolean isParent = false;
myPart = mp.readNextPart();
String sParent = ((ParamPart)myPart).getStringValue();
if (sParent != null && sParent.equals("true")) {
	isParent = true;
}
logger.info("parent = " + sParent);

myPart = mp.readNextPart();
String sCustID = ((ParamPart)myPart).getStringValue();
if (sCustID == null || sCustID.length() == 0) sCustID = "0";
logger.info("cust id = " + sCustID);

myPart = mp.readNextPart();
String sChildList = ((ParamPart)myPart).getStringValue();
if (sChildList == null || sChildList.length() == 0) sChildList = null;
logger.info("child list = " + sChildList);

myPart = mp.readNextPart();
String sApprovalFlag = ((ParamPart)myPart).getStringValue();
if (sApprovalFlag == null || sApprovalFlag.length() == 0) sApprovalFlag = "0";
logger.info("approval flag = " + sApprovalFlag);

//Templates Files
String[] templates = new String[2];
for (int x=0;x<2;++x) {
	templates[x] = "";
	myPart = mp.readNextPart();
	in = ((FilePart)myPart).getInputStream();
	while (in.read(buf) != -1) {		
		templates[x] += new String(buf,"UTF-8");
		//Clear out buf
		buf = new byte[1024*5];
	}
	//Remove white spaces at the end of the template
	templates[x] = templates[x].trim();
	in.close();
}

//Image File

File f;
String validExtensions = application.getInitParameter("ValidImageExtensions");
String[] fileName = new String[2];
for (int x=0;x<2;x++) {
	myPart = mp.readNextPart();
	fileName[x] = ((FilePart)myPart).getFileName();
	long fileLength;
	if (fileName[x] != null) {
		fileName[x] = fileName[x].toLowerCase();
		if (validExtensions.indexOf(fileName[x].substring(fileName[x].lastIndexOf(".")+1)) == -1) {
			//not a valid image extension
			%> Bad Image Extension <%
			return;
		} else {
			//write image to images directory
			f = new File(application.getInitParameter("ImagePath")+"templates\\"+fileName[x]);
			fileLength = ((FilePart)myPart).writeTo(f);			
			if (fileLength == 0) {
				//remove the file
				f.delete();
				//return an error
				%> Bad Image File: image file size is 0 <%
				return;
			}
		}
	} else {
		fileName[x] = "";
	}
}

String errmsg = "";
//Make sure none of them are empty
if (templateName.length() == 0) errmsg += "<li>No value for the Master Template's Name\n";
if (category.equals("0"))       errmsg += "<li>Please select a category for your Master Template\n";
if (templates[0].length() == 0) errmsg += "<li>Bad file for the HTML Master Template File\n";
if (templates[1].length() == 0) errmsg += "<li>Bad file for the Text Master Template File\n";
if (fileName[0].length() == 0)  errmsg += "<li>No value for the small image\n";
if (fileName[1].length() == 0)  errmsg += "<li>No value for the large image\n";

if (errmsg.length() != 0) {
	%>
<html>
<head>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height="2" src="../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%" colspan="2"><img height="2" src="../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTab">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="top" style="padding:10px;">
						<p><b>There was a problem when uploading the Master Template</b></p>
						<ul>
						<%= errmsg %>
						</ul>
						<p><a class="subactionbutton" href="templatenew.jsp<%=(isParent?"?parent=true":"")%>">< Return to Edit</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
	<%
	return;
}

//Create new TemplateBean
TemplateBean tbean = new TemplateBean(templateID, Integer.parseInt(sCustID), templateName, category, fileName, templates);
if (sChildList != null) {
	if (sChildList.equals("0")) {
		tbean.setGlobal(true);
	}
	else {
		tbean.addChildCustList(sChildList);
	}
}
if (sApprovalFlag != null && sApprovalFlag.equals("1")) {
	tbean.setApproval(true);
}
errmsg = tbean.parseTemplate();

%>

<html>
<head>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body>
<%
request.getInputStream().readLine(buf,0,100000);
String str = new String(buf, "UTF-8");
%>
<%= str %>

<% if (!errmsg.equals("ok")) { %>
<%-- Bad template file --%>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height="2" src="../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%" colspan="2"><img height="2" src="../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTab">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="top" style="padding:10px;">
						<p><b>There was a problem when uploading the Master Template</b></p>
						<p>The apparent error is: <font color=#223399 size=+1><%= errmsg %></font></p>
						<p>Please back up your browser, fix the master template, and reupload the master template.</p>
						<p>This is what was uploaded:<br>
						<blockquote>
						<textarea cols=80 rows=20 wrap=off><%= templates[0] %></textarea>
						</blockquote>
						</p>
						<!--
						If this is not the error, some common problems you should check are:
						<ul>
						<li>Bad numbering: (i.e. bminput1:2 when you ment bminput1:4)<br>
						    If the numbers are mixed up this will make the parser very confused.
						<li>Typos in the tags.
						</ul>
						-->
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<% } else {
//Save tbean in the session - next page will save it in the application scope
session.setAttribute("newtbean",tbean);
%>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onClick="FT.submit();">Confirm &amp; Save</a>
		</td>
	</tr>
</table>
<br>
<%-- Show them the values parsed and ask if the master template looks like what they expected --%>
<form name="FT" method="POST" action="templatenew3.jsp">
<input type="hidden" name="parent" value="<%=(isParent?"true":"false")%>">

<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height="2" src="../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%" colspan="2"><img height="2" src="../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTab">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="top" style="padding:10px;">
						<p>Confirm below that the uploaded Master Template appears correct.</p>
						<p>Then click Confirm &amp; Save above to save the new master template.</p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>

<table cellpadding="0" cellspacing="0" class="main" width="650">
	<tr>
		<td class="sectionheader">Master Template Info</td>
	</tr>
</table>
<br>
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=2><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="100">Name: </td>
					<td><%= templateName %></td>
				</tr>
				<tr>
					<td width="100">Category: </td>
					<td><%= category %></td>
				</tr>
				<tr>
					<td width="100">Customer ID: </td>
					<td><%= sCustID %></td>
				</tr>
				<tr>
					<td width="100">Requires Approval: </td>
					<td><%=((sApprovalFlag!=null&&sApprovalFlag.equals("1"))?"Yes":"No")%></td>
				</tr>				
				<tr>
					<td width="100">Replication: </td>
					<td><%=((sChildList!=null&&sChildList.equals("0"))?"Global":"Selected Child Customer")%></td>
				</tr>
				<tr>
					<td width="100">Child Customer ID: </td>
					<td><%=((sChildList!=null&&!sChildList.equals("0"))?sChildList:"")%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>

<table cellpadding="0" cellspacing="0" class="main" width="650">
	<tr>
		<td class="sectionheader">Uploaded File Info</td>
	</tr>
</table>
<br>
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=2><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="100">Structure: </td>
					<td><%= tbean.prettyOutput() %></td>
				</tr>
				<tr>
					<td width="100">HTML: </td>
					<td><textarea rows="15" cols="80" wrap="off" style="width:100%;"><%= tbean.getTemplate("html") %></textarea></td>
				</tr>
				<tr>
					<td width="100">Text: </td>
					<td><textarea rows="15" cols="80" wrap="off" style="width:100%;"><%= tbean.getTemplate("txt") %></textarea></td>
				</tr>
				<tr>
					<td width="100">Small Image: </td>
					<td><img src="/cctm/ui/images/templates/<%= fileName[0] %>"></td>
				</tr>
				<tr>
					<td width="100">Large Image: </td>
					<td><img src="/cctm/ui/images/templates/<%= fileName[1] %>"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>
</form>

<% } %>
</body>
</html>

