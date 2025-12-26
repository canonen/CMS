package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Campaigns extends BriteList
{
	// === Retrieve, delete & save params ===

	public String s_camp_id = null;
	public String s_type_id = null;
	public String s_status_id = null;
	public String s_camp_name = null;
	public String s_cust_id = null;
	public String s_cont_id = null;
	public String s_filter_id = null;
	public String s_seed_list_id = null;
	public String s_origin_camp_id = null;
	public String s_sample_id = null;
	public String s_approval_flag = null;
	public String s_camp_code = null;
	private static Logger logger = Logger.getLogger(Campaigns.class.getName());

	// === Constructors ===

	public Campaigns(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB stuff ===

	private void resetParams()
	{
		s_camp_id = null;
		s_type_id = null;
		s_status_id = null;
		s_camp_name = null;
		s_cust_id = null;
		s_cont_id = null;
		s_filter_id = null;
		s_seed_list_id = null;
		s_origin_camp_id = null;
		s_sample_id = null;		
		s_approval_flag = null;
		s_camp_code = null;
	}

	// init default retrieve sql variables;
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;	

		m_sSelectClause = 
			" SELECT" +
			"	camp_id," +
			"	type_id," +
			"	status_id," +
			"	camp_name," +
			"	cust_id," +
			"	cont_id," +
			"	filter_id," +
			"	seed_list_id," +
			"	origin_camp_id," +
			"	sample_id," +
			"	approval_flag, " +
		    "  camp_code " ;
	
		m_sFromClause = " FROM cque_campaign ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY camp_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = "";
		boolean bAddAnd = false;
		
		if(s_camp_id != null) { sWhereSql += " (camp_id IN (?)) "; bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
		if(s_status_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (status_id IN (?)) "); bAddAnd = true; }
		if(s_camp_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (camp_name IN (?)) "); bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_cont_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cont_id IN (?)) "); bAddAnd = true; }
		if(s_filter_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (filter_id IN (?)) "); bAddAnd = true; }
		if(s_seed_list_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (seed_list_id IN (?)) "); bAddAnd = true; }
		if(s_origin_camp_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (origin_camp_id IN (?)) "); bAddAnd = true; }
		if(s_sample_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (sample_id IN (?)) "); bAddAnd = true; }		
		if(s_approval_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (approval_flag IN (?)) "); bAddAnd = true; }
		if(s_camp_code != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (camp_code IN (?)) "); bAddAnd = true; }		
		
		if (!"".equals(sWhereSql)) sWhereSql = " WHERE " + sWhereSql;

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_camp_id != null) { pstmt.setString(i, s_camp_id); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_status_id != null) { pstmt.setString(i, s_status_id); i++; }
		if(s_camp_name != null) { pstmt.setBytes(i, s_camp_name.getBytes("UTF-8")); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_cont_id != null) { pstmt.setString(i, s_cont_id); i++; }
		if(s_filter_id != null) { pstmt.setString(i, s_filter_id); i++; }
		if(s_seed_list_id != null) { pstmt.setString(i, s_seed_list_id); i++; }
		if(s_origin_camp_id != null) { pstmt.setString(i, s_origin_camp_id); i++; }
		if(s_sample_id != null) { pstmt.setString(i, s_sample_id); i++; }		
		if(s_approval_flag != null) { pstmt.setString(i, s_approval_flag); i++;} 
		if(s_camp_code != null) { pstmt.setString(i, s_camp_code); i++;}		
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		Campaign camp = null;
		while (rs.next())
		{
			camp = new Campaign();
			camp.getPropsFromResultSetRow(rs);
			add(camp);
			nReturnCode++;
		}
		return nReturnCode;
	}
	
	// === XML stuff ===

	public String m_sMainElementName = "campaigns";
	public String getMainElementName() { return m_sMainElementName; }
	
	public String m_sSubElementName = "campaign";	
	public String getSubElementName() { return m_sSubElementName; }
	
	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		Campaign camp = null;
		for(int i = 0; i < iLength; i++)
		{
			camp = new Campaign ((Element)nl.item(i));
			v.add(camp);
		}
		return iLength;
	}
}
