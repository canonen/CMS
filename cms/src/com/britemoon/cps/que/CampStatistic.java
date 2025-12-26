package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampStatistic extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_start_date = null;
	public String s_finish_date = null;
	public String s_recip_total_qty = null;
	public String s_recip_queued_qty = null;
	public String s_recip_sent_qty = null;
	private static Logger logger = Logger.getLogger(CampStatistic.class.getName());

	// === Parents ===

	// === Children ===

	CampStatDetails m_CampStatDetails = null;

	// === Constructors ===

	public CampStatistic()
	{
	}
	
	public CampStatistic(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public CampStatistic(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	start_date," +
		"	finish_date," +
		"	recip_total_qty," +
		"	recip_queued_qty," +
		"	recip_sent_qty" +
		" FROM cque_camp_statistic" +
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
		s_camp_id = rs.getString(1);
		s_start_date = rs.getString(2);
		s_finish_date = rs.getString(3);
		s_recip_total_qty = rs.getString(4);
		s_recip_queued_qty = rs.getString(5);
		s_recip_sent_qty = rs.getString(6);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_statistic_save" +
		"	@camp_id=?," +
		"	@start_date=?," +
		"	@finish_date=?," +
		"	@recip_total_qty=?," +
		"	@recip_queued_qty=?," +
		"	@recip_sent_qty=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (s_camp_id == null) return 1;

		if (m_CampStatDetails!=null)
		{
			String sSql = "DELETE cque_camp_stat_detail WHERE camp_id = " + s_camp_id;
			BriteUpdate.executeUpdate(sSql,conn);
		}

		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_start_date);
		pstmt.setString(3, s_finish_date);
		pstmt.setString(4, s_recip_total_qty);
		pstmt.setString(5, s_recip_queued_qty);
		pstmt.setString(6, s_recip_sent_qty);

		ResultSet rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_camp_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_CampStatDetails!=null)
		{
		 	m_CampStatDetails.s_camp_id = s_camp_id;
		  	m_CampStatDetails.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_camp_statistic WHERE (camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_statistic";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_start_date != null ) XmlUtil.appendTextChild(e, "start_date", s_start_date);
		if( s_finish_date != null ) XmlUtil.appendTextChild(e, "finish_date", s_finish_date);
		if( s_recip_total_qty != null ) XmlUtil.appendTextChild(e, "recip_total_qty", s_recip_total_qty);
		if( s_recip_queued_qty != null ) XmlUtil.appendTextChild(e, "recip_queued_qty", s_recip_queued_qty);
		if( s_recip_sent_qty != null ) XmlUtil.appendTextChild(e, "recip_sent_qty", s_recip_sent_qty);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_CampStatDetails != null) appendChild(e, m_CampStatDetails);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_start_date = XmlUtil.getChildTextValue(e, "start_date");
		s_finish_date = XmlUtil.getChildTextValue(e, "finish_date");
		s_recip_total_qty = XmlUtil.getChildTextValue(e, "recip_total_qty");
		s_recip_queued_qty = XmlUtil.getChildTextValue(e, "recip_queued_qty");
		s_recip_sent_qty = XmlUtil.getChildTextValue(e, "recip_sent_qty");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eCampStatDetails = XmlUtil.getChildByName(e, "camp_stat_details");
		if(eCampStatDetails != null) m_CampStatDetails = new CampStatDetails(eCampStatDetails);
	}

	// === Other Methods ===
}


