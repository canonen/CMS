package com.britemoon.cps.ntt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EntityImportTemplate extends BriteObject
{
	// === Properties ===

	public String s_template_id = null;
	public String s_template_name = null;
	public String s_first_row = null;
	public String s_cust_id = null;
	public String s_entity_id = null;
	public String s_field_separator = null;
	private static Logger logger = Logger.getLogger(EntityImportTemplate.class.getName());	

	// === Parents ===

	  // Delete this part if you do not intend to use parents.
	  // public Customer m_Customer = null;

	// === Children ===

	  // Delete this part if you do not intend to use children.
	  // public FtpTaskImportTemplate(s) m_FtpTaskImportTemplate(s) = null;
	  // public EntityImport(s) m_EntityImport(s) = null;
	  
	public EntityImportTemplateAttrs m_EntityImportTemplateAttrs = null;

	// === Constructors ===

	public EntityImportTemplate()
	{
	}
	
	public EntityImportTemplate(String sTemplateId) throws Exception
	{
		s_template_id = sTemplateId;
		retrieve();
	}

	public EntityImportTemplate(Element e) throws Exception
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
		"	template_id," +
		"	template_name," +
		"	first_row," +
		"	cust_id," +
		"	entity_id," +
		"	field_separator" +
		" FROM cntt_entity_import_template" +
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
		b = rs.getBytes(2);
		s_template_name = (b == null)?null:new String(b,"UTF-8");
		s_first_row = rs.getString(3);
		s_cust_id = rs.getString(4);
		s_entity_id = rs.getString(5);
		b = rs.getBytes(6);
		s_field_separator = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cntt_entity_import_template_save" +
		"	@template_id=?," +
		"	@template_name=?," +
		"	@first_row=?," +
		"	@cust_id=?," +
		"	@entity_id=?," +
		"	@field_separator=?";

	public String getSaveSql() { return m_sSaveSql; }

	// Methods save() and save(Connection conn) implemented in BriteObject
	// will call the following save(blah) methods like this:
	//
	//	saveParents(Connection conn);
	//	saveProps(PreparedStatement pstmt);
	//	saveChildren(Connection conn);

	// Save parents here or remove this method if you do not need it.
	// public int saveParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.save(conn);
	//
	//	//Fix ids after saving parent if needed
	//
	//	return 1;
	// }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_template_id);
		if(s_template_name == null) pstmt.setString(2, s_template_name);
		else pstmt.setBytes(2, s_template_name.getBytes("UTF-8"));
		pstmt.setString(3, s_first_row);
		pstmt.setString(4, s_cust_id);
		pstmt.setString(5, s_entity_id);
		if(s_field_separator == null) pstmt.setString(6, s_field_separator);
		else pstmt.setBytes(6, s_field_separator.getBytes("UTF-8"));

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
		if (m_EntityImportTemplateAttrs != null)
		{
			m_EntityImportTemplateAttrs.s_template_id = s_template_id;
					
			String sSql =
				" DELETE cntt_entity_import_template_attr" +
				" WHERE template_id=" + s_template_id;

			BriteUpdate.executeUpdate(sSql);
			m_EntityImportTemplateAttrs.save(conn);
		}

		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cntt_entity_import_template" +
		" WHERE" +
		"	(template_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if (m_EntityImportTemplateAttrs != null)
		{
			String sSql =
				" DELETE cntt_entity_import_tempalte_attr" +
				" WHERE template_id=" + s_template_id;

			BriteUpdate.executeUpdate(sSql);
		}
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_template_id);
		return pstmt.executeUpdate();
	}

	// Delete parents here or remove this method if you do not need it.
	// public int deleteParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.delete(conn);
	//	return 1;
	// }
	
	// === XML Methods ===

	public String m_sMainElementName = "entity_import_template";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_template_id != null ) XmlUtil.appendTextChild(e, "template_id", s_template_id);
		if( s_template_name != null ) XmlUtil.appendCDataChild(e, "template_name", s_template_name);
		if( s_first_row != null ) XmlUtil.appendTextChild(e, "first_row", s_first_row);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_entity_id != null ) XmlUtil.appendTextChild(e, "entity_id", s_entity_id);
		if( s_field_separator != null ) XmlUtil.appendCDataChild(e, "field_separator", s_field_separator);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_EntityImportTemplateAttrs != null) appendChild(e, m_EntityImportTemplateAttrs);
	}
	
	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_template_id = XmlUtil.getChildTextValue(e, "template_id");
		s_template_name = XmlUtil.getChildCDataValue(e, "template_name");
		s_first_row = XmlUtil.getChildTextValue(e, "first_row");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_entity_id = XmlUtil.getChildTextValue(e, "entity_id");
		s_field_separator = XmlUtil.getChildCDataValue(e, "field_separator");
	}

	
	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eEntityImportTemplateAttrs = XmlUtil.getChildByName(e, "entity_import_template_attrs");
		if(eEntityImportTemplateAttrs != null)
			m_EntityImportTemplateAttrs = new EntityImportTemplateAttrs(eEntityImportTemplateAttrs);
	}

	// === Other Methods ===
}


