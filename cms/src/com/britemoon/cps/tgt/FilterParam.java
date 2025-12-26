package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FilterParam extends BriteObject
{
	// === Properties ===

	public String s_filter_id = null;
	public String s_param_id = null;
	public String s_param_name = null;
	public String s_integer_value = null;
	public String s_date_value = null;
	public String s_string_value = null;
	public String s_money_value = null;	
	private static Logger logger = Logger.getLogger(FilterParam.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FilterParam()
	{
	}
	
	public FilterParam(String sFilterId, String sParamId) throws Exception
	{
		s_filter_id = sFilterId;
		s_param_id = sParamId;
		retrieve();
	}

	public FilterParam(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	private String m_sRetrieveSql =
		" SELECT" +
		"	filter_id," +
		"	param_id," +
		"	param_name," +
		"	integer_value," +
		"	date_value," +
		"	string_value," +
		"	money_value" +		
		" FROM ctgt_filter_param" +
		" WHERE" +
		"	(filter_id=?) AND" +
		"	(param_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	protected int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_param_id);

		ResultSet rs = pstmt.executeQuery();
		if (rs.next())
		{
			getPropsFromResultSetRow(rs);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	protected void getPropsFromResultSetRow(ResultSet rs) throws Exception
	{
		byte[] b = null;
		
		s_filter_id = rs.getString(1);
		s_param_id = rs.getString(2);
		
		b = rs.getBytes(3);
		s_param_name = (b == null)?null:new String(b,"UTF-8");
		
		s_integer_value = rs.getString(4);
		s_date_value = rs.getString(5);
		
		b = rs.getBytes(6);
		s_string_value = (b == null)?null:new String(b,"UTF-8");
		
		s_money_value = rs.getString(7);
	}

	// === DB Method save()===

	private String m_sSaveSql =
		" EXECUTE usp_ctgt_filter_param_save" +
		"	@filter_id=?," +
		"	@param_id=?," +
		"	@param_name=?," +
		"	@integer_value=?," +
		"	@date_value=?," +
		"	@string_value=?," +
		"	@money_value=?";

	public String getSaveSql() { return m_sSaveSql; }

	protected int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_param_id);

		if(s_param_name == null) pstmt.setString(3, s_param_name);
		else pstmt.setBytes(3, s_param_name.getBytes("UTF-8"));

		pstmt.setString(4, s_integer_value);
		pstmt.setString(5, s_date_value);

		if(s_string_value == null) pstmt.setString(6, s_string_value);
		else pstmt.setBytes(6, s_string_value.getBytes("UTF-8"));

		if(s_money_value == null) pstmt.setNull(7, java.sql.Types.DOUBLE);
		else pstmt.setDouble(7, Double.parseDouble(s_money_value));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_filter_id = rs.getString(1);
			s_param_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	private String m_sDeleteSql =
		" DELETE FROM ctgt_filter_param" +
		" WHERE" +
		"	(filter_id=?) AND" +
		"	(param_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	protected int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_param_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "filter_param";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_param_id != null ) XmlUtil.appendTextChild(e, "param_id", s_param_id);
		if( s_param_name != null ) XmlUtil.appendCDataChild(e, "param_name", s_param_name);
		if( s_integer_value != null ) XmlUtil.appendTextChild(e, "integer_value", s_integer_value);
		if( s_date_value != null ) XmlUtil.appendTextChild(e, "date_value", s_date_value);
		if( s_string_value != null ) XmlUtil.appendCDataChild(e, "string_value", s_string_value);
		if( s_money_value != null ) XmlUtil.appendTextChild(e, "money_value", s_money_value);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_param_id = XmlUtil.getChildTextValue(e, "param_id");
		s_param_name = XmlUtil.getChildCDataValue(e, "param_name");
		s_integer_value = XmlUtil.getChildTextValue(e, "integer_value");
		s_date_value = XmlUtil.getChildTextValue(e, "date_value");
		s_string_value = XmlUtil.getChildCDataValue(e, "string_value");
		s_money_value = XmlUtil.getChildTextValue(e, "money_value");
	}

	// === Other Methods ===
}


