package com.britemoon.cps.xcs.cti;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;

import com.britemoon.cps.xcs.cti.dao.*;
import com.britemoon.cps.imc.*;
import com.britemoon.cps.*;
import com.britemoon.*;

import javax.xml.namespace.QName;
import javax.xml.rpc.ParameterMode;
import java.net.*;
import org.apache.log4j.*;

public class OrderStatusClient
{
	private PackageBrokerWebService m_service;
	private PackageBrokerWebServiceSoap m_port;
	private static Logger logger = Logger.getLogger(OrderStatusClient.class.getName());

	public OrderStatusClient()
	{
          m_service = null;
          m_port = null;
	}

	private String sendStatus(String sCtiOrderId, String sStatus) throws Exception
	 {
          String sReturn = null;

		if (m_port != null) {
               sReturn = m_port.updatePackageStatus(sCtiOrderId,sStatus);
          } else {
               throw new Exception("Error attempting to connect to customer Web Service.  ServicePort is NULL.");
          }
		return sReturn;

/*
          // String endpoint ="http://66.0.5.135/PackageBrokerWebServices/PackageBrokerWebService.asmx";
		org.apache.axis.client.Service sService = null;
		org.apache.axis.client.Call cCall = null;
		try
		{
			sService = new org.apache.axis.client.Service();
			cCall = (org.apache.axis.client.Call) sService.createCall();
			cCall.setPortName(new QName("PackageBrokerWebService"));
			cCall.setTargetEndpointAddress( new java.net.URL(endpoint) );
		}
		catch (Exception e)
		{
			System.out.println("Exception in OrderStatusClient!");
			e.printStackTrace();
			throw new Exception("Error attempting to set up connection to Web Service..." + e.getMessage());
		}
		System.out.println("OrderStatusClient.sendStatus --> CtiOrderID:" + sCtiOrderId + "Status:" + sStatus);
		cCall.setOperationName(new QName("http://cti.xcs.cps.britemoon.com", "updatePackageStatus"));
		String sReturn = (String) cCall.invoke( new Object[] { sCtiOrderId, sStatus } );

		return sReturn;
*/

	}

	public void sendBriteStatus(String sBriteOrderId, int iBriteStatus)
	{
		//System.out.println("OrderStatusClient.sendBriteStatus --> BriteOrderID:" + sBriteOrderId + "Status:" + iBriteStatus);

		try {
               OrderDAO oDao = new OrderDAO();
               String sCustId = null;
               String sCtiOrderId = null;

               // get customer information and customer-specific Web Service connection info
               sCustId = oDao.getCustId(sBriteOrderId);
               getServicePort(sCustId);
               // get customer order ID
               sCtiOrderId = oDao.getCtiOrderId(sBriteOrderId);
		
               // for error statuses, change status number from 910, 920, or 930 to CTI's generic error status-90
               if (iBriteStatus > 900) 
                    iBriteStatus = 90;
		
               String sStatus = String.valueOf(iBriteStatus);   //OrderStatus.getCtiStatus
     		logger.info("Sending Status ID:" + iBriteStatus + " for Britemoon OrderID:" + sBriteOrderId + ";Customer OrderID:" + sCtiOrderId);
               String sReturn = sendStatus(sCtiOrderId, sStatus);
               logger.info("Return value from Customer Web Service:" + sReturn);
          } catch (Exception e) {
               logger.error("***ERROR in OrderStatusClient:\n" , e);
          }
	}

	public void sendBriteStatus(String sCustId, String sCustOrderId, int iBriteStatus)
	{
		//System.out.println("OrderStatusClient.sendBriteStatus --> CustID:" + sCustId + "; CustOrderID:" + sCustOrderId + "; Status:" + iBriteStatus);

		try {
               OrderDAO oDao = new OrderDAO();

               // get customer-specific Web Service connection info
               getServicePort(sCustId);
		
               // for error statuses, change status number from 910, 920, or 930 to CTI's generic error status-90
               if (iBriteStatus > 900) 
                    iBriteStatus = 90;
		
               String sStatus = String.valueOf(iBriteStatus);   //OrderStatus.getCtiStatus
     		logger.info("Sending Status ID:" + iBriteStatus + " for Customer OrderID:" + sCustOrderId);
               String sReturn = sendStatus(sCustOrderId, sStatus);
               logger.info("Return value from Customer Web Service:" + sReturn);
          } catch (Exception e) {
               logger.error("***ERROR in OrderStatusClient:\n", e);
          }
	}

     private void getServicePort(String sCustId) throws Exception {

          if (sCustId == null)
               throw new Exception("Cannot connect to customer Web Service--Customer information could not be determined.");
               
		m_service = new PackageBrokerWebServiceLocator();
          Vector vSvcs = Services.getByCust(ServiceType.CXCS_SEND_CUST_ORDER_STATUS, sCustId);
          com.britemoon.cps.imc.Service svc = (com.britemoon.cps.imc.Service) vSvcs.get(0);
          URL uServiceUrl = svc.getURL();
          logger.info("*** OrderStatusClient \n  URL to customer Web Service is:"+uServiceUrl.toString() + "\n*** OrderStatusClient");
          if (uServiceUrl != null) {
               m_port = m_service.getPackageBrokerWebServiceSoap(uServiceUrl);
          } else {
               throw new Exception("Cannot connect to customer Web Service--URL information could not be found.");
          }

          
     }

	public static void main(String[] args) throws Exception
	{
		OrderStatusClient osc = new OrderStatusClient();
		String sCtiOrderId = "4444";
		String sStatus = "13";

		String sReturn = osc.sendStatus(sCtiOrderId, sStatus);

		logger.info(sReturn);
	}
}
