package com.britemoon.cps.ftp;

import java.sql.*;
import java.util.*;

import org.apache.log4j.Logger;
import com.britemoon.cps.BriteTimer;
import com.britemoon.cps.BriteTask;
import com.britemoon.cps.BriteTimer;
import com.britemoon.cps.ConnectionPool;
import com.britemoon.cps.Registry;

public class ImportProcessTimer extends BriteTimer {
		private static Logger logger = Logger.getLogger(ImportProcessTimer.class.getName());
		public String getSleepKeyName() { return "default_import_process_timer_sleep"; }
		public long getDefaultSleepInterval() { return 0; } // 0 - do not start
		
		public ImportProcessTimer(String sTimerNameSuffix)
		{
			String sName = this.getClass().getName().replaceFirst("com.britemoon.","");
			sName += sTimerNameSuffix;
			setTimerName(sName);
			init();
		}

		public Vector buildTaskList()
		{
			long sleepInterval = findSleepInterval();
			
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
					String sFileName = null;
					String sTaskID = null;
					ImportProcessTask importProcessTask = null;

					stmt = conn.createStatement();

					String sSql =
							" SELECT file_id, task_id, file_name_local FROM cftp_ftp_file " +
							" WHERE status_id = 3 " +
							" AND (type_id in (10,20) or (type_id is null)) ";
						
					ResultSet rs = stmt.executeQuery(sSql);
					while (rs.next())
					{
						sFileID = rs.getString(1);
						sTaskID = rs.getString(2);
						sFileName = rs.getString(3);
					
						importProcessTask = new ImportProcessTask(sFileID, sTaskID, sFileName);
						vTaskList.add(importProcessTask);
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
