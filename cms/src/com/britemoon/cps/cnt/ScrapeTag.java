package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeTag extends BriteObject
{
	// === Properties ===

// s_scrape_id
// s_tag_id
// s_tag_name
// s_level

	public String s_scrape_id = null;
	public String s_tag_id = null;
	public String s_tag_name = null;
	public String s_level = null;
	private static Logger logger = Logger.getLogger(ScrapeTag.class.getName());

	// === Parents ===
	// === Constructors ===

	public ScrapeTag()
	{
	}

	public ScrapeTag(String sScrapeId, String sTagId) throws Exception
	{
		s_scrape_id = sScrapeId;
		s_tag_id = sTagId;
		retrieve();
	}

	public ScrapeTag(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	scrape_id," +
		"	tag_id," +
		"	tag_name," +
		"	level" +
		" FROM ccnt_scrape_tag" +
		" WHERE" +
		"	(scrape_id=?)" +
		"	AND (tag_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_scrape_id);
		pstmt.setString(2, s_tag_id);

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
		s_scrape_id = rs.getString(1);
		s_tag_id = rs.getString(2);
		b = rs.getBytes(3);
		s_tag_name = (b == null)?null:new String(b,"UTF-8");
		s_level = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_scrape_tag_save" +
		"	@scrape_id=?," +
		"	@tag_id=?," +
		"	@tag_name=?," +
		"	@level=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_scrape_id);
		pstmt.setString(2, s_tag_id);
		if(s_tag_name == null) pstmt.setString(3, s_tag_name);
		else pstmt.setBytes(3, s_tag_name.getBytes("UTF-8"));
		pstmt.setString(4, s_level);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_scrape_id = rs.getString(1);
			s_tag_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_scrape_tag" +
		" WHERE" +
		"	(scrape_id=?)" +
		"	AND (tag_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_scrape_id);
		pstmt.setString(2, s_tag_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_tag";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_scrape_id != null ) XmlUtil.appendTextChild(e, "scrape_id", s_scrape_id);
		if( s_tag_id != null ) XmlUtil.appendTextChild(e, "tag_id", s_tag_id);
		if( s_tag_name != null ) XmlUtil.appendCDataChild(e, "tag_name", s_tag_name);
		if( s_level != null ) XmlUtil.appendTextChild(e, "level", s_level);
	}

	public void appendParentsToXml(Element e)
	{
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_scrape_id = XmlUtil.getChildTextValue(e, "scrape_id");
		s_tag_id = XmlUtil.getChildTextValue(e, "tag_id");
		s_tag_name = XmlUtil.getChildCDataValue(e, "s_tag_name");
		s_level = XmlUtil.getChildTextValue(e, "s_level");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
	}
	
	// === Other Methods ===
}


