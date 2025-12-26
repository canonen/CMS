package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class CustUniqueId extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_type_id = null;
	public String s_min_id = null;
	public String s_max_id = null;
	public String s_next_id = null;
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustUniqueId.class.getName());
	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CustUniqueId()
	{
	}
	
	public CustUniqueId(String sTypeId, String sCustId) throws Exception
	{
		s_cust_id = sCustId;
		s_type_id = sTypeId;		
		retrieve();
	}

	public CustUniqueId(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	type_id," +
		"	min_id," +
		"	max_id," +
		"	next_id" +
		" FROM sadm_cust_unique_id" +
		" WHERE" +
		"	(type_id=?) AND" +
		"	(cust_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_type_id);
		pstmt.setString(2, s_cust_id);

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
		s_type_id = rs.getString(2);
		s_min_id = rs.getString(3);
		s_max_id = rs.getString(4);
		s_next_id = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_cust_unique_id_save" +
		"	@cust_id=?," +
		"	@type_id=?," +
		"	@min_id=?," +
		"	@max_id=?," +
		"	@next_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_type_id);
		pstmt.setString(3, s_min_id);
		pstmt.setString(4, s_max_id);
		pstmt.setString(5, s_next_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_type_id = rs.getString(2);
			s_min_id = rs.getString(3);
			s_max_id = rs.getString(4);
			s_next_id = rs.getString(5);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_cust_unique_id" +
		" WHERE" +
		"	(type_id=?) AND" +
		"	(cust_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_type_id);
		pstmt.setString(2, s_cust_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "cust_unique_id";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_min_id != null ) XmlUtil.appendTextChild(e, "min_id", s_min_id);
		if( s_max_id != null ) XmlUtil.appendTextChild(e, "max_id", s_max_id);
		if( s_next_id != null ) XmlUtil.appendTextChild(e, "next_id", s_next_id);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_min_id = XmlUtil.getChildTextValue(e, "min_id");
		s_max_id = XmlUtil.getChildTextValue(e, "max_id");
		s_next_id = XmlUtil.getChildTextValue(e, "next_id");
	}

	// === Other Methods ===
}


