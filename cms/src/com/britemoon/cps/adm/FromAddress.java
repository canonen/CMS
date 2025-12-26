package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FromAddress extends BriteObject
{
	// === Properties ===

	public String s_from_address_id = null;
	public String s_cust_id = null;
	public String s_domain = null;
	public String s_prefix = null;
	private static Logger logger = Logger.getLogger(FromAddress.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FromAddress()
	{
	}
	
	public FromAddress(String sFromAddressId) throws Exception
	{
		s_from_address_id = sFromAddressId;
		retrieve();
	}

	public FromAddress(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	from_address_id," +
		"	cust_id," +
		"	domain," +
		"	prefix" +
		" FROM ccps_from_address" +
		" WHERE" +
		"	(from_address_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_from_address_id);

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
		s_from_address_id = rs.getString(1);
		s_cust_id = rs.getString(2);
		b = rs.getBytes(3);
		s_domain = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_prefix = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_from_address_save" +
		"	@from_address_id=?," +
		"	@cust_id=?," +
		"	@domain=?," +
		"	@prefix=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_from_address_id);
		pstmt.setString(2, s_cust_id);
		if(s_domain == null) pstmt.setString(3, s_domain);
		else pstmt.setBytes(3, s_domain.getBytes("UTF-8"));
		if(s_prefix == null) pstmt.setString(4, s_prefix);
		else pstmt.setBytes(4, s_prefix.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_from_address_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_from_address" +
		" WHERE" +
		"	(from_address_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_from_address_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "from_address";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_from_address_id != null ) XmlUtil.appendTextChild(e, "from_address_id", s_from_address_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_domain != null ) XmlUtil.appendCDataChild(e, "domain", s_domain);
		if( s_prefix != null ) XmlUtil.appendCDataChild(e, "prefix", s_prefix);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_from_address_id = XmlUtil.getChildTextValue(e, "from_address_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_domain = XmlUtil.getChildCDataValue(e, "domain");
		s_prefix = XmlUtil.getChildCDataValue(e, "prefix");
	}

	// === Other Methods ===

	public void saveWithSync() throws Exception
	{
		synchronize();
		save();
	}

	private void synchronize() throws Exception
	{
		String sRequest = this.toXml();
		String sResponse = Service.communicate(ServiceType.SADM_FROM_ADDRESS_SETUP, s_cust_id, sRequest);

		Element eResponse = XmlUtil.getRootElement(sResponse);
		this.fromXml(eResponse);
		sRequest = sResponse;
						
		sResponse = Service.communicate(ServiceType.AINB_FROM_ADDRESS_SETUP, s_cust_id, sRequest);
		eResponse = XmlUtil.getRootElement(sResponse);
	}
}
