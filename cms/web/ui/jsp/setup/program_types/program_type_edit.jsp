<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.ANALYTICAL_REPORTING);

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<%
String sProgramTypeId= request.getParameter("program_type_id");

ProgramType programType = new ProgramType(cust.s_cust_id, sProgramTypeId);

String sProgramTypeName = programType.s_program_type_name;
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
		var pgm_name = document.program_type.program_type_name.value;
		if( (pgm_name != null) && (pgm_name != "") )
		{
			program_type.action='program_type_save.jsp'; 
			program_type.submit();
		}
		else
			alert('Please enter the Program Type Name');
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

<FORM method="POST" action="" target="_self" name="program_type">
<%
if(sProgramTypeId!= null)
{
	%>
	<INPUT type="hidden" name="program_type_id" value="<%=sProgramTypeId%>">
	<!-- IMG STYLE="cursor:hand" SRC="../../../images/deletebutton.gif" onClick="filter_delete();" -->
	<%
}
%>
<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Name your Program Type</td>
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
					<td align="left" valign="middle"><INPUT type="text" name="program_type_name" size="60" value="<%=(sProgramTypeName==null)?"":sProgramTypeName%>"></td>
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
