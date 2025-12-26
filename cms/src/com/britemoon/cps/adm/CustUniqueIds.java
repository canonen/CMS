package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustUniqueIds extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(CustUniqueIds.class.getName());
	public CustUniqueIds()
	{
	}

	public CustUniqueIds(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_type_id = null;
	public String s_min_id = null;
	public String s_max_id = null;
	public String s_next_id = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_type_id = null;
		s_min_id = null;
		s_max_id = null;
		s_next_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	type_id," +
			"	min_id," +
			"	max_id," +
			"	next_id" ;

		m_sFromClause = " FROM ccps_cust_unique_id ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  type_id, cust_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
		if(s_min_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (min_id IN (?)) "); bAddAnd = true; }
		if(s_max_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (max_id IN (?)) "); bAddAnd = true; }
		if(s_next_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (next_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_min_id != null) { pstmt.setString(i, s_min_id); i++; }
		if(s_max_id != null) { pstmt.setString(i, s_max_id); i++; }
		if(s_next_id != null) { pstmt.setString(i, s_next_id); i++; }
	}

	public void fixIds()
	{
		CustUniqueId custuniqueid = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			custuniqueid = (CustUniqueId)e.nextElement();
			if(s_cust_id != null) custuniqueid.s_cust_id = s_cust_id;
			if(s_type_id != null) custuniqueid.s_type_id = s_type_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CustUniqueId custuniqueid = null;
		while (rs.next())
		{
			custuniqueid = new CustUniqueId();
			custuniqueid.getPropsFromResultSetRow(rs);
			add(custuniqueid);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "cust_unique_ids";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cust_unique_id";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CustUniqueId custuniqueid = null;
		for(int i = 0; i < iLength; i++)
		{
			custuniqueid = new CustUniqueId ((Element)nl.item(i));
			v.add(custuniqueid);
		}
		return iLength;
	}

	// === Other Methods ===
}


