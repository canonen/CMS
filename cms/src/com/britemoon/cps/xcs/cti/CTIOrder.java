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
import org.apache.log4j.*;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.xcs.cti.bean.*;

import java.sql.*;

public class CTIOrder
{
	private static Logger logger = Logger.getLogger(CTIOrder.class.getName());
    public String submitCampaign(String orderId) throws AxisFault
	{
		String status = null;
          int statusId = 0;
		boolean zipFileOk = true;
		String stagingDir = null;
		logger.info("Order No = " + orderId);
		
		stagingDir = Registry.getKey("cti_staging_dir");
		
		MessageContext context = MessageContext.getCurrentContext();
		String custId = (String) context.getProperty("CUST_ID");
		
		if (orderId == null || orderId.equals("")) {
			status = "Unable to process order due to invalid data format (order no was null)";
			logger.info("processing status = " + status);
			throw new AxisFault(status);
		}
				
		if (custId == null || custId.equals("")) {
			status = "Unable to process order due to internal system problem (cust id not found)";
			logger.info("processing status = " + status);
			throw new AxisFault(status);
		}
		logger.info("Found cust id = " + custId);
		
		PreparedStatement pstmt	= null;
		ResultSet		  rs	= null; 
		ConnectionPool	  cp	= null;
		Connection		  conn  = null;
		String            sql   = null;
		
		try {
			// make sure order no is new
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CTIOrder");
			
			sql =
				"SELECT cust_order_id FROM cxcs_order " +
				" WHERE cust_id = " + custId +
				"   AND cust_order_id = '" + orderId + "'";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				rs.close();
				pstmt.close();
				logger.info("Order already exist");
				throw new Exception("Order already exist");
			}
			rs.close();
			pstmt.close();

			// parse attachments
			Message requestMsg = context.getRequestMessage();
			Attachments msgAttachments = requestMsg.getAttachmentsImpl();
			if (null == msgAttachments || msgAttachments.getAttachmentCount() <= 0) {
				logger.info("no package file found");
				throw new Exception("no package file found");
			}
			int attachmentCount= msgAttachments.getAttachmentCount();
			logger.info("There are " + attachmentCount + " attachments");
			AttachmentPart attachments[] = new AttachmentPart[attachmentCount];
			Iterator iter = msgAttachments.getAttachments().iterator();
			int count = 0;
			while (iter.hasNext()) {
				AttachmentPart part = (AttachmentPart) iter.next();
				attachments[count++] = part;
			}
			logger.info("Total attachments received = " + attachments.length);

			// make new dir for the attachment
               // directory structure is like D:\Britemoon\ccps.500\web\data\cti\<custId>\<orderId>
			String dirName = stagingDir + custId + "\\" + orderId;
			try	{
                    logger.info("attempting to create directory(s):" + dirName);
				File dir = new File(dirName);
				if (!dir.mkdirs()) {
					logger.info("failed to mkdir for package..." + dirName);
					throw new Exception("failed to mkdir for package");
				}
			}
			catch(Exception e){
				logger.error("Unable to mkdir for new zip file  : " , e);
				throw new Exception("Unable to mkdir for new zip file : " + e.getMessage());
			}

			// save attachment using the order no as filename									
			logger.info("Saving first attachment as zip file");
			DataHandler dh = attachments[0].getDataHandler();
			logger.info("Found first attachment named " + dh.getName() + " of type " + dh.getContentType());
			String fileName = dirName + "\\" + orderId + ".zip";
			try	{
				InputStream is = dh.getInputStream();
				File file = new File(fileName);
				FileOutputStream fos = new FileOutputStream(file);
				dh.writeTo(fos);
			}
			catch(Exception e){
				logger.error("Unable to save file : ", e);
				throw new Exception("Unable to save file : " + e.getMessage());
			}
			
			// verify integrity of the zip file
			try	{
				ZipInputStream zis = new ZipInputStream(new FileInputStream(fileName));
				boolean hasMore = true;
				while (hasMore) {
					ZipEntry entry = zis.getNextEntry();
					if (entry !=null ) {
						String name = entry.getName();
						long size = entry.getSize();
						long crc = entry.getCrc();
						logger.info("found entry = " + name);
						logger.info("      size  = " + size);
						logger.info("      CRC   = " + crc);
						if (crc == -1) {
							zipFileOk = false;
							hasMore = false;
						}						
					}
					else {
						hasMore = false;
					}
					zis.closeEntry();
				}
				zis.close();
			}
			catch(Exception e){
				logger.error("Unable to verify file: ", e);
				throw new Exception("Unable to verify file: " + e.getMessage());
			}
			if (!zipFileOk) {
				status = "zip file has invalid CRC";
				logger.info("Zip file has invalid CRC");
				throw new Exception("Zip file has invalid CRC");
			}
			
			logger.info("Updating database for new order");
			
			// insert row into cxcs_order
			sql = 
				"INSERT INTO cxcs_order (cust_id, cust_order_id, status_id, status_desc, received_date, status_date) " +
				"     SELECT " + custId + ",'" + orderId + "',status_id, status_name, getDate(), getDate()" +
				"       FROM cxcs_order_status where status_id = 10";
			pstmt = conn.prepareStatement(sql);
			pstmt.executeUpdate();
			pstmt.close();
			logger.info("Insert order " + orderId + " for cust " + custId + " to database");				
			
			// retrieve the brite_order_id just created
			sql = 
				"SELECT brite_order_id FROM cxcs_order " +
				" WHERE cust_id = " + custId + 
				"   AND cust_order_id = '" + orderId + "'";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if (!rs.next()) {
				logger.info("Database problem, unable to create Order");
				throw new Exception("Database problem, unable to create Order");
			}
			String briteOrderId = rs.getString(1);
			rs.close();
			pstmt.close();
			logger.info("britemoon order no was " + briteOrderId);				
			
			// insert row into cxcs_file
			sql = 
				"INSERT INTO cxcs_file (file_id, brite_order_id, type_id, file_name) " +
				"     VALUES (1, " + briteOrderId + ",10,'" + fileName + "')";
			pstmt = conn.prepareStatement(sql);
			pstmt.executeUpdate();
			logger.info("Inserting file information");				
			
			status = "The order has been received and saved as " + orderId + ".zip";
               statusId = com.britemoon.cps.OrderStatus.RECEIVED;

			// send status to CTI
//			OrderStatusClient osc = new OrderStatusClient();
//			osc.sendBriteStatus(briteOrderId, com.britemoon.OrderStatus.RECEIVED);
			
		}
		catch (SQLException e) {
			status = "Unable to process order " + orderId + " due to database error: " + e.getMessage();
               statusId = com.britemoon.cps.OrderStatus.ERROR_PROCESSING;
               logger.error("Unable to process order " + orderId + " due to database error: " , e);
               throw new AxisFault(status);
		}
		catch (Exception e) {
			status = "Unable to process order " + orderId + " due to exception: " + e.getMessage();
               statusId = com.britemoon.cps.OrderStatus.ERROR_PROCESSING;
               logger.error("Unable to process order " + orderId + " due to exception: " + e.getMessage());
               throw new AxisFault(status);
		}
		finally {
			cp.free(conn);

			// send status to CTI
			OrderStatusClient osc = new OrderStatusClient();
			osc.sendBriteStatus(custId, orderId, statusId);
		}		
		
		logger.info("submitCampaign: processing status = " + status);
		return status;
	}

    public com.britemoon.cps.xcs.cti.bean.OrderStatus selectStatus(String orderId) throws AxisFault
	{
		com.britemoon.cps.xcs.cti.bean.OrderStatus campStatus = null;
		String status = null;
		logger.info("Order No = " + orderId);
		
		MessageContext context = MessageContext.getCurrentContext();
		String custId = (String) context.getProperty("CUST_ID");
		
		if (orderId == null || orderId.equals("")) {
			status = "Unable to process order due to invalid data format (order no was null)";
			logger.info("processing status = " + status);
			throw new AxisFault(status);
		}

		if (custId == null || custId.equals("")) {
			status = "Unable to process order due to internal system problem (cust id not found)";
			logger.info("processing status = " + status);
			throw new AxisFault(status);
		}
		logger.info("Found cust id = " + custId);
		
		PreparedStatement pstmt	= null;
		ResultSet		  rs	= null; 
		ConnectionPool	  cp	= null;
		Connection		  conn  = null;
		String            sql   = null;
		
		try {
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CTIOrder");
			
			sql =
				"SELECT o.status_id, o.status_desc FROM cxcs_order o" +
				" WHERE o.cust_id = " + custId +
				"   AND o.cust_order_id = '" + orderId + "'";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				int statusId = rs.getInt(1);
				String statusDesc = rs.getString(2);
				if (statusId >= 900) {
					statusId = 90;
				}
				status = "" + statusId;
				campStatus = new com.britemoon.cps.xcs.cti.bean.OrderStatus();
				campStatus.setStatusId(statusId);
				campStatus.setStatusName(statusDesc);
			}
			else {
				logger.info("Order No " + orderId + " is not found in the database");
				throw new Exception("Order No " + orderId + " is not found in the database");
			}
			rs.close();
			pstmt.close();			
		}
		catch (SQLException e) {
			status = "Unable to process order " + orderId + " due to database error: " + e.getMessage();
			logger.error("Unable to process order " + orderId + " due to database error: " , e);
			throw new AxisFault(status);
		}
		catch (Exception e) {
			status = "Unable to process order " + orderId + " due to exception: " + e.getMessage();
			logger.error("Unable to process order " + orderId + " due to exception: ", e);			
			throw new AxisFault(status);
		}
		finally {
			cp.free(conn);
		}		
		
		logger.info("selectStatus: processing status = " + status);
		return campStatus;
	}

    public CampaignSummary getCampaignSummary(String orderId, String orderIndex) throws AxisFault
	{
		CampaignSummary campSummary = null;
		String status = null;
		logger.info("Order No = " + orderId);
		
		MessageContext context = MessageContext.getCurrentContext();
		String custId = (String) context.getProperty("CUST_ID");
		
		if (orderId == null || orderId.equals("")) {
			status = "Unable to process order due to invalid data format (order no was null)";
			logger.info("processing status = " + status);
			throw new AxisFault(status);
		}
		
		if (custId == null || custId.equals("")) {
			status = "Unable to process order due to internal system problem (cust id not found)";
			logger.info("processing status = " + status);
			throw new AxisFault(status);
		}
		logger.info("Found cust id = " + custId);
		
		PreparedStatement pstmt	= null;
		ResultSet		  rs	= null; 
		ConnectionPool	  cp	= null;
		Connection		  conn  = null;
		String            sql   = null;
		
		try {
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CTIOrderSummary");
			
			sql =
				"SELECT obo.brite_object_id " +
				"  FROM cxcs_order o, cxcs_order_brite_object obo " +
				" WHERE o.cust_order_id = ? " +
				"   AND o.brite_order_id = obo.brite_order_id " +
				"   AND obo.index_id = ? " +
				"   AND obo.type_id = " + ObjectType.CAMPAIGN;
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, orderId);
			if (orderIndex != null) 
				pstmt.setString(2, orderIndex);
			else
				pstmt.setString(2,"0");
			
			rs = pstmt.executeQuery();
			String campId = null;
			if (rs.next()) {
				campId = rs.getString(1);				
			}
			rs.close();
			
			if (campId == null) {
				logger.info("There is no campaign id for this orderId");
				throw new Exception("There is no campaign id for this orderId");
			}

			logger.info("retrieving campaign summary for camp_id " + campId);
			sql =
				"SELECT start_date, bbacks, unsubs, tot_reads, tot_clicks, last_update_date" +
				"  FROM crpt_camp_summary " +
				" WHERE camp_id = " + campId;
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				String startDate = rs.getString(1);
				int bbacks = rs.getInt(2);
				int unsubs = rs.getInt(3);
				int reads = rs.getInt(4);
				int clicks = rs.getInt(5);
				String lastUpdateDate = rs.getString(6);
				campSummary = new CampaignSummary();
				campSummary.setSendDate(startDate);
				campSummary.setBbackQty(bbacks);
				campSummary.setUnsubQty(unsubs);
				campSummary.setReadQty(reads);
				campSummary.setClickQty(clicks);
				campSummary.setLastUpdateDate(lastUpdateDate);
				status = "Summary for orderId " + orderId + " => " + startDate + "," +  bbacks + "," +  unsubs + "," +  reads + "," +  clicks + " [" + lastUpdateDate + "]";
			}
			rs.close();
		}
		catch (SQLException e) {
			status = "Unable to process order " + orderId + " due to database error: " + e.getMessage();
			logger.info("Unable to process order " + orderId + " due to database error: " , e);
			throw new AxisFault(status);
		}
		catch (Exception e) {
			status = "Unable to process order " + orderId + " due to exception: " + e.getMessage();
			logger.info("Unable to process order " + orderId + " due to exception: " , e);
			throw new AxisFault(status);
		}
		finally {
			cp.free(conn);
		}		
		
		logger.info("getCampaignSummary: processing status = " + status);
		return campSummary;
	}

	
}