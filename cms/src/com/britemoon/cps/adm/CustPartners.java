package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustPartners extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(CustPartners.class.getName());
	public CustPartners()
	{
	}

	public CustPartners(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_partner_id = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_partner_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	partner_id" ;

		m_sFromClause = " FROM ccps_cust_partner ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, partner_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_partner_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (partner_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_partner_id != null) { pstmt.setString(i, s_partner_id); i++; }
	}

	public void fixIds()
	{
		CustPartner custpartner = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			custpartner = (CustPartner)e.nextElement();
			if(s_cust_id != null) custpartner.s_cust_id = s_cust_id;
			if(s_partner_id != null) custpartner.s_partner_id = s_partner_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CustPartner custpartner = null;
		while (rs.next())
		{
			custpartner = new CustPartner();
			custpartner.getPropsFromResultSetRow(rs);
			add(custpartner);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "cust_partners";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cust_partner";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CustPartner custpartner = null;
		for(int i = 0; i < iLength; i++)
		{
			custpartner = new CustPartner ((Element)nl.item(i));
			v.add(custpartner);
		}
		return iLength;
	}

	// === Other Methods ===
}


