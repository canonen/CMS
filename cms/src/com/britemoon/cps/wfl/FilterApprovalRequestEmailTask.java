package com.britemoon.cps.wfl;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.tgt.*;
import com.britemoon.cps.imc.*;
import org.w3c.dom.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;
 
public class FilterApprovalRequestEmailTask extends BriteTask
{
	private String m_sApprovalRequestId = null;
	private String m_sFilterId = null;
	private static Logger logger = Logger.getLogger(FilterApprovalRequestEmailTask.class.getName());		

	public FilterApprovalRequestEmailTask(String sApprovalRequestId, String sFilterId) throws Exception
	{
		init(sApprovalRequestId, sFilterId);
	}
		
	private void init(String sApprovalRequestId, String sFilterId)
	{
		m_sApprovalRequestId = sApprovalRequestId;
		m_sFilterId = sFilterId;
		
		// === === ===
		
		setTaskName("FilterApprovalRequestEmailTask");
		
		setIdName("ApprovalRequest");
		setId(sApprovalRequestId);

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		startStatic(m_sApprovalRequestId, m_sFilterId);
	}
	
	public void startStatic(String sApprovalRequestId, String sFilterId) throws Exception
	{
		logger.info(this + " request_approval_id = " + sApprovalRequestId + " started at " + new java.util.Date());

/*          com.britemoon.cps.tgt.Filter filter = null;
          String sFilterXml = null;
		Element eFilter = null;
          int iStatus = 0;

          filter = new com.britemoon.cps.tgt.Filter(sFilterId);
*/
		try
		{
/*               sFilterXml = filter.toXml();
               Vector services = Services.getByCust(ServiceType.RRCP_FILTER_STATISTIC_GET, filter.s_cust_id);
               Service service = (Service) services.get(0);
               sFilterXml = service.communicate(sFilterXml);
               eFilter = XmlUtil.getRootElement(sFilterXml);
               filter = new com.britemoon.cps.tgt.Filter(eFilter);

               iStatus = Integer.parseInt(filter.s_status_id);

               // Only send emails for Filters that have completed processing on RCP (READY status) 
               if (iStatus == FilterStatus.READY) {
                    if( filter.m_FilterStatistic != null )
                         filter.m_FilterStatistic.save();
               }
*/               
                    WorkflowEmailUtil.sendFilterApprovalRequestEmail(sApprovalRequestId, sFilterId);

		}
		catch(Exception ex) 
		{
			throw ex;
		}
	}
}
