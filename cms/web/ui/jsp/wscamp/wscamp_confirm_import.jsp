<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.xcs.*,
			com.britemoon.cps.xcs.dts.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			org.w3c.dom.*,
			java.sql.*,
			java.io.*,
			java.net.*,
			java.util.*,
			java.util.zip.*,
			com.jscape.inet.sftp.*,
			com.jscape.inet.ssh.util.SshParameters,
			com.jscape.inet.http.Http,
			com.jscape.inet.http.HttpResponse,
			com.jscape.inet.http.HttpRequest,
			org.apache.commons.fileupload.*,
			org.apache.commons.fileupload.disk.*,
			org.apache.commons.fileupload.servlet.*,
			java.text.DateFormat,
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Get all component objects needed to display all Campaign data from web services
String sCampId = null;
String sWsCampId = null;
String sWsFileName = null;
String sWsSealId = null;

String sWsFileDate = null;
String sWsFileSize = null;

boolean bDownload = true; 


boolean isMultipart = ServletFileUpload.isMultipartContent(request);
if (isMultipart) {
	logger.info("found multipart");
	FileItemFactory factory = new DiskFileItemFactory();
	ServletFileUpload upload = new ServletFileUpload(factory);
	List items = upload.parseRequest(request);
	
	Iterator iter = items.iterator();
	while (iter.hasNext()) {
	    FileItem item = (FileItem) iter.next();
	    String name = item.getFieldName();
	    String value = null;
	    if (item.isFormField()) {
	        value = item.getString();
	    }
	    else {
	        value = item.getName();
	    }
        if (name.toLowerCase().equals("camp_id")) {
        	sCampId = value;
        }
        else if (name.toLowerCase().equals("ws_camp_id")) {
        	sWsCampId = value;
        }
        else if (name.toLowerCase().equals("ws_seal_id")) {
        	sWsSealId = value;
        }  
	    else if (name.toLowerCase().equals("ws_local_file_name")) {
	        sWsFileName = value;
	    }
	    logger.info("found param name = " + name + ", value = " + value);
	}
	
	String sWsShortFileName = sWsFileName.substring(sWsFileName.lastIndexOf(File.separator)+1);
	String myListFileName = Registry.getKey("import_data_dir") + File.separator + "c" + cust.s_cust_id + "_ws_list_" + sCampId + "_" + sWsShortFileName;
	
	logger.info("locally download file : " + sWsFileName);
	logger.info("short file name : " + sWsShortFileName);
	logger.info("dest file name : " + myListFileName);
	
	iter = items.iterator();
	boolean savedLocalFile = false;
	while (iter.hasNext() && !savedLocalFile) {
		FileItem item = (FileItem) iter.next();
	    if (!item.isFormField()) {
	        InputStream is = item.getInputStream();
			int BUFFER = 1024*5;
			int count;
			byte data[] = new byte[BUFFER];
			BufferedInputStream bis = new BufferedInputStream(is);
			FileOutputStream fos = new FileOutputStream(new File(myListFileName));
			BufferedOutputStream bos = new BufferedOutputStream(fos, BUFFER);
			while ((count = bis.read(data, 0, BUFFER)) != -1) {
				bos.write(data, 0, count);
				bos.flush();
			}
			bos.close();
		    bis.close();
	        is.close();
	        savedLocalFile = true;
	        logger.info("successfully saved file to " + myListFileName);
	    }
	}
	File myListFile = new File(myListFileName);
	sWsFileName = sWsShortFileName;
	sWsFileDate = DateFormat.getDateTimeInstance().format(new java.util.Date(myListFile.lastModified()));
	sWsFileSize = Long.toString(myListFile.length());
}
else {
	logger.info("regular form");
	sCampId = request.getParameter("camp_id");
	sWsCampId = request.getParameter("ws_camp_id");
	sWsFileName = request.getParameter("ws_file_name");
	sWsSealId = request.getParameter("ws_seal_id");

	//	get list file via sftp
	if (bDownload) {
		logger.info("calling sftp to retrieve datran list for id = " + sWsCampId);
		CustResource res = new CustResource(cust.s_cust_id, String.valueOf(CustResourceType.SFTP));

		String myFileName = Registry.getKey("import_data_dir") + File.separator + "c" + cust.s_cust_id + "_ws_list_" + sCampId + "_" + sWsFileName;
		String status = WsCampUtil.getSftpFile(res, sWsFileName, myFileName, bDownload);
		if (status.startsWith("0")) {
			logger.info("Error getting file from sftp: " + myFileName);
			Exception ex = new Exception("Error getting file from sftp: " + myFileName);
			ErrLog.put(this, ex, "Problem with WS Campaign.",out,1);
			return;
		}

		if (myFileName.toLowerCase().endsWith(".zip") && !WsCampUtil.verifyZipFile(myFileName)) { 
			logger.info("Invalid list Zip file");
			Exception ex = new Exception("Invalid list Zip file: " + myFileName);
			ErrLog.put(this, ex, "Problem with WS Campaign.",out,1);
			return;
		}
		String[] parts = status.split("\\|");
		sWsFileDate = parts[1];
		sWsFileSize = parts[2];
	}
	
}

logger.info("camp_id = " + sCampId);
logger.info("ws_camp_id = " + sWsCampId);
logger.info("ws_file_name = " + sWsFileName);
logger.info("ws_seal_id = " + sWsSealId);

// get unsub file via http
String myShortUnsubFileName = "ClickSeal_" + sWsSealId + ".zip";
String myUnsubFileName = Registry.getKey("import_data_dir") + File.separator + "c" + cust.s_cust_id + "_ws_unsub_" + sCampId + "_" + myShortUnsubFileName;
if (bDownload) {
	logger.info("calling http service to retrieve datran unsub list for id = " + sWsCampId);
	CustResource res = new CustResource(cust.s_cust_id, String.valueOf(CustResourceType.CLICK_SEAL_FILE));
	String myUrl = res.s_url;
	myUrl = myUrl.replace("!*username*!", res.s_username);
	myUrl = myUrl.replace("!*password*!", res.s_password);
	myUrl = myUrl.replace("!*clickseal*!", sWsSealId);
	if (!WsCampUtil.getHttpFile(myUrl, myUnsubFileName, bDownload)) {
		logger.info("Error getting file " + myUnsubFileName);
		Exception ex = new Exception("Error getting file: " + myUnsubFileName);
		ErrLog.put(this, ex, "Problem with WS Campaign.",out,1);
		return;
	}

	if (myUnsubFileName.toLowerCase().endsWith(".zip") && !WsCampUtil.verifyZipFile(myUnsubFileName)) { 
		logger.info("Invalid unsub Zip file");
		Exception ex = new Exception("Invalid unsub Zip file: " + myUnsubFileName);
		ErrLog.put(this, ex, "Problem with WS Campaign.",out,1);
		return;
	}
}

File myUnsubFile = new File(myUnsubFileName);
String sWsUnsubFileName = myShortUnsubFileName;
String sWsUnsubFileDate = DateFormat.getDateTimeInstance().format(new java.util.Date(myUnsubFile.lastModified()));
String sWsUnsubFileSize = Long.toString(myUnsubFile.length());

%>
<HTML>
<HEAD>
	<BASE target="_self">
	<%@ include file="../header.html"%>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>

<FORM METHOD="POST" NAME="FT" ACTION="wscamp_save_import.jsp" TARGET="_self">
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Campaign Import:</b> Save Confirmation</td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px; font-size:14pt;">
						Please confirm all import details before saving
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>

<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td width="125" height="25" align="left" valign="middle">List File Name: </td>
					<td width="425" height="25" align="left" valign="middle"><%=HtmlUtil.escape(sWsFileName)%> </td>
					<input type="hidden" name="ws_camp_id" value="<%=HtmlUtil.escape(sWsCampId)%>" />
					<input type="hidden" name="ws_file_name" value="<%=HtmlUtil.escape(sWsFileName)%>" />
				</tr>
				<tr>
					<td width="125" height="25" align="left" valign="middle">List File Date: </td>
					<td width="425" height="25" align="left" valign="middle"><%=HtmlUtil.escape(sWsFileDate)%> </td>
				</tr>
				<tr>
					<td width="125" height="25">List File Size: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(sWsFileSize) %></td>
				</tr>
				<tr>
					<td width="125" height="25">Click Seal File Name: </td>
					<td width="425" height="25">
						<%= HtmlUtil.escape(sWsUnsubFileName) %>
					</td>
					<input type="hidden" name="ws_seal_id" size="40" maxlength="40" value="<%=HtmlUtil.escape(sWsSealId)%>" >
					<input type="hidden" name="ws_unsub_file_name" value="<%= HtmlUtil.escape(sWsUnsubFileName) %>" />
				</tr>
				<tr>
					<td width="125" height="25">Click Seal File Date: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(sWsUnsubFileDate) %></td>
				</tr>
				<tr>
					<td width="125" height="25">Click Seal File Size: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(sWsUnsubFileSize) %></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>


<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" width="50%" style="padding:5px;">
						<table cellspacing="0" cellpadding="3" border="0">
							<tr>
								<td align="center" width="50%">
									<a class="subactionbutton" href="javascript:doEdit();"><< Go Back To Edit</a>
								</td>
								<td align="center" width="50%">
									<a class="actionbutton" href="javascript:doSave();">Confirm >> Save Import</a>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</FORM>

<SCRIPT>

function doSave()
{
	FT.submit();
}

function doEdit()
{
	FT.action = "wscamp_edit.jsp?ws_camp_id=<%=sWsCampId%>";
	FT.submit();
}

</SCRIPT>


</BODY>
</HTML>


