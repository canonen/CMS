package com.britemoon.cps;

import java.util.*;

public class TimerManager
{
	private static Vector m_vTimerNames = new Vector();
	private static Hashtable m_htTimers = new Hashtable();
	
	final static synchronized void addTimer(BriteTimerGeneric timer) throws Exception
	{
		Object o = m_htTimers.get(timer.getTimerName());
		if (o != null)
			throw new Exception("Timer manager ERROR: Cannot register Timer: " + timer.getTimerName() + " Timer already exists.");
		else
		{
			m_htTimers.put(timer.getTimerName(), timer);
			m_vTimerNames.add(timer.getTimerName());
		}
	}

	// === === ===
	
	public static Vector getTimerNames() { return m_vTimerNames;}
	public static Hashtable getTimers() { return m_htTimers; }

	public static BriteTimerGeneric getTimer(String sTimerName)
	{
		return (BriteTimerGeneric) m_htTimers.get(sTimerName);
	}

	public static synchronized BriteTimerGeneric removeTimer(String sTimerName)
	{
		BriteTimerGeneric timer = (BriteTimerGeneric) m_htTimers.remove(sTimerName);
		if ( timer != null )
		{
			m_vTimerNames.remove(timer.getTimerName());
			timer.stop();
		}
		return timer;
	}

	public static synchronized BriteTimerGeneric removeTimer(BriteTimerGeneric timer)
	{
		if(timer == null) return timer;
		return removeTimer(timer.getTimerName());
	}

	// === === ===
	
	final public static void startAllTimers()
	{
		BriteTimerGeneric bt = null;
		for (Enumeration e = m_htTimers.elements() ; e.hasMoreElements() ;)
		{
			bt = (BriteTimerGeneric)e.nextElement();
			bt.start();
		}
	}

	final public static void stopAllTimers()
	{
		BriteTimerGeneric bt = null;
		for (Enumeration e = m_htTimers.elements() ; e.hasMoreElements() ;)
		{
			bt = (BriteTimerGeneric)e.nextElement();
			bt.stop();
		}
	}
}

