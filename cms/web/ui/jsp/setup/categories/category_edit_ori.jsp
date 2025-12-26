<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.apache.log4j.Logger"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CATEGORY);

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<%
String sCategoryId = request.getParameter("category_id");

Category category = new Category(cust.s_cust_id, sCategoryId);

String sCategoryName = category.s_category_name;
String sCategoryDescrip = category.s_category_descrip;
%>
<HTML>

<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
	<SCRIPT src="../../../js/disable_forms.js"></SCRIPT>
	<script language="javascript">
	function checkBeforeSave()
	{
		var cat_name = document.category.category_name.value;
		if( (cat_name != null) && (cat_name != "") )
		{
			category.action='category_save.jsp'; 
			category.submit();
		}
		else
			alert('Please enter the Category Name');
	}
	</script>	
</HEAD>

<BODY <%=(!can.bWrite)?"onload='disable_forms();'":""%>>
<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="checkBeforeSave();">Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>

<FORM method="POST" action="" target="_self" name="category">
<%
if(sCategoryId != null)
{
	%>
	<INPUT type="hidden" name="category_id" value="<%=sCategoryId%>">
	<!-- IMG STYLE="cursor:hand" SRC="../../../images/deletebutton.gif" onClick="filter_delete();" -->
	<%
}
%>
<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Name your category</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Name</td>
					<td align="left" valign="middle"><INPUT type="text" name="category_name" size="60" value="<%=(sCategoryName==null)?"":sCategoryName%>"></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Describe your category</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Description</td>
					<td align="left" valign="middle"><INPUT type="text" name="category_descrip" size="80" value="<%=(sCategoryDescrip==null)?"":sCategoryDescrip%>"></td>
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
