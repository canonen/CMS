package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class Users extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(Users.class.getName());
	// === Constructors ===
	public Users()
	{
	}

	public Users(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

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

	private void resetParams()
	{
		s_user_id = null;
		s_user_name = null;
		s_last_name = null;
		s_password = null;
		s_cust_id = null;
		s_login_name = null;
		s_position = null;
		s_phone = null;
		s_email = null;
		s_descrip = null;
		s_status_id = null;
		s_pass_exp_date = null;
		s_pass_notify_date = null;
		s_recip_owner = null;
		s_pv_login = null;
		s_pv_password = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
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
			"	pv_login," +
			"	pv_password" ;

		m_sFromClause = " FROM scps_user ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  user_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_user_id != null) { sWhereSql += " (user_id IN (?)) "; bAddAnd = true; }
		if(s_user_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (user_name IN (?)) "); bAddAnd = true; }
		if(s_last_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (last_name IN (?)) "); bAddAnd = true; }	
		if(s_password != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (password IN (?)) "); bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_login_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (login_name IN (?)) "); bAddAnd = true; }
		if(s_position != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (position IN (?)) "); bAddAnd = true; }
		if(s_phone != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (phone IN (?)) "); bAddAnd = true; }
		if(s_email != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (email IN (?)) "); bAddAnd = true; }
		if(s_descrip != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (descrip IN (?)) "); bAddAnd = true; }
		if(s_status_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (status_id IN (?)) "); bAddAnd = true; }
		if(s_pass_exp_date != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (pass_exp_date IN (?)) "); bAddAnd = true; }
		if(s_pass_notify_date != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (pass_notify_date IN (?)) "); bAddAnd = true; }
		if(s_recip_owner != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (recip_owner IN (?)) "); bAddAnd = true; }
		if(s_pv_login != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (pv_login IN (?)) "); bAddAnd = true; }
		if(s_pv_password != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (pv_password IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_user_id != null) { pstmt.setString(i, s_user_id); i++; }
		if(s_user_name != null) { pstmt.setBytes(i, s_user_name.getBytes("UTF-8")); i++; }
		if(s_last_name != null) { pstmt.setBytes(i, s_last_name.getBytes("UTF-8")); i++; }
		if(s_password != null) { pstmt.setBytes(i, s_password.getBytes("UTF-8")); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_login_name != null) { pstmt.setBytes(i, s_login_name.getBytes("UTF-8")); i++; }
		if(s_position != null) { pstmt.setBytes(i, s_position.getBytes("UTF-8")); i++; }
		if(s_phone != null) { pstmt.setBytes(i, s_phone.getBytes("UTF-8")); i++; }
		if(s_email != null) { pstmt.setBytes(i, s_email.getBytes("UTF-8")); i++; }
		if(s_descrip != null) { pstmt.setBytes(i, s_descrip.getBytes("UTF-8")); i++; }
		if(s_status_id != null) { pstmt.setString(i, s_status_id); i++; }
		if(s_pass_exp_date != null) { pstmt.setBytes(i, s_pass_exp_date.getBytes("UTF-8")); i++; }
		if(s_pass_notify_date != null) { pstmt.setBytes(i, s_pass_notify_date.getBytes("UTF-8")); i++; }
		if(s_recip_owner != null) { pstmt.setString(i, s_recip_owner); i++; }
		if(s_pv_login != null) { pstmt.setBytes(i, s_pv_login.getBytes("UTF-8")); i++; }
		if(s_pv_password != null) { pstmt.setBytes(i, s_pv_password.getBytes("UTF-8")); i++; }
	}

	public void fixIds()
	{
		User user = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			user = (User)e.nextElement();
			if(s_cust_id != null) user.s_cust_id = s_cust_id;
			if(s_status_id != null) user.s_status_id = s_status_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		User user = null;
		while (rs.next())
		{
			user = new User();
			user.getPropsFromResultSetRow(rs);
			add(user);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "users";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "user";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		User user = null;
		for(int i = 0; i < iLength; i++)
		{
			user = new User ((Element)nl.item(i));
			v.add(user);
		}
		return iLength;
	}

	// === Other Methods ===
}


