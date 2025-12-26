package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.imc.*;
import com.britemoon.cps.jtk.*;
import com.britemoon.cps.adm.*;

import java.sql.*;
import java.util.*;
import java.net.*;
import java.util.zip.*;
import java.util.regex.*;
import java.io.*;
import org.w3c.dom.*;
import javax.servlet.http.HttpServletResponse;
import org.apache.log4j.*;

public class ContLoadUtil {
// Registry variables needed:
//   img_file_path
//   img_url_path
//   img_staging_path
    
    
    private static Logger logger = Logger.getLogger(ContLoadUtil.class.getName());
    public static boolean isTextFile(String sFileName) throws Exception {
        boolean bIsTextFile = false;
        if (Pattern.matches(".*\\.TXT\\Z", sFileName.toUpperCase().trim())) bIsTextFile = true; //FileType.IMAGE
        else if (Pattern.matches(".*\\.TEXT\\Z", sFileName.toUpperCase().trim())) bIsTextFile = true; //FileType.IMAGE
        else bIsTextFile = false;
        return bIsTextFile;
    }
    
    public static boolean isHtmlFile(String sFileName) throws Exception {
        boolean bIsHtmlFile = false;
        if (Pattern.matches(".*\\.HTM\\Z", sFileName.toUpperCase().trim())) bIsHtmlFile = true; //FileType.IMAGE
        else if (Pattern.matches(".*\\.HTML\\Z", sFileName.toUpperCase().trim())) bIsHtmlFile = true; //FileType.IMAGE
        else bIsHtmlFile = false;
        return bIsHtmlFile;
    }
    
    public static boolean isZipFile(String sFileName) throws Exception {
        boolean bIsZIP = false;
        if (Pattern.matches(".*\\.ZIP\\Z", sFileName.toUpperCase().trim())) bIsZIP = true; //FileType.IMAGE
        else bIsZIP = false;
        return bIsZIP;
    }
    
    private static String splitGroupName(String sFileName) {
        String returnvalue = "s";
        String [] fileName = sFileName.split("/");
        String fileWithoutPath = fileName[fileName.length-1];
        
        String [] fileWithoutType = fileWithoutPath.split("\\.");
        String fileNameOnly = fileWithoutType[0];
        return fileNameOnly;
    }
    
      private static String splitIntoFileName(String sFileName) {
        String returnvalue = "s";
        String [] fileName = sFileName.split("/");
        String fileWithoutPath = fileName[fileName.length-1];
        return fileWithoutPath;
      }
    
    private static String replaceImages(String sCustID, String sLoadId, String sContent) throws Exception {
        // Put in full path for image URLs from ZIP file images
        ConnectionPool cp = null;
        Connection conn = null;
        
        String sResult = sContent;
        StringBuffer sbResult = null;
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ContLoadUtil.replaceImages()");
            
            Statement stmt = null;
            
            try {
                stmt = conn.createStatement();
                ResultSet rs = null;
                
                String sImageURL = null;
                String sImageName = null;
                String sRootDir = "";
                int idx = 0;
                
                // find rootdir from text file
                String sSql = "SELECT DISTINCT f.file_url"
                        + " FROM ccnt_cont_load_file f"
                        + " WHERE f.type_id = " + FileType.CONT_TEXT
                        + " AND f.load_id = "+sLoadId;
                
                rs = stmt.executeQuery(sSql);
                if (rs.next()) {
                    sRootDir = rs.getString(1);
                }
                rs.close();
                idx = sRootDir.lastIndexOf('/');
                if (idx > 0) {
                    sRootDir = sRootDir.substring(0, idx+1);
                } else {
                    sRootDir = "/";
                }
                
                // process each image file
                sSql = "SELECT DISTINCT f.file_url"
                        + " FROM ccnt_cont_load_file f"
                        + " WHERE f.type_id = " + FileType.IMAGE
                        + " AND f.load_id = "+sLoadId;
                
                rs = stmt.executeQuery(sSql);
                String sImageNameMatch = null;
                
                while (rs.next()) {
                    sImageURL = rs.getString(1);
                    if (sImageURL.toLowerCase().startsWith(sRootDir.toLowerCase())) {
                        sImageName = sImageURL.substring(sRootDir.length());
                    } else {
                        sImageName = sImageURL.substring(sImageURL.lastIndexOf("/")+1);
                    }
                    logger.info("in replaceImages...trying to match on:" + sImageName);
                    logger.info(" url => " + sImageURL);
                    sImageURL = ImageHostUtil.getMirrorPath(sCustID, sImageURL);
                    logger.info(" mirror => " + sImageURL);
                    
                    sImageNameMatch = "='" + sImageName.toLowerCase() + "'";
                    for (int i = sResult.toLowerCase().indexOf(sImageNameMatch); i >= 0; i = sResult.toLowerCase().indexOf(sImageNameMatch, i+sImageURL.length())) {
                        sbResult = new StringBuffer(sResult);
                        sResult = sbResult.replace(i, i + sImageNameMatch.length(), "='" + sImageURL +"'").toString();
                    }
                    
                    sImageNameMatch = "=\"" + sImageName.toLowerCase() + "\"";
                    for (int i = sResult.toLowerCase().indexOf(sImageNameMatch); i >= 0; i = sResult.toLowerCase().indexOf(sImageNameMatch, i+sImageURL.length())) {
                        sbResult = new StringBuffer(sResult);
                        sResult = sbResult.replace(i, i + sImageNameMatch.length(), "=\"" + sImageURL + "\"").toString();
                    }
                    
                    sImageNameMatch =  "=" + sImageName.toLowerCase();
                    for (int i = sResult.toLowerCase().indexOf(sImageNameMatch); i >= 0; i = sResult.toLowerCase().indexOf(sImageNameMatch, i+sImageURL.length())) {
                        sbResult = new StringBuffer(sResult);
                        sResult = sbResult.replace(i, i + sImageNameMatch.length(), "=" +sImageURL).toString();
                    }
                }
            } catch (Exception ex) {
                throw ex;
            } finally {
                if (stmt!=null) stmt.close();
            }
        } catch (Exception ex) {
            throw ex;
        } finally {
            if ( conn != null ) cp.free(conn);
        }
        
        return sResult;
    }
    
    public static String getContLoadRoot(String sCustId) throws Exception {
        String sContLoadRootId = null;
        ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ContLoadUtil.getContLoadRoot(" + sCustId + ")");
            stmt = conn.createStatement();
            rs = stmt.executeQuery("Select folder_id from ccnt_img_folder where cust_id = " + sCustId + " and root_flag = 2");
            if (rs.next()) {
                sContLoadRootId = rs.getString(1);
            }
            rs.close();
        } catch (Exception e) {
            throw e;
        } finally {
            if (stmt != null) {
                try { stmt.close(); } catch (Exception e) { }
            }
            cp.free(conn);
        }
        return sContLoadRootId;
    }
    
    public static String createContLoadRoot(String sCustId, String sUserId)  throws Exception {
        String sContLoadRootId = null;
        String sRootFolderId = ImageHostUtil.getRoot(sCustId);
        if (sRootFolderId == null) {
            logger.info("Creating Content Load ROOT folder for customer:" + sCustId);
            sRootFolderId = ImageHostUtil.createRoot(sCustId, sUserId);
        }
        ImgFolder root = new ImgFolder(sRootFolderId);
        String sFilePath = root.s_file_path + "content_load\\";
        String sUrlPath = root.s_url_path + "content_load/";
        
        String[] sAccessMap = { sCustId };
        
        sContLoadRootId = ImageHostUtil.createFolder(sCustId,"CONTENT_LOAD",sFilePath, sUrlPath, sRootFolderId, sUserId, sAccessMap);
        
        return sContLoadRootId;
    }
    
    
    public static String getFolderIdFromName(String sCustId, String sParentId, String sFolderName) throws Exception {
        String sFolderId = null;
        ConnectionPool cp = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sSql = "Select folder_id from ccnt_img_folder WHERE cust_id = ? and parent_id = ? and folder_name = ?";
        
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ImageHostUtil.checkFolderIdFromName(" + sCustId + "," + sParentId + ", " + sFolderName + ")");
            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1,sCustId);
            pstmt.setString(2,sParentId);
            pstmt.setString(3,sFolderName);
            rs = pstmt.executeQuery();
            if (rs.next())
                sFolderId = rs.getString(1);
            rs.close();
        } catch (Exception e) {
            throw e;
        } finally {
            if (pstmt != null) {
                try { pstmt.close(); } catch (Exception e) { }
            }
            cp.free(conn);
        }
        return sFolderId;
    }
    
    public static String getFolderIdFromPath(String sCustId, String sFilePath) throws Exception {
        String sFolderId = null;
        ConnectionPool cp = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sSql = "Select folder_id from ccnt_img_folder WHERE cust_id = ? and file_path = ?";
        
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ImageHostUtil.getFolderIdFromPath(" + sCustId + "," + sFilePath + ")");
            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1,sCustId);
            pstmt.setString(2,sFilePath);
            rs = pstmt.executeQuery();
            if (rs.next())
                sFolderId = rs.getString(1);
            rs.close();
        } catch (Exception e) {
            throw e;
        } finally {
            if (pstmt != null) {
                try { pstmt.close(); } catch (Exception e) { }
            }
            cp.free(conn);
        }
        return sFolderId;
    }
    
    public static String getImageIdFromName(String sCustId, String sFolderId, String sImageName) throws Exception {
        String sImageId = null;
        ConnectionPool cp = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sSql = "Select image_id from ccnt_image WHERE cust_id = ? and folder_id = ? and image_name = ?";
        
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ImageHostUtil.getImageIdFromName(" + sCustId + "," + sFolderId + ", " + sImageName + ")");
            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1,sCustId);
            pstmt.setString(2,sFolderId);
            pstmt.setString(3,sImageName);
            rs = pstmt.executeQuery();
            if (rs.next())
                sImageId = rs.getString(1);
            rs.close();
        } catch (Exception e) {
            throw e;
        } finally {
            if (pstmt != null) {
                try { pstmt.close(); } catch (Exception e) { }
            }
            cp.free(conn);
        }
        return sImageId;
    }
    
    public static String startLoad(String sCustId) throws Exception {
        String sLoadId = null;
        ConnectionPool cp = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sSql = "EXEC usp_ccnt_cont_load_save @cust_id=?, @status_id=?, @status_desc=?";
        
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ContLoadUtil.startLoad(" + sCustId + ")");
            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1,sCustId);
            pstmt.setInt(2,ContLoadStatus.RECEIVED);
            pstmt.setString(3,"Starting Load");
            rs = pstmt.executeQuery();
            if (rs.next())
                sLoadId = rs.getString(1);
            rs.close();
        } catch (Exception e) {
            throw e;
        } finally {
            if (pstmt != null) {
                try { pstmt.close(); } catch (Exception e) { }
            }
            cp.free(conn);
        }
        return sLoadId;
    }
    
    public static void setStatus(String sLoadId, int iStatus, String sStatusDesc) throws Exception {
        ConnectionPool cp = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        int iResult = 0;
        
        String sSql = "UPDATE ccnt_cont_load " +
                " SET status_id = ?" +
                ", status_desc = RTRIM(?)" +
                " WHERE load_id = ?";
        
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ContLoadUtil.setError(" + sLoadId + ")");
            pstmt = conn.prepareStatement(sSql);
            pstmt.setInt(1,iStatus);
            pstmt.setString(2,sStatusDesc);
            pstmt.setString(3,sLoadId);
            iResult = pstmt.executeUpdate();
            if (iResult != 1)
                logger.error("ContLoadUtil.setError SQL Update of one Load ID returned value other than 1.");
        } catch (Exception e) {
            throw e;
        } finally {
            if (pstmt != null) {
                try { pstmt.close(); } catch (Exception e) { }
            }
            cp.free(conn);
        }
    }
    
        /*
         * process zip file
         */
    public static Vector processZipFile(com.oreilly.servlet.multipart.FilePart fpContFile, String sCustId, int iFileId, String sLoadId, String sFolderId, String sFileName, String sUserId) throws Exception {
        Vector v = null;
        
                /*
                 * write zip file to staging folder
                 */
        setStatus(sLoadId, ContLoadStatus.PROCESSING, "Processing ZIP file: " + sFileName);
        String sStagingPath = getStagingPath() + sCustId + "_" + new java.util.Date().getTime() + "_" + sFileName;
        File fStagingFile = new File(sStagingPath);
        fpContFile.writeTo(fStagingFile);
        addFileRecord(sLoadId, iFileId++,FileType.ZIP,sStagingPath,null);
        int iZipLength = new Long(fStagingFile.length()).intValue();
        int iZipLimit = ImageHostUtil.getZipFileLimit(sCustId);
        if ( iZipLength > iZipLimit ) {
            v = new Vector();
            String sError = "ZIP File limit exceded.  Cannot upload ZIP file.\nLimit:" + iZipLimit + " ;ZIP:" + iZipLength;
            v.add(sError);
            setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
            return v;
        }
        
                /*
                 * check zip file content
                 */
        ZipFile zf = new ZipFile(fStagingFile);
        ZipEntry entry = null;
        String sEntryFileName = null;
        String sTextFileName = "";
        Enumeration e = null;
        String sError = "";
        boolean isError = false;
        String rootDir = "";
        int idx = 0;
        
        
        // make sure there are EXACTLY 1 text file and AT MOST 1 html file
        // make sure image library feature is enabled for image files
        // make sure there are no unknown files
        int iTextFiles = 0;
        int iHtmlFiles = 0;
        int iImageFiles = 0;
        int iInvalidFiles = 0;
        String sLastInvalidFile = null;
        int iUnknownFiles = 0;
        String sLastUnknownFile = null;
        e = zf.entries();
        while (e.hasMoreElements()) {
            entry = (ZipEntry) e.nextElement();
            if (entry.isDirectory()) continue;
            //System.out.println("file=" + entry.getName());
            if (isTextFile(entry.getName())) {
                iTextFiles++;
                sTextFileName = entry.getName();
            } else if (isHtmlFile(entry.getName())) {
                iHtmlFiles++;
            } else if (ImageHostUtil.isImageFile(entry.getName(), sCustId)) {
                iImageFiles++;
            } else {
                iUnknownFiles++;
                sLastUnknownFile = entry.getName();
            }
            if (entry.getName().indexOf(' ') >= 0) {
                iInvalidFiles++;
                sLastInvalidFile = entry.getName();
            }
        }
        if (iTextFiles != 1) {
            sError = "Error: ZIP file contained incorrect number of Text files: " + iTextFiles;
            isError = true;
        }
        if (iHtmlFiles > 1) {
            sError = "Error:  ZIP file contains more than 1 HTML file";
            isError = true;
        }
        if (iImageFiles > 0) {
            if (!CustFeature.exists(sCustId,110)) {
                sError = "Error: ZIP file contained images but this customer doesn't have the image library feature";
                isError = true;
            }
        }
        if (iUnknownFiles > 0) {
            sError = "Error: ZIP file contained files of unknown type, last unknown file: " + sLastUnknownFile;
            isError = true;
        }
        if (iInvalidFiles > 0) {
            sError = "Error: ZIP file contained invalid file names (ie. containing space, tab etc), last invalid file: " + sLastInvalidFile;
            isError = true;
        }
        
        if (isError) {
            v = new Vector();
            v.add(sError);
            setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
            return v;
        }
        
        // find root dir using the text content filename as frame of reference
        idx = sTextFileName.lastIndexOf('/');
        if (idx >= 0) {
            rootDir = sTextFileName.substring(0,idx+1);
        }
        //System.out.println("rootDir=" + rootDir);
        // make sure all files has a rootDir
        e = zf.entries();
        while (e.hasMoreElements()) {
            entry = (ZipEntry) e.nextElement();
            if (entry.isDirectory()) continue;
            sEntryFileName = entry.getName();
            String filename = sEntryFileName.toLowerCase();
            if (rootDir.length() > 0) {
                if (!sEntryFileName.startsWith(rootDir)) {
                    sError = "Error: ZIP file contains file starts with different root directory: " + sEntryFileName;
                    isError = true;
                    break;
                }
                // chop of rootdir
                filename = filename.substring(rootDir.length());
            }
            
            // make sure non-image filenams sans rootdir is clean
            //System.out.println("filename=" + filename);
            if (ImageHostUtil.isImageFile(filename, sCustId)) {
                if ( !filename.startsWith("img/") && !filename.startsWith("images/") && (filename.indexOf('/') >= 0) ) {
                    sError = "Error: ZIP file contains images file of different sub directory: " + sEntryFileName;
                    isError = true;
                    break;
                }
            } else {
                if (filename.indexOf('/') >= 0) {
                    sError = "Error: ZIP file contains non-image file of different root directory: " + sEntryFileName;
                    isError = true;
                    break;
                }
            }
            
        }
        if (isError) {
            v = new Vector();
            v.add(sError);
            setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
            return v;
        }
        
        // we may need to create a new folder using the load id
        String[] sAccessMap = { sCustId };  //ContLoad folders/images only go to customer uploading
        String sNewFolderId = ImageHostUtil.getFolderIdFromName(sCustId, sFolderId, sLoadId);
        if (sNewFolderId == null) {
            sNewFolderId = ImageHostUtil.createFolder(sCustId, sLoadId, sFolderId, sUserId, sAccessMap);
        }
        sFolderId = sNewFolderId;
        
        // create rootDir folder
        String sFolderName = "";
        StringTokenizer st = new StringTokenizer(rootDir, "/");
        while (st.hasMoreTokens()) {
            sFolderName = st.nextToken();
            sFolderId = ImageHostUtil.createFolder(sCustId, sFolderName, sFolderId, sUserId, sAccessMap);
            //System.out.println("created folder=" + sFolderName + " (" + sFolderId + ")");
        }
        
        // sFolderId = the root folder id for this zip file
        
        // process zip files
        int BUFFER = 2048;
        BufferedOutputStream dest = null;
        BufferedInputStream is = null;
        String sFullPath = null;
        
        v = new Vector();
        e = zf.entries();
        while (e.hasMoreElements()) {
            entry = (ZipEntry) e.nextElement();
            if (entry.isDirectory()) continue;
            sEntryFileName = entry.getName();
            
            String sFileShortName = sEntryFileName;
            if (rootDir.length() > 0) {
                sFileShortName = sFileShortName.substring(rootDir.length());
            }
            // write file to staging
            sFullPath = sStagingPath + sCustId + "_" + new java.util.Date().getTime() + "_" + sFileShortName.replaceAll("/", "_");
            is = new BufferedInputStream(zf.getInputStream(entry));
            int count;
            byte data[] = new byte[BUFFER];
            File fEntryFile = new File(sFullPath);
            FileOutputStream fos = new FileOutputStream(fEntryFile);
            dest = new BufferedOutputStream(fos, BUFFER);
            while ((count = is.read(data, 0, BUFFER)) != -1) {
                dest.write(data, 0, count);
            }
            dest.flush();
            dest.close();
            is.close();
            int iEntryFileType = getFileType(sFileShortName, sCustId);
            // process file
            if (iEntryFileType != 0 && iEntryFileType != FileType.ZIP) {
                String sRealFolderId = sFolderId;
                idx = sFileShortName.lastIndexOf('/');
                if ( (iEntryFileType == FileType.IMAGE ) && (idx > 0) ) {
                    // we may need to the subfolders for images
                    String sSubFolderId = null;
                    st = new StringTokenizer(sFileShortName.substring(0, idx), "/");
                    while (st.hasMoreTokens()) {
                        sFolderName = st.nextToken();
                        sSubFolderId = ImageHostUtil.getFolderIdFromName(sCustId, sRealFolderId, sFolderName);
                        if (sSubFolderId == null) {
                            sSubFolderId = ImageHostUtil.createFolder(sCustId, sFolderName, sRealFolderId, sUserId, sAccessMap);
                            //System.out.println("created subfolder=" + sFolderName + " (" + sSubFolderId + ")");
                        }
                        sRealFolderId = sSubFolderId;
                    }
                    sFileShortName = sFileShortName.substring(idx+1);
                }
                String sReturnMsg = processFile(fEntryFile, sCustId, iFileId++, sLoadId, sRealFolderId, sFileShortName,iEntryFileType , sUserId, false);
                if (sReturnMsg.equalsIgnoreCase("success")) {
                    v.add(sEntryFileName);
                } else {
                    sError = "Error:  An error occurred during processing of Zip entry file:" + sEntryFileName; // + ".  Details: " + sReturnMsg;
                    logger.info("Error:  An error occurred during processing of Zip entry file:" + sEntryFileName  + " : " + sFileShortName + " : Details: " + sReturnMsg);
                    v.add(sError);
                    setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
                }
            }
        }
        return v;
    }
    
    public static Vector processZipFileWithMultipleContentElements(com.oreilly.servlet.multipart.FilePart fpContFile, String sCustId, int iFileId, String sLoadId, String sFolderId, String sFileName, String sUserId) throws Exception {
        Vector v = null;
        
    /*
     * write zip file to staging folder
     *First determine if all the files in the zip conform to the business rules.  Then process each file in the
     *zip and write each file to the staging folder.
     */
        setStatus(sLoadId, ContLoadStatus.PROCESSING, "Processing ZIP file: " + sFileName);
        String sStagingPath = getStagingPath() + sCustId + "_" + new java.util.Date().getTime() + "_" + sFileName;
        File fStagingFile = new File(sStagingPath);
        fpContFile.writeTo(fStagingFile);
        addFileRecord(sLoadId, iFileId++,FileType.ZIP,sStagingPath,null, null);
        int iZipLength = new Long(fStagingFile.length()).intValue();
        int iZipLimit = ImageHostUtil.getZipFileLimit(sCustId);
        if ( iZipLength > iZipLimit ) {
            v = new Vector();
            String sError = "ZIP File limit exceded.  Cannot upload ZIP file.\nLimit:" + iZipLimit + " ;ZIP:" + iZipLength;
            v.add(sError);
            setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
            return v;
        }
        
    /*
     * check zip file content
     */
        ZipFile zf = new ZipFile(fStagingFile);
        ZipEntry entry = null;
        String sEntryFileName = null;
        String sTextFileName = "";
        Enumeration e = null;
        String sError = "";
        boolean isError = false;
        String rootDir = "";
        int idx = 0;
        
        
        // make sure all images are in a directory called either img or images or all image files exist solely under the root.
        e = zf.entries();
        while (e.hasMoreElements()) {
            entry = (ZipEntry) e.nextElement();
            if (entry.isDirectory()) continue;
            sEntryFileName = entry.getName();
            String filename = sEntryFileName.toLowerCase();
            if (ImageHostUtil.isImageFile(filename, sCustId)) {
                if ( !filename.startsWith("img/") && !filename.startsWith("images/") && (filename.indexOf('/') >= 0) ) {
                    sError = "Error: ZIP file contains images file of different sub directory: " + sEntryFileName;
                    isError = true;
                    break;
                }
            }
        }
        
        if (isError) {
            v = new Vector();
            v.add(sError);
            setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
            return v;
        }
        
        // make sure there are EXACTLY 1 text file and AT MOST 1 html file for each content element.
        // make sure image library feature is enabled for image files
        // make sure there are no unknown files
        int iTextFiles = 0;
        int iHtmlFiles = 0;
        int iImageFiles = 0;
        int iInvalidFiles = 0;
        boolean firstTimeThruVector = true;
        Vector sFileGroup = new Vector();
        String sLastContentElementFileName = null;
        String sCurrentContentElementFileName = null;
        String sLastInvalidFile = null;
        int iUnknownFiles = 0;
        String sLastUnknownFile = null;
        e = zf.entries();
        while (e.hasMoreElements()) {
            entry = (ZipEntry) e.nextElement();
            if (entry.isDirectory()) continue;
            String filename = entry.getName().toLowerCase();
            if (ImageHostUtil.isImageFile(filename, sCustId)) {
                continue;
            }
            String currentFile = entry.getName();
            String fileNameWithoutPath = splitIntoFileName(currentFile);
            if ((fileNameWithoutPath != null) || (fileNameWithoutPath.length() > 0)) {
                sFileGroup.add(fileNameWithoutPath);
            }
             // find root dir using the last text content filename in the zip as frame of reference
            idx = currentFile.lastIndexOf('/');
            if (idx >= 0) {
                rootDir = currentFile.substring(0,idx+1);
            }
        }
        //System.out.println(" Have added all the files into the Vector.\n" );
        // go through Vector of file names and check to see that there is EXACTLY 1 text file and AT MOST 1 html file for each content element.
        // make sure that there aren't any unknown file types (i.e.  known file types are txt, html, gif or jpg).
        Collections.sort(sFileGroup, null);
        
        for(Enumeration fileGroupEnum = sFileGroup.elements(); fileGroupEnum.hasMoreElements();) {
            //for(Enumeration ecust = custList.elements(); ecust.hasMoreElements();)
            
            String thisFile = (String)fileGroupEnum.nextElement();
            sCurrentContentElementFileName = splitGroupName(thisFile);
            if ((!sCurrentContentElementFileName.equals(sLastContentElementFileName))&& (! firstTimeThruVector)) {
                if (iTextFiles != 1) {
                    sError = "  Error: ZIP file contained incorrect number of Text files: " + iTextFiles;
                    isError = true;
                }
                if (iHtmlFiles > 1) {
                    sError = "Error:  ZIP file contains more than 1 HTML file";
                    isError = true;
                }
                if (iImageFiles > 0) {
                    if (!CustFeature.exists(sCustId,110)) {
                        sError = "  Error: ZIP file contained images but this customer doesn't have the image library feature";
                        isError = true;
                    }
                }
                if (iUnknownFiles > 0) {
                    sError = "  Error: ZIP file contained files of unknown type, last unknown file: " + sLastUnknownFile;
                    isError = true;
                }
                if (iInvalidFiles > 0) {
                    sError = "  Error: ZIP file contained invalid file names (ie. containing space, tab etc), last invalid file: " + sLastInvalidFile;
                    isError = true;
                }
                
                if (isError) {
                    v = new Vector();
                    v.add(sError);
                    //System.out.println("\n In check of zip file for proper number of text/html/image files.  sError = "+ sError);
                    setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
                    return v;
                }
                
                iTextFiles = 0;
                iHtmlFiles = 0;
                iImageFiles = 0;
                iInvalidFiles = 0;
                iUnknownFiles = 0;
                
            }
            // processing file with the same name as previous file.
            firstTimeThruVector = false;
            sLastContentElementFileName = sCurrentContentElementFileName;
            if (isTextFile(thisFile)) {
                iTextFiles++;
                sTextFileName = thisFile;
            } else if (isHtmlFile(thisFile)) {
                iHtmlFiles++;
            } else if (ImageHostUtil.isImageFile(thisFile, sCustId)) {
                iImageFiles++;
            } else {
                iUnknownFiles++;
                sLastUnknownFile = thisFile;
            }
            if (thisFile.indexOf(' ') >= 0) {
                iInvalidFiles++;
                sLastInvalidFile = thisFile;
            }
             //System.out.println("\n For this content element, iTextFiles =" + iTextFiles + " iHtmlFiles = "+ iHtmlFiles + " iImageFiles = " + iImageFiles + " iUnknownFiles = " + iUnknownFiles);
            
        }
        
        // check very last item in enumeration.
        
         if (iTextFiles != 1) {
            sError = "  Error: ZIP file contained incorrect number of Text files: " + iTextFiles;
            isError = true;
        }
        if (iHtmlFiles > 1) {
            sError = "Error:  ZIP file contains more than 1 HTML file";
            isError = true;
        }
        if (iImageFiles > 0) {
            if (!CustFeature.exists(sCustId,110)) {
                sError = "  Error: ZIP file contained images but this customer doesn't have the image library feature";
                isError = true;
            }
        }
        if (iUnknownFiles > 0) {
            sError = "  Error: ZIP file contained files of unknown type, last unknown file: " + sLastUnknownFile;
            isError = true;
        }
        if (iInvalidFiles > 0) {
            sError = "  Error: ZIP file contained invalid file names (ie. containing space, tab etc), last invalid file: " + sLastInvalidFile;
            isError = true;
        }

        if (isError) {
            v = new Vector();
            v.add(sError);
            //System.out.println("\n In check of zip file for proper number of text/html/image files.  sError = "+ sError);
            setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
            return v;
        }
        
        
        // we may need to create a new folder using the load id
        String[] sAccessMap = { sCustId };  //ContLoad folders/images only go to customer uploading
        String sNewFolderId = ImageHostUtil.getFolderIdFromName(sCustId, sFolderId, sLoadId);
        if (sNewFolderId == null) {
            sNewFolderId = ImageHostUtil.createFolder(sCustId, sLoadId, sFolderId, sUserId, sAccessMap);
        }
        sFolderId = sNewFolderId;
        
        // create rootDir folder
        String sFolderName = "";
        StringTokenizer st = new StringTokenizer(rootDir, "/");
        while (st.hasMoreTokens()) {
            sFolderName = st.nextToken();
            sFolderId = ImageHostUtil.createFolder(sCustId, sFolderName, sFolderId, sUserId, sAccessMap);
            //System.out.println("created folder=" + sFolderName + " (" + sFolderId + ")");
        }
        
        // sFolderId = the root folder id for this zip file
        
        // process zip files
        int BUFFER = 2048;
        BufferedOutputStream dest = null;
        BufferedInputStream is = null;
        String sFullPath = null;
        String contentNameFromFile = null;
        
        v = new Vector();
        e = zf.entries();
        while (e.hasMoreElements()) {
            entry = (ZipEntry) e.nextElement();
            if (entry.isDirectory()) continue;
            sEntryFileName = entry.getName();
            // get the name of the contentElement to store the contentName in ccnt_cont_load_file row.
            contentNameFromFile = splitGroupName(sEntryFileName);
  
            String sFileShortName = sEntryFileName;
            if (rootDir.length() > 0) {
                sFileShortName = sFileShortName.substring(rootDir.length());
            }
            // write file to staging
            sFullPath = sStagingPath + sCustId + "_" + new java.util.Date().getTime() + "_" + sFileShortName.replaceAll("/", "_");
            is = new BufferedInputStream(zf.getInputStream(entry));
            int count;
            byte data[] = new byte[BUFFER];
            File fEntryFile = new File(sFullPath);
            FileOutputStream fos = new FileOutputStream(fEntryFile);
            dest = new BufferedOutputStream(fos, BUFFER);
            while ((count = is.read(data, 0, BUFFER)) != -1) {
                dest.write(data, 0, count);
            }
            dest.flush();
            dest.close();
            is.close();
            int iEntryFileType = getFileType(sFileShortName, sCustId);
            // process file
            if (iEntryFileType != 0 && iEntryFileType != FileType.ZIP) {
                String sRealFolderId = sFolderId;
                idx = sFileShortName.lastIndexOf('/');
                if ( (iEntryFileType == FileType.IMAGE ) && (idx > 0) ) {
                    // we may need to the subfolders for images
                    String sSubFolderId = null;
                    st = new StringTokenizer(sFileShortName.substring(0, idx), "/");
                    while (st.hasMoreTokens()) {
                        sFolderName = st.nextToken();
                        sSubFolderId = ImageHostUtil.getFolderIdFromName(sCustId, sRealFolderId, sFolderName);
                        if (sSubFolderId == null) {
                            sSubFolderId = ImageHostUtil.createFolder(sCustId, sFolderName, sRealFolderId, sUserId, sAccessMap);
                            //System.out.println("created subfolder=" + sFolderName + " (" + sSubFolderId + ")");
                        }
                        sRealFolderId = sSubFolderId;
                    }
                    sFileShortName = sFileShortName.substring(idx+1);
                }
                String sReturnMsg = processFile(fEntryFile, sCustId, iFileId++, sLoadId, sRealFolderId, sFileShortName,iEntryFileType , sUserId, false, contentNameFromFile);
                if (sReturnMsg.equalsIgnoreCase("success")) {
                    v.add(sEntryFileName);
                } else {
                    sError = "Error:  An error occurred during processing of Zip entry file:" + sEntryFileName + ".  Details: " + sReturnMsg;
                    logger.info("Error:  An error occurred during processing of Zip entry file:" + sEntryFileName  + " : " + sFileShortName + " : Details: " + sReturnMsg);
                    v.add(sError);
                    setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sError);
                }
            }
        }
        return v;
    }
    
    /**
     *  Get the zip file from ccnt_cont_load_file and then examines each text file in the zip.  
     *  The fileName without extension of each text file becomes the file's content_group in the ccnt_cont_load_file row.
     *  The Vector of ContentGroup is used by cont_element_load_save to set up the same number of content paragraphs as the number of text files in the zip file.
     **/
    public static Vector getContentGroup(com.oreilly.servlet.multipart.FilePart fpContFile, String sCustId, String sLoadId) throws Exception {
        Vector vContentGroup = new Vector();
        String sZipFileName = null;
        ConnectionPool cp = null;
        Connection conn = null;
        
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sSql = "SELECT DISTINCT f.file_name"
                        + " FROM ccnt_cont_load_file f"
                        + " WHERE f.type_id = " + FileType.ZIP
                        + " AND f.load_id = "+sLoadId;
        
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ContLoadUtil.getContentGroup(" + sLoadId  + ")");
            pstmt = conn.prepareStatement(sSql);
  
            rs = pstmt.executeQuery();
            if (rs.next())
                sZipFileName = rs.getString(1);
            rs.close();
        } catch (Exception e) {
            throw e;
        } finally {
            if (pstmt != null) {
                try { pstmt.close(); } catch (Exception e) { }
            }
            cp.free(conn);
        }
        
         
        ZipFile zf = new ZipFile(sZipFileName);
        ZipEntry entry = null;
        Enumeration e = null;
        
        e = zf.entries();
        while (e.hasMoreElements()) {
            entry = (ZipEntry) e.nextElement();
            if (entry.isDirectory()) continue;
            String filename = entry.getName().toLowerCase();
            if (ImageHostUtil.isImageFile(filename, sCustId)) {
                continue;
            }
            if (isHtmlFile(entry.getName())) {
                continue;
            }
            String thisFile = entry.getName();
            String sCurrentFileName = splitGroupName(thisFile);
            vContentGroup.add(sCurrentFileName);
         }
         return vContentGroup;
    }
    
    public static String processFile(com.oreilly.servlet.multipart.FilePart fpContFile, String sCustId, int iFileId, String sLoadId, String sFolderId, String sFileName, int iFileType, String sUserId) throws Exception {
        // write to staging folder
        setStatus(sLoadId, ContLoadStatus.PROCESSING, "Processing Content file: " + sFileName);
        String sStagingPath = getStagingPath();
        sStagingPath += sCustId + "_" + new java.util.Date().getTime() + "_" + sFileName;
        File fStagingFile = new File(sStagingPath);
//          System.out.println("writing to staging..." + sStagingPath);
        fpContFile.writeTo(fStagingFile);
        return processFile(fStagingFile,sCustId,iFileId,sLoadId, sFolderId, sFileName, iFileType, sUserId, true);
        
    }
    
     public static String processFile(File fStagingFile, String sCustId, int iFileId, String sLoadId, String sFolderId, String sFileName, int iFileType, String sUserId, boolean makeLoadFolder) throws Exception {
        String sContentGroup = null;
        return processFile(fStagingFile, sCustId, iFileId, sLoadId, sFolderId, sFileName, iFileType, sUserId, makeLoadFolder, sContentGroup );
     }
    
    
    public static String processFile(File fStagingFile, String sCustId, int iFileId, String sLoadId, String sFolderId, String sFileName, int iFileType, String sUserId, boolean makeLoadFolder, String sContentGroup) throws Exception {
               
        String sReturn = null;
        logger.info("Starting ContLoadUtil.processFile");
        
        try {
            
            int iTotalFileSizeLimit = ImageHostUtil.getTotalFileSizeLimit(sCustId);
            int iTotalFileSizeUsed = ImageHostUtil.getTotalFileSizeUsed(sCustId);
            int iFileSizeLimit = ImageHostUtil.getFileSizeLimit(sCustId);
            
            // check file extension to make sure image files are image files
            if (iFileType == FileType.IMAGE && !ImageHostUtil.isImageFile(sFileName, sCustId)) {
                String sErrors = "Error: File: " + sFileName + " is not an image file.  The file cannot be uploaded.";
//               System.out.println(sErrors);
                setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sErrors);
                return sErrors;
            }
            // check file extension to make sure text  file is a text file
            if (iFileType == FileType.CONT_TEXT && !isTextFile(sFileName)) {
                String sErrors = "Error: File: " + sFileName + " is not a text file.  The file cannot be uploaded.";
//               System.out.println(sErrors);
                setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sErrors);
                return sErrors;
            }
            // check file extension to make sure HTML file is an HTML file
            if (iFileType == FileType.CONT_HTML && !isHtmlFile(sFileName)) {
                String sErrors = "Error: File: " + sFileName + " is not an HTML file.  The file cannot be uploaded.";
//               System.out.println(sErrors);
                setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sErrors);
                return sErrors;
            }
            
            long fileLength = fStagingFile.length();
            if (fileLength == 0) {
                String sErrors = "Error: Uploaded file: " + sFileName + " has ZERO length.";
                setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sErrors);
                return sErrors;
            }
            
            // check size vs. single file size limit
            int iFileLength = new Long(fileLength).intValue();
            if (iFileLength > iFileSizeLimit) {
                String sErrors = "Error: This file excedes the single file size limit for the customer.  Limit = " + iFileSizeLimit + "; Size of this file = " + iFileLength;
                setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sErrors);
                return sErrors;
            }
            // check size vs. total size limit
            if ((iFileLength + iTotalFileSizeUsed) > iTotalFileSizeLimit) {
                String sErrors = "Error: Uploading this file would cause the total file size limit to be exceded for this customer. Limit = " + iTotalFileSizeLimit + "; Used (after upload) = " + (iFileLength + iTotalFileSizeUsed);
                setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sErrors);
                return sErrors;
            }
            
            String[] sAccessMap = { sCustId };  //ContLoad images only go to customer uploading image
            String sNewFolderId = sFolderId;
            if (makeLoadFolder) {
                sNewFolderId = ImageHostUtil.getFolderIdFromName(sCustId, sFolderId, sLoadId);
                if (sNewFolderId == null) {
                    sNewFolderId = ImageHostUtil.createFolder(sCustId, sLoadId, sFolderId, sUserId, sAccessMap);
                }
            }
            ImgFolder folder = new ImgFolder(sNewFolderId);
            
            // write file to permanent location
            String sFilePath = folder.s_file_path + sFileName;
            String sFileUrl = null;
            if (iFileType == FileType.IMAGE) {
                sFileUrl = folder.s_url_path + sFileName;
                String sImageId = ImageHostUtil.createImage(sCustId, sFileName, sNewFolderId, iFileLength, sUserId, fStagingFile, sAccessMap);
//                    System.out.println("New Image created");
                if (sImageId == null) {
//                         System.out.println("Image NOT created.");
                    String sErrors = "Error:  Image creation failed.  Cannot save Content.";
                    setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sErrors);
                    return sErrors;
                }
            } else {
                sFileUrl = folder.s_url_path + sFileName;
//                    System.out.println("writing to..." + sFilePath);
                File fPermFile = new File(sFilePath);
                if (!fPermFile.exists()) {
                    FileInputStream in = new FileInputStream(fStagingFile);
                    FileOutputStream out = new FileOutputStream(fPermFile);
                    byte[] b = new byte[32768];
                    for(int n = in.read(b); n > 0; n = in.read(b)) {
                        out.write(b, 0, n);
                    }
                    in.close();
                    out.flush();
                    out.close();
                }
            }
            
            // add record to database for file
            boolean bSuccess = false;
            bSuccess = addFileRecord(sLoadId, iFileId, iFileType, sFilePath, sFileUrl, sContentGroup);
            if (bSuccess)
                sReturn = "Success";
        } catch (Exception e) {
            sReturn = "Error: " + e.getMessage();
            setStatus(sLoadId, ContLoadStatus.ERROR_PROCESSING, sReturn);
        }
        
        return sReturn;
    }
    
    private static boolean addFileRecord(String sLoadId, int iFileId, int iFileType, String sFileName, String sFileUrl) throws Exception {
        String sContentGroup = null;
        return addFileRecord(sLoadId, iFileId, iFileType, sFileName, sFileUrl, sContentGroup);
    }
    
    private static boolean addFileRecord(String sLoadId, int iFileId, int iFileType, String sFileName, String sFileUrl, String sContentGroup) throws Exception {
        
        boolean bSuccess = false;
        ConnectionPool cp = null;
        Connection conn = null;
                
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ContLoadUtil.addFileRecord()");
            
            PreparedStatement pstmt = null;
            try {
                String sSql = "INSERT ccnt_cont_load_file " +
                        " (load_id, file_id, type_id, file_name, file_url, content_group) " +
                        " VALUES " +
                        " (?,?,?,RTRIM(?)," + ((sFileUrl==null)?"?":"RTRIM(?)") + ",?)";
                pstmt = conn.prepareStatement(sSql);
                pstmt.setString(1,sLoadId);
                pstmt.setInt(2,iFileId);
                pstmt.setInt(3,iFileType);
                pstmt.setString(4,sFileName);
                pstmt.setString(5,sFileUrl);
                pstmt.setString(6,sContentGroup);
                if ((pstmt.executeUpdate()) != 1) {
                    bSuccess = false;
                } else {
                    bSuccess = true;
                }
            } catch (Exception ex) {
                throw ex;
            } finally {
                if (pstmt!=null) pstmt.close();
            }
        } catch (Exception ex) {
            throw ex;
        } finally {
            if ( conn != null ) cp.free(conn);
        }
        return bSuccess;
        
    }
    public static String setupContent(String sLoadId, String sContName, String sCharset, String sUnsubMsgId, String sUnsubPos) throws Exception {
        String sContentGroup = null;
        String sContentType = String.valueOf(ContType.CONTENT);
        return setupContent(sLoadId, sContName, sCharset, sUnsubMsgId, sUnsubPos, sContentType, sContentGroup);
    }
    
    public static String setupContent(String sLoadId, String sContName, String sCharset, String sUnsubMsgId, String sUnsubPos, String sContentType, String sContentGroup) throws Exception {
        String sContentId = null;
        ConnectionPool cp = null;
        Connection conn = null;
        logger.info("Starting ContLoadUtil.setupContent");
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("ContLoadUtil.setupContent()");
            
            Statement stmt = null;
            PreparedStatement pstmt = null;
            
            try {
                stmt = conn.createStatement();
                ResultSet rs = null;
                
                // get list of content files for order
                String sCustID = null;
                int iFileType;
                String sTextFileName = null;
                String sHtmlFileName = null;
                String sIndexID = null;
                String sContSendTypeID = null;
                String sContText = "";
                String sContHtml = "";
                
                String sLinkURL = null;
                String sLinkName = null;
                String sSql = null;
                
                if ((sContentGroup == null)|| (sContentGroup.length() == 0)) {
                    sSql = "SELECT cl.cust_id, f.type_id, f.file_name" +
                        " FROM ccnt_cont_load cl, ccnt_cont_load_file f" +
                        " WHERE cl.load_id = f.load_id" +
                        " AND " +
                        " (f.type_id = " + FileType.CONT_TEXT +
                        " OR " +
                        " f.type_id = " + FileType.CONT_HTML + ") " +
                        " AND cl.load_id = "+sLoadId;
                } else {
                    sSql = "SELECT cl.cust_id, f.type_id, f.file_name" +
                        " FROM ccnt_cont_load cl, ccnt_cont_load_file f" +
                        " WHERE cl.load_id = f.load_id" +
                        " AND " +
                        " (f.type_id = " + FileType.CONT_TEXT +
                        " OR " +
                        " f.type_id = " + FileType.CONT_HTML + ") " +
                        " AND cl.load_id = "+sLoadId +
                        " AND f.content_group = '" +sContentGroup + "'";    
                }
                
               rs = stmt.executeQuery(sSql);
                
                while (rs.next()) {
                    sCustID = rs.getString(1);
                    iFileType = rs.getInt(2);
                    if (iFileType == FileType.CONT_TEXT) {
                        sTextFileName = rs.getString(3);
                    } else if (iFileType == FileType.CONT_HTML) {
                        sHtmlFileName = rs.getString(3);
                    } else {
                        Exception e = new Exception("File type is neither Text nor HTML");
                        logger.error("ContLoadUtil.setupContent()", e );
                        sContentId = null;
                        rs.close();
                        throw e;
                    }
                    
                }
                rs.close();
                
                // read contents of Text file and Html file into Strings
                BufferedReader read = null;
                String temp = null;
                if (sTextFileName != null) {
                    read = new BufferedReader(new FileReader(sTextFileName));
                    while ((temp = read.readLine()) != null){
                        sContText += temp + "\n";
                    }
                }
                temp = "";
                if (sHtmlFileName != null) {
                    read = new BufferedReader(new FileReader(sHtmlFileName));
                    while ((temp = read.readLine()) != null){
                        sContHtml += temp + "\n";
                    }
                }
                /* *** */
                
                // Create Content object
                Content cont = new Content();
                if ((sContentGroup == null) || (sContentGroup.length() == 0)) {
                    cont.s_cont_name = sContName;
                } else {
                    cont.s_cont_name = sContentGroup;
                }
                cont.s_status_id = String.valueOf(ContStatus.DRAFT);
                cont.s_cust_id = sCustID;
                if (sCharset != null)
                    cont.s_charset_id = sCharset;
                else
                    cont.s_charset_id = "1";
                if (sContentType != null) {
                    cont.s_type_id = sContentType;
                } else {
                    cont.s_type_id = String.valueOf(ContType.CONTENT);
                }
                
                // create child objects for new Content object
                ContBody cb = new ContBody();
                ContEditInfo cei = new ContEditInfo();
                ContSendParam csp = new ContSendParam();
                
                if (sUnsubMsgId != null)
                    csp.s_unsub_msg_id = sUnsubMsgId;
                if (sUnsubPos != null)
                    csp.s_unsub_msg_position = sUnsubPos;
                
                cb.s_text_part = sContText;             //replaceImages(sLoadId, sContText);
                csp.s_send_text_flag = "1";
                
                // Replace all references to images within the HTML with full Image URL
                if (sHtmlFileName != null) {
                    cb.s_html_part = replaceImages(sCustID, sLoadId, sContHtml);
                    csp.s_send_html_flag = "1";
                } else {
                    csp.s_send_html_flag = "0";
                }
                /* *** */
                
                cont.m_ContBody = cb;
                cont.m_ContSendParam = csp;
                cont.m_ContEditInfo = cei;
                
                // Save created Content object
                cont.save();
                sContentId = cont.s_cont_id;
                /* *** */
                
                // update ccnt_cont_load with cont.s_cont_id
                sSql = "UPDATE ccnt_cont_load " +
                        " set cont_id = " + sContentId +
                        ", status_id = " + ContLoadStatus.COMPLETE +
                        ", status_desc = '" + ContLoadStatus.getDisplayName(ContLoadStatus.COMPLETE) + "'" +
                        " WHERE load_id = " + sLoadId;
                int iUpdate = stmt.executeUpdate(sSql);
                if (iUpdate != 1) {
                    throw new Exception("Error while updating Content Load table with content ID.  Update statement returned result != 1");
                }
                /* *** */
                
            } catch (Exception ex) {
                throw ex;
            } finally {
                if (stmt!=null) stmt.close();
            }
        } catch (Exception ex) {
            throw ex;
        } finally {
            if ( conn != null ) cp.free(conn);
        }
        return sContentId;
    }
    
    private static String getStagingPath() throws Exception {
        String sStagingPath = Registry.getKey("img_staging_path");
        sStagingPath += "content_load\\";
        File fTmp = new File(sStagingPath);
        if (!fTmp.exists())
            fTmp.mkdirs();
        return sStagingPath;
    }
    
    private static int getFileType(String sFileName, String sCustId) throws Exception {
        if (isTextFile(sFileName))
            return FileType.CONT_TEXT;
        else if (isHtmlFile(sFileName))
            return FileType.CONT_HTML;
        else if (ImageHostUtil.isImageFile(sFileName, sCustId))
            return FileType.IMAGE;
        else if (isZipFile(sFileName))
            return FileType.ZIP;
        else
            return 0;
    }
    
    
}






