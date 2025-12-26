<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%@ include file="../header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
<BASE target="task">
<SCRIPT LANGUAGE="JavaScript">
function toggleHeaders() {
	if (document.FT.generic_stored_proc_flag.checked == true) {
    	document.getElementById('headers').style.display = "none";
    	document.FT.generic_stored_proc_flag.value = "0";
	}
	else {
	    document.getElementById('headers').style.display = "block";
	    document.FT.generic_stored_proc_flag.value = "1";
	}
}
</SCRIPT>
</HEAD>
<BODY>
<%

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("custom_export_new.jsp");
	stmt = conn.createStatement();

	String		sExpID		= request.getParameter("exp_id");
	String		sExpName	= "";
	String		sStoredProc = "";
	String		sCustID = "";
	int		nFixedWidthFlag = 0;	
	int		nGenericStoredProcFlag = 1;

	rs = stmt.executeQuery("SELECT exp_name, stored_proc, cust_id, ISNULL(fixed_width_flag,0), ISNULL(generic_stored_proc_flag,0) FROM cexp_custom_export WHERE cstm_exp_id = "+sExpID);
	if (rs.next()) {
		sExpName = new String(rs.getBytes(1), "ISO-8859-1");
		sStoredProc = rs.getString(2);
		sCustID = rs.getString(3);
		nFixedWidthFlag = rs.getInt(4);
		nGenericStoredProcFlag = rs.getInt(5);
	}
%>
<FORM  METHOD="POST" NAME="FT" action="custom_export_save.jsp" TARGET="_self">
<INPUT type="hidden" name="exp_id" value="<%=(sExpID!=null)?sExpID:""%>">
<TABLE>
<TR><TD>Customer</TD><TD><INPUT type="text" name="cust_id" value="<%=sCustID%>"></TD></TR>
<TR><TD>Export Name</TD><TD><INPUT type="text" name="exp_name" value="<%=sExpName%>" size=60></TD></TR>
<TR><TD>Stored Procedure</TD><TD><INPUT type="text" name="stored_proc" value="<%=sStoredProc%>" size=60></TD></TR>
<TR><TD>Stored Procedure is old style</TD><TD><INPUT type="checkbox" name="generic_stored_proc_flag" value="<%=nGenericStoredProcFlag %>" <%=(nGenericStoredProcFlag==0)?" CHECKED":""%> onClick="toggleHeaders();"></TD></TR>
<TR><TD>Fixed Width</TD><TD><INPUT type="checkbox" name="fixed_width_flag" value="1"<%=(nFixedWidthFlag!=0)?" CHECKED":""%>></TD></TR>
</TABLE>
<TABLE id=headers style="display:<%=(nGenericStoredProcFlag==0)?"none":"block"%>">
<TR><TD colspan=2>
<b>&nbsp;if you define a header without width, the length of the header name will be used.</b>
<br>
<b>&nbsp;if you need to define more headers, save what you have and hit 'Back to Edit'.</b>
<TR><TH>Header Name</TH><TH>Header Width</TH></TR>
</TD></TR>
<%
	rs = stmt.executeQuery("SELECT param_name FROM cexp_custom_exp_param"
						 + " WHERE cstm_exp_id = " + sExpID + " AND param_name like '_header_;%'"
						 + " ORDER BY param_id");
	int i = 0;
	int max = 0;
	while (rs.next()) {
		i++;
		String sParamName = new String(rs.getBytes(1), "ISO-8859-1");
		String[] parts = sParamName.split(";");   // expected format:  _header_;name;width
		String sHeaderTag = parts[0];
		String sHeaderName = parts[1];
		String sHeaderWidth = parts[2];
%>
<TR>
	<TD><INPUT type="text" name="header_name" value="<%=sHeaderName%>"></TD>
	<TD><INPUT type="text" name="header_width" value="<%=sHeaderWidth%>"></TD>
</TR>
<% 
	}
	if (i == 0) max = 10; else max = i + 5;
	if (max < 10) max = 10;
	for (; i < max ; i++) {
%>
<TR>
	<TD><INPUT type="text" name="header_name"></TD>
	<TD><INPUT type="text" name="header_width"></TD>
</TR>
<% 
	}
	rs.close();
%>
</TABLE>
<br>
<b>if you need to define more parameter, save what you have and hit 'Back to Edit'.</b>
<TABLE>
<TR><TH>Parameter Name</TH><TH>Display Name</TH></TR>
<%
	rs = stmt.executeQuery("SELECT ISNULL(display_name,param_name), param_name FROM cexp_custom_exp_param"
						+ " WHERE cstm_exp_id = " + sExpID + " AND param_name not like '_header_;%'");
	i = 0;
	while (rs.next()) {
		i++;
		String sDisplayName = new String(rs.getBytes(1), "ISO-8859-1");
		String sParamName = rs.getString(2);
%>
<TR>
	<TD><INPUT type="text" name="param_name" value="<%=sParamName%>"></TD>
	<TD><INPUT type="text" name="display_name" value="<%=sDisplayName%>"></TD>
</TR>
<% 
	}
	if (i == 0) max = 5; else max = i + 2;
	if (max < 5) max = 5;
	for (; i < max ; i++) {
%>
<TR>
	<TD><INPUT type="text" name="param_name"></TD>
	<TD><INPUT type="text" name="display_name"></TD>
</TR>
<% 
	}
%>
</TABLE>
<BR>
<INPUT type="submit" value="Save">
</FORM>
</BODY>

<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"custom_export_list.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
</HTML>
