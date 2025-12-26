package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class ModInstService extends BriteObject
{
	// === Properties ===

	public String s_mod_inst_id = null;
	public String s_service_type_id = null;
	public String s_protocol = null;
	public String s_port = null;
	public String s_path = null;
	//log4j implementation
	private static Logger logger = Logger.getLogger(ModInstService.class.getName());
	// === Parents ===

	// === Children ===

	// === Constructors ===

	public ModInstService()
	{
	}
	
	public ModInstService(String sModInstId, String sServiceTypeId) throws Exception
	{
		s_mod_inst_id = sModInstId;
		s_service_type_id = sServiceTypeId;
		retrieve();
	}

	public ModInstService(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	mod_inst_id," +
		"	service_type_id," +
		"	protocol," +
		"	port," +
		"	path" +
		" FROM sadm_mod_inst_service" +
		" WHERE" +
		"	(mod_inst_id=?) AND" +
		"	(service_type_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_mod_inst_id);
		pstmt.setString(2, s_service_type_id);

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
		s_mod_inst_id = rs.getString(1);
		s_service_type_id = rs.getString(2);
		b = rs.getBytes(3);
		s_protocol = (b == null)?null:new String(b,"UTF-8");
		s_port = rs.getString(4);
		b = rs.getBytes(5);
		s_path = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_mod_inst_service_save" +
		"	@mod_inst_id=?," +
		"	@service_type_id=?," +
		"	@protocol=?," +
		"	@port=?," +
		"	@path=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_mod_inst_id);
		pstmt.setString(2, s_service_type_id);
		if(s_protocol == null) pstmt.setString(3, s_protocol);
		else pstmt.setBytes(3, s_protocol.getBytes("UTF-8"));
		pstmt.setString(4, s_port);
		if(s_path == null) pstmt.setString(5, s_path);
		else pstmt.setBytes(5, s_path.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_mod_inst_id = rs.getString(1);
			s_service_type_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_mod_inst_service" +
		" WHERE" +
		"	(mod_inst_id=?) AND" +
		"	(service_type_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_mod_inst_id);
		pstmt.setString(2, s_service_type_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "mod_inst_service";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_mod_inst_id != null ) XmlUtil.appendTextChild(e, "mod_inst_id", s_mod_inst_id);
		if( s_service_type_id != null ) XmlUtil.appendTextChild(e, "service_type_id", s_service_type_id);
		if( s_protocol != null ) XmlUtil.appendCDataChild(e, "protocol", s_protocol);
		if( s_port != null ) XmlUtil.appendTextChild(e, "port", s_port);
		if( s_path != null ) XmlUtil.appendCDataChild(e, "path", s_path);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_mod_inst_id = XmlUtil.getChildTextValue(e, "mod_inst_id");
		s_service_type_id = XmlUtil.getChildTextValue(e, "service_type_id");
		s_protocol = XmlUtil.getChildCDataValue(e, "protocol");
		s_port = XmlUtil.getChildTextValue(e, "port");
		s_path = XmlUtil.getChildCDataValue(e, "path");
	}

	// === Other Methods ===
}


