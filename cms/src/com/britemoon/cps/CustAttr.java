package com.britemoon.cps;

import com.britemoon.*;
import com.britemoon.cps.imc.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;

import org.w3c.dom.*;

public class CustAttr extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_attr_id = null;
	public String s_display_name = null;
	public String s_display_seq = null;
	public String s_fingerprint_seq = null;
	public String s_sync_flag = null;
	public String s_hist_flag = null;
	public String s_newsletter_flag = null;
	public String s_recip_view_seq = null;
	
	// === Parents ===

	public Attribute m_Attribute = null;
	private static Logger logger = Logger.getLogger(CustAttr.class.getName());
	
	// === Children ===

	// === Constructors ===

	public CustAttr()
	{
	}
	
	public CustAttr(String sCustId, String sAttrId) throws Exception
	{
		s_cust_id = sCustId;
		s_attr_id = sAttrId;
		retrieve();
	}

	public CustAttr(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	attr_id," +
		"	display_name," +
		"	display_seq," +
		"	fingerprint_seq," +
		"	sync_flag," +
		"	hist_flag," +
		"	newsletter_flag," +
		"	recip_view_seq" +
		" FROM ccps_cust_attr" +

		" WHERE" +
		"	(cust_id=?) AND" +
		"	(attr_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);

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
		s_cust_id = rs.getString(1);
		s_attr_id = rs.getString(2);
		b = rs.getBytes(3);
		s_display_name = (b == null)?null:new String(b,"UTF-8");
		s_display_seq = rs.getString(4);
		s_fingerprint_seq = rs.getString(5);
		s_sync_flag = rs.getString(6);
		s_hist_flag = rs.getString(7);		
		s_newsletter_flag = rs.getString(8);		
		s_recip_view_seq = rs.getString(9);		
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_cust_attr_save" +
		"	@cust_id=?," +
		"	@attr_id=?," +
		"	@display_name=?," +
		"	@display_seq=?," +
		"	@fingerprint_seq=?," +
		"	@sync_flag=?," +
		"	@hist_flag=?," +
		"	@newsletter_flag=?," +
		"	@recip_view_seq=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_Attribute!=null)
		{
			m_Attribute.save(conn);
			s_attr_id = m_Attribute.s_attr_id;
		}
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);
		if(s_display_name == null) pstmt.setString(3, s_display_name);
		else pstmt.setBytes(3, s_display_name.getBytes("UTF-8"));
		pstmt.setString(4, s_display_seq);
		pstmt.setString(5, s_fingerprint_seq);
		pstmt.setString(6, s_sync_flag);
		pstmt.setString(7, s_hist_flag);
		pstmt.setString(8, s_newsletter_flag);
		pstmt.setString(9, s_recip_view_seq);
		
		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_attr_id = rs.getString(2);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_cust_attr" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(attr_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_attr_id);
		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_Attribute!=null) m_Attribute.delete(conn);
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "cust_attr";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_display_name != null ) XmlUtil.appendCDataChild(e, "display_name", s_display_name);
		if( s_display_seq != null ) XmlUtil.appendTextChild(e, "display_seq", s_display_seq);
		if( s_fingerprint_seq != null ) XmlUtil.appendTextChild(e, "fingerprint_seq", s_fingerprint_seq);
		if( s_sync_flag != null ) XmlUtil.appendTextChild(e, "sync_flag", s_sync_flag);		
		if( s_hist_flag != null ) XmlUtil.appendTextChild(e, "hist_flag", s_hist_flag);		
		if( s_newsletter_flag != null ) XmlUtil.appendTextChild(e, "newsletter_flag", s_newsletter_flag);		
		if( s_recip_view_seq != null ) XmlUtil.appendTextChild(e, "recip_view_seq", s_recip_view_seq);		
	}

	public void appendParentsToXml(Element e)
	{
		if (m_Attribute != null) appendChild(e, m_Attribute);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_display_name = XmlUtil.getChildCDataValue(e, "display_name");
		s_display_seq = XmlUtil.getChildTextValue(e, "display_seq");
		s_fingerprint_seq = XmlUtil.getChildTextValue(e, "fingerprint_seq");
		s_sync_flag = XmlUtil.getChildTextValue(e, "sync_flag");
		s_hist_flag = XmlUtil.getChildTextValue(e, "hist_flag");		
		s_newsletter_flag = XmlUtil.getChildTextValue(e, "newsletter_flag");
		s_recip_view_seq = XmlUtil.getChildTextValue(e, "recip_view_seq");		
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eAttribute = XmlUtil.getChildByName(e, "attribute");
		if(eAttribute != null) m_Attribute = new Attribute(eAttribute);
	}
	
	// === Other Methods ===
	
	public void saveWithSync() throws Exception
	{
		synchronize();
		save();
	}

	private void synchronize() throws Exception
	{
		String sRequest = this.toXml();
		String sResponse = Service.communicate(ServiceType.SADM_CUST_ATTR_SETUP, s_cust_id, sRequest);
//		if (sResponse != null && sResponse.startsWith("\uFEFF")) {
//			sResponse = sResponse.substring(1); // BOM'u sil
//		}
//		sResponse = sResponse.replaceFirst("^\uFEFF", "");
		sResponse = sResponse.replaceFirst("^\\s+", "");
		Element eResponse = XmlUtil.getRootElement(sResponse.trim());
		this.fromXml(eResponse);
		sRequest = sResponse;

		sResponse = Service.communicate(ServiceType.RRCP_CUST_ATTR_SETUP, s_cust_id, sRequest);
		sResponse = sResponse.replaceFirst("^\\s+", "");
//		sResponse = sResponse.replaceFirst("^\uFEFF", "");
		eResponse = XmlUtil.getRootElement(sResponse.trim());
		System.out.println(eResponse);
	}
}


