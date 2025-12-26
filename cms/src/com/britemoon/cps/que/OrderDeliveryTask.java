package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.xcs.cti.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class OrderDeliveryTask extends BriteTask
{
	private Campaign m_Camp = null;
	private String m_chunk_id = null;
	private String m_file_url = null;
	private static Logger logger = Logger.getLogger(OrderDeliveryTask.class.getName());

	public OrderDeliveryTask(String sCampId, String sChunkId, String sFileUrl) throws Exception
	{
		Campaign camp = new Campaign(sCampId);
		m_chunk_id = sChunkId;
		m_file_url = sFileUrl;
		init(camp);
	}
		
	public OrderDeliveryTask(Campaign camp)
	{
		init(camp);
	}
	
	private void init(Campaign camp)
	{
		m_Camp = camp;
		
		// === === ===
		
		setTaskName("OrderDeliveryTask");
		
		setCustId(camp.s_cust_id);
		setIdName("Campaign");
		setId(camp.s_camp_id);
		setStringComment(camp.s_camp_name);

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		String sCampId = m_Camp.s_camp_id;
		String sCustId = m_Camp.s_cust_id;
		String sChunkId = m_chunk_id;
		String sFileUrl = m_file_url;
		logger.info(this + " camp_id = " + sCampId + " started at " + new java.util.Date());
		startStatic(sCustId, sCampId, sChunkId, sFileUrl);
		logger.info(this + " camp_id = " + sCampId + " finished at " + new java.util.Date());
	}
	
	public static void startStatic(String sCustId, String sCampId, String sChunkId, String sFileUrl) throws Exception
	{
		try {			
			// update status
			String sSql =
				" UPDATE cxcs_delivery " +
				"    SET status = 1 " +
				"  WHERE camp_id = " + sCampId +
				"    AND chunk_id = " + sChunkId;
			BriteUpdate.executeUpdate(sSql);
			
			logger.info("Calling WS to deliver print order:");
			logger.info("           camp_id = " + sCampId);
			logger.info("           chunk_id = " + sChunkId);
			logger.info("           file_url = " + sFileUrl);

			com.britemoon.cps.xcs.cti.CTIDelivery cti = new com.britemoon.cps.xcs.cti.CTIDelivery();
			cti.deliverOrder(sCustId, sCampId, sChunkId, sFileUrl);
			
			// update order submission date
			String sSql2 =
				" UPDATE cxcs_delivery " +
				"    SET submit_date = getDate() " +
				"  WHERE camp_id = " + sCampId +
				"    AND chunk_id = " + sChunkId;
			BriteUpdate.executeUpdate(sSql2);

		}
		catch (Exception ex){
			logger.error("Exception: ", ex);
			throw ex;
		}
	}
}
