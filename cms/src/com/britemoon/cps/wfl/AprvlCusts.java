package com.britemoon.cps.wfl;

import com.britemoon.cps.*;
import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class AprvlCusts extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(AprvlCusts.class.getName());
	public AprvlCusts()
	{
	}

	public AprvlCusts(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_object_type = null;
	public String s_aprvl_workflow_flag = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_object_type = null;
		s_aprvl_workflow_flag = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	object_type," +
			"	aprvl_workflow_flag" ;

		m_sFromClause = " FROM ccps_aprvl_cust ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, object_type ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_object_type != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (object_type IN (?)) "); bAddAnd = true; }
		if(s_aprvl_workflow_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (aprvl_workflow_flag IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_object_type != null) { pstmt.setString(i, s_object_type); i++; }
		if(s_aprvl_workflow_flag != null) { pstmt.setString(i, s_aprvl_workflow_flag); i++; }
	}

	public void fixIds()
	{
		AprvlCust aprvlcust = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			aprvlcust = (AprvlCust)e.nextElement();
			if(s_cust_id != null) aprvlcust.s_cust_id = s_cust_id;
			if(s_object_type != null) aprvlcust.s_object_type = s_object_type;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		AprvlCust aprvlcust = null;
		while (rs.next())
		{
			aprvlcust = new AprvlCust();
			aprvlcust.getPropsFromResultSetRow(rs);
			add(aprvlcust);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "aprvl_custs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "aprvl_cust";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		AprvlCust aprvlcust = null;
		for(int i = 0; i < iLength; i++)
		{
			aprvlcust = new AprvlCust ((Element)nl.item(i));
			v.add(aprvlcust);
		}
		return iLength;
	}

	// === Other Methods ===
}


