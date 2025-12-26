package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FilterParams extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(FilterParams.class.getName()); 
	public FilterParams()
	{
	}

	public FilterParams(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_filter_id = null;
	public String s_param_id = null;
	public String s_param_name = null;
	public String s_integer_value = null;
	public String s_date_value = null;
	public String s_string_value = null;
	public String s_money_value = null;	
	
	private void resetParams()
	{
		s_filter_id = null;
		s_param_id = null;
		s_param_name = null;
		s_integer_value = null;
		s_date_value = null;
		s_string_value = null;
		s_money_value = null;		
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	filter_id," +
			"	param_id," +
			"	param_name," +
			"	integer_value," +
			"	date_value," +
			"	string_value," +
			"	money_value";

		m_sFromClause = " FROM ctgt_filter_param ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  filter_id, param_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_filter_id != null) { sWhereSql += " (filter_id IN (?)) "; bAddAnd = true; }
		if(s_param_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (param_id IN (?)) "); bAddAnd = true; }
		if(s_param_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (param_name IN (?)) "); bAddAnd = true; }
		if(s_integer_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (integer_value IN (?)) "); bAddAnd = true; }
		if(s_date_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (date_value IN (?)) "); bAddAnd = true; }
		if(s_string_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (string_value IN (?)) "); bAddAnd = true; }
		if(s_money_value != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (money_value IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_filter_id != null) { pstmt.setString(i, s_filter_id); i++; }
		if(s_param_id != null) { pstmt.setString(i, s_param_id); i++; }
		if(s_param_name != null) { pstmt.setBytes(i, s_param_name.getBytes("UTF-8")); i++; }
		if(s_integer_value != null) { pstmt.setString(i, s_integer_value); i++; }
		if(s_date_value != null) { pstmt.setString(i, s_date_value); i++; }
		if(s_string_value != null) { pstmt.setBytes(i, s_string_value.getBytes("UTF-8")); i++; }
		if(s_money_value != null) { pstmt.setString(i, s_money_value); i++; }		
	}

	public void fixIds()
	{
		FilterParam filterparam = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			filterparam = (FilterParam)e.nextElement();
			if(s_filter_id != null) filterparam.s_filter_id = s_filter_id;
			//if(s_param_id != null) filterparam.s_param_id = s_param_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		FilterParam filterparam = null;
		while (rs.next())
		{
			filterparam = new FilterParam();
			filterparam.getPropsFromResultSetRow(rs);
			add(filterparam);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "filter_params";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "filter_param";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		FilterParam filterparam = null;
		for(int i = 0; i < iLength; i++)
		{
			filterparam = new FilterParam ((Element)nl.item(i));
			v.add(filterparam);
		}
		return iLength;
	}

	// === Other Methods ===
	
	public FilterParam getParam(String sParamName)
	{
		FilterParam fp = null;
		if (sParamName == null) return fp;
		
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			fp = (FilterParam)e.nextElement();
			if (sParamName.equals(fp.s_param_name)) return fp;
		}
		
		return null;
	}

	final private static int m_nIntegerValueType = DataType.INTEGER;
	final private static int m_nStringValueType = DataType.VARCHAR_255;
	final private static int m_nDateValueType = DataType.DATETIME;
	final private static int m_nMoneyValueType = DataType.MONEY;
	
	public String getIntegerValue(String sParamName)
	{
		return getValue(sParamName, m_nIntegerValueType);
	}

	public String getStringValue(String sParamName)
	{
		return getValue(sParamName, m_nStringValueType);
	}

	public String getDateValue(String sParamName)
	{
		return getValue(sParamName, m_nDateValueType);
	}

	public String getMoneyValue(String sParamName)
	{
		return getValue(sParamName, m_nMoneyValueType);
	}
	
	private String getValue(String sParamName, int nValueType)
	{
		String sValue = null;
		FilterParam fp = getParam(sParamName);		
		if (fp == null) return sValue;
		
		switch (nValueType)
		{
			case m_nIntegerValueType:
			{
				sValue = fp.s_integer_value;
				break;
			}
			case m_nStringValueType:
			{
				sValue = fp.s_string_value;
				break;
			}
			case m_nDateValueType:
			{
				sValue = fp.s_date_value;
				break;
			}
			default:
			{
				sValue = null;
				break;
			}
		}
		return sValue;
	}
}


