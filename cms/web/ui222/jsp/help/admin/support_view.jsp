<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%@ include file="../../header.jsp" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sSupportId = request.getParameter("support_id");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sCustID = null;
String sCustName = null;
String sUserName = null;
String sSubject = null;
String sOrigIssue = null;
String sFurtherInfo = null;
String sSupportDate = null;
													
sSql = " SELECT s.support_id, c.cust_id, c.cust_name, u.[user_name], s.support_subject, s.original_issue, s.further_info, s.support_date" +
		" FROM chlp_support s with(nolock)" +
		" INNER JOIN ccps_customer c with(nolock) on s.cust_id = c.cust_id" +
		" INNER JOIN ccps_user u with(nolock) on s.[user_id] = u.[user_id]" +
		" WHERE s.support_id = " + sSupportId;

try
{
	cp = ConnectionPool.getInstance();	
	conn = cp.getConnection(this);	
	
	try
	{
		if (sSupportId != null)
		{
			pstmt = conn.prepareStatement(sSql);
			rs = pstmt.executeQuery();
	
			byte[] b = null;
			while (rs.next())
			{
				sSupportId = rs.getString(1);
				
				sCustID = rs.getString(2);
				
				b = rs.getBytes(3);
				sCustName = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(4);
				sUserName = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(5);
				sSubject = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(6);
				sOrigIssue = (b==null)?null:new String(b, "ISO-8859-1");
				//sOrigIssue = sOrigIssue.replace("\n", "<br>");
				
				b = rs.getBytes(7);
				sFurtherInfo = (b==null)?null:new String(b, "ISO-8859-1");
				//sFurtherInfo = sFurtherInfo.replace("\n", "<br>");
				
				sSupportDate = rs.getString(8);
			}
			rs.close();
		}
	}
	catch(Exception ex)
	{
		throw new Exception(sSql+"\r\n"+ex.getMessage());
	}
	finally
	{
		if(pstmt != null) pstmt.close();
	}
%>
<html>
<head>
	<title>View Support Request</title>
	<%@ include file="../../header.html" %>
	<style type="text/css">
	<!--
	
		a:link,a:visited
		{
			font-family: Arial, Helvetica;
			font-size: 10px;
			color:#990000;
			text-decoration: underline;
		}
		
		td.sectionheader
		{
			font-family: Arial, Helvetica;
			color: #ffffff;
			background-color=#000040;
			font-size: 12px
		}
		
		table
		{
			font-size:8pt;
			color:#000000;
			font-family:Verdana;
		}
		
		
		td
		{
			font-size:8pt;
			color:#000000;
			font-family:Verdana;
		}
		
		
		b.sectionheader
		{
			font-family: Arial, Helvetica;
			color:#ffcc00;
			text-decoration: none;
		}
		
		input,textarea,option,select
		{
			font-family: arial;
			font-size: 9pt;
		}
		
		select.smallDDL
		{
			font-family: arial;
			font-size: 8pt;
		}



	//-->
	</style>
</head>
<body bgColor="#dddddd" topmargin="0" leftmargin="0">
<table cellspacing="0" cellpadding="0" border="0" width="100%" height="100%">
	<tr>
		<td colspan="5"><IMG src="../../../images/blank.gif" width="1" height="15" border="0"></td>
	</tr>
	<tr>
		<td width="20"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
		<td colspan="3" width="100%" bgColor="#31319C"><img src="../../../images/blank.gif" width="1" height="1" border="0"></td>
		<td width="20"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
	</tr>
	<tr>
		<td width="20"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
		<td width="1" bgColor="#31319C"><img src="../../../images/blank.gif" width="1" height="1" border="0"></td>
		<td width="100%" height="100%" bgColor="#ffffff" align="center" valign="top">
			<table cellspacing="0" cellpadding="0" border="0" width="100%">
				<tr>
					<td colspan="3" align="left" valign="top" width="159"><img src="../../../images/blank.gif" width="1" height="5" border="0"></td>
				</tr>
				<tr>
					<td align="left" valign="top"><img src="../../../images/blank.gif" width="25" height="1" border="0"></td>
					<td align="left" valign="top" width="100%">
						<TABLE cellpadding="0" cellspacing="0" class="main" width="100%">
							<TR>
								<TD class="sectionheader"><B class="sectionheader"> Support Request:</B> Detailed Information</TD>
							</TR>
						</TABLE>
						<BR>
						<TABLE cellpadding="1" cellspacing="1" border="0" width="100%">
							<TR>
								<TD align="left" valign="bottom" width="20%"><b>Support Ticket #:</b></TD>
								<TD align="left" valign="bottom" width="40%"><b>Customer</b></TD>
								<TD align="left" valign="bottom" width="40%"><b>User</b></TD>
							</TR>
							<TR>
								<TD align="left" valign="bottom" width="20%"><%= sCustID %>-<%= sSupportId %>&nbsp;</TD>
								<TD align="left" valign="bottom" width="40%"><%= sCustName %>&nbsp;</TD>
								<TD align="left" valign="bottom" width="40%"><%= sUserName %>&nbsp;</TD>
							</TR>
							<TR>
								<TD align="left" valign="bottom" width="100%" colspan="3"><b>Subject:</b></TD>
							</TR>
							<TR>
								<TD align="left" valign="bottom" width="100%" colspan="3"><%= sSubject %>&nbsp;</TD>
							</TR>
							<TR>
								<TD align="left" valign="bottom" width="100%" colspan="3"><b>Original Issue:</b></TD>
							</TR>
							<TR>
								<TD align="left" valign="bottom" width="100%" colspan="3"><textarea cols="120" rows="10"><%= sOrigIssue %></textarea></TD>
							</TR>
							<TR>
								<TD align="left" valign="bottom" width="100%" colspan="3"><b>Further Info:</b></TD>
							</TR>
							<TR>
								<TD align="left" valign="bottom" width="100%" colspan="3"><textarea cols="120" rows="10"><%= sFurtherInfo %></textarea></TD>
							</TR>
						</TABLE>
						<BR><BR>
					</td>
					<td align="left" valign="top"><img src="../../../images/blank.gif" width="25" height="1" border="0"></td>
				</tr>
			</table>
		</td>
		<td width="1" bgColor="#31319C"><img src="../../../images/blank.gif" width="1" height="1" border="0"></td>
		<td width="20"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
	</tr>
	<tr>
		<td width="20"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
		<td colspan="3" width="100%" bgColor="#31319C"><img src="../../../images/blank.gif" width="1" height="1" border="0"></td>
		<td width="20"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
	</tr>
	<tr>
		<td colspan="5"><IMG src="../../../images/blank.gif" width="1" height="15" border="0"></td>
	</tr>
</table>
</body>
</html>
<%
}
catch(Exception ex)
{
	throw ex;
}
finally
{
	if(conn != null) cp.free(conn);
}
%>