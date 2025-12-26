<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*, 
			java.sql.*,
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp" %>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
String sql = null;

try	{
	Element eCamp = XmlUtil.getRootElement(request);  //get the full XML document from the request object
	if (eCamp == null) {
		out.println("<ERROR>Error retrieving XML in CPS->briteconnect_camp_info.jsp.  XML sent to CPS did not parse correctly.</ERROR>");
	}
	else {
		String camp_id = XmlUtil.getChildTextValue(eCamp,"camp_id");
	    logger.info("camp_id = " + camp_id);
	    logger.info("request = " + request);
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("briteconnect_camp_info.jsp");
		stmt = conn.createStatement();		
		sql = 
			"select c.camp_id, s.start_date, t.type_name, c.cont_id, n.cont_name, " +
			"       c.filter_id, f.filter_name, c.seed_list_id, c.origin_camp_id, h.from_name, " +
			"       case when h.from_address_id is not null then a.prefix + '@' + a.domain else h.from_address end, " +
			"       p.response_frwd_addr, h.subject_html " +
			"  from cque_campaign c " +
			"  left outer join cque_camp_type t on c.type_id = t.type_id " +
			"  left join cque_msg_header h on c.camp_id = h.camp_id " +
			"  left join cque_schedule s on c.camp_id = s.camp_id " +
			"  left join ccnt_content n on c.cont_id = n.cont_id " +
			"  left join ctgt_filter f on c.filter_id = f.filter_id " +
			"  left join cque_camp_send_param p on c.camp_id = p.camp_id " +
			"  left join ccps_from_address a on h.from_address_id = a.from_address_id " +
			" where c.camp_id = " + camp_id;
		
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			out.println("<CampaignInfo>");
			out.println("  <camp_id>" + rs.getString(1) + "</camp_id>");
			out.println("  <send_date>" + rs.getString(2) + "</send_date>");
			out.println("  <type_name>" + rs.getString(3) + "</type_name>");
			out.println("  <content_id>" + rs.getString(4) + "</content_id>");
			out.println("  <content_name>" + rs.getString(5) + "</content_name>");
			out.println("  <target_group_id>" + rs.getString(6) + "</target_group_id>");
			out.println("  <target_group_name>" + rs.getString(7) + "</target_group_name>");
			out.println("  <seed_list_id>" + rs.getString(8) + "</seed_list_id>");
			out.println("  <origin_camp_id>" + rs.getString(9) + "</origin_camp_id>");
			out.println("  <from_name>" + rs.getString(10) + "</from_name>");
			out.println("  <from_address>" + rs.getString(11) + "</from_address>");
			out.println("  <response_forwarding_address>" + rs.getString(12) + "</response_forwarding_address>");
			out.println("  <subject>" + rs.getString(13) + "</subject>");
			out.println("</CampaignInfo>");
		}
		else {
			out.println("<ERROR>No data found for campaign id "+camp_id+"</ERROR>");
		}
	}
}
catch(Exception ex) { 
	ex.printStackTrace(new PrintWriter(out));
	logger.error("Exception: ", ex);
	out.println("<ERROR>Exception thrown during briteconnect_camp_info.jsp: " + ex.getMessage() + "</ERROR>");
} finally {
	if (conn != null) cp.free(conn);
}
%>
