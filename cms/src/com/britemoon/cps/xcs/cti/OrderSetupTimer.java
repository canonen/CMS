package com.britemoon.cps.xcs.cti;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.upd.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class OrderSetupTimer extends BriteTimer
{
	private static Logger logger = Logger.getLogger(OrderSetupTimer.class.getName());
	public OrderSetupTimer(String sTimerNameSuffix)
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
			conn = cp.getConnection("OrderSetupTimer");

			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT brite_order_id"
					+ " FROM cxcs_order"
					+ " WHERE status_id = 10" //OrderStatus.RECEIVED
					+ " ORDER BY brite_order_id";
					
				rs = stmt.executeQuery(sSql);
				
				String sOrderId = null;

				byte[] b = null;
				OrderSetupTask order_setup_task = null;				
				while (rs.next())
				{
					sOrderId = rs.getString(1);
					order_setup_task = new OrderSetupTask(sOrderId);
					vTaskList.add(order_setup_task);
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
