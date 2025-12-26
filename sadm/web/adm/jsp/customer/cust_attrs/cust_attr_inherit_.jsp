<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.cps.*, com.britemoon.cps.adm.*, java.io.*,java.sql.*,java.util.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>

<%
AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
int nUIType = ui.n_ui_type_id;

if((!can.bRead) || (!can.bWrite))
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<HTML>

<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>

<TABLE width="650" cellpadding="1" cellspacing="1" border="0">
	<TR>
		<TD valign="middle">
			<H4>Attributes available to inherit</H4>
		</TD>
	</TR>
</TABLE>

<TABLE class="main" width="650" cellpadding="0" cellspacing="1">
	<TR>
		<TH>Display Name</TH>
		<TH width="5%" nowrap>Multi-value</TH>
		<TH width="5%">Fingerprint</TH>
	</TR>
<%
	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		String sSQL =
			" SELECT" +
			"	a.attr_id," +
			"	a.attr_name," +
			"	a.value_qty," +			
			"	ca.display_name," +
			"	ca.display_seq," +
			"	ca.fingerprint_seq," +
			"	t.type_name" +
			" FROM" +
			"	ccps_cust_attr ca," +
			"	ccps_attribute a," +
			"	ccps_data_type t" +
			" WHERE" +
			"	ca.cust_id=" + cust.s_parent_cust_id + " AND" +			
			"	ca.attr_id = a.attr_id AND" +
			"	a.type_id = t.type_id AND" +
			"	a.scope_id = " + AttrScope.PUBLIC + " AND" +			
			"	ISNULL(a.internal_flag,0) <= 0 AND" +
			"	ca.attr_id NOT IN" +
			"		(SELECT attr_id FROM ccps_cust_attr" +
			"			WHERE cust_id = " + cust.s_cust_id + ")" +
			" ORDER BY display_seq, display_name";

 		ResultSet rs = stmt.executeQuery(sSQL);

		String sAttrId = null;
		String sAttrName = null;
		String sValueQty = null;
		
		String sDisplayName = null;
		String sDisplaySeq = null;
		String sFingerprintSeq = null;

		String sTypeName = null;

		String sDescrip = null;

		while(rs.next())
		{
			sAttrId = rs.getString(1);
			sAttrName = rs.getString(2);
			sValueQty = rs.getString(3);

			sDisplayName = new String(rs.getBytes(4), "UTF-8");
			sDisplaySeq = rs.getString(5);
			sFingerprintSeq = rs.getString(6);

			sTypeName = rs.getString(7);
%>
	<TR>
		<TD><A href="cust_attr_edit.jsp?attr_id=<%=sAttrId%>"><%=sDisplayName%> (<%=sTypeName%>)</TD>
		<TD align="center"><INPUT type="checkbox" <%=(sValueQty==null)?"":"checked"%> disabled></TD>
		<TD align="center"><INPUT type="checkbox" <%=(sFingerprintSeq==null)?"":"checked"%> disabled></TD>
	</TR>
<%
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn!=null) cp.free(conn); }
%>
</TABLE>
</BODY>
</HTML>
