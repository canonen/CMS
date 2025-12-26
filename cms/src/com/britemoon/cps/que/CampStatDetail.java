package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampStatDetail extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_detail_id = null;
	public String s_detail_name = null;
	public String s_integer_value = null;
	public String s_string_value = null;
	public String s_date_value = null;
	private static Logger  logger = Logger.getLogger(CampStatDetail.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CampStatDetail()
	{
	}
	
	public CampStatDetail(String sCampId, String sDetailId) throws Exception
	{
		s_camp_id = sCampId;
		s_detail_id = sDetailId;
		retrieve();
	}

	public CampStatDetail(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteObject will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	detail_id," +
		"	detail_name," +
		"	integer_value," +
		"	string_value," +
		"	date_value" +
		" FROM cque_camp_stat_detail" +
		" WHERE" +
		"	(camp_id=?) AND" +
		"	(detail_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_detail_id);

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
		s_detail_id = rs.getString(2);
		b = rs.getBytes(3);
		s_detail_name = (b == null)?null:new String(b,"UTF-8");
		s_integer_value = rs.getString(4);
		b = rs.getBytes(5);
		s_string_value = (b == null)?null:new String(b,"UTF-8");
		s_date_value = rs.getString(6);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_stat_detail_save" +
		"	@camp_id=?," +
		"	@detail_id=?," +
		"	@detail_name=?," +
		"	@integer_value=?," +
		"	@string_value=?," +
		"	@date_value=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_detail_id);
		if(s_detail_name == null) pstmt.setString(3, s_detail_name);
		else pstmt.setBytes(3, s_detail_name.getBytes("UTF-8"));
		pstmt.setString(4, s_integer_value);
		if(s_string_value == null) pstmt.setString(5, s_string_value);
		else pstmt.setBytes(5, s_string_value.getBytes("UTF-8"));
		pstmt.setString(6, s_date_value);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_camp_id = rs.getString(1);
			s_detail_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_camp_stat_detail" +
		" WHERE" +
		"	(camp_id=?) AND" +
		"	(detail_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_detail_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_stat_detail";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_detail_id != null ) XmlUtil.appendTextChild(e, "detail_id", s_detail_id);
		if( s_detail_name != null ) XmlUtil.appendCDataChild(e, "detail_name", s_detail_name);
		if( s_integer_value != null ) XmlUtil.appendTextChild(e, "integer_value", s_integer_value);
		if( s_string_value != null ) XmlUtil.appendCDataChild(e, "string_value", s_string_value);
		if( s_date_value != null ) XmlUtil.appendTextChild(e, "date_value", s_date_value);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_detail_id = XmlUtil.getChildTextValue(e, "detail_id");
		s_detail_name = XmlUtil.getChildCDataValue(e, "detail_name");
		s_integer_value = XmlUtil.getChildTextValue(e, "integer_value");
		s_string_value = XmlUtil.getChildCDataValue(e, "string_value");
		s_date_value = XmlUtil.getChildTextValue(e, "date_value");
	}

	// === Other Methods ===
}


