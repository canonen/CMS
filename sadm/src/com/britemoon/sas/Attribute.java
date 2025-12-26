package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class Attribute extends BriteObject
{
	// === Properties ===

	public String s_attr_id = null;
	public String s_cust_id = null;
	public String s_attr_name = null;
	public String s_type_id = null;
	public String s_scope_id = null;
	public String s_descrip = null;
	public String s_value_qty = null;
	public String s_internal_flag = null;

	// === Parents ===

	// === Children ===
	//log4j implementation
	private static Logger logger = Logger.getLogger(Attribute.class.getName());
	public CustAttrs m_CustAttrs = null;

	// === Constructors ===

	public Attribute()
	{
	}
	
	public Attribute(String sAttrId) throws Exception
	{
		s_attr_id = sAttrId;
		retrieve();
	}

	public Attribute(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	attr_id," +
		"	cust_id," +
		"	attr_name," +
		"	type_id," +
		"	scope_id," +
		"	descrip," +
		"	value_qty," +
		"	internal_flag" +
		" FROM sadm_attribute" +
		" WHERE" +
		"	(attr_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_attr_id);

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
		s_attr_id = rs.getString(1);
		s_cust_id = rs.getString(2);
		b = rs.getBytes(3);
		s_attr_name = (b == null)?null:new String(b,"UTF-8");
		s_type_id = rs.getString(4);
		s_scope_id = rs.getString(5);
		b = rs.getBytes(6);
		s_descrip = (b == null)?null:new String(b,"UTF-8");
		s_value_qty = rs.getString(7);
		s_internal_flag = rs.getString(8);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_attribute_save" +
		"	@attr_id=?," +
		"	@cust_id=?," +
		"	@attr_name=?," +
		"	@type_id=?," +
		"	@scope_id=?," +
		"	@descrip=?," +
		"	@value_qty=?," +
		"	@internal_flag=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_attr_id);
		pstmt.setString(2, s_cust_id);
		if(s_attr_name == null) pstmt.setString(3, s_attr_name);
		else pstmt.setBytes(3, s_attr_name.getBytes("UTF-8"));
		pstmt.setString(4, s_type_id);
		pstmt.setString(5, s_scope_id);
		if(s_descrip == null) pstmt.setString(6, s_descrip);
		else pstmt.setBytes(6, s_descrip.getBytes("UTF-8"));
		pstmt.setString(7, s_value_qty);
		pstmt.setString(8, s_internal_flag);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_attr_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_CustAttrs!=null)
		{
			m_CustAttrs.s_attr_id = s_attr_id;
			m_CustAttrs.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_attribute" +
		" WHERE" +
		"	(attr_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_CustAttrs!=null) m_CustAttrs.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_attr_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "attribute";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_attr_name != null ) XmlUtil.appendCDataChild(e, "attr_name", s_attr_name);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_scope_id != null ) XmlUtil.appendTextChild(e, "scope_id", s_scope_id);
		if( s_descrip != null ) XmlUtil.appendCDataChild(e, "descrip", s_descrip);
		if( s_value_qty != null ) XmlUtil.appendTextChild(e, "value_qty", s_value_qty);
		if( s_internal_flag != null ) XmlUtil.appendTextChild(e, "internal_flag", s_internal_flag);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_CustAttrs != null) appendChild(e, m_CustAttrs);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_attr_name = XmlUtil.getChildCDataValue(e, "attr_name");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_scope_id = XmlUtil.getChildTextValue(e, "scope_id");
		s_descrip = XmlUtil.getChildCDataValue(e, "descrip");
		s_value_qty = XmlUtil.getChildTextValue(e, "value_qty");
		s_internal_flag = XmlUtil.getChildTextValue(e, "internal_flag");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eCustAttrs = XmlUtil.getChildByName(e, "cust_attrs");
		if(eCustAttrs != null) m_CustAttrs = new CustAttrs(eCustAttrs);
	}

	// === Other Methods ===
}


