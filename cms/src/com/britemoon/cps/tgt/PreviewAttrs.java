package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class PreviewAttrs extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(PreviewAttrs.class.getName());
	public PreviewAttrs()
	{
	}

	public PreviewAttrs(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_filter_id = null;
	public String s_attr_id = null;
	public String s_display_seq = null;

	private void resetParams()
	{
		s_filter_id = null;
		s_attr_id = null;
		s_display_seq = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	filter_id," +
			"	attr_id," +
			"	display_seq" ;

		m_sFromClause = " FROM ctgt_preview_attr ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  display_seq, attr_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_filter_id != null) { sWhereSql += " (filter_id IN (?)) "; bAddAnd = true; }
		if(s_attr_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (attr_id IN (?)) "); bAddAnd = true; }
		if(s_display_seq != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (display_seq IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_filter_id != null) { pstmt.setString(i, s_filter_id); i++; }
		if(s_attr_id != null) { pstmt.setString(i, s_attr_id); i++; }
		if(s_display_seq != null) { pstmt.setString(i, s_display_seq); i++; }
	}

	public void fixIds()
	{
		PreviewAttr previewattr = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			previewattr = (PreviewAttr)e.nextElement();
			if(s_attr_id != null) previewattr.s_attr_id = s_attr_id;
			if(s_filter_id != null) previewattr.s_filter_id = s_filter_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		PreviewAttr previewattr = null;
		while (rs.next())
		{
			previewattr = new PreviewAttr();
			previewattr.getPropsFromResultSetRow(rs);
			add(previewattr);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "preview_attrs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "preview_attr";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		PreviewAttr previewattr = null;
		for(int i = 0; i < iLength; i++)
		{
			previewattr = new PreviewAttr ((Element)nl.item(i));
			v.add(previewattr);
		}
		return iLength;
	}

	// === Other Methods ===
}


