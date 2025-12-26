package com.britemoon.cps.ftp;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Vector;

import com.britemoon.cps.*;
import org.apache.log4j.Logger;

public class FTPTaskTimer extends BriteTimer
	{
		private static Logger logger = Logger.getLogger(FTPTaskTimer.class.getName());
		public FTPTaskTimer(String sTimerNameSuffix)
		{
			String sName = this.getClass().getName().replaceFirst("com.britemoon.","");
			sName += sTimerNameSuffix;
			setTimerName(sName);
			init();
		}

		public Vector buildTaskList()
		{
			Vector vTaskList = new Vector();
			
			ConnectionPool cp = null;
			Connection conn = null;
			
			try
			{
				Statement stmt  = null;
				ResultSet rs = null;

				cp = ConnectionPool.getInstance();
				conn = cp.getConnection("FTPTaskTimer");

				try
				{
					stmt = conn.createStatement();

					String sSql =
						" SELECT s1.task_id"+
						" FROM cftp_ftp_task_schedule s1 WITH(NOLOCK)"+
						" LEFT OUTER JOIN cftp_ftp_task_schedule s2 WITH(NOLOCK)"+
						" ON"+
						" 	s1.linked_task_id = s2.task_id AND"+
						" 	("+
						" 		(s1.linked_task_id IS NULL)"+
						" 		OR"+
						" 		(s1.next_start_date < s2.next_start_date )"+
						" 	)"+
						" WHERE s1.next_start_date <= getdate()"+
						" AND ISNULL(s1.start_date, getdate()) <= getdate()" +
						" AND ISNULL(s1.finish_date, getdate()) >= getdate()" +
						" ORDER BY s1.task_id";
						
					rs = stmt.executeQuery(sSql);
					
					String sTaskId = null;
					FtpTaskTask fit = null;				
					while (rs.next())
					{
						sTaskId = rs.getString(1);
						fit = new FtpTaskTask(sTaskId);
						vTaskList.add(fit);
					}
					rs.close();
				}
				catch(Exception ex) { throw ex; }
				finally { if (stmt!=null) stmt.close(); }
			}
			catch(Exception ex) { logger.error("Exception: ", ex); }
			finally { if (conn!=null) cp.free(conn); }
		
			vTaskList.add(new SleepTask(findSleepInterval()));
			
			return vTaskList;
		}

		// === === ===

		public long findSleepInterval()
		{
			long lSleepInterval = 60*60*1000;
			
			try
			{
				String sSleepInterval = Registry.getKey("default_ftp_import_sleep");
				if (sSleepInterval != null) lSleepInterval = Long.parseLong(sSleepInterval);
			}
			catch(Exception ex)
			{
				lSleepInterval = 60*60*1000;
			}
			
			return lSleepInterval;
		}
	}

