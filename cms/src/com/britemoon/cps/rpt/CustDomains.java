package com.britemoon.cps.rpt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustDomains extends BriteList
{
	// === Constructors ===
	private static Logger logger  = Logger.getLogger(CustDomains.class.getName());
	public CustDomains()	
	{
	}

	public CustDomains(Element e) throws Exception
	{
		fromXml(e);
	}

	public CustDomains(String sCustId) throws Exception
	{
		s_cust_id = sCustId;
		retrieve();
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_domain_id = null;
	public String s_cust_id = null;
	public String s_domain = null;

	public String getOwnerId() { return s_cust_id; }

	private void resetParams()
	{
		s_domain_id = null;
		s_cust_id = null;
		s_domain = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	domain_id," +
			"	cust_id," +
			"	domain";

		m_sFromClause = " FROM crpt_cust_domain ";
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

		return sWhereSql;
	}

	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_domain_id != null) { pstmt.setString(i, s_domain_id); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_domain != null) { pstmt.setBytes(i, s_domain.getBytes("UTF-8")); i++; }
	}

/*	public void fixIds()
	{
		CustDomain CustDomain = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			CustDomain = (CustDomain)e.nextElement();
			if(s_export_id != null) CustDomain.s_export_id = s_export_id;
		}
	}
*/
	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CustDomain CustDomain = null;
		while (rs.next())
		{
			CustDomain = new CustDomain();
			CustDomain.getPropsFromResultSetRow(rs);
			add(CustDomain);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "cust_domains";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cust_domain";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CustDomain CustDomain = null;
		for(int i = 0; i < iLength; i++)
		{
			CustDomain = new CustDomain ((Element)nl.item(i));
			v.add(CustDomain);
		}

		return iLength;
	}

	public int getPartsFromXml(Element e) throws Exception
	{
		int nReturnCode = 0;

		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");

		NodeList nl = XmlUtil.getChildrenByName(e, getSubElementName());
		int iLength = nl.getLength();
		if (iLength > 0)
		{
			v = new Vector(iLength);
			nReturnCode = getPartsFromXml(nl);
		}
		else { v = new Vector();}
		
		return nReturnCode;
	}

	public int appendPartsToXml(Element e)
	{
		int nReturnCode = 0;

		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);

		if( v == null ) return nReturnCode;

		CustDomain cd = null;
		for (Enumeration en = this.elements() ; en.hasMoreElements() ;)
		{
			cd = (CustDomain) en.nextElement();
			appendChild(e, cd);
			nReturnCode ++;
		}
		
		 return nReturnCode;
	}

/*	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
	}

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
	}
*/
	// === Other Methods ===
}
