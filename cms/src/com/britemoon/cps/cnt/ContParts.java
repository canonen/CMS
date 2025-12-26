package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ContParts extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(ContParts.class.getName());
	public ContParts()
	{
	}

	public ContParts(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_parent_cont_id = null;
	public String s_seq = null;
	public String s_child_cont_id = null;
	public String s_filter_id = null;
	public String s_default_flag = null;
        public String s_max_elements_in_logic_block = null;
        

	private void resetParams()
	{
		s_parent_cont_id = null;
		s_seq = null;
		s_child_cont_id = null;
		s_filter_id = null;
		s_default_flag = null;
                s_max_elements_in_logic_block = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	parent_cont_id," +
			"	seq," +
			"	child_cont_id," +
			"	filter_id," +
			"	default_flag," +
                        "       max_elements_in_logic_block";

		m_sFromClause = " FROM ccnt_cont_part ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  parent_cont_id, seq ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_parent_cont_id != null) { sWhereSql += " (parent_cont_id IN (?)) "; bAddAnd = true; }
		if(s_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (seq IN (?)) "); bAddAnd = true; }
		if(s_child_cont_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (child_cont_id IN (?)) "); bAddAnd = true; }
		if(s_filter_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (filter_id IN (?)) "); bAddAnd = true; }
		if(s_default_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (default_flag IN (?)) "); bAddAnd = true; }
                if(s_max_elements_in_logic_block != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (max_elements_in_logic_block IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_parent_cont_id != null) { pstmt.setString(i, s_parent_cont_id); i++; }
		if(s_seq != null) { pstmt.setString(i, s_seq); i++; }
		if(s_child_cont_id != null) { pstmt.setString(i, s_child_cont_id); i++; }
		if(s_filter_id != null) { pstmt.setString(i, s_filter_id); i++; }
		if(s_default_flag != null) { pstmt.setString(i, s_default_flag); i++; }
                if(s_max_elements_in_logic_block != null) { pstmt.setString(i, s_max_elements_in_logic_block); i++; }
	}

	public void fixIds()
	{
		ContPart contpart = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			contpart = (ContPart)e.nextElement();
			if(s_parent_cont_id != null) contpart.s_parent_cont_id = s_parent_cont_id;
			if(s_child_cont_id != null) contpart.s_child_cont_id = s_child_cont_id;
			if(s_filter_id != null) contpart.s_filter_id = s_filter_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ContPart contpart = null;
		while (rs.next())
		{
			contpart = new ContPart();
			contpart.getPropsFromResultSetRow(rs);
			add(contpart);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "cont_parts";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cont_part";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ContPart contpart = null;
		for(int i = 0; i < iLength; i++)
		{
			contpart = new ContPart ((Element)nl.item(i));
			v.add(contpart);
		}
		return iLength;
	}

	// === Other Methods ===
}
