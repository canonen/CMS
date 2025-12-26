<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.imc.*,
		java.sql.*,java.util.*,
		com.britemoon.cps.tgt.Filter,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sFilterId = BriteRequest.getParameter(request, "filter_id");
System.out.println("sFilterId in filter_stat_new = " + sFilterId);
String sAction		= request.getParameter("sRecipType").trim();
System.out.println("sAction in filter_stat_new = " + sAction);
String sAttribList = "0";

Filter filter = null;
if(sFilterId != null)
{
	filter = new Filter(sFilterId);
	filter.s_cust_id = cust.s_cust_id;
	System.out.println("filter object created");
	System.out.println("filter.s_filter_name = " + filter.s_filter_name);
}
else
{
	System.out.println("filter retrieves all the fields");
}


Statement	stmt;
ResultSet	rs; 
ConnectionPool 	connectionPool 	= null;
Connection 	srvConnection 	= null;
int		nStep		= 1;
try 
{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("filter_stat_export_new.jsp");
	stmt  = srvConnection.createStatement();
} catch(Exception ex) {
	connectionPool.free(srvConnection);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

try {

	String ExpDescrip = "Export of " + filter.s_filter_name;
%>
<HTML>
<HEAD>
<title>Report Export</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT>
function a()		{ return confirm("Are you sure?"); }
</SCRIPT>
</HEAD>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="Try_Submit();">Save Export</a>
		</td>
	</tr>
</table>
<br>

<FORM METHOD="POST" NAME="FT" ACTION="../export/filter_stat_export_save.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="Action" VALUE=<%=(sAction == null)?"\"\"":"\""+sAction+"\""%>>
<INPUT TYPE="hidden" NAME="filter_id" VALUE=<%=(sFilterId == null)?"\"\"":"\""+sFilterId+"\""%>>
<INPUT TYPE="hidden" NAME="view" VALUE="">
<!--- Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader><b class=sectionheader>Reporting:</b> New Export</td>
	</tr>
</table>
<br>

<!---- Info----->
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
						<b><%= ExpDescrip %></b>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader align=left><b class=sectionheader>Step 1:</b> Choose export name and delimiter</td>
	</tr>
</table>
<br><br>
<!---- Step  Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="275"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td valign="center" nowrap align="middle" width="15"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>

	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class="fillTab" valign="top" align="center" width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="150">Enter export name</td>
					<td width="475"><INPUT TYPE="text" NAME="export_name" width="100%" SIZE="40" MAXLENGTH="50" value=""></td> 
				</tr>
				
				<TR>
					<TD width="150">Delimiter</TD>
					<TD width="475">
						<INPUT TYPE="radio" NAME="delim" VALUE="TAB" CHECKED>Tab
						<INPUT TYPE="radio" NAME="delim" VALUE=";">Semicolon (;)
						<INPUT TYPE="radio" NAME="delim" VALUE=",">Comma (,)
						<INPUT TYPE="radio" NAME="delim" VALUE="|">Pipe (|)
					</TD>
				</tr>
			</table>
		</td>		
	</tr>
	</tbody>
</table>
<br><br>

<!--- Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Add Fields to Export</td>
	</tr>
</table>
<br>

<!---- Info----->
<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=1 src="../../images/blank.gif" width=650></td>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="left" valign="middle">
						<%@ include file="../export/export_preview_attrs.inc"%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</FORM>

<SCRIPT>

function Try_Submit()
{
 if (FT.export_name.value.length == 0)
 {   alert ("Error - No export name");  return 0;   }
 if (FT.target.options.length == 0)
 {   alert ("Error - No fields selected");  return 0;   }
 FT.view.value = ""; 
 for (var j=0; j < FT.target.options.length; ++j) 
 {
	if (j > 0)
		FT.view.value += ","; 
	FT.view.value += FT.target.options[j].value ; 
 } 
 FT.submit();
}

Init();

</SCRIPT>
</body>
</HTML>
<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"filter_stat_export_new.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (srvConnection != null) connectionPool.free(srvConnection);
	}
%>
