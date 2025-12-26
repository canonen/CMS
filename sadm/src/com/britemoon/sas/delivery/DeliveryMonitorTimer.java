package com.britemoon.sas.delivery;

import com.britemoon.*;
import com.britemoon.cps.SleepTask;
import com.britemoon.sas.*;

import java.sql.*;
import java.util.*;

public class DeliveryMonitorTimer extends BriteTimer
{

	public Vector buildTaskList()
	{
		Vector vTaskList = new Vector();
		DeliveryMonitorTask task =  new DeliveryMonitorTask();
		vTaskList.add(task);
	
		// sleep anyway
		// if setup failed there is no reasone to retry it immediatelly
		vTaskList.add(new SleepTask(findSleepInterval()));
		
		return vTaskList;
	}

	// === === ===

	public long findSleepInterval()
	{
		long lSleepInterval = 60000; // 60 secs
		
		try
		{
			String sSleepInterval = Registry.getKey("delivery_monitor_sleep_sec");
			if (sSleepInterval != null) lSleepInterval = 1000* Long.parseLong(sSleepInterval);
		}
		catch(Exception ex)
		{
			lSleepInterval = 60000;
		}
		
		return lSleepInterval;
	}
}
