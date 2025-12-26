package com.britemoon.cps.xcs.cti;


import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.upd.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;
 
public class OrderSetupTask extends BriteTask
{
	private String m_sOrderID = null;
	private static Logger logger = Logger.getLogger(OrderSetupTask.class.getName());

	public OrderSetupTask(String sOrderID) throws Exception
	{
		init(sOrderID);
	}
		
	private void init(String sOrderID)
	{
		m_sOrderID = sOrderID;
		
		// === === ===
		
		setTaskName("OrderSetupTask");
		
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
					+ " SET status_id = " + OrderStatus.PROCESSING + ", status_date = getdate(),"
					+ " status_desc = 'Processing'"
					+ " WHERE brite_order_id = "+sOrderID;
			BriteUpdate.executeUpdate(sSql);
	
			OrderStatusClient osc = new OrderStatusClient();		
			osc.sendBriteStatus(sOrderID, OrderStatus.PROCESSING);
			
			// === UnZip ===
	
			OrderSetupUtil.unzipPackage(sOrderID);
	
			// === SetupCampaign ===
		
			OrderSetupUtil.setupCampaign(sOrderID);
	
			// === SetupContent ===
		
			OrderSetupUtil.setupContent(sOrderID);

			// === Setup Import ===
		
			OrderSetupUtil.setupImport(sOrderID);

			logger.info(this + " order_id = " + sOrderID + " finished at " + new java.util.Date());
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
			logger.error("Exception: ",ex);
			throw ex;
		}
	}
}
