package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImportTemplateAttrs extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(ImportTemplateAttrs.class.getName());
	public ImportTemplateAttrs()
	{
	}

	public ImportTemplateAttrs(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_template_id = null;
	public String s_attr_id = null;
	public String s_seq = null;

	private void resetParams()
	{
		s_template_id = null;
		s_attr_id = null;
		s_seq = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	template_id," +
			"	attr_id," +
			"	seq" ;

		m_sFromClause = " FROM cupd_import_template_attr ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  template_id, attr_id, seq ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_template_id != null) { sWhereSql += " (template_id IN (?)) "; bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }
		if(s_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (seq IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_template_id != null) { pstmt.setString(i, s_template_id); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_seq != null) { pstmt.setString(i, s_seq); i++; }
	}

	public void fixIds()
	{
		ImportTemplateAttr ita = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			ita = (ImportTemplateAttr)e.nextElement();
			if(s_template_id != null) ita.s_template_id = s_template_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ImportTemplateAttr ita = null;
		while (rs.next())
		{
			ita = new ImportTemplateAttr();
			ita.getPropsFromResultSetRow(rs);
			add(ita);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "import_template_attrs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "import_template_attr";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ImportTemplateAttr ita = null;
		for(int i = 0; i < iLength; i++)
		{
			ita = new ImportTemplateAttr ((Element)nl.item(i));
			v.add(ita);
		}
		return iLength;
	}

	// === Other Methods ===
}


