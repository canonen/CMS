package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class Entities extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(Entities.class.getName());
	// === Constructors ===

	public Entities()
	{
	}

	public Entities(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteList will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_entity_id = null;
	public String s_cust_id = null;
	public String s_entity_name = null;
	public String s_scope_id = null;

	private void resetParams()
	{
		s_entity_id = null;
		s_cust_id = null;
		s_entity_name = null;
		s_scope_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	entity_id," +
			"	cust_id," +
			"	entity_name," +
			"	scope_id" ;

		m_sFromClause = " FROM sntt_entity ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY entity_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_entity_id != null) { sWhereSql += " (entity_id IN (?)) "; bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_entity_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (entity_name IN (?)) "); bAddAnd = true; }
		if(s_scope_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (scope_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_entity_id != null) { pstmt.setString(i, s_entity_id); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_entity_name != null) { pstmt.setBytes(i, s_entity_name.getBytes("UTF-8")); i++; }
		if(s_scope_id != null) { pstmt.setString(i, s_scope_id); i++; }
	}

	public void fixIds()
	{
		Entity entity = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			entity = (Entity)e.nextElement();
			if(s_cust_id != null) entity.s_cust_id = s_cust_id;
			if(s_scope_id != null) entity.s_scope_id = s_scope_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		Entity entity = null;
		while (rs.next())
		{
			entity = new Entity();
			entity.getPropsFromResultSetRow(rs);
			add(entity);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "entities";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "entity";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		Entity entity = null;
		for(int i = 0; i < iLength; i++)
		{
			entity = new Entity ((Element)nl.item(i));
			v.add(entity);
		}
		return iLength;
	}

	// === Other Methods ===
}


