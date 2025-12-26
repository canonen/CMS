<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctm.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.imc.*,
			org.w3c.dom.*,
			java.sql.*,
			java.util.*,
			java.io.*,
			javax.servlet.*,
			javax.servlet.http.*,
			org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			javax.xml.parsers.*,
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
ConnectionPool connectionPool = null;
Connection srvConnection = null;
Statement sqlStatement = null;
ResultSet rs = null;
PreparedStatement pstmt = null;


String sCustId = request.getParameter("customerID");
String sUserId = request.getParameter("userID");
String sScanLink = request.getParameter("scanLink"); // used by CTM templates

UserUiSettings uus = new UserUiSettings(sUserId);
String[] sCategories = new String[1];
if (uus.s_category_id != null) sCategories[0] = uus.s_category_id;
else sCategories = null;

// 2nd Step --- Get XML from wizard ---

String strWizardContentId = null;

String strContentName = null;
String strContentSendTypeID = null;
String strStatus = null;
String strContentText = null;
String strContentHTML = null;
Vector vTrack = new Vector();
Vector vPers = new Vector();

Element RootElement; 
NodeList nlRows=null;
Element elRow;

try {
     // --- Create URL ---
	Hashtable tbeans = (Hashtable)application.getAttribute("tbeans");
	String contentID = request.getParameter("contentID");
	if (contentID == null) {
		%>Need to supply a contentID<%
		return;
	}

	ConnectionPool connPool = ConnectionPool.getInstance();
	Connection conn = connPool.getConnection("cont_setup.jsp");
	Statement stmt = conn.createStatement();
	rs = stmt.executeQuery("select customer_id, template_id from ctm_pages where content_id = "+contentID);
	if (!rs.next()) {
		%>Error: Invalid Content ID<%
		return;
	}
	int templateID = rs.getInt(2);
	rs.close();
	stmt.close();
	if (conn != null) connPool.free(conn);

//	Grab a tbean from the Hashtable using the templateID key
	TemplateBean tbean = (TemplateBean)tbeans.get(new Integer(templateID));

//	Get the pbean corresponding to the contentID
	PageBean pbean = new PageBean(0, tbean);
	pbean.load(Integer.parseInt(contentID));
	
	String sXml = pbean.generateXML(application.getInitParameter("ImageURL"));

	// get rid of any potential 0x0
	String sXml2 = "";
	for (int x = 0; x < sXml.length(); x++) {
		if (sXml.charAt(x) != 0x0) {
			sXml2 += sXml.charAt(x);
		}
	}
	//System.out.println("sXml2 = " + sXml2);
	// --------------- Download Content ----------			

	RootElement = XmlUtil.getRootElement(sXml2);

	if (!RootElement.getNodeName().equals("ContentDef")) throw new Exception("Malformed content xml.");

	strWizardContentId = XmlUtil.getChildTextValue(RootElement, "ContentID");
	strStatus = XmlUtil.getChildTextValue(RootElement, "Status");
	strContentName = XmlUtil.getChildCDataValue(RootElement, "ContentName");
	strContentSendTypeID = XmlUtil.getChildTextValue(RootElement, "ContentSendTypeID");

	strContentText = XmlUtil.getChildCDataValue(RootElement, "ContentText");
	strContentHTML = XmlUtil.getChildCDataValue(RootElement, "ContentHTML");

	strContentText = CharReplacement.cleanChars(strContentText);
	strContentHTML = CharReplacement.cleanChars(strContentHTML);

	// ------ Tracking URLs ------
	String str1 = null;
	String str2 = null;
	String tmpUrl,tmpName;
	String str[];
	for (int i=1; i<=40; i++) {
		str1 = "TrackURL0" + ((i<10)?"0":"") + i;
		str2 = "TrackName0" + ((i<10)?"0":"") + i;
		tmpUrl = XmlUtil.getChildCDataValue(RootElement, str1);
		tmpName = XmlUtil.getChildCDataValue(RootElement, str2);
		if (tmpUrl != null && tmpName != null) {
			str = new String[2];
			str[0] = tmpUrl;
			str[1] = tmpName.replaceAll("'", "''");			
			vTrack.add(str);
		}
	}
} catch ( Exception e) {
     logger.error("Exception thrown during XML processing in cont_setup.jsp.", e);
}

// 3rd Step --- Save the information into the database ---
String strContentId = null;
String strInUse = "0";
String strSQL = null;
boolean newContent = false;
String strUnsubID = null;

try {
     // ------- Establish Database connection -------
     connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("cont_setup.jsp");
        srvConnection.setAutoCommit(false);
	sqlStatement = srvConnection.createStatement();			

	try {
		// --- Get content id corresponding with wizard content id ---
		strSQL = "SELECT cont_id FROM ccnt_cont_edit_info WHERE wizard_id = "+strWizardContentId;
		rs = sqlStatement.executeQuery(strSQL);
		if (rs.next()) strContentId = rs.getString(1);
		rs.close();
		
		newContent = (strContentId == null);

		rs = sqlStatement.executeQuery("SELECT TOP 1 msg_id FROM ccps_unsub_msg WHERE cust_id = "+sCustId); 
		if (rs.next()) 
			strUnsubID = rs.getString(1);

          if (newContent) {
               strContentId = NextId.get(sCustId,UniqueIdType.CONT_ID);
               if (strContentId == null) throw new Exception("Can not get ID for new content ...");
          }
     } catch (SQLException sqle) {
		  logger.error("SQL exception thrown attempting to retrieve content and/or unsub message info during cont_setup.jsp.", sqle);
          throw sqle;
     }

     // --- Set Status of the content ---
	strSQL = "Exec usp_ccnt_modify" + 
               "  @cont_id=" + strContentId + 
               ( (newContent)?", @new_cont=1 ":" ") +
               ", @type_id=20" +
               ", @cust_id=" + sCustId +
               ", @status_id=" + ((strStatus.equals("Draft"))?"10":"20") +
               ", @cont_name=?" +
               ", @charset_id=" + strContentSendTypeID +
               ", @unsub_msg_id=" + strUnsubID +
               ", @unsub_msg_position=1" +
               ", @send_text_flag="+(strContentText==null || strContentText.length() == 0?"0":"1") +
               ", @send_html_flag="+(strContentHTML==null || strContentHTML.length() == 0?"0":"1") +
               ", @send_aol_flag=0"+
               ", @user_id=" + sUserId;

	pstmt = srvConnection.prepareStatement(strSQL);
	pstmt.setBytes(1, strContentName.getBytes("ISO-8859-1"));
	rs = pstmt.executeQuery();

	if (rs.next()) {
		strContentId = rs.getString(1);
		rs.close();

		strSQL = "UPDATE ccnt_cont_edit_info SET wizard_id = " + strWizardContentId +
				" WHERE cont_id = " + strContentId;
		sqlStatement.executeUpdate(strSQL);

		// --- Blobs Text/HTML ---
		if (newContent)
			pstmt = srvConnection.prepareStatement(
					"INSERT ccnt_cont_body (cont_id, text_part, html_part) VALUES " +
					"("+strContentId+",?,?)");
		else
			pstmt = srvConnection.prepareStatement(
					"UPDATE ccnt_cont_body SET text_part=?, html_part=?"+
					" WHERE cont_id = "+strContentId);
		try {
			if (strContentText == null) pstmt.setString(1, strContentText);
			else pstmt.setBytes(1, strContentText.getBytes("UTF-8"));
			
			if (strContentHTML == null) pstmt.setString(2, strContentHTML);
			else pstmt.setBytes(2, strContentHTML.getBytes("UTF-8"));
						
			pstmt.execute();
		} catch (Exception e) {
			throw e;
		} finally {
			pstmt.close();
		}

		//--- Tracking ---
		sqlStatement.executeUpdate("DELETE cjtk_link WHERE cont_id = "+strContentId);

		String[] strTrack;
		if (vTrack.size() > 0){
			//Grab enough link_ids
			
			for(int i=0; i<vTrack.size(); i++) {
				strTrack =(String[]) vTrack.get(i);
					
				PreparedStatement psPD = srvConnection.prepareStatement(
						"Exec usp_ccnt_link_insert_bytes "+strContentId+",?,?,"+sCustId);
				psPD.setBytes(1,strTrack[1].getBytes("ISO-8859-1"));
				psPD.setString(2,strTrack[0]);
				psPD.execute();
				psPD.close();
			}
		}
			
	} else {
		rs.close();
		throw new Exception ("Could not save general content information!");
	}
	
	
	try
	{
		CategortiesControl.saveCategories(sCustId, ObjectType.CONTENT, strContentId, sCategories);
	}
	catch(Exception ex)
	{
		logger.error("cont_setup.jsp ERROR: unable to save categories.",ex);
	}
	
	
	srvConnection.commit();					

	// scan for link and save (should only be used by CTM templates)
	if (sScanLink != null && sScanLink.equals("1")) {
		// make sure customer has 'auto_link_scan_templates' feature 
		CustFeature cs = new CustFeature();
		if (cs.exists(sCustId, Feature.AUTO_LINK_SCAN_TEMPLATES)) {
			ContLinkScan cls = new ContLinkScan(sCustId, strContentId, null, true, true, true);
			boolean rc = cls.scanAndSave();
			logger.info("has auto link scan templates");
		}
		else {
			logger.info("does not have auto link scan templates");
		}
	}

} catch (Exception e){
        srvConnection.rollback();
	ErrLog.put(this,e,"cont_setup.jsp",out,1);
%>
     ERROR during cont_setup.jsp
<%
     return;
} finally {
	if (sqlStatement != null) sqlStatement.close();
	if (srvConnection!=null) {
            srvConnection.setAutoCommit(true);
            connectionPool.free(srvConnection);
        }
}
%>ok
