package com.britemoon.cps.xcs;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.tgt.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustResource extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_resource_id = null;
	public String s_username = null;
	public String s_password = null;
	public String s_host = null;
	public String s_url = null;
	public String s_str_value = null;
	public String s_id_value = null;

	private static Logger logger = Logger.getLogger(CustResource.class.getName());

	// === Constructors ===
	
	public CustResource()
	{
	}
	
	public CustResource(String sCustId, String sResourceId) throws Exception
	{
		s_cust_id = sCustId;
		s_resource_id = sResourceId;
		retrieve();
	}

	public CustResource(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===
	
	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	resource_id," +
		"	username," +
		"	password," +
		"	host," +
		"	url," +
		"	str_value," +
		"	id_value" +
		" FROM cxcs_cust_resource" +
		" WHERE" +
		"	(cust_id=?) AND (resource_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_resource_id);
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
		s_cust_id = rs.getString(1);
		s_resource_id = rs.getString(2);
		s_username = rs.getString(3);
		s_password = rs.getString(4);
		s_host = rs.getString(5);
		s_url = rs.getString(6);
		s_str_value = rs.getString(7);
		s_id_value = rs.getString(8);
	}
	
	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cxcs_cust_resource_save" +
		"	@cust_id=?," +
		"	@resource_id=?," +
		"	@username=?," +
		"	@password=?," +
		"	@host=?," +
		"	@url=?," +
		"	@str_value=?," +
		"	@id_value=?";

	public String getSaveSql() { return m_sSaveSql; }
	
	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_resource_id);
		pstmt.setString(3, s_username);
		pstmt.setString(4, s_password);
		pstmt.setString(5, s_host);
		pstmt.setString(6, s_url);
		pstmt.setString(7, s_str_value);
		pstmt.setString(8, s_id_value);

		ResultSet rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_resource_id = rs.getString(2);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cxcs_cust_resource" +
		" WHERE" +
		"	(cust_id=?) AND (resource_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(1, s_resource_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "CustResource";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_resource_id != null ) XmlUtil.appendTextChild(e, "resource_id", s_resource_id);
		if( s_username != null ) XmlUtil.appendTextChild(e, "username", s_username);
		if( s_password != null ) XmlUtil.appendTextChild(e, "password", s_password);
		if( s_host != null ) XmlUtil.appendCDataChild(e, "host", s_host);
		if( s_url != null ) XmlUtil.appendTextChild(e, "url", s_url);
		if( s_str_value != null ) XmlUtil.appendTextChild(e, "str_value", s_str_value);
		if( s_str_value != null ) XmlUtil.appendTextChild(e, "id_value", s_id_value);

	}
	
	// === From XML Methods ===	
	
	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_resource_id = XmlUtil.getChildTextValue(e, "resource_id");
		s_username = XmlUtil.getChildTextValue(e, "username");
		s_password = XmlUtil.getChildTextValue(e, "password");
		s_host = XmlUtil.getChildCDataValue(e, "host");
		s_url = XmlUtil.getChildTextValue(e, "url");
		s_str_value = XmlUtil.getChildTextValue(e, "str_value");
		s_id_value = XmlUtil.getChildTextValue(e, "id_value");
	}
	
	// === Other Methods ===
}
