<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.CategortiesControl,
		com.britemoon.cps.imc.*,
		java.sql.*,java.util.*,
		java.io.*,java.net.*,
		java.text.DateFormat,org.w3c.dom.*,
		org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
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


String		USER_ID		= user.s_user_id;
String		CUSTOMER_ID	= cust.s_cust_id;

String sSelectedCategoryId = request.getParameter("category_id");
String 		sFileID = request.getParameter("file_id");

String		DELIMETER	= request.getParameter("delim");
String		EXPORT_NAME	= request.getParameter("export_name");
String		CUSTOM_EXP_ID = request.getParameter("exp_id");
String[]	PARAM_NAMES = request.getParameterValues("param_name");
String[]	PARAM_VALUES = request.getParameterValues("param_value");

String		PARAMS = "";
String		STORED_PROC = null;
String		FIXED_WIDTH_FLAG = null;
String		GENERIC_STORED_PROC_FLAG = null;

if (EXPORT_NAME != null) EXPORT_NAME = EXPORT_NAME.trim();

if (DELIMETER != null && !(DELIMETER.equals(",") || DELIMETER.equals(";") || DELIMETER.equals("|"))) {
	DELIMETER = "\t";
}

String outXml="";

// === === ===

Statement			stmt = null;
PreparedStatement	pstmt = null;
ResultSet			rs = null;
ConnectionPool 		cp = null;
Connection 			conn  = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("custom_export_save.jsp");
	stmt = conn.createStatement();

	rs = stmt.executeQuery("SELECT stored_proc, fixed_width_flag, ISNULL(generic_stored_proc_flag,0) FROM cexp_custom_export WHERE cstm_exp_id = "+CUSTOM_EXP_ID
						+ " AND cust_id = "+CUSTOMER_ID);
	if (rs.next())
	{
		STORED_PROC = rs.getString(1);
		FIXED_WIDTH_FLAG = rs.getString(2);
		GENERIC_STORED_PROC_FLAG = rs.getString(3);
	}
	rs.close();

	outXml = "<export>\n" +
			"<cust_id>"+CUSTOMER_ID+"</cust_id>\n" +
			"<stored_proc>"+STORED_PROC+"</stored_proc>\n" +
			"<delimiter>"+(DELIMETER.equals("\t")?"\\t":DELIMETER)+"</delimiter>\n" +
			"<generic_stored_proc_flag>"+GENERIC_STORED_PROC_FLAG+"</generic_stored_proc_flag>\n";
	outXml += (FIXED_WIDTH_FLAG!=null)?("<fixed_width_flag>"+FIXED_WIDTH_FLAG+"</fixed_width_flag>\n"):"";
	PARAMS += "Custom; stored_proc="+STORED_PROC+"; ";
	if (PARAM_NAMES != null)
	{
		for (int i=0 ; i < PARAM_NAMES.length ; i++) {
			outXml += "<parameter>\n"
				+ "<param_name>"+PARAM_NAMES[i]+"</param_name>\n"
				+ "<param_value><![CDATA["+PARAM_VALUES[i]+"]]></param_value>\n"
				+ "</parameter>\n";
			PARAMS += PARAM_NAMES[i]+"="+PARAM_VALUES[i]+"; ";
		}
	}
	PARAMS += "delimiter=''"+(DELIMETER.equals("\t")?"\\t":DELIMETER)+"''; ";

	if (sFileID != null)
		outXml += "<file_id>"+sFileID+"</file_id>\n";
	
	outXml += "</export>\n";

	//Send request to RCP

	String sMsg = Service.communicate(ServiceType.REXP_CUSTOM_EXPORT_START, CUSTOMER_ID, outXml);

	//Receive response and save export
	String fileUrl = "";
	try
	{
		Element eDetails = XmlUtil.getRootElement(sMsg);
		fileUrl = XmlUtil.getChildCDataValue(eDetails,"file_url");
		if (fileUrl == null)
		{
			//Probably an error
			String error = XmlUtil.getChildCDataValue(eDetails,"error");
			if (error == null)
				throw new Exception("");
			else
				throw new Exception(error);
		}
	}
	catch (Exception e)
	{
		throw new Exception("RCP could not setup the export.  Please check the RCP system: "+e.getMessage());
	}

	outXml = outXml.substring(0,outXml.indexOf("</export>"));
	outXml += "<type_id>"+ExportType.CUSTOM+"</type_id>\n";
	outXml += "<export_name>"+EXPORT_NAME+"</export_name>\n";
	outXml += "<file_url>"+fileUrl+"</file_url>\n";
	outXml += "<status_id>"+ExportStatus.QUEUED+"</status_id>\n";
	outXml += "<params>"+PARAMS+"</params>\n";
	outXml += "</export>\n";
		
	try
	{		
		CustomExport ce = new CustomExport(XmlUtil.getRootElement(outXml));
		Export exp = new Export(ce);
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

	pstmt = conn.prepareStatement("SELECT file_id FROM cexp_export_file WHERE file_url = '"+fileUrl+"'");
	rs = pstmt.executeQuery();
	if (!rs.next()) throw new Exception("Could not get file_id for new export");
	String fileID = rs.getString(1);

	if (sFileID == null)
		sFileID = fileID;

//------------------------- Categories -------
	
	String[] sCategories = request.getParameterValues("categories");
	int l = ( sCategories == null )?0:sCategories.length;
	if ( l > 0) 
		CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.EXPORT, fileID, request);
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
}
catch(Exception ex)
{
	ErrLog.put(this,ex,"custom_export_save.jsp",out,1);
}
finally
{
	try
	{
		if (pstmt != null) pstmt.close();
		if (stmt != null) stmt.close();
	}
	catch (SQLException se) { }
	if (conn != null) cp.free(conn);
}
%>
