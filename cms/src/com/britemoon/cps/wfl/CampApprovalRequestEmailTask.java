package com.britemoon.cps.wfl;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.upd.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;
 
public class CampApprovalRequestEmailTask extends BriteTask
{
	private String m_sApprovalRequestId = null;
	private String m_sCampId = null;
	private static Logger logger = Logger.getLogger(CampApprovalRequestEmailTask.class.getName());	

	public CampApprovalRequestEmailTask(String sApprovalRequestId, String sCampId) throws Exception
	{
		init(sApprovalRequestId, sCampId);
	}
		
	private void init(String sApprovalRequestId, String sCampId)
	{
		m_sApprovalRequestId = sApprovalRequestId;
		m_sCampId = sCampId;
		
		// === === ===
		
		setTaskName("CampApprovalRequestEmailTask");
		
		setIdName("ApprovalRequest");
		setId(sApprovalRequestId);

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		startStatic(m_sApprovalRequestId, m_sCampId);
	}
	
	public void startStatic(String sApprovalRequestId, String sCampId) throws Exception
	{
//		System.out.println(this + " request_approval_id = " + sApprovalRequestId + " started at " + new java.util.Date());

		try
		{
               WorkflowEmailUtil.sendCampApprovalRequestEmail(sApprovalRequestId, sCampId);
		}
		catch(Exception ex) 
		{
			throw ex;
		}
	}
}
