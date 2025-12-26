package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Scrape extends BriteObject
{
	// === Properties ===

// s_scrape_id
// s_scrape_name
// s_status_id
// s_cust_id
// s_scrape_date
// s_num_entries
// s_num_urls

	public String s_scrape_id = null;
	public String s_scrape_name = null;
	public String s_status_id = null;
	public String s_cust_id = null;
	public String s_scrape_date = null;
	public String s_num_entries = null;
	public String s_num_urls = null;
	public String s_base_url = null;
	private static Logger logger = Logger.getLogger(Scrape.class.getName());

	// === Parents ===

	// === Children ===

	public ScrapeTags m_ScrapeTags = null;
	public ScrapeUrls m_ScrapeUrls = null;
	public ScrapeFormats m_ScrapeFormats = null;

	// === Constructors ===

	public Scrape()
	{
	}
	
	public Scrape(String sScrapeId) throws Exception
	{
		s_scrape_id = sScrapeId;
		retrieve();
	}

	public Scrape(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	scrape_id," +
		"	scrape_name," +
		"	status_id," +
		"	cust_id," +
		"	scrape_date," +
		"	num_entries," +
		"	num_urls," +
		"	base_url" +
		" FROM ccnt_scrape" +
		" WHERE" +
		"	(scrape_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_scrape_id);

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
		b = rs.getBytes(2);
		s_scrape_name = (b == null)?null:new String(b,"UTF-8");
		s_status_id = rs.getString(3);
		s_cust_id = rs.getString(4);
		s_scrape_date = rs.getString(5);
		s_num_entries = rs.getString(6);
		s_num_urls = rs.getString(7);
		s_base_url = rs.getString(8);
	}
	
	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_scrape_save" +
		"	@scrape_id=?," +
		"	@scrape_name=?," +
		"	@status_id=?," +
		"	@cust_id=?," +
		"	@scrape_date=?," +
		"	@num_entries=?," +
		"	@num_urls=?," +
		"	@base_url=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		// this has nothing in common with "parents" but
		// delete all old content parts		
		// (that is relations between this and child contents
		// but not child contents themselvs as they can participate other contents)
		// should be executed before saving new content parts
		// it could be done in saveChildren
		// but deleting them here will simplify cycle refernce check in content tree

		if (s_scrape_id == null) return 1;
		
		if (m_ScrapeTags != null)
		{
			ScrapeTags tags = new ScrapeTags();
			tags.s_scrape_id = s_scrape_id;
			if(tags.retrieve(conn) > 0) tags.delete(conn);
		}

		if (m_ScrapeUrls != null)
		{
			ScrapeUrls urls = new ScrapeUrls();
			urls.s_scrape_id = s_scrape_id;
			if(urls.retrieve(conn) > 0) urls.delete(conn);
		}

		if (m_ScrapeFormats != null)
		{
			ScrapeFormats formats = new ScrapeFormats();
			formats.s_scrape_id = s_scrape_id;
			if(formats.retrieve(conn) > 0) formats.delete(conn);
		}

		return 1;
	 }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_scrape_id);
		if(s_scrape_name == null) pstmt.setString(2, s_scrape_name);
		else pstmt.setBytes(2, s_scrape_name.getBytes("UTF-8"));
		pstmt.setString(3, s_status_id);
		pstmt.setString(4, s_cust_id);
		pstmt.setString(5, s_scrape_date);
		pstmt.setString(6, s_num_entries);
		pstmt.setString(7, s_num_urls);
		pstmt.setString(8, s_base_url);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_scrape_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	 public int saveChildren(Connection conn) throws Exception
	 {
		 if (m_ScrapeTags != null)
		 {
		 	m_ScrapeTags.s_scrape_id = s_scrape_id;
		 	m_ScrapeTags.save(conn);
		 }

		 if (m_ScrapeUrls != null)
		 {
		 	m_ScrapeUrls.s_scrape_id = s_scrape_id;
		 	m_ScrapeUrls.save(conn);
		 }

		if (m_ScrapeFormats != null)
		{
			m_ScrapeFormats.s_scrape_id = s_scrape_id;
			m_ScrapeFormats.save(conn);
		}
		return 1;
	 }

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_scrape" +
		" WHERE" +
		"	(scrape_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if (m_ScrapeTags!=null) m_ScrapeTags.delete(conn);
		if (m_ScrapeUrls!=null) m_ScrapeUrls.delete(conn);
		if (m_ScrapeFormats!=null) m_ScrapeFormats.delete(conn);		
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_scrape_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_scrape_id != null ) XmlUtil.appendTextChild(e, "scrape_id", s_scrape_id);
		if( s_scrape_name != null ) XmlUtil.appendCDataChild(e, "scrape_name", s_scrape_name);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_scrape_date != null ) XmlUtil.appendCDataChild(e, "scrape_date", s_scrape_date);
		if( s_num_entries != null ) XmlUtil.appendTextChild(e, "num_entries", s_num_entries);
		if( s_num_urls != null ) XmlUtil.appendTextChild(e, "num_urls", s_num_urls);
		if( s_base_url != null ) XmlUtil.appendTextChild(e, "base_url", s_base_url);
	}
	
	public void appendChildrenToXml(Element e)
	{
		if (m_ScrapeTags != null) appendChild(e, m_ScrapeTags);
		if (m_ScrapeUrls != null) appendChild(e, m_ScrapeUrls);
		if (m_ScrapeFormats != null) appendChild(e, m_ScrapeFormats);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_scrape_id = XmlUtil.getChildTextValue(e, "scrape_id");
		s_scrape_name = XmlUtil.getChildCDataValue(e, "scrape_name");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_scrape_date = XmlUtil.getChildCDataValue(e, "scrape_date");
		s_num_entries = XmlUtil.getChildTextValue(e, "num_entries");
		s_num_urls = XmlUtil.getChildTextValue(e, "num_urls");
		s_base_url = XmlUtil.getChildTextValue(e, "base_url");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eScrapeTags = XmlUtil.getChildByName(e, "scrape_tags");
		if(eScrapeTags != null) m_ScrapeTags = new ScrapeTags(eScrapeTags);

		Element eScrapeUrls = XmlUtil.getChildByName(e, "scrape_urls");
		if(eScrapeUrls != null) m_ScrapeUrls = new ScrapeUrls(eScrapeUrls);

		Element eScrapeFormats = XmlUtil.getChildByName(e, "scrape_formats");
		if(eScrapeFormats != null) m_ScrapeFormats = new ScrapeFormats(eScrapeFormats);
	}

	// === Other Methods ===
}


