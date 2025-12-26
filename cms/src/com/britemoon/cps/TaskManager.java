package com.britemoon.cps;

import java.util.*;

public class TaskManager
{
	private static Vector m_vTasks = new Vector();

	public static synchronized boolean addTask(BriteTaskGeneric btg)
	{
		return m_vTasks.add(btg);
	}
	
	public static synchronized boolean removeTask(BriteTaskGeneric btg)
	{
		return m_vTasks.remove(btg); 
	}
	
	public static Vector getTasks()
	{
		return m_vTasks;
	}
}