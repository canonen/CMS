package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FromAddresses extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(FromAddresses.class.getName());
	public FromAddresses()
	{
	}

	public FromAddresses(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_from_address_id = null;
	public String s_cust_id = null;
	public String s_domain = null;
	public String s_prefix = null;

	private void resetParams()
	{
		s_from_address_id = null;
		s_cust_id = null;
		s_domain = null;
		s_prefix = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	from_address_id," +
			"	cust_id," +
			"	domain," +
			"	prefix" ;

		m_sFromClause = " FROM ccps_from_address ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  from_address_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_from_address_id != null) { sWhereSql += " (from_address_id IN (?)) "; bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_domain != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (domain IN (?)) "); bAddAnd = true; }
		if(s_prefix != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (prefix IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_from_address_id != null) { pstmt.setString(i, s_from_address_id); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_domain != null) { pstmt.setBytes(i, s_domain.getBytes("UTF-8")); i++; }
		if(s_prefix != null) { pstmt.setBytes(i, s_prefix.getBytes("UTF-8")); i++; }
	}

	public void fixIds()
	{
		FromAddress fromaddress = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			fromaddress = (FromAddress)e.nextElement();
			if(s_cust_id != null) fromaddress.s_cust_id = s_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		FromAddress fromaddress = null;
		while (rs.next())
		{
			fromaddress = new FromAddress();
			fromaddress.getPropsFromResultSetRow(rs);
			add(fromaddress);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "from_addresses";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "from_address";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		FromAddress fromaddress = null;
		for(int i = 0; i < iLength; i++)
		{
			fromaddress = new FromAddress ((Element)nl.item(i));
			v.add(fromaddress);
		}
		return iLength;
	}

	// === Other Methods ===
}


