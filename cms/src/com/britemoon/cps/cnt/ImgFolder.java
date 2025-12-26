package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.jtk.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImgFolder extends BriteObject
{
	// === Properties ===

	public String s_folder_id = null;
	public String s_folder_name = null;
	public String s_cust_id = null;
	public String s_parent_id = null;
	public String s_file_path = null;
	public String s_url_path = null;
	public String s_root_flag = null;
	public String s_last_mod_user = null;
	public String s_last_mod_date = null;
	public String s_create_user = null;
	public String s_create_date = null;
	public String s_type_id = null;
	private static Logger logger = Logger.getLogger(ImgFolder.class.getName());

	// === Parents ===

	// === Children ===

	public Vector m_SubFolders = null;
	public Vector m_Images = null;

	// === Constructors ===

	public ImgFolder()
	{
		m_SubFolders = new Vector();
		m_Images = new Vector();
	}

	public ImgFolder(String sFolderId) throws Exception
	{
		s_folder_id = sFolderId;
		retrieve();
//		getSubFolders();
//		getImages();
	}

	public ImgFolder(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
			" f.cust_id, " +
			" f.folder_name, " +
			" f.file_path, " +
			" f.url_path, " +
			" f.root_flag, " +
			" f.parent_id, " +
			" f.last_mod_user, " +
			" CONVERT(VARCHAR(32), f.last_mod_date, 100), " +
			" f.create_user, " +
			" f.create_date, " +
			" f.type_id" +
		" FROM ccnt_img_folder f" +
		" WHERE" +
			"	(f.folder_id=?) " +
		" ORDER BY f.folder_name";

	public String getRetrieveSql()
	{ 
		return m_sRetrieveSql; 
	}

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_folder_id);

		ResultSet rs = pstmt.executeQuery();
		if (rs.next())
		{
			getPropsFromResultSetRow(rs);
			nReturnCode = 1;
		}
		rs.close();

		return nReturnCode;
	}

	public void getPropsFromResultSetRow(ResultSet rs) throws Exception
	{
		s_cust_id = rs.getString(1);
		s_folder_name = rs.getString(2);
		s_file_path = rs.getString(3);
		s_url_path = rs.getString(4);
		s_root_flag = rs.getString(5);
		s_parent_id = rs.getString(6);
		s_last_mod_user = rs.getString(7);
		s_last_mod_date = rs.getString(8);
		s_create_user = rs.getString(9);
		s_create_date = rs.getString(10);
		s_type_id = rs.getString(11);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_img_folder_save" +
		"	@cust_id=?," +
		"	@folder_name=?";

	public String getSaveSql()
	{ 
		return m_sSaveSql; 
	}


	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_folder_id);

		ResultSet rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_folder_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();

		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
/*		if (m_ContBody!=null)
		{
		 	m_ContBody.s_cont_id = s_cont_id;
		  	m_ContBody.save(conn);
		}
*/
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_img_folder" +
		" WHERE" +
		"	(folder_id=?)";

	public String getDeleteSql()
	{ 
		return m_sDeleteSql; 
	}

	public int deleteChildren(Connection conn) throws Exception
	{
		logger.info("in deleteChildren for Folder:" + s_folder_name);
		try
		{
			getSubFolders();
			if (m_SubFolders != null && m_SubFolders.size() > 0)
			{
				ImgFolder subFolder = null;
				Iterator itSubFolders = m_SubFolders.iterator();
				while (itSubFolders.hasNext())
				{
					subFolder = (ImgFolder) itSubFolders.next();
					subFolder.delete(conn);
				}
			} else
			{
				logger.info("no subfolders for Folder:" + s_folder_name + "...exiting deleteChildren");
			}
			deleteFolder(conn);
		} catch (Exception e)
		{
			logger.info("Exception in ImgFolder.deteteChildren()");
			logger.error("Exception: ", e);
			throw e;
		}
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_folder_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "img_folder";
	public String getMainElementName()
	{ return m_sMainElementName; 
	}

	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
	}

	public void appendChildrenToXml(Element e)
	{
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
	}

	// === Other Methods ===


	public int getImgSize(String sCustId) throws Exception 
	{
		String sSql = " SELECT" +
			" sum(i.file_size) " +
		" FROM ccnt_img_folder f, ccnt_image i, ccnt_img_cust_access a" +
		" WHERE" +
			" f.folder_id = i.folder_id" +
			" AND i.image_id = a.image_id" +
			" AND a.cust_id = " + sCustId +
			" AND a.access_flag = 1" +
			" AND f.folder_id = " + s_folder_id;
	
		return getResultInt(sSql);
	}

	public int getImgCount(String sCustId) throws Exception 
	{
		String sSql = " SELECT" +
			" count(i.image_id) " +
		" FROM ccnt_img_folder f, ccnt_image i, ccnt_img_cust_access a" +
		" WHERE" +
			" f.folder_id = i.folder_id" +
			" AND i.image_id = a.image_id" +
			" AND a.cust_id = " + sCustId +
			" AND a.access_flag = 1" +
			" AND f.folder_id = " + s_folder_id;
	
		return getResultInt(sSql);

	}

	private int getResultInt (String sSql) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		
		int iResult = 0;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();
			rs = stmt.executeQuery(sSql);
			if (rs.next())
			{
				iResult = rs.getInt(1);
			}
			rs.close();
		} catch (Exception e) { 
			throw e;
		} finally
		{
			if (stmt != null)
			{
				try { 
					stmt.close(); 
				} catch (Exception e) { }
			}
			cp.free(conn);
		}

		return iResult;
	}



	public void getSubFolders() throws Exception
	{
		getSubFolders(s_cust_id);
	}

	public void getSubFolders(String sCustId) throws Exception
	{
		String sRootId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		if (m_SubFolders == null)
			m_SubFolders = new Vector();
		else
			return;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();

			rs = stmt.executeQuery(
				"SELECT f.folder_id"
				+ " FROM ccnt_img_folder f, ccnt_img_fld_cust_access a"
				+ " WHERE f.folder_id = a.folder_id"
				+ " AND a.cust_id = " + sCustId 
				+ " AND a.access_flag = 1"
				+ " AND f.parent_id = " + s_folder_id
				+ " ORDER BY f.folder_name");
			while (rs.next())
			{
				ImgFolder subFolder = new ImgFolder(rs.getString(1));
				m_SubFolders.add(subFolder);
			}
			rs.close();
		} catch (Exception e) { 
			throw e;
		} finally
		{
			if (stmt != null)
			{
				try { 
					stmt.close(); 
				} catch (Exception e) { }
			}
			cp.free(conn);
		}
	}

	public boolean deleteFolder (Connection conn) throws Exception
	{
		logger.info("Deleting Folder:" + s_file_path);
		boolean bSuccess = false;
		// check for and delete any Images in this ImgFolder
		getImages();
		if (m_Images != null)
		{
			Image image = null;
			Iterator itImages = m_Images.iterator();
			while (itImages.hasNext())
			{
				image = (Image) itImages.next();
				image.deleteImage(conn);
			}
		}
		// check for and delete any files in this directory from the file system
		File file = new File(s_file_path);
		File[] files = file.listFiles();
		// this should not be necessary.  The image files should have been deleted by the image.deleteImage call above
		if (files != null && files.length > 0)
		{
			for (int i = 0; i < files.length; i++)
			{
				File delFile = files[i];
				if (!delFile.delete())
				{
					if (delFile.isDirectory())
					{
						throw new Exception("Could not delete Folder.  Folder contains unknown subFolders.");
					}
				}
			}
		}
		// delete the directory from the file system
		if (!file.delete())
		{
			throw new Exception("Could not delete Folder:" + file.getName() + " or: " + s_file_path + ".  Delete method returned FALSE.");
		} else
			bSuccess = true;

		return bSuccess;
	}

	public void getImages() throws Exception
	{
		getImages(s_cust_id);
	}

	public void getImages(String sCustId) throws Exception
	{
		String sRootId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		if (m_Images == null)
			m_Images = new Vector();
		else
			return;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();
			rs = stmt.executeQuery(
				"SELECT i.image_id"
				+ " FROM ccnt_image i, ccnt_img_cust_access a"
				+ " WHERE i.image_id = a.image_id"
				+ " AND a.cust_id = " + sCustId 
				+ " AND a.access_flag = 1"
				+ " AND i.folder_id = " + s_folder_id 
				+ " ORDER BY i.image_name");
			while (rs.next())
			{
				String sImageId = rs.getString(1);
				Image image = new Image(sImageId);
				m_Images.add(image);
			}
			rs.close();
		} catch (Exception e)
		{
			throw e;
		} finally
		{
			if (stmt != null)
			{
				try
				{ 
					stmt.close(); 
				} catch (Exception e) { }
			}
			cp.free(conn);
		}
	}

	public String getPrettyPath() throws Exception 
	{
		return getPrettyPath(null);
	}

	public String getPrettyPath(String sInputName) throws Exception
	{
		String sPrettyPath = "";
		if (s_parent_id != null)
		{
			ImgFolder parent = new ImgFolder(s_parent_id);
			sPrettyPath = parent.getPrettyPath(sInputName) + "&nbsp;&nbsp;&gt;&nbsp;&nbsp;";
		}
		sPrettyPath += "<a class=\"menubarbutton\" href=\"folder_details.jsp?folder_id=" + s_folder_id + ((sInputName!=null)?("&input_name="+sInputName):"") + "\">" + s_folder_name + "</a>&nbsp;";

		return sPrettyPath;
	}

	public String getPrettyPathUrl() throws Exception
	{
		return getPrettyPathUrl(null);
	}

	public String getPrettyPathUrl(String sInputName) throws Exception
	{
		String sPrettyPath = "";
		if (s_parent_id != null)
		{
			ImgFolder parent = new ImgFolder(s_parent_id);
			sPrettyPath = parent.getPrettyPathUrl(sInputName) + " >> ";
		}
		sPrettyPath += "<a href=\"folder_details_url.jsp?folder_id=" + s_folder_id + ((sInputName!=null)?("&input_name="+sInputName):"") + "\">" + s_folder_name + "</a>";

		return sPrettyPath;
	}

	public void setSubFolders(Vector vSubFolders)
	{
		m_SubFolders = vSubFolders;
	}

	public void setImages(Vector vImages)
	{
		m_Images = vImages;
	}

	public boolean hide (String sCustId) throws Exception
	{
		BriteUpdate.executeUpdate("EXEC usp_ccnt_img_fld_hide @folder_id="+s_folder_id+", @cust_id="+sCustId);
		return true;
	}



}


