<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.que.*"
	import="com.britemoon.cps.xcs.cti.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sCustId = request.getParameter("cust_id");
String sCampId = request.getParameter("camp_id");
String sChunkId = request.getParameter("chunk_id");
	
Campaign camp = new Campaign(sCampId);
	
ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
String sSql = null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("admin_fix_camp.jsp");
	stmt = conn.createStatement();

	// get cont ids
	String sContIdList = null;
	sSql = 
		"SELECT DISTINCT cont_id " +
		"  FROM cque_campaign " +
		" WHERE origin_camp_id = " + camp.s_origin_camp_id;
	rs = stmt.executeQuery(sSql);
	while (rs.next()) {
		if (sContIdList == null) {
			sContIdList = rs.getString(1);
		}
		else {
			sContIdList +=  "," + rs.getString(1);
		}
	}
	rs.close();
	logger.info("fixing headers for camp_id = "  + camp.s_origin_camp_id + ", cont_id = " + sContIdList);
				
	if (sContIdList != null) {
		
		// get saved cti_doc_attrs
		String sSavedAttrIdList = null;
		sSql = "SELECT DISTINCT attr_id FROM cxcs_cti_doc_attrs WHERE cont_id in (" + sContIdList + ") ORDER BY attr_id";
		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			if (sSavedAttrIdList == null) sSavedAttrIdList = rs.getString(1);
			else sSavedAttrIdList +=  "," + rs.getString(1);
		}
		rs.close();
		logger.info("sSavedAttrIdList= " + sSavedAttrIdList);
		
		// call WS to populate the cxcs_cti_doc_attrs table
		try	{
			StringTokenizer contIdList = new StringTokenizer(sContIdList, ",");
			while (contIdList.hasMoreTokens()) {
				String contId = contIdList.nextToken();
				logger.info("calling web service to populate cxcs_cti_doc_attrs table for cont_id = " + contId);
				CTIDocAttributeWS docAttr = new CTIDocAttributeWS();
				docAttr.getDocAttributes(sCustId, contId);
			}
			camp.s_status_id = String.valueOf(CampaignStatus.BEING_PROCESSED);
			camp.save();
		}
		catch (Exception ex) {
			logger.info("oops! unable to call web services! camp_id = " + camp.s_camp_id);
		}
		
		// get new cti_doc_attrs
		String sNewAttrIdList = null;
		sSql = "SELECT DISTINCT attr_id FROM cxcs_cti_doc_attrs WHERE cont_id in (" + sContIdList + ") ORDER BY attr_id";
		rs = stmt.executeQuery(sSql);
		while (rs.next()) {
			if (sNewAttrIdList == null) {
				sNewAttrIdList = rs.getString(1);
			}
			else {
				sNewAttrIdList +=  "," + rs.getString(1);
			}
		}
		rs.close();
		logger.info("sNewAttrIdList= " + sNewAttrIdList);
		out.println("Campaign fixed! Should be queued for submission");
	}
	logger.info("done fixing headers for camp_id = "  + camp.s_origin_camp_id + ", cont_id = " + sContIdList);

}
catch (Exception ex) {
	logger.error("admin_fix_camp.jsp error!\r\n",ex);
}
finally {
	try { if (stmt != null) stmt.close(); }
	catch (Exception ex2) { }
	if (conn != null) cp.free(conn);
}

%>
