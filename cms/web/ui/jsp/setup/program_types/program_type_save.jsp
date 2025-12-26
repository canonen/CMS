<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.Logger"
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

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sProgramTypeId = request.getParameter("program_type_id");
ProgramType programType = null;

if( sProgramTypeId == null)
{
	programType = new ProgramType();
	programType.s_cust_id = cust.s_cust_id;
}
else {
	programType = new ProgramType(cust.s_cust_id, sProgramTypeId);
}

programType.s_program_type_name = BriteRequest.getParameter(request,"program_type_name");

programType.save();

String sRequest = programType.toXml();
String sResponse =
	Service.communicate(ServiceType.RQUE_PROGRAM_TYPE, cust.s_cust_id, sRequest);

// === === ===

try { XmlUtil.getRootElement(sResponse); }
catch(Exception ex)
{
	String sErrMsg =
		"\r\nError sending ProgramType to rcp: ERROR: " + 
		"\r\nsRequest = \r\n" + sRequest +
		"\r\nsResponse = \r\n" + sResponse;				
	
	logger.info(sErrMsg,ex);
	throw ex;
}

%>
<HTML>
<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Program Type:</b> Saved</td>
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
						<A href="program_type_list.jsp">Back to list</A>
						<BR><BR>
						<A href="program_type_edit.jsp?program_type_id=<%=programType.s_program_type_id%>">Back to edit</A>
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
