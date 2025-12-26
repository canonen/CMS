package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImportTemplate extends BriteObject
{
	// === Properties ===

	public String s_template_id = null;
	public String s_type_id = null;
	public String s_batch_id = null;
	public String s_first_row = null;
	public String s_field_separator = null;
	public String s_multi_value_field_separator = null;	
	public String s_auto_commit_flag = null;
	public String s_upd_rule_id = null;
	public String s_upd_hierarchy_id = null;	
	public String s_full_name_flag = null;
	public String s_email_type_flag = null;
	public String s_name_import_as_file_flag = null;
	public String s_filter_per_import_flag = null;
	public String s_template_name = null;
	private static Logger loggre = Logger.getLogger(ImportTemplate.class.getName());

	// === Parents ===

	public Batch m_Batch = null;

	// === Children ===

	public ImportTemplateAttrs m_ImportTemplateAttrs = null;

	// === Constructors ===

	public ImportTemplate()
	{
	}
	
	public ImportTemplate(String sTemplateId) throws Exception
	{
		s_template_id = sTemplateId;
		retrieve();
	}

	public ImportTemplate(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	template_id," +
		"	type_id," +
		"	batch_id," +
		"	first_row," +
		"	field_separator," +
		"	upd_rule_id," +
		"	full_name_flag," +
		"	email_type_flag," +
		"	upd_hierarchy_id," +
		"	auto_commit_flag," +
		"	multi_value_field_separator," +
		"	name_import_as_file_flag," +
		"	filter_per_import_flag," +
		"	template_name" +
		" FROM cupd_import_template" +
		" WHERE" +
		"	(template_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_template_id);

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
		s_template_id = rs.getString(1);
		s_type_id = rs.getString(2);
		s_batch_id = rs.getString(3);
		s_first_row = rs.getString(4);
		b = rs.getBytes(5);
		s_field_separator = (b == null)?null:new String(b,"UTF-8");
		s_upd_rule_id = rs.getString(6);
		s_full_name_flag = rs.getString(7);
		s_email_type_flag = rs.getString(8);
		s_upd_hierarchy_id = rs.getString(9);
		s_auto_commit_flag = rs.getString(10);
		b = rs.getBytes(11);
		s_multi_value_field_separator = (b == null)?null:new String(b,"UTF-8");
		s_name_import_as_file_flag = rs.getString(12);
		s_filter_per_import_flag = rs.getString(13);
		b = rs.getBytes(14);
		s_template_name = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cupd_import_template_save" +
		"	@template_id=?," +
		"	@type_id=?," +
		"	@batch_id=?," +
		"	@first_row=?," +
		"	@field_separator=?," +
		"	@upd_rule_id=?," +
		"	@full_name_flag=?," +
		"	@email_type_flag=?," +
		"	@upd_hierarchy_id=?," +
		"	@auto_commit_flag=?," +
		"	@multi_value_field_separator=?,"+
		"	@name_import_as_file_flag=?," +
		"	@filter_per_import_flag=?," +
		"	@template_name=?";
		
	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_Batch!=null)
		{
			m_Batch.save(conn);
			s_batch_id = m_Batch.s_batch_id;
		}
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_template_id);
		pstmt.setString(2, s_type_id);
		pstmt.setString(3, s_batch_id);
		pstmt.setString(4, s_first_row);
		if(s_field_separator == null) pstmt.setString(5, s_field_separator);
		else pstmt.setBytes(5, s_field_separator.getBytes("UTF-8"));
		pstmt.setString(6, s_upd_rule_id);
		pstmt.setString(7, s_full_name_flag);
		pstmt.setString(8, s_email_type_flag);
		pstmt.setString(9, s_upd_hierarchy_id);
		pstmt.setString(10, s_auto_commit_flag);
		if(s_multi_value_field_separator == null) pstmt.setString(11, s_multi_value_field_separator);
		else pstmt.setBytes(11, s_multi_value_field_separator.getBytes("UTF-8"));
		pstmt.setString(12, s_name_import_as_file_flag);
		pstmt.setString(13, s_filter_per_import_flag);
		if(s_template_name == null) pstmt.setString(14, s_template_name);
		else pstmt.setBytes(14, s_template_name.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_template_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_ImportTemplateAttrs != null)
		{
			m_ImportTemplateAttrs.s_template_id = s_template_id;
					
			String sSql =
				" DELETE cupd_import_template_attr" +
				" WHERE template_id=" + s_template_id;

			BriteUpdate.executeUpdate(sSql);
			m_ImportTemplateAttrs.save(conn);
		}

		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cupd_import_template" +
		" WHERE" +
		"	(template_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if (m_ImportTemplateAttrs != null)
		{
			String sSql =
				" DELETE cupd_import_tempalte_attr" +
				" WHERE template_id=" + m_ImportTemplateAttrs.s_template_id;

			BriteUpdate.executeUpdate(sSql);
			//m_ImportTemplateAttrs.delete(conn);
		}
		/*
		if(m_FtpImportFile != null) m_FtpImportFile.delete(conn);
		if(m_FtpImportSchedule != null) m_FtpImportSchedule.delete(conn);		
		*/
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_template_id);
		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_Batch!=null) m_Batch.delete(conn);
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "import_template";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_template_id != null ) XmlUtil.appendTextChild(e, "template_id", s_template_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_batch_id != null ) XmlUtil.appendTextChild(e, "batch_id", s_batch_id);
		if( s_first_row != null ) XmlUtil.appendTextChild(e, "first_row", s_first_row);
		if( s_field_separator != null ) XmlUtil.appendCDataChild(e, "field_separator", s_field_separator);
		if( s_upd_rule_id != null ) XmlUtil.appendTextChild(e, "upd_rule_id", s_upd_rule_id);
		if( s_full_name_flag != null ) XmlUtil.appendTextChild(e, "full_name_flag", s_full_name_flag);
		if( s_email_type_flag != null ) XmlUtil.appendTextChild(e, "email_type_flag", s_email_type_flag);
		if( s_upd_hierarchy_id != null ) XmlUtil.appendTextChild(e, "upd_hierarchy_id", s_upd_hierarchy_id);
		if( s_auto_commit_flag != null ) XmlUtil.appendTextChild(e, "auto_commit_flag", s_auto_commit_flag);
		if( s_multi_value_field_separator != null ) XmlUtil.appendCDataChild(e, "multi_value_field_separator", s_multi_value_field_separator);
		if( s_name_import_as_file_flag != null ) XmlUtil.appendCDataChild(e, "name_import_as_file_flag", s_name_import_as_file_flag);
		if( s_filter_per_import_flag != null ) XmlUtil.appendCDataChild(e, "filter_per_import_flag", s_filter_per_import_flag);
		if( s_template_name != null ) XmlUtil.appendCDataChild(e, "template_name", s_template_name);		
	}

	public void appendParentsToXml(Element e)
	{
		if (m_Batch != null) appendChild(e, m_Batch);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_ImportTemplateAttrs != null) appendChild(e, m_ImportTemplateAttrs);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_template_id = XmlUtil.getChildTextValue(e, "template_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_batch_id = XmlUtil.getChildTextValue(e, "batch_id");
		s_first_row = XmlUtil.getChildTextValue(e, "first_row");
		s_field_separator = XmlUtil.getChildCDataValue(e, "field_separator");
		s_upd_rule_id = XmlUtil.getChildTextValue(e, "upd_rule_id");
		s_full_name_flag = XmlUtil.getChildTextValue(e, "full_name_flag");
		s_email_type_flag = XmlUtil.getChildTextValue(e, "email_type_flag");
		s_upd_hierarchy_id = XmlUtil.getChildTextValue(e, "upd_hierarchy_id");
		s_auto_commit_flag = XmlUtil.getChildTextValue(e, "auto_commit_flag");
		s_multi_value_field_separator = XmlUtil.getChildCDataValue(e, "multi_value_field_separator");
		s_name_import_as_file_flag = XmlUtil.getChildCDataValue(e, "name_import_as_file_flag");		
		s_filter_per_import_flag = XmlUtil.getChildCDataValue(e, "filter_per_import_flag");		
		s_template_name = XmlUtil.getChildCDataValue(e, "template_name");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eBatch = XmlUtil.getChildByName(e, "batch");
		if(eBatch != null) m_Batch = new Batch(eBatch);
	}
	
	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eImportTemplateAttrs = XmlUtil.getChildByName(e, "import_template_attrs");
		if(eImportTemplateAttrs != null)
			m_ImportTemplateAttrs = new ImportTemplateAttrs(eImportTemplateAttrs);
	}

	// === Other Methods ===
}


