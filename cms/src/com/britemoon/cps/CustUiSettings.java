package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;

import org.w3c.dom.*;

public class CustUiSettings extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_css_filename = null;
	public String s_frame_dir = null;
	public String s_config_file = null;	
	private static Logger logger = Logger.getLogger(CustUiSettings.class.getName());
	// === Parents ===

	// === Children ===

	// === Constructors ===
	
	public CustUiSettings()
	{
	}
	
	public CustUiSettings(String sCustId) throws Exception
	{
		s_cust_id = sCustId;
		retrieve();
	}

	public CustUiSettings(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	css_filename," +
		"	frame_dir," +
		"	config_file" +
		" FROM ccps_cust_ui_settings" +
		" WHERE" +
		"	(cust_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);

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
		s_css_filename = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_frame_dir = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_config_file = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_cust_ui_settings_save" +
		"	@cust_id=?," +
		"	@css_filename=?," +
		"	@frame_dir=?," +
		"	@config_file=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		if(s_css_filename == null) pstmt.setString(2, s_css_filename);
		else pstmt.setBytes(2, s_css_filename.getBytes("UTF-8"));
		if(s_frame_dir == null) pstmt.setString(3, s_frame_dir);
		else pstmt.setBytes(3, s_frame_dir.getBytes("UTF-8"));
		if(s_config_file == null) pstmt.setString(4, s_config_file);
		else pstmt.setBytes(4, s_config_file.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_cust_ui_settings" +
		" WHERE" +
		"	(cust_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "cust_ui_settings";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_css_filename != null ) XmlUtil.appendCDataChild(e, "css_filename", s_css_filename);
		if( s_frame_dir != null ) XmlUtil.appendCDataChild(e, "frame_dir", s_frame_dir);
		if( s_config_file != null ) XmlUtil.appendCDataChild(e, "config_file", s_config_file);				
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_css_filename = XmlUtil.getChildCDataValue(e, "css_filename");
		s_frame_dir = XmlUtil.getChildCDataValue(e, "frame_dir");
		s_config_file = XmlUtil.getChildCDataValue(e, "config_file");		
	}

	// === Other Methods ===
}


