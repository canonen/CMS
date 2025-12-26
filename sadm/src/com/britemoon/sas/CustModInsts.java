package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class CustModInsts extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustModInsts.class.getName());
	// === Constructors ===
	public CustModInsts()
	{
	}

	public CustModInsts(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_mod_inst_id = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_mod_inst_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	mod_inst_id" ;

		m_sFromClause = " FROM sadm_cust_mod_inst ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, mod_inst_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_mod_inst_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (mod_inst_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_mod_inst_id != null) { pstmt.setString(i, s_mod_inst_id); i++; }
	}

	public void fixIds()
	{
		CustModInst custmodinst = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			custmodinst = (CustModInst)e.nextElement();
			if(s_cust_id != null) custmodinst.s_cust_id = s_cust_id;
			if(s_mod_inst_id != null) custmodinst.s_mod_inst_id = s_mod_inst_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CustModInst custmodinst = null;
		while (rs.next())
		{
			custmodinst = new CustModInst();
			custmodinst.getPropsFromResultSetRow(rs);
			add(custmodinst);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "cust_mod_insts";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cust_mod_inst";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CustModInst custmodinst = null;
		for(int i = 0; i < iLength; i++)
		{
			custmodinst = new CustModInst ((Element)nl.item(i));
			v.add(custmodinst);
		}
		return iLength;
	}

	// === Other Methods ===
}


