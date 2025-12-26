<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.exp.*,
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

String CUSTOMER_ID	= cust.s_cust_id;
String 		sFileID = request.getParameter("file_id");

String sAction		= request.getParameter("Action").trim();
String FilterId		= request.getParameter("filter_id");
String VIEWFIELDS	= request.getParameter("view");
String DELIMITER	= request.getParameter("delim");
String EXPORT_NAME	= request.getParameter("export_name");

System.out.println("sAction = " + sAction);
System.out.println("FilterId = " + FilterId);
System.out.println("VIEWFIELDS = " + VIEWFIELDS);
System.out.println("DELIMITER = " + DELIMITER);
System.out.println("sFileID = " + sFileID);

String PARAMS = "";

if (EXPORT_NAME != null) EXPORT_NAME = EXPORT_NAME.trim();

if (DELIMITER != null) 
{
	if (DELIMITER.equals ("TAB"))
		DELIMITER = "\t";
	if (DELIMITER.equals (","))
		DELIMITER = ",";
	if (DELIMITER.equals (";"))
		DELIMITER = ";";
	if (DELIMITER.equals ("|"))
		DELIMITER = "|";		
}

PreparedStatement	pstmt = null;
Statement			stmt = null;
ResultSet			rs;
ConnectionPool 		cp = null;
Connection 			conn  = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("filter_stat_export_save.jsp");
	stmt = conn.createStatement();
	
	String sSql = null;
		
	PARAMS += sAction+"; filter_id="+FilterId+"; ";

	String outXml = "<RecipRequest>\r\n";

	if (sFileID != null)
		outXml += "<recip_id>"+sFileID+"</recip_id>\n";
		
	outXml += "<action>"+sAction+"</action>\r\n";
	outXml += "<cust_id>"+CUSTOMER_ID+"</cust_id>\r\n";
	outXml += "<filter_id>"+FilterId+"</filter_id>\r\n";
	outXml += "<num_recips>all</num_recips>\r\n";
	outXml += "<attr_list>"+VIEWFIELDS+"</attr_list>\r\n";
	outXml += "<delimiter>"+(DELIMITER.equals("\t")?"\\t":DELIMITER)+"</delimiter>\r\n";
	outXml += "</RecipRequest>\r\n";

	PARAMS += "attr_list="+VIEWFIELDS+"; delimiter=''"+(DELIMITER.equals("\t")?"\\t":DELIMITER)+"''; ";

	String sMsg = Service.communicate(ServiceType.REXP_EXPORT_SETUP, CUSTOMER_ID, outXml);

	String fileUrl = "";
	try
	{
		Element eDetails = XmlUtil.getRootElement(sMsg);
		fileUrl = XmlUtil.getChildCDataValue(eDetails,"file_url");
		if (fileUrl == null)
		{
			//Probably an error
			String error = XmlUtil.getChildCDataValue(eDetails,"error");
			if (error == null) throw new Exception("");
			else throw new Exception(error);
		}
	}
	catch (Exception e)
	{
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
		
	sSql = "SELECT file_id FROM cexp_export_file WHERE file_url = '"+fileUrl+"'";
	pstmt = conn.prepareStatement(sSql);
	rs = pstmt.executeQuery();
	if (!rs.next()) throw new Exception("Could not get file_id for new export");
	fileID = rs.getString(1);
	
	if (sFileID == null)
		sFileID = fileID;
	
	rs.close();
%>
<HTML>
<HEAD>
<title>Report Export</title>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script>
function gotoParent(url)
{
	if( opener != null )
	{
		opener.top.parent.location.href = url;
		self.close();
	}
	else
	{
		top.parent.location.href = url;
	}
}
</script>	
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
						<p align="center"><a href="javascript:gotoParent('../index.jsp?tab=Data&sec=3&url=<%= URLEncoder.encode("/export/export_list.jsp", "UTF-8") %>');">Go to Export List</a></p>
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
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (pstmt != null) pstmt.close();
	if (conn != null) cp.free(conn);
}
%>