package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class EntityAttrs extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(EntityAttrs.class.getName());
	// === Constructors ===
	public EntityAttrs()
	{
	}

	public EntityAttrs(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteList will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_attr_id = null;
	public String s_entity_id = null;
	public String s_type_id = null;
	public String s_attr_name = null;
	public String s_scope_id = null;
	public String s_internal_id_flag = null;
	public String s_fingerprint_seq = null;

	private void resetParams()
	{
		s_attr_id = null;
		s_entity_id = null;
		s_type_id = null;
		s_attr_name = null;
		s_scope_id = null;
		s_internal_id_flag = null;
		s_fingerprint_seq = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	attr_id," +
			"	entity_id," +
			"	type_id," +
			"	attr_name," +
			"	scope_id," +
			"	internal_id_flag," +
			"	fingerprint_seq" ;

		m_sFromClause = " FROM sntt_entity_attr ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY attr_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_attr_id != null) { sWhereSql += " (attr_id IN (?)) "; bAddAnd = true; }
		if(s_entity_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (entity_id IN (?)) "); bAddAnd = true; }
		if(s_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
		if(s_attr_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_name IN (?)) "); bAddAnd = true; }
		if(s_scope_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (scope_id IN (?)) "); bAddAnd = true; }
		if(s_internal_id_flag != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (internal_id_flag IN (?)) "); bAddAnd = true; }
		if(s_fingerprint_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (fingerprint_seq IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_entity_id != null) { pstmt.setString(i, s_entity_id); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_attr_name != null) { pstmt.setBytes(i, s_attr_name.getBytes("UTF-8")); i++; }
		if(s_scope_id != null) { pstmt.setString(i, s_scope_id); i++; }
		if(s_internal_id_flag != null) { pstmt.setString(i, s_internal_id_flag); i++; }
		if(s_fingerprint_seq != null) { pstmt.setString(i, s_fingerprint_seq); i++; }
	}

	public void fixIds()
	{
		EntityAttr entityattr = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			entityattr = (EntityAttr)e.nextElement();
			if(s_type_id != null) entityattr.s_type_id = s_type_id;
			if(s_entity_id != null) entityattr.s_entity_id = s_entity_id;
			if(s_scope_id != null) entityattr.s_scope_id = s_scope_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		EntityAttr entityattr = null;
		while (rs.next())
		{
			entityattr = new EntityAttr();
			entityattr.getPropsFromResultSetRow(rs);
			add(entityattr);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "entity_attrs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "entity_attr";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		EntityAttr entityattr = null;
		for(int i = 0; i < iLength; i++)
		{
			entityattr = new EntityAttr ((Element)nl.item(i));
			v.add(entityattr);
		}
		return iLength;
	}

	// === Other Methods ===
}


