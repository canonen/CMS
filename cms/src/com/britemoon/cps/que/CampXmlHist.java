package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampXmlHist extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_camp_xml = null;
	public String s_version_id = null;
	public String s_update_date = null;
	private static Logger logger = Logger.getLogger(CampXmlHist.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CampXmlHist()
	{
	}
	
	public CampXmlHist(String sCampId, String sVersionId) throws Exception
	{
		s_camp_id = sCampId;
		s_version_id = sVersionId;
		retrieve();
	}

	public CampXmlHist(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	camp_xml," +
		"	version_id," +
		"	update_date" +
		" FROM cque_camp_xml_hist" +
		" WHERE" +
		"	(camp_id=?) AND" +
		"	(version_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_version_id);

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
		s_camp_id = rs.getString(1);
		b = rs.getBytes(2);
		s_camp_xml = (b == null)?null:new String(b,"UTF-8");
		s_version_id = rs.getString(3);
		s_update_date = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_xml_hist_save" +
		"	@camp_id=?," +
		"	@camp_xml=?," +
		"	@version_id=?," +
		"	@update_date=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		if(s_camp_xml == null) pstmt.setString(2, s_camp_xml);
		else pstmt.setBytes(2, s_camp_xml.getBytes("UTF-8"));
		pstmt.setString(3, s_version_id);
		pstmt.setString(4, s_update_date);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_camp_id = rs.getString(1);
			s_version_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_camp_xml_hist" +
		" WHERE" +
		"	(camp_id=?) AND" +
		"	(version_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_version_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_xml_hist";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_camp_xml != null ) XmlUtil.appendCDataChild(e, "camp_xml", s_camp_xml);
		if( s_version_id != null ) XmlUtil.appendTextChild(e, "version_id", s_version_id);
		if( s_update_date != null ) XmlUtil.appendTextChild(e, "update_date", s_update_date);
	}

	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_camp_xml = XmlUtil.getChildCDataValue(e, "camp_xml");
		s_version_id = XmlUtil.getChildTextValue(e, "version_id");
		s_update_date = XmlUtil.getChildTextValue(e, "update_date");
	}

	// === Other Methods ===
}


