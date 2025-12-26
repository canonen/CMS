package com.britemoon.cps.xcs.cti;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.upd.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class OrderCompletionTimer extends BriteTimer
{
	private static Logger logger = Logger.getLogger(OrderCompletionTimer.class.getName());
	public OrderCompletionTimer(String sTimerNameSuffix)
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
			conn = cp.getConnection("OrderCompletionTimer");

			try
			{
				stmt = conn.createStatement();

				// Find Orders in PROCESSING status with completed imports
				String sSql = "SELECT o.brite_order_id"
					+ " FROM cxcs_order o, cxcs_order_brite_object bo, cupd_import i"
					+ " WHERE o.brite_order_id = bo.brite_order_id"
					+ " AND bo.type_id = " + ObjectType.IMPORT
					+ " AND bo.brite_object_id = i.import_id"
					+ " AND i.status_id = " + ImportStatus.COMMIT_COMPLETE
					+ " AND o.status_id = " + OrderStatus.PROCESSING
					+ " ORDER BY o.brite_order_id";
					
				rs = stmt.executeQuery(sSql);
				
				String sOrderId = null;

				byte[] b = null;
				OrderCompletionTask order_completion_task = null;				
				while (rs.next())
				{
					sOrderId = rs.getString(1);
					order_completion_task = new OrderCompletionTask(sOrderId);
					vTaskList.add(order_completion_task);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ",ex); 
		}
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
			String sSleepInterval = Registry.getKey("default_order_setup_sleep");
			if (sSleepInterval != null) lSleepInterval = Long.parseLong(sSleepInterval);
		}
		catch(Exception ex)
		{
			lSleepInterval = 60000;
		}
		
		return lSleepInterval;
	}
}
