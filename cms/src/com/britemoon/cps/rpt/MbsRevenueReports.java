package com.britemoon.cps.rpt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class MbsRevenueReports extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(MbsRevenueReports.class.getName());
	public MbsRevenueReports()
	{
	}

	public MbsRevenueReports(Element e) throws Exception
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
	public String s_purchasers = null;
	public String s_delivered = null;
	public String s_purchases = null;
	public String s_total = null;

	private void resetParams()
	{
		s_camp_id = null;
		s_purchasers = null;
		s_delivered = null;
		s_purchases = null;
		s_total = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	camp_id," +
			"	purchasers," +
			"	delivered," +
			"	purchases," +
			"	total" ;

		m_sFromClause = " FROM crpt_mbs_revenue_report ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  camp_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_camp_id != null) { sWhereSql += " (camp_id IN (?)) "; bAddAnd = true; }
		if(s_purchasers != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (purchasers IN (?)) "); bAddAnd = true; }
		if(s_delivered != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (delivered IN (?)) "); bAddAnd = true; }
		if(s_purchases != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (purchases IN (?)) "); bAddAnd = true; }
		if(s_total != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (total IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_camp_id != null) { pstmt.setString(i, s_camp_id); i++; }
		if(s_purchasers != null) { pstmt.setString(i, s_purchasers); i++; }
		if(s_delivered != null) { pstmt.setString(i, s_delivered); i++; }
		if(s_purchases != null) { pstmt.setString(i, s_purchases); i++; }
		if(s_total != null) { pstmt.setString(i, s_total); i++; }
	}

	public void fixIds()
	{
		MbsRevenueReport mbsrevenuereport = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			mbsrevenuereport = (MbsRevenueReport)e.nextElement();
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		MbsRevenueReport mbsrevenuereport = null;
		while (rs.next())
		{
			mbsrevenuereport = new MbsRevenueReport();
			mbsrevenuereport.getPropsFromResultSetRow(rs);
			add(mbsrevenuereport);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "mbs_revenue_reports";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "mbs_revenue_report";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		MbsRevenueReport mbsrevenuereport = null;
		for(int i = 0; i < iLength; i++)
		{
			mbsrevenuereport = new MbsRevenueReport ((Element)nl.item(i));
			v.add(mbsrevenuereport);
		}
		return iLength;
	}

	// === Other Methods ===
}


