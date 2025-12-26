package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustSendParam extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_sender_address = null;
	public String s_error_to_address = null;
	private static Logger logger = Logger.getLogger(CustSendParam.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CustSendParam()
	{
	}
	
	public CustSendParam(String sCustId) throws Exception
	{
		s_cust_id = sCustId;
		retrieve();
	}

	public CustSendParam(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	sender_address," +
		"	error_to_address" +
		" FROM ccps_cust_send_param" +
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
		s_sender_address = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_error_to_address = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_cust_send_param_save" +
		"	@cust_id=?," +
		"	@sender_address=?," +
		"	@error_to_address=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		if(s_sender_address == null) pstmt.setString(2, s_sender_address);
		else pstmt.setBytes(2, s_sender_address.getBytes("UTF-8"));
		if(s_error_to_address == null) pstmt.setString(3, s_error_to_address);
		else pstmt.setBytes(3, s_error_to_address.getBytes("UTF-8"));

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
		" DELETE FROM ccps_cust_send_param" +
		" WHERE" +
		"	(cust_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "cust_send_param";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_sender_address != null ) XmlUtil.appendCDataChild(e, "sender_address", s_sender_address);
		if( s_error_to_address != null ) XmlUtil.appendCDataChild(e, "error_to_address", s_error_to_address);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_sender_address = XmlUtil.getChildCDataValue(e, "sender_address");
		s_error_to_address = XmlUtil.getChildCDataValue(e, "error_to_address");
	}

	// === Other Methods ===
}


