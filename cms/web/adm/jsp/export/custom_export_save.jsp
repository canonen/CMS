<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.sql.*, 
			java.util.*, 
			java.io.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String		EXPORT_NAME	= request.getParameter("exp_name");
String		CUSTOM_EXP_ID = request.getParameter("exp_id");
String		CUST_ID = request.getParameter("cust_id");
String		STORED_PROC = request.getParameter("stored_proc");
String		FIXED_WIDTH_FLAG = request.getParameter("fixed_width_flag");
String		GENERIC_STORED_PROC_FLAG = request.getParameter("generic_stored_proc_flag");
String[]	PARAM_NAMES = request.getParameterValues("param_name");
String[]	DISPLAY_NAMES = request.getParameterValues("display_name");
String[]	HEADER_NAMES = request.getParameterValues("header_name");
String[]	HEADER_WIDTHS = request.getParameterValues("header_width");

if (GENERIC_STORED_PROC_FLAG == null || GENERIC_STORED_PROC_FLAG == "") {
	GENERIC_STORED_PROC_FLAG = "1";
}

if (GENERIC_STORED_PROC_FLAG.equals("1")) {
	for (int i=0 ; i<HEADER_NAMES.length ; i++) {
		String sHeaderName = HEADER_NAMES[i];
		if ((sHeaderName != null) && (sHeaderName.trim().length() > 0)) {
			if ((sHeaderName.indexOf(";") > 0)|| (sHeaderName.indexOf("|") > 0) ||
				(sHeaderName.indexOf(",") > 0)|| (sHeaderName.indexOf("\\t") > 0)) {
				out.println("<BR>input error: header name '" +  sHeaderName + "' cannot contain the ';' or '|' or ',' or 'tab' delimiter");
				return;
			}
		}
	}
}

Statement			stmt = null;
PreparedStatement	pstmt = null;
ResultSet			rs = null;
ConnectionPool 		cp = null;
Connection 			conn  = null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("export_save.jsp");
        conn.setAutoCommit(false);
	stmt = conn.createStatement();
} catch(Exception ex) {
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

try {
	String sSql = "EXEC usp_cexp_custom_exp_update @cstm_exp_id=?, @cust_id=?, @exp_name=?, @stored_proc=?, @fixed_width_flag=?, @generic_stored_proc_flag=?"; 

	pstmt = conn.prepareStatement(sSql);
	if ((CUSTOM_EXP_ID != null) && (CUSTOM_EXP_ID.trim().length() > 0)) 
		pstmt.setString(1, CUSTOM_EXP_ID);
	else pstmt.setNull(1, Types.VARCHAR);	
	pstmt.setString(2, CUST_ID);
	pstmt.setBytes(3, EXPORT_NAME.getBytes("ISO-8859-1"));
	pstmt.setString(4, STORED_PROC);
	pstmt.setString(5, FIXED_WIDTH_FLAG);
	pstmt.setString(6, GENERIC_STORED_PROC_FLAG);
	rs = pstmt.executeQuery();
	if (!rs.next()) throw new Exception ("Problem saving Custom Export!");
	else CUSTOM_EXP_ID = rs.getString(1);

	stmt.executeUpdate("DELETE cexp_custom_exp_param WHERE cstm_exp_id = "+CUSTOM_EXP_ID);
	int param_id = 1;
	if (GENERIC_STORED_PROC_FLAG.equals("1")) {	
		for (int i=0 ; i<HEADER_NAMES.length ; i++) {
			if ((HEADER_NAMES[i] != null) && (HEADER_NAMES[i].trim().length() > 0)) {
				int pos = i + 1;
				String sHeaderName = HEADER_NAMES[i].trim();
				String sHeaderWidth = String.valueOf(sHeaderName.length());
				if ((HEADER_WIDTHS[i] != null) && (HEADER_WIDTHS[i].trim().length() > 0)) {
					try {
						sHeaderWidth = String.valueOf(Integer.parseInt(HEADER_WIDTHS[i].trim()));		
					}
					catch (Exception e) {}
				}
				String header_definition = "_header_;" + sHeaderName + ";" + sHeaderWidth;
				sSql = "INSERT cexp_custom_exp_param (param_id, cstm_exp_id, param_name, display_name)"
					+ " VALUES ("+ param_id+","+CUSTOM_EXP_ID+",?,null)";
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, header_definition);
				pstmt.executeUpdate();
				param_id++;
			}
		}
	}
	for (int i=0 ; i<PARAM_NAMES.length ; i++) {
		if ((PARAM_NAMES[i] != null) && (PARAM_NAMES[i].trim().length() > 0)) {
			sSql = "INSERT cexp_custom_exp_param (param_id, cstm_exp_id, param_name, display_name)"
				+ " VALUES ("+ param_id +","+CUSTOM_EXP_ID+",?,?)";
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1, PARAM_NAMES[i]);
			pstmt.setBytes(2, DISPLAY_NAMES[i].getBytes("ISO-8859-1"));
			pstmt.executeUpdate();
			param_id++;
		}
	}
	conn.commit();
	%>
<HTML>

<HEAD>
	<BASE target="_self">
	<LINK rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>

<BODY>
<BR><BR><BR>
<H3 align="center">The export was saved.</H3>
<BR><BR>
<P align="center"><a href="custom_export_list.jsp">Back to List</a></P>
<P align="center"><a href="custom_export_edit.jsp?exp_id=<%=CUSTOM_EXP_ID%>">Back to Edit</a></P>

</BODY>
</HTML>
<%		

} catch(Exception ex) {
	conn.rollback();
	ErrLog.put(this,ex,"custom_export_save.jsp",out,1);
	return;
} finally {
	try { 
		if (pstmt != null) pstmt.close();
		if (stmt != null) stmt.close();
	} catch (SQLException se) { }
	if (conn != null) {
            conn.setAutoCommit(true);
            cp.free(conn);
        }
}
	
%>
