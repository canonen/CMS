package com.britemoon.cps;

final public class SleepTask extends BriteTaskGeneric
{
	long m_lSleepInterval = 0;
	
	public SleepTask(long lSleepInterval)
	{
		m_lSleepInterval = lSleepInterval;
		
		// === === ===

		setTaskName("SleepTask");
		
		setCustId("");
		setIdName("SleepInterval");
		setId(String.valueOf(lSleepInterval));
		setStringComment("Timer is sleeping!");

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		BriteTimerGeneric btg = getTimer();
		try
		{
			long lGranularity = 1000;
			for(long l = 0; l < m_lSleepInterval; l += lGranularity)
			{
				if((btg != null) && (btg.isStopping())) break;
				Thread.sleep(lGranularity);
			}
		}
		catch(Exception ex) { ex.printStackTrace(); }
	}
	
	public int retrieve() throws Exception { return 1; }
	public int save() throws Exception { return 1; }
	public int delete() throws Exception { return 1; }
}
