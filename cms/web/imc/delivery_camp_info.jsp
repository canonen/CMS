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
	Element xml = XmlUtil.getRootElement(request);  //get the full XML document from the request object
	if (xml == null) {
		out.println("<ERROR>Error retrieving XML in CPS->delivery_camp_info.jsp.  XML sent to CPS did not parse correctly.</ERROR>");
	}
	else {
		String started_past_hours = XmlUtil.getChildTextValue(xml,"started_past_hours");
		String completed_past_hours = XmlUtil.getChildTextValue(xml,"completed_past_hours");
	    logger.info("[cps:delivery_camp_info] getting campaigns started within the past " + started_past_hours + " hours" + 
	    			" that are either ongoing or finished within the past = " + completed_past_hours + " hours");
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("delivery_camp_info.jsp");
		stmt = conn.createStatement();
		sql = 
			"SELECT c.camp_id, c.cust_id, c.camp_name, cust.cust_name," +
		    "       cs.start_date, cs.recip_total_qty, cs.recip_sent_qty" +
		   	"  FROM cque_campaign c with(nolock)" +
		 	" INNER JOIN cque_camp_statistic cs with(nolock) ON (c.camp_id = cs.camp_id)" +
		 	" INNER JOIN ccps_customer cust with(nolock) ON (c.cust_id = cust.cust_id)" +
		 	" WHERE c.status_id BETWEEN 55 AND 60" +
		 	"   AND c.type_id = 2" +
		 	"   AND (c.media_type_id IS NULL OR c.media_type_id = 1)" +
		 	"   AND DATEDIFF(hh, cs.start_date,getDate()) < " + started_past_hours +
		 	"   AND (cs.finish_date is NULL OR DATEDIFF(hh, cs.finish_date,getDate()) <  " + completed_past_hours + ")";
		rs = stmt.executeQuery(sql);
		int count = 0;
		out.println("<RecentCampaigns>");
		while (rs.next()) {
			count++;
			byte[] bVal = new byte[255];
			out.println("<CampaignInfo>");
			out.println("  <camp_id>" + rs.getString(1) + "</camp_id>");
			out.println("  <cust_id>" + rs.getString(2) + "</cust_id>");
			bVal = rs.getBytes(3);
			out.println("  <camp_name><![CDATA[" + (bVal!=null?new String(bVal,"UTF-8"):"") + "]]></camp_name>");
			bVal = rs.getBytes(4);
			out.println("  <cust_name><![CDATA[" + (bVal!=null?new String(bVal,"UTF-8"):"") + "]]></cust_name>");
			out.println("  <start_date>" + rs.getString(5) + "</start_date>");
			out.println("  <recip_queue_qty>" +  rs.getString(6) + "</recip_queue_qty>");
			out.println("  <recip_sent_qty>" + rs.getString(7) + "</recip_sent_qty>");
			out.println("</CampaignInfo>");
		}
		logger.info("[cps:delivery_camp_info] found " + count + " qualifying campaigns");
		out.println("</RecentCampaigns>");
		rs.close();
	}
}

catch(Exception ex) { 
	ex.printStackTrace(new PrintWriter(out));
	logger.error("Exception: ", ex);
	out.println("<ERROR>Exception thrown during delivery_camp_info.jsp: " + ex.getMessage() + "</ERROR>");
} 
finally {
	try	 {
		if ( stmt != null ) stmt.close();
	}
	catch (SQLException se) { }
	if ( conn != null ) cp.free(conn);  
}
%>
