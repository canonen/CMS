package com.britemoon.cps.exp;

import com.britemoon.*;
import com.britemoon.cps.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ExportParams extends BriteList
{
	public String s_param_id = null;
	public String s_file_id = null;
	public String s_param_name = null;
	public String s_param_value = null;
	public String s_cust_id = null;

	
	private static Logger logger = Logger.getLogger(ExportParams.class.getName());
	
	//=== Constructors ===
	public ExportParams()
	{
	}
	
	public ExportParams(Element e) throws Exception
	{
		fromXml(e);
	}
	
	public String getOwnerId() { return s_cust_id; }
	
	private void resetParams()
	{
		s_param_id = null;
		s_file_id = null;
		s_param_name = null;
		s_param_value = null;
	}
//	 init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	param_id," +
			"	file_id," +
			"	param_name," +
			"	param_value" ;

		m_sFromClause = " FROM cexp_export_param ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY param_id, file_id";
	}
	
	public String buildWhereClause()
	{
		String sWhereSql = "";
		boolean bAddAnd = false;

		if(s_param_id != null) { sWhereSql += " (param_id IN (?)) "; bAddAnd = true; }
		if(s_file_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (file_id IN (?)) "); bAddAnd = true; }
		if(s_param_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (param_name IN (?)) "); bAddAnd = true; }
		if(s_param_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (param_value IN (?)) "); bAddAnd = true; }

		if (!"".equals(sWhereSql)) sWhereSql = " WHERE " + sWhereSql;

		return sWhereSql;
	}

	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_param_id != null) { pstmt.setString(i, s_param_id); i++; }
		if(s_file_id != null) { pstmt.setString(i, s_file_id); i++; }
		if(s_param_name != null) { pstmt.setString(i, s_param_name); i++; }
		if(s_param_value != null) { pstmt.setString(i, s_param_value); i++; }
	}
	
	public void fixIds()
	{
		ExportParam exportparam = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			exportparam = (ExportParam)e.nextElement();
			if(s_param_id != null) exportparam.s_param_id = s_param_id;
			if(s_file_id != null) exportparam.s_file_id = s_file_id;
			if(s_param_name != null) exportparam.s_param_name= s_param_name;
			if(s_param_value != null) exportparam.s_param_value = s_param_value;
		}
	}
	
	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		ExportParam exportparam = null;
		while (rs.next())
		{
			exportparam = new ExportParam();
			exportparam.getPropsFromResultSetRow(rs);
			add(exportparam);
			nReturnCode++;
		}
		return nReturnCode;
	}
	
//	 === XML Methods ===

	public String m_sMainElementName = "export_params";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "export_param";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		ExportParam exportparam = null;
		for(int i = 0; i < iLength; i++)
		{
			exportparam = new ExportParam((Element)nl.item(i));
			v.add(exportparam);
		}
		return iLength;
	}
	
}
