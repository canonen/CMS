package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeUrlConts extends BriteList
{
	private static Logger logger = Logger.getLogger(ScrapeUrlConts.class.getName());
	// === Constructors ===

	public ScrapeUrlConts()
	{
	}

	public ScrapeUrlConts(String sFormatId) throws Exception
	{
		s_format_id = sFormatId;
		retrieve();
	}

	public ScrapeUrlConts(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===
// s_url_id
// s_format_id
// s_cont_id

	public String s_url_id = null;
	public String s_format_id = null;
	public String s_cont_id = null;

	private void resetParams()
	{
		s_url_id = null;
		s_format_id = null;
		s_cont_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	url_id," +
			"	format_id," +
			"	cont_id";

		m_sFromClause = " FROM ccnt_scrape_url_cont ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  format_id, url_id, cont_id";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_url_id != null) { sWhereSql += " (url_id IN (?)) "; bAddAnd = true; }
		if(s_format_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (format_id IN (?)) "); bAddAnd = true; }
		if(s_cont_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cont_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_url_id != null) { pstmt.setString(i, s_url_id); i++; }
		if(s_format_id != null) { pstmt.setString(i, s_format_id); i++; }
		if(s_cont_id != null) { pstmt.setString(i, s_cont_id); i++; };
	}

	public void fixIds()
	{
		ScrapeUrlCont suc = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			suc = (ScrapeUrlCont)e.nextElement();
			if(s_format_id != null) suc.s_format_id = s_format_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ScrapeUrlCont suc = null;
		while (rs.next())
		{
			suc = new ScrapeUrlCont();
			suc.getPropsFromResultSetRow(rs);
			add(suc);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_url_conts";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "scrape_url_cont";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ScrapeUrlCont suc = null;
		for(int i = 0; i < iLength; i++)
		{
			suc = new ScrapeUrlCont ((Element)nl.item(i));
			v.add(suc);
		}
		return iLength;
	}

	// === Other Methods ===
}
