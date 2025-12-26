package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeTags extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(ScrapeTags.class.getName());
	public ScrapeTags()
	{
	}

	public ScrapeTags(String sScrapeId) throws Exception
	{
		s_scrape_id = sScrapeId;
		retrieve();
	}

	public ScrapeTags(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===
// s_scrape_id
// s_tag_id
// s_tag_name
// s_level

	public String s_scrape_id = null;
	public String s_tag_id = null;
	public String s_tag_name = null;
	public String s_level = null;

	private void resetParams()
	{
		s_scrape_id = null;
		s_tag_id = null;
		s_tag_name = null;
		s_level = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	scrape_id," +
			"	tag_id," +
			"	tag_name," +
			"	level";

		m_sFromClause = " FROM ccnt_scrape_tag ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  scrape_id, tag_id, level, tag_name";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_scrape_id != null) { sWhereSql += " (scrape_id IN (?)) "; bAddAnd = true; }
		if(s_tag_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (tag_id IN (?)) "); bAddAnd = true; }
		if(s_tag_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (tag_name IN (?)) "); bAddAnd = true; }
		if(s_level != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (level IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_scrape_id != null) { pstmt.setString(i, s_scrape_id); i++; }
		if(s_tag_id != null) { pstmt.setString(i, s_tag_id); i++; }
		if(s_tag_name != null) { pstmt.setBytes(i, s_tag_name.getBytes("UTF-8")); i++; };
		if(s_level != null) { pstmt.setString(i, s_level); i++; };
	}

	public void fixIds()
	{
		ScrapeTag tag = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			tag = (ScrapeTag)e.nextElement();
			if(s_scrape_id != null) tag.s_scrape_id = s_scrape_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ScrapeTag tag = null;
		while (rs.next())
		{
			tag = new ScrapeTag();
			tag.getPropsFromResultSetRow(rs);
			add(tag);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_tags";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "scrape_tag";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ScrapeTag tag = null;
		for(int i = 0; i < iLength; i++)
		{
			tag = new ScrapeTag ((Element)nl.item(i));
			v.add(tag);
		}
		return iLength;
	}

	// === Other Methods ===
}
