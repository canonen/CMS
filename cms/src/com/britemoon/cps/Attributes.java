package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;

import org.w3c.dom.*;


public class Attributes extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(Attributes.class.getName());
	public Attributes()
	{
	}

	public Attributes(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_attr_id = null;
	public String s_cust_id = null;
	public String s_attr_name = null;
	public String s_type_id = null;
	public String s_scope_id = null;
	public String s_descrip = null;
	public String s_value_qty = null;
	public String s_internal_flag = null;

	private void resetParams()
	{
		s_attr_id = null;
		s_cust_id = null;
		s_attr_name = null;
		s_type_id = null;
		s_scope_id = null;
		s_descrip = null;
		s_value_qty = null;
		s_internal_flag = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	attr_id," +
			"	cust_id," +
			"	attr_name," +
			"	type_id," +
			"	scope_id," +
			"	descrip," +
			"	value_qty," +
			"	internal_flag" ;

		m_sFromClause = " FROM ccps_attribute ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  attr_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_attr_id != null) { sWhereSql += " (attr_id IN (?)) "; bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_attr_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_name IN (?)) "); bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
		if(s_scope_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (scope_id IN (?)) "); bAddAnd = true; }
		if(s_descrip != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (descrip IN (?)) "); bAddAnd = true; }
		if(s_value_qty != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (value_qty IN (?)) "); bAddAnd = true; }
		if(s_internal_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (internal_flag IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_attr_name != null) { pstmt.setBytes(i, s_attr_name.getBytes("UTF-8")); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_scope_id != null) { pstmt.setString(i, s_scope_id); i++; }
		if(s_descrip != null) { pstmt.setBytes(i, s_descrip.getBytes("UTF-8")); i++; }
		if(s_value_qty != null) { pstmt.setString(i, s_value_qty); i++; }
		if(s_internal_flag != null) { pstmt.setString(i, s_internal_flag); i++; }
	}

	public void fixIds()
	{
		Attribute attribute = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			attribute = (Attribute)e.nextElement();
			if(s_scope_id != null) attribute.s_scope_id = s_scope_id;
			if(s_cust_id != null) attribute.s_cust_id = s_cust_id;
			if(s_type_id != null) attribute.s_type_id = s_type_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		Attribute attribute = null;
		while (rs.next())
		{
			attribute = new Attribute();
			attribute.getPropsFromResultSetRow(rs);
			add(attribute);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "attributes";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "attribute";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		Attribute attribute = null;
		for(int i = 0; i < iLength; i++)
		{
			attribute = new Attribute ((Element)nl.item(i));
			v.add(attribute);
		}
		return iLength;
	}

	// === Other Methods ===
}


