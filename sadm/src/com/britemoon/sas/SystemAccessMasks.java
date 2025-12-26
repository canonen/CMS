package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;

public class SystemAccessMasks extends BriteList
{
	// === Constructors ===

	public SystemAccessMasks()
	{
	}

	public SystemAccessMasks(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_system_user_id = null;
	public String s_type_id = null;
	public String s_mask = null;

	private void resetParams()
	{
		s_system_user_id = null;
		s_type_id = null;
		s_mask = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	system_user_id," +
			"	type_id," +
			"	mask" ;

		m_sFromClause = " FROM sadm_system_access_mask ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  system_user_id, type_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_system_user_id != null) { sWhereSql += " (system_user_id IN (?)) "; bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
		if(s_mask != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (mask IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_system_user_id != null) { pstmt.setString(i, s_system_user_id); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_mask != null) { pstmt.setString(i, s_mask); i++; }
	}

	public void fixIds()
	{
		SystemAccessMask systemaccessmask = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			systemaccessmask = (SystemAccessMask)e.nextElement();
			if(s_type_id != null) systemaccessmask.s_type_id = s_type_id;
			if(s_system_user_id != null) systemaccessmask.s_system_user_id = s_system_user_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		SystemAccessMask systemaccessmask = null;
		while (rs.next())
		{
			systemaccessmask = new SystemAccessMask();
			systemaccessmask.getPropsFromResultSetRow(rs);
			add(systemaccessmask);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "system_access_masks";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "system_access_mask";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		SystemAccessMask systemaccessmask = null;
		for(int i = 0; i < iLength; i++)
		{
			systemaccessmask = new SystemAccessMask ((Element)nl.item(i));
			v.add(systemaccessmask);
		}
		return iLength;
	}

	// === Other Methods ===
}


