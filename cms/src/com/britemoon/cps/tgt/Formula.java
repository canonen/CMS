package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Formula extends BriteObject
{
	// === Properties ===

	public String s_filter_id = null;
	public String s_attr_id = null;
	public String s_operation_id = null;
	public String s_positive_flag = null;
	public String s_value1 = null;
	public String s_value2 = null;
	private static Logger logger = Logger.getLogger(Formula.class.getName());	

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public Formula()
	{
	}
	
	public Formula(String sFilterId) throws Exception
	{
		s_filter_id = sFilterId;
		retrieve();
	}

	public Formula(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	filter_id," +
		"	attr_id," +
		"	operation_id," +
		"	value1," +
		"	positive_flag," +
		"	value2" +
		" FROM ctgt_formula" +
		" WHERE" +
		"	(filter_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);

		ResultSet rs = pstmt.executeQuery();
		if (rs.next())
		{
			getPropsFromResultSetRow(rs);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public void getPropsFromResultSetRow(ResultSet rs) throws Exception
	{
		byte[] b = null;
		s_filter_id = rs.getString(1);
		s_attr_id = rs.getString(2);
		s_operation_id = rs.getString(3);
		b = rs.getBytes(4);
		s_value1 = (b == null)?null:new String(b,"UTF-8");
		s_positive_flag = rs.getString(5);
		b = rs.getBytes(6);
		s_value2 = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ctgt_formula_save" +
		"	@filter_id=?," +
		"	@attr_id=?," +
		"	@operation_id=?," +
		"	@value1=?," +
		"	@positive_flag=?," +
		"	@value2=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_attr_id);
		pstmt.setString(3, s_operation_id);
		if(s_value1 == null) pstmt.setString(4, s_value1);
		else pstmt.setBytes(4, s_value1.getBytes("UTF-8"));
		pstmt.setString(5, s_positive_flag);
		if(s_value2 == null) pstmt.setString(6, s_value2);
		else pstmt.setBytes(6, s_value2.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_filter_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ctgt_formula" +
		" WHERE" +
		"	(filter_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_filter_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "formula";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_operation_id != null ) XmlUtil.appendTextChild(e, "operation_id", s_operation_id);
		if( s_value1 != null ) XmlUtil.appendCDataChild(e, "value1", s_value1);
		if( s_positive_flag != null ) XmlUtil.appendTextChild(e, "positive_flag", s_positive_flag);
		if( s_value2 != null ) XmlUtil.appendCDataChild(e, "value2", s_value2);
	}

	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_operation_id = XmlUtil.getChildTextValue(e, "operation_id");
		s_value1 = XmlUtil.getChildCDataValue(e, "value1");
		s_positive_flag = XmlUtil.getChildTextValue(e, "positive_flag");
		s_value2 = XmlUtil.getChildCDataValue(e, "value2");
	}

	// === Other Methods ===
}


