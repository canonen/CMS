package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class ImgCustFileExtensions extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(ImgCustFileExtensions.class.getName());
	// === Constructors ===

	public ImgCustFileExtensions()
	{
	}

	public ImgCustFileExtensions(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_file_extension = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_file_extension = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	file_extension" ;

		m_sFromClause = " FROM scnt_img_cust_file_extension ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, file_extension ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_file_extension != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (file_extension IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_file_extension != null) { pstmt.setBytes(i, s_file_extension.getBytes("UTF-8")); i++; }
	}

	public void fixIds()
	{
		ImgCustFileExtension imgcustfileextension = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			imgcustfileextension = (ImgCustFileExtension)e.nextElement();
			if(s_cust_id != null) imgcustfileextension.s_cust_id = s_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ImgCustFileExtension imgcustfileextension = null;
		while (rs.next())
		{
			imgcustfileextension = new ImgCustFileExtension();
			imgcustfileextension.getPropsFromResultSetRow(rs);
			add(imgcustfileextension);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "img_cust_file_extensions";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "img_cust_file_extension";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ImgCustFileExtension imgcustfileextension = null;
		for(int i = 0; i < iLength; i++)
		{
			imgcustfileextension = new ImgCustFileExtension ((Element)nl.item(i));
			v.add(imgcustfileextension);
		}
		return iLength;
	}

	// === Other Methods ===
}


