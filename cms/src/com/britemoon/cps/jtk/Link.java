package com.britemoon.cps.jtk;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.ntt.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Link extends BriteObject
{
	// === Properties ===

	public String s_link_id = null;
	public String s_link_name = null;
	public String s_cust_id = null;
	public String s_origin_link_id = null;
	public String s_cont_id = null;
	public String s_href = null;
	public String s_camp_id = null;
	public String s_entity_id = null;
	private static Logger logger = Logger.getLogger(Link.class.getName());

	// === Parents ===

	// === Children ===

	public EntityImportLinkAttrs m_EntityImportLinkAttrs = null;

	// === Constructors ===

	public Link()
	{
	}
	
	public Link(String sLinkId) throws Exception
	{
		s_link_id = sLinkId;
		retrieve();
	}

	public Link(Element e) throws Exception
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
		"	link_id," +
		"	link_name," +
		"	cust_id," +
		"	origin_link_id," +
		"	cont_id," +
		"	href," +
		"	camp_id," +
		"	entity_id" +
		" FROM cjtk_link" +
		" WHERE" +
		"	(link_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_link_id);

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
		s_link_id = rs.getString(1);
		b = rs.getBytes(2);
		s_link_name = (b == null)?null:new String(b,"UTF-8");
		s_cust_id = rs.getString(3);
		s_origin_link_id = rs.getString(4);
		s_cont_id = rs.getString(5);
		b = rs.getBytes(6);
		s_href = (b == null)?null:new String(b,"UTF-8");
		s_camp_id = rs.getString(7);
		s_entity_id = rs.getString(8);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cjtk_link_save" +
		"	@link_id=?," +
		"	@link_name=?," +
		"	@cust_id=?," +
		"	@origin_link_id=?," +
		"	@cont_id=?," +
		"	@href=?," +
		"	@camp_id=?," +
		"	@entity_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_link_id);
		if(s_link_name == null) pstmt.setString(2, s_link_name);
		else pstmt.setBytes(2, s_link_name.getBytes("UTF-8"));
		pstmt.setString(3, s_cust_id);
		pstmt.setString(4, s_origin_link_id);
		pstmt.setString(5, s_cont_id);
		if(s_href == null) pstmt.setString(6, s_href);
		else pstmt.setBytes(6, s_href.getBytes("UTF-8"));
		pstmt.setString(7, s_camp_id);
		pstmt.setString(8, s_entity_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_link_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if(m_EntityImportLinkAttrs != null)
		{
			String sSql = 
				" DELETE cntt_entity_import_link_attr WHERE link_id = " + s_link_id;
			BriteUpdate.executeUpdate(sSql);
			
			m_EntityImportLinkAttrs.s_link_id = s_link_id;
			m_EntityImportLinkAttrs.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cjtk_link" +
		" WHERE" +
		"	(link_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_EntityImportLinkAttrs != null) m_EntityImportLinkAttrs.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_link_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "link";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_link_id != null ) XmlUtil.appendTextChild(e, "link_id", s_link_id);
		if( s_link_name != null ) XmlUtil.appendCDataChild(e, "link_name", s_link_name);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_origin_link_id != null ) XmlUtil.appendTextChild(e, "origin_link_id", s_origin_link_id);
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
		if( s_href != null ) XmlUtil.appendCDataChild(e, "href", s_href);
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_entity_id != null ) XmlUtil.appendTextChild(e, "entity_id", s_entity_id);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_EntityImportLinkAttrs != null) appendChild(e, m_EntityImportLinkAttrs);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_link_id = XmlUtil.getChildTextValue(e, "link_id");
		s_link_name = XmlUtil.getChildCDataValue(e, "link_name");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_origin_link_id = XmlUtil.getChildTextValue(e, "origin_link_id");
		s_cont_id = XmlUtil.getChildTextValue(e, "cont_id");
		s_href = XmlUtil.getChildCDataValue(e, "href");
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_entity_id = XmlUtil.getChildTextValue(e, "entity_id");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eEntityImportLinkAttrs = XmlUtil.getChildByName(e, "entity_import_link_attrs");
		if(eEntityImportLinkAttrs != null)
			m_EntityImportLinkAttrs = new EntityImportLinkAttrs(eEntityImportLinkAttrs);
	}

	// === Other Methods ===
}
