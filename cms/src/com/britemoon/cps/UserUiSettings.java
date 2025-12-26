package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;

public class UserUiSettings extends BriteObject
{
	// === Properties ===

	public String s_user_id = null;
	public String s_cust_id = null;
	public String s_category_id = null;
	public String s_ui_type_id = null;
	public String s_recip_view_count = null;
	public String s_default_page_size = null;

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public UserUiSettings()
	{
	}
	
	public UserUiSettings(String sUserId) throws Exception
	{
		s_user_id = sUserId;
		retrieve();
	}

	public UserUiSettings(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	user_id," +
		"	cust_id," +
		"	category_id," +
		"	ui_type_id," +
		"	recip_view_count," +
		"	default_page_size" +
		" FROM ccps_user_ui_settings" +
		" WHERE" +
		"	(user_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_user_id);

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
		s_user_id = rs.getString(1);
		s_cust_id = rs.getString(2);
		s_category_id = rs.getString(3);
		s_ui_type_id = rs.getString(4);
		s_recip_view_count = rs.getString(5);
		s_default_page_size = rs.getString(6);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_user_ui_settings_save" +
		"	@user_id=?," +
		"	@cust_id=?," +
		"	@category_id=?," +
		"	@ui_type_id=?," +
		"	@recip_view_count=?," +
		"	@default_page_size=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_user_id);
		pstmt.setString(2, s_cust_id);
		pstmt.setString(3, s_category_id);
		pstmt.setString(4, s_ui_type_id);
		pstmt.setString(5, s_recip_view_count);
		pstmt.setString(6, s_default_page_size);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_user_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_user_ui_settings" +
		" WHERE" +
		"	(user_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_user_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "user_ui_settings";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_user_id != null ) XmlUtil.appendTextChild(e, "user_id", s_user_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_category_id != null ) XmlUtil.appendTextChild(e, "category_id", s_category_id);
		if( s_ui_type_id != null ) XmlUtil.appendTextChild(e, "ui_type_id", s_ui_type_id);
		if( s_recip_view_count != null ) XmlUtil.appendTextChild(e, "recip_view_count", s_recip_view_count);
		if( s_default_page_size != null ) XmlUtil.appendTextChild(e, "default_page_size", s_default_page_size);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_user_id = XmlUtil.getChildTextValue(e, "user_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_category_id = XmlUtil.getChildTextValue(e, "category_id");
		s_ui_type_id = XmlUtil.getChildTextValue(e, "ui_type_id");
		s_recip_view_count = XmlUtil.getChildTextValue(e, "recip_view_count");
		s_default_page_size = XmlUtil.getChildTextValue(e, "default_page_size");
	}

	// === Other Methods ===
}


