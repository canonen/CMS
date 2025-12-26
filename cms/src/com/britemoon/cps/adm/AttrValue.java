package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class AttrValue extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_attr_id = null;
	public String s_attr_value = null;
	public String s_value_qty = null;
	private static Logger logger = Logger.getLogger(AttrValue.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public AttrValue()
	{
	}
	
	public AttrValue(String sCustId, String sAttrId, String sAttrValue) throws Exception
	{
		s_cust_id = sCustId;
		s_attr_id = sAttrId;
		s_attr_value = sAttrValue;
		retrieve();
	}

	public AttrValue(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	attr_id," +
		"	attr_value," +
		"	value_qty" +
		" FROM ccps_attr_value" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(attr_id=?) AND" +
		"	(attr_value=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);
		if(s_attr_value == null) pstmt.setString(3, s_attr_value);
		else pstmt.setBytes(3, s_attr_value.getBytes("UTF-8"));


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
		b = rs.getBytes(3);
		s_attr_value = (b == null)?null:new String(b,"UTF-8");
		s_value_qty = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_attr_value_save" +
		"	@cust_id=?," +
		"	@attr_id=?," +
		"	@attr_value=?," +
		"	@value_qty=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);
		if(s_attr_value == null) pstmt.setString(3, s_attr_value);
		else pstmt.setBytes(3, s_attr_value.getBytes("UTF-8"));
		pstmt.setString(4, s_value_qty);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_attr_id = rs.getString(2);
			b = rs.getBytes(3);
			s_attr_value = (b == null)?null:new String(b,"UTF-8");

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_attr_value" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(attr_id=?) AND" +
		"	(attr_value=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);
		if(s_attr_value == null) pstmt.setString(3, s_attr_value);
		else pstmt.setBytes(3, s_attr_value.getBytes("UTF-8"));

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "attr_value";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_attr_value != null ) XmlUtil.appendCDataChild(e, "attr_value", s_attr_value);
		if( s_value_qty != null ) XmlUtil.appendTextChild(e, "value_qty", s_value_qty);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_attr_value = XmlUtil.getChildCDataValue(e, "attr_value");
		s_value_qty = XmlUtil.getChildTextValue(e, "value_qty");
	}

	// === Other Methods ===
}


