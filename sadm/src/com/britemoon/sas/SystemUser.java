package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;

public class SystemUser extends BriteObject
{
	// === Properties ===

	public String s_system_user_id = null;
	public String s_partner_id = null;
	public String s_first_name = null;
	public String s_last_name = null;
	public String s_email_address = null;
	public String s_phone = null;
	public String s_username = null;	
	public String s_password = null;
	public String s_super_user_flag = null;
	public String s_status_id = null;

	// === Parents ===

	// === Children ===

	public SystemAccessMasks m_SystemAccessMasks = null;
	
	// === Constructors ===

	public SystemUser()
	{
	}
	
	public SystemUser(String sSystemUserId) throws Exception
	{
		s_system_user_id = sSystemUserId;
		retrieve();
	}

	public SystemUser(String sSystemUserId, String sUserName, String sPartId) throws Exception
	{
		s_system_user_id = sSystemUserId;
		s_username = sUserName;
		s_partner_id = sPartId;
		try
		{
			m_bDoLogin = true;
			retrieve();
		}
		catch(Exception ex)	{ throw ex; }
		finally { m_bDoLogin = false; }
	}

	public SystemUser(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	private boolean m_bDoLogin = false;
	
	// === DB Method retrieve()===

	public String m_sDefaultRetrieveSql =
		" SELECT" +
		"	system_user_id," +
		"	partner_id," +
		"	first_name," +
		"	last_name," +		
		"	email_address," +
		"	phone," +
		"	username," +
		"	password," +
		"	super_user_flag," +
		"	status_id" +
		" FROM sadm_system_user" +
		" WHERE" +
		"	(system_user_id=?)";

	private String m_sLoginRetrieveSql =
			" EXEC usp_sadm_system_user_retrieve" +
			" @system_user_id=?," +
			" @username=?," +
			" @partner_id=?";

	public String getRetrieveSql()
	{
		if(m_bDoLogin) return m_sLoginRetrieveSql;
		else return m_sDefaultRetrieveSql;
	}

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_system_user_id);

		if (m_bDoLogin)
		{
			pstmt.setString(2, s_username);
			pstmt.setString(3, s_partner_id);
		}

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
		s_system_user_id = rs.getString(1);
		s_partner_id = rs.getString(2);
		
		b = rs.getBytes(3);
		s_first_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_last_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_email_address = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(6);
		s_phone = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(7);
		s_username = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(8);
		s_password = (b == null)?null:new String(b,"UTF-8");
		s_super_user_flag = rs.getString(9);		
		s_status_id = rs.getString(10);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_system_user_save" +
		"	@system_user_id=?," +
		"	@partner_id=?," +
		"	@first_name=?," +
		"	@last_name=?," +		
		"	@email_address=?," +
		"	@phone=?," +
		"	@username=?," +
		"	@password=?," +
		"	@super_user_flag=?," +
		"	@status_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_system_user_id);
		pstmt.setString(2, s_partner_id);
		
		if(s_first_name == null) pstmt.setString(3, s_first_name);
		else pstmt.setBytes(3, s_first_name.getBytes("UTF-8"));
		
		if(s_last_name == null) pstmt.setString(4, s_last_name);
		else pstmt.setBytes(4, s_last_name.getBytes("UTF-8"));
		
		if(s_email_address == null) pstmt.setString(5, s_email_address);
		else pstmt.setBytes(5, s_email_address.getBytes("UTF-8"));
		
		if(s_phone == null) pstmt.setString(6, s_phone);
		else pstmt.setBytes(6, s_phone.getBytes("UTF-8"));
		
		if(s_username == null) pstmt.setString(7, s_username);
		else pstmt.setBytes(7, s_username.getBytes("UTF-8"));
		
		if(s_password == null) pstmt.setString(8, s_password);
		else pstmt.setBytes(8, s_password.getBytes("UTF-8"));

		pstmt.setString(9, s_super_user_flag);
		
		pstmt.setString(10, s_status_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_system_user_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_SystemAccessMasks!=null)
		{
			m_SystemAccessMasks.s_system_user_id = s_system_user_id;
			m_SystemAccessMasks.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_system_user" +
		" WHERE" +
		"	(system_user_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_SystemAccessMasks!=null) m_SystemAccessMasks.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_system_user_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "system_user";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_system_user_id != null ) XmlUtil.appendTextChild(e, "system_user_id", s_system_user_id);
		if( s_partner_id != null ) XmlUtil.appendTextChild(e, "partner_id", s_partner_id);
		if( s_first_name != null ) XmlUtil.appendCDataChild(e, "first_name", s_first_name);
		if( s_last_name != null ) XmlUtil.appendCDataChild(e, "last_name", s_last_name);
		if( s_email_address != null ) XmlUtil.appendCDataChild(e, "email_address", s_email_address);
		if( s_phone != null ) XmlUtil.appendCDataChild(e, "phone", s_phone);
		if( s_username != null ) XmlUtil.appendCDataChild(e, "username", s_username);
		if( s_password != null ) XmlUtil.appendCDataChild(e, "password", s_password);
		if( s_super_user_flag != null ) XmlUtil.appendTextChild(e, "super_user_flag", s_super_user_flag);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_SystemAccessMasks != null) appendChild(e, m_SystemAccessMasks);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_system_user_id = XmlUtil.getChildTextValue(e, "system_user_id");
		s_partner_id = XmlUtil.getChildTextValue(e, "partner_id");
		s_first_name = XmlUtil.getChildCDataValue(e, "first_name");
		s_last_name = XmlUtil.getChildCDataValue(e, "last_name");
		s_email_address = XmlUtil.getChildCDataValue(e, "email_address");
		s_phone = XmlUtil.getChildCDataValue(e, "phone");
		s_username = XmlUtil.getChildCDataValue(e, "username");
		s_password = XmlUtil.getChildCDataValue(e, "password");
		s_super_user_flag = XmlUtil.getChildTextValue(e, "super_user_flag");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eSystemAccessMasks = XmlUtil.getChildByName(e, "system_access_masks");
		if(eSystemAccessMasks != null) m_SystemAccessMasks = new SystemAccessMasks(eSystemAccessMasks);
	}

	// === Other Methods ===

	public SystemAccessPermission getAccessPermission(int iObjectType) throws SQLException
	{
		return new SystemAccessPermission(getAccessMask(iObjectType));
	}

	public int getAccessMask(int iObjectType) throws SQLException
	{
		int iMask = 0;
		try
		{
			SystemAccessMask am = new SystemAccessMask(s_system_user_id, String.valueOf(iObjectType));
			iMask = Integer.parseInt(am.s_mask);
		}
		catch(Exception ex)
		{
			iMask = 0;
		}

		return iMask;
	}
}


