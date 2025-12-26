package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class EntityAttr extends BriteObject
{
	// === Properties ===

	public String s_attr_id = null;
	public String s_entity_id = null;
	public String s_type_id = null;
	public String s_attr_name = null;
	public String s_scope_id = null;
	public String s_internal_id_flag = null;
	public String s_fingerprint_seq = null;
	//log4j implementation
	private static Logger logger = Logger.getLogger(EntityAttr.class.getName());
	// === Parents ===

	  // Delete this part if you do not intend to use parents.
	  // public Entity m_Entity = null;
	  // public Scope m_Scope = null;

	// === Children ===

	  // Delete this part if you do not intend to use children.

	// === Constructors ===

	public EntityAttr()
	{
	}
	
	public EntityAttr(String sAttrId) throws Exception
	{
		s_attr_id = sAttrId;
		retrieve();
	}

	public EntityAttr(Element e) throws Exception
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
		"	attr_id," +
		"	entity_id," +
		"	type_id," +
		"	attr_name," +
		"	scope_id," +
		"	internal_id_flag," +
		"	fingerprint_seq" +
		" FROM sntt_entity_attr" +
		" WHERE" +
		"	(attr_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_attr_id);

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
		s_attr_id = rs.getString(1);
		s_entity_id = rs.getString(2);
		s_type_id = rs.getString(3);
		b = rs.getBytes(4);
		s_attr_name = (b == null)?null:new String(b,"UTF-8");
		s_scope_id = rs.getString(5);
		s_internal_id_flag = rs.getString(6);
		s_fingerprint_seq = rs.getString(7);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sntt_entity_attr_save" +
		"	@attr_id=?," +
		"	@entity_id=?," +
		"	@type_id=?," +
		"	@attr_name=?," +
		"	@scope_id=?," +
		"	@internal_id_flag=?," +
		"	@fingerprint_seq=?";

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

		pstmt.setString(1, s_attr_id);
		pstmt.setString(2, s_entity_id);
		pstmt.setString(3, s_type_id);
		if(s_attr_name == null) pstmt.setString(4, s_attr_name);
		else pstmt.setBytes(4, s_attr_name.getBytes("UTF-8"));
		pstmt.setString(5, s_scope_id);
		pstmt.setString(6, s_internal_id_flag);
		pstmt.setString(7, s_fingerprint_seq);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_attr_id = rs.getString(1);

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
		" DELETE FROM sntt_entity_attr" +
		" WHERE" +
		"	(attr_id=?)";

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
		pstmt.setString(1, s_attr_id);

		return pstmt.executeUpdate();
	}

	// Delete parents here or remove this method if you do not need it.
	// public int deleteParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.delete(conn);
	//	return 1;
	// }

	
	// === XML Methods ===

	public String m_sMainElementName = "entity_attr";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_entity_id != null ) XmlUtil.appendTextChild(e, "entity_id", s_entity_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_attr_name != null ) XmlUtil.appendCDataChild(e, "attr_name", s_attr_name);
		if( s_scope_id != null ) XmlUtil.appendTextChild(e, "scope_id", s_scope_id);
		if( s_internal_id_flag != null ) XmlUtil.appendTextChild(e, "internal_id_flag", s_internal_id_flag);
		if( s_fingerprint_seq != null ) XmlUtil.appendTextChild(e, "fingerprint_seq", s_fingerprint_seq);
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
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_entity_id = XmlUtil.getChildTextValue(e, "entity_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_attr_name = XmlUtil.getChildCDataValue(e, "attr_name");
		s_scope_id = XmlUtil.getChildTextValue(e, "scope_id");
		s_internal_id_flag = XmlUtil.getChildTextValue(e, "internal_id_flag");
		s_fingerprint_seq = XmlUtil.getChildTextValue(e, "fingerprint_seq");
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


