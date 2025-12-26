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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

Statement stmt = null;
PreparedStatement prepStmt = null;
ResultSet rs = null; 
ConnectionPool connectionPool = null;
Connection srvConnection = null;
JsonObject savedMessage= new JsonObject();
JsonArray savedArray= new JsonArray();
JsonObject data= new JsonObject();
JsonArray array= new JsonArray();
try
{
          connectionPool = ConnectionPool.getInstance();
          srvConnection = connectionPool.getConnection(this);
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
               }
          catch (Exception e)
          {
                    mp = null;
                    String sError = "No files saved.  Upload exceded total file size limit for customer.";
                    vErroredFiles.add(sError);
                    bErrors = true;
          }

          String sLoadId = ContLoadUtil.startLoad(cust.s_cust_id);

          if (mp != null) {
               while ((myPart = mp.readNextPart()) != null && !bErrors) {
     //               System.out.println("dealing with part:" + myPart.getName());

                    if (myPart.getName().equals("category_id")) {
                         sSelectedCategoryId = ((ParamPart)myPart).getStringValue();
                    }
                    if (myPart.getName().equals("categories")) {
                         vCategories.add(((ParamPart)myPart).getStringValue());
                    }
                    if (myPart.getName().equals("contentName")) {
                         sContentName = ((ParamPart)myPart).getStringValue();
                    }
                    if (myPart.getName().equals("auto_link_scan")) {
                         sAutoLinkScan = ((ParamPart)myPart).getStringValue();
                    }
                    if (myPart.getName().equals("use_anchor_name")) {
                         sUseAnchorName = ((ParamPart)myPart).getStringValue();
                    }
                    if (myPart.getName().equals("use_link_renaming")) {
                         sUseLinkRenaming = ((ParamPart)myPart).getStringValue();
                    }
                    if (myPart.getName().equals("replace_scanned_links")) {
                         sReplaceScannedLinks = ((ParamPart)myPart).getStringValue();
                    }
                    
                    if (myPart.getName().equals("SendTypes")) {
                         sCharset = ((ParamPart)myPart).getStringValue();
                         if (sCharset.length() == 0)
                              sCharset = null;
                    }
                    if (myPart.getName().equals("unsubID")) {
                         sUnsubMsgId = ((ParamPart)myPart).getStringValue();
                         if (sUnsubMsgId.length() == 0)
                              sUnsubMsgId = null;
                    }
                    if (myPart.getName().equals("unsubPos")) {
                         sUnsubPos = ((ParamPart)myPart).getStringValue();
                         if (sUnsubPos.length() == 0)
                              sUnsubPos = null;
                    }
                    
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
                                             vZipFiles = ContLoadUtil.processZipFile(fpContFile, cust.s_cust_id, iFileId++, sLoadId, sContLoadFolderId, sFileName, user.s_user_id);
                                             String sTemp = null;
                                             Iterator itZipFiles = vZipFiles.iterator();
                                             bZipProcessed = true;
                                             while (itZipFiles.hasNext()) {
                                                  sTemp = (String)itZipFiles.next();
                                                  if (sTemp.indexOf("Error") != -1) {    // an element of the ZIP file caused an error in ContLoadUtil
     //                                                  System.out.println("something errored while processing ZIP");
                                                       bZipProcessed = false;
                                                       bErrors = true;
                                                       vErroredFiles.add(sTemp);
                                                  }
                                             }
                                             //break;
                                        } else {    // Attempting ZIP file upload with non-ZIP file.
                                             sProcessedMsg = "Error: File: " + sFileName + " is not a ZIP file and cannot be loaded from the 'Upload Content ZIP' page.";
                                             bErrors = true;
                                             ContLoadUtil.setStatus(sLoadId,ContLoadStatus.ERROR_PROCESSING,sProcessedMsg);
                                             break;
                                        }
                                   } else {
     //                                   System.out.println("About to attempt to process a file:" + myPart.getName());
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
          if (sAutoLinkScan == null ) {
               sUseAnchorName = null;
               sUseLinkRenaming = null;
               sReplaceScannedLinks = null;
          } else if (sUseAnchorName == null && sUseLinkRenaming == null && sReplaceScannedLinks == null) {
               sAutoLinkScan = null;
          } else {
               if (sUseAnchorName == null)
                    sUseAnchorName = "0";
               if (sUseLinkRenaming == null)
                    sUseLinkRenaming = "0";
               if (sReplaceScannedLinks == null)
                    sReplaceScannedLinks = "0";
          }
          if (bTextProcessed) {
               if (!bHtmlProcessed || !bImageProcessed) {
                    if (sProcessedMsg == null) {
                         vErroredFiles.add("Error: The Text file processed correctly, but either an HTML file or an Image file did not process successfully.");
                    } else {
                         vErroredFiles.add(sProcessedMsg);
                    }
                    bErrors = true;
               } else {
                    String sContentId = ContLoadUtil.setupContent(sLoadId, sContentName, sCharset, sUnsubMsgId, sUnsubPos);
                    if (sContentId == null) {
                         String sError = "Error:  An Error occurred while attempting to setup the Content object.";
                         vErroredFiles.add(sError);
                         bErrors = true;
                         ContLoadUtil.setStatus(sLoadId,ContLoadStatus.ERROR_PROCESSING,sError);
                    } else {
                         try
                         {
                              CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CONTENT, sContentId, sCategories);
                         }
                         catch(Exception ex)
                         {
                              logger.error("cont_load_save.jsp ERROR: unable to save categories.",ex);
                         }
                         if (sContentId != null && sAutoLinkScan != null) {
                              sRedirectUrl = "link_scan.jsp?cont_id=" + sContentId + "&use_anchor_name=" + sUseAnchorName + "&use_link_renaming=" + sUseLinkRenaming + "&replace_scanned_links=" + sReplaceScannedLinks + "&type=load&loadId=" + sLoadId;
                         }
                         if (sRedirectUrl != null) {
                              response.sendRedirect(sRedirectUrl);
                              return;
                         }
                    }
               }
          } else if (bZipProcessed) {
               String sContentId = ContLoadUtil.setupContent(sLoadId, sContentName, sCharset, sUnsubMsgId, sUnsubPos);
               if (sContentId == null) {
                    String sError = "Error:  An Error occurred while attempting to setup the Content object.";
                    vErroredFiles.add(sError);
                    bErrors = true;
                    ContLoadUtil.setStatus(sLoadId,ContLoadStatus.ERROR_PROCESSING,sError);
               } else {
                    try
                    {
                         CategortiesControl.saveCategories(cust.s_cust_id, ObjectType.CONTENT, sContentId, sCategories);
                    }
                    catch(Exception ex)
                    {
                         logger.error("cont_load_save.jsp ERROR: unable to save categories.",ex);
                    }
                    if (sContentId != null && sAutoLinkScan != null) {
                         sRedirectUrl = "link_scan.jsp?cont_id=" + sContentId + "&use_anchor_name=" + sUseAnchorName + "&use_link_renaming=" + sUseLinkRenaming + "&replace_scanned_links=" + sReplaceScannedLinks + "&type=load&loadId=" + sLoadId;
                         
                    }
                   
                    
                    if (sRedirectUrl != null) {
                         response.sendRedirect(sRedirectUrl);                      
                         return;
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
      
     //data.put("sContentId",sContentId);
     data.put("sUseAnchorName",sUseAnchorName);
     data.put("sUseLinkRenaming",sUseLinkRenaming);
     data.put("sReplaceScannedLinks",sReplaceScannedLinks);
     data.put("sLoadId",sLoadId);
     array.put(data);
     savedMessage.put("Message:","cont load saved successfully");
     savedArray.put(savedMessage);
     out.print(array);
     out.print(savedArray);
} catch (Exception ex) {
          logger.error("Exception: ",ex);
          throw ex;
     } finally {
          if ( prepStmt != null ) prepStmt.close ();	
          if ( stmt != null ) stmt.close ();	
          if ( srvConnection != null ) connectionPool.free(srvConnection);


       
     }

%>
