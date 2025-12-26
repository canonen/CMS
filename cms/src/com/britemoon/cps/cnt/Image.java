package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.jtk.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Image extends BriteObject
{
	// === Properties ===

	public String s_image_id = null;
	public String s_folder_id = null;
	public String s_cust_id = null;
	public String s_file_path = null;
	public String s_url_path = null;
	public String s_image_name = null;
	public String s_size = null;
	public String s_last_mod_user = null;
	public String s_last_mod_date = null;
	public String s_create_user = null;
	public String s_create_date = null;
	public String s_last_refresh_date = null;
	private static Logger logger = Logger.getLogger(Image.class.getName());

	// === Constructors ===

	public Image()
	{
	}

	public Image(String sImageId) throws Exception
	{
		s_image_id = sImageId;
		retrieve();
	}

	public Image(Element e) throws Exception
	{
		fromXml(e);
	}



	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT " +
		"cust_id,  " +
		"folder_id,  " +
		"file_path,  " +
		"url_path,  " +
		"image_name, " +
		"file_size,  " +
		"last_mod_user,  " +
		"CONVERT(VARCHAR(32), last_mod_date, 100),  " +
		"create_user,  " +
		"create_date,  " +
		"last_refresh_date  " +
		" FROM ccnt_image " +
		" WHERE (image_id=?) ";

	public String getRetrieveSql()
	{ 
		return m_sRetrieveSql; 
	}

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_image_id);

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
		s_folder_id = rs.getString(2);
		s_file_path = rs.getString(3);
		s_url_path = rs.getString(4);
		s_image_name = rs.getString(5);
		s_size = rs.getString(6);
		s_last_mod_user = rs.getString(7);
		s_last_mod_date = rs.getString(8);
		s_create_user = rs.getString(9);
		s_create_date = rs.getString(10);
		s_last_refresh_date = rs.getString(11);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_image_save" +
		"	@cust_id=?," +
		"	@folder_name=?";

	public String getSaveSql()
	{ 
		return m_sSaveSql; 
	}


	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_image_id);

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
		" DELETE FROM ccnt_image" +
		" WHERE" +
		"	(image_id=?)";

	public String getDeleteSql()
	{ return m_sDeleteSql; 
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_image_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "image";
	public String getMainElementName()
	{ return m_sMainElementName; 
	}

	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
//		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
//		if( s_cont_name != null ) XmlUtil.appendCDataChild(e, "cont_name", s_cont_name);
	}

	public void appendChildrenToXml(Element e)
	{
//		if (m_ContBody != null) appendChild(e, m_ContBody);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		//		s_cont_id = XmlUtil.getChildTextValue(e, "cont_id");
		//		s_cont_name = XmlUtil.getChildCDataValue(e, "cont_name");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		//Element eContBody = XmlUtil.getChildByName(e, "cont_body");
		//if(eContBody != null) m_ContBody = new ContBody(eContBody);

	}

	// === Other Methods ===

	public boolean deleteImage (Connection conn) throws Exception
	{
		File file = new File(s_file_path);
		// delete the image file from the file system
		if (!file.delete())
		{
			throw new Exception("Could not delete Image.  Delete method returned FALSE.");
		}
		// delete this Image
		this.delete(conn);

		return true;

	}

	public boolean hide (String sCustId) throws Exception
	{
		BriteUpdate.executeUpdate("EXEC usp_ccnt_image_hide @image_id="+s_image_id+", @cust_id="+sCustId);
		return true;
	}


}


