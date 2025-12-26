package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Import extends BriteObject
{
	// === Properties ===

	public String s_import_id = null;
	public String s_batch_id = null;
	public String s_import_name = null;
	public String s_status_id = null;
	public String s_import_date = null;
	public String s_field_separator = null;
	public String s_first_row = null;
	public String s_import_file = null;
	public String s_upd_rule_id = null;
	public String s_import_url = null;
	public String s_full_name_flag = null;
	public String s_email_type_flag = null;
	public String s_type_id = null;
	public String s_upd_hierarchy_id = null;
	public String s_auto_commit_flag = null;
	public String s_multi_value_field_separator = null;
	private static Logger logger = Logger.getLogger(Import.class.getName());	

	// === Parents ===

	public Batch m_Batch = null;

	// === Children ===

	public FieldsMappings m_FieldsMappings = null;
	public ImportNewsletters m_ImportNewsletters = null;
	// public ImportStatistics(s) m_ImportStatistics(s) = null;

	// === Constructors ===

	public Import()
	{
	}
	
	public Import(String sImportId) throws Exception
	{
		s_import_id = sImportId;
		retrieve();
	}

	public Import(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	import_id," +
		"	batch_id," +
		"	import_name," +
		"	status_id," +
		"	import_date," +
		"	field_separator," +
		"	first_row," +
		"	import_file," +
		"	upd_rule_id," +
		"	import_url," +
		"	full_name_flag," +
		"	email_type_flag," +
		"	type_id," +
		"	upd_hierarchy_id," +
		"	auto_commit_flag," +
		"	multi_value_field_separator" +
		" FROM cupd_import" +
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
		s_batch_id = rs.getString(2);
		b = rs.getBytes(3);
		s_import_name = (b == null)?null:new String(b,"UTF-8");
		s_status_id = rs.getString(4);
		s_import_date = rs.getString(5);
		b = rs.getBytes(6);
		s_field_separator = (b == null)?null:new String(b,"UTF-8");
		s_first_row = rs.getString(7);
		b = rs.getBytes(8);
		s_import_file = (b == null)?null:new String(b,"UTF-8");
		s_upd_rule_id = rs.getString(9);
		b = rs.getBytes(10);
		s_import_url = (b == null)?null:new String(b,"UTF-8");
		s_full_name_flag = rs.getString(11);
		s_email_type_flag = rs.getString(12);
		s_type_id = rs.getString(13);
		s_upd_hierarchy_id = rs.getString(14);
		s_auto_commit_flag = rs.getString(15);
		b = rs.getBytes(16);
		s_multi_value_field_separator = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cupd_import_save" +
		"	@import_id=?," +
		"	@batch_id=?," +
		"	@import_name=?," +
		"	@status_id=?," +
		"	@import_date=?," +
		"	@field_separator=?," +
		"	@first_row=?," +
		"	@import_file=?," +
		"	@upd_rule_id=?," +
		"	@import_url=?," +
		"	@full_name_flag=?," +
		"	@email_type_flag=?," +
		"	@type_id=?," +
		"	@upd_hierarchy_id=?," +
		"	@auto_commit_flag=?," +
		"	@multi_value_field_separator=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_Batch!=null)
		{
			m_Batch.save(conn);
			s_batch_id = m_Batch.s_batch_id;
		}
		
		if (s_import_id == null) return 1;
		
		if (m_FieldsMappings!=null)
		{
			FieldsMappings fms = new FieldsMappings();
			fms.s_import_id = s_import_id;
			if(fms.retrieve(conn) > 0) fms.delete(conn);
		}

		if (m_ImportNewsletters!=null)
		{
			ImportNewsletters ins = new ImportNewsletters();
			ins.s_import_id = s_import_id;
			if(ins.retrieve(conn) > 0) ins.delete(conn);
		}

		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_import_id);
		pstmt.setString(2, s_batch_id);
		if(s_import_name == null) pstmt.setString(3, s_import_name);
		else pstmt.setBytes(3, s_import_name.getBytes("UTF-8"));
		pstmt.setString(4, s_status_id);
		pstmt.setString(5, s_import_date);
		if(s_field_separator == null) pstmt.setString(6, s_field_separator);
		else pstmt.setBytes(6, s_field_separator.getBytes("UTF-8"));
		pstmt.setString(7, s_first_row);
		if(s_import_file == null) pstmt.setString(8, s_import_file);
		else pstmt.setBytes(8, s_import_file.getBytes("UTF-8"));
		pstmt.setString(9, s_upd_rule_id);
		if(s_import_url == null) pstmt.setString(10, s_import_url);
		else pstmt.setBytes(10, s_import_url.getBytes("UTF-8"));
		pstmt.setString(11, s_full_name_flag);
		pstmt.setString(12, s_email_type_flag);
		pstmt.setString(13, s_type_id);
		pstmt.setString(14, s_upd_hierarchy_id);
		pstmt.setString(15, s_auto_commit_flag);
		if(s_multi_value_field_separator == null) pstmt.setString(16, s_multi_value_field_separator);
		else pstmt.setBytes(16, s_multi_value_field_separator.getBytes("UTF-8"));

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
		if (m_FieldsMappings!=null)
		{
			m_FieldsMappings.s_import_id = s_import_id;
			m_FieldsMappings.save(conn);
		}

		if (m_ImportNewsletters!=null)
		{
			m_ImportNewsletters.s_import_id = s_import_id;
			m_ImportNewsletters.save(conn);
		}

		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cupd_import" +
		" WHERE" +
		"	(import_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_FieldsMappings!=null) m_FieldsMappings.delete(conn);
		if(m_ImportNewsletters!=null) m_ImportNewsletters.delete(conn);		
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_import_id);
		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_Batch!=null) m_Batch.delete(conn);
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "import";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_import_id != null ) XmlUtil.appendTextChild(e, "import_id", s_import_id);
		if( s_batch_id != null ) XmlUtil.appendTextChild(e, "batch_id", s_batch_id);
		if( s_import_name != null ) XmlUtil.appendCDataChild(e, "import_name", s_import_name);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_import_date != null ) XmlUtil.appendTextChild(e, "import_date", s_import_date);
		if( s_field_separator != null ) XmlUtil.appendCDataChild(e, "field_separator", s_field_separator);
		if( s_first_row != null ) XmlUtil.appendTextChild(e, "first_row", s_first_row);
		if( s_import_file != null ) XmlUtil.appendCDataChild(e, "import_file", s_import_file);
		if( s_upd_rule_id != null ) XmlUtil.appendTextChild(e, "upd_rule_id", s_upd_rule_id);
		if( s_import_url != null ) XmlUtil.appendCDataChild(e, "import_url", s_import_url);
		if( s_full_name_flag != null ) XmlUtil.appendTextChild(e, "full_name_flag", s_full_name_flag);
		if( s_email_type_flag != null ) XmlUtil.appendTextChild(e, "email_type_flag", s_email_type_flag);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_upd_hierarchy_id != null ) XmlUtil.appendTextChild(e, "upd_hierarchy_id", s_upd_hierarchy_id);
		if( s_auto_commit_flag != null ) XmlUtil.appendTextChild(e, "auto_commit_flag", s_auto_commit_flag);
		if( s_multi_value_field_separator != null ) XmlUtil.appendCDataChild(e, "multi_value_field_separator", s_multi_value_field_separator);
	}

	public void appendParentsToXml(Element e)
	{
		if (m_Batch != null) appendChild(e, m_Batch);
	}
	
	public void appendChildrenToXml(Element e)
	{
		if (m_FieldsMappings != null) appendChild(e, m_FieldsMappings);
		if (m_ImportNewsletters != null) appendChild(e, m_ImportNewsletters);
	}
	
	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_import_id = XmlUtil.getChildTextValue(e, "import_id");
		s_batch_id = XmlUtil.getChildTextValue(e, "batch_id");
		s_import_name = XmlUtil.getChildCDataValue(e, "import_name");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_import_date = XmlUtil.getChildTextValue(e, "import_date");
		s_field_separator = XmlUtil.getChildCDataValue(e, "field_separator");
		s_first_row = XmlUtil.getChildTextValue(e, "first_row");
		s_import_file = XmlUtil.getChildCDataValue(e, "import_file");
		s_upd_rule_id = XmlUtil.getChildTextValue(e, "upd_rule_id");
		s_import_url = XmlUtil.getChildCDataValue(e, "import_url");
		s_full_name_flag = XmlUtil.getChildTextValue(e, "full_name_flag");
		s_email_type_flag = XmlUtil.getChildTextValue(e, "email_type_flag");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_upd_hierarchy_id = XmlUtil.getChildTextValue(e, "upd_hierarchy_id");
		s_auto_commit_flag = XmlUtil.getChildTextValue(e, "auto_commit_flag");
		s_multi_value_field_separator = XmlUtil.getChildCDataValue(e, "multi_value_field_separator");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eBatch = XmlUtil.getChildByName(e, "batch");
		if(eBatch != null) m_Batch = new Batch(eBatch);
	}
	
	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eFieldsMappings = XmlUtil.getChildByName(e, "fields_mappings");
		if(eFieldsMappings != null) m_FieldsMappings = new FieldsMappings(eFieldsMappings);

		Element eImportNewsletters = XmlUtil.getChildByName(e, "import_newsletters");
		if(eImportNewsletters != null) m_ImportNewsletters = new ImportNewsletters(eImportNewsletters);
	}

	// === Other Methods ===
}
