package com.britemoon.sas;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.apache.log4j.*;

import com.britemoon.sas.delivery.DeliveryMonitorTimer;
public final class ContextListener implements ServletContextListener
{
	private ServletContext context = null;
	private static Logger logger = Logger.getLogger(ContextListener.class.getName());
	
	private DeliveryMonitorTimer m_DeliveryMonitorTimer = null;
	
	public void contextInitialized(ServletContextEvent event)
	{
		this.context = event.getServletContext();
		log("ContextListener.contextInitialized()");

		try
		{
			ConnectionPool cp = new ConnectionPool();
			cp.init(context);

			Registry.init(context);
			
			m_DeliveryMonitorTimer = new DeliveryMonitorTimer();
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ", ex);			
		}
	}

	public void contextDestroyed(ServletContextEvent event)
	{
		log("ContextListener.contextDestroyed()");
		if(m_DeliveryMonitorTimer != null) m_DeliveryMonitorTimer.stop();
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
