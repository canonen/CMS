package com.britemoon.cps.ftp;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Vector;

import com.britemoon.cps.*;
import org.apache.log4j.Logger;

import com.britemoon.cps.ftp.OfferProcessTask;

public class OfferProcessTimer extends BriteTimer {
	private static Logger logger = Logger.getLogger(ImportProcessTimer.class.getName());
	public String getSleepKeyName() { return "default_offer_process_timer_sleep"; }
	public long getDefaultSleepInterval() { return 0; } // 0 - do not start
	
	public OfferProcessTimer(String sTimerNameSuffix)
	{
		String sName = this.getClass().getName().replaceFirst("com.britemoon.","");
		sName += sTimerNameSuffix;
		setTimerName(sName);
		init();
	}

	public Vector buildTaskList()
	{
		//long sleepInterval = findSleepInterval();
		
		Vector vTaskList = new Vector();
		
		ConnectionPool cp = ConnectionPool.getInstance();
		Connection conn = null;
		try
		{
			conn = cp.getConnection(this);
			Statement stmt = null;
			try
			{
				String sFileID = null;
				String sZipLocalFileName = null;
				String sZipRemoteFileName = null;
				String sTaskID = null;
				OfferProcessTask offerProcessTask = null;

				stmt = conn.createStatement();

				String sSql =
						"SELECT file_id, task_id, file_name_local, file_name_remote FROM cftp_ftp_file " +
						" WHERE status_id = 3 " +
						" AND type_id =30 ";
					
				ResultSet rs = stmt.executeQuery(sSql);
				while (rs.next())
				{
					sFileID = rs.getString(1);
					sTaskID = rs.getString(2);
					sZipLocalFileName = rs.getString(3);
					sZipRemoteFileName = rs.getString(4);
					logger.info("OfferProcessTimer: file_id = " + sFileID + " fileName = " + sZipLocalFileName);
					offerProcessTask = new OfferProcessTask(sFileID, sTaskID, sZipLocalFileName, sZipRemoteFileName);
					vTaskList.add(offerProcessTask);
				}
				rs.close();
			}
			catch(SQLException ex) { 
				logger.error(ex.getMessage(), ex);
			}
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(SQLException ex) { 
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		finally { if (conn!=null) cp.free(conn); }
		
		vTaskList.add(new SleepTask(findSleepInterval()));
		return vTaskList;
	}
	
	public long findSleepInterval()
	{
		long lSleepInterval = getDefaultSleepInterval();
		
		try
		{
			String sSleepInterval = Registry.getKey(getSleepKeyName());
			if (sSleepInterval != null) lSleepInterval = Long.parseLong(sSleepInterval);
		}
		catch(Exception ex)
		{
			lSleepInterval = getDefaultSleepInterval();
		}
		
		return lSleepInterval;
	}
}
