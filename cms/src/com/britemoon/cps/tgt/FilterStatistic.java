package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FilterStatistic extends BriteObject
{
	// === Properties ===

	public String s_filter_id = null;
	public String s_start_date = null;
	public String s_finish_date = null;
	public String s_recip_qty = null;
	public String s_print_recip_qty = null;	
	private static Logger logger = Logger.getLogger(FilterStatistic.class.getName());	

	// === Parents ===

	// === Children ===	
	FilterStatDetails m_FilterStatDetails = null;
	
	// === Constructors ===

	public FilterStatistic()
	{
	}
	
	public FilterStatistic(String sFilterId) throws Exception
	{
		s_filter_id = sFilterId;
		retrieve();
	}

	public FilterStatistic(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	filter_id," +
		"	start_date," +
		"	finish_date," +
		"	recip_qty," +
		"	print_recip_qty" +
		" FROM ctgt_filter_statistic" +
		" WHERE" +
		"	(filter_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);

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
		s_start_date = rs.getString(2);
		s_finish_date = rs.getString(3);
		s_recip_qty = rs.getString(4);
		s_print_recip_qty = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ctgt_filter_statistic_save" +
		"	@filter_id=?," +
		"	@start_date=?," +
		"	@finish_date=?," +
		"	@recip_qty=?," +
		"	@print_recip_qty=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_start_date);
		pstmt.setString(3, s_finish_date);
		pstmt.setString(4, s_recip_qty);
		pstmt.setString(5, s_print_recip_qty);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_filter_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_FilterStatDetails!=null)
		{
			m_FilterStatDetails.s_filter_id = s_filter_id;
		  	m_FilterStatDetails.save(conn);
		}
		return 1;
	}
	
	public int saveParents(Connection conn) throws Exception
	{
		if (s_filter_id == null) return 1;

		if (m_FilterStatDetails!=null)
		{
			String sSql = "DELETE ctgt_filter_stat_detail WHERE filter_id = " + s_filter_id;
			BriteUpdate.executeUpdate(sSql,conn);
		}

		return 1;
	}
	
	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_FilterStatDetails!=null) 
		{
			m_FilterStatDetails.delete(conn);
		}
		else
		{
			m_FilterStatDetails = new FilterStatDetails();
			m_FilterStatDetails.s_filter_id = s_filter_id;
			if(m_FilterStatDetails.retrieve() > 0)
			{
				m_FilterStatDetails.delete(conn);
			}
		}
		return 1;
	}
	
	public void appendChildrenToXml(Element e)
	{
		if (m_FilterStatDetails != null) appendChild(e, m_FilterStatDetails);
	}
	
	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eFilterStatDetails = XmlUtil.getChildByName(e, "filter_stat_details");
		if(eFilterStatDetails != null) m_FilterStatDetails = new FilterStatDetails(eFilterStatDetails);
	}
	
	// === DB Method delete()===
 
	public String m_sDeleteSql =
		" DELETE FROM ctgt_filter_statistic" +
		" WHERE" +
		"	(filter_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_filter_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "filter_statistic";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_start_date != null ) XmlUtil.appendTextChild(e, "start_date", s_start_date);
		if( s_finish_date != null ) XmlUtil.appendTextChild(e, "finish_date", s_finish_date);
		if( s_recip_qty != null ) XmlUtil.appendTextChild(e, "recip_qty", s_recip_qty);
		if( s_print_recip_qty != null ) XmlUtil.appendTextChild(e, "print_recip_qty", s_print_recip_qty);		
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_start_date = XmlUtil.getChildTextValue(e, "start_date");
		s_finish_date = XmlUtil.getChildTextValue(e, "finish_date");
		s_recip_qty = XmlUtil.getChildTextValue(e, "recip_qty");
		s_print_recip_qty = XmlUtil.getChildTextValue(e, "print_recip_qty");
	}

	// === Other Methods ===
}


