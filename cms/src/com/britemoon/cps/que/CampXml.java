package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampXml extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_camp_xml = null;
	private static Logger logger = Logger.getLogger(CampXml.class.getName());

	// === Constructors ===

	public CampXml()
	{
	}
	
	public CampXml(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public CampXml(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	camp_xml" +
		" FROM cque_camp_xml" +
		" WHERE" +
		"	(camp_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);

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
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_xml_save" +
		"	@camp_id=?," +
		"	@camp_xml=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		if(s_camp_xml == null) pstmt.setString(2, s_camp_xml);
		else pstmt.setBytes(2, s_camp_xml.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_camp_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_camp_xml" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_xml";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_camp_xml != null ) XmlUtil.appendCDataChild(e, "camp_xml", s_camp_xml);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_camp_xml = XmlUtil.getChildCDataValue(e, "camp_xml");
	}

	// === Other Methods ===
}


