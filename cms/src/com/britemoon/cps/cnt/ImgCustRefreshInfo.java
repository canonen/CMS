package com.britemoon.cps.cnt;

import com.britemoon.cps.*;
import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImgCustRefreshInfo extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_domain_prefix = null;
	public String s_refresh_url = null;
	public String s_immediate_refresh_flag = null;
	public String s_login_id = null;
	public String s_login_pwd = null;
	public String s_last_refresh_date = null;
	private static Logger logger = Logger.getLogger(ImgCustRefreshInfo.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public ImgCustRefreshInfo()
	{
	}
	
	public ImgCustRefreshInfo(String sCustId) throws Exception
	{
		s_cust_id = sCustId;
		retrieve();
	}

	public ImgCustRefreshInfo(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	domain_prefix," +
		"	refresh_url," +
		"	immediate_refresh_flag," +
		"	login_id," +
		"	login_pwd," +
		"	last_refresh_date" +
		" FROM ccnt_img_cust_refresh_info" +
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
		s_domain_prefix = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_refresh_url = (b == null)?null:new String(b,"UTF-8");
		s_immediate_refresh_flag = rs.getString(4);
		b = rs.getBytes(5);
		s_login_id = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(6);
		s_login_pwd = (b == null)?null:new String(b,"UTF-8");
		s_last_refresh_date = rs.getString(7);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_img_cust_refresh_info_save" +
		"	@cust_id=?," +
		"	@domain_prefix=?," +
		"	@refresh_url=?," +
		"	@immediate_refresh_flag=?," +
		"	@login_id=?," +
		"	@login_pwd=?," +
		"	@last_refresh_date=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		if(s_domain_prefix == null) pstmt.setString(2, s_domain_prefix);
		else pstmt.setBytes(2, s_domain_prefix.getBytes("UTF-8"));
		if(s_refresh_url == null) pstmt.setString(3, s_refresh_url);
		else pstmt.setBytes(3, s_refresh_url.getBytes("UTF-8"));
		pstmt.setString(4, s_immediate_refresh_flag);
		if(s_login_id == null) pstmt.setString(5, s_login_id);
		else pstmt.setBytes(5, s_login_id.getBytes("UTF-8"));
		if(s_login_pwd == null) pstmt.setString(6, s_login_pwd);
		else pstmt.setBytes(6, s_login_pwd.getBytes("UTF-8"));
		pstmt.setString(7, s_last_refresh_date);

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
		" DELETE FROM ccnt_img_cust_refresh_info" +
		" WHERE" +
		"	(cust_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "img_cust_refresh_info";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_domain_prefix != null ) XmlUtil.appendCDataChild(e, "domain_prefix", s_domain_prefix);
		if( s_refresh_url != null ) XmlUtil.appendCDataChild(e, "refresh_url", s_refresh_url);
		if( s_immediate_refresh_flag != null ) XmlUtil.appendTextChild(e, "immediate_refresh_flag", s_immediate_refresh_flag);
		if( s_login_id != null ) XmlUtil.appendCDataChild(e, "login_id", s_login_id);
		if( s_login_pwd != null ) XmlUtil.appendCDataChild(e, "login_pwd", s_login_pwd);
		if( s_last_refresh_date != null ) XmlUtil.appendTextChild(e, "last_refresh_date", s_last_refresh_date);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_domain_prefix = XmlUtil.getChildCDataValue(e, "domain_prefix");
		s_refresh_url = XmlUtil.getChildCDataValue(e, "refresh_url");
		s_immediate_refresh_flag = XmlUtil.getChildTextValue(e, "immediate_refresh_flag");
		s_login_id = XmlUtil.getChildCDataValue(e, "login_id");
		s_login_pwd = XmlUtil.getChildCDataValue(e, "login_pwd");
		s_last_refresh_date = XmlUtil.getChildTextValue(e, "last_refresh_date");
	}

	// === Other Methods ===
}


