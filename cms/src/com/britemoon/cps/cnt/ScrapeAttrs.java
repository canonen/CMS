package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeAttrs extends BriteList
{
	private static Logger logger = Logger.getLogger(ScrapeAttrs.class.getName());
	// === Constructors ===

	public ScrapeAttrs()
	{
	}

	public ScrapeAttrs(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===
// s_url_id
// s_entry_id
// s_attr_name
// s_attr_value

	public String s_url_id = null;
	public String s_entry_id = null;
	public String s_attr_name = null;
	public String s_attr_value = null;

	private void resetParams()
	{
		s_url_id = null;
		s_entry_id = null;
		s_attr_name = null;
		s_attr_value = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	url_id," +
			"	entry_id," +
			"	attr_name," +
			"	attr_value";

		m_sFromClause = " FROM ccnt_scrape_attr ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  url_id, entry_id, attr_name";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_url_id != null) { sWhereSql += " (url_id IN (?)) "; bAddAnd = true; }
		if(s_entry_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (entry_id IN (?)) "); bAddAnd = true; }
		if(s_attr_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_name IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_url_id != null) { pstmt.setString(i, s_url_id); i++; }
		if(s_entry_id != null) { pstmt.setString(i, s_entry_id); i++; }
		if(s_attr_name != null) { pstmt.setBytes(i, s_attr_name.getBytes("UTF-8")); i++; };
	}

	public void fixIds()
	{
		ScrapeAttr attr = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			attr = (ScrapeAttr)e.nextElement();
			if(s_url_id != null) attr.s_url_id = s_url_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ScrapeAttr attr = null;
		while (rs.next())
		{
			attr = new ScrapeAttr();
			attr.getPropsFromResultSetRow(rs);
			add(attr);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_attrs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "scrape_attr";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ScrapeAttr attr = null;
		for(int i = 0; i < iLength; i++)
		{
			attr = new ScrapeAttr ((Element)nl.item(i));
			v.add(attr);
		}
		return iLength;
	}

	// === Other Methods ===
}
