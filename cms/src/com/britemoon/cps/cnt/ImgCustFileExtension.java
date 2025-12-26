package com.britemoon.cps.cnt;

import com.britemoon.cps.*;
import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImgCustFileExtension extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_file_extension = null;
	private static Logger logger = Logger.getLogger(ImgCustFileExtension.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public ImgCustFileExtension()
	{
	}
	
	public ImgCustFileExtension(String sCustId, String sFileExtension) throws Exception
	{
		s_cust_id = sCustId;
		s_file_extension = sFileExtension;
		retrieve();
	}

	public ImgCustFileExtension(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	file_extension" +
		" FROM ccnt_img_cust_file_extension" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(file_extension=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		if(s_file_extension == null) pstmt.setString(2, s_file_extension);
		else pstmt.setBytes(2, s_file_extension.getBytes("UTF-8"));


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
		byte[] b = null;
		s_cust_id = rs.getString(1);
		b = rs.getBytes(2);
		s_file_extension = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_img_cust_file_extension_save" +
		"	@cust_id=?," +
		"	@file_extension=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		if(s_file_extension == null) pstmt.setString(2, s_file_extension);
		else pstmt.setBytes(2, s_file_extension.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			b = rs.getBytes(2);
			s_file_extension = (b == null)?null:new String(b,"UTF-8");

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_img_cust_file_extension" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(file_extension=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		if(s_file_extension == null) pstmt.setString(2, s_file_extension);
		else pstmt.setBytes(2, s_file_extension.getBytes("UTF-8"));

		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "img_cust_file_extension";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_file_extension != null ) XmlUtil.appendCDataChild(e, "file_extension", s_file_extension);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_file_extension = XmlUtil.getChildCDataValue(e, "file_extension");
	}

	// === Other Methods ===
}


