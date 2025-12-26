package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FilterParts extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(FilterParts.class.getName());
	public FilterParts()
	{
	}

	public FilterParts(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_parent_filter_id = null;
	public String s_child_filter_id = null;
	public String s_display_seq = null;

	private void resetParams()
	{
		s_parent_filter_id = null;
		s_child_filter_id = null;
		s_display_seq = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	parent_filter_id," +
			"	child_filter_id," +
			"	display_seq" ;

		m_sFromClause = " FROM ctgt_filter_part ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  display_seq, parent_filter_id, child_filter_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_parent_filter_id != null) { sWhereSql += " (parent_filter_id = (?)) "; bAddAnd = true; }
		if(s_child_filter_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (child_filter_id = (?)) "); bAddAnd = true; }
		if(s_display_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (display_seq = (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_parent_filter_id != null) { pstmt.setString(i, s_parent_filter_id); i++; }
		if(s_child_filter_id != null) { pstmt.setString(i, s_child_filter_id); i++; }
		if(s_display_seq != null) { pstmt.setString(i, s_display_seq); i++; }
	}

	public void fixIds()
	{
		FilterPart filterpart = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			filterpart = (FilterPart)e.nextElement();
			if(s_parent_filter_id != null) filterpart.s_parent_filter_id = s_parent_filter_id;
			if(s_child_filter_id != null) filterpart.s_child_filter_id = s_child_filter_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		FilterPart filterpart = null;
		while (rs.next())
		{
			filterpart = new FilterPart();
			filterpart.getPropsFromResultSetRow(rs);
			add(filterpart);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "filter_parts";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "filter_part";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		FilterPart filterpart = null;
		for(int i = 0; i < iLength; i++)
		{
			filterpart = new FilterPart ((Element)nl.item(i));
			v.add(filterpart);
		}
		return iLength;
	}

	// === Other Methods ===
}


