package com.britemoon.cps.jtk;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Links extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(Links.class.getName());
	public Links()
	{
	}

	public Links(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteList will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_link_id = null;
	public String s_link_name = null;
	public String s_cust_id = null;
	public String s_origin_link_id = null;
	public String s_cont_id = null;
	public String s_href = null;
	public String s_camp_id = null;
	public String s_entity_id = null;

	private void resetParams()
	{
		s_link_id = null;
		s_link_name = null;
		s_cust_id = null;
		s_origin_link_id = null;
		s_cont_id = null;
		s_href = null;
		s_camp_id = null;
		s_entity_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	link_id," +
			"	link_name," +
			"	cust_id," +
			"	origin_link_id," +
			"	cont_id," +
			"	href," +
			"	camp_id," +
			"	entity_id" ;

		m_sFromClause = " FROM cjtk_link ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  link_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_link_id != null) { sWhereSql += " (link_id IN (?)) "; bAddAnd = true; }
		if(s_link_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (link_name IN (?)) "); bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_origin_link_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (origin_link_id IN (?)) "); bAddAnd = true; }
		if(s_cont_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cont_id IN (?)) "); bAddAnd = true; }
		if(s_href != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (href IN (?)) "); bAddAnd = true; }
		if(s_camp_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (camp_id IN (?)) "); bAddAnd = true; }
		if(s_entity_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (entity_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_link_id != null) { pstmt.setString(i, s_link_id); i++; }
		if(s_link_name != null) { pstmt.setBytes(i, s_link_name.getBytes("UTF-8")); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_origin_link_id != null) { pstmt.setString(i, s_origin_link_id); i++; }
		if(s_cont_id != null) { pstmt.setString(i, s_cont_id); i++; }
		if(s_href != null) { pstmt.setBytes(i, s_href.getBytes("UTF-8")); i++; }
		if(s_camp_id != null) { pstmt.setString(i, s_camp_id); i++; }
		if(s_entity_id != null) { pstmt.setString(i, s_entity_id); i++; }
	}

	public void fixIds()
	{
		Link link = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			link = (Link)e.nextElement();
			if(s_cont_id != null) link.s_cont_id = s_cont_id;
			if(s_cust_id != null) link.s_cust_id = s_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		Link link = null;
		while (rs.next())
		{
			link = new Link();
			link.getPropsFromResultSetRow(rs);
			add(link);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "links";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "link";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		Link link = null;
		for(int i = 0; i < iLength; i++)
		{
			link = new Link ((Element)nl.item(i));
			v.add(link);
		}
		return iLength;
	}

	// === Other Methods ===
}
