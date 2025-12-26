package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Schedule extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_start_date = null;
	public String s_end_date = null;
	public String s_start_daily_time = null;
	public String s_end_daily_time = null;
	public String s_start_daily_weekday_mask = null;
	private static Logger logger = Logger.getLogger(Schedule.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public Schedule()
	{
	}
	
	public Schedule(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public Schedule(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	start_date," +
		"	end_date," +
		"	start_daily_time," +
		"	end_daily_time," +
		"	start_daily_weekday_mask" +
		" FROM cque_schedule" +
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
		s_start_date = rs.getString(2);
		s_end_date = rs.getString(3);
		s_start_daily_time = rs.getString(4);
		s_end_daily_time = rs.getString(5);
		s_start_daily_weekday_mask = rs.getString(6);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_schedule_save" +
		"	@camp_id=?," +
		"	@start_date=?," +
		"	@end_date=?," +
		"	@start_daily_time=?," +
		"	@end_daily_time=?," +
		"	@start_daily_weekday_mask=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_start_date);
		pstmt.setString(3, s_end_date);
		pstmt.setString(4, s_start_daily_time);
		pstmt.setString(5, s_end_daily_time);
		pstmt.setString(6, s_start_daily_weekday_mask);

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
		" DELETE FROM cque_schedule" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "schedule";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_start_date != null ) XmlUtil.appendTextChild(e, "start_date", s_start_date);
		if( s_end_date != null ) XmlUtil.appendTextChild(e, "end_date", s_end_date);
		if( s_start_daily_time != null ) XmlUtil.appendTextChild(e, "start_daily_time", s_start_daily_time);
		if( s_end_daily_time != null ) XmlUtil.appendTextChild(e, "end_daily_time", s_end_daily_time);
		if( s_start_daily_weekday_mask != null ) XmlUtil.appendTextChild(e, "start_daily_weekday_mask", s_start_daily_weekday_mask);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_start_date = XmlUtil.getChildTextValue(e, "start_date");
		s_end_date = XmlUtil.getChildTextValue(e, "end_date");
		s_start_daily_time = XmlUtil.getChildTextValue(e, "start_daily_time");
		s_end_daily_time = XmlUtil.getChildTextValue(e, "end_daily_time");
		s_start_daily_weekday_mask = XmlUtil.getChildTextValue(e, "start_daily_weekday_mask");
	}

	// === Other Methods ===
}


