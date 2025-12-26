package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class Entity extends BriteObject
{
	// === Properties ===

	public String s_entity_id = null;
	public String s_cust_id = null;
	public String s_entity_name = null;
	public String s_scope_id = null;
	//log4j implementation
	private static Logger logger = Logger.getLogger(Entity.class.getName());
	// === Parents ===

	// === Children ===

	public EntityAttrs m_EntityAttrs = null;

	// === Constructors ===

	public Entity()
	{
	}
	
	public Entity(String sEntityId) throws Exception
	{
		s_entity_id = sEntityId;
		retrieve();
	}

	public Entity(Element e) throws Exception
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
		"	entity_id," +
		"	cust_id," +
		"	entity_name," +
		"	scope_id" +
		" FROM sntt_entity" +
		" WHERE" +
		"	(entity_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_entity_id);

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
		s_entity_id = rs.getString(1);
		s_cust_id = rs.getString(2);
		b = rs.getBytes(3);
		s_entity_name = (b == null)?null:new String(b,"UTF-8");
		s_scope_id = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sntt_entity_save" +
		"	@entity_id=?," +
		"	@cust_id=?," +
		"	@entity_name=?," +
		"	@scope_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_entity_id);
		pstmt.setString(2, s_cust_id);
		if(s_entity_name == null) pstmt.setString(3, s_entity_name);
		else pstmt.setBytes(3, s_entity_name.getBytes("UTF-8"));
		pstmt.setString(4, s_scope_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_entity_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_EntityAttrs!=null)
		{
			m_EntityAttrs.s_entity_id = s_entity_id;
			m_EntityAttrs.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sntt_entity" +
		" WHERE" +
		"	(entity_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_EntityAttrs!=null) m_EntityAttrs.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_entity_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "entity";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_entity_id != null ) XmlUtil.appendTextChild(e, "entity_id", s_entity_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_entity_name != null ) XmlUtil.appendCDataChild(e, "entity_name", s_entity_name);
		if( s_scope_id != null ) XmlUtil.appendTextChild(e, "scope_id", s_scope_id);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_EntityAttrs != null) appendChild(e, m_EntityAttrs);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_entity_id = XmlUtil.getChildTextValue(e, "entity_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_entity_name = XmlUtil.getChildCDataValue(e, "entity_name");
		s_scope_id = XmlUtil.getChildTextValue(e, "scope_id");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eEntityAttrs = XmlUtil.getChildByName(e, "entity_attrs");
		if(eEntityAttrs != null) m_EntityAttrs = new EntityAttrs(eEntityAttrs);
	}

	// === Other Methods ===
}


