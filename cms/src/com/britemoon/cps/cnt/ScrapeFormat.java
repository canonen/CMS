package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ScrapeFormat extends BriteObject
{
	// === Properties ===

// s_format_id
// s_scrape_id
// s_format_name
// s_cont_text
// s_cont_html
// s_charset_id
// s_cont_id
// s_create_date
// s_modified_date

	public String s_format_id = null;
	public String s_scrape_id = null;
	public String s_format_name = null;
	public String s_cont_text = null;
	public String s_cont_html = null;
	public String s_charset_id = null;
	public String s_cont_id = null;
	public String s_create_date = null;
	public String s_modified_date = null;
	private static Logger logger = Logger.getLogger(ScrapeFormat.class.getName());

	// === Parents ===

//		public Content m_Content = null;

	// === Constructors ===

	public ScrapeFormat()
	{
	}
	
	public ScrapeFormat(String sUrlId) throws Exception
	{
		s_format_id = sUrlId;
		retrieve();
	}

	public ScrapeFormat(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	format_id," +
		"	scrape_id," +
		"	format_name," +
		"	cont_text," +
		"	cont_html," +
		"	charset_id," +
		"	cont_id," +
		"	create_date," +
		"	modified_date" +
		" FROM ccnt_scrape_cont_format" +
		" WHERE" +
		"	(format_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_format_id);

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
		s_format_id = rs.getString(1);
		s_scrape_id = rs.getString(2);
		b = rs.getBytes(3);
		s_format_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_cont_text = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_cont_html = (b == null)?null:new String(b,"UTF-8");
		s_charset_id = rs.getString(6);
		s_cont_id = rs.getString(7);
		s_create_date = rs.getString(8);
		s_modified_date = rs.getString(9);


	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_scrape_cont_format_save" +
		"	@format_id=?," +
		"	@scrape_id=?," +
		"	@format_name=?," +
		"	@cont_text=?," +
		"	@cont_html=?," +
		"	@charset_id=?," +
		"	@cont_id=?," +
		"	@create_date=?," +
		"	@modified_date=?";
			 

	public String getSaveSql() { return m_sSaveSql; }

//	public int saveParents(Connection conn) throws Exception
//	{
//		if (m_Content!=null)
//		{
//			m_Content.save(conn);
//			s_cont_id = m_Content.s_cont_id;
//		}
//		return 1;
//	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_format_id);
		pstmt.setString(2, s_scrape_id);
		if(s_format_name == null) pstmt.setString(3, s_format_name);
		else pstmt.setBytes(3, s_format_name.getBytes("UTF-8"));
		if(s_cont_text == null) pstmt.setString(4, s_cont_text);
		else pstmt.setBytes(4, s_cont_text.getBytes("UTF-8"));
		if(s_cont_html == null) pstmt.setString(5, s_cont_html);
		else pstmt.setBytes(5, s_cont_html.getBytes("UTF-8"));
		pstmt.setString(6, s_charset_id);
		pstmt.setString(7, s_cont_id);
		pstmt.setString(8, s_create_date);
		pstmt.setString(9, s_modified_date);


		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_format_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_scrape_cont_format" +
		" WHERE" +
		"	(format_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_format_id);

		return pstmt.executeUpdate();
	}

//	public int deleteParents(Connection conn) throws Exception
//	{
//		if(m_Content!=null) m_Content.delete(conn);
//		return 1;
//	}
	
	// === XML Methods ===

	public String m_sMainElementName = "scrape_url";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_format_id != null ) XmlUtil.appendTextChild(e, "format_id", s_format_id);
		if( s_scrape_id != null ) XmlUtil.appendTextChild(e, "scrape_id", s_scrape_id);
		if( s_format_name != null ) XmlUtil.appendCDataChild(e, "format_name", s_format_name);
		if( s_cont_text != null ) XmlUtil.appendCDataChild(e, "cont_text", s_cont_text);
		if( s_cont_html != null ) XmlUtil.appendCDataChild(e, "cont_html", s_cont_html);
		if( s_charset_id != null ) XmlUtil.appendTextChild(e,  "charset_id", s_charset_id);
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
		if( s_create_date != null ) XmlUtil.appendTextChild(e, "create_date", s_create_date);
		if( s_modified_date != null ) XmlUtil.appendTextChild(e, "modified_date", s_modified_date);
	}

//	public void appendParentsToXml(Element e)
//	{
//		if (m_Content != null) appendChild(e, m_Content);
//	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_format_id = XmlUtil.getChildTextValue(e, "format_id");
		s_scrape_id = XmlUtil.getChildTextValue(e, "scrape_id");
		s_format_name = XmlUtil.getChildCDataValue(e, "format_name");
		s_cont_text = XmlUtil.getChildCDataValue(e, "cont_text");
		s_cont_html = XmlUtil.getChildCDataValue(e, "cont_html");
		s_charset_id = XmlUtil.getChildTextValue(e, "charset_id");
		s_cont_id = XmlUtil.getChildTextValue(e, "cont_id");
		s_create_date = XmlUtil.getChildTextValue(e, "create_date");
		s_modified_date = XmlUtil.getChildTextValue(e, "modified_date");

	}

//	public void getParentsFromXml(Element e) throws Exception
//	{
//		Element eChildContent = XmlUtil.getChildByName(e, "content");
//		if(eChildContent != null) m_ChildContent = new Content(eChildContent);
//	}
	
	// === Other Methods ===
}


