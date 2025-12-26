package com.britemoon.cps.ctm;

import com.britemoon.*;

import com.britemoon.cps.BriteList;
import com.britemoon.cps.ctm.Offer;
import com.britemoon.cps.ctm.OfferHyatt;

import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Offers extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(Offers.class.getName());
	public Offers()
	{
	}

	public Offers(Element e) throws Exception
	{
		fromXml(e);
	}

	public String s_offer_id = null;
	public String s_cust_id = null;
	public String s_size_id = null;
	public String s_name = null;		
	public String s_headline_html = null;
	public String s_detail_html = null;
	public String s_image_url = null;
	public String s_detail_text = null;
	public String s_last_send_date = null;
	
	
	private void resetParams()
	{
		s_offer_id = null;
		s_cust_id = null;
		s_size_id = null;
		s_name = null;
		s_headline_html = null;
		s_detail_html = null;
		s_image_url = null;
		s_detail_text = null;
		s_last_send_date = null;
		
	}
	
//	 === DB Methods ===

	// === Retrieve, delete & save params ===

	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	offer_id," +
			"	cust_id," +
			"	size_id," +
			"	name," +
			"	headline_html," +
			"	detail_html," +
			"	image_url," +
			"	detail_text," +
			"	last_send_date";
		
		m_sFromClause = " FROM ctm_offer ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  offer_id, cust_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_offer_id != null) { sWhereSql += " (offer_id IN (?)) "; bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_size_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (size_id IN (?)) "); bAddAnd = true; }
		if(s_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (name IN (?)) "); bAddAnd = true; }
		if(s_headline_html != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (headline_html IN (?)) "); bAddAnd = true; }
		if(s_detail_html != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (detail_html IN (?)) "); bAddAnd = true; }
		if(s_image_url != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (image_url IN (?)) "); bAddAnd = true; }
		if(s_detail_text != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (detail_text IN (?)) "); bAddAnd = true; }
		if(s_last_send_date != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (last_send_date IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_offer_id != null) { pstmt.setString(i, s_offer_id); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_size_id != null) { pstmt.setString(i, s_size_id); i++; }
		if(s_name != null) { pstmt.setString(i, s_name); i++; }		
		if(s_headline_html != null) { pstmt.setBytes(i, s_headline_html.getBytes("UTF-8")); i++; }
		if(s_detail_html != null) { pstmt.setBytes(i, s_detail_html.getBytes("UTF-8")); i++; }
		if(s_image_url != null) { pstmt.setString(i, s_image_url); i++; }
		if(s_detail_text != null) { pstmt.setBytes(i, s_detail_text.getBytes("UTF-8")); i++; }
		if(s_last_send_date != null) { pstmt.setString(i, s_last_send_date); i++; }

	}

	public void fixIds()
	{
		Offer off = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			off = (Offer)e.nextElement();
			if(s_offer_id != null) off.s_offer_id = s_offer_id;
			if(s_cust_id != null) off.s_cust_id = s_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		Offer off = null;
		while (rs.next())
		{
			off = new Offer();
			off.getPropsFromResultSetRow(rs);
			add(off);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "offers";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "offer";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		Offer off = null;
		for(int i = 0; i < iLength; i++)
		{
			off = new Offer ((Element)nl.item(i));
			v.add(off);
		}
		return iLength;
	}

	// === Other Methods ===
}


