package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeUrls extends BriteList
{
	private static Logger logger = Logger.getLogger(ScrapeUrls.class.getName());
	// === Constructors ===

	public ScrapeUrls()
	{
	}

	public ScrapeUrls(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_filter_id = null;
	public String s_scrape_id = null;
	public String s_title_text = null;
	public String s_title_html = null;
	public String s_url = null;
	public String s_seq = null;

	private void resetParams()
	{
		s_filter_id = null;
		s_scrape_id = null;
		s_title_text = null;
		s_title_html = null;
		s_url = null;
		s_seq = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	url_id," +
			"	filter_id," +
			"	scrape_id," +
			"	title_text," +
			"	title_html," +
			"	url," +
			"	seq" ;

		m_sFromClause = " FROM ccnt_scrape_url ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  scrape_id, seq ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_filter_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (filter_id IN (?)) "); bAddAnd = true; }
		if(s_scrape_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (scrape_id IN (?)) "); bAddAnd = true; }
		if(s_title_text != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (title_text IN (?)) "); bAddAnd = true; }
		if(s_title_html != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (title_html IN (?)) "); bAddAnd = true; }
		if(s_url != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (url IN (?)) "); bAddAnd = true; }
		if(s_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (seq IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_filter_id != null) { pstmt.setString(i, s_filter_id); i++; }
		if(s_scrape_id != null) { pstmt.setString(i, s_scrape_id); i++; }
		if(s_title_text != null) { pstmt.setBytes(i, s_title_text.getBytes("UTF-8")); i++; };
		if(s_title_html != null) { pstmt.setBytes(i, s_title_html.getBytes("UTF-8")); i++; };
		if(s_url != null) { pstmt.setBytes(i, s_url.getBytes("UTF-8")); i++; };
		if(s_seq != null) { pstmt.setString(i, s_seq); i++; };
	}

	public void fixIds()
	{
		ScrapeUrl url = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			url = (ScrapeUrl)e.nextElement();
			if(s_scrape_id != null) url.s_scrape_id = s_scrape_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ScrapeUrl url = null;
		while (rs.next())
		{
			url = new ScrapeUrl();
			url.getPropsFromResultSetRow(rs);
			add(url);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_urls";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "scrape_url";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ScrapeUrl url = null;
		for(int i = 0; i < iLength; i++)
		{
			url = new ScrapeUrl ((Element)nl.item(i));
			v.add(url);
		}
		return iLength;
	}

	// === Other Methods ===
}
