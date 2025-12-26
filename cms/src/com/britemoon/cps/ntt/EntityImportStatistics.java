package com.britemoon.cps.ntt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EntityImportStatistics extends BriteObject
{
	// === Properties ===

	public String s_import_id = null;
	public String s_total_rows = null;
	public String s_parsed_rows = null;
	public String s_not_parsable_rows = null;
	public String s_warning_rows = null;
	public String s_invalid_xml_chars = null;
	public String s_missed_fk_entities = null;
	public String s_bad_pk_entities = null;
	public String s_new_entities = null;
	public String s_old_entities = null;
	public String s_dup_entities = null;
	public String s_inserted_entities = null;
	public String s_updated_entities = null;
	public String s_error_msg = null;
	private static Logger logger = Logger.getLogger(EntityImportStatistics.class.getName());
	

	// === Parents ===

	  // Delete this part if you do not intend to use parents.
	  // public EntityImport m_EntityImport = null;

	// === Children ===

	  // Delete this part if you do not intend to use children.

	// === Constructors ===

	public EntityImportStatistics()
	{
	}
	
	public EntityImportStatistics(String sImportId) throws Exception
	{
		s_import_id = sImportId;
		retrieve();
	}

	public EntityImportStatistics(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	import_id," +
		"	total_rows," +
		"	parsed_rows," +
		"	not_parsable_rows," +
		"	warning_rows," +
		"	invalid_xml_chars," +
		"	missed_fk_entities," +
		"	bad_pk_entities," +
		"	new_entities," +
		"	old_entities," +
		"	dup_entities," +
		"	inserted_entities," +
		"	updated_entities," +
		"	error_msg" +
		" FROM cntt_entity_import_statistics" +
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
		s_total_rows = rs.getString(2);
		s_parsed_rows = rs.getString(3);
		s_not_parsable_rows = rs.getString(4);
		s_warning_rows = rs.getString(5);
		s_invalid_xml_chars = rs.getString(6);
		s_missed_fk_entities = rs.getString(7);
		s_bad_pk_entities = rs.getString(8);
		s_new_entities = rs.getString(9);
		s_old_entities = rs.getString(10);
		s_dup_entities = rs.getString(11);
		s_inserted_entities = rs.getString(12);
		s_updated_entities = rs.getString(13);
		b = rs.getBytes(14);
		s_error_msg = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cntt_entity_import_statistics_save" +
		"	@import_id=?," +
		"	@total_rows=?," +
		"	@parsed_rows=?," +
		"	@not_parsable_rows=?," +
		"	@warning_rows=?," +
		"	@invalid_xml_chars=?," +
		"	@missed_fk_entities=?," +
		"	@bad_pk_entities=?," +
		"	@new_entities=?," +
		"	@old_entities=?," +
		"	@dup_entities=?," +
		"	@inserted_entities=?," +
		"	@updated_entities=?," +
		"	@error_msg=?";

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

		pstmt.setString(1, s_import_id);
		pstmt.setString(2, s_total_rows);
		pstmt.setString(3, s_parsed_rows);
		pstmt.setString(4, s_not_parsable_rows);
		pstmt.setString(5, s_warning_rows);
		pstmt.setString(6, s_invalid_xml_chars);
		pstmt.setString(7, s_missed_fk_entities);
		pstmt.setString(8, s_bad_pk_entities);
		pstmt.setString(9, s_new_entities);
		pstmt.setString(10, s_old_entities);
		pstmt.setString(11, s_dup_entities);
		pstmt.setString(12, s_inserted_entities);
		pstmt.setString(13, s_updated_entities);
		
		if(s_error_msg == null) pstmt.setString(14, s_error_msg);
		else
		{
			s_error_msg = s_error_msg.substring(0,250);
			pstmt.setBytes(14, s_error_msg.getBytes("UTF-8"));
		}

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

	// Save children here or remove this method if you do not need it.	
	// public int saveChildren(Connection conn) throws Exception
	// {
	//
	//	//Fix ids before saving children if needed
	//
	//	if(m_Child!=null) m_Child.save(conn);
	//	return 1;
	// }

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cntt_entity_import_statistics" +
		" WHERE" +
		"	(import_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	// Methods delete() and delete(Connection conn) implemented in BriteObject
	// will call the following save(blah) methods like this:
	//
	//	deleteChildren(Connection conn);
	//	delete(PreparedStatement pstmt);
	//	deleteParents(Connection conn);

	// Delete children here or remove this method if you do not need it.
	// public int deleteChildren(Connection conn) throws Exception
	// {
	//	if(m_Child!=null) m_Child.delete(conn);
	//	return 1;
	// }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_import_id);

		return pstmt.executeUpdate();
	}

	// Delete parents here or remove this method if you do not need it.
	// public int deleteParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.delete(conn);
	//	return 1;
	// }

	
	// === XML Methods ===

	public String m_sMainElementName = "entity_import_statistics";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_import_id != null ) XmlUtil.appendTextChild(e, "import_id", s_import_id);
		if( s_total_rows != null ) XmlUtil.appendTextChild(e, "total_rows", s_total_rows);
		if( s_parsed_rows != null ) XmlUtil.appendTextChild(e, "parsed_rows", s_parsed_rows);
		if( s_not_parsable_rows != null ) XmlUtil.appendTextChild(e, "not_parsable_rows", s_not_parsable_rows);
		if( s_warning_rows != null ) XmlUtil.appendTextChild(e, "warning_rows", s_warning_rows);
		if( s_invalid_xml_chars != null ) XmlUtil.appendTextChild(e, "invalid_xml_chars", s_invalid_xml_chars);
		if( s_missed_fk_entities != null ) XmlUtil.appendTextChild(e, "missed_fk_entities", s_missed_fk_entities);
		if( s_bad_pk_entities != null ) XmlUtil.appendTextChild(e, "bad_pk_entities", s_bad_pk_entities);
		if( s_new_entities != null ) XmlUtil.appendTextChild(e, "new_entities", s_new_entities);
		if( s_old_entities != null ) XmlUtil.appendTextChild(e, "old_entities", s_old_entities);
		if( s_dup_entities != null ) XmlUtil.appendTextChild(e, "dup_entities", s_dup_entities);
		if( s_inserted_entities != null ) XmlUtil.appendTextChild(e, "inserted_entities", s_inserted_entities);
		if( s_updated_entities != null ) XmlUtil.appendTextChild(e, "updated_entities", s_updated_entities);
		if( s_error_msg != null ) XmlUtil.appendCDataChild(e, "error_msg", s_error_msg);
	}

	// Kill these parent - child methods
	// if they are not supposed to be in use.

	public void appendParentsToXml(Element e)
	{
		// if (m_Parent != null) appendChild(e, m_Parent);
	}
	
	public void appendChildrenToXml(Element e)
	{
		// if (m_Child != null) appendChild(e, m_Child);
	}
	
	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_import_id = XmlUtil.getChildTextValue(e, "import_id");
		s_total_rows = XmlUtil.getChildTextValue(e, "total_rows");
		s_parsed_rows = XmlUtil.getChildTextValue(e, "parsed_rows");
		s_not_parsable_rows = XmlUtil.getChildTextValue(e, "not_parsable_rows");
		s_warning_rows = XmlUtil.getChildTextValue(e, "warning_rows");
		s_invalid_xml_chars = XmlUtil.getChildTextValue(e, "invalid_xml_chars");
		s_missed_fk_entities = XmlUtil.getChildTextValue(e, "missed_fk_entities");
		s_bad_pk_entities = XmlUtil.getChildTextValue(e, "bad_pk_entities");
		s_new_entities = XmlUtil.getChildTextValue(e, "new_entities");
		s_old_entities = XmlUtil.getChildTextValue(e, "old_entities");
		s_dup_entities = XmlUtil.getChildTextValue(e, "dup_entities");
		s_inserted_entities = XmlUtil.getChildTextValue(e, "inserted_entities");
		s_updated_entities = XmlUtil.getChildTextValue(e, "updated_entities");
		s_error_msg = XmlUtil.getChildCDataValue(e, "error_msg");
	}

	// Kill these parent - child methods
	// if they are not supposed to be in use.

	public void getParentsFromXml(Element e) throws Exception
	{
		// Element eParent = XmlUtil.getChildByName(e, "parent_main_element_name");
		// if(eParent != null) m_Parent = new Parent(eParent);
	}
	
	public void getChildrenFromXml(Element e) throws Exception
	{
		// Element eChild = XmlUtil.getChildByName(e, "child_main_element_name");
		// if(eChild != null) m_Child = new Child(eChild);
	}

	// === Other Methods ===
}