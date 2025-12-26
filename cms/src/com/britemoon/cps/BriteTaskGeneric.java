package com.britemoon.cps;


import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;

public abstract class BriteTaskGeneric implements Runnable
{
	private boolean m_isRunning = false;
	private boolean m_bSkip = false;

	private String m_sTaskId = null;
	private String m_sTaskName = null;

	private String m_sCustId = null;
	private String m_sIdName = null;
	private String m_sId = null;
	private String m_sNumberComment = null;
	private String m_sDateComment = null;
	private String m_sStringComment = null;	

	private java.util.Date m_dCreateDate = null;
	private java.util.Date m_dStartDate = null;
	private java.util.Date m_dFinishDate = null;

	private Exception m_ex = null;

	// === === ===

	private BriteTimerGeneric m_Timer = null;
	public final void setTimer(BriteTimerGeneric timer) { m_Timer = timer; }
	public final BriteTimerGeneric getTimer() { return m_Timer; }
	
	// === === ===

	public final boolean isRunning() { return m_isRunning; }
	public final boolean isSkipped() { return m_bSkip; }

	public final String getTaskId() { return m_sTaskId; }
	public final String getTaskName() { return  m_sTaskName; }
	
	public final String getCustId() { return  m_sCustId; }
	public final String getIdName() { return  m_sIdName; }
	public final String getId() { return  m_sId; }
	public final String getNumberComment() { return m_sNumberComment; }
	public final String getDateComment() { return m_sDateComment; }
	public final String getStringComment() { return m_sStringComment; }		
	
	public final java.util.Date getCreateDate() { return m_dCreateDate; }	
	public final java.util.Date getStartDate() { return m_dStartDate; }
	public final java.util.Date getFinishDate() { return m_dFinishDate; }
	
	public final Exception getException() { return m_ex; }

	// === === ===	

	public final void setTaskId(String sTaskId) { m_sTaskId = sTaskId; }
	public final void setTaskName(String sTaskName) { m_sTaskName = sTaskName; }
	
	public final void setCustId(String sCustId) { m_sCustId = sCustId; }
	public final void setIdName(String sIdName) { m_sIdName = sIdName; }
	public final void setId(String sId) { m_sId = sId; }
	public final void setNumberComment(String sNumberComment) { m_sNumberComment = sNumberComment; }
	public final void setDateComment(String sDateComment) { m_sDateComment = sDateComment; }
	public final void setStringComment(String sStringComment) { m_sStringComment = sStringComment; }		
	
	protected final void setCreateDate(java.util.Date dCreateDate) { m_dCreateDate = dCreateDate; }	
	protected final void setStartDate(java.util.Date dStartDate) { m_dStartDate = dStartDate; }
	protected final void setFinishDate(java.util.Date dFinishDate) { m_dFinishDate = dFinishDate; }	
	
	public final void setException(Exception ex) { m_ex = ex; }
		
	// === === ===
	
    public final void run()
    {
		if(m_bSkip) return;
		
        m_isRunning = true;

		boolean bIsSleepTask = "SleepTask".equals(getTaskName());
							
		try
		{
			m_dStartDate = new java.util.Date();
			if (!bIsSleepTask)
			{
				TaskManager.addTask(this);
				save();
			}
			start();
			m_dFinishDate = new java.util.Date();
			if (!bIsSleepTask) save();
		}
		catch(Exception ex)
		{
			m_ex = ex;
			ex.printStackTrace();
		}
		finally
		{
			if (!bIsSleepTask) TaskManager.removeTask(this);
			m_isRunning = false;			
		}
    }

	public final void skip() { m_bSkip = true; }
	public final void unskip() { m_bSkip = false; }
	
	// === === ===
	
    abstract public void start() throws Exception;
    abstract public int retrieve() throws Exception;
    abstract public int save() throws Exception;
    abstract public int delete() throws Exception;	
	
	// === === ===
}
