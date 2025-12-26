<%@ page
	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,
			org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;


try	{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("nonemail_new.jsp");
	stmt = srvConnection.createStatement();

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<FORM  METHOD="POST" NAME="FT" ENCTYPE="multipart/form-data" ACTION="nonemail_download.jsp" TARGET="_self">
<%
if(can.bWrite)
{
	%>
	<table cellpadding="4" cellspacing="0" border="0" width="525">
		<tr>
			<td vAlign="middle" align="left">
				<a class="savebutton" href="#" onClick="try_submit();">Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}

String sCampId=request.getParameter("id");	
%>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Campaign Info </td>
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
			<TABLE class=main WIDTH="100%" cellpadding=2 cellspacing=1>
				<TR>
					<TD width="90px">&nbsp;Campaign Name:&nbsp;</TD>
					<TD><b>&nbsp;&nbsp;
						<%
                        String sCampName = null;
						String sSql = "SELECT camp_name FROM cque_campaign"
									+ " WHERE cust_id = "+cust.s_cust_id
									+ " AND (    (status_id = "+CampaignStatus.DONE + " AND type_id = " + CampaignType.NON_EMAIL + " ) "
							        + "       OR (status_id in (55, 57, 60) AND media_type_id = 2) ) "
									+ " AND camp_id = "+sCampId
									+ " ORDER BY camp_id DESC";
						rs = stmt.executeQuery(	sSql );
						if ( rs.next() ) sCampName=new String(rs.getBytes(1), "UTF-8");
                        rs.close();
						%>
						<input type="hidden" name="camp_id" value="<%=sCampId%>"><%=sCampName%></b>
					</TD>
				</TR>
			</TABLE>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!----Step 2 Header ---->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Select your File</td>
	</tr>
</table>
<br>
<!---Step 2 Info------->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main width=100% cellpadding=2 cellspacing=1 border=0>
				<TR>
					<TD WIDTH="150">Select Your File</TD>
					<TD WIDTH="500"><input type="file" name="recipient_file" size="30"<%=((!bCanWrite)?" disabled":"")%>></TD>
				</TR>
			</table>
			<br>
			<table class=main width=100% cellpadding=2 cellspacing=1 border=0>
				<TR>
					<TD>
						File should be a single column containing a list of recipient fingerprint fields.
						<%
						rs = stmt.executeQuery("SELECT count(attr_id) FROM ccps_cust_attr WHERE cust_id = "+cust.s_cust_id
									+ " AND fingerprint_seq IS NOT NULL");

						int nFingerFields = 0;
						
						if (rs.next()) nFingerFields = rs.getInt(1);

						if (nFingerFields > 1)
						{
							rs = stmt.executeQuery("SELECT display_name FROM ccps_cust_attr WHERE cust_id = "+cust.s_cust_id
									+ " AND fingerprint_seq IS NOT NULL ORDER BY fingerprint_seq");
									
							String sFingerSeq = "";
							
							while (rs.next()) sFingerSeq += ((sFingerSeq.length() > 0)?", ":"")+rs.getString(1);
							%>
							Multiple fingerprint fields should be concatenated into a single string in the following order: <%= sFingerSeq %>
							<%
						}
						%>
					</TD>
				</TR>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</FORM>	
</BODY>
<SCRIPT>

function try_submit () {

	if(FT.recipient_file.value == "" )	{ alert("You have to choose File ...");		return false; }
	if(FT.camp_id.value == "" )		{ alert("You have to choose Campaign ...");		return false; }

	FT.submit();
}


</SCRIPT>
<%

} catch (Exception ex) { 

	ErrLog.put(this,ex, "Problem with nonemail import.",out,1);

} finally {

	if ( stmt != null ) stmt.close();
	if ( srvConnection  != null ) connectionPool.free(srvConnection); 

}
%>
</HTML>


























