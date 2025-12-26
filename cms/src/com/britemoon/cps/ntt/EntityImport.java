package com.britemoon.cps.ntt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EntityImport extends BriteObject
{
	// === Properties ===

	public String s_import_id = null;
	public String s_import_name = null;
	public String s_template_id = null;
	public String s_cust_id = null;
	public String s_status_id = null;
	public String s_file_name = null;
	public String s_file_url = null;
	private static Logger logger = Logger.getLogger(EntityImport.class.getName());

	// === Parents ===

	public EntityImportTemplate m_EntityImportTemplate = null;

	// === Children ===

	// EntityImportSyncInfo does not exist in CPS.
	// For now it only takes data from cftp_ftp_file_assignments
	// to sent to RCP to keep recipient_import - entity_import sequence in case
	// entity data was imported with recipient data.
	public EntityImportSyncInfo m_EntityImportSyncInfo = null;
	public EntityImportStatistics m_EntityImportStatistics = null;	

	// === Constructors ===

	public EntityImport()
	{
	}
	
	public EntityImport(String sImportId) throws Exception
	{
		s_import_id = sImportId;
		retrieve();
	}

	public EntityImport(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteObject will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	import_id," +
		"	import_name," +
		"	template_id," +
		"	cust_id," +
		"	status_id," +
		"	file_name," +
		"	file_url" +
		" FROM cntt_entity_import" +
		" WHERE" +
		"	(import_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_import_id);

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
		s_import_id = rs.getString(1);
		b = rs.getBytes(2);
		s_import_name = (b == null)?null:new String(b,"UTF-8");
		s_template_id = rs.getString(3);
		s_cust_id = rs.getString(4);
		s_status_id = rs.getString(5);
		b = rs.getBytes(6);
		s_file_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(7);
		s_file_url = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cntt_entity_import_save" +
		"	@import_id=?," +
		"	@import_name=?," +
		"	@template_id=?," +
		"	@cust_id=?," +
		"	@status_id=?," +
		"	@file_name=?," +
		"	@file_url=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_EntityImportTemplate !=null)
		{
			m_EntityImportTemplate.save(conn);
			s_template_id = m_EntityImportTemplate.s_template_id;
		}
		
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_import_id);
		if(s_import_name == null) pstmt.setString(2, s_import_name);
		else pstmt.setBytes(2, s_import_name.getBytes("UTF-8"));
		pstmt.setString(3, s_template_id);
		pstmt.setString(4, s_cust_id);
		pstmt.setString(5, s_status_id);
		if(s_file_name == null) pstmt.setString(6, s_file_name);
		else pstmt.setBytes(6, s_file_name.getBytes("UTF-8"));
		if(s_file_url == null) pstmt.setString(7, s_file_url);
		else pstmt.setBytes(7, s_file_url.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_import_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_EntityImportStatistics != null)
		{
			m_EntityImportStatistics.s_import_id = s_import_id;
			m_EntityImportStatistics.save();
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cntt_entity_import" +
		" WHERE" +
		"	(import_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_EntityImportStatistics!=null) m_EntityImportStatistics.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_import_id);
		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_EntityImportTemplate!=null) m_EntityImportTemplate.delete(conn);
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "entity_import";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_import_id != null ) XmlUtil.appendTextChild(e, "import_id", s_import_id);
		if( s_import_name != null ) XmlUtil.appendCDataChild(e, "import_name", s_import_name);
		if( s_template_id != null ) XmlUtil.appendTextChild(e, "template_id", s_template_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_file_name != null ) XmlUtil.appendCDataChild(e, "file_name", s_file_name);
		if( s_file_url != null ) XmlUtil.appendCDataChild(e, "file_url", s_file_url);
	}

	// Kill these parent - child methods
	// if they are not supposed to be in use.

	public void appendParentsToXml(Element e)
	{
		if (m_EntityImportTemplate != null) appendChild(e, m_EntityImportTemplate);
	}
	
	public void appendChildrenToXml(Element e)
	{
		if (m_EntityImportSyncInfo != null) appendChild(e, m_EntityImportSyncInfo);
		if (m_EntityImportStatistics != null) appendChild(e, m_EntityImportStatistics);		
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_import_id = XmlUtil.getChildTextValue(e, "import_id");
		s_import_name = XmlUtil.getChildCDataValue(e, "import_name");
		s_template_id = XmlUtil.getChildTextValue(e, "template_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_file_name = XmlUtil.getChildCDataValue(e, "file_name");
		s_file_url = XmlUtil.getChildCDataValue(e, "file_url");
	}

	// Kill these parent - child methods
	// if they are not supposed to be in use.

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eEntityImportTemplate = XmlUtil.getChildByName(e, "entity_import_template");
		if(eEntityImportTemplate != null)
			m_EntityImportTemplate = new EntityImportTemplate(eEntityImportTemplate);
	}
	
	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eEntityImportSyncInfo = XmlUtil.getChildByName(e, "entity_import_sync_info");
		if(eEntityImportSyncInfo != null) m_EntityImportSyncInfo = new EntityImportSyncInfo(eEntityImportSyncInfo);

		Element eEntityImportStatistics = XmlUtil.getChildByName(e, "entity_import_statistics");
		if(eEntityImportStatistics != null) m_EntityImportStatistics = new EntityImportStatistics(eEntityImportStatistics);
	}

	// === Other Methods ===
}


