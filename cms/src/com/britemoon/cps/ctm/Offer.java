package com.britemoon.cps.ctm;

import com.britemoon.*;
import com.britemoon.cps.BriteObject;
import com.britemoon.cps.XmlUtil;
import com.britemoon.cps.ctm.OfferHyatt;

import java.sql.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Offer extends BriteObject
{
	// === Properties ===

	public String s_offer_id = null;
	public String s_cust_id = null;
	public String s_size_id = null;  // 1 = small; 2 = large
	public String s_name = null;
	public String s_headline_html = null;
	public String s_detail_html = null;
	public String s_image_url = null;
	public String s_detail_text = null;
	public String s_last_send_date = null;
	
	
	private static Logger logger = Logger.getLogger(Offer.class.getName());

	// === Parents ===

	// === Children ===

	public OfferHyatt m_OfferHyatt = null;
	

	// === Constructors ===

	public Offer()
	{
	}
	
	public Offer(String sOfferId, String sCustId) throws Exception
	{
		s_offer_id = sOfferId;
		s_cust_id = sCustId;
		retrieve();
	}

	public Offer(Element e) throws Exception
	{
		fromXml(e);
	}
	

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	offer_id," +
		"	cust_id," +
		"	size_id," +
		"	name," +
		"	headline_html," +
		"	detail_html," +
		"	image_url," +
		"	detail_text," +
		"	last_send_date" +
		" FROM ctm_offer" +
		" WHERE" +
		"	(offer_id=?) AND" +
		"   (cust_id=?) AND" +
		"   (size_id=?) ";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	// === DB Methods ===
	
		
	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_offer_id);
		pstmt.setString(2, s_cust_id);
		pstmt.setString(3, s_size_id);

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
		s_offer_id = rs.getString(1);
		s_cust_id = rs.getString(2);
		s_size_id = rs.getString(3);
		s_name = rs.getString(4);
		b = rs.getBytes(5);
		try {  s_headline_html = ((b == null)? null : new String(b,"UTF-8"));  } 	catch (Exception ex) {}
		b = rs.getBytes(6);
		try	{ s_detail_html = ((b == null)? null : new String(b,"UTF-8"));  } catch (Exception ex) {}
		s_image_url = rs.getString(7);
		b = rs.getBytes(8);
		s_detail_text = (b == null)?null:new String(b,"UTF-8");
		s_last_send_date = rs.getString(9);
		
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cctm_offer_save" +
		"	@offer_id=?," +
		"	@cust_id=?," +
		"	@size_id=?," +
		"	@name=?," +
		"	@headline_html=?," +
		"	@detail_html=?," +
		"	@image_url=?," +
		"	@detail_text=?," +
		"   @last_send_date=?";
		

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_offer_id);
		pstmt.setString(2, s_cust_id);
		pstmt.setString(3, s_size_id);
		pstmt.setString(4, s_name);
		
		if(s_headline_html == null) pstmt.setString(5, s_headline_html);
		else pstmt.setBytes(5, s_headline_html.getBytes("UTF-8"));
		
		if(s_detail_html == null) pstmt.setString(6, s_detail_html);
		else pstmt.setBytes(6, s_detail_html.getBytes("UTF-8"));
		
		if(s_image_url == null) pstmt.setString(7, s_image_url);
		else pstmt.setBytes(7, s_image_url.getBytes("UTF-8"));
		
		if(s_detail_text == null) pstmt.setString(8, s_detail_text);
		else pstmt.setBytes(8, s_detail_text.getBytes("UTF-8"));
		
		pstmt.setString(9, s_last_send_date);
		
		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_offer_id = rs.getString(1);
			s_cust_id = rs.getString(2);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_OfferHyatt!=null)
		{
			m_OfferHyatt.s_offer_id = s_offer_id;
			m_OfferHyatt.s_cust_id = s_cust_id;
			m_OfferHyatt.save(conn);
		}
		
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ctm_offer" +
		" WHERE" +
		"	(offer_id=?) AND (cust_id = ?) AND (size_id = ?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_OfferHyatt!=null) m_OfferHyatt.delete(conn);	
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_offer_id);
		pstmt.setString(2, s_cust_id);
		pstmt.setString(3, s_size_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "offer";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_offer_id != null ) XmlUtil.appendTextChild(e, "offer_id", s_offer_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_size_id != null ) XmlUtil.appendTextChild(e, "size_id", s_size_id);
		if( s_name != null ) XmlUtil.appendTextChild(e, "name", s_name);
		if( s_headline_html != null ) XmlUtil.appendCDataChild(e, "headline_html", s_headline_html);
		if( s_detail_html != null ) XmlUtil.appendCDataChild(e, "detail_html", s_detail_html);
		if( s_image_url != null ) XmlUtil.appendTextChild(e, "image_url", s_image_url);
		if( s_detail_text != null ) XmlUtil.appendCDataChild(e, "detail_text", s_detail_text);
		if( s_last_send_date != null ) XmlUtil.appendTextChild(e, "last_send_date", s_last_send_date);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_OfferHyatt != null) appendChild(e, m_OfferHyatt);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_offer_id = XmlUtil.getChildTextValue(e, "offer_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_size_id = XmlUtil.getChildTextValue(e, "size_id");
		s_name = XmlUtil.getChildTextValue(e, "name");	
		s_headline_html = XmlUtil.getChildCDataValue(e, "headline_html");
		s_detail_html = XmlUtil.getChildCDataValue(e, "detail_html");
		s_image_url = XmlUtil.getChildTextValue(e, "image_url");
		s_detail_text = XmlUtil.getChildCDataValue(e, "detail_text");
		s_last_send_date = XmlUtil.getChildTextValue(e, "last_send_date");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eOfferHyatt = XmlUtil.getChildByName(e, "offer_hyatt");
		if(eOfferHyatt != null) m_OfferHyatt = new OfferHyatt(eOfferHyatt);
	}

	// === Other Methods ===

	
}
