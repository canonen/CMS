package com.britemoon.cps.rpt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustDomain extends BriteObject
{
	// === Properties ===

	public String s_domain_id = null;
	public String s_cust_id = null;
	public String s_domain = null;
	private static Logger logger = Logger.getLogger(CustDomain.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CustDomain()
	{
	}
	
	public CustDomain(String sDomainId, String sCustId) throws Exception
	{
		s_domain_id = sDomainId;
		s_cust_id = sCustId;
		retrieve();
	}

	public CustDomain(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===
	
	public String getOwnerId() { return s_cust_id; }	

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	domain_id," +
		"	cust_id," +
		"	domain" +
		" FROM crpt_cust_domain" +
		" WHERE" +
		"	(domain_id=?)" +
		"	AND (cust_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_domain_id);
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
		s_domain_id = rs.getString(1);
		s_cust_id = rs.getString(2);
		b = rs.getBytes(3);
		s_domain = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		"EXECUTE usp_crpt_cust_domain_save" +
		" @domain_id=?," + 
		" @cust_id=?," + 
		" @domain=?"; 

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_domain_id);
		pstmt.setString(2, s_cust_id);
		if(s_domain == null) pstmt.setString(3, s_domain);
		else pstmt.setBytes(3, s_domain.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_domain_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM crpt_cust_domain" +
		" WHERE" +
		"	(domain_id=?)" +
		"	AND (cust_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_domain_id);
		pstmt.setString(2, s_cust_id);
		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "cust_domain";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_domain_id != null ) XmlUtil.appendTextChild(e, "domain_id", s_domain_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_domain != null ) XmlUtil.appendCDataChild(e, "domain", s_domain);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_domain_id = XmlUtil.getChildTextValue(e, "domain_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_domain = XmlUtil.getChildCDataValue(e, "domain");
	}
	
	// === Other Methods ===
}


