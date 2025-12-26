package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImportNewsletters extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(ImportNewsletters.class.getName());
	public ImportNewsletters()
	{
	}

	public ImportNewsletters(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_import_id = null;
	public String s_attr_id = null;

	private void resetParams()
	{
		s_import_id = null;
		s_attr_id = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	import_id," +
			"	attr_id" ;

		m_sFromClause = " FROM cupd_import_newsletter ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  import_id, attr_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_import_id != null) { sWhereSql += " (import_id IN (?)) "; bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_import_id != null) { pstmt.setString(i, s_import_id); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
	}

	public void fixIds()
	{
		ImportNewsletter importnewsletter = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			importnewsletter = (ImportNewsletter)e.nextElement();
			if(s_import_id != null) importnewsletter.s_import_id = s_import_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ImportNewsletter importnewsletter = null;
		while (rs.next())
		{
			importnewsletter = new ImportNewsletter();
			importnewsletter.getPropsFromResultSetRow(rs);
			add(importnewsletter);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "import_newsletters";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "import_newsletter";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ImportNewsletter importnewsletter = null;
		for(int i = 0; i < iLength; i++)
		{
			importnewsletter = new ImportNewsletter ((Element)nl.item(i));
			v.add(importnewsletter);
		}
		return iLength;
	}

	// === Other Methods ===
}


