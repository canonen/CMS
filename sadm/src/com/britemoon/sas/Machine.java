package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class Machine extends BriteObject
{
	// === Properties ===

	public String s_machine_id = null;
	public String s_machine_name = null;
	public String s_ip_address = null;
	//log4j implementation
	private static Logger logger = Logger.getLogger(Machine.class.getName());
	// === Parents ===

	// === Children ===

	// === Constructors ===

	public Machine()
	{
	}
	
	public Machine(String sMachineId) throws Exception
	{
		s_machine_id = sMachineId;
		retrieve();
	}

	public Machine(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	machine_id," +
		"	machine_name," +
		"	ip_address" +
		" FROM sadm_machine" +
		" WHERE" +
		"	(machine_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_machine_id);

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
		s_machine_id = rs.getString(1);
		b = rs.getBytes(2);
		s_machine_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_ip_address = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_machine_save" +
		"	@machine_id=?," +
		"	@machine_name=?," +
		"	@ip_address=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_machine_id);
		if(s_machine_name == null) pstmt.setString(2, s_machine_name);
		else pstmt.setBytes(2, s_machine_name.getBytes("UTF-8"));
		if(s_ip_address == null) pstmt.setString(3, s_ip_address);
		else pstmt.setBytes(3, s_ip_address.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_machine_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_machine" +
		" WHERE" +
		"	(machine_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_machine_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "machine";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_machine_id != null ) XmlUtil.appendTextChild(e, "machine_id", s_machine_id);
		if( s_machine_name != null ) XmlUtil.appendCDataChild(e, "machine_name", s_machine_name);
		if( s_ip_address != null ) XmlUtil.appendCDataChild(e, "ip_address", s_ip_address);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_machine_id = XmlUtil.getChildTextValue(e, "machine_id");
		s_machine_name = XmlUtil.getChildCDataValue(e, "machine_name");
		s_ip_address = XmlUtil.getChildCDataValue(e, "ip_address");
	}

	// === Other Methods ===
}
