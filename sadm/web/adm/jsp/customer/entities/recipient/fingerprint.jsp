<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="/adm/jsp/header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
Customer cust = new Customer(sCustId);
if( cust.s_cust_id == null) throw new Exception(this.getClass().getName() + ": cust_id is null");
boolean hasFingerprint = false;

ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	sSQL =
		" SELECT ca.attr_id, ca.display_name" +
		" FROM sadm_cust_attr ca" +
		" WHERE ca.cust_id=" + cust.s_cust_id +
		" AND ca.fingerprint_seq > 0" +
		" ORDER BY ca.fingerprint_seq";

	rs = stmt.executeQuery(sSQL);

	String sAttrId = null;
	String sDisplayName = null;

	while(rs.next())
	{
		hasFingerprint = true;
	}
	rs.close();

%>
<HTML>

<HEAD>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">
</HEAD>

<BODY>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
<%
if(!hasFingerprint)
{
	%>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left" nowrap>
						<a class="newbutton" href="#" onclick="FT.submit();">Save</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<%
}
%>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:350; height:100%;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Fingerprint</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<div style="width:100%; height:100%; overflow:auto;">
						<FORM name="FT" method="POST" action="fingerprint_save.jsp">
						<INPUT type="hidden" name="cust_id" value=<%=cust.s_cust_id%>>
						<table class="listTable layout" style="width:100%;" border="0" cellspacing="0" cellpadding="3">
							<col>
							<col width="30">
							<tr height="22">
								<th>Display Name</th>
								<th>F</th>
							</tr>
						<%
						rs = stmt.executeQuery(sSQL);

						sAttrId = null;
						sDisplayName = null;

						while(rs.next())
						{
							sAttrId = rs.getString(1);
							sDisplayName = rs.getString(2);
							%>
							<tr height="26">
								<td><A href="cust_attr_frame.jsp?cust_id=<%=cust.s_cust_id%>&attr_id=<%=sAttrId%>"><%=sDisplayName%></td>
								<td><input type="checkbox"checked disabled></td>
							</tr>
							<%
							hasFingerprint = true;
						}
						rs.close();
						
						if(!hasFingerprint)
						{
							sSQL =
								" SELECT ca.attr_id, ca.display_name" +
								" FROM sadm_attribute a, sadm_cust_attr ca" +
								" WHERE ca.cust_id=" + cust.s_cust_id +
								" AND a.attr_id = ca.attr_id" +
								" AND ISNULL(a.value_qty, 0) <= 1" +
								" ORDER BY ISNULL(ca.display_seq, 1000000), ca.display_name";

 							rs = stmt.executeQuery(sSQL);

							while(rs.next())
							{
								sAttrId = rs.getString(1);
								sDisplayName = rs.getString(2);
								%>
							<tr height="26">
								<td><A href="cust_attr_frame.jsp?cust_id=<%=cust.s_cust_id%>&attr_id=<%=sAttrId%>"><%=sDisplayName%></td>
								<td><input type="checkbox" name="fingerprint" value=<%=sAttrId%>></td>
							</tr>
								<%
							}
							rs.close();
						}
						%>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>
	<%
}
catch(Exception ex)
{
	ex.printStackTrace(response.getWriter());
}
finally
{
	if(conn!=null) cp.free(conn);
}
%>
