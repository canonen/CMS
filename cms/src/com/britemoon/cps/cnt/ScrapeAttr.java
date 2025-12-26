package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeAttr extends BriteObject
{
	// === Properties ===

// s_url_id
// s_entry_id
// s_attr_name
// s_attr_value

	public String s_url_id = null;
	public String s_entry_id = null;
	public String s_attr_name = null;
	public String s_attr_value = null;
	private static Logger logger = Logger.getLogger(ScrapeAttr.class.getName());

	// === Parents ===
	// === Constructors ===

	public ScrapeAttr()
	{
	}
	
	public ScrapeAttr(String sUrlId, String sEntryId, String sAttrName) throws Exception
	{
		s_url_id = sUrlId;
		s_entry_id = sEntryId;
		s_attr_name = sAttrName;
		retrieve();
	}

	public ScrapeAttr(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	url_id," +
		"	entry_id," +
		"	attr_name," +
		"	attr_value" +
		" FROM ccnt_scrape_attr" +
		" WHERE" +
		"	(url_id=?)" +
		"	AND (entry_id=?)" +
		"	AND (attr_name=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_url_id);
		pstmt.setString(2, s_entry_id);
		if(s_attr_name == null) pstmt.setString(3, s_attr_name);
		else pstmt.setBytes(3, s_attr_name.getBytes("UTF-8"));

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
		s_url_id = rs.getString(1);
		s_entry_id = rs.getString(2);
		b = rs.getBytes(3);
		s_attr_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_attr_value = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_scrape_attr_save" +
		"	@url_id=?," +
		"	@entry_id=?," +
		"	@attr_name=?," +
		"	@attr_value=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_url_id);
		pstmt.setString(2, s_entry_id);
		if(s_attr_name == null) pstmt.setString(3, s_attr_name);
		else pstmt.setBytes(3, s_attr_name.getBytes("UTF-8"));
		if(s_attr_value == null) pstmt.setString(4, s_attr_value);
		else pstmt.setBytes(4, s_attr_value.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_url_id = rs.getString(1);
			s_entry_id = rs.getString(2);
			b = rs.getBytes(3);
			s_attr_name = (b == null)?null:new String(b,"UTF-8");

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_scrape_attr" +
		" WHERE" +
		"	(url_id=?)" +
		"	AND (entry_id=?)" +
		"	AND (attr_name=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_url_id);
		pstmt.setString(2, s_entry_id);
		if(s_attr_name == null) pstmt.setString(3, s_attr_name);
		else pstmt.setBytes(3, s_attr_name.getBytes("UTF-8"));

		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "scrape_attr";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_url_id != null ) XmlUtil.appendTextChild(e, "url_id", s_url_id);
		if( s_entry_id != null ) XmlUtil.appendTextChild(e, "entry_id", s_entry_id);
		if( s_attr_name != null ) XmlUtil.appendCDataChild(e, "attr_name", s_attr_name);
		if( s_attr_value != null ) XmlUtil.appendCDataChild(e, "attr_value", s_attr_value);
	}

	public void appendParentsToXml(Element e)
	{
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_url_id = XmlUtil.getChildTextValue(e, "url_id");
		s_entry_id = XmlUtil.getChildTextValue(e, "entry_id");
		s_attr_name = XmlUtil.getChildCDataValue(e, "s_attr_name");
		s_attr_value = XmlUtil.getChildCDataValue(e, "s_attr_value");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
	}
	
	// === Other Methods ===
}


