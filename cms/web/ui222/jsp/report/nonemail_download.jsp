<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			javax.servlet.http.*,
			javax.servlet.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%!
	String MyMessage = "";
	static Logger logger = null; 
	protected String getParameterName (String sSource)	throws Exception
	{
		String sParamName = null;
		String sSearch = "name=\"";
		int nBeginning = sSource.indexOf (sSearch) + sSearch.length();
		int nEnd = sSource.indexOf ("\"", nBeginning);
		MyMessage = "PN: " + sSource + " " + nBeginning + " " + nEnd;
		sParamName = sSource.substring (nBeginning, nEnd);
		return sParamName;
	}


	protected String getParameterValue (String sSource)	throws Exception
	{
		String sParamName = null;
		String sSearch = "filename=\"";
		int nBeginning = sSource.indexOf (sSearch) + sSearch.length();
		int nEnd = sSource.indexOf ("\"", nBeginning);
		MyMessage = "PV: " + sSource + " " + nBeginning + " " + nEnd;
		sParamName = sSource.substring (nBeginning, nEnd);
		// look for last file separator to get only filename, without path
		int nLastSeparator = sParamName.lastIndexOf (File.separator);
		if (nLastSeparator != -1)
		{
			MyMessage = "PV2: " + sParamName + " " + nLastSeparator;
			sParamName = sParamName.substring (nLastSeparator + 1);
		}
		return sParamName;
	}
%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}


//======================================================================

ServletInputStream in = request.getInputStream();
	
//======================================================================
	
byte[] buf = new byte[16384];
int nBufLength = buf.length;
String sDataString = "";
int nDataRead = 0;

String sRequestDelimiter = "";
int nRequestDelimiterLength = 0;
String sHeaderString = "";
String sParamName = "";
String sParamValue = "";		
String sOnServerFlatFileName = "";
String sImportUrl = "";
String sDataDir = "";

String sDetailXML = "";

boolean bIsNameParamSet=false;
boolean bIsContentTypeParamSet=false;
String sCRLF = "\r\n";

Statement stmt = null;
PreparedStatement prepStmt = null;
ResultSet rs = null; 
ConnectionPool connectionPool = null;
Connection conn = null;

String sImportID = null;

try	{	
	//======================================================================

	nRequestDelimiterLength = in.readLine (buf, 0, nBufLength) - sCRLF.length();
	sRequestDelimiter = new String (buf, 0, nRequestDelimiterLength);
	nDataRead = nRequestDelimiterLength;
	
	//======================================================================		
	HashMap aImportParameters = new HashMap();
	while (nDataRead > 0) {
		bIsNameParamSet=false;
		bIsContentTypeParamSet=false;
				
		while((nDataRead = in.readLine(buf, 0, nBufLength)) > 0) {	
			sHeaderString = new String (buf, 0, nDataRead);
			if (sHeaderString.equals("\r\n"))  break;
			if (!bIsNameParamSet) {
				bIsNameParamSet = ((sParamName = getParameterName (sHeaderString)) != null);
				if (sParamName.indexOf ("recipient_file") != -1) {
					sParamValue = getParameterValue (sHeaderString);
					if (sParamValue == null)    sParamValue = "unknown_name";
				}
			}
			if (!bIsContentTypeParamSet) {
				bIsContentTypeParamSet = (sHeaderString.indexOf ("Content-Type:") != -1) ? true : false;
			}
		}

		if (bIsContentTypeParamSet) {
			aImportParameters.put (sParamName, sParamValue);			
			break;
		} else {
			sParamValue = "";
			while ((nDataRead = in.readLine (buf, 0, nBufLength)) > 0) { 
				sDataString = new String (buf, 0, nDataRead);
				if(sDataString.startsWith (sRequestDelimiter))  break;
				else {
					if  (sParamValue.length() == 0)   sParamValue = sDataString;
					else sParamValue = sParamValue + "\r\n" + sDataString;
				}
				aImportParameters.put (sParamName, sParamValue);
			}
		}
	}
		
	//======================================================================

	String sUserFilename = aImportParameters.get("recipient_file").toString();
	sUserFilename = sUserFilename.trim ();

	String sCampID = aImportParameters.get("camp_id").toString();
	sCampID = sCampID.trim ();

	//=== GET CONNECTION FROM CONNECTION POOL ==================================
	connectionPool = ConnectionPool.getInstance();
	conn = connectionPool.getConnection("nonemail_download.jsp");
	stmt = conn.createStatement();

	//==== Read Import Dir from XML file =======================================
	ServletContext SrvCont = getServletConfig().getServletContext();
	sDataDir = Registry.getKey("import_data_dir");
	sImportUrl = Registry.getKey("import_url_dir");

	//==== Get filename to save into ===========================================
	sOnServerFlatFileName = sUserFilename.replace(' ','_')  + "_" + cust.s_cust_id + "_" + new java.util.Date().getTime();

	//=== Download file to local disk under the name of (...) ===================================
	File fOutFile = new File (sDataDir + sOnServerFlatFileName);
	FileOutputStream fosOutFile = new FileOutputStream (fOutFile);
	while ((nDataRead = in.readLine (buf, 0, nBufLength)) > 0) {
		sDataString = new String (buf, 0, nRequestDelimiterLength);
		if (sDataString.startsWith (sRequestDelimiter))  break;
		fosOutFile.write (buf, 0, nDataRead);
	}
	fosOutFile.close();

	//=== Erase last empty string in just downloaded file (if any) =============================
	long len;
	byte[] buff = new byte [2];
	RandomAccessFile fraFile = new RandomAccessFile (fOutFile, "rw");
	while (true) {
		len = fraFile.length ();
		if (len < 2)	
			break;
		fraFile.seek (len-2);
		fraFile.read (buff);

		if (buff [0] == 0xD && buff [1] == 0xA ||
		    buff [0] == 0xA && buff [1] == 0xD)
			fraFile.setLength(len-2);
		else 	break;
	}
	fraFile.close();

	//=== Add new import (and new Batch, if needed) ============================================
	String sAddNewImport = "EXECUTE usp_crpt_nonemail_import_add @cust_id=?, @camp_id=?, "
		+ "@import_url=?, @import_filename=?, @import_user=?";

	prepStmt = conn.prepareStatement(sAddNewImport);
	prepStmt.setString(1, cust.s_cust_id);
	prepStmt.setString(2, sCampID);
	prepStmt.setString(3, sImportUrl);
	prepStmt.setString(4, sOnServerFlatFileName);
	prepStmt.setString(5, user.s_user_id);

	MyMessage = "EXECUTE usp_crpt_nonemail_import_add @cust_id="+cust.s_cust_id+", @camp_id="+sCampID+","
		+ "@import_url="+sImportUrl+", @import_filename="+sOnServerFlatFileName
		+ ", @import_user="+user.s_user_id;

	rs = prepStmt.executeQuery();
	rs.next();
	sImportID = rs.getString(1);

	sDetailXML += "<nonemail_import>\r\n";
	sDetailXML += "<cust_id>"+cust.s_cust_id+"</cust_id>\r\n";
	sDetailXML += "<camp_id>"+sCampID+"</camp_id>\r\n";
	sDetailXML += "<import_file><![CDATA["+sOnServerFlatFileName+"]]></import_file>\r\n";
	sDetailXML += "<import_url><![CDATA["+sImportUrl+"]]></import_url>\r\n";
	sDetailXML += "</nonemail_import>\r\n";
	MyMessage = "XML: " + sDetailXML;
	
	Service service = null;
	Vector services = Services.getByCust(ServiceType.RQUE_CAMP_NONEMAIL_IMPORT_SETUP, cust.s_cust_id);

	service = (Service) services.get(0);
	service.connect();
	service.send(sDetailXML);
	MyMessage = service.receive();
	service.disconnect();

	String sNumRecips = "0";
	Element e = null;
	try {
		e = XmlUtil.getRootElement(MyMessage);
		sNumRecips =  XmlUtil.getChildTextValue(e, "num_recips");
		
		MyMessage = "UPDATE crpt_nonemail_import"
				+ " SET num_recips = "+sNumRecips
				+ " WHERE import_id = "+sImportID;

		stmt.executeUpdate("UPDATE crpt_nonemail_import"
				+ " SET num_recips = "+sNumRecips
				+ " WHERE import_id = "+sImportID);

	} catch (Exception ex) {
		logger.error("Problem sending xml:\r\n" + sDetailXML,ex);
		throw new Exception ("Problem sending xml:\r\n"+sDetailXML+"\r\n"+MyMessage);
	}
	
	fOutFile.delete();
%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>File:</b> Downloaded</td>
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
						<b>The file was transmitted and uploaded.</b>
						<br><br>
						<b>There was <%= sNumRecips %> recipient(s) in the file.</b>
						<P align="center"><a href="report_list.jsp">Back to List</a></P>
						<P align="center"><a href="report_object.jsp?act=VIEW&id=<%= sCampID %>">Back to Report</a></P>
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

} catch (Exception ex) {
	ErrLog.put(this, ex, "Error in nonemail_download: "+ MyMessage, out, 1);
} finally {
	if ( prepStmt != null ) prepStmt.close ();	
	if ( stmt != null ) stmt.close ();
	if ( conn != null ) connectionPool.free(conn);
}

%>
