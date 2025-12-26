package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.tgt.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.regex.*;
import java.net.*;
import org.apache.log4j.*;

import org.w3c.dom.*;

public class ScrapeUrl extends BriteObject
{
	// === Properties ===

// s_url_id
// s_filter_id
// s_scrape_id
// s_title_html
// s_url
// s_seq

	public String s_url_id = null;
	public String s_filter_id = null;
	public String s_scrape_id = null;
	public String s_title_text = null;
	public String s_title_html = null;
	public String s_url = null;
	public String s_seq = null;
	private static Logger logger = Logger.getLogger(ScrapeUrl.class.getName());

	// === Parents ===

		public Filter m_Filter = null;

	// === Children ===

	public ScrapeAttrs m_ScrapeAttrs = null;

	// === Constructors ===

	public ScrapeUrl()
	{
	}
	
	public ScrapeUrl(String sUrlId) throws Exception
	{
		s_url_id = sUrlId;
		retrieve();
	}

	public ScrapeUrl(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	url_id," +
		"	filter_id," +
		"	scrape_id," +
		"	title_text," +
		"	title_html," +
		"	url," +
		"	seq" +
		" FROM ccnt_scrape_url" +
		" WHERE" +
		"	(url_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_url_id);

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
		s_filter_id = rs.getString(2);
		s_scrape_id = rs.getString(3);
		b = rs.getBytes(4);
		s_title_text = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_title_html = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(6);
		s_url = (b == null)?null:new String(b,"UTF-8");
		s_seq = rs.getString(7);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_scrape_url_save" +
		"	@url_id=?," +
		"	@filter_id=?," +
		"	@scrape_id=?," +
		"	@title_text=?," +
		"	@title_html=?," +
		"	@url=?,"+
		"	@seq=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_ScrapeAttrs != null)
		{
			ScrapeAttrs attrs = new ScrapeAttrs();
			attrs.s_url_id = s_url_id;
			if(attrs.retrieve(conn) > 0) attrs.delete(conn);
		}

		if (m_Filter!=null)
		{
			m_Filter.save(conn);
			s_filter_id = m_Filter.s_filter_id;
		}
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_url_id);
		pstmt.setString(2, s_filter_id);
		pstmt.setString(3, s_scrape_id);
		if(s_title_text == null) pstmt.setString(4, s_title_text);
		else pstmt.setBytes(4, s_title_text.getBytes("UTF-8"));
		if(s_title_html == null) pstmt.setString(5, s_title_html);
		else pstmt.setBytes(5, s_title_html.getBytes("UTF-8"));
		if(s_url == null) pstmt.setString(6, s_url);
		else pstmt.setBytes(6, s_url.getBytes("UTF-8"));
		pstmt.setString(7, s_seq);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_url_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_ScrapeAttrs != null)
		{
			m_ScrapeAttrs.s_url_id = s_url_id;
			m_ScrapeAttrs.save(conn);
		}

		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_scrape_url" +
		" WHERE" +
		"	(url_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_url_id);

		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_Filter!=null) m_Filter.delete(conn);
		return 1;
	}
	
	public int deleteChildren(Connection conn) throws Exception
	{
		if (m_ScrapeAttrs!=null) m_ScrapeAttrs.delete(conn);
		return 1;
	}

	// === XML Methods ===

	public String m_sMainElementName = "scrape_url";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_url_id != null ) XmlUtil.appendTextChild(e, "url_id", s_url_id);
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_scrape_id != null ) XmlUtil.appendTextChild(e, "scrape_id", s_scrape_id);
		if( s_title_text != null ) XmlUtil.appendCDataChild(e, "title_text", s_title_text);
		if( s_title_html != null ) XmlUtil.appendCDataChild(e, "title_html", s_title_html);
		if( s_url != null ) XmlUtil.appendCDataChild(e, "url", s_url);
		if( s_seq != null ) XmlUtil.appendTextChild(e, "seq", s_seq);
	}

	public void appendParentsToXml(Element e)
	{
		if (m_Filter != null) appendChild(e, m_Filter);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_ScrapeAttrs != null) appendChild(e, m_ScrapeAttrs);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_url_id = XmlUtil.getChildTextValue(e, "url_id");
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_scrape_id = XmlUtil.getChildTextValue(e, "scrape_id");
		s_title_text = XmlUtil.getChildCDataValue(e, "title_text");
		s_title_html = XmlUtil.getChildCDataValue(e, "title_html");
		s_url = XmlUtil.getChildCDataValue(e, "url");
		s_seq = XmlUtil.getChildTextValue(e, "seq");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eFilter = XmlUtil.getChildByName(e, "filter");
		if(eFilter != null) m_Filter = new Filter(eFilter);
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eScrapeAttrs = XmlUtil.getChildByName(e, "scrape_attrs");
		if(eScrapeAttrs != null) m_ScrapeAttrs = new ScrapeAttrs(eScrapeAttrs);
	}
	
	// === Other Methods ===

	public int scrape (int nEntries) throws Exception 
	{
		Scrape scrape = new Scrape ();
		scrape.s_scrape_id = s_scrape_id;
		scrape.retrieve();

		ScrapeTags baseTags = new ScrapeTags ();
		baseTags.s_scrape_id = s_scrape_id;
		baseTags.s_level = "0";
		baseTags.retrieve();
		ScrapeTag baseTag = (ScrapeTag) baseTags.elements().nextElement();

		ScrapeTags tags = new ScrapeTags ();
		tags.s_scrape_id = s_scrape_id;
		tags.s_level = "1";
		tags.retrieve();

		URL url = new URL(s_url);
		URLConnection uc = url.openConnection();
		BufferedReader in = new BufferedReader(new InputStreamReader(uc.getInputStream()));

		char [] c = new char [32768];
		StringBuffer sb = new StringBuffer();
		for(int n = in.read(c); n > 0; n = in.read(c)) sb.append(c, 0, n);
		
		String sScrapeText = sb.toString();
		if (sScrapeText == null) return 0;

		sScrapeText = new String(sScrapeText.getBytes(), "ISO-8859-1");
		sScrapeText = CharReplacement.cleanChars(sScrapeText.trim());

		// loop nEntries 
		int i0 = 0;
		int i1 = 0;
		int i2 = 0;
		int count = 0;
		for (int i = 0; i < nEntries; i++)
		{
			ScrapeTag tag = null;
			i1 = sScrapeText.indexOf("<"+baseTag.s_tag_name+">", i0);
			i2 = sScrapeText.indexOf("</"+baseTag.s_tag_name+">", i1);
			i0 = i2 + baseTag.s_tag_name.length() + 3;
			if ((i1 < 0) || (i2 < 0)) break;
			i1 += (baseTag.s_tag_name.length() + 2);
			count++;
			String sBaseText = sScrapeText.substring(i1,i2);
		// loop through tags, get data
			for (Enumeration e = tags.elements(); e.hasMoreElements();)
			{
				tag = (ScrapeTag) e.nextElement();
				
				int j1 = sBaseText.indexOf("<"+tag.s_tag_name+">");
				int j2 = sBaseText.indexOf("</"+tag.s_tag_name+">");

				String sAttrValue = null;
				
				if (!((j1 < 0) || (j2 < 0)))
				{
					j1 += (tag.s_tag_name.length() + 2);
					sAttrValue = sBaseText.substring(j1, j2);
					if (tag.s_tag_name.toUpperCase().indexOf("LINK") > -1) {
						sAttrValue = parseLink(sAttrValue, scrape.s_base_url);
					} else {
						sAttrValue = removeHtml(sAttrValue);
					}
					sAttrValue = ((sAttrValue!=null)&&(sAttrValue.length()>0))?sAttrValue:null;
				}
				ScrapeAttr attr = new ScrapeAttr();
				attr.s_url_id = s_url_id;
				attr.s_entry_id = String.valueOf(i+1);
				attr.s_attr_name = tag.s_tag_name;
				attr.s_attr_value = sAttrValue;
				
				attr.save();
			}
		}
		return count;	
	}


	private String removeHtml (String sText) throws Exception 
	{
		String sResult = sText.trim();

		sResult = sResult.replaceAll("</?[^aA][^>]*>", "");

		return sResult;

	}

	private String parseLink (String sText, String sBaseUrl) throws Exception 
	{
		String sResult = sText.trim();
		
		Pattern p = Pattern.compile(".*href=['\"](\\S*)['\"].*", Pattern.CASE_INSENSITIVE);
		Matcher m = p.matcher(sText.trim());
		if (m.matches()) {
			 sResult = ((sBaseUrl!=null)?sBaseUrl:"") + m.group(1);
		}
		return sResult;

	}


	public String replaceContentAttrs (String sContent) throws Exception
	{
		String sResult = sContent;
		String tmp;
		int offset,i,j,k;
		String sAttrName, sAttrValue;

		ScrapeAttrs attrs = new ScrapeAttrs();
		attrs.s_url_id = s_url_id;
		attrs.retrieve();
		
		if (attrs.size() < 1) return null; // no attrs for this url, return blank content

		for (Enumeration e = attrs.elements(); e.hasMoreElements();)
		{
			//get attr properties and replace in content
			ScrapeAttr attr = (ScrapeAttr) e.nextElement();
			// !*attr.s_attr_name:attr.s_entry_id;default*!

			sAttrName = attr.s_attr_name+":"+attr.s_entry_id;
			sAttrValue = (attr.s_attr_value != null)?attr.s_attr_value:"";
			
			tmp = sResult;
			offset = 0;
			i = tmp.indexOf("!*"+sAttrName+";");
			while (i != -1) {
				tmp = tmp.substring(i);
				j = tmp.indexOf("*!");
				if (j != -1) {
					if (sAttrValue.length() == 0) {
						k = tmp.indexOf(";");
						if (k != -1 && k < j) {
							//Use default since attr_value was not provided
							sAttrValue = tmp.substring(k+1,j);
						}
					}
					sResult = sResult.substring(0,offset+i)+sAttrValue+tmp.substring(j+2);

					offset += sAttrValue.length()+i-2;
					tmp = tmp.substring(j);
					i = tmp.indexOf("!*"+sAttrName+";");
				} else {
					i = -1;
				}
			}
		}
		
		sResult = cleanContentTags(sResult);
		
		return sResult;
	}

	public String cleanContentTags(String sContent) throws Exception
	{
		String sResult = sContent;
		String tmp;
		int offset,i,j,k;
		String sTagName, sAttrValue;

		ScrapeTags tags = new ScrapeTags();
		tags.s_scrape_id = s_scrape_id;
		tags.retrieve();
		
		for (Enumeration e = tags.elements(); e.hasMoreElements();)
		{
			//get tag name and clean out any extra tags with that name in Content
			ScrapeTag tag = (ScrapeTag) e.nextElement();

			sTagName = tag.s_tag_name;
			sAttrValue = "";

			tmp = sResult;
			offset = 0;
			i = tmp.indexOf("!*"+sTagName+":");
			while (i != -1) {
				tmp = tmp.substring(i);
				j = tmp.indexOf("*!");
				if (j != -1) {
					k = tmp.indexOf(";");
					if (k != -1 && k < j) {
						//Use default since attr_value was not provided
						sAttrValue = tmp.substring(k+1,j);
					}
					sResult = sResult.substring(0,offset+i)+sAttrValue+tmp.substring(j+2);

					offset += sAttrValue.length()+i-2;
					tmp = tmp.substring(j);
					i = tmp.indexOf("!*"+sTagName+":");
				} else {
					i = -1;
				}
			}
		}
	
		return sResult;	
	}




}


