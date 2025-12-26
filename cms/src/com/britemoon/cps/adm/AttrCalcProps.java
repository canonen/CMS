package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;
import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;

import org.w3c.dom.*;

public class AttrCalcProps extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_attr_id = null;
	public String s_calc_values_flag = null;
	public String s_last_calc_date = null;
	public String s_distinct_values_qty = null;
	public String s_calc_status_id = null;
	public String s_filter_usage = null;
	private static Logger logger = Logger.getLogger(AttrCalcProps.class.getName());

	// === Parents ===

	// === Children ===

	public AttrValues m_AttrValues = null;
	
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
		"	last_calc_date," +
		"	distinct_values_qty," +
		"	calc_status_id," +
		"	filter_usage" +
		" FROM ccps_attr_calc_props" +
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
		s_distinct_values_qty = rs.getString(5);
		s_calc_status_id = rs.getString(6);
		s_filter_usage = rs.getString(7);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_attr_calc_props_save" +
		"	@cust_id=?," +
		"	@attr_id=?," +
		"	@calc_values_flag=?," +
		"	@last_calc_date=?," +
		"	@distinct_values_qty=?," +
		"	@calc_status_id=?," +
		"	@filter_usage=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);
		pstmt.setString(3, s_calc_values_flag);
		pstmt.setString(4, s_last_calc_date);
		pstmt.setString(5, s_distinct_values_qty);
		pstmt.setString(6, s_calc_status_id);
		pstmt.setString(7, s_filter_usage);

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

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_AttrValues!=null)
		{
			m_AttrValues.s_cust_id = s_cust_id;
			m_AttrValues.s_attr_id = s_attr_id;

			String sSql =
				" DELETE ccps_attr_value" +
				" WHERE cust_id = " + s_cust_id +
				" AND attr_id = " + s_attr_id;
			BriteUpdate.executeUpdate(sSql, conn);

			m_AttrValues.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_attr_calc_props" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(attr_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_AttrValues!=null) m_AttrValues.delete(conn);
		return 1;
	}

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
		if( s_distinct_values_qty != null ) XmlUtil.appendTextChild(e, "distinct_values_qty", s_distinct_values_qty);
		if( s_calc_status_id != null ) XmlUtil.appendTextChild(e, "calc_status_id", s_calc_status_id);
		if( s_filter_usage != null ) XmlUtil.appendTextChild(e, "filter_usage", s_filter_usage);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_AttrValues != null) appendChild(e, m_AttrValues);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_calc_values_flag = XmlUtil.getChildTextValue(e, "calc_values_flag");
		s_last_calc_date = XmlUtil.getChildTextValue(e, "last_calc_date");
		s_distinct_values_qty = XmlUtil.getChildTextValue(e, "distinct_values_qty");
		s_calc_status_id = XmlUtil.getChildTextValue(e, "calc_status_id");
		s_filter_usage = XmlUtil.getChildTextValue(e, "filter_usage");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eAttrValues = XmlUtil.getChildByName(e, "attr_values");
		if(eAttrValues != null) m_AttrValues = new AttrValues(eAttrValues);
	}

	// === Other Methods ===
}


