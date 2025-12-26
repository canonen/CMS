package com.britemoon.cps;

import com.britemoon.*;
import com.britemoon.cps.imc.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.apache.log4j.*;

import org.w3c.dom.*;

public class User extends BriteObject
{
	// === Properties ===

	public String s_user_id = null;
	public String s_user_name = null;
	public String s_last_name = null;		
	public String s_password = null;
	public String s_cust_id = null;
	public String s_login_name = null;
	public String s_position = null;
	public String s_phone = null;
	public String s_email = null;
	public String s_descrip = null;
	public String s_status_id = null;
	public String s_pass_exp_date = null;
	public String s_pass_notify_date = null;
	public String s_recip_owner = null;
	//added for release 5.9 , pviq changes
	public String s_pv_login = null;
	public String s_pv_password = null;
	
	private static Logger logger = Logger.getLogger(User.class.getName());

	// === Parents ===

	// === Children ===

	public AccessMasks m_AccessMasks = null;
	public UserUiSettings m_UserUiSettings = null;

	// === Constructors ===

	public User()
	{
	}
	
	public User(String sUserId) throws Exception
	{
		s_user_id = sUserId;
		retrieve();		
	}

	public User(String sUserId, String sLoginName, String sCustId) throws Exception
	{
		s_user_id = sUserId;
		s_login_name = sLoginName;
		s_cust_id = sCustId;
		try
		{
			m_bDoLogin = true;
			retrieve();
		}
		catch(Exception ex)	{ throw ex; }
		finally { m_bDoLogin = false; }
	}

	public User(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	// === DB Methods ===
	
	private boolean m_bDoLogin = false;
	
	private String m_sDefaultRetrieveSql =
		" SELECT" +
		"	user_id," +
		"	user_name," +
		"	last_name," +		
		"	password," +
		"	cust_id," +
		"	login_name," +
		"	position," +
		"	phone," +
		"	email," +
		"	descrip," +
		"	status_id," +
		"	pass_exp_date," +
		"	pass_notify_date," +
		"	recip_owner," +
		"   pv_login," + 
		"   pv_password" +
		" FROM ccps_user" +
		" WHERE" +
		"	(user_id=?)";

	private String m_sLoginRetrieveSql =
			" EXEC usp_ccps_user_retrieve" +
			" @user_id=?," +
			" @login_name=?," +
			" @cust_id=?";

	public String getRetrieveSql()
	{
		if(m_bDoLogin) return m_sLoginRetrieveSql;
		else return m_sDefaultRetrieveSql;
	}

	protected int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_user_id);

		if (m_bDoLogin)
		{
			pstmt.setString(2, s_login_name);
			pstmt.setString(3, s_cust_id);
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
		s_user_id = rs.getString(1);
		b = rs.getBytes(2);
		s_user_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_last_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_password = (b == null)?null:new String(b,"UTF-8");
		s_cust_id = rs.getString(5);
		b = rs.getBytes(6);
		s_login_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(7);
		s_position = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(8);
		s_phone = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(9);
		s_email = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(10);
		s_descrip = (b == null)?null:new String(b,"UTF-8");
		s_status_id = rs.getString(11);
		s_pass_exp_date = rs.getString(12);
		s_pass_notify_date = rs.getString(13);
		s_recip_owner = rs.getString(14);
		b = rs.getBytes(15);
		s_pv_login = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(16);
		s_pv_password = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_user_save" +
		"	@user_id=?," +
		"	@user_name=?," +
		"	@last_name=?," +
		"	@password=?," +
		"	@cust_id=?," +
		"	@login_name=?," +
		"	@position=?," +
		"	@phone=?," +
		"	@email=?," +
		"	@descrip=?," +
		"	@status_id=?," +
		"	@pass_exp_date=?," +
		"	@pass_notify_date=?," +
		"	@recip_owner=?," +
		"	@pv_login=?," +
		"	@pv_password=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_user_id);
		
		if(s_user_name == null) pstmt.setString(2, s_user_name);
		else pstmt.setBytes(2, s_user_name.getBytes("UTF-8"));
		
		if(s_last_name == null) pstmt.setString(3, s_last_name);
		else pstmt.setBytes(3, s_last_name.getBytes("UTF-8"));
		
		if(s_password == null) pstmt.setString(4, s_password);
		else pstmt.setBytes(4, s_password.getBytes("UTF-8"));
		
		pstmt.setString(5, s_cust_id);
		
		if(s_login_name == null) pstmt.setString(6, s_login_name);
		else pstmt.setBytes(6, s_login_name.getBytes("UTF-8"));
		
		if(s_position == null) pstmt.setString(7, s_position);
		else pstmt.setBytes(7, s_position.getBytes("UTF-8"));
		
		if(s_phone == null) pstmt.setString(8, s_phone);
		else pstmt.setBytes(8, s_phone.getBytes("UTF-8"));
		
		if(s_email == null) pstmt.setString(9, s_email);
		else pstmt.setBytes(9, s_email.getBytes("UTF-8"));
		
		if(s_descrip == null) pstmt.setString(10, s_descrip);
		else pstmt.setBytes(10, s_descrip.getBytes("UTF-8"));
		
		pstmt.setString(11, s_status_id);
		
		pstmt.setString(12, s_pass_exp_date);
		pstmt.setString(13, s_pass_notify_date);
		
		pstmt.setString(14, s_recip_owner);
		
		if(s_pv_login == null) pstmt.setString(15, s_pv_login);
		else pstmt.setBytes(15, s_pv_login.getBytes("UTF-8"));
		
		if(s_pv_password == null) pstmt.setString(16, s_pv_password);
		else pstmt.setBytes(16, s_pv_password.getBytes("UTF-8"));
		
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

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_AccessMasks!=null)
		{
			m_AccessMasks.s_user_id = s_user_id;
			m_AccessMasks.save(conn);
		}
		if (m_UserUiSettings!=null)
		{
			m_UserUiSettings.s_user_id = s_user_id;
			m_UserUiSettings.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_user" +
		" WHERE" +
		"	(user_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_AccessMasks!=null) m_AccessMasks.delete(conn);
		if(m_UserUiSettings!=null) m_UserUiSettings.delete(conn);		
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_user_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "user";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_user_id != null ) XmlUtil.appendTextChild(e, "user_id", s_user_id);
		if( s_user_name != null ) XmlUtil.appendCDataChild(e, "user_name", s_user_name);
		if( s_last_name != null ) XmlUtil.appendCDataChild(e, "last_name", s_last_name);
		if( s_password != null ) XmlUtil.appendCDataChild(e, "password", s_password);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_login_name != null ) XmlUtil.appendCDataChild(e, "login_name", s_login_name);
		if( s_position != null ) XmlUtil.appendCDataChild(e, "position", s_position);
		if( s_phone != null ) XmlUtil.appendCDataChild(e, "phone", s_phone);
		if( s_email != null ) XmlUtil.appendCDataChild(e, "email", s_email);
		if( s_descrip != null ) XmlUtil.appendCDataChild(e, "descrip", s_descrip);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_pass_exp_date != null ) XmlUtil.appendTextChild(e, "pass_exp_date", s_pass_exp_date);
		if( s_pass_notify_date != null ) XmlUtil.appendTextChild(e, "pass_notify_date", s_pass_notify_date);
		if( s_recip_owner != null ) XmlUtil.appendTextChild(e, "recip_owner", s_recip_owner);
		if( s_pv_login != null ) XmlUtil.appendCDataChild(e, "pv_login", s_pv_login);
		if( s_pv_password != null ) XmlUtil.appendCDataChild(e, "pv_password", s_pv_password);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_AccessMasks != null) appendChild(e, m_AccessMasks);
		if (m_UserUiSettings != null) appendChild(e, m_UserUiSettings);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_user_id = XmlUtil.getChildTextValue(e, "user_id");
		s_user_name = XmlUtil.getChildCDataValue(e, "user_name");
		s_last_name = XmlUtil.getChildCDataValue(e, "last_name");		
		s_password = XmlUtil.getChildCDataValue(e, "password");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_login_name = XmlUtil.getChildCDataValue(e, "login_name");
		s_position = XmlUtil.getChildCDataValue(e, "position");
		s_phone = XmlUtil.getChildCDataValue(e, "phone");
		s_email = XmlUtil.getChildCDataValue(e, "email");
		s_descrip = XmlUtil.getChildCDataValue(e, "descrip");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_pass_exp_date = XmlUtil.getChildTextValue(e, "pass_exp_date");
		s_pass_notify_date = XmlUtil.getChildTextValue(e, "pass_notify_date");
		s_recip_owner = XmlUtil.getChildTextValue(e, "recip_owner");
		s_pv_login = XmlUtil.getChildCDataValue(e, "pv_login");
		s_pv_password = XmlUtil.getChildCDataValue(e, "pv_password");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eAccessMasks = XmlUtil.getChildByName(e, "access_masks");
		if(eAccessMasks != null) m_AccessMasks = new AccessMasks(eAccessMasks);

		Element eUserUiSettings = XmlUtil.getChildByName(e, "user_ui_settings");
		if(eUserUiSettings != null) m_UserUiSettings = new UserUiSettings(eUserUiSettings);
	}

	// === Other Methods ===

	public AccessPermission getAccessPermission(int iObjectType)
	{
		return new AccessPermission(getAccessMask(iObjectType));
	}

	public int getAccessMask(int iObjectType)
	{
		int iMask = 0;
		try
		{
			AccessMask am = new AccessMask(s_user_id, String.valueOf(iObjectType));
			iMask = Integer.parseInt(am.s_mask);
		}
		catch(Exception ex)
		{
			iMask = 0;
		}

		return iMask;
	}
	
	// === === ===

	public void saveWithSync() throws Exception
	{
		if (m_UserUiSettings!=null)
		{
			// as category is CCPS setting only
			// save it and restore after sync

			String sCustId = m_UserUiSettings.s_cust_id;
			String sCategory = m_UserUiSettings.s_category_id;
						
			synchronize();
			
			m_UserUiSettings.s_cust_id = sCustId;
			m_UserUiSettings.s_category_id = sCategory;
		}
		else synchronize();
		
		save();
	}

	private void synchronize() throws Exception
	{
		String sRequest = this.toXml();
		String sResponse = Service.communicate(ServiceType.SADM_USER_SETUP, s_cust_id, sRequest);

		Element eResponse = XmlUtil.getRootElement(sResponse);
		this.fromXml(eResponse);
	}
	
	public boolean isPassExpiring() throws Exception
	{
		boolean b_return = false;

		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			Statement stmt  = null;
			ResultSet rs = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);

			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT u.user_id" +
					" FROM ccps_user u, ccps_customer c" +
					" WHERE" +
					"	u.cust_id = c.cust_id" +
					"	AND datediff(d, GETDATE(), u.pass_exp_date) < c.pass_notify_days" + 
					"	AND	isnull(datediff(d, GETDATE(), u.pass_notify_date), 0) >= 0" +
					"	AND u.user_id = '" + s_user_id + "'" + 
					" ORDER BY u.user_id";
					
				rs = stmt.executeQuery(sSql);

				while (rs.next())
				{
					b_return = true;
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) { logger.error("Exception: ", ex);}
		finally { if (conn!=null) cp.free(conn); }
		
		return b_return;
	}
	
	public boolean isPassHasExpired() throws Exception
	{
		boolean b_return = false;

		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			Statement stmt  = null;
			ResultSet rs = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);

			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT u.user_id" +
					" FROM ccps_user u" +
					" WHERE" +
					"	u.pass_exp_date <= GETDATE()" +
					"	AND u.user_id = '" + s_user_id + "'" + 
					" ORDER BY u.user_id";
					
				rs = stmt.executeQuery(sSql);

				while (rs.next())
				{
					b_return = true;
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) {logger.error("Exception: ", ex);}
		finally { if (conn!=null) cp.free(conn); }
		
		return b_return;
	}
	
	public String remainingPassDays() throws Exception
	{
		String s_days = "0";

		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			Statement stmt  = null;
			ResultSet rs = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);

			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT datediff(d, GETDATE(), pass_exp_date)" +
					" FROM ccps_user u" +
					" WHERE" +
					"	u.user_id = '" + s_user_id + "'";
					
				rs = stmt.executeQuery(sSql);

				while (rs.next())
				{
					s_days = rs.getString(1);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) { logger.error("Exception: ", ex);}
		finally { if (conn!=null) cp.free(conn); }
		
		return s_days;
	}
}
