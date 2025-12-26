<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,java.io.*,
			java.text.DateFormat,org.apache.log4j.*"
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

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
String sCampId = BriteRequest.getParameter(request,"camp_id");
String [] sCategories = BriteRequest.getParameterValues(request,"categories");

%>

<%
// === Save Main Campaign ===

//"save";"clone";"clone2destination"; "send_test";"send_camp";
String MODE = "save";
CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CAMPAIGN, sCampId, request);
 
// === === ===

String actionText = "saved";


%>
<HTML>
<!-- <%=MODE%> -->
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Campaign:</b> <%=(MODE.equals("clone"))?"Cloned":"Saved"%></td>
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
			<table class=main cellspacing=1 cellpadding=2 width="650">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p>The campaign categories were <%= actionText %>.</p>
						<p align="center">
							<%
							String sHref = "camp_list.jsp";
							
								%>
								<a href="<%=sHref%>">Back to List</a>
								
							
						</p>
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

<%@ include file="camp_save_functions.inc"%>

