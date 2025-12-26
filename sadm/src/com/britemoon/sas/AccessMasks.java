package com.britemoon.sas;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class AccessMasks extends BriteList
{
	// === Constructors ===
	//log4j implementation
	private static Logger logger = Logger.getLogger(AccessMasks.class.getName());
	public AccessMasks()
	{
	}

	public AccessMasks(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_user_id = null;
	public String s_type_id = null;
	public String s_mask = null;

	private void resetParams()
	{
		s_user_id = null;
		s_type_id = null;
		s_mask = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	user_id," +
			"	type_id," +
			"	mask" ;

		m_sFromClause = " FROM scps_access_mask ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  user_id, type_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_user_id != null) { sWhereSql += " (user_id IN (?)) "; bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
		if(s_mask != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (mask IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_user_id != null) { pstmt.setString(i, s_user_id); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_mask != null) { pstmt.setString(i, s_mask); i++; }
	}

	public void fixIds()
	{
		AccessMask accessmask = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			accessmask = (AccessMask)e.nextElement();
			if(s_type_id != null) accessmask.s_type_id = s_type_id;
			if(s_user_id != null) accessmask.s_user_id = s_user_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		AccessMask accessmask = null;
		while (rs.next())
		{
			accessmask = new AccessMask();
			accessmask.getPropsFromResultSetRow(rs);
			add(accessmask);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "access_masks";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "access_mask";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		AccessMask accessmask = null;
		for(int i = 0; i < iLength; i++)
		{
			accessmask = new AccessMask ((Element)nl.item(i));
			v.add(accessmask);
		}
		return iLength;
	}

	// === Other Methods ===
}


