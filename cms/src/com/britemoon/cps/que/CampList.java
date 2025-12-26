package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampList extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_exclusion_list_id = null;
	public String s_auto_respond_list_id = null;
	public String s_test_list_id = null;
	public String s_auto_respond_attr_id = null;
	private static Logger logger = Logger.getLogger(CampList.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CampList()
	{
	}
	
	public CampList(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public CampList(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	exclusion_list_id," +
		"	auto_respond_list_id," +
		"	test_list_id," +
		"	auto_respond_attr_id" +
		" FROM cque_camp_list" +
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
		s_exclusion_list_id = rs.getString(2);
		s_auto_respond_list_id = rs.getString(3);
		s_test_list_id = rs.getString(4);
		s_auto_respond_attr_id = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_list_save" +
		"	@camp_id=?," +
		"	@exclusion_list_id=?," +
		"	@auto_respond_list_id=?," +
		"	@test_list_id=?," +
		"	@auto_respond_attr_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_exclusion_list_id);
		pstmt.setString(3, s_auto_respond_list_id);
		pstmt.setString(4, s_test_list_id);
		pstmt.setString(5, s_auto_respond_attr_id);

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
		" DELETE FROM cque_camp_list" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_list";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_exclusion_list_id != null ) XmlUtil.appendTextChild(e, "exclusion_list_id", s_exclusion_list_id);
		if( s_auto_respond_list_id != null ) XmlUtil.appendTextChild(e, "auto_respond_list_id", s_auto_respond_list_id);
		if( s_test_list_id != null ) XmlUtil.appendTextChild(e, "test_list_id", s_test_list_id);
		if( s_auto_respond_attr_id != null ) XmlUtil.appendTextChild(e, "auto_respond_attr_id", s_auto_respond_attr_id);
	}

	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_exclusion_list_id = XmlUtil.getChildTextValue(e, "exclusion_list_id");
		s_auto_respond_list_id = XmlUtil.getChildTextValue(e, "auto_respond_list_id");
		s_test_list_id = XmlUtil.getChildTextValue(e, "test_list_id");
		s_auto_respond_attr_id = XmlUtil.getChildTextValue(e, "auto_respond_attr_id");
	}

	// === Other Methods ===
}


