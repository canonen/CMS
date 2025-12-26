<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.imc.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.CategortiesControl,
		java.sql.*,java.util.*,
		java.io.*,java.net.*,
		java.text.DateFormat,org.w3c.dom.*,
		org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

PreparedStatement	pstmt = null;
ResultSet			rs;
ConnectionPool 		cp = null;
Connection 			conn  = null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("export_save.jsp");
} catch(Exception ex) {
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

String sSelectedCategoryId = request.getParameter("category_id");
String 		sFileID = request.getParameter("file_id");

String		USER_ID		= user.s_user_id;
String		CUSTOMER_ID	= cust.s_cust_id;

String		VIEWFIELDS	= request.getParameter("view");
String		GROUP_SELECTED	= request.getParameter("GroupSelected");
String		CORRESPONDING_ID= request.getParameter("IdSelected");
String		ADDIT_STRING	= request.getParameter("AdditString");
String		DELIMETER	= request.getParameter("delim");
String		EXPORT_NAME	= request.getParameter("export_name");


String		PARAMS = "";

if (EXPORT_NAME != null)
	EXPORT_NAME = EXPORT_NAME.trim();

if (DELIMETER != null) 
{
	if (DELIMETER.equals ("TAB"))
		DELIMETER = "\t";
	if (DELIMETER.equals (","))
		DELIMETER = ",";
	if (DELIMETER.equals (";"))
		DELIMETER = ";";
	if (DELIMETER.equals ("|"))
		DELIMETER = "|";		
}
String outXml="";

try {

	outXml = "<RecipRequest>\n" +
			 "<cust_id>"+CUSTOMER_ID+"</cust_id>\n";
	if (sFileID != null)
		outXml += "<recip_id>"+sFileID+"</recip_id>\n";
	

	if (GROUP_SELECTED.equals ("1")) {	/* Campaign */
		outXml += "<camp_id>"+CORRESPONDING_ID+"</camp_id>\n";

		//4 types for campaign
		String campType = request.getParameter("which1");
		if (campType.equals("1")) {
			outXml += "<action>ExpCampSent</action>\n";
			PARAMS += "ExpCampSent; ";
		} else if (campType.equals("2")) {
			outXml += "<action>ExpCampRead</action>\n";
			PARAMS += "ExpCampRead; ";
		} else if (campType.equals("3")) {
			outXml += "<action>ExpCampBBack</action>\n";
			PARAMS += "ExpCampBBack; ";
		} else if (campType.equals("4")) {
			outXml += "<action>ExpCampUnsub</action>\n";
			PARAMS += "ExpCampUnsub; ";
		} else if (campType.equals("5")) {
			outXml += "<action>ExpCampClick</action>\n";
			PARAMS += "ExpCampClick; ";
		} else {
			throw new Exception("Invalid type of campaign");
		}

		PARAMS += "camp_id="+CORRESPONDING_ID+"; ";

	} else if (GROUP_SELECTED.equals ("1b")) {	/* Click-Thrus */
	
		String linkID = CORRESPONDING_ID.substring(CORRESPONDING_ID.indexOf(":")+1);
		CORRESPONDING_ID = CORRESPONDING_ID.substring(0,CORRESPONDING_ID.indexOf(":"));
	
		outXml += "<action>ExpCampLinkClick</action>\n" +
				  "<camp_id>"+CORRESPONDING_ID+"</camp_id>\n" +
				  "<link_id>"+linkID+"</link_id>\n";

		PARAMS += "ExpCampLinkClick; camp_id="+CORRESPONDING_ID+"; link_id="+linkID+"; ";
		
	} else if (GROUP_SELECTED.equals ("2")) {	/* Target group */
		outXml += "<action>ExpTgt</action>\n" +
				  "<filter_id>"+CORRESPONDING_ID+"</filter_id>\n";

		PARAMS += "ExpTgt; filter_id="+CORRESPONDING_ID+"; ";

	} else if (GROUP_SELECTED.equals ("3")) {	/* Batch */
		outXml += "<action>ExpBatch</action>\n" +
				  "<batch_id>"+CORRESPONDING_ID+"</batch_id>\n";

		PARAMS += "ExpBatch; batch_id="+CORRESPONDING_ID+"; ";

	} else if (GROUP_SELECTED.equals ("4")) {	/* Bounce Backs */
		outXml += "<action>ExpBBack</action>\n";

		PARAMS += "ExpBBack; ";

	} else if (GROUP_SELECTED.equals ("5"))	{ /* Unsubscribes */
		outXml += "<action>ExpUnsub</action>\n";

		PARAMS += "ExpUnsub; ";

	} else {
		throw new Exception ();
	}

	outXml += "<num_recips>all</num_recips>\n" +
			  "<attr_list>"+VIEWFIELDS+"</attr_list>\n" +
			  "<delimiter>"+(DELIMETER.equals("\t")?"\\t":DELIMETER)+"</delimiter>\n" +
			  "</RecipRequest>\n";

	PARAMS += "attr_list="+VIEWFIELDS+"; delimiter=''"+(DELIMETER.equals("\t")?"\\t":DELIMETER)+"''; ";

	//Send request to RCP	
	String sMsg = Service.communicate(ServiceType.REXP_EXPORT_SETUP, CUSTOMER_ID, outXml);
	
	//Receive response and save export
	String fileUrl = "";
	try {

		Element eDetails = XmlUtil.getRootElement(sMsg);

		fileUrl = XmlUtil.getChildCDataValue(eDetails,"file_url");
		if (fileUrl == null) {
			//Probably an error
			String error = XmlUtil.getChildCDataValue(eDetails,"error");
			if (error == null)
				throw new Exception("");
			else
				throw new Exception(error);
		}
	} catch (Exception e) {
		throw new Exception("RCP could not setup the export.  Please check the RCP system: "+e.getMessage());
	}
	
	outXml = outXml.substring(0,outXml.indexOf("</RecipRequest>"));
	outXml += "<type_id>"+ExportType.STANDARD+"</type_id>\n";
	outXml += "<export_name>"+EXPORT_NAME+"</export_name>\n";
	outXml += "<file_url>"+fileUrl+"</file_url>\n";
	if (fileUrl == null) {
	outXml += "<status_id>"+ExportStatus.ERROR+"</status_id>\n";
	} else {
	outXml += "<status_id>"+ExportStatus.QUEUED+"</status_id>\n";
	}
	outXml += "<params>"+PARAMS+"</params>\n";
	outXml += "</RecipRequest>\n";
		
	try
	{		
		RecipList rl = new RecipList(XmlUtil.getRootElement(outXml));
		Export exp = new Export(rl);
		exp.save();
		
		//Send back the URL of the export text file
		String returnXml =
			"<export><file_url><![CDATA["+exp.s_file_url+"]]></file_url></export>";
		out.print(returnXml);
	}
	catch (Exception e)
	{
		logger.error("Exception: ", e);

		String returnXml =
			"<export><error><![CDATA["+e.getMessage()+"]]></error></export>";
		
		out.print(returnXml);
	}
	String fileID = null;
	
	pstmt = conn.prepareStatement("SELECT file_id FROM cexp_export_file WHERE file_url = '"+fileUrl+"'");
	rs = pstmt.executeQuery();
	if (!rs.next()) throw new Exception("Could not get file_id for new export");
	fileID = rs.getString(1);
	
	if (sFileID == null)
		sFileID = fileID;
		
	//------------------------- Categories -------
		
		String[] sCategories = request.getParameterValues("categories");
		int l = ( sCategories == null )?0:sCategories.length;
		
		if ( l > 0) 
			CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.EXPORT, sFileID, request);
	%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader><b class=sectionheader>Export:</b> Processing</td>
	</tr>
</table>
<br>
<!---- Info----->
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
						<p align="center">The export has been queued.</p>
						<p align="center"><a href="export_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a></p>
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
	ErrLog.put(this,ex,"export_save.jsp",out,1);
	return;
} finally {
	if (pstmt != null) pstmt.close();
	if (conn != null) cp.free(conn);
}

%>
