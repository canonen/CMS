package com.britemoon.cps.xcs.cti.dao;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.xcs.cti.bean.*;

import com.britemoon.cps.xcs.cti.*;
import com.britemoon.cps.imc.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.net.*;
import org.apache.log4j.*;


public class MessageActivityDAO
{
     private String m_sCustId;
     private static Logger logger = Logger.getLogger(MessageActivityDAO.class.getName());

	public MessageActivityDAO(String sCustId) {
          m_sCustId = sCustId;
	}

     public int getMessageActivityQty(String sCtiOrderId, String sOrderIndex) throws Exception {
          int iQty = 0;

          try {
               String sCampId = getCampId(sCtiOrderId, sOrderIndex);
               URL uServiceUrl = getRcpUrl();
                    
               // Connect to the Web Service
               CtiImcWebServiceService service = new CtiImcWebServiceServiceLocator();
               CtiImcWebService port = service.getCtiIMC(uServiceUrl);

               iQty = port.getMessageActivityQty(m_sCustId, sCampId);

          } catch (Exception e) 
		  {
               logger.error("Exception: ", e);
               throw e;
          }

          return iQty;
     }


	public MessageActivity[] getMessageActivity(String sCustId, String sCtiOrderId, String sOrderIndex, String sLastId) throws Exception {

          // System.out.println("In " + this.getClass().getName() + "  custID:"+sCustId+"; CTIOrderID:"+sCtiOrderId+"; OrderIndex:"+sOrderIndex+"; LastId:" + sLastId + ".");
          MessageActivity[] maMsgs = null;

          try {
               //System.out.println("got data on CPS side...");
               // go get data from RCP
               String sCampId = getCampId(sCtiOrderId, sOrderIndex);

               // get URL to correct RCP
               URL uServiceUrl = getRcpUrl();

               //Connect to the Web Service
               CtiImcWebServiceService service = new CtiImcWebServiceServiceLocator();
               CtiImcWebService port = service.getCtiIMC(uServiceUrl);

               maMsgs = port.getMessageActivity(m_sCustId,sCampId,sCtiOrderId,sLastId);


               if (maMsgs != null)
                    logger.info("CPS-MessageActivityDAO:  Exiting... Number of MessageActivity objects retrieved:" + maMsgs.length);
               else
                    logger.info("CPS-MessageActivityDAO:  Exiting... NO MessageActivity objects retrieved.");
               return maMsgs;
          } catch (Exception e) 
		  {
          	   logger.error("Exception: ", e); 	
               throw new Exception("Exception thrown during database retrieval of Message Activity data.\n"+e.getMessage());
          } 

	}

     private String getCampId(String sCtiOrderId, String sOrderIndex) throws Exception {
          String sCampId = null;
          ConnectionPool cp = null;
          Connection conn = null;
          PreparedStatement pstmt = null;
          ResultSet rs = null;

          try {
               cp = ConnectionPool.getInstance();
               conn = cp.getConnection(this);

               String sSql = "Select obo.brite_object_id " +
                                        " FROM cxcs_order o, cxcs_order_brite_object obo " +
                                        " WHERE o.cust_order_id = ? AND " +
                                        " o.brite_order_id = obo.brite_order_id AND " +
                                        " obo.index_id = ? AND " +
                                        " obo.type_id = " + ObjectType.CAMPAIGN;
               pstmt = conn.prepareStatement(sSql);
               pstmt.setString(1, sCtiOrderId);
               if (sOrderIndex != null) 
                    pstmt.setString(2,sOrderIndex);
               else
                    pstmt.setString(2,"0");
                    
               rs = pstmt.executeQuery();
               if (rs.next()) {
                    sCampId = rs.getString(1);
               }
               rs.close();

          } catch (Exception e) 
		  {
          	logger.error("Exception: ", e);
               throw e;
          } finally {
               if (pstmt != null) {
                    try {
                         pstmt.close();
                    } catch (Exception e) {
                         throw e;
                    }
               }
               if (cp != null) cp.free(conn);
          }


          return sCampId;
     }

     private URL getRcpUrl() throws SQLException, MalformedURLException {

          URL uServiceUrl = null;

          Vector vSvcs = Services.getByType(ServiceType.RXCS_ACTIVITY_DATA_REQUEST);
          Service svc = (Service) vSvcs.get(0);
          uServiceUrl = svc.getURL();
             //  uServiceUrl = new URL("http://localhost/rrcp/services/CtiIMC");
             //  System.out.println("About to call service at:" + uServiceUrl.toString());

          return uServiceUrl;
          
     }



}

