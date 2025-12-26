package com.britemoon.cps.ntt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EntityImportLinkAttrs extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(EntityImportLinkAttrs.class.getName());

	public EntityImportLinkAttrs()
	{
	}

	public EntityImportLinkAttrs(Element e) throws Exception
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
	public String s_attr_id = null;
	public String s_param_name = null;

	private void resetParams()
	{
		s_link_id = null;
		s_attr_id = null;
		s_param_name = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	link_id," +
			"	attr_id," +
			"	param_name" ;

		m_sFromClause = " FROM cntt_entity_import_link_attr ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  link_id, attr_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_link_id != null) { sWhereSql += " (link_id IN (?)) "; bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }
		if(s_param_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (param_name IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_link_id != null) { pstmt.setString(i, s_link_id); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_param_name != null) { pstmt.setBytes(i, s_param_name.getBytes("UTF-8")); i++; }
	}

	public void fixIds()
	{
		EntityImportLinkAttr entityimportlinkattr = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			entityimportlinkattr = (EntityImportLinkAttr)e.nextElement();
			if(s_link_id != null) entityimportlinkattr.s_link_id = s_link_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		EntityImportLinkAttr entityimportlinkattr = null;
		while (rs.next())
		{
			entityimportlinkattr = new EntityImportLinkAttr();
			entityimportlinkattr.getPropsFromResultSetRow(rs);
			add(entityimportlinkattr);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "entity_import_link_attrs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "entity_import_link_attr";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		EntityImportLinkAttr entityimportlinkattr = null;
		for(int i = 0; i < iLength; i++)
		{
			entityimportlinkattr = new EntityImportLinkAttr ((Element)nl.item(i));
			v.add(entityimportlinkattr);
		}
		return iLength;
	}

	// === Other Methods ===
}


