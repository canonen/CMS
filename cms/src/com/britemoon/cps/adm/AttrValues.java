package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class AttrValues extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(AttrValues.class.getName());
	public AttrValues()
	{
	}

	public AttrValues(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_attr_id = null;
	public String s_attr_value = null;
	public String s_value_qty = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_attr_id = null;
		s_attr_value = null;
		s_value_qty = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	attr_id," +
			"	attr_value," +
			"	value_qty" ;

		m_sFromClause = " FROM ccps_attr_value ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, attr_id, attr_value ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }
		if(s_attr_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_value IN (?)) "); bAddAnd = true; }
		if(s_value_qty != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (value_qty IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_attr_value != null) { pstmt.setBytes(i, s_attr_value.getBytes("UTF-8")); i++; }
		if(s_value_qty != null) { pstmt.setString(i, s_value_qty); i++; }
	}

	public void fixIds()
	{
		AttrValue attrvalue = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			attrvalue = (AttrValue)e.nextElement();
			if(s_cust_id != null) attrvalue.s_cust_id = s_cust_id;
			if(s_attr_id != null) attrvalue.s_attr_id = s_attr_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		AttrValue attrvalue = null;
		while (rs.next())
		{
			attrvalue = new AttrValue();
			attrvalue.getPropsFromResultSetRow(rs);
			add(attrvalue);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "attr_values";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "attr_value";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		AttrValue attrvalue = null;
		for(int i = 0; i < iLength; i++)
		{
			attrvalue = new AttrValue ((Element)nl.item(i));
			v.add(attrvalue);
		}
		return iLength;
	}

	// === Other Methods ===
}


