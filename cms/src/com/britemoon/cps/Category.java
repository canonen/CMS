package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;

import org.w3c.dom.*;

public class Category extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_category_id = null;
	public String s_category_name = null;
	public String s_category_descrip = null;
	private static Logger logger = Logger.getLogger(Category.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public Category()
	{
	}
	
	public Category(String sCustId, String sCategoryId) throws Exception
	{
		s_cust_id = sCustId;
		s_category_id = sCategoryId;
		retrieve();
	}

	public Category(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	category_id," +
		"	category_name," +
		"	category_descrip" +
		" FROM ccps_category" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(category_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_category_id);

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
		s_category_id = rs.getString(2);
		b = rs.getBytes(3);
		s_category_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_category_descrip = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_category_save" +
		"	@cust_id=?," +
		"	@category_id=?," +
		"	@category_name=?," +
		"	@category_descrip=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_category_id);
		if(s_category_name == null) pstmt.setString(3, s_category_name);
		else pstmt.setBytes(3, s_category_name.getBytes("UTF-8"));
		if(s_category_descrip == null) pstmt.setString(4, s_category_descrip);
		else pstmt.setBytes(4, s_category_descrip.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_category_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_category" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(category_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_category_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "category";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_category_id != null ) XmlUtil.appendTextChild(e, "category_id", s_category_id);
		if( s_category_name != null ) XmlUtil.appendCDataChild(e, "category_name", s_category_name);
		if( s_category_descrip != null ) XmlUtil.appendCDataChild(e, "category_descrip", s_category_descrip);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_category_id = XmlUtil.getChildTextValue(e, "category_id");
		s_category_name = XmlUtil.getChildCDataValue(e, "category_name");
		s_category_descrip = XmlUtil.getChildCDataValue(e, "category_descrip");
	}

	// === Other Methods ===
}


