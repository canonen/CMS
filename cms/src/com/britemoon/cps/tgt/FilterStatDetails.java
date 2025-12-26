package com.britemoon.cps.tgt;

import com.britemoon.cps.*;

import java.sql.*;
import java.util.*;

import org.apache.log4j.Logger;
import org.w3c.dom.*;

public class FilterStatDetails extends BriteList
{
	private static Logger logger = Logger.getLogger(FilterStatDetails.class.getName());
	// === Constructors ===

	public FilterStatDetails()
	{
	}

	public FilterStatDetails(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteList will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_filter_id = null;
	public String s_detail_id = null;
	public String s_detail_name = null;
	public String s_integer_value = null;
	public String s_date_value = null;

	private void resetParams()
	{
		s_filter_id = null;
		s_detail_id = null;
		s_detail_name = null;
		s_integer_value = null;
		s_date_value = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	filter_id," +
			"	detail_id," +
			"	detail_name," +
			"	integer_value," +
			"	date_value" ;

		m_sFromClause = " FROM ctgt_filter_stat_detail ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  filter_id, detail_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_filter_id != null) { sWhereSql += " (filter_id IN (?)) "; bAddAnd = true; }
		if(s_detail_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (detail_id IN (?)) "); bAddAnd = true; }
		if(s_detail_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (detail_name IN (?)) "); bAddAnd = true; }
		if(s_integer_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (integer_value IN (?)) "); bAddAnd = true; }
		if(s_date_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (date_value IN (?)) "); bAddAnd = true; }
		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_filter_id != null) { pstmt.setString(i, s_filter_id); i++; }
		if(s_detail_id != null) { pstmt.setString(i, s_detail_id); i++; }
		if(s_detail_name != null) { pstmt.setBytes(i, s_detail_name.getBytes("UTF-8")); i++; }
		if(s_integer_value != null) { pstmt.setString(i, s_integer_value); i++; }
		if(s_date_value != null) { pstmt.setString(i, s_date_value); i++; }
	}

	public void fixIds()
	{
		FilterStatDetail filterstatdetail = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			filterstatdetail = (FilterStatDetail)e.nextElement();
			if(s_filter_id != null) filterstatdetail.s_filter_id = s_filter_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		FilterStatDetail filterstatdetail = null;
		while (rs.next())
		{
			filterstatdetail = new FilterStatDetail();
			filterstatdetail.getPropsFromResultSetRow(rs);
			add(filterstatdetail);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "filter_stat_details";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "filter_stat_detail";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		FilterStatDetail filterstatdetail = null;
		for(int i = 0; i < iLength; i++)
		{
			filterstatdetail = new FilterStatDetail ((Element)nl.item(i));
			v.add(filterstatdetail);
		}
		return iLength;
	}

	// === Other Methods ===
}
