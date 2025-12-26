<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.imc.*,
		java.io.*,java.util.*,
		java.sql.*,java.net.*,
		javax.servlet.http.*,
		javax.servlet.*,
		org.w3c.dom.*,org.apache.log4j.*"
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
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bWrite)
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

boolean isCommited = false;
String sImportID = null;

String fileData = "";

ConnectionPool cp	= null;
Connection conn		= null;

try
{
	//======================================================================

	nRequestDelimiterLength = in.readLine (buf, 0, nBufLength) - sCRLF.length();
	sRequestDelimiter = new String (buf, 0, nRequestDelimiterLength);
	nDataRead = nRequestDelimiterLength;
	
	//======================================================================		
	
	HashMap aImportParameters = new HashMap();
	while (nDataRead > 0)
	{
		bIsNameParamSet=false;
		bIsContentTypeParamSet=false;
				
		while((nDataRead = in.readLine(buf, 0, nBufLength)) > 0)
		{	
			sHeaderString = new String (buf, 0, nDataRead);
			if (sHeaderString.equals("\r\n"))  break;
			if (!bIsNameParamSet)
			{
				bIsNameParamSet = ((sParamName = getParameterName (sHeaderString)) != null);
				if (sParamName.indexOf ("cont_file") != -1)
				{
					sParamValue = getParameterValue (sHeaderString);
					if (sParamValue == null)    sParamValue = "unknown_name";
				}
			}
			if (!bIsContentTypeParamSet)
			{
				bIsContentTypeParamSet = (sHeaderString.indexOf ("Content-Type:") != -1) ? true : false;
			}
		}

		if (bIsContentTypeParamSet)
		{
			aImportParameters.put (sParamName, sParamValue);			
			break;
		}
		else
		{
			sParamValue = "";
			while ((nDataRead = in.readLine (buf, 0, nBufLength)) > 0)
			{ 
				sDataString = new String (buf, 0, nDataRead);
				if(sDataString.startsWith (sRequestDelimiter))  break;
				else
				{
					if  (sParamValue.length() == 0)   sParamValue = sDataString;
					else sParamValue = sParamValue + "\r\n" + sDataString;
				}
				aImportParameters.put (sParamName, sParamValue);
			}
		}
	}
		
	//======================================================================

	String sUserFilename = aImportParameters.get("cont_file").toString();
	sUserFilename = sUserFilename.trim ();

	while ((nDataRead = in.readLine (buf, 0, nBufLength)) > 0)
	{
		sDataString = new String (buf, 0, nRequestDelimiterLength);
		if (sDataString.startsWith (sRequestDelimiter))  break;
		fileData += new String(buf, 0, nDataRead, "ISO-8859-1");
	}
	
	//Have file xml contents in fileData variable, parse it
	Element RootElement = XmlUtil.getRootElement(fileData);

	if(!RootElement.getNodeName().equals("content_update"))
		throw new Exception("Malformed content xml.  Must begin with <content_update> tags.");
	
	Element eParagraphs = XmlUtil.getChildByName(RootElement, "paragraphs");
	if (eParagraphs == null)
		throw new Exception("Malformed content xml.  Can must contain exactly one <paragraphs> tag");
	
	NodeList nl = XmlUtil.getChildrenByName(eParagraphs, "paragraph");
	int iLength = nl.getLength();
	if(iLength == 0) throw new Exception("Malformed content xml.  No <paragraph> tag(s).");

	// === === ===

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);

	String paraID, paraName, charsetID, textPart, aolPart, htmlPart;	
	String sSql = null;
	for(int i = 0; i < iLength; i++)
	{
		Element ParaElement = (Element)nl.item(i);
		
		paraID = XmlUtil.getChildTextValue(ParaElement, "paragraph_id");
		paraName = XmlUtil.getChildCDataValue(ParaElement, "paragraph_name");
		charsetID = XmlUtil.getChildTextValue(ParaElement, "charset_id");
		textPart = XmlUtil.getChildCDataValue(ParaElement, "text_part");
		aolPart = XmlUtil.getChildCDataValue(ParaElement, "aol_part");
		htmlPart = XmlUtil.getChildCDataValue(ParaElement, "html_part");

		if (textPart != null && textPart.trim().length() == 0) textPart = null;
		if (aolPart != null && aolPart.trim().length() == 0) aolPart = null;
		if (htmlPart != null && htmlPart.trim().length() == 0) htmlPart = null;

		sSql =
			" EXEC usp_ccnt_modify" +
			"  @cont_id=" + paraID +
			", @type_id=30" +
			", @cust_id=" + cust.s_cust_id +
			", @status_id=20" +
			", @cont_name=?" +
			", @charset_id=" + charsetID +
			", @unsub_msg_id=null" +
			", @unsub_msg_position=null" +
			", @send_text_flag="+(textPart==null?"0":"1") +
			", @send_html_flag="+(htmlPart==null?"0":"1") +
			", @send_aol_flag=0" + //(aolPart==null?"0":"1");
			", @user_id=" + user.s_user_id;
		
		PreparedStatement pstmt = null;		
		paraID = null;
		try
		{
			pstmt = conn.prepareStatement(sSql);

			pstmt.setBytes(1, paraName.getBytes("ISO-8859-1"));
			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) paraID = rs.getString(1);
			rs.close();
		}
		catch(Exception ex) { throw ex; }
		finally { if (pstmt!=null) pstmt.close(); }

		if(paraID == null) return;

		// === === ===

		ContBody cb = new ContBody();
		
		cb.s_cont_id = paraID;
		cb.s_html_part = htmlPart;
		cb.s_text_part = textPart;
		cb.s_aol_part = null;
		
		cb.save(conn);
	}
}
catch (Exception ex)
{
	logger.error("Exception:",ex);
//	throw ex;
}
finally { if (conn!=null) cp.free(conn); }
%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Content Block:</b> File Loaded</td>
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
						<b>The content block file was loaded.</b>
						<P align="center"><a href="cont_block_list.jsp">Back to List</a></P>
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

<%!
	String MyMessage = "";

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
