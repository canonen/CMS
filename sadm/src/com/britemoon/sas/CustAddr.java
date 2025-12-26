package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustAddr extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_state = null;
	public String s_address1 = null;
	public String s_address2 = null;
	public String s_city = null;
	public String s_country = null;
	public String s_zip = null;
	public String s_phone = null;
	public String s_fax = null;

	// === Parents ===

	// === Children ===

	// === Constructors ===
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustAddr.class.getName());
	
	public CustAddr()
	{
	}
	
	public CustAddr(String sCustId) throws Exception
	{
		s_cust_id = sCustId;
		retrieve();
	}

	public CustAddr(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	state," +
		"	address1," +
		"	address2," +
		"	city," +
		"	country," +
		"	zip," +
		"	phone," +
		"	fax" +
		" FROM sadm_cust_addr" +
		" WHERE" +
		"	(cust_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);

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
		b = rs.getBytes(2);
		s_state = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_address1 = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_address2 = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_city = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(6);
		s_country = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(7);
		s_zip = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(8);
		s_phone = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(9);
		s_fax = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_cust_addr_save" +
		"	@cust_id=?," +
		"	@state=?," +
		"	@address1=?," +
		"	@address2=?," +
		"	@city=?," +
		"	@country=?," +
		"	@zip=?," +
		"	@phone=?," +
		"	@fax=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		if(s_state == null) pstmt.setString(2, s_state);
		else pstmt.setBytes(2, s_state.getBytes("UTF-8"));
		if(s_address1 == null) pstmt.setString(3, s_address1);
		else pstmt.setBytes(3, s_address1.getBytes("UTF-8"));
		if(s_address2 == null) pstmt.setString(4, s_address2);
		else pstmt.setBytes(4, s_address2.getBytes("UTF-8"));
		if(s_city == null) pstmt.setString(5, s_city);
		else pstmt.setBytes(5, s_city.getBytes("UTF-8"));
		if(s_country == null) pstmt.setString(6, s_country);
		else pstmt.setBytes(6, s_country.getBytes("UTF-8"));
		if(s_zip == null) pstmt.setString(7, s_zip);
		else pstmt.setBytes(7, s_zip.getBytes("UTF-8"));
		if(s_phone == null) pstmt.setString(8, s_phone);
		else pstmt.setBytes(8, s_phone.getBytes("UTF-8"));
		if(s_fax == null) pstmt.setString(9, s_fax);
		else pstmt.setBytes(9, s_fax.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_cust_addr" +
		" WHERE" +
		"	(cust_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "cust_addr";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_state != null ) XmlUtil.appendCDataChild(e, "state", s_state);
		if( s_address1 != null ) XmlUtil.appendCDataChild(e, "address1", s_address1);
		if( s_address2 != null ) XmlUtil.appendCDataChild(e, "address2", s_address2);
		if( s_city != null ) XmlUtil.appendCDataChild(e, "city", s_city);
		if( s_country != null ) XmlUtil.appendCDataChild(e, "country", s_country);
		if( s_zip != null ) XmlUtil.appendCDataChild(e, "zip", s_zip);
		if( s_phone != null ) XmlUtil.appendCDataChild(e, "phone", s_phone);
		if( s_fax != null ) XmlUtil.appendCDataChild(e, "fax", s_fax);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_state = XmlUtil.getChildCDataValue(e, "state");
		s_address1 = XmlUtil.getChildCDataValue(e, "address1");
		s_address2 = XmlUtil.getChildCDataValue(e, "address2");
		s_city = XmlUtil.getChildCDataValue(e, "city");
		s_country = XmlUtil.getChildCDataValue(e, "country");
		s_zip = XmlUtil.getChildCDataValue(e, "zip");
		s_phone = XmlUtil.getChildCDataValue(e, "phone");
		s_fax = XmlUtil.getChildCDataValue(e, "fax");
	}

	// === Other Methods ===
}


