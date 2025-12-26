<%@ page

	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
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
	conn = cp.getConnection("report_settings_save_cy.jsp");
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
	
	//Report Dashboard columns
	 
	 String sCampIdColFlag=request.getParameter("camp_id_col_flag");
	 String sCampTypeColFlag=request.getParameter("camp_type_col_flag");
	 String sStartDateColFlag=request.getParameter("start_date_col_flag");
	 String sSubjectLineColFlag=request.getParameter("subject_line_col_flag");
	 String sContentNameColFlag=request.getParameter("content_name_col_flag");
	 String sTargetGroupNameColFlag=request.getParameter("target_group_name_col_flag");
	 String sCampCodeColFlag=request.getParameter("camp_code_col_flag");
	 String sSentColFlag=request.getParameter("sent_col_flag");
	 String sBBackColFlag=request.getParameter("bback_col_flag");
	 String sOpenColFlag=request.getParameter("open_col_flag");
	 String sClicksThroughColFlag=request.getParameter("clicks_through_col_flag");
	 String nUnsubscribesColFlag=request.getParameter("unsubscribes_col_flag");
	 String sOrdersColFlag=request.getParameter("orders_col_flag");
	 String sSalesColFlag=request.getParameter("sales_col_flag");
	
	//Threshold metrics
	String sBbackTh = request.getParameter("bback_threshold_percent");
	String sOpenTh = request.getParameter("open_threshold_percent");
	String sClickTh = request.getParameter("click_threshold_percent");
	
/*
sTotalsSecFlag
sGeneralSecFlag
sBBackSecFlag
sActionSecFlag
sDistClickSecFlag
sTotClickSecFlag
sFormSecFlag
sTotReadFlag
sMultiReadFlag
sTotClickFlag
sMultiLinkClickFlag
sLinkMultiClickFlag

 = @totals_sec_flag
 = @general_sec_flag
 = @bback_sec_flag
 = @action_sec_flag
 = @dist_click_sec_flag
 = @tot_click_sec_flag
 = @form_sec_flag
 = @tot_read_flag
 = @multi_read_flag
 = @tot_click_flag
 = @multi_link_click_flag
 = @link_multi_click_flag
*/

	String sSql1 = "EXEC usp_crpt_report_settings_update"
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
		
	pstmt = conn.prepareStatement(sSql1);

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

/*
sCampIdColFlag
sCampNameColFlag
sCampTypeColFlag
sStartDateColFlag
sSubjectLineColFlag
sContentNameColFlag
sTargetGroupNameColFlag
sCampCodeColFlag
sSentColFlag
sBBackColFlag
sOpenColFlag
sClicksThroughColFlag
nUnsubscribesColFlag
sOrdersColFlag
sSalesColFlag

 = @camp_id_col_flag
 = @camp_name_col_flag
 = @camp_type_col_flag
 = @start_date_col_flag
 = @subject_line_col_flag
 = @content_name_col_flag
 = @target_group_name_col_flag
 = @camp_code_col_flag
 = @sent_col_flag
 = @bback_col_flag
 = @open_col_flag
 = @clicks_through_col_flag
 = @unsubscribes_col_flag 
 = @orders_col_flag
 = @sales_col_flag
*/


String sSql2 = "EXEC usp_crpt_report_settings_column_update"
		+ " @camp_id_col_flag = ?,"
		+ " @camp_type_col_flag = ?,"
		+ " @start_date_col_flag = ?,"
		+ " @subject_line_col_flag = ?,"
		+ " @content_name_col_flag = ?,"
		+ " @target_group_name_col_flag = ?,"
		+ " @camp_code_col_flag = ?,"
		+ " @sent_col_flag = ?,"
		+ " @bback_col_flag = ?,"
		+ " @open_col_flag = ?,"
		+ " @clicks_through_col_flag = ?,"
		+ " @unsubscribes_col_flag =? ,"
		+ " @orders_col_flag = ?,"
		+ " @sales_col_flag = ?,"
		+ " @cust_id = ?";

	pstmt = conn.prepareStatement(sSql2);

	pstmt.setString(1, sCampIdColFlag);
	pstmt.setString(2, sCampTypeColFlag);
	pstmt.setString(3, sStartDateColFlag);
	pstmt.setString(4, sSubjectLineColFlag);
	pstmt.setString(5, sContentNameColFlag);
	pstmt.setString(6, sTargetGroupNameColFlag);
	pstmt.setString(7, sCampCodeColFlag);
	pstmt.setString(8, sSentColFlag);
	pstmt.setString(9, sBBackColFlag);
	pstmt.setString(10, sOpenColFlag);
	pstmt.setString(11, sClicksThroughColFlag);
	pstmt.setString(12, nUnsubscribesColFlag);
	pstmt.setString(13, sOrdersColFlag);
	pstmt.setString(14, sSalesColFlag);
	pstmt.setString(15, cust.s_cust_id);
	
	pstmt.executeUpdate();

/*
sBbackTh
sOpenTh
sClickTh

 = @bback_threshold_percent
 = @open_threshold_percent
 = @click_threshold_percent
*/

	String sSql = "EXEC usp_crpt_report_threshold_levels_update"
		+ " @bback_threshold_percent = ?,"
		+ " @open_threshold_percent = ?,"
		+ " @click_threshold_percent = ?,"
		+ " @cust_id = ?";

	pstmt = conn.prepareStatement(sSql);

	pstmt.setString(1, sBbackTh);
	pstmt.setString(2, sOpenTh);
	pstmt.setString(3, sClickTh);
	pstmt.setString(4, cust.s_cust_id);
	
	pstmt.executeUpdate();
	
%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Report Settings:</b> Saved</td>
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
						<b>The report settings were saved.</b>
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
<%

} catch(Exception ex) {
	ErrLog.put(this,ex,"report_settings_save_cy.jsp",out,1);
	return;
} finally {
	if (pstmt != null) pstmt.close();
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
