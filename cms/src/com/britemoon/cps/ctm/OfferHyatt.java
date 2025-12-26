package com.britemoon.cps.ctm;

import com.britemoon.*;
import com.britemoon.cps.BriteObject;

import java.sql.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class OfferHyatt extends BriteObject
{
	// === Properties ===

	public String s_offer_id = null;
	public String s_cust_id = null;
	public String s_hotel_id = null;		
	public String s_brand_code = null;

	
	
	
	private static Logger logger = Logger.getLogger(Offer.class.getName());

	// === Parents ===

	// === Children ===	

	// === Constructors ===

	public OfferHyatt()
	{
	}
	
	public OfferHyatt(String sOfferId, String sCustId) throws Exception
	{
		s_offer_id = sOfferId;
		s_cust_id = sCustId;
		retrieve();
	}

	public OfferHyatt(Element e) throws Exception
	{
		fromXml(e);
	}
	

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	offer_id," +
		"	cust_id," +
		"	hotel_id," +
		"	brand_code" +
		" FROM ctm_offer_hyatt" +
		" WHERE" +
		"	(offer_id=?) AND" +
		"   (cust_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	// === DB Methods ===
	
		
	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_offer_id);
		pstmt.setString(1, s_cust_id);

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
		s_hotel_id = rs.getString(3);
		s_brand_code = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cctm_offer_hyatt_save" +
		"	@offer_id=?," +
		"	@cust_id=?," +
		"	@hotel_id=?," +
		"	@brand_code=?" ;
		

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_offer_id);
		pstmt.setString(2, s_cust_id);
		pstmt.setString(3, s_hotel_id);
		pstmt.setString(4, s_brand_code);
		
		
		
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


	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_offer_hyatt" +
		" WHERE" +
		"	(offer_id=?) AND (cust_id =?)";

	public String getDeleteSql() { return m_sDeleteSql; }


	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_offer_id);
		pstmt.setString(2, s_cust_id);
		return pstmt.executeUpdate();

	}

	// === XML Methods ===

	public String m_sMainElementName = "offer_hyatt";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_offer_id != null ) XmlUtil.appendTextChild(e, "offer_id", s_offer_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_hotel_id != null ) XmlUtil.appendTextChild(e, "hotel_id", s_hotel_id);
		if( s_brand_code != null ) XmlUtil.appendTextChild(e, "brand_code", s_brand_code);
	}

		
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_offer_id = XmlUtil.getChildTextValue(e, "offer_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_hotel_id = XmlUtil.getChildTextValue(e, "hotel_id");		
		s_brand_code = XmlUtil.getChildTextValue(e, "brand_code");
		
	}

	

	// === Other Methods ===

	
}
