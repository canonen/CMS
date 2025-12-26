package com.britemoon.cps.xcs.cti;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.upd.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;
 
public class OrderCompletionTask extends BriteTask
{
	private String m_sOrderID = null;
	private static Logger logger = Logger.getLogger(OrderCompletionTask.class.getName());

	public OrderCompletionTask(String sOrderID) throws Exception
	{
		init(sOrderID);
	}
		
	private void init(String sOrderID)
	{
		m_sOrderID = sOrderID;
		
		// === === ===
		
		setTaskName("OrderCompletionTask");
		
		setIdName("Order");
		setId(sOrderID);

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		String sOrderID = m_sOrderID;
		startStatic(sOrderID);
	}
	
	public void startStatic(String sOrderID) throws Exception
	{
		logger.info(this + " order_id = " + sOrderID + " started at " + new java.util.Date());

		try
		{
			String sSql = "UPDATE cxcs_order"
					+ " SET status_id = " + OrderStatus.IMPORT_COMPLETE + ", status_date = getdate()"
					+ " WHERE brite_order_id = "+sOrderID;
			BriteUpdate.executeUpdate(sSql);
	
			// === Setup Target Group ===
		
			OrderSetupUtil.setupFilter(sOrderID);
	
			// === Start Campaign ===
		
			OrderSetupUtil.startCampaign(sOrderID);

			// === Update Status ===

			sSql = "UPDATE cxcs_order"
					+ " SET status_id = " + OrderStatus.EXECUTING + ", status_date = getdate(),"
					+ " status_desc = 'Executing'"
					+ " WHERE brite_order_id = "+sOrderID;
			BriteUpdate.executeUpdate(sSql);

			OrderStatusClient osc = new OrderStatusClient();		
			osc.sendBriteStatus(sOrderID, OrderStatus.EXECUTING);

		}
		catch(Exception ex) 
		{
			String sMsg = ex.toString();
			sMsg = (sMsg!=null)?sMsg:"NULL";

			String sSql = "UPDATE cxcs_order"
				+ " SET status_id = " + OrderStatus.ERROR_PROCESSING + ", status_date = getdate(),"
				+ " status_desc = '" + sMsg.replaceAll("'","''") + "'"
				+ " WHERE brite_order_id = "+sOrderID;
			BriteUpdate.executeUpdate(sSql);

			OrderStatusClient osc = new OrderStatusClient();		
			osc.sendBriteStatus(sOrderID, OrderStatus.ERROR_PROCESSING);
			
			logger.info(this + " order_id = " + sOrderID + " finished WITH ERROR at " + new java.util.Date());
			logger.error("Exception: " , ex);
			throw ex;
		}
	}
}
