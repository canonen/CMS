<%@ page
	language="java"
	import="com.oreilly.servlet.multipart.*,
			com.oreilly.servlet.multipart.Part,
			com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.io.*,java.util.*,
			java.sql.*,javax.servlet.http.*,
			javax.servlet.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}


String sCategories = BriteRequest.getParameter(request,"categorytemp");
String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");

String sImageId = BriteRequest.getParameter(request,"image_id");

String sAccessCusts = BriteRequest.getParameter(request,"access_map");
String[] sAccessMap = sAccessCusts.split(";");

if (sImageId == null || sImageId.length() == 0 || sImageId.equals("null"))
	throw new Exception("No Image ID parameter found...cannot save");

ImageHostUtil.setImageAccess (cust.s_cust_id, sImageId, sAccessMap);

%>
<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Image:</b> Saved</td>
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
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b>The access rights were saved.</b>
						<br><br>
						<a href="image_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a>
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
<%


%>