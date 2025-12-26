package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Filters extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(Filters.class.getName());

	public Filters()
	{
	}

	public Filters(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_filter_id = null;
	public String s_filter_name = null;
	public String s_type_id = null;
	public String s_cust_id = null;
	public String s_status_id = null;
	public String s_origin_filter_id = null;
	public String s_usage_type_id = null;

	private void resetParams()
	{
		s_filter_id = null;
		s_filter_name = null;
		s_type_id = null;
		s_cust_id = null;
		s_status_id = null;
		s_origin_filter_id = null;
		s_usage_type_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT TOP 10" +
			"	filter_id," +
			"	filter_name," +
			"	type_id," +
			"	cust_id," +
			"	status_id," +
			"	origin_filter_id," +
			"	usage_type_id" ;

		m_sFromClause = " FROM ctgt_filter ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  filter_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = "";
		boolean bAddAnd = false;

		if(s_filter_id != null) { sWhereSql += " (filter_id=?) "; bAddAnd = true; }
		if(s_filter_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (filter_name=?) "); bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id=?) "); bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id=?) "); bAddAnd = true; }
		if(s_status_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (status_id=?) "); bAddAnd = true; }
		if(s_origin_filter_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (origin_filter_id=?) "); bAddAnd = true; }
		if(s_usage_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (usage_type_id IN (?)) "); bAddAnd = true; }

		if (!"".equals(sWhereSql)) sWhereSql = " WHERE " + sWhereSql;

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_filter_id != null) { pstmt.setString(i, s_filter_id); i++; }
		if(s_filter_name != null) { pstmt.setBytes(i, s_filter_name.getBytes("UTF-8")); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_status_id != null) { pstmt.setString(i, s_status_id); i++; }
		if(s_origin_filter_id != null) { pstmt.setString(i, s_origin_filter_id); i++; }
		if(s_usage_type_id != null) { pstmt.setString(i, s_usage_type_id); i++; }
	}

	public void fixIds()
	{
		Filter filter = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			filter = (Filter)e.nextElement();
			if(s_cust_id != null) filter.s_cust_id = s_cust_id;
			if(s_origin_filter_id != null) filter.s_origin_filter_id = s_origin_filter_id;
			if(s_status_id != null) filter.s_status_id = s_status_id;
			if(s_type_id != null) filter.s_type_id = s_type_id;
			if(s_usage_type_id != null) filter.s_usage_type_id = s_usage_type_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		Filter filter = null;
		while (rs.next())
		{
			filter = new Filter();
			filter.getPropsFromResultSetRow(rs);
			add(filter);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "filters";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "filter";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		Filter filter = null;
		for(int i = 0; i < iLength; i++)
		{
			filter = new Filter ((Element)nl.item(i));
			v.add(filter);
		}
		return iLength;
	}

	// === Other Methods ===
}


