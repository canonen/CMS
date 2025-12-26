package com.britemoon.cps.xcs.cti;

import org.apache.axis.attachments.Attachments;
import org.apache.axis.attachments.AttachmentPart;
import org.apache.axis.AxisFault;
import org.apache.axis.MessageContext;
import org.apache.axis.*;
import javax.activation.*;
import java.io.*;
import java.util.*;
import java.util.zip.*;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.xcs.cti.bean.*;

import java.sql.*;
import org.apache.log4j.*;

public class CTIDeliveryStatus
{

     private static final int RECEIVED = 3;
     private static final int PRINTED = 5;
     private static final int SHIPPED = 6;
     private static final int DONE = 7;

     private static Logger logger = Logger.getLogger(CTIDeliveryStatus.class.getName());
     public int setOrderStatus(String sOrderId, int iOrderStatus)
	{
		int iStatus = -1;
		
		MessageContext context = MessageContext.getCurrentContext();
		String custId = (String) context.getProperty("CUST_ID");
          //custId = "32";
		
		if (sOrderId == null || sOrderId.equals("")) {
               iStatus = -1;
			logger.error("Order ID was null or empty string.");
//			throw new AxisFault(status);
		}
		
		if (custId == null || custId.equals("")) {
			iStatus = -1;
               logger.error("Unable to process order due to internal system problem (cust id not found)");
//			throw new AxisFault(status);
		}
		logger.info("Found cust id = " + custId);
          logger.info("status:" + iOrderStatus);
		
		try {

			// update status
			String sql =
				"UPDATE cxcs_delivery " +
				"   SET confirm_date = getDate(), status=" + iOrderStatus +
				"  WHERE order_id = '" + sOrderId + "'";	   
               logger.info("Sql to update delivery table:" + sql);
			int rc = BriteUpdate.executeUpdate(sql);		
			if (rc != 1) {
                    logger.info("return from BriteUpdate update cxcs_delivery is:" + rc);
				throw new Exception ("unable to update database");
			}
               Campaign camp = new Campaign();
               CampStatistic cstat = new CampStatistic();
               CampSendParam csp = new CampSendParam();
               Schedule sched = new Schedule();
               String sCampId = null;
               
               java.util.Date dNow = new java.util.Date();
			java.util.Date dEndDate = null;
			java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
               String sNow = df.format(dNow);

               //String sNow = "" + cal.get(cal.YEAR) + "-" + (cal.get(cal.MONTH)+1) + "-" + cal.get(cal.DAY_OF_MONTH) + " " + cal.get(cal.HOUR_OF_DAY) + ":" + cal.get(cal.MINUTE);

               ConnectionPool cp	= null;
               Connection conn		= null;
               Statement stmt		= null;
               ResultSet rs		= null;

               String sSql = null;
               try
               {
                    cp = ConnectionPool.getInstance();
                    conn = cp.getConnection(this);
                    stmt = conn.createStatement();
                    sSql = "select camp_id from cxcs_delivery where order_id = '" + sOrderId + "'";

                    rs = stmt.executeQuery(sSql);
                    if (rs.next()) {
                         sCampId = rs.getString(1);
                    }
                    rs.close();

                    if (sCampId != null) {
                         logger.info("Campaign ID:" + sCampId + " from order:" + sOrderId);
                         camp.s_camp_id = sCampId;
                         camp.retrieve();
                         cstat.s_camp_id = sCampId;
                         cstat.retrieve();
                         csp.s_camp_id = sCampId;
                         csp.retrieve();
                         sched.s_camp_id = sCampId;
                         sched.retrieve();
                         if (sched.s_end_date != null) {
                              dEndDate = df.parse(sched.s_end_date);
                         }

                         if (iOrderStatus == DONE) {      // Order complete
                              if (dEndDate != null && dEndDate.before(dNow)) {
                                   camp.s_status_id = String.valueOf(CampaignStatus.DONE);
                              } else {
                                   if (camp.s_type_id.equals("3") || camp.s_type_id.equals("4")) {
                                        camp.s_status_id = String.valueOf(CampaignStatus.WAITING);
                                   } else {
                                        if ( (csp.s_queue_daily_flag != null && csp.s_queue_daily_flag.equals("1")) && 
                                             (csp.s_queue_date != null) && 
                                             (csp.s_queue_daily_time != null) 
                                        ) {
                                             camp.s_status_id = String.valueOf(CampaignStatus.WAITING);
                                        } else {
                                             camp.s_status_id = String.valueOf(CampaignStatus.DONE);
                                        }
                                   }
                              }
                              camp.save();
                              cstat.s_recip_sent_qty = cstat.s_recip_queued_qty;
                              cstat.s_finish_date = sNow;
                              cstat.save();
                              iStatus = iOrderStatus;
                         } else if (iOrderStatus == PRINTED) {
                              camp.s_status_id = String.valueOf(CampaignStatus.BEING_PROCESSED);
                              camp.save();
                              iStatus = iOrderStatus;
                         } else {                                // order is not done yet, no need to set status of campaign.  Just return status to calling client.
                              iStatus = iOrderStatus;
                         }
                    } else {
                         logger.error("Campaign ID not found for order ID:" + sOrderId);
                    }

               }
               catch (SQLException e) {
                    throw e;
               } finally {
                    if (stmt != null) stmt.close();
                    if (conn != null) cp.free(conn);
               }

		}
		catch (Exception ex) {
               logger.error("Exception thrown while attempting to set status of an order.", ex);
               iStatus = -1;
		}
		
		logger.info("Exiting CTIDeliveryStatus web service...returning: " + iStatus);		
        return iStatus;		
	}

}
