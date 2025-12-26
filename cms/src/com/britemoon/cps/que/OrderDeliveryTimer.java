package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class OrderDeliveryTimer extends BriteTimer
{
	private static Logger logger = Logger.getLogger(OrderDeliveryTimer.class.getName());
	public OrderDeliveryTimer(String sTimerNameSuffix)
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
			conn = cp.getConnection("OrderDeliveryTimer");

			try
			{
				stmt = conn.createStatement();
				String sSql =
					" SELECT d.camp_id, d.chunk_id, f.file_url " +
					"   FROM cxcs_delivery d, " +
					"        cque_campaign c, " +
					"        cexp_export_file f, " +
					"        cque_schedule s " +
					"  WHERE d.submit_date IS NULL " +
					"    AND d.status IS NULL " +
					"    AND d.camp_id = c.camp_id " +
					"    AND c.status_id = " + CampaignStatus.BEING_PROCESSED +
					"    AND d.camp_id = s.camp_id " +
					"    AND ISNULL(s.start_date, getdate()) <= getdate()" +
					"    AND d.file_id = f.file_id " +
					"    AND f.status_id = " + ExportStatus.COMPLETE +
					" ORDER BY d.camp_id";
					
				rs = stmt.executeQuery(sSql);
				
				String sCampId = null;
				String sChunkId = null;
				String sFileUrl = null;

				byte[] b = null;
				OrderDeliveryTask order_delivery_task = null;				
				while (rs.next())
				{
					sCampId = rs.getString(1);
					sChunkId = rs.getString(2);
					sFileUrl = rs.getString(3);
					order_delivery_task = new OrderDeliveryTask(sCampId, sChunkId, sFileUrl);
					vTaskList.add(order_delivery_task);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) { logger.error("Exception: ", ex); }
		finally { if (conn!=null) cp.free(conn); }
	
		// sleep anyway
		// if setup failed there is no reasone to retry it immediatelly
		vTaskList.add(new SleepTask(findSleepInterval()));
		
		return vTaskList;
	}

	// === === ===

	public long findSleepInterval()
	{
		long lSleepInterval = 60000;
		
		try
		{
			String sSleepInterval = Registry.getKey("default_order_delivery_sleep");
			if (sSleepInterval != null) lSleepInterval = Long.parseLong(sSleepInterval);
		}
		catch(Exception ex)
		{
			lSleepInterval = 60000;
		}
		
		return lSleepInterval;
	}
}
