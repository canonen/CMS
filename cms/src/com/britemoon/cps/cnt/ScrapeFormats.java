package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeFormats extends BriteList
{
	private static Logger logger = Logger.getLogger(ScrapeFormats.class.getName());
	// === Constructors ===

	public ScrapeFormats()
	{
	}

	public ScrapeFormats(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

// s_format_id
// s_scrape_id
// s_format_name
// s_cont_text
// s_cont_html
// s_charset_id
// s_cont_id
// s_create_date
// s_modified_date

	public String s_format_id = null;
	public String s_scrape_id = null;
	public String s_format_name = null;
	public String s_cont_text = null;
	public String s_cont_html = null;
	public String s_charset_id = null;
	public String s_cont_id = null;
	public String s_create_date = null;
	public String s_modified_date = null;

	private void resetParams()
	{
		s_format_id = null;
		s_scrape_id = null;
		s_format_name = null;
		s_cont_text = null;
		s_cont_html = null;
		s_charset_id = null;
		s_cont_id = null;
		s_create_date = null;
		s_modified_date = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	format_id," +
			"	scrape_id," +
			"	format_name," +
			"	cont_text," +
			"	cont_html," +
			"	charset_id," +
			"	cont_id," +
			"	create_date," +
			"	modified_date";

		m_sFromClause = " FROM ccnt_scrape_cont_format ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  scrape_id, format_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_format_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (format_id IN (?)) "); bAddAnd = true; }
		if(s_scrape_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (scrape_id IN (?)) "); bAddAnd = true; }
		if(s_format_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (format_name IN (?)) "); bAddAnd = true; }
		if(s_charset_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (charset_id IN (?)) "); bAddAnd = true; }
		if(s_cont_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cont_id IN (?)) "); bAddAnd = true; }
		if(s_create_date != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (create_date IN (?)) "); bAddAnd = true; }
		if(s_modified_date != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (modified_date IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_format_id != null) { pstmt.setString(i, s_format_id); i++; }
		if(s_scrape_id != null) { pstmt.setString(i, s_scrape_id); i++; }
		if(s_format_name != null) { pstmt.setBytes(i, s_format_name.getBytes("UTF-8")); i++; };
		if(s_charset_id != null) { pstmt.setBytes(i, s_charset_id.getBytes("UTF-8")); i++; };
		if(s_cont_id != null) { pstmt.setBytes(i, s_cont_id.getBytes("UTF-8")); i++; };
		if(s_create_date != null) { pstmt.setBytes(i, s_create_date.getBytes("UTF-8")); i++; };
		if(s_modified_date != null) { pstmt.setBytes(i, s_modified_date.getBytes("UTF-8")); i++; };
	}

	public void fixIds()
	{
		ScrapeFormat format = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			format = (ScrapeFormat)e.nextElement();
			if(s_scrape_id != null) format.s_scrape_id = s_scrape_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ScrapeFormat format = null;
		while (rs.next())
		{
			format = new ScrapeFormat();
			format.getPropsFromResultSetRow(rs);
			add(format);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_formats";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "scrape_format";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ScrapeFormat format = null;
		for(int i = 0; i < iLength; i++)
		{
			format = new ScrapeFormat ((Element)nl.item(i));
			v.add(format);
		}
		return iLength;
	}

	// === Other Methods ===
}
