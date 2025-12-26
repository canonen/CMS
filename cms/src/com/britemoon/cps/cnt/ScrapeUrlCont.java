package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeUrlCont extends BriteObject
{
	// === Properties ===

// s_url_id
// s_format_id
// s_cont_id

	public String s_url_id = null;
	public String s_format_id = null;
	public String s_cont_id = null;
	private static Logger logger = Logger.getLogger(ScrapeUrlCont.class.getName());

	// === Parents ===
	// === Constructors ===

	public ScrapeUrlCont()
	{
	}

	public ScrapeUrlCont(String sUrlId, String sFormatId) throws Exception
	{
		s_url_id = sUrlId;
		s_format_id = sFormatId;
		retrieve();
	}

	public ScrapeUrlCont(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	url_id," +
		"	format_id," +
		"	cont_id" +
		" FROM ccnt_scrape_url_cont" +
		" WHERE" +
		"	(url_id=?)" +
		"	AND (format_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_url_id);
		pstmt.setString(2, s_format_id);

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
		s_url_id = rs.getString(1);
		s_format_id = rs.getString(2);
		s_cont_id = rs.getString(3);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_scrape_url_cont_save" +
		"	@url_id=?," +
		"	@format_id=?," +
		"	@cont_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_url_id);
		pstmt.setString(2, s_format_id);
		pstmt.setString(3, s_cont_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_url_id = rs.getString(1);
			s_format_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_scrape_url_cont" +
		" WHERE" +
		"	(url_id=?)" +
		"	AND (format_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_url_id);
		pstmt.setString(2, s_format_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_url_cont";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_url_id != null ) XmlUtil.appendTextChild(e, "url_id", s_url_id);
		if( s_format_id != null ) XmlUtil.appendTextChild(e, "format_id", s_format_id);
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
	}

	public void appendParentsToXml(Element e)
	{
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_url_id = XmlUtil.getChildTextValue(e, "url_id");
		s_format_id = XmlUtil.getChildTextValue(e, "format_id");
		s_cont_id = XmlUtil.getChildTextValue(e, "s_cont_id");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
	}
	
	// === Other Methods ===
}


