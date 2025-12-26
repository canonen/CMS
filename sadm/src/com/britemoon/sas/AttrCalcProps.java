package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class AttrCalcProps extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_attr_id = null;
	public String s_calc_values_flag = null;
	public String s_last_calc_date = null;

	// === Parents ===

	// === Children ===
	//log4j implementation
	private static Logger logger = Logger.getLogger(AttrCalcProps.class.getName());
	
	// === Constructors ===

	public AttrCalcProps()
	{
	}
	
	public AttrCalcProps(String sCustId, String sAttrId) throws Exception
	{
		s_cust_id = sCustId;
		s_attr_id = sAttrId;
		retrieve();
	}

	public AttrCalcProps(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	attr_id," +
		"	calc_values_flag," +
		"	last_calc_date" +
		" FROM sadm_attr_calc_props" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(attr_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);

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
		s_cust_id = rs.getString(1);
		s_attr_id = rs.getString(2);
		s_calc_values_flag = rs.getString(3);
		s_last_calc_date = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_attr_calc_props_save" +
		"	@cust_id=?," +
		"	@attr_id=?," +
		"	@calc_values_flag=?," +
		"	@last_calc_date=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);
		pstmt.setString(3, s_calc_values_flag);
		pstmt.setString(4, s_last_calc_date);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_attr_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_attr_calc_props" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(attr_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "attr_calc_props";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_calc_values_flag != null ) XmlUtil.appendTextChild(e, "calc_values_flag", s_calc_values_flag);
		if( s_last_calc_date != null ) XmlUtil.appendTextChild(e, "last_calc_date", s_last_calc_date);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_calc_values_flag = XmlUtil.getChildTextValue(e, "calc_values_flag");
		s_last_calc_date = XmlUtil.getChildTextValue(e, "last_calc_date");
	}

	// === Other Methods ===
}


