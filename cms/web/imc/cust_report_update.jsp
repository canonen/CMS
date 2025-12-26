<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,
			java.sql.*,
			java.net.*,
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
PreparedStatement pstmt = null;
Statement		stmt = null;
ResultSet		rs = null; 
ConnectionPool	cp = null;
Connection		conn = null;

String sSQL = null;

String sReportID = null;
String sCustID = null;
Element e = null;
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("imc/cust_report_update.jsp");
	stmt = conn.createStatement();

//	Msg msgIn = new Msg(XmlUtility.getRootElement(request));
//	msgIn.save();
//	Element eDetails = msgIn.getDetails();
//
//	e = XmlUtility.getChildByName(eDetails,"cust_report");

	e = XmlUtil.getRootElement(request);

	if(e == null) throw new Exception("Malformed Campaign Report xml.");

	sSQL = "EXEC usp_crpt_cust_report_update"
		+ " @report_id=?,"
		+ " @cust_id=?,"
		+ " @user_id=?,"
		+ " @update_date=?,"
		+ " @active=?,"
		+ " @have_bback=?,"
		+ " @are_bback=?,"
		+ " @unsub=?,"
		+ " @click=?,"
		+ " @multi_click=?,"
		+ " @camp_qty=?,"
		+ " @sent=?,"
		+ " @not_sent=?,"
		+ " @detect_html=?,"
		+ " @detect_text=?,"
		+ " @detect_aol=?,"
		+ " @unconfirmed=?,"
		+ " @status_id=?,"
		+ " @start_date=?,"
		+ " @end_date=?";

	pstmt = conn.prepareStatement(sSQL);

	sReportID = XmlUtil.getChildTextValue(e, "report_id");
	sCustID = XmlUtil.getChildTextValue(e, "cust_id");

	if ((sReportID == null) || (sCustID == null)) throw new Exception("Customer Report not specified.");
	logger.info("Updating cust report, ReportID = "+sReportID+", CustID = "+sCustID);
	String sVal = null;
	pstmt.setString(1,sReportID);
	pstmt.setString(2,sCustID);
	sVal = XmlUtil.getChildTextValue(e, "user_id");
	if (sVal != null) pstmt.setString(3,sVal);
	else pstmt.setNull(3,Types.VARCHAR);
	sVal = XmlUtil.getChildTextValue(e, "update_date");
	if (sVal != null) pstmt.setString(4,sVal);
	else pstmt.setNull(4,Types.VARCHAR);
	pstmt.setString(5,XmlUtil.getChildTextValue(e, "active"));
	pstmt.setString(6,XmlUtil.getChildTextValue(e, "have_bback"));
	pstmt.setString(7,XmlUtil.getChildTextValue(e, "are_bback"));
	pstmt.setString(8,XmlUtil.getChildTextValue(e, "unsub"));
	pstmt.setString(9,XmlUtil.getChildTextValue(e, "click"));
	pstmt.setString(10,XmlUtil.getChildTextValue(e, "multi_click"));
	pstmt.setString(11,XmlUtil.getChildTextValue(e, "camp_qty"));
	pstmt.setString(12,XmlUtil.getChildTextValue(e, "sent"));
	pstmt.setString(13,XmlUtil.getChildTextValue(e, "not_sent"));
	pstmt.setString(14,XmlUtil.getChildTextValue(e, "detect_html"));
	pstmt.setString(15,XmlUtil.getChildTextValue(e, "detect_text"));
	pstmt.setString(16,XmlUtil.getChildTextValue(e, "detect_aol"));
	pstmt.setString(17,XmlUtil.getChildTextValue(e, "unconfirmed"));
	pstmt.setString(18,XmlUtil.getChildTextValue(e, "status_id"));
	pstmt.setString(19,XmlUtil.getChildTextValue(e, "start_date"));
	pstmt.setString(20,XmlUtil.getChildTextValue(e, "end_date"));
	rs = pstmt.executeQuery();
	if (rs.next()) sReportID = rs.getString(1);
	pstmt.close();
	
	logger.info("Customer Report update, ReportID = "+sReportID+", CustID = "+sCustID);

	Element e2 = XmlUtil.getChildByName(e, "cust_report_bbacks");
	if (e2 != null) {
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "cust_report_bback");
logger.info("Updating cust report bbacks, ReportID = "+sReportID);
		if (xel.getLength() > 0) {
			conn.setAutoCommit(false);
			stmt.executeUpdate("DELETE crpt_cust_report_bback WHERE cust_id = "+sCustID+" AND report_id = "+sReportID);

			for (int j=0; j < xel.getLength(); j++) {
				Element e3 = (Element)xel.item(j);

				sSQL = "INSERT crpt_cust_report_bback"
					+ " (cust_id,"
					+ " report_id,"
					+ " category_id,"
					+ " bbacks)"
					+ " VALUES ("+sCustID+","+sReportID+",?,?)";
					
					pstmt = conn.prepareStatement(sSQL);

					pstmt.setString(1,XmlUtil.getChildTextValue(e3, "category_id"));
					pstmt.setString(2,XmlUtil.getChildTextValue(e3, "bbacks"));

					pstmt.executeUpdate();
					pstmt.close();
			}
			conn.commit();
		}
	}

	e2 = XmlUtil.getChildByName(e, "cust_report_domains");
	if (e2 != null) {
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "cust_report_domain");
logger.info("Updating cust report domains, ReportID = "+sReportID);
		if (xel.getLength() > 0) {
			conn.setAutoCommit(false);
			stmt.executeUpdate("DELETE crpt_cust_report_domain WHERE cust_id = "+sCustID+" AND report_id = "+sReportID);

			for (int j=0; j < xel.getLength(); j++) {
				Element e3 = (Element)xel.item(j);

				sSQL = "INSERT crpt_cust_report_domain"
					+ " (cust_id,"
					+ " report_id,"
					+ " domain,"
					+ " sent,"
					+ " bbacks)"
					+ " VALUES ("+sCustID+","+sReportID+",?,?,?)";
					
				pstmt = conn.prepareStatement(sSQL);

				pstmt.setString(1,XmlUtil.getChildCDataValue(e3, "domain"));
				pstmt.setString(2,XmlUtil.getChildTextValue(e3, "sent"));
				pstmt.setString(3,XmlUtil.getChildTextValue(e3, "bbacks"));

				pstmt.executeUpdate();
				pstmt.close();
			}
			conn.commit();
		}
	}

} catch (Exception ex) {
	logger.error("Customer Report Update Error! ",ex);
	if (pstmt != null) pstmt.close();
	conn.rollback();
	if ((sReportID != null) && (sCustID != null))
		 stmt.executeUpdate("UPDATE crpt_cust_report"
							+ " SET status_id = "+ReportStatus.ERROR
							+ " WHERE report_id = "+sReportID+" AND cust_id = "+sCustID);
        conn.commit();
} finally {
	try {
		if (stmt != null) stmt.close();
	} catch (Exception ex2) { }
	if (conn != null) {
            conn.setAutoCommit(true);
            cp.free(conn);
        }

}


%>