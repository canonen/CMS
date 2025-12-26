package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class CustFeatures extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustFeatures.class.getName());
	// === Constructors ===
	public CustFeatures()
	{
	}

	public CustFeatures(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_feature_id = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_feature_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	feature_id" ;

		m_sFromClause = " FROM sadm_cust_feature ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, feature_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = "";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_feature_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (feature_id IN (?)) "); bAddAnd = true; }

		if (!"".equals(sWhereSql)) sWhereSql = " WHERE " + sWhereSql;

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_feature_id != null) { pstmt.setString(i, s_feature_id); i++; }
	}

	public void fixIds()
	{
		CustFeature custfeature = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			custfeature = (CustFeature)e.nextElement();
			if(s_cust_id != null) custfeature.s_cust_id = s_cust_id;
			if(s_feature_id != null) custfeature.s_feature_id = s_feature_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CustFeature custfeature = null;
		while (rs.next())
		{
			custfeature = new CustFeature();
			custfeature.getPropsFromResultSetRow(rs);
			add(custfeature);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "cust_features";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cust_feature";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CustFeature custfeature = null;
		for(int i = 0; i < iLength; i++)
		{
			custfeature = new CustFeature ((Element)nl.item(i));
			v.add(custfeature);
		}
		return iLength;
	}

	// === Other Methods ===
        
}
