<%@ page

	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
// Connection
Statement			stmt	= null;
PreparedStatement	pstmt	= null;
ResultSet			rs		= null; 
ConnectionPool		cp 		= null;
Connection			conn 	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_settings_save.jsp");
	stmt = conn.createStatement();

	String sTotalsSecFlag= request.getParameter("totals_sec_flag");
	String sGeneralSecFlag= request.getParameter("general_sec_flag");
	String sBBackSecFlag= request.getParameter("bback_sec_flag");
	String sActionSecFlag= request.getParameter("action_sec_flag");
	String sDistClickSecFlag= request.getParameter("dist_click_sec_flag");
	String sTotClickSecFlag= request.getParameter("tot_click_sec_flag");
	String sFormSecFlag= request.getParameter("form_sec_flag");
	String sTotReadFlag= request.getParameter("tot_read_flag");
	String sMultiReadFlag= request.getParameter("multi_read_flag");
	String sTotClickFlag= request.getParameter("tot_click_flag");
	String sMultiLinkClickFlag= request.getParameter("multi_link_click_flag");
	String sLinkMultiClickFlag= request.getParameter("link_multi_click_flag");
	String sDomainFlag= request.getParameter("domain_flag");
	String sOptoutFlag= request.getParameter("optout_flag");


	String sSql = "EXEC usp_crpt_report_settings_update"
		+ " @totals_sec_flag = ?,"
		+ " @general_sec_flag = ?,"
		+ " @bback_sec_flag = ?,"
		+ " @action_sec_flag = ?,"
		+ " @dist_click_sec_flag = ?,"
		+ " @tot_click_sec_flag = ?,"
		+ " @form_sec_flag = ?,"
		+ " @tot_read_flag = ?,"
		+ " @multi_read_flag = ?,"
		+ " @tot_click_flag = ?,"
		+ " @multi_link_click_flag = ?,"
		+ " @link_multi_click_flag = ?,"
		+ " @domain_flag = ?,"
		+ " @optout_flag = ?,"
		+ " @cust_id = ?";
		
	pstmt = conn.prepareStatement(sSql);

	pstmt.setString(1, sTotalsSecFlag);
	pstmt.setString(2, sGeneralSecFlag);
	pstmt.setString(3, sBBackSecFlag);
	pstmt.setString(4, sActionSecFlag);
	pstmt.setString(5, sDistClickSecFlag);
	pstmt.setString(6, sTotClickSecFlag);
	pstmt.setString(7, sFormSecFlag);
	pstmt.setString(8, sTotReadFlag);
	pstmt.setString(9, sMultiReadFlag);
	pstmt.setString(10, sTotClickFlag);
	pstmt.setString(11, sMultiLinkClickFlag);
	pstmt.setString(12, sLinkMultiClickFlag);
	pstmt.setString(13, sDomainFlag);
	pstmt.setString(14, sOptoutFlag);
	pstmt.setString(15, cust.s_cust_id);
	
	pstmt.executeUpdate();


} catch(Exception ex) {
	ErrLog.put(this,ex,"super_camp_save.jsp",out,1);
	return;
} finally {
	if (pstmt != null) pstmt.close();
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
