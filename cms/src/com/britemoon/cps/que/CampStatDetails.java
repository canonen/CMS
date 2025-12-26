package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampStatDetails extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(CampStatDetails.class.getName());
	public CampStatDetails()
	{
	}

	public CampStatDetails(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteList will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_camp_id = null;
	public String s_detail_id = null;
	public String s_detail_name = null;
	public String s_integer_value = null;
	public String s_string_value = null;
	public String s_date_value = null;

	private void resetParams()
	{
		s_camp_id = null;
		s_detail_id = null;
		s_detail_name = null;
		s_integer_value = null;
		s_string_value = null;
		s_date_value = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	camp_id," +
			"	detail_id," +
			"	detail_name," +
			"	integer_value," +
			"	string_value," +
			"	date_value" ;

		m_sFromClause = " FROM cque_camp_stat_detail ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  camp_id, detail_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_camp_id != null) { sWhereSql += " (camp_id IN (?)) "; bAddAnd = true; }
		if(s_detail_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (detail_id IN (?)) "); bAddAnd = true; }
		if(s_detail_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (detail_name IN (?)) "); bAddAnd = true; }
		if(s_integer_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (integer_value IN (?)) "); bAddAnd = true; }
		if(s_string_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (string_value IN (?)) "); bAddAnd = true; }
		if(s_date_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (date_value IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_camp_id != null) { pstmt.setString(i, s_camp_id); i++; }
		if(s_detail_id != null) { pstmt.setString(i, s_detail_id); i++; }
		if(s_detail_name != null) { pstmt.setBytes(i, s_detail_name.getBytes("UTF-8")); i++; }
		if(s_integer_value != null) { pstmt.setString(i, s_integer_value); i++; }
		if(s_string_value != null) { pstmt.setBytes(i, s_string_value.getBytes("UTF-8")); i++; }
		if(s_date_value != null) { pstmt.setString(i, s_date_value); i++; }
	}

	public void fixIds()
	{
		CampStatDetail campstatdetail = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			campstatdetail = (CampStatDetail)e.nextElement();
			if(s_camp_id != null) campstatdetail.s_camp_id = s_camp_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CampStatDetail campstatdetail = null;
		while (rs.next())
		{
			campstatdetail = new CampStatDetail();
			campstatdetail.getPropsFromResultSetRow(rs);
			add(campstatdetail);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "camp_stat_details";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "camp_stat_detail";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CampStatDetail campstatdetail = null;
		for(int i = 0; i < iLength; i++)
		{
			campstatdetail = new CampStatDetail ((Element)nl.item(i));
			v.add(campstatdetail);
		}
		return iLength;
	}

	// === Other Methods ===
}
