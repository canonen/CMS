package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;

public class ObjectCategories extends BriteList
{
	// === Constructors ===

	public ObjectCategories()
	{
	}

	public ObjectCategories(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_type_id = null;
	public String s_category_id = null;
	public String s_object_id = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_type_id = null;
		s_category_id = null;
		s_object_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	type_id," +
			"	category_id," +
			"	object_id" ;

		m_sFromClause = " FROM ccps_object_category ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, category_id, type_id, object_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = "";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
		if(s_category_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (category_id IN (?)) "); bAddAnd = true; }
		if(s_object_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (object_id IN (?)) "); bAddAnd = true; }

		if (!"".equals(sWhereSql)) sWhereSql = " WHERE " + sWhereSql;

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_category_id != null) { pstmt.setString(i, s_category_id); i++; }
		if(s_object_id != null) { pstmt.setString(i, s_object_id); i++; }
	}

	public void fixIds()
	{
		ObjectCategory objectcategory = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			objectcategory = (ObjectCategory)e.nextElement();
			if(s_cust_id != null) objectcategory.s_cust_id = s_cust_id;
			if(s_category_id != null) objectcategory.s_category_id = s_category_id;
			if(s_type_id != null) objectcategory.s_type_id = s_type_id;
			if(s_object_id != null) objectcategory.s_object_id = s_object_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ObjectCategory objectcategory = null;
		while (rs.next())
		{
			objectcategory = new ObjectCategory();
			objectcategory.getPropsFromResultSetRow(rs);
			add(objectcategory);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "object_categories";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "object_category";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ObjectCategory objectcategory = null;
		for(int i = 0; i < iLength; i++)
		{
			objectcategory = new ObjectCategory ((Element)nl.item(i));
			v.add(objectcategory);
		}
		return iLength;
	}

	// === Other Methods ===
}


