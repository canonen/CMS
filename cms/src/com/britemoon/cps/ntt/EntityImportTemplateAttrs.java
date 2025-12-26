package com.britemoon.cps.ntt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EntityImportTemplateAttrs extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(EntityImportTemplateAttrs.class.getName());
	public EntityImportTemplateAttrs()
	{
	}

	public EntityImportTemplateAttrs(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteList will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_template_id = null;
	public String s_seq = null;
	public String s_attr_id = null;

	private void resetParams()
	{
		s_template_id = null;
		s_seq = null;
		s_attr_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	template_id," +
			"	seq," +
			"	attr_id" ;

		m_sFromClause = " FROM cntt_entity_import_template_attr ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  template_id, seq ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_template_id != null) { sWhereSql += " (template_id IN (?)) "; bAddAnd = true; }
		if(s_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (seq IN (?)) "); bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_template_id != null) { pstmt.setString(i, s_template_id); i++; }
		if(s_seq != null) { pstmt.setString(i, s_seq); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
	}

	public void fixIds()
	{
		EntityImportTemplateAttr entityimporttemplateattr = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			entityimporttemplateattr = (EntityImportTemplateAttr)e.nextElement();
			if(s_template_id != null) entityimporttemplateattr.s_template_id = s_template_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		EntityImportTemplateAttr entityimporttemplateattr = null;
		while (rs.next())
		{
			entityimporttemplateattr = new EntityImportTemplateAttr();
			entityimporttemplateattr.getPropsFromResultSetRow(rs);
			add(entityimporttemplateattr);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "entity_import_template_attrs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "entity_import_template_attr";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		EntityImportTemplateAttr entityimporttemplateattr = null;
		for(int i = 0; i < iLength; i++)
		{
			entityimporttemplateattr = new EntityImportTemplateAttr ((Element)nl.item(i));
			v.add(entityimporttemplateattr);
		}
		return iLength;
	}

	// === Other Methods ===
}


