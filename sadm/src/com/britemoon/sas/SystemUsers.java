package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;

public class SystemUsers extends BriteList
{
	// === Constructors ===

	public SystemUsers()
	{
	}

	public SystemUsers(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_system_user_id = null;
	public String s_partner_id = null;
	public String s_first_name = null;
	public String s_last_name = null;
	public String s_email_address = null;
	public String s_phone = null;
	public String s_username = null;	
	public String s_password = null;	
	public String s_status_id = null;

	private void resetParams()
	{
		s_system_user_id = null;
		s_partner_id = null;
		s_first_name = null;
		s_last_name = null;
		s_email_address = null;
		s_phone = null;
		s_username = null;	
		s_password = null;	
		s_status_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	system_user_id," +
			"	partner_id," +
			"	first_name," +
			"	last_name," +
			"	email_address," +
			"	phone," +
			"	username," +
			"	status_id" ;

		m_sFromClause = " FROM sadm_system_user ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  system_user_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_system_user_id != null) { sWhereSql += " (system_user_id IN (?)) "; bAddAnd = true; }
		if(s_partner_id != null) { sWhereSql += " (partner_id IN (?)) "; bAddAnd = true; }
		if(s_first_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (first_name IN (?)) "); bAddAnd = true; }
		if(s_last_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (last_name IN (?)) "); bAddAnd = true; }	
		if(s_email_address != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (email_address IN (?)) "); bAddAnd = true; }
		if(s_phone != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (phone IN (?)) "); bAddAnd = true; }
		if(s_username != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (username IN (?)) "); bAddAnd = true; }
		if(s_password != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (password IN (?)) "); bAddAnd = true; }
		if(s_status_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (status_id IN (?)) "); bAddAnd = true; }
		
		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_system_user_id != null) { pstmt.setString(i, s_system_user_id); i++; }
		if(s_partner_id != null) { pstmt.setString(i, s_partner_id); i++; }
		if(s_first_name != null) { pstmt.setBytes(i, s_first_name.getBytes("UTF-8")); i++; }
		if(s_last_name != null) { pstmt.setBytes(i, s_last_name.getBytes("UTF-8")); i++; }
		if(s_email_address != null) { pstmt.setBytes(i, s_email_address.getBytes("UTF-8")); i++; }
		if(s_phone != null) { pstmt.setBytes(i, s_phone.getBytes("UTF-8")); i++; }
		if(s_username != null) { pstmt.setBytes(i, s_username.getBytes("UTF-8")); i++; }
		if(s_status_id != null) { pstmt.setString(i, s_status_id); i++; }
	}

	public void fixIds()
	{
		SystemUser systemuser = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			systemuser = (SystemUser)e.nextElement();
			if(s_partner_id != null) systemuser.s_partner_id = s_partner_id;
			if(s_status_id != null) systemuser.s_status_id = s_status_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		SystemUser systemuser = null;
		while (rs.next())
		{
			systemuser = new SystemUser();
			systemuser.getPropsFromResultSetRow(rs);
			add(systemuser);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "system_users";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "system_user";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		SystemUser systemuser = null;
		for(int i = 0; i < iLength; i++)
		{
			systemuser = new SystemUser ((Element)nl.item(i));
			v.add(systemuser);
		}
		return iLength;
	}

	// === Other Methods ===
}


