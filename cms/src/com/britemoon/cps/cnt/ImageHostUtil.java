package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.util.*;
import java.net.*;
import java.util.zip.*;
import java.util.regex.*;
import java.io.*;

import com.oreilly.servlet.multipart.FilePart;
import com.oreilly.servlet.Base64Encoder;
import javax.servlet.http.HttpServletResponse;
import javax.net.ssl.*;
import org.apache.log4j.*;

// Registry variables needed:
//   img_file_path
//   img_url_path
//   img_staging_path

public class ImageHostUtil
{
	private static Logger logger = Logger.getLogger(ImageHostUtil.class.getName());
	public static boolean isImageFile(String sFileName, String sCustId) throws Exception
	{
		boolean bIsImage = false;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.isImageFile()");

			Statement stmt = null;
			try 
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT file_extension" +
					" FROM ccnt_img_cust_file_extension " +
					" WHERE cust_id = 0 OR cust_id = " + sCustId;

				ResultSet rs = stmt.executeQuery(sSql);

				String sUpperCaseFileName = sFileName.toUpperCase().trim();
				String sRegEx = null;
				while (rs.next())
				{
					sRegEx = ".*\\." + rs.getString(1).toUpperCase() + "\\Z";
					bIsImage = Pattern.matches(sRegEx, sUpperCaseFileName);
					if( bIsImage ) break;
				}
				rs.close();
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return bIsImage;
	}

	public static boolean isZipFile(String sFileName) throws Exception
	{
		String sUpperCaseFileName = sFileName.toUpperCase().trim();
		String sRegEx = ".*\\.ZIP\\Z";
		return Pattern.matches(sRegEx, sUpperCaseFileName);
	}

	public static String getFolderOptionsHTML(String sFolderId, int iIndent, String sCustId) throws Exception
	{
		return getFolderOptionsHTML(sFolderId, iIndent, "0", sCustId);
	}

	public static String getFolderOptionsHTML(String sFolderId, int iIndent, String sSelectedFolderId, String sCustId) throws Exception
	{
		String sFolderOptions = "";
		if (sFolderId == null) return sFolderOptions;

		if (sSelectedFolderId == null) sSelectedFolderId = "0";

		ImgFolder rootFolder = new ImgFolder(sFolderId);
		if (iIndent == 0)
		{
			sFolderOptions +=
				"<OPTION" +
					" value=" + sFolderId +
					" type_id=" + rootFolder.s_type_id +
					(sFolderId.equals(sSelectedFolderId)?" selected":"") +
					">"+ rootFolder.s_folder_name +
				"</OPTION>\r\n";
		}

		rootFolder.getSubFolders(sCustId);
		if (rootFolder.m_SubFolders == null || rootFolder.m_SubFolders.size() == 0)
		{
			return sFolderOptions;
		}

		// === === ===

		iIndent++;
		String sIndent = "";		
		for (int i = 0; i <= iIndent; i++) sIndent += "&nbsp;&nbsp;&nbsp;&nbsp;";

		Iterator itSubFolders = rootFolder.m_SubFolders.iterator();
		ImgFolder subFolder = null;
		while (itSubFolders.hasNext())
		{
			subFolder = (ImgFolder) itSubFolders.next();
			sFolderOptions +=
				"<OPTION " +
					" value="+subFolder.s_folder_id+
					" type_id="+subFolder.s_type_id+
					(subFolder.s_folder_id.equals(sSelectedFolderId)?" selected":"")+
					">" + sIndent + subFolder.s_folder_name +
				"</OPTION>\r\n";

			sFolderOptions += getFolderOptionsHTML(subFolder.s_folder_id,iIndent,sSelectedFolderId,sCustId);
		}

		return sFolderOptions;
	}

	public static String getFolderCustAccessHTML(String sCustId, String sFolderId) throws Exception
	{
		String sCustAccessHTML = "";

		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		Vector vChildCusts = new Vector();
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getFolderCustAccessHTML()");
			stmt = conn.createStatement();
			
			rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = "+sCustId);
			while (rs.next())
			{
				String sChildCustId = rs.getString(1);
				if (sChildCustId.equals(sCustId)) continue;
				
				String sChildCustName = rs.getString(3);
				String[] sChildCust = { sChildCustId, sChildCustName };
				vChildCusts.add(sChildCust);
			}
			rs.close();
			
			int nCol = 0;
			int nRow = 0;
			// Global Setting
			boolean bHasAccess = false;
			if (sFolderId != null)
			{
				rs = stmt.executeQuery(
					"SELECT count(*)"
					+ " FROM ccnt_img_fld_cust_access"
					+ " WHERE cust_id = 0"
					+ " AND folder_id = "+sFolderId);
				if (rs.next()) bHasAccess = ( rs.getInt(1) > 0);
				rs.close();
			}
			sCustAccessHTML += "<tr>\r\n<td class=\"listItem_Data\" colspan=3><input type=\"checkbox\""+(bHasAccess?" checked":"")+" name=\"cust_access\" value=0 onClick=\"checkGlobal(0)\" id=\"cust_check_0\"><label for=\"cust_check_0\"> Global </label></td>\r\n";


			String sClassAppend = "";
			for (int i=0; i<vChildCusts.size(); i++)
			{
				String[] sChildCust = (String[])vChildCusts.get(i);
				
				if (nCol % 3 == 0)
				{
					sCustAccessHTML += "</tr>\r\n<tr>\r\n";
					nRow++;
				}

				if (nRow % 2 != 0) sClassAppend = "_Alt";
				else	sClassAppend = "";

				bHasAccess = false;
				if (sFolderId != null)
				{
					rs = stmt.executeQuery(
						"SELECT count(*)"
						+ " FROM ccnt_img_fld_cust_access"
						+ " WHERE cust_id = "+sChildCust[0]
						+ " AND folder_id = "+sFolderId);
					if (rs.next()) bHasAccess = ( rs.getInt(1) > 0);
					rs.close();
				}
				
				sCustAccessHTML += "<td width=\"33%\" class=\"listItem_Data"+sClassAppend+"\"><input type=\"checkbox\""+(bHasAccess?" checked":"")+" name=\"cust_access\" value="+sChildCust[0]+" onClick=\"checkGlobal("+(i+1)+")\" id=\"cust_check_"+sChildCust[0]+"\"><label for=\"cust_check_"+sChildCust[0]+"\">  "+sChildCust[1]+" </label></td>\r\n";
				nCol++;
			}

			if (nCol % 3 != 0)
			{
				for (; (nCol % 3) != 0; nCol++)
				{
					sCustAccessHTML += "<td width=\"33%\" class=\"listItem_Data"+sClassAppend+"\">&nbsp;</td>\r\n";
				}
			}
			sCustAccessHTML += "</tr>\r\n";

		}
		catch (Exception e) { throw e; }
		finally
		{
			if (stmt != null)
			{
				try { stmt.close(); }
				catch (Exception e) { }
			}
			cp.free(conn);
		}

		return sCustAccessHTML;
	}

	public static String getImageCustAccessHTML(String sCustId, String sImageId) throws Exception
	{
		String sCustAccessHTML = "";

		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		Vector vChildCusts = new Vector();
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getImageCustAccessHTML()");
			stmt = conn.createStatement();
			
			rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = "+sCustId);
			while (rs.next())
			{
				String sChildCustId = rs.getString(1);
				if (sChildCustId.equals(sCustId)) continue;
				
				String sChildCustName = rs.getString(3);
				String[] sChildCust = { sChildCustId, sChildCustName };
				vChildCusts.add(sChildCust);
			}
			rs.close();
			
			int nCol = 0;
			int nRow = 0;
			// Global Setting
			boolean bHasAccess = false;
			if (sImageId != null)
			{
				rs = stmt.executeQuery(
					"SELECT count(*)"
					+ " FROM ccnt_img_cust_access"
					+ " WHERE cust_id = 0"
					+ " AND image_id = "+sImageId);
				if (rs.next()) bHasAccess = ( rs.getInt(1) > 0);
				rs.close();
			}
			sCustAccessHTML += "<tr>\r\n<td class=\"listItem_Data\" colspan=3><input type=\"checkbox\""+(bHasAccess?" checked":"")+" name=\"cust_access\" value=0 onClick=\"checkGlobal(0)\" id=\"cust_check_0\"><label for=\"cust_check_0\"> Global </label></td>\r\n";

			
			String sClassAppend = "";
			for (int i=0; i<vChildCusts.size(); i++)
			{
				String[] sChildCust = (String[])vChildCusts.get(i);

				if (nCol % 3 == 0) {
					sCustAccessHTML += "</tr>\r\n<tr>\r\n";
					nRow++;
				}

				if (nRow % 2 != 0) sClassAppend = "_Alt";
				else	sClassAppend = "";

				bHasAccess = false;
				if (sImageId != null)
				{
					rs = stmt.executeQuery(
						"SELECT count(*)"
						+ " FROM ccnt_img_cust_access"
						+ " WHERE cust_id = "+sChildCust[0]
						+ " AND image_id = "+sImageId);
					if (rs.next()) bHasAccess = ( rs.getInt(1) > 0);
					rs.close();
				}
				sCustAccessHTML += "<td width=\"33%\" class=\"listItem_Data"+sClassAppend+"\"><input type=\"checkbox\""+(bHasAccess?" checked":"")+" name=\"cust_access\" value="+sChildCust[0]+" onClick=\"checkGlobal("+(i+1)+")\" id=\"cust_check_"+sChildCust[0]+"\"><label for=\"cust_check_"+sChildCust[0]+"\">  "+sChildCust[1]+" </label></td>\r\n";
				nCol++;
			}

			if (nCol % 3 != 0)
			{
				for (; (nCol % 3) != 0; nCol++)
				{
					sCustAccessHTML += "<td width=\"33%\" class=\"listItem_Data"+sClassAppend+"\">&nbsp;</td>\r\n";
				}
			}
			sCustAccessHTML += "</tr>\r\n";
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (stmt != null) { try { stmt.close(); } catch (Exception e) { } }
			if (conn != null) cp.free(conn);
		}

		return sCustAccessHTML;
	}

	public static String getImageListHTML(String sFolderId, int iIndent, String sCustId, User user) throws Exception
	{
		String sFolderHTML = "";
		if (sFolderId == null) return sFolderHTML;

		AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

		String folderID, folderName;

		Statement			stmt			= null;
		ResultSet			rs				= null; 
		ConnectionPool	connectionPool= null;
		Connection			conn = null;

		ImgFolder rootFolder = null;
		String sClassAppend = "";
		String sDeleteWarning =
			"Are you sure you want to delete this folder and ALL subfolder and images contained within this folder?\\n" +
			"Any current Content referencing any of these images will be adversely effected.";

		rootFolder = new ImgFolder(sFolderId);
		if (rootFolder == null) return sFolderHTML;

		if (iIndent == 0)
		{
			sFolderHTML += "<tr height=22>\n";
			sFolderHTML += "<td align=left valign=middle class=dots>&nbsp;</td>\n";
			sFolderHTML += "<td align=left valign=middle><img src=\"../../images/images_folder.gif\" border=0 style=\"cursor:hand;\" onclick=\"toggleFolder('" + rootFolder.s_folder_id + "', false);\"></td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle><a href=\"folder_details.jsp?folder_id=" + rootFolder.s_folder_id + "\">" + rootFolder.s_folder_name + "</a></td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>" + rootFolder.getImgCount(sCustId) + " images</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>" + rootFolder.getImgSize(sCustId) + " bytes</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>&nbsp;</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>&nbsp;</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>&nbsp;</td>\n";
			sFolderHTML += "</tr>\n";
		}

		// display subfolders
		rootFolder.getSubFolders(sCustId);
		rootFolder.getImages(sCustId);

		if ((rootFolder.m_SubFolders == null || rootFolder.m_SubFolders.size() == 0) &&
			(rootFolder.m_Images == null || rootFolder.m_Images.size() ==0))
		{
			return sFolderHTML;
		}
		else //start a new table
		{

			sFolderHTML += "<tbody id=\"folder_" + rootFolder.s_folder_id + "\"";

			if (iIndent != 0) sFolderHTML += " style=\"display:none;\"";

			sFolderHTML += ">\n";

			iIndent++;

			sFolderHTML += "<tr>\n";
			sFolderHTML += "<td align=left valign=middle class=dotsExtender>&nbsp;</td>\n";
			sFolderHTML += "<td align=left valign=top colspan=7>\n";
			sFolderHTML += "<table cellspacing=0 cellpadding=0 border=0 class=\"layout\" style=\"width: 100%;\">\n";
			sFolderHTML += "<col width=20>\n";
			sFolderHTML += "<col width=22>\n";
			sFolderHTML += "<col>\n";
			sFolderHTML += "<col width=70>\n";
			sFolderHTML += "<col width=70>\n";
			sFolderHTML += "<col width=110>\n";
			sFolderHTML += "<col width=60>\n";
			sFolderHTML += "<col width=55>\n";
		}

/*
		if (iIndent  % 2 != 0) {
			sClassAppend = "_Alt";
		} else {
			sClassAppend = "";
		}
*/

		Iterator itSubFolders = rootFolder.m_SubFolders.iterator();
		ImgFolder subFolder = null;
		while (itSubFolders.hasNext())
		{
			subFolder = (ImgFolder) itSubFolders.next();

			sFolderHTML += "<tr height=22>\n";
			sFolderHTML += "<td align=left valign=middle class=dots>&nbsp;</td>\n";
//			sFolderHTML += "<td align=left valign=middle><img src=\"../../images/images_folder.gif\" border=0 style=\"cursor:hand;\" onclick=\"toggleFolder('" + subFolder.s_folder_id + "', false);\"></td>\n";
			sFolderHTML += "<td align=left valign=middle><a href=\"folder_details.jsp?folder_id=" + subFolder.s_folder_id + "\"><img src=\"../../images/images_folder.gif\" border=0></a></td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle><a href=\"folder_details.jsp?folder_id=" + subFolder.s_folder_id + "\">" + subFolder.s_folder_name + "</a></td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>" + subFolder.getImgCount(sCustId) + " images</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>" + subFolder.getImgSize(sCustId) + " bytes</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>" + ((subFolder.s_last_mod_date!=null)?subFolder.s_last_mod_date:"--") + "</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>"+((can.bWrite)?("<a class=subactionbutton href=\"#\" onClick=\"href='folder_new.jsp?folder_id=" + subFolder.s_folder_id + "&clone=1'\">Clone</a>&nbsp;"):"")+"&nbsp;</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>"+((can.bDelete)?("<a class=deletebutton href=\"#\" onClick=\"if (confirm('" + sDeleteWarning + "'))href='folder_delete.jsp?folder_id=" + subFolder.s_folder_id + "'\">Delete</a>&nbsp;"):"")+"&nbsp;</td>\n";
			sFolderHTML += "</tr>\n";

//			sFolderHTML += getImageListHTML(subFolder.s_folder_id, iIndent, sCustId, user);
		}

		//display Images

		Iterator itImages = rootFolder.m_Images.iterator();
		Image image = null;
		String imageFileName = "";
		int nameStart = 0;

		while (itImages.hasNext())
		{
			image = (Image) itImages.next();

			imageFileName = image.s_url_path;
			nameStart = imageFileName.lastIndexOf("/");

			imageFileName = imageFileName.substring(nameStart + 1);

			sFolderHTML += "<tr height=22>\n";
			sFolderHTML += "<td align=left valign=middle class=dots>&nbsp;</td>\n";
			sFolderHTML += "<td align=left valign=middle><img src=\"../../images/images_image.gif\" border=0></td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle><a href=\"image_new.jsp?image_id=" + image.s_image_id + "\">" + imageFileName + "</a></td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>&nbsp;</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>" + image.s_size + " bytes</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>" + ((image.s_last_mod_date!=null)?image.s_last_mod_date:"--") + "</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle>&nbsp;</td>\n";//<a class=subactionbutton onclick=\"image_popup('" + image.s_url_path + "');\" href='#'>Preview</a>&nbsp;&nbsp;</td>\n";
			sFolderHTML += "<td class=listItem_Data align=left valign=middle><a class=deletebutton href=\"#\" onClick=\"if (confirm('Are you sure you want to delete this image?')) href='image_delete.jsp?image_id=" + image.s_image_id + "'\">Delete</a>&nbsp;&nbsp;</td>\n";
			sFolderHTML += "</tr>\n";
		}

		sFolderHTML += "</table>\n</td>\n</tr>\n</tbody>\n";

		return sFolderHTML;

	}

//	public static String getImageListUrlHTML(String sFolderId, int iIndent) throws Exception {
//		String sFolderHTML = "";
//		String folderID, folderName;
//
//		Statement			stmt			= null;
//		ResultSet			rs				= null; 
//		ConnectionPool	connectionPool= null;
//		Connection			conn = null;
//
//		ImgFolder rootFolder = null;
//		String sClassAppend = "";
//
//		rootFolder = new ImgFolder(sFolderId);
//		if (rootFolder == null) {
//			return sFolderHTML;
//		}
//		if (iIndent == 0) {
//			sFolderHTML += "<tr>\n" +
//				"<td class=listItem_Data" + sClassAppend + " align=left valign=middle>&nbsp;</td>\n" +
//				"	<td class=listItem_Data" + sClassAppend + " width=100% align=left valign=middle colspan=5>\n" +
//				"	<table cellspacing=0 cellpadding=2 border=0 width=100% class=listTable>\n" +
//				"<tr>\n";
//
//			sFolderHTML += "	<td class=listItem_Data" + sClassAppend + " align=left valign=middle><img src='../../images/images_folder.gif' border=0></td>\n" +
//				"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle nowrap>" + rootFolder.s_folder_name + "</td>\n" +
//				"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle nowrap>&nbsp;</td>\n" +
//				"	<td class=listItem_Data" + sClassAppend + " width=100% align=left valign=middle nowrap>&nbsp;</td>\n" +
//				"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle nowrap>&nbsp;</td>\n" +
//				"</tr>\n";
//
//		}
//
//		// display subfolders
//		rootFolder.getSubFolders();
//		rootFolder.getImages();
//
//		if ((rootFolder.m_SubFolders == null || rootFolder.m_SubFolders.size() == 0) &&
//			(rootFolder.m_Images == null || rootFolder.m_Images.size() ==0)) {   
//			return sFolderHTML;
//		} else {  //start a new table
//			iIndent++;
//			sFolderHTML += "<tr>\n" +
//				"<td class=listItem_Data" + sClassAppend + " align=left valign=middle>&nbsp;</td>\n" +
//				"	<td class=listItem_Data" + sClassAppend + " width=100% align=left valign=middle colspan=5>\n" +
//				"	<table cellspacing=0 cellpadding=2 border=0 width=100% class=listTable>\n" +
//				"<tr>\n";
//		}
//
//		if (iIndent  % 2 != 0) {
//			sClassAppend = "_Alt";
//		} else {
//			sClassAppend = "";
//		}
//
//		if (rootFolder.m_SubFolders != null) {
//			Iterator itSubFolders = rootFolder.m_SubFolders.iterator();
//			ImgFolder subFolder = null;
//			while (itSubFolders.hasNext()) {
//				subFolder = (ImgFolder) itSubFolders.next();
//
//				sFolderHTML += "<tr>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle><img src='../../images/images_folder.gif' border=0></td>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle nowrap> <a href=\"folder_details_url.jsp?folder_id=" + subFolder.s_folder_id + "\">" + subFolder.s_folder_name + "</a></td>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle nowrap>" + subFolder.getImgCount() + " images</td>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " width=100% align=left valign=middle nowrap>" + subFolder.getImgSize() + " bytes used</td>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle nowrap>" + subFolder.s_last_mod_date + "</td>\n" +
//					"</tr>\n";
//
//				sFolderHTML += getImageListUrlHTML(subFolder.s_folder_id, iIndent);
//			}
//		}
//
//		//display Images
//
//		if (rootFolder.m_Images != null) {
//			Iterator itImages = rootFolder.m_Images.iterator();
//			Image image = null;
//			while (itImages.hasNext()) {
//				image = (Image) itImages.next();
//
//				if (iIndent == 0) {
//					sFolderHTML += "<tr>\n" +
//						"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle>&nbsp;</td>\n" +
//						"	<td class=listItem_Data" + sClassAppend + " width=100% align=left valign=middle colspan=5>\n" +
//						"		<table cellspacing=0 cellpadding=2 border=0 width=100% class=listTable>\n";
//				}
//
//				sFolderHTML += "<tr>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle><img src='../../images/images_image.gif' border=0></td>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle nowrap><a onclick=\"makeURL('" + image.s_url_path + "')\" href=\"#\">" + image.s_url_path + "</a></td>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " width=100% align=left valign=middle>&nbsp;</td>\n" +
//					"	<td class=listItem_Data" + sClassAppend + " align=left valign=middle><a class=subactionbutton onclick=\"image_popup('" + image.s_url_path + "');\" href='#'>Preview</a>&nbsp;&nbsp;</td>\n" +
//					"</tr>\n";
//			}
//		}
//
//		sFolderHTML += "</table>  </td>  </tr>";
//
//		return sFolderHTML;
//
//	}

	public static String getMirrorPath(String sCustId, String sUrlPath) throws Exception
	{
		String sResult = sUrlPath;
		String sMirrorDir = null;

		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		String sSql = "Select domain_prefix from ccnt_img_cust_refresh_info WHERE cust_id = "+sCustId;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.createRoot()");
			stmt = conn.createStatement();
			rs = stmt.executeQuery(sSql);
			if (rs.next()) sMirrorDir = rs.getString(1);
			rs.close();
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (stmt != null)
			{
				try { stmt.close(); }
				catch (Exception e) { }
			}
			cp.free(conn);
		}

		if (sMirrorDir != null)
		{
			String sRootDir = Registry.getKey("img_url_path") + sCustId + "/";
			sResult = sResult.replaceFirst(sRootDir, sMirrorDir);
		}
		return sResult;
	}

	public static String getRoot(String sCustId) throws Exception
	{
		String sRootId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getRoot(" + sCustId + ")");
			stmt = conn.createStatement();

			String sSql = 
				" SELECT folder_id" +
				" FROM ccnt_img_folder" +
				" WHERE cust_id = " + sCustId +
				" AND type_id = "+ ImageFolderType.STANDARD +
				" AND parent_id IS NULL";

			ResultSet rs = stmt.executeQuery(sSql);
			if (rs.next()) {
                    sRootId = rs.getString(1);
                    
                    // check if filesystem folder exists
                    if (!isFileSystemFolderCreated(sRootId)) {
                         sRootId = null;
                         throw new Exception ("Error:  Database and filesystem are out of sync...Root folder exists in database but not in filesystem.");
                    }
                    
               }
			rs.close();
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (stmt != null) { try { stmt.close(); } catch (Exception e) { } }
			if (conn != null) cp.free(conn);
		}
		return sRootId;
	}

	public static String createRoot(String sCustId, String sUserId) throws Exception
	{
		String sRootId = null;
		String sFilePath = null;
		String sUrlPath = null;
		String[] sAccessMap = { sCustId };

		sFilePath = Registry.getKey("img_file_path") + sCustId + "\\";
		sUrlPath = Registry.getKey("img_url_path") + sCustId + "/";
		sRootId = createFolder(sCustId,"ROOT",sFilePath, sUrlPath, null, sUserId, sAccessMap);

		return sRootId;
	}

	public static String getGlobalRoot(String sCustId) throws Exception
	{
		String sRootId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getGlobalRoot(" + sCustId + ")");
			stmt = conn.createStatement();

			String sTopParentId = sCustId;
			rs = stmt.executeQuery("EXEC usp_ccps_cust_parent_chain_get @cust_id = " + sCustId);
			while (rs.next())
			{
				//only interested in last customer on chain
				sTopParentId = rs.getString(1);
			}
			rs.close();

			rs = stmt.executeQuery(
				"SELECT folder_id"
				+ " FROM ccnt_img_folder"
				+ " WHERE cust_id = " + sTopParentId 
				+ " AND type_id = "+ ImageFolderType.GLOBAL
				+ " AND parent_id IS NULL");
			if (rs.next()) {
				sRootId = rs.getString(1);

                    // check if filesystem folder exists
                    if (!isFileSystemFolderCreated(sRootId)) {
                         sRootId = null;
                         throw new Exception ("Error:  Database and filesystem are out of sync...Global Root folder exists in database but not in filesystem.");
                    }
                    

			}
			rs.close();
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (stmt != null)
			{
				try { stmt.close(); } catch (Exception e) { }
			}
			cp.free(conn);
		}
		return sRootId;
	}

	public static String createGlobalRoot(String sCustId, String sUserId) throws Exception
	{
		String sRootId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		String sTopParentId = sCustId;
		int nParentCount = -1;
		int nChildCount = -1;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getGlobalRoot(" + sCustId + ")");
			stmt = conn.createStatement();

			rs = stmt.executeQuery("EXEC usp_ccps_cust_parent_chain_get @cust_id = " + sCustId);
			while (rs.next())
			{
				//only interested in last customer on chain
				sTopParentId = rs.getString(1);
				nParentCount++;
			}
			rs.close();

			rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + sCustId);
			while (rs.next())
			{
				//only interested in last customer on chain
				nChildCount++;
			}
			rs.close();
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (stmt != null)
			{
				try { stmt.close(); } catch (Exception e) { }
			}
			cp.free(conn);
		}
		
		if ((nParentCount <= 0) && (nChildCount <= 0))
		{
			// not in a family
			return null;
		}
		
		String sFilePath = null;
		String sUrlPath = null;
		String[] sAccessMap = null;

		sFilePath = Registry.getKey("img_file_path") + sTopParentId + "G\\";
		sUrlPath = Registry.getKey("img_url_path") + sTopParentId + "G/";
		sRootId = createFolder(sTopParentId,"GLOBAL",sFilePath, sUrlPath, null, sUserId, sAccessMap);

		return sRootId;
	}

	private static ImgFolder cloneSubFolders(ImgFolder origSubFolder, String sParentId, String sUserId, String sCustId, String[] sAccessMap) throws Exception
	{
		// first 'clone' the actual folder
		ImgFolder newFolder = cloneFolder(origSubFolder, sParentId, sUserId, sCustId, sAccessMap);

		// next clone all the subfolders
		origSubFolder.getSubFolders(sCustId);
		if (origSubFolder.m_SubFolders != null)
		{
			Iterator itSubFolders = origSubFolder.m_SubFolders.iterator();
			ImgFolder tmpFolder = null;
			while (itSubFolders.hasNext())
			{
				tmpFolder = (ImgFolder)itSubFolders.next();
				newFolder.m_SubFolders.add(cloneSubFolders(tmpFolder, newFolder.s_folder_id, sUserId, sCustId, sAccessMap));
			}
		}

		// then the images
		origSubFolder.getImages(sCustId);
		if (origSubFolder.m_Images != null)
		{
			Iterator itImages = origSubFolder.m_Images.iterator();
			Image tImg = null;
			while (itImages.hasNext())
			{
				tImg = (Image)itImages.next();
				newFolder.m_Images.add(cloneImage(tImg, newFolder.s_folder_id, sUserId, sCustId, sAccessMap));
			}
		}
		return newFolder;
	}

	public static String cloneFolder(String sPrevFolderId, String sFolderName, String sParentId, String sUserId, String sCustId, String[] sAccessMap) throws Exception
	{
		String sFilePath = null;
		String sUrlPath = null;
		String sNewFolderId = null;
		Vector vNewSubFolders = new Vector();
		Vector vNewImages = new Vector();
		ImgFolder prevFolder = new ImgFolder(sPrevFolderId);
		ImgFolder parent = new ImgFolder(sParentId);
		sFilePath = parent.s_file_path;
		sUrlPath = parent.s_url_path;
		// first create the new folder
		sNewFolderId = createFolder(sCustId, sFolderName, sFilePath, sUrlPath, sParentId, sUserId, sAccessMap);
		ImgFolder newFolder = new ImgFolder(sNewFolderId);

		// then, create new folders for any subfolders of the original folder  !!! excluding the cloned folder just created
		prevFolder.getSubFolders(sCustId);
		if (prevFolder.m_SubFolders != null)
		{
			Iterator itSubFolders = prevFolder.m_SubFolders.iterator();
			ImgFolder tempFolder;
			while (itSubFolders.hasNext())
			{
				tempFolder = (ImgFolder)itSubFolders.next();
				if ( !sNewFolderId.equals(tempFolder.s_folder_id) )
				{   // avoid recursive nightmare
					vNewSubFolders.add(cloneSubFolders(tempFolder, sNewFolderId, sUserId, sCustId, sAccessMap));
				}
			}
			newFolder.setSubFolders(vNewSubFolders);
		}

		// then, create images for any images within the original folder
		prevFolder.getImages(sCustId);
		if (prevFolder.m_Images != null)
		{
			Iterator itImages = prevFolder.m_Images.iterator();
			while (itImages.hasNext())
			{
				vNewImages.add(cloneImage((Image)itImages.next(),sNewFolderId, sUserId, sCustId, sAccessMap));
			}
			newFolder.setImages(vNewImages);
		}

		return sNewFolderId;
	}

	public static ImgFolder cloneFolder(ImgFolder origFolder, String sParentId, String sUserId, String sCustId, String[] sAccessMap) throws Exception
	{
		ImgFolder newFolder = null;
		String sNewFolderId = null;
//		String sCustId = origFolder.s_cust_id;
		String sFolderName = origFolder.s_folder_name;
		String sFilePath = null;
		String sUrlPath = null;
		ImgFolder parent = new ImgFolder(sParentId);
		sFilePath = parent.s_file_path;
		sUrlPath = parent.s_url_path;
		sNewFolderId = createFolder(sCustId, sFolderName, sFilePath, sUrlPath, sParentId, sUserId, sAccessMap);
		newFolder = new ImgFolder(sNewFolderId);
		return newFolder;
	}

	public static String createFolder(String sCustId, String sFolderName, String sParentId, String sUserId, String[] sAccessMap) throws Exception
	{
		String sFilePath = null;
		String sUrlPath = null;
		ImgFolder parent = new ImgFolder(sParentId);
		sFilePath = parent.s_file_path;
		sUrlPath = parent.s_url_path;
		return createFolder(sCustId, sFolderName, sFilePath, sUrlPath, sParentId, sUserId, sAccessMap);
	}

	public static String createFolder(String sCustId, String sFolderName, String sFilePath, String sUrlPath, String sParentId, String sUserId, String[] sAccessMap) throws Exception
	{
		String sFolderId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sRootFlag = null;
		String sTypeId = null;

		if (sFolderName.equalsIgnoreCase("ROOT"))
		{  // creating ROOT Folder
			sRootFlag = "1";
			sTypeId = String.valueOf(ImageFolderType.STANDARD);
		}
		else if (sFolderName.equalsIgnoreCase("CONTENT_LOAD"))
		{
			sRootFlag = "2";
			sTypeId = String.valueOf(ImageFolderType.CONTENT_LOAD);
		}
		else if (sFolderName.equalsIgnoreCase("GLOBAL"))
		{
			sRootFlag = "3";
			sTypeId = String.valueOf(ImageFolderType.GLOBAL);
		}
		else
		{
			// append FolderName to File Dir and URL Dir
			sFilePath += sFolderName + "\\";
			sUrlPath += sFolderName + "/";
		}

		String sSql =
			" EXEC usp_ccnt_img_folder_save" +
			" @cust_id = ?, @folder_name = ?, @file_path = ?, @url_path = ?," +
			" @parent_id = ?, @user_id = ?, @root_flag = ?, @type_id=?";

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.createFolder(" + sCustId + "," + sFolderName + ",...)");
               // set Autocommit to false so database transaction can be rolled back if filesystem functions fail
               conn.setAutoCommit(false);

			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,sCustId);
			pstmt.setString(2,sFolderName);
			pstmt.setString(3,sFilePath);
			pstmt.setString(4,sUrlPath);
			pstmt.setString(5,sParentId);
			pstmt.setString(6,sUserId);
			pstmt.setString(7,sRootFlag);
			pstmt.setString(8,sTypeId);
			
			rs = pstmt.executeQuery();
			if (rs.next()) sFolderId = rs.getString(1);
			rs.close();
               setImageFolderAccess (conn, sCustId, sFolderId, sAccessMap);
     
               File f = new File(sFilePath);
               if ((!f.exists()) && (!f.mkdir()))
               {
               	throw new Exception("Error attempting to create folder.  'mkdir( ... )' returned FALSE for custID: " + sCustId + "; FolderName: " + sFolderName + ".");
               }
               conn.commit();
		}
		catch (Exception e) {
			conn.rollback();
            throw e; 
         }
		finally
		{
			if (pstmt != null)
			{
				try { pstmt.close(); }
				catch (Exception e) { }
			}
               try {
                    conn.setAutoCommit(true);
               }
               catch (Exception e) {
                    logger.error("Exception: ", e);
               }
			cp.free(conn);
		}

		return sFolderId;
	}

	public static boolean deleteFolder(String sCustId, String sFolderId) throws Exception
	{
		boolean bSuccess = false;
		ConnectionPool cp = null;
		Connection conn = null;

		ImgFolder folder = null;
		String sFilePath = null;

		if (sCustId == null || sFolderId == null)
		{
			throw new Exception ("Incomplete folder information for folder delete.  No customer and/or folder ID.");
		}

		//get the file path from the database into sFilePath
		//delete folder from database

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.deleteFolder(" + sFolderId + ")");
			folder = new ImgFolder(sFolderId);
			folder.delete(conn);
			bSuccess = true;
		}
		catch (Exception e)
		{
			logger.info("Exception in Util.deleteFolder()");
			logger.error("Exception: ",e);
			throw e;
		}
		finally { cp.free(conn); }

		return bSuccess;
	}

	public static String getFolderIdFromName(String sCustId, String sParentId, String sFolderName) throws Exception
	{
		String sFolderId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sSql = "Select folder_id from ccnt_img_folder WHERE parent_id = ? and folder_name = ?";

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.checkFolderIdFromName(" + sCustId + "," + sParentId + ", " + sFolderName + ")");
			pstmt = conn.prepareStatement(sSql);
//			pstmt.setString(1,sCustId);
			pstmt.setString(1,sParentId);
			pstmt.setString(2,sFolderName);
			rs = pstmt.executeQuery();
			if (rs.next())
				sFolderId = rs.getString(1);
			rs.close();
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (pstmt != null)
			{
				try { pstmt.close(); }
				catch (Exception e) { }
			}
			cp.free(conn);
		}
		return sFolderId;
	}

	public static String getFolderIdFromPath(String sCustId, String sFilePath) throws Exception
	{
		String sFolderId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sSql = "Select folder_id from ccnt_img_folder WHERE file_path = ?";

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getFolderIdFromPath(" + sCustId + "," + sFilePath + ")");
			pstmt = conn.prepareStatement(sSql);
//			pstmt.setString(1,sCustId);
			pstmt.setString(1,sFilePath);
			rs = pstmt.executeQuery();
			if (rs.next())
				sFolderId = rs.getString(1);
			rs.close();
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (pstmt != null)
			{
				try { pstmt.close(); }
				catch (Exception e) { }
			}
			cp.free(conn);
		}
		return sFolderId;
	}

	public static String getImageIdFromName(String sCustId, String sFolderId, String sImageName) throws Exception
	{
		String sImageId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sSql = "Select image_id from ccnt_image WHERE folder_id = ? and image_name = ?";

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getImageIdFromName(" + sCustId + "," + sFolderId + ", " + sImageName + ")");
			pstmt = conn.prepareStatement(sSql);
//			pstmt.setString(1,sCustId);
			pstmt.setString(1,sFolderId);
			pstmt.setString(2,sImageName);
			rs = pstmt.executeQuery();
			if (rs.next()) sImageId = rs.getString(1);
			rs.close();
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (pstmt != null)
			{
				try { pstmt.close(); }
				catch (Exception e) { }
			}
			cp.free(conn);
		}
		return sImageId;
	}

	public static Image cloneImage(Image origImage, String sNewFolderId, String sUserId, String sCustId, String[] sAccessMap)  throws Exception
	{
		ImgFolder parentFolder = new ImgFolder(sNewFolderId);
		
		if (origImage == null)
		{
			throw new Exception("Error in ImageHostUtil.cloneImage().  Original Image information not supplied.");
		}

//		String sCustId = origImage.s_cust_id;
		String sFileName = origImage.s_image_name;
		String sFolderId = sNewFolderId;
		String sFilePath = parentFolder.s_file_path;
		String sUrlPath = parentFolder.s_url_path; 
		int iFileSize = Integer.parseInt(origImage.s_size);
		File fStagingFile = new File(origImage.s_file_path);

		String sNewImageId =
			createImage(sCustId, sFileName, sFolderId, sFilePath,
				sUrlPath, iFileSize, sUserId, fStagingFile, sAccessMap);
				
		Image newImage = new Image(sNewImageId);

		return newImage;
	}

	public static String updateImage(String sCustId, String sImageId, String sFileName, String sFolderId, int iFileSize, String sUserId,File fStagingFile, String[] sAccessMap) throws Exception
	{
		String sUpdatedImageId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		ImgFolder folder = new ImgFolder(sFolderId);
		if (folder == null)
		{	
			throw new Exception("Error in ImageHostUtil.updateImage().  Error retrieving path information from parent folder.");
		}

		String sFilePath = folder.s_file_path + sFileName;
		String sUrlPath = folder.s_url_path + sFileName;

		String sSql = "Exec usp_ccnt_image_save @cust_id=?, @image_name=?, " +
			"@folder_id=?, @file_path=?, @url_path=?, @file_size=?, @user_id=?, @image_id=?";

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.updateImage(" + sCustId + "," + sFileName + ",...)");
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,sCustId);
			pstmt.setString(2,sFileName);
			pstmt.setString(3,sFolderId);
			pstmt.setString(4,sFilePath);
			pstmt.setString(5,sUrlPath);
			pstmt.setInt(6,iFileSize);
			pstmt.setString(7,sUserId);
			pstmt.setInt(8,Integer.parseInt(sImageId));

			rs = pstmt.executeQuery();
			if (rs.next()) sUpdatedImageId = rs.getString(1);
			rs.close();
						
			// System.out.println("value back after ccnt_image_save for update:" + sUpdatedImageId + " ... original image Id:" + sImageId);
		}
		catch (Exception e) { throw e; }
		finally
		{
			if (pstmt != null) { try { pstmt.close();  } catch (Exception e) {}}
			if (conn != null) cp.free(conn);
		}

		// === === ===
		
		setImageAccess (sCustId, sImageId, sAccessMap);

		// === === ===

		File f = new File(sFilePath);
		if (!f.exists())
		{
			String sErrMsg = 
				"File:" + sFileName + " does not exist in the specified location. " +
				"Cannot update Image file.";
//			throw new Exception(sErrMsg);
		}

		f.delete();
		FileInputStream in = new FileInputStream(fStagingFile);
		FileOutputStream out = new FileOutputStream(f);
		byte[] b = new byte[32768];
		for(int n = in.read(b); n > 0; n = in.read(b)) out.write(b, 0, n);
		in.close();
		out.flush();
		out.close();

		// === === ===
		
		// refreshContent(sCustId, sFolderId);
		refreshContent(sCustId, getMirrorPath(sCustId, sUrlPath));

		// === === ===
		
		return sUpdatedImageId;
	}

	public static String createImage(String sCustId, String sFileName, String sFolderId, int iFileSize, String sUserId,File fStagingFile, String[] sAccessMap) throws Exception
	{
		ImgFolder folder = new ImgFolder(sFolderId);
		String sFilePath = null;
		String sUrlPath = null;
		if (folder != null)
		{
			sFilePath = folder.s_file_path;
			sUrlPath = folder.s_url_path;
		}
		else
		{
			throw new Exception("Error in ImageHostUtil.createImage().  Error retrieving path information from parent folder.");
		}

		return createImage(sCustId, sFileName, sFolderId, sFilePath, sUrlPath, iFileSize, sUserId, fStagingFile, sAccessMap);
	}

	public static String createImage
		(String sCustId, String sFileName, String sFolderId, String sFilePath, String sUrlPath,
			int iFileSize, String sUserId, File fStagingFile, String[] sAccessMap)
				throws Exception
	{
		String sImageId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;

		sFilePath += sFileName;
		sUrlPath += sFileName;

		String sSql =
			" EXEC usp_ccnt_image_save @cust_id=?, @image_name=?, " +
			" @folder_id=?, @file_path=?, @url_path=?, @file_size=?, @user_id=?";

		try
		{
			cp = ConnectionPool.getInstance();
			
			conn = cp.getConnection("ImageHostUtil.createImage(" + sCustId + "," + sFileName + ",...)");
               // set Autocommit to False to rollback database transaction if filesystem functions fail
               conn.setAutoCommit(false);
			
			pstmt = conn.prepareStatement(sSql);
			
			pstmt.setString(1,sCustId);
			pstmt.setString(2,sFileName);
			pstmt.setString(3,sFolderId);
			pstmt.setString(4,sFilePath);
			pstmt.setString(5,sUrlPath);
			pstmt.setInt(6,iFileSize);
			pstmt.setString(7,sUserId);

			ResultSet rs  = pstmt.executeQuery();
			if (rs.next()) sImageId = rs.getString(1);
			rs.close();
               setImageAccess (conn, sCustId, sImageId, sAccessMap);
     
               File f = new File(sFilePath);
               if (!f.exists())
               {
                    FileInputStream in = new FileInputStream(fStagingFile);
                    FileOutputStream out = new FileOutputStream(f);
                    byte[] b = new byte[32768];
                    for(int n = in.read(b); n > 0; n = in.read(b)) out.write(b, 0, n);
                    in.close();
                    out.flush();
                    out.close();
               }
               else
               {
               	   throw new Exception("File: " + sFileName + " already exists in the specified location.  Cannot create Image file.");
               }
               conn.commit();
		}
		catch (Exception e) { 
			conn.rollback();
            throw e; 
        }
		finally
		{
			if (pstmt != null) { try { pstmt.close(); } catch (Exception e) { }	}
			if (conn !=null) {
                    conn.setAutoCommit(true);
                    cp.free(conn);
               }
		}


		return sImageId;
	}

	private static int getQuotaValue(String sSql, String sParam) throws Exception
	{
		int iQuotaValue = 0;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.getQuotaValue()");
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,sParam);
			rs = pstmt.executeQuery();
			if (rs.next()) iQuotaValue = rs.getInt(1);
			rs.close();
		}
		catch (Exception e)
		{
			throw e;
		}
		finally
		{
			if (pstmt != null) { try { pstmt.close(); } catch (Exception e) { }	}
			if (conn !=null) cp.free(conn);
		}

		return iQuotaValue;
	}

	private static boolean isImageDeleted(String sImageId, String sCustId) throws Exception
	{
		boolean bIsDeleted = false;
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String sSql = "Select access_flag " +
				" from ccnt_img_cust_access " +
				" WHERE image_id = ? and cust_id = ?";

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.isImageDeleted()");
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,sImageId);
			pstmt.setString(2,sCustId);
			rs = pstmt.executeQuery();
			if (rs.next()) 
		bIsDeleted = (rs.getInt(1) == -1);
			rs.close();
		}
		catch (Exception e)
		{
			throw e;
		}
		finally
		{
			if (pstmt != null) { try { pstmt.close(); } catch (Exception e) { }	}
			if (conn !=null) cp.free(conn);
		}

		return bIsDeleted;
	}



	public static int getFileSizeLimit(String sCustId) throws Exception
	{
		int DEFAULT_FILE_SIZE_LIMIT = 1024000;	//default file size limit = 1 Meg
		String sSql = "Select ISNULL(file_capacity,0) from ccnt_img_quota WHERE cust_id = ? ";
		int iFileSizeLimit = getQuotaValue(sSql, sCustId);
		if (iFileSizeLimit == 0) iFileSizeLimit = DEFAULT_FILE_SIZE_LIMIT;

		return iFileSizeLimit;
	}

	public static int getTotalFileSizeLimit(String sCustId) throws Exception
	{
		int DEFAULT_TOTAL_FILE_SIZE_LIMIT = 10240000;	//default total file size limit = 10 Meg
		String sSql = "Select ISNULL(total_capacity,0) from ccnt_img_quota WHERE cust_id = ? ";
		int iTotalFileSizeLimit = getQuotaValue(sSql, sCustId);
		if (iTotalFileSizeLimit == 0) iTotalFileSizeLimit = DEFAULT_TOTAL_FILE_SIZE_LIMIT;

		return iTotalFileSizeLimit;
	}

	public static int getTotalFileSizeUsed(String sCustId) throws Exception
	{
		String sSql = "EXEC usp_ccnt_img_total_file_size_get @cust_id = ?";
		int iTotalFileSizeUsed = getQuotaValue(sSql, sCustId);
		return iTotalFileSizeUsed;
	}

	public static int getZipFileLimit(String sCustId) throws Exception
	{
		int DEFAULT_ZIP_FILE_SIZE_LIMIT = 10240000; //default total file size limit = 10 Meg		
		String sSql = "Select ISNULL(zip_file_capacity,0) from ccnt_img_quota WHERE cust_id = ? ";
		int iZipFileLimit = getQuotaValue(sSql, sCustId);
		if (iZipFileLimit == 0) iZipFileLimit = DEFAULT_ZIP_FILE_SIZE_LIMIT;
		
		return iZipFileLimit;
	}

	public static String processFile(FilePart fpImage, String sCustId, String sFolderId, String sUserId, String sImageId, String sFileName, boolean bOverwrite, String[] sAccessMap) throws Exception
	{
		boolean bNewImage = false;
		String sReturn = null;

		int iTotalFileSizeLimit = ImageHostUtil.getTotalFileSizeLimit(sCustId);
		int iTotalFileSizeUsed = ImageHostUtil.getTotalFileSizeUsed(sCustId);
		int iFileSizeLimit = ImageHostUtil.getFileSizeLimit(sCustId);

		if (sImageId == "0")
			bNewImage = true;
		if (!bNewImage) { // this is an edit
			Image img = new Image(sImageId);
			if (!img.s_image_name.equalsIgnoreCase(sFileName)) {
				String sErrors = "Error: Image editing failed.  The selected file has a different name from the original.";
				return sErrors;
			}
		}

		// check file extension to make sure it is an image file
		if(!ImageHostUtil.isImageFile(sFileName, sCustId)) {
			String sErrors = "Error: File:" + sFileName + " is not an image file.  The file cannot be uploaded.";
			return sErrors;
		}
		ImgFolder folder = new ImgFolder(sFolderId);
		boolean bImageExists = false;

		// check for duplicate path
		String sExistingImageId = ImageHostUtil.getImageIdFromName(sCustId, sFolderId,sFileName);
		if (sExistingImageId != null) {
			bImageExists = true;
			// OK for overwrite, not OK for new
			if(bNewImage && !bOverwrite) {
		String sErrors = null;
		if (isImageDeleted(sExistingImageId, sCustId)) {
			sErrors = "Error: An inactive image with this name,'" + sFileName + "', exists in the system and cannot be overwritten.  You may either 1) upload your image file with a different name; or 2) Contact Support to reactivate the '" + sFileName + "' image and then edit the image from the image detail page.";
		} else {
			sErrors = "Error: File:" + sFileName + " already exists.  To overwrite this file, edit the image.";
		}
				return sErrors;
			}
		}

		// write to staging folder
		String sStagingPath = Registry.getKey("img_staging_path");
		sStagingPath += sCustId + "_" + new java.util.Date().getTime() + "_" + sFileName;
		File fStagingFile = new File(sStagingPath);
		if (fStagingFile.exists()) {
			bImageExists = true;
			// this technically shouldn't be possible
			String sErrors = "Error: Error attempting to save file to staging area. Please try uploading again.";
			return sErrors;
		}
		long fileLength = fpImage.writeTo(fStagingFile);
		if (fileLength == 0) {
			String sErrors = "Error: Image file has ZERO length.";
			return sErrors;
		}

		// check size vs. single file size limit
		int iFileLength = new Long(fileLength).intValue();
		if (iFileLength > iFileSizeLimit) {
			//bad
//		System.out.println("This file excedes the single file size limit for the customer.  Image cannot be uploaded.");
//		System.out.println("Limit = " + iFileSizeLimit + "; Size of this image = " + iFileLength);
			String sErrors = "Error: This file excedes the single file size limit for the customer.  The limit is " + iFileSizeLimit + " bytes, while the size of this image is " + iFileLength + " bytes.";
			return sErrors;
		}
		// check size vs. total size limit
		if((iFileLength + iTotalFileSizeUsed) > iTotalFileSizeLimit) {
			//bad
//		System.out.println("Uploading this file would cause the total file size limit to be exceded for this customer.  Image cannot be uploaded.");
//		System.out.println("Limit = " + iTotalFileSizeLimit + "; Used (after upload) = " + (iFileLength + iTotalFileSizeUsed));
			String sErrors = "Error: Uploading this file would cause the total file size limit to be exceded for this customer. The limit is " + iTotalFileSizeLimit + " bytes, and the total used (after upload) would be " + (iFileLength + iTotalFileSizeUsed) + " bytes.";
			return sErrors;
		}

		// create or update Image
		if(bNewImage) {
			sImageId = ImageHostUtil.createImage(sCustId, sFileName, sFolderId, folder.s_file_path, folder.s_url_path, iFileLength, sUserId, fStagingFile, sAccessMap);
		} else if (bImageExists) {
			sImageId = ImageHostUtil.updateImage(sCustId, sImageId, sFileName, sFolderId, iFileLength, sUserId, fStagingFile, sAccessMap);
		}
		if (sImageId != null)
			sReturn = "Success";
		else
			sReturn = "Error:  Create or Update of image: " + sFileName + " failed.  Create or Update method caused an error.";

		return sReturn;
	}


	public static Vector processZipFile
		(com.oreilly.servlet.multipart.FilePart fpZip, String sCustId, String sParentFolderId,
			String sUserId, boolean bOverwrite, String[] sAccessMap)
				throws Exception
	{
		Vector vZipFiles = null;
		// save to staging area
		InputStream fin = fpZip.getInputStream();
		String sStagingPath = Registry.getKey("img_staging_path");
		sStagingPath += sCustId + "_" + new java.util.Date().getTime() + "_" + fpZip.getFileName();
		File fStagingFile = new File(sStagingPath);
		FileOutputStream fout = new FileOutputStream(fStagingFile);
		byte[] b = new byte[32768];
		for(int n = fin.read(b); n > 0; n = fin.read(b)) fout.write(b, 0, n);
		fin.close();
		fout.flush();
		fout.close();

		// check quota for ZIP
		int iZipLength = new Long(fStagingFile.length()).intValue();
		int iZipLimit = getZipFileLimit(sCustId);
		if ( iZipLength > iZipLimit ) {
			vZipFiles = new Vector();
			vZipFiles.add("<td>" + fpZip.getFileName() + "</td><td>ZIP File</td><td><font color=red>Error</font></td><td>The upload file size limit is " + iZipLimit + " bytes. The uploaded ZIP file was " + iZipLength + " bytes.</td>");
			return vZipFiles;
		}

		vZipFiles = unzipPackage(sStagingPath, sCustId, sParentFolderId, sUserId, bOverwrite, sAccessMap);

		return vZipFiles;

	}

	public static Vector unzipPackage
		(String sZipFile, String sCustId, String sParentFolderId,
			String sUserId, boolean bOverwrite, String[] sAccessMap)
				throws Exception
	{
		Vector vZipFiles = new Vector();
		int BUFFER = 2048;
		ZipFile zf = null;
		try
		{
			String sStageFileDir = Registry.getKey("img_staging_path");

			ImgFolder baseFolder = new ImgFolder(sParentFolderId);
			String sFolderFileDir = baseFolder.s_file_path;
			String sFolderUrlDir = baseFolder.s_url_path;

			BufferedOutputStream dest = null;
			BufferedInputStream is = null;
			ZipEntry entry;
//		System.out.println("ZIP file:" + sZipFile);
			zf = new ZipFile(sZipFile);

			Enumeration e = zf.entries();
			// 2 passes thru Zip file
			// 1st pass - process the directories
			String sPathName = null;
			boolean bDirectoryFound = false;
			while (e.hasMoreElements())
			{
				entry = (ZipEntry) e.nextElement();
				sPathName = entry.getName();
				bDirectoryFound = false;
//		System.out.println("in ZIP entry loop...entry:" + sPathName);
//		System.out.println(sPathName + " is a directory?:" + entry.isDirectory());
				if(sPathName.indexOf("/") != -1)
				{
//			System.out.println("found directory in entry:" + sPathName);
//			System.out.println(sPathName + " is a directory?:" + entry.isDirectory());
					bDirectoryFound = true;
					sPathName = sPathName.substring(0,sPathName.lastIndexOf("/")+1);
//			System.out.println("truncated pathname is now:" + sPathName);
				} 
				if (entry.isDirectory() || bDirectoryFound)
				{
					logger.info("Extracting directory(s) for entry:" + entry.getName());
					String sTmpParentFolderId = sParentFolderId;
					String sTmpId;
					// directory entry will look like: sub1/sub2/.../
					String[] sDirs = sPathName.split("/");
					for (int i = 0; i < sDirs.length; i++)
					{
//			System.out.println("Processing directory:" + sDirs[i]);
						if((sTmpId = getFolderIdFromName(sCustId,sTmpParentFolderId,sDirs[i])) != null)
						{
//				System.out.println("Folder:" + sDirs[i] + " already exists.");
							sTmpParentFolderId = sTmpId;
						}
						else
						{
//				System.out.println("Creating folder:" + sDirs[i]);
							sTmpParentFolderId = createFolder(sCustId,sDirs[i],sTmpParentFolderId, sUserId, sAccessMap);
							String sSuccess = "<td>" + sDirs[i] + "</td><td>Folder</td><td>Created</td><td>--</td>";
							vZipFiles.add(sSuccess);
						}
					}
					// create the path in the staging area
					File f = new File(sStageFileDir + sPathName);
					if (!f.exists())
					{
						if (!f.mkdirs() )
						{
							String sError = "<td>" + entry.getName() + "</td><td>Folder</td><td><font color=red>Error</font></td><td>There was a system error while unzipping the file.<!--Error in ImageHostUtil.unzipPackage().  Could not create unzipped folder:" + sPathName + " in staging area.  'mkdirs()' method returned FALSE.--></td>";
							vZipFiles.add(sError);
						}
					}
				}
			}
			//2nd pass - process the files
			e = zf.entries();
			while (e.hasMoreElements())
			{
				entry = (ZipEntry) e.nextElement();
				if (!entry.isDirectory())
				{
					// process the entry as a file
					// write the file to the staging area
//			System.out.println("Processing file from ZIP.");
					String sEntryName = entry.getName();
					String sFileName = sEntryName;
					String sEntryPath = "";
					if (sEntryName.indexOf("/") != -1)
					{
						sEntryPath = sEntryName.substring(0,sEntryName.lastIndexOf("/") + 1);
						sEntryPath = sEntryPath.replace('/','\\');
						sFileName = sEntryName.substring(sEntryName.lastIndexOf("/") + 1);
					}
//			System.out.println("sStageFiledir:" + sStageFileDir + " ; sEntryName:" + sEntryName + " ; sFileName:" + sFileName + " ; sEntryPath:"+ sEntryPath);
					String sFullStagingPath = sStageFileDir + sEntryPath + sCustId + "_" + new java.util.Date().getTime() + sFileName;
//			System.out.println("Extracting file from entry:" + sEntryName + " to:" + sFullStagingPath + "...sEntryPath:" + sEntryPath + "; sFileName:" + sFileName);
					is = new BufferedInputStream (zf.getInputStream(entry));
					int count;
					byte data[] = new byte[BUFFER];
					FileOutputStream fos = new FileOutputStream(sFullStagingPath);
					dest = new BufferedOutputStream(fos, BUFFER);
					while ((count = is.read(data, 0, BUFFER)) != -1)
					{
						dest.write(data, 0, count);
					}
					dest.flush();
					dest.close();
					is.close();
//			System.out.println("file entry written..."+ sFullStagingPath);

					if (isImageFile(sFileName, sCustId))
					{
						//get file size
						File fTmp = new File(sFullStagingPath);
						if (!fTmp.exists())
						{
							String sError = "<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>There was a system error while processing the image file.<!-- Image file:" + fTmp.getName() + " does not exist.--></td>";
							vZipFiles.add(sError);
							continue;
						}

						// check file size against quotas

						int iFileSize = new Long(fTmp.length()).intValue();
						int iFileSizeLimit = getFileSizeLimit(sCustId);
						int iTotalSizeLimit = getTotalFileSizeLimit(sCustId);
						int iCurrentTotalSize = getTotalFileSizeUsed(sCustId);
						
						if (iFileSize > iFileSizeLimit)
						{
							String sError = "<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>The file size limit was exceded.\n<br>The file size limit is " + iFileSizeLimit + " bytes. The uploaded file contains " + iFileSize + " bytes.</td>";
							vZipFiles.add(sError);
							continue;
						}
						if (iFileSize + iCurrentTotalSize > iTotalSizeLimit)
						{
							String sError = "<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>The total size of all files combined would be exceded for this customer.\n<br>The total file size limit for the customer is " + iTotalSizeLimit + " bytes. The uploaded file would increase the total size to " + (iFileSize + iCurrentTotalSize) + " bytes.</td>";
							vZipFiles.add(sError);
							continue;
						}
						/* *** */
						// get true parent folder for this image (folder could have recently been created)
						String sFolderPath = sFolderFileDir + sEntryPath;
//			System.out.println("getting Folder ID for cust:" + sCustId + " ; Path:" + sFolderPath);
						String sFolderId = getFolderIdFromPath(sCustId, sFolderPath);
						if (sFolderId == null)
						{
							String sError = "<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>There was a system error while uploading the ZIP file.<!--Error in ImageHostUtil.unzipPackage() attempting to retrieve FolderID from Pathname:" + sFolderPath + "--></td>";
							vZipFiles.add(sError);
							continue;
						}
						/* *** */
						// create Image
						String sImageId = null;
						sImageId = getImageIdFromName(sCustId, sFolderId,sFileName);
						if (!bOverwrite && sImageId != null) {	 // check to see if image already exists
							String sError = "<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>The image already exists and the &quot;Overwrite Existing Images&quot; option was not selected.</td>";
							vZipFiles.add(sError);
							continue;
						}
						if (sImageId == null) {
//				System.out.println("Creating image:" + sFileName);
							sImageId = createImage(sCustId, sFileName, sFolderId, iFileSize, sUserId, fTmp, sAccessMap);
						} else {
							sImageId = updateImage(sCustId, sImageId, sFileName, sFolderId, iFileSize, sUserId, fTmp, sAccessMap);
						}

						if (sImageId == null) {
							String sError = "<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>There was a system error while uploading the ZIP file.<!--Error in ImageHostUtil.unzipPackage().  create/updateImage() returned a null value-->.</td>";
							vZipFiles.add(sError);
						} else {
							String sSuccess = "<td>" + sFileName + "</td><td>Image</td><td>Uploaded</td><td>--</td>";
							vZipFiles.add(sSuccess);
						}
					}
				}
			}
		}
		catch (Exception ex)
		{
			throw ex;
		}
		finally
		{
			if (zf != null) zf.close();
		}

		return vZipFiles;
	}

	// public static void refreshContent(String sCustId, String sFolderId) throws Exception
	public static void refreshContent(String sCustId) throws Exception
	{
		int iImmediateRefresh = 0;
		String sRefreshUrl = null, sLoginId = null, sLoginPwd = null;


		ImgCustRefreshInfo icri = new ImgCustRefreshInfo(sCustId);

          if (icri == null) {
          	throw new Exception("Image refresh failed.  No customer refresh information exists in database.");
          }
		
          if (icri.s_immediate_refresh_flag == null) {
          	throw new Exception("Image refresh failed.  Customer refresh information does not exist or is incomplete.");
          }

          iImmediateRefresh = Integer.parseInt(icri.s_immediate_refresh_flag);
          sRefreshUrl = icri.s_refresh_url;
          sLoginId = icri.s_login_id;
          sLoginPwd = icri.s_login_pwd;

		// === === ===

		if (iImmediateRefresh != 1 || sRefreshUrl == null) return;
		if (sLoginId == null || sLoginPwd == null)		{
			throw new Exception("Image refresh failed.  No Login information supplied for content refresh for customer " + sCustId);
		}

		// get URL info from database, given sCustId
		String sFullRefreshUrl = sRefreshUrl + "?id=" + sLoginId + "&pw=" + sLoginPwd;
		URL url = new URL(sFullRefreshUrl);
		HttpURLConnection huc = (HttpURLConnection) url.openConnection();
		huc.connect();

		if (huc.getResponseCode()!= HttpServletResponse.SC_OK)
		{
			String sErrMsg =
				"ERROR attempting to refresh content cache.\r\n" +
				"huc.getResponseCode()" + huc.getResponseCode() + "\r\n" +
				"huc.getResponseMessage()" + huc.getResponseMessage() + "\r\n";

			logger.info(sErrMsg);
			
			sErrMsg = 
				"Error in ImageHostUtil.refreshContent(). " +
				"Response from URL not successful. " +
				"Response:" + huc.getResponseMessage();

			throw new Exception (sErrMsg);
		}
		else
		{
			String sMsg = 
				"Successfully contacted URL to refresh content cache... " +
				"huc.getResponseCode()" + huc.getResponseCode() + "\r\n" +
				"huc.getResponseMessage():" + huc.getResponseMessage();
		}
	}

	public static void refreshContent(String sCustId, String sImageURL) throws Exception
	{
		ImgCustRefreshInfo icri = new ImgCustRefreshInfo(sCustId);
          
          if (icri == null) {
          	throw new Exception("Image refresh failed.  No customer refresh information exists in database.");
          }
		
          if (icri.s_immediate_refresh_flag == null) {
          	throw new Exception("Image refresh failed.  Customer refresh information does not exist or is incomplete.");
          }
//System.out.println(icri.toXmlNice());
//System.out.flush();
		
		int iImmediateRefresh = Integer.parseInt(icri.s_immediate_refresh_flag);

		// === === ===

		if (iImmediateRefresh != 1 || icri.s_refresh_url == null) return;
		if (icri.s_login_id == null || icri.s_login_pwd == null)
		{
			throw new Exception("Image refresh failed.  No Login information supplied for content refresh for customer " + sCustId);
		}
		doMIRefresh (icri.s_login_id, icri.s_login_pwd, icri.s_refresh_url,sImageURL, sCustId);
	}

	private static void doMIRefresh
		(String sLoginId, String sLoginPwd, String sFullRefreshUrl, String sImageURL, String sCustId)
			throws Exception
	{
//		String sFullRefreshUrl = "https://customercontrol.mirror-image.com/objectrefresh";
//sRefreshUrl + "?id=" + sLoginId + "&pw=" + sLoginPwd;

logger.info("sFullRefreshUrl = " + sFullRefreshUrl);

		URL url = new URL(sFullRefreshUrl);

		SSLContext sc = SSLContext.getInstance("SSL");
		
		TrustManager[] trustAllCerts = new TrustManager[1];
		trustAllCerts [0] = new ImageHostUtilTrustManager();
	
		sc.init(null, trustAllCerts, new java.security.SecureRandom());
		HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

		URLConnection uu = url.openConnection();

		// === === ===

logger.info("uu = " + uu);
logger.info("");
System.out.flush();
		
		// === === ===
				
		//HttpsURLConnection huc = (HttpsURLConnection) uu;
		HttpURLConnection huc = (HttpURLConnection) uu;
		String sBase64Login = Base64Encoder.encode(sLoginId + ":" + sLoginPwd);
		huc.setRequestProperty("Authorization","Basic " + sBase64Login);
		String sRequestString = "version=1.0&urls=" + sImageURL;
		logger.info("ImageHostUtil: Image refresh being requested for:" + sImageURL + "; for Cust ID:" + sCustId);
		huc.setRequestMethod("POST");
		huc.setDoOutput(true);

		OutputStream out = huc.getOutputStream();
		out.write(sRequestString.getBytes("UTF-8"));
		out.flush();
		out.close();

		if (huc.getResponseCode()!= HttpServletResponse.SC_NO_CONTENT)
		{
			String sErrMsg =
				"ImageHostUtil:  ERROR attempting to refresh content cache.\r\n" +
				"huc.getResponseCode()" + huc.getResponseCode() + "\r\n" +
				"huc.getResponseMessage()" + huc.getResponseMessage() + "\r\n";

			throw new Exception (sErrMsg);
		}
		else if (!huc.getHeaderField("X-MII-Success").equals("true"))
		{
			String sErrMsg =
				"ImageHostUtil:  ERROR attempting to refresh content cache.\r\n" +
				"Error from MII error code field:" + huc.getHeaderField("X-MII-ErrorCode") + "\r\n";

			throw new Exception (sErrMsg);
		}
		else
		{
			String sMsg = 
				"Successfully contacted URL to refresh content cache.  Image:" + sImageURL + "; Cust ID:" + sCustId;
			logger.info("ImageHostUtil" + sMsg);
		}
	}

	public static int setImageAccess (Connection conn, String sCustId, String sImageId, String[] sAccessMap) throws Exception
	{
		String sSql = null;
		int iReturn = 0;

		try
		{

			sSql = "EXEC usp_ccnt_img_cust_access_delete"
				+ " @cust_id = " + sCustId
				+ ", @image_id = " + sImageId;
			BriteUpdate.executeUpdate(sSql, conn);
			
			if (sAccessMap != null)
			{
				for (int i=0; i<sAccessMap.length; i++) {
					sSql = "EXEC usp_ccnt_img_cust_access_set"
						+ " @cust_id = " + sCustId
						+ ", @image_id = " + sImageId
						+ ", @access_cust_id = " + sAccessMap[i];
					BriteUpdate.executeUpdate(sSql, conn);
					iReturn++;
				}
			}
			else
			{
				//Sets Global Access to all children
				sSql = "EXEC usp_ccnt_img_cust_access_set"
					+ " @cust_id = " + sCustId
					+ ", @image_id = " + sImageId;
				iReturn = BriteUpdate.executeUpdate(sSql, conn);
			}			

		}
		catch (Exception e)
		{
			throw e;
		}

		return iReturn;
	}

	public static int setImageAccess (String sCustId, String sImageId, String[] sAccessMap) throws Exception
	{
		int iReturn = 0;
		ConnectionPool cp = null;
		Connection conn = null;

		boolean bAutoCommit = true;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.setImageAccess()");

			bAutoCommit = conn.getAutoCommit();
			conn.setAutoCommit(false);
               
               iReturn = setImageAccess (conn, sCustId, sImageId, sAccessMap);

			conn.commit();
		}
		catch (Exception e)
		{
			if (conn != null) conn.rollback();
			throw e;
		}
		finally
		{
			if (conn != null)
			{
				try { conn.setAutoCommit(bAutoCommit); }
				catch(Exception ex) { logger.error("Exception: ", ex); }
				cp.free(conn);
			}
		}

		return iReturn;
	}


	public static int setImageFolderAccess
		(Connection conn, String sCustId, String sFolderId, String[] sAccessMap)
			throws Exception
	{
		String sSql = null;
		int iReturn = 0;

		try
		{

			sSql = "EXEC usp_ccnt_img_fld_cust_access_delete"
				+ " @cust_id = " + sCustId
				+ ", @folder_id = " + sFolderId;
			BriteUpdate.executeUpdate(sSql, conn);
			
			if (sAccessMap != null) {
				for (int i=0; i<sAccessMap.length; i++) {
					sSql = "EXEC usp_ccnt_img_fld_cust_access_set"
						+ " @cust_id = " + sCustId
						+ ", @folder_id = " + sFolderId
						+ ", @access_cust_id = " + sAccessMap[i];
					BriteUpdate.executeUpdate(sSql, conn);
					iReturn++;
				}
			}
			else
			{
				//Sets Global Access to all children
				sSql = "EXEC usp_ccnt_img_fld_cust_access_set"
						+ " @cust_id = " + sCustId
						+ ", @folder_id = " + sFolderId;
				iReturn = BriteUpdate.executeUpdate(sSql, conn);
			}			

		}
		catch (Exception e)
		{
			throw e;
		}

		return iReturn;
	}
     

	public static int setImageFolderAccess
		(String sCustId, String sFolderId, String[] sAccessMap)
			throws Exception
	{
		int iReturn = 0;
		ConnectionPool cp = null;
		Connection conn = null;

		boolean bAutoCommit = true;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImageHostUtil.setImageFolderAccess()");

			bAutoCommit = conn.getAutoCommit();
			conn.setAutoCommit(false);
               
               iReturn = setImageFolderAccess(conn,sCustId, sFolderId, sAccessMap);
               conn.commit();

		}
		catch (Exception e)
		{
			if (conn != null) conn.rollback();
			throw e;
		}
		finally
		{
			if (conn != null)
			{
				try { conn.setAutoCommit(bAutoCommit); }
				catch(Exception ex) { logger.error("Exception: ", ex); }
				cp.free(conn);
			}
		}

		return iReturn;
	}
     
     private static boolean isFileSystemFolderCreated (String sFolderId) throws Exception {
          
          ImgFolder ifFolder = new ImgFolder(sFolderId);
          File fFolder = new File(ifFolder.s_file_path);
          return fFolder.exists();
     }
     
     


	public static void main (String[] args) throws Exception
	{
//		doMIRefresh("britemoon_cust", "britem00n_cust", "http://bmimageqa.00b.net/testimage.jpg","252");
		doMIRefresh("britemoon_cust", "britem00n_cust",
		"https://customercontrol.mirror-image.com/objectrefresh",
		"http://cps1.britemoon.com/ccps/ui/images/242/Test/jb.gif",
		"32");
		logger.info("done refreshing...check it out.");
	}
}
