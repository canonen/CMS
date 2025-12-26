package com.britemoon.cps;

import com.britemoon.cps.adm.UserNotifyTimer;
import com.britemoon.cps.ctm.TemplateBean;
import com.britemoon.cps.que.CampSetupTimer;
import com.britemoon.cps.que.OrderDeliveryTimer;
import com.britemoon.cps.ftp.ImportProcessTimer;
import com.britemoon.cps.ftp.OfferProcessTimer;
import com.britemoon.cps.ftp.FTPTaskTimer;
import com.britemoon.cps.wfl.ApprovalRequestEmailTimer;
import com.britemoon.cps.xcs.cti.OrderCompletionTimer;
import com.britemoon.cps.xcs.cti.OrderSetupTimer;
import com.britemoon.cps.xcs.cti.OrderStatusTimer;
//import com.britemoon.cps.xcs.dts.WsCampImportTimer;


import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.apache.log4j.Logger;


public final class ContextListener implements ServletContextListener
{
	private ServletContext context = null;
	
	// === === ===

	private CampSetupTimer m_CampSetupTimer = null;

	private OrderSetupTimer m_OrderSetupTimer = null;
	private OrderCompletionTimer m_OrderCompletionTimer = null;
	private OrderStatusTimer m_OrderStatusTimer = null;
	private OrderDeliveryTimer m_OrderDeliveryTimer = null;
	private ApprovalRequestEmailTimer m_ApprovalRequestEmailTimer = null;
	//private WsCampImportTimer m_WsCampImportTimer = null;
	private FTPTaskTimer m_FTPTaskTimer = null;
	
	private ImportProcessTimer m_ImportProcessTimer = null;
	private OfferProcessTimer m_OfferProcessTimer = null;
	
	private UserNotifyTimer m_UserNotifyTimer = null;

	static Logger logger = Logger.getLogger(ContextListener.class.getName());
	
	// === === ===
	
	public void contextInitialized(ServletContextEvent event)
	{
		this.context = event.getServletContext();
		log("ContextListener.contextInitialized()");

		try
		{
			ConnectionPool cp = new ConnectionPool();
			cp.init(context);
			
			Registry.init(context);
			String sTimerNameSuffix = context.getInitParameter("JdbcUrl");
			sTimerNameSuffix = sTimerNameSuffix.replaceAll("jdbc:odbc:brite_","");
			m_CampSetupTimer = new CampSetupTimer(" @ " + sTimerNameSuffix);
			m_OrderSetupTimer = new OrderSetupTimer(" @ " + sTimerNameSuffix);
			m_OrderCompletionTimer = new OrderCompletionTimer(" @ " + sTimerNameSuffix);
			m_OrderStatusTimer = new OrderStatusTimer(" @ " + sTimerNameSuffix);
			m_OrderDeliveryTimer = new OrderDeliveryTimer(" @ " + sTimerNameSuffix);
			m_ApprovalRequestEmailTimer = new ApprovalRequestEmailTimer(" @ " + sTimerNameSuffix);
		//	m_WsCampImportTimer = new WsCampImportTimer(" @ " + sTimerNameSuffix);
			m_FTPTaskTimer = new FTPTaskTimer(" @ " + sTimerNameSuffix);
			m_ImportProcessTimer = new ImportProcessTimer(" @ " + sTimerNameSuffix);
			m_OfferProcessTimer = new OfferProcessTimer(" @ " + sTimerNameSuffix);
			m_UserNotifyTimer = new UserNotifyTimer(" @ " + sTimerNameSuffix, context);
		}
		
		catch(Exception ex) { ex.printStackTrace(); }
		
		try
		{
			ConnectionPool cp = new ConnectionPool();
			cp.init(context);

			new TemplateBean().loadAllTemplatesInSeperateThread(context);
		}
		catch(Exception ex)
		{
			logger.error("Error while initializing loading templates" , ex);
		}
	}

	public void contextDestroyed(ServletContextEvent event)
	{
		if(m_CampSetupTimer != null) m_CampSetupTimer.stop();

		if(m_OrderSetupTimer != null) m_OrderSetupTimer.stop();
		if(m_OrderCompletionTimer != null) m_OrderCompletionTimer.stop();
		if(m_OrderStatusTimer != null) m_OrderStatusTimer.stop();
		if(m_OrderDeliveryTimer != null) m_OrderDeliveryTimer.stop();
		if(m_ApprovalRequestEmailTimer != null) m_ApprovalRequestEmailTimer.stop();
	//	if(m_WsCampImportTimer != null) m_WsCampImportTimer.stop();
		if(m_ImportProcessTimer != null) m_ImportProcessTimer.stop();
		if(m_OfferProcessTimer != null) m_OfferProcessTimer.stop();

		if(m_UserNotifyTimer != null) m_UserNotifyTimer.stop();

		log("ContextListener.contextDestroyed()");
		this.context = null;
	}

	// === === ===

	private void log(String message)
	{
		if (context != null) context.log("ContextListener: " + message);
		else logger.info("ContextListener: " + message);
	}

	private void log(String message, Throwable throwable)
	{
		if (context != null) context.log("ContextListener: " + message, throwable);
		else
		{
			logger.info("ContextListener: " + message);
			throwable.printStackTrace(System.out);
		}
	}
}
