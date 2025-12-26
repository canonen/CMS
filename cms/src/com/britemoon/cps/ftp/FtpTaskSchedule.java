package com.britemoon.cps.ftp;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FtpTaskSchedule extends BriteObject
{
	// === Properties ===

	public String s_task_id = null;
	public String s_linked_task_id = null;
	public String s_next_start_date = null;
	public String s_next_start_interval = null;  // controls when the FtpImportTimer will run this task next.
        public String s_hm_daily_weekday_mask = null;  // Controls when the HM monitor will alert a user that the task has not started.
	private static Logger logger = Logger.getLogger(FtpTaskSchedule.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FtpTaskSchedule()
	{
	}
	
	public FtpTaskSchedule(String sTaskId) throws Exception
	{
		s_task_id = sTaskId;
		retrieve();
	}

	public FtpTaskSchedule(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	task_id," +
		"	linked_task_id," +
		"	next_start_date," +
		"	next_start_interval," +	
                "       hm_daily_weekday_mask" +
		" FROM cftp_ftp_task_schedule" +
		" WHERE" +
		"	(task_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_task_id);

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
		s_task_id = rs.getString(1);
		s_linked_task_id = rs.getString(2);
		s_next_start_date = rs.getString(3);
		s_next_start_interval = rs.getString(4);
                s_hm_daily_weekday_mask = rs.getString(5);
        }

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cftp_ftp_task_schedule_save" +
		"	@task_id=?," +
		"	@linked_task_id=?," +
		"	@next_start_date=?," +
		"	@next_start_interval=?," +
                "       @hm_daily_weekday_mask=?";
		
	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_task_id);
		pstmt.setString(2, s_linked_task_id);
		pstmt.setString(3, s_next_start_date);
		pstmt.setString(4, s_next_start_interval);
                pstmt.setString(5, s_hm_daily_weekday_mask);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_task_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cftp_ftp_task_schedule" +
		" WHERE" +
		"	(task_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_task_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "ftp_task_schedule";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_task_id != null ) XmlUtil.appendTextChild(e, "task_id", s_task_id);
		if( s_linked_task_id != null ) XmlUtil.appendTextChild(e, "linked_task_id", s_linked_task_id);
		if( s_next_start_date != null ) XmlUtil.appendTextChild(e, "next_start_date", s_next_start_date);
		if( s_next_start_interval != null ) XmlUtil.appendTextChild(e, "next_start_interval", s_next_start_interval);
                if(s_hm_daily_weekday_mask != null) XmlUtil.appendTextChild(e, "hm_daily_weekday_mask", s_hm_daily_weekday_mask);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_task_id = XmlUtil.getChildTextValue(e, "task_id");
		s_linked_task_id = XmlUtil.getChildTextValue(e, "linked_task_id");
		s_next_start_date = XmlUtil.getChildTextValue(e, "next_start_date");
		s_next_start_interval = XmlUtil.getChildTextValue(e, "next_start_interval");	
                s_hm_daily_weekday_mask = XmlUtil.getChildTextValue(e, "hm_daily_weekday_mask");
	}

	// === Other Methods ===
}
