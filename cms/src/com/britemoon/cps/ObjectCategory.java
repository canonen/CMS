package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;

public class ObjectCategory extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_type_id = null;
	public String s_category_id = null;
	public String s_object_id = null;
	// === Constructors ===

	public ObjectCategory()
	{
	}
	
	public ObjectCategory(String sCustId, String sCategoryId, String sTypeId, String sObjectId) throws Exception
	{
		s_cust_id = sCustId;
		s_category_id = sCategoryId;
		s_type_id = sTypeId;
		s_object_id = sObjectId;
		retrieve();
	}

	public ObjectCategory(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	type_id," +
		"	category_id," +
		"	object_id" +
		" FROM ccps_object_category" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(category_id=?) AND" +
		"	(type_id=?) AND" +
		"	(object_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_category_id);
		pstmt.setString(3, s_type_id);
		pstmt.setString(4, s_object_id);

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
		s_type_id = rs.getString(2);
		s_category_id = rs.getString(3);
		s_object_id = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_object_category_save" +
		"	@cust_id=?," +
		"	@type_id=?," +
		"	@category_id=?," +
		"	@object_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_type_id);
		pstmt.setString(3, s_category_id);
		pstmt.setString(4, s_object_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_category_id = rs.getString(2);
			s_type_id = rs.getString(3);
			s_object_id = rs.getString(4);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_object_category" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(category_id=?) AND" +
		"	(type_id=?) AND" +
		"	(object_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_category_id);
		pstmt.setString(3, s_type_id);
		pstmt.setString(4, s_object_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "object_category";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_category_id != null ) XmlUtil.appendTextChild(e, "category_id", s_category_id);
		if( s_object_id != null ) XmlUtil.appendTextChild(e, "object_id", s_object_id);
	}

	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_category_id = XmlUtil.getChildTextValue(e, "category_id");
		s_object_id = XmlUtil.getChildTextValue(e, "object_id");
	}

	// === Other Methods ===
}


