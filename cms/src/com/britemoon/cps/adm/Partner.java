package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Partner extends BriteObject
{
	// === Properties ===
	private static Logger logger = Logger.getLogger(Partner.class.getName());
	public String s_partner_id = null;
	public String s_partner_name = null;

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public Partner()
	{
	}
	
	public Partner(String sPartnerId) throws Exception
	{
		s_partner_id = sPartnerId;
		retrieve();
	}

	public Partner(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	partner_id," +
		"	partner_name" +
		" FROM ccps_partner" +
		" WHERE" +
		"	(partner_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_partner_id);

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
		s_partner_id = rs.getString(1);
		b = rs.getBytes(2);
		s_partner_name = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_partner_save" +
		"	@partner_id=?," +
		"	@partner_name=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_partner_id);
		if(s_partner_name == null) pstmt.setString(2, s_partner_name);
		else pstmt.setBytes(2, s_partner_name.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_partner_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_partner" +
		" WHERE" +
		"	(partner_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_partner_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "partner";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_partner_id != null ) XmlUtil.appendTextChild(e, "partner_id", s_partner_id);
		if( s_partner_name != null ) XmlUtil.appendCDataChild(e, "partner_name", s_partner_name);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_partner_id = XmlUtil.getChildTextValue(e, "partner_id");
		s_partner_name = XmlUtil.getChildCDataValue(e, "partner_name");
	}

	// === Other Methods ===
}


