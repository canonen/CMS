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

String sSelectedCategoryId = request.getParameter("category_id");

String CUSTOMER_ID	= cust.s_cust_id;

String sAction		= request.getParameter("Action").trim();
String CampId 		= request.getParameter("Q");
String LinkId		= request.getParameter("H");
String ContentType	= request.getParameter("T");
String FormId		= request.getParameter("F");
String sMax			= request.getParameter("Max");
String BBackCatId	= request.getParameter("B");
String UnsubLevelId	= request.getParameter("S");
String Domain		= request.getParameter("D");
String NewsletterId	= request.getParameter("N");
String Cache		= request.getParameter("Z");
String CacheID		= request.getParameter("C");
Cache = ("1".equals(Cache))?Cache:"0";
CacheID = (CacheID==null||"".equals(CacheID))?"0":CacheID;

String VIEWFIELDS	= request.getParameter("view");
String DELIMITER	= request.getParameter("delim");
String EXPORT_NAME	= request.getParameter("export_name");

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
	conn = cp.getConnection("report_export_save.jsp");
	stmt = conn.createStatement();

	String sCacheStartDate = null;
	String sCacheEndDate = null;
	String sCacheAttrID = null;
	String sCacheAttrValue1 = null;
	String sCacheAttrValue2 = null;
	String sCacheAttrOperator = null;
	String sCacheUserID = "0";
	
	String sSql = null;
		
	if ("1".equals(Cache))
	{
		sSql = 
			" SELECT cache_start_date, cache_end_date," +
			" attr_id, attr_value1, attr_value2, attr_operator, user_id" +
			" FROM crpt_camp_summary_cache" +
			" WHERE camp_id = " + CampId +
			" AND cache_id = " + CacheID;
			
		rs = stmt.executeQuery(sSql);
		if (rs.next())
		{
			sCacheStartDate = rs.getString(1);
			sCacheEndDate = rs.getString(2);
			sCacheAttrID = rs.getString(3);
			byte [] bval = rs.getBytes(4);
			sCacheAttrValue1 = (bval!=null?(new String(bval, "UTF-8")).trim():null);
			bval = rs.getBytes(5);
			sCacheAttrValue2 = (bval!=null?(new String(bval, "UTF-8")).trim():null);
			sCacheAttrOperator = rs.getString(6);
			sCacheUserID = rs.getString(7);
				
			if ( (sCacheUserID == null) || (sCacheUserID.equals("")) ) sCacheUserID = "0";
		}
		rs.close();
	}

	PARAMS += sAction+"; camp_id="+CampId+"; ";

	String outXml = "<RecipRequest>\r\n";
	
	outXml += "<action>"+sAction+"</action>\r\n";
	outXml += "<cust_id>"+CUSTOMER_ID+"</cust_id>\r\n";
	outXml += "<camp_id>"+CampId+"</camp_id>\r\n";
	if ((LinkId != null) && !(LinkId.equals("")))
	{
		outXml += "<link_id>"+LinkId+"</link_id>\r\n";
		PARAMS += "link_id="+LinkId+"; ";
	}
	if ((ContentType != null) && !(ContentType.equals("")))
	{
		outXml += "<content_type>"+ContentType+"</content_type>\r\n";
		PARAMS += "content_type="+ContentType+"; ";
	}
	if ((FormId != null) && !(FormId.equals("")))
	{
		outXml += "<form_id>"+FormId+"</form_id>\r\n";
		PARAMS += "form_id="+FormId+"; ";
	}
	if ((BBackCatId != null) && !(BBackCatId.equals("")))
	{
		outXml += "<bback_category>"+BBackCatId+"</bback_category>\r\n";
		PARAMS += "bback_category="+BBackCatId+"; ";
	}
	if ((UnsubLevelId != null) && !(UnsubLevelId.equals("")))
	{
		outXml += "<unsub_level>"+UnsubLevelId+"</unsub_level>\r\n";
		PARAMS += "unsub_level="+UnsubLevelId+"; ";
	}
	if ((Domain != null) && !(Domain.equals("")))
	{
		outXml += "<domain><![CDATA["+Domain+"]]></domain>\r\n";
		PARAMS += "domain="+Domain+"; ";
	}
	if ((NewsletterId != null) && !(NewsletterId.equals("")))
	{
		outXml += "<newsletter_id>"+NewsletterId+"</newsletter_id>\r\n";
		PARAMS += "newsletter="+NewsletterId+"; ";
	}
	if ((CacheID != null) && !(CacheID.equals("")))
	{
		outXml += "<cache_id>"+CacheID+"</cache_id>\r\n";
		PARAMS += "cache_id="+CacheID+"; ";
	}
	if (sCacheStartDate != null)
	{
		outXml += "<cache_start_date><![CDATA["+sCacheStartDate+"]]></cache_start_date>\r\n";
		PARAMS += "start_date="+sCacheStartDate+"; ";
	}
	if (sCacheEndDate != null)
	{
		outXml += "<cache_end_date><![CDATA["+sCacheEndDate+"]]></cache_end_date>\r\n";
		PARAMS += "end_date="+sCacheEndDate+"; ";
	}
	if (sCacheAttrID != null)
	{
		outXml += "<cache_attr_id>"+sCacheAttrID+"</cache_attr_id>\r\n";
		PARAMS += "attr_id="+sCacheAttrID+"; ";
	}
	if (sCacheAttrValue1 != null)
	{
		outXml += "<cache_attr_value1><![CDATA["+sCacheAttrValue1+"]]></cache_attr_value1>\r\n";
		PARAMS += "attr_value1="+sCacheAttrValue1+"; ";
	}
	if (sCacheAttrValue2 != null)
	{
		outXml += "<cache_attr_value2><![CDATA["+sCacheAttrValue2+"]]></cache_attr_value2>\r\n";
		PARAMS += "attr_value2="+sCacheAttrValue2+"; ";
	}
	if (sCacheAttrOperator != null)
	{
		outXml += "<cache_attr_operator>"+sCacheAttrOperator+"</cache_attr_operator>\r\n";
		PARAMS += "attr_operator="+sCacheAttrOperator+"; ";
	}
	if (sCacheUserID != null)
	{
		outXml += "<cache_user_id>"+sCacheUserID+"</cache_user_id>\r\n";
		PARAMS += "user_id="+sCacheUserID+"; ";
	}
	outXml += "<num_recips>all</num_recips>\r\n";
	outXml += "<attr_list>"+VIEWFIELDS+"</attr_list>\r\n";
	outXml += "<delimiter>"+DELIMITER+"</delimiter>\r\n";
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
	
		
	sSql = "SELECT file_id FROM cexp_export_file WHERE file_url = '"+fileUrl+"'";
	pstmt = conn.prepareStatement(sSql);
	rs = pstmt.executeQuery();
	if (!rs.next()) throw new Exception("Could not get file_id for new export");
	String fileID = rs.getString(1);
	rs.close();
		
	//------------------------- Categories -------
		
	String[] sCategories = request.getParameterValues("categories");
	int l = ( sCategories == null )?0:sCategories.length;	
	if ( l > 0) 
		CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.EXPORT, fileID, request);
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
						<p align="center"><a href="javascript:gotoParent('../index.jsp?tab=Data&sec=3&url=<%= URLEncoder.encode("export/export_list.jsp" + ((sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""), "UTF-8") %>');">Go to Export List</a></p>
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