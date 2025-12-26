package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;

import org.apache.log4j.Logger;
import org.w3c.dom.*;

public class FilterStatDetail extends BriteObject
{
	private static Logger logger = Logger.getLogger(FilterStatDetail.class.getName());
	// === Properties ===

	public String s_filter_id = null;
	public String s_detail_id = null;
	public String s_detail_name = null;
	public String s_integer_value = null;
	public String s_date_value = null;

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FilterStatDetail()
	{
	}
	
	public FilterStatDetail(String sFilterId, String sDetailId) throws Exception
	{
		s_filter_id = sFilterId;
		s_detail_id = sDetailId;
		retrieve();
	}

	public FilterStatDetail(Element e) throws Exception
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
		"	filter_id," +
		"	detail_id," +
		"	detail_name," +
		"	integer_value," +
		"	date_value" +
		" FROM ctgt_filter_stat_detail" +
		" WHERE" +
		"	(filter_id=?) AND" +
		"	(detail_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
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
		s_filter_id = rs.getString(1);
		s_detail_id = rs.getString(2);
		b = rs.getBytes(3);
		s_detail_name = (b == null)?null:new String(b,"UTF-8");
		s_integer_value = rs.getString(4);
		s_date_value = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ctgt_filter_stat_detail_save" +
		"	@filter_id=?," +
		"	@detail_id=?," +
		"	@detail_name=?," +
		"	@integer_value=?," +
		"	@date_value=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_detail_id);
		if(s_detail_name == null) pstmt.setString(3, s_detail_name);
		else pstmt.setBytes(3, s_detail_name.getBytes("UTF-8"));
		pstmt.setString(4, s_integer_value);
		pstmt.setString(5, s_date_value);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_filter_id = rs.getString(1);
			s_detail_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ctgt_filter_stat_detail" +
		" WHERE" +
		"	(filter_id=?) AND" +
		"	(detail_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_detail_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "filter_stat_detail";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_detail_id != null ) XmlUtil.appendTextChild(e, "detail_id", s_detail_id);
		if( s_detail_name != null ) XmlUtil.appendCDataChild(e, "detail_name", s_detail_name);
		if( s_integer_value != null ) XmlUtil.appendTextChild(e, "integer_value", s_integer_value);
		if( s_date_value != null ) XmlUtil.appendTextChild(e, "date_value", s_date_value);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_detail_id = XmlUtil.getChildTextValue(e, "detail_id");
		s_detail_name = XmlUtil.getChildCDataValue(e, "detail_name");
		s_integer_value = XmlUtil.getChildTextValue(e, "integer_value");
		s_date_value = XmlUtil.getChildTextValue(e, "date_value");
	}

	// === Other Methods ===
}


