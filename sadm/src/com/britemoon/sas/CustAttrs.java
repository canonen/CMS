package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustAttrs extends BriteList
{
	// === Constructors ===
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustAttrs.class.getName());
	public CustAttrs()
	{
	}

	public CustAttrs(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_attr_id = null;
	public String s_display_name = null;
	public String s_display_seq = null;
	public String s_fingerprint_seq = null;
	public String s_sync_flag = null;
	public String s_hist_flag = null;
	public String s_newsletter_flag = null;
	public String s_recip_view_seq = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_attr_id = null;
		s_display_name = null;
		s_display_seq = null;
		s_fingerprint_seq = null;
		s_sync_flag = null;
		s_hist_flag = null;
		s_newsletter_flag = null;
		s_recip_view_seq = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	attr_id," +
			"	display_name," +
			"	display_seq," +
			"	fingerprint_seq," +
			"	sync_flag," +
			"	hist_flag," +
			"	newsletter_flag," +
			"	recip_view_seq";

		m_sFromClause = " FROM sadm_cust_attr ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, attr_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }
		if(s_display_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (display_name IN (?)) "); bAddAnd = true; }
		if(s_display_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (display_seq IN (?)) "); bAddAnd = true; }
		if(s_fingerprint_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (fingerprint_seq IN (?)) "); bAddAnd = true; }
		if(s_sync_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (sync_flag IN (?)) "); bAddAnd = true; }
		if(s_hist_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (hist_flag IN (?)) "); bAddAnd = true; }
		if(s_newsletter_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (newsletter_flag IN (?)) "); bAddAnd = true; }				
		if(s_recip_view_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (recip_view_seq IN (?)) "); bAddAnd = true; }				

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_display_name != null) { pstmt.setBytes(i, s_display_name.getBytes("UTF-8")); i++; }
		if(s_display_seq != null) { pstmt.setString(i, s_display_seq); i++; }
		if(s_fingerprint_seq != null) { pstmt.setString(i, s_fingerprint_seq); i++; }
		if(s_sync_flag != null) { pstmt.setString(i, s_sync_flag); i++; }
		if(s_hist_flag != null) { pstmt.setString(i, s_hist_flag); i++; }
		if(s_newsletter_flag != null) { pstmt.setString(i, s_newsletter_flag); i++; }				
		if(s_recip_view_seq != null) { pstmt.setString(i, s_recip_view_seq); i++; }				
	}

	public void fixIds()
	{
		CustAttr custattr = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			custattr = (CustAttr)e.nextElement();
			if(s_attr_id != null) custattr.s_attr_id = s_attr_id;
			if(s_cust_id != null) custattr.s_cust_id = s_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CustAttr custattr = null;
		while (rs.next())
		{
			custattr = new CustAttr();
			custattr.getPropsFromResultSetRow(rs);
			add(custattr);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "cust_attrs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cust_attr";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CustAttr custattr = null;
		for(int i = 0; i < iLength; i++)
		{
			custattr = new CustAttr ((Element)nl.item(i));
			v.add(custattr);
		}
		return iLength;
	}

	// === Other Methods ===
}
