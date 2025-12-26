/**
 * CtiImpl.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.britemoon.cps.xcs.cti;

import com.britemoon.cps.xcs.cti.bean.*;
import com.britemoon.cps.xcs.cti.dao.*;

import org.apache.axis.MessageContext;
import org.apache.log4j.*;

public class CtiMarshImpl  {

	private static Logger logger = Logger.getLogger(CtiMarshImpl.class.getName());
     public MessageActivity[] getMessageActivity(String sOrderId, String sCtiOrderIndex, String sLastId) throws Exception {
         //  System.out.println("In CPS CtiMarshImpl.getMessageActivity"); 
         String sCustIdFromAxis = (String)MessageContext.getCurrentContext().getProperty("CUST_ID");
         if (sCustIdFromAxis == null || sCustIdFromAxis.equals("")) {
              throw new Exception("Incomplete customer ID information");
         }

//         String sCustIdFromAxis = "32";
         //System.out.println("In CPS CtiMarshImpl.getMessageActivity()...custId retrieved from MessageContext is:"+sCustIdFromAxis);
         try {
              MessageActivityDAO maDAO = new MessageActivityDAO(sCustIdFromAxis);
              //System.out.println("CPS WS - about to get MessageActivity[]s");
              MessageActivity[] maMsgs = maDAO.getMessageActivity(sCustIdFromAxis, sOrderId, sCtiOrderIndex, sLastId);
               if (maMsgs != null && maMsgs.length > 0)
                    logger.info("CPS-CtiMarshImpl.getMessageActivity:  Exiting... Number of MessageActivity objects retrieved:" + maMsgs.length);
               else
                    logger.info("CPS-CtiMarshImpl.getMessageActivity:  Exiting... NO MessageActivity objects retrieved.");
              return maMsgs;
         } catch (Exception e) 
		 {
              logger.error("Exception: ", e);
              throw new Exception("Exception thrown while attempting to retrieve Message Actions.  \n"+e.getMessage());
         }
    }

    public ClickActivity[] getClickActivity(String sOrderId, String sCtiOrderIndex, String sLastId) throws Exception {
         //  System.out.println("In CPS CtiMarshImpl.getClickActivity"); 
         String sCustIdFromAxis = (String)MessageContext.getCurrentContext().getProperty("CUST_ID");
         if (sCustIdFromAxis == null || sCustIdFromAxis.equals("")) {
              throw new Exception("Incomplete customer ID information");
         }

//         String sCustIdFromAxis = "32";
         //System.out.println("In CPS CtiMarshImpl.getClickActivity()...custId retrieved from MessageContext is:"+sCustIdFromAxis);
         try {
              ClickActivityDAO caDAO = new ClickActivityDAO(sCustIdFromAxis);
              // System.out.println("CPS WS - about to get ClickActivity[]s");
              ClickActivity[] caClicks = caDAO.getClickActivity(sCustIdFromAxis, sOrderId, sCtiOrderIndex, sLastId);
               if (caClicks != null && caClicks.length > 0)
                    logger.info("CPS-CtiMarshImpl.getClickActivity:  Exiting... Number of Clicks retrieved:" + (caClicks.length));
               else
                    logger.info("CPS-CtiMarshImpl.getClickActivity:  Exiting... NO Clicks retrieved.");
              return caClicks;
         } catch (Exception e) 
		 {
              logger.error("Exception: ", e);
              throw new Exception("Exception thrown while attempting to retrieve Click Actions.  \n"+e.getMessage());
         }
    }

     public int getClickActivityQty(String sOrderId, String sCtiOrderIndex) throws Exception{
          int iQty = 0;
         //  System.out.println("In CPS CtiMarshImpl.getClickActivityQty"); 
         String sCustIdFromAxis = (String)MessageContext.getCurrentContext().getProperty("CUST_ID");
         if (sCustIdFromAxis == null || sCustIdFromAxis.equals("")) {
              throw new Exception("Incomplete customer ID information");
         }

          ClickActivityDAO caDAO = new ClickActivityDAO(sCustIdFromAxis);
          try {
               iQty = caDAO.getClickActivityQty(sOrderId, sCtiOrderIndex);
          } catch (Exception e) 
		  {
               logger.error("Exception: ",e);
          }
          return iQty;
     }

     public int getMessageActivityQty(String sOrderId, String sCtiOrderIndex) throws Exception{
          int iQty = 0;
         //  System.out.println("In CPS CtiMarshImpl.getMessageActivityQty"); 
         String sCustIdFromAxis = (String)MessageContext.getCurrentContext().getProperty("CUST_ID");
         if (sCustIdFromAxis == null || sCustIdFromAxis.equals("")) {
              throw new Exception("Incomplete customer ID information");
         }

          MessageActivityDAO maDAO = new MessageActivityDAO(sCustIdFromAxis);
          try {
               iQty = maDAO.getMessageActivityQty(sOrderId, sCtiOrderIndex);
          } catch (Exception e) 
		  {
               logger.error("Exception: ", e);
          }
          return iQty;
     }



}
