package com.britemoon.cps;


import java.sql.*;
import java.util.*;

public abstract class BriteTimerGeneric implements Runnable
{
	protected BriteTimerGeneric()
	{
		// === this is crap, but right now there is no time to do it right ===	
		
		String sName = this.getClass().getName();
		if(sName.indexOf("com.britemoon.cps") != -1) return;
		
		// === === ===
		
		init();
	}

	protected void init()
	{
		if (getTimerName() == null)
		{
			String sName = this.getClass().getName().replaceFirst("com.britemoon.","");
			setTimerName(sName);
		}
		
		try { registerTimer(); }
		catch(Exception ex)
		{
			// this is a trick to throw exception without declaration;
			throw new NullPointerException(ex.getMessage());
		}
	}

	// === === ===
	
	private Thread m_Thread = null;

	private String m_sTimerId = null;
	private String m_sTimerName = null;

	private Vector m_vTaskList = null;
	private BriteTaskGeneric m_btCurrentTask = null;
	
	long m_lSleepInterval = 1000;

	private boolean m_isStarted = false;
	private boolean m_isWorking = false;	
	private boolean m_bStop = true;		

	// === === ===
	
	private boolean m_bSequential = true;
	public boolean isSequential() { return m_bSequential; }
	public void setSequential(boolean bSequential) { m_bSequential = bSequential; }
	
	// === === ===

	final protected void registerTimer() throws Exception { registerTimer(this); }
	final protected static void registerTimer(BriteTimerGeneric timer) throws Exception
	{
		TimerManager.addTimer(timer);
	}

	// === === ===
	
	final public void start()
	{
		// === do not start timer if  m_lSleepInterval <= 0

		boolean bDontStart = true;		
		try
		{
			m_lSleepInterval = findSleepInterval();
			if(m_lSleepInterval > 0) bDontStart = false;
		}
		catch(Exception ex) { reportException(ex); }
		if(bDontStart) return;

		// === === ===
		
		m_bStop = false;
		if (m_isStarted) return;
		m_Thread = new Thread(this);
		m_Thread.start();
	}

	final public void stop() { m_bStop = true; }

	final public void run()
	{
		synchronized(this)
		{
			if(m_isStarted)return;
			m_isStarted = true;
			notifyAll();
		}
		
		System.out.println(m_sTimerName + " is started.");

		int iTaskCount = 0;
		
		while (!m_bStop)
		{
			try
			{
				m_vTaskList = buildTaskList();
			}
			catch (Exception ex)
			{
				reportException(ex);
				break;
			}

			iTaskCount = (m_vTaskList == null) ? 0 : m_vTaskList.size();
			
			if((iTaskCount == 0)&&(!m_bStop)) goToSleep();
			else runTasks();
		}
		
		m_isStarted = false;
		System.out.println(m_sTimerName + " is stopped.");
	}

	final private void runTasks()
	{
		if (m_vTaskList == null) return;
		
		m_isWorking = true;

		int iTaskCount = m_vTaskList.size();

		for(int i = 0; i < iTaskCount; i++)
		{
			try
			{
				m_btCurrentTask = (BriteTaskGeneric) m_vTaskList.get(i);
				m_btCurrentTask.setTimer(this);
				
				if ("SleepTask".equals(m_btCurrentTask.getTaskName())) m_btCurrentTask.run();
				else if(isSequential()) m_btCurrentTask.run();
				else new Thread(m_btCurrentTask).start();
			}
			catch(Exception ex) { reportException(ex); }
			finally { m_btCurrentTask = null; }
			if(m_bStop) break;
		}

		m_isWorking = false;		
	}

	/* send an interrupt to all tasks of this timer, not sure if it does any good */
	final protected void interruptTasks()
	{
		int iTaskCount = m_vTaskList.size();

		for(int i = 0; i < iTaskCount; i++)
		{
			try
			{
				m_btCurrentTask = (BriteTaskGeneric) m_vTaskList.get(i);
				m_btCurrentTask.notifyAll();
				new Thread(m_btCurrentTask).interrupt();
			}
			catch(Exception ex) { reportException(ex); }
			finally { m_btCurrentTask = null; }
		}

	}
	
	/* wake up all tasks, clear the timer task list. we can use this to start a new instance of the timer */
	final protected void notifyTasks()
	{
		int iTaskCount = m_vTaskList.size();

		for(int i = 0; i < iTaskCount; i++)
		{
			try
			{
				m_btCurrentTask = (BriteTaskGeneric) m_vTaskList.get(i);
				m_btCurrentTask.notifyAll();
			}
			catch(Exception ex) { reportException(ex); }
			finally { m_btCurrentTask = null; }
		}
		m_vTaskList.clear();
		m_vTaskList = null;
		m_isStarted = false;;
	}
	
	final private void goToSleep()
	{
		try	{ m_lSleepInterval = findSleepInterval(); }
		catch(Exception ex) { reportException(ex); }
		
		if(m_lSleepInterval < 1000) m_lSleepInterval = 1000;
		
		try
		{
			long lGranularity = 1000;
			for(long l = 0; l < m_lSleepInterval; l += lGranularity)
			{
				if(m_bStop) break;
				Thread.sleep(lGranularity);
			}
		}
		catch(Exception ex) { reportException(ex); }
	}

	final private void reportException(Exception ex)
	{
		System.out.println("\r\n" + this + " ERROR:");
		ex.printStackTrace();
	}
	
	// === === ===
		
	abstract public long findSleepInterval();
	abstract public Vector buildTaskList();

	// === === ===

	public final String getTimerId() { return  m_sTimerId; }
	public final String getTimerName() { return m_sTimerName; }
	public final void setTimerName(String sTimerName) { m_sTimerName = sTimerName; }	
		
	public final boolean isStarted() { return m_isStarted; }
	public final boolean isWorking() { return m_isWorking; }
	public final boolean isStopping() { return m_bStop; }
	public final long getSleepInterval() { return m_lSleepInterval; }	

	final public BriteTaskGeneric getCurrentTask() { return m_btCurrentTask; }
	final public Vector getTaskList() { return m_vTaskList; }
}

