package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class VanityDomains extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(VanityDomains.class.getName());
	// === Constructors ===
	public VanityDomains()
	{
	}

	public VanityDomains(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_domain_id = null;
	public String s_cust_id = null;
	public String s_domain = null;
	public String s_mod_inst_id = null;

	private void resetParams()
	{
		s_domain_id = null;
		s_cust_id = null;
		s_domain = null;
		s_mod_inst_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	domain_id," +
			"	cust_id," +
			"	domain," +
			"	mod_inst_id" ;

		m_sFromClause = " FROM sadm_vanity_domain ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  domain_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_domain_id != null) { sWhereSql += " (domain_id IN (?)) "; bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_domain != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (domain IN (?)) "); bAddAnd = true; }
		if(s_mod_inst_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (mod_inst_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_domain_id != null) { pstmt.setString(i, s_domain_id); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_domain != null) { pstmt.setBytes(i, s_domain.getBytes("UTF-8")); i++; }
		if(s_mod_inst_id != null) { pstmt.setString(i, s_mod_inst_id); i++; }
	}

	public void fixIds()
	{
		VanityDomain vanitydomain = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			vanitydomain = (VanityDomain)e.nextElement();
			if(s_cust_id != null) vanitydomain.s_cust_id = s_cust_id;
			if(s_mod_inst_id != null) vanitydomain.s_mod_inst_id = s_mod_inst_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		VanityDomain vanitydomain = null;
		while (rs.next())
		{
			vanitydomain = new VanityDomain();
			vanitydomain.getPropsFromResultSetRow(rs);
			add(vanitydomain);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "vanity_domains";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "vanity_domain";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		VanityDomain vanitydomain = null;
		for(int i = 0; i < iLength; i++)
		{
			vanitydomain = new VanityDomain ((Element)nl.item(i));
			v.add(vanitydomain);
		}
		return iLength;
	}

	// === Other Methods ===
}


