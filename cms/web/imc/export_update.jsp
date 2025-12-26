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
<%! static Logger logger = null; %>
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

String sCustID = null;
String sFileURL = null;
String sStatusID = null;
String sError = null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("imc/export_update.jsp");
	stmt = conn.createStatement();

	Element e = XmlUtil.getRootElement(request);

	if(e == null) throw new Exception("Malformed Export xml.");

// XML fields	
// <cust_id></cust_id>
// <file_url><![CDATA[]]></file_url>
// <status_id></status_id>
// <error><![CDATA[]]></error>

	sCustID = XmlUtil.getChildTextValue(e, "cust_id");
	if (sCustID == null)
		throw new Exception("No cust_id");
	sFileURL = XmlUtil.getChildCDataValue(e, "file_url");
	if (sFileURL == null)
		throw new Exception("No file_url");

	sStatusID = XmlUtil.getChildTextValue(e, "status_id");
	if (sStatusID != null) {
		sSQL = "UPDATE cexp_export_file SET status_id = "+sStatusID+" WHERE cust_id = "+sCustID
			+ " AND file_url = '"+sFileURL+"'";
		stmt.executeUpdate(sSQL);
	}

	sError = XmlUtil.getChildCDataValue(e, "error");
	if (sError != null) {
		sSQL = "UPDATE cexp_export_file SET params = ISNULL(params, '') + 'ERROR:"+sError+"' WHERE cust_id = "+sCustID
			+ " AND file_url = '"+sFileURL+"'";
		stmt.executeUpdate(sSQL);
	}

} catch (Exception ex) {
	logger.error("Export Update Error: ",ex);
} finally {
	try {
		if (stmt != null) stmt.close();
	} catch (Exception ex2) { }
	if (conn != null) cp.free(conn);

}


%>