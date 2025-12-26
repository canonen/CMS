package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustPartner extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_partner_id = null;
	private static Logger logger = Logger.getLogger(CustPartner.class.getName());

	// === Parents ===

	public Partner m_Partner = null;

	// === Children ===

	// === Constructors ===

	public CustPartner()
	{
	}
	
	public CustPartner(String sCustId, String sPartnerId) throws Exception
	{
		s_cust_id = sCustId;
		s_partner_id = sPartnerId;
		retrieve();
	}

	public CustPartner(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	partner_id" +
		" FROM ccps_cust_partner" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(partner_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_partner_id);

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
		s_partner_id = rs.getString(2);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_cust_partner_save" +
		"	@cust_id=?," +
		"	@partner_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_Partner!=null)
		{
			m_Partner.save(conn);
			s_partner_id = m_Partner.s_partner_id;
		}
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_partner_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_partner_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_cust_partner" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(partner_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_partner_id);

		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_Partner!=null) m_Partner.delete(conn);
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "cust_partner";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_partner_id != null ) XmlUtil.appendTextChild(e, "partner_id", s_partner_id);
	}

	public void appendParentsToXml(Element e)
	{
		if (m_Partner != null) appendChild(e, m_Partner);
	}
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_partner_id = XmlUtil.getChildTextValue(e, "partner_id");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element ePartner = XmlUtil.getChildByName(e, "partner");
		if(ePartner != null) m_Partner = new Partner(ePartner);
	}

	// === Other Methods ===
}
