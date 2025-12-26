package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FieldsMappings extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(FieldsMappings.class.getName());
	public FieldsMappings()
	{
	}

	public FieldsMappings(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_import_id = null;
	public String s_attr_id = null;
	public String s_seq = null;

	private void resetParams()
	{
		s_import_id = null;
		s_attr_id = null;
		s_seq = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	import_id," +
			"	attr_id," +
			"	seq" ;

		m_sFromClause = " FROM cupd_fields_mapping ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY import_id, seq, attr_id";
	}

	public String buildWhereClause()
	{
		String sWhereSql = "";
		boolean bAddAnd = false;

		if(s_import_id != null) { sWhereSql += " (import_id IN (?)) "; bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }
		if(s_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (seq IN (?)) "); bAddAnd = true; }

		if (!"".equals(sWhereSql)) sWhereSql = " WHERE " + sWhereSql;

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_import_id != null) { pstmt.setString(i, s_import_id); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_seq != null) { pstmt.setString(i, s_seq); i++; }
	}

	public void fixIds()
	{
		FieldsMapping fieldsmapping = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			fieldsmapping = (FieldsMapping)e.nextElement();
			if(s_import_id != null) fieldsmapping.s_import_id = s_import_id;
			if(s_attr_id != null) fieldsmapping.s_attr_id = s_attr_id;
			if(s_seq != null) fieldsmapping.s_seq = s_seq;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		FieldsMapping fieldsmapping = null;
		while (rs.next())
		{
			fieldsmapping = new FieldsMapping();
			fieldsmapping.getPropsFromResultSetRow(rs);
			add(fieldsmapping);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "fields_mappings";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "fields_mapping";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		FieldsMapping fieldsmapping = null;
		for(int i = 0; i < iLength; i++)
		{
			fieldsmapping = new FieldsMapping ((Element)nl.item(i));
			v.add(fieldsmapping);
		}
		return iLength;
	}

	// === Other Methods ===
}


