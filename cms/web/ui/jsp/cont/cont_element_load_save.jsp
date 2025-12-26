<%@ page
	language="java"
	import="com.oreilly.servlet.multipart.*,
		com.oreilly.servlet.multipart.Part,
		com.britemoon.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.*,
		java.io.*,java.util.*,
		java.sql.*,javax.servlet.http.*,
		javax.servlet.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
    if(logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    if(!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    Statement stmt = null;
    PreparedStatement prepStmt = null;
    ResultSet rs = null;
    ConnectionPool connectionPool = null;
    Connection srvConnection = null;

    try	{
        connectionPool = ConnectionPool.getInstance();
        srvConnection = connectionPool.getConnection("cont_load_save.jsp");
        stmt = srvConnection.createStatement();


        String sSelectedCategoryId = null;
        String[] sCategories;
        Vector vCategories = new Vector();
        String sContentName = "";
        String sFileName = null, sFolderName = null, sFolderId = null,sAutoLinkScan = null, sUseAnchorName=null, sUseLinkRenaming=null, sReplaceScannedLinks=null;
        String sCharset = null, sUnsubMsgId = null, sUnsubPos = null;
        String sRedirectUrl = null;
        Vector vSavedFiles = new Vector();
        Vector vErroredFiles = new Vector();
        Vector vZipFiles = new Vector();
        Vector vContentGroup = new Vector();
        String sProcessedMsg = null;
        boolean bZipProcessed = false, bTextProcessed = false;
        boolean bHtmlProcessed = true, bImageProcessed = true;
        boolean bErrors = false;
        FilePart fpContFile = null;
        Part myPart = null;
        int iFileId = 1;

        // First get the ID for the root content load Folder.  If this customer has no root content load folder, create it.
        String sContLoadFolderId = null;
        sContLoadFolderId = ContLoadUtil.getContLoadRoot(cust.s_cust_id);
        if (sContLoadFolderId == null) {
            sContLoadFolderId = ContLoadUtil.createContLoadRoot(cust.s_cust_id, user.s_user_id);
        }


        ImgFolder contLoadFolder = new ImgFolder(sContLoadFolderId);


        //Have a 10 Meg limit as default
        int iTotalFileSizeLimit = ImageHostUtil.getTotalFileSizeLimit(cust.s_cust_id);
        int iTotalFileSizeUsed = ImageHostUtil.getTotalFileSizeUsed(cust.s_cust_id);
        int iFileSizeLimit = ImageHostUtil.getFileSizeLimit(cust.s_cust_id);
        if (iTotalFileSizeLimit == 0)
            iTotalFileSizeLimit = 10240000;
        MultipartParser mp = null;

        try {
            mp = new MultipartParser(request, iTotalFileSizeLimit);
        } catch (Exception e) {
            mp = null;
            String sError = "No files were saved.  Upload exceded total file size limit for customer.";
            vErroredFiles.add(sError);
            bErrors = true;
        }

        String sLoadId = ContLoadUtil.startLoad(cust.s_cust_id);
 
        if (mp != null) {
            while ((myPart = mp.readNextPart()) != null && !bErrors) {
                //System.out.println(" Dealing with part:" + myPart.getName());

                if (myPart.getName().equals("category_id")) {
                    sSelectedCategoryId = ((ParamPart)myPart).getStringValue();
                }
                if (myPart.getName().equals("categories")) {
                    vCategories.add(((ParamPart)myPart).getStringValue());
                }
                if (myPart.getName().equals("contentName")) {
                    sContentName = ((ParamPart)myPart).getStringValue();
                }

                if (myPart.getName().equals("SendTypes")) {
                    sCharset = ((ParamPart)myPart).getStringValue();
                    if (sCharset.length() == 0)
                        sCharset = null;
                }

                //System.out.println("\n++  myPart.getName = " + myPart.getName());
                if (myPart.isFile()) {
                    fpContFile = (FilePart) myPart;
                    if (fpContFile != null && fpContFile.getFileName() != null) {
                        sFileName = fpContFile.getFileName();
    //  Zip upload does not change lower case
    //                         sFileName = sFileName.replace(' ','_');
    //                         sFileName = sFileName.toLowerCase();
                        try {
                            // check file extension to see if it is a ZIP file
                            if (myPart.getName().equals("zip_file")) {
                                if (ImageHostUtil.isZipFile(sFileName)) {
                                    vZipFiles = ContLoadUtil.processZipFileWithMultipleContentElements(fpContFile, cust.s_cust_id, iFileId++, sLoadId, sContLoadFolderId, sFileName, user.s_user_id);
                                    String sTemp = null;
                                    Iterator itZipFiles = vZipFiles.iterator();
                                    bZipProcessed = true;
                                    while (itZipFiles.hasNext()) {
                                        sTemp = (String)itZipFiles.next();
                                        if (sTemp.indexOf("Error") != -1) {    // an element of the ZIP file caused an error in ContLoadUtil
                                            //System.out.println("Error while processing ZIP: " + sTemp);
                                            bZipProcessed = false;
                                            bErrors = true;
                                            vErroredFiles.add(sTemp);
                                        }
                                    }
                                    vContentGroup = ContLoadUtil.getContentGroup(fpContFile, cust.s_cust_id, sLoadId);
                                } else {    // Attempting ZIP file upload with non-ZIP file.
                                    sProcessedMsg = "Error: File: " + sFileName + " is not a ZIP file and cannot be loaded from the 'Upload Content ZIP' page.";
                                    bErrors = true;
                                    ContLoadUtil.setStatus(sLoadId,ContLoadStatus.ERROR_PROCESSING,sProcessedMsg);
                                    break;
                                }
                            } else {
                                //System.out.println("About to attempt to process a file, not a zip file.:" + myPart.getName());
                                if (myPart.getName().equals("cont_text_file")) {    // text file
                                    sProcessedMsg = ContLoadUtil.processFile(fpContFile,cust.s_cust_id,iFileId++,sLoadId, sContLoadFolderId, sFileName, FileType.CONT_TEXT, user.s_user_id);
                                    if (sProcessedMsg.equalsIgnoreCase("success")) {
                                        bTextProcessed = true;
                                    } else {
                                        bTextProcessed = false;
                                        bErrors = true;
                                        break;
                                    }
                                }
                                if (myPart.getName().equals("cont_html_file")) {    // HTML file
                                    sProcessedMsg = ContLoadUtil.processFile(fpContFile,cust.s_cust_id,iFileId++,sLoadId, sContLoadFolderId, sFileName, FileType.CONT_HTML, user.s_user_id);
                                    if (!sProcessedMsg.equalsIgnoreCase("success")) {
                                        bHtmlProcessed = false;
                                        bErrors = true;
                                        break;
                                    }
                                }
                                if (myPart.getName().indexOf("cont_image_file") != -1) {  // image file(s)
                                    sProcessedMsg = ContLoadUtil.processFile(fpContFile,cust.s_cust_id,iFileId++,sLoadId, sContLoadFolderId, sFileName, FileType.IMAGE, user.s_user_id);
                                    if (!sProcessedMsg.equalsIgnoreCase("success")) {
                                        bImageProcessed = false;
                                        bErrors = true;
                                        break;
                                    }
                                }
                                if (sProcessedMsg.equalsIgnoreCase("success")) {
                                    vSavedFiles.add(sFileName);
                                } else {
                                    vErroredFiles.add(sFileName + " - " + sProcessedMsg);
                                    bErrors = true;
                                }
                            }
                        } catch (Exception e) {
                            throw e;
                        }
                    }
                }

            }
            sCategories = (String[])vCategories.toArray(new String[0]);

            if (bTextProcessed) {
                if (!bHtmlProcessed || !bImageProcessed) {
                    if (sProcessedMsg == null) {
                        vErroredFiles.add("Error: The Text file processed correctly, but either an HTML file or an Image file did not process successfully.");
                    } else {
                        vErroredFiles.add(sProcessedMsg);
                    }
                    bErrors = true;
                } else {
                        //System.out.println(" Text file processed: Load in content using ContLoadUtil.setupContent with type PARAGRAPH");
                        String sContentType = String.valueOf(ContType.PARAGRAPH);
                        String sContentId = ContLoadUtil.setupContent(sLoadId, sContentName, sCharset, sUnsubMsgId, sUnsubPos, sContentType, null);
                        if (sContentId == null) {
                            String sError = "Error:  An Error occurred while attempting to setup the Content object.";
                            vErroredFiles.add(sError);
                            bErrors = true;
                            ContLoadUtil.setStatus(sLoadId,ContLoadStatus.ERROR_PROCESSING,sError);
                        } else {
                            try {
                                CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CONTENT, sContentId, sCategories);
                            } catch(Exception ex) {
                                logger.error("cont_load_save.jsp ERROR: unable to save categories.",ex);
                            }

                        }
                 }
            } else if (bZipProcessed) {
                //System.out.println(" Zip File Processed.  Loading Content using ContLoadUtil.setupContent with type = Paragraph");
                Iterator iter = vContentGroup.iterator(); 
                while (iter.hasNext()) {
                    String sContentGroup = (String) iter.next(); 
                    String sContentType = String.valueOf(ContType.PARAGRAPH);
                    String sContentId = ContLoadUtil.setupContent(sLoadId, sContentName, sCharset, sUnsubMsgId, sUnsubPos, sContentType, sContentGroup);
                    if (sContentId == null) {
                        String sError = "Error:  An Error occurred while attempting to setup the Content object.";
                        vErroredFiles.add(sError);
                        bErrors = true;
                        ContLoadUtil.setStatus(sLoadId,ContLoadStatus.ERROR_PROCESSING,sError);
                    } else {
                        try {
                            CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CONTENT, sContentId, sCategories);
                        } catch(Exception ex) {
                            logger.error("cont_load_save.jsp ERROR: unable to save categories.",ex);
                        }
                    }
                }
            } else {
                if (sProcessedMsg == null) {
                    vErroredFiles.add("Error: No files processed successfully.");
                } else {
                    vErroredFiles.add(sProcessedMsg);
                }
                bErrors = true;
            }
        }

    %>
    <HTML>

    <HEAD>
        <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
    </HEAD>

    <BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Content Load:</b>
               <% if (bErrors) {
               %>
                    Content Not Loaded due to Errors
               <%   } else { %>
                    Content Loaded
               <%   } %>
                    </td>
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
                              <% if (vErroredFiles != null && vErroredFiles.size() > 0) {
                              %>
						<br><br>
						<b> <font color="red">
                                   The Content was not saved for the reasons listed:<br>
                              <%   Iterator itErroredFiles = vErroredFiles.iterator();
                                        while (itErroredFiles.hasNext()) {
                              %>
                                        <%=(String)itErroredFiles.next()%>
                                        <br>
                              <%
                                        }
                              %>
                              </font></b>
                              <%
                                   } else if (vSavedFiles != null && vSavedFiles.size() > 0) {
                              %>
						<b>
                                   The Content was loaded using the following files:<br>
                              <%   Iterator itSavedFiles = vSavedFiles.iterator();
                                        while (itSavedFiles.hasNext()) {
                              %>
                                        <%=(String)itSavedFiles.next()%>
                                        <br>
                              <%
                                                  }
                              %>
                              </b>
                                                                                          <b>
                              <% } else if (vZipFiles != null && vZipFiles.size() > 0) {
                              %>
                                   The Content was saved using the following files in a zip file:<br>
                              <%   Iterator itZipFiles = vZipFiles.iterator();
                                        String sTmp = null;
                                        while (itZipFiles.hasNext()) {
                                             sTmp = (String)itZipFiles.next();
                                             if (sTmp.indexOf("Error") != -1) {
                              %>             <font color="red">
                              <%             } 
                              %>
                                        <%=sTmp%>
                              <%        if (sTmp.indexOf("Error") != -1) {
                              %>             </font>
                              <%        }
                              %>
                                        <br>
                              <%
                                                  }
                                        }
                              %>
                              </b>
						<br><br>
						<a href="dynamic_elements.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a>
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
	logger.error("Exception: ",ex);
     throw ex;
} finally {
	if ( prepStmt != null ) prepStmt.close ();	
	if ( stmt != null ) stmt.close ();	
	if ( srvConnection != null ) connectionPool.free(srvConnection);
}

%>
