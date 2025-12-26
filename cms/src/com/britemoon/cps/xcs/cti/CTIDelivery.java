package com.britemoon.cps.xcs.cti;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.io.*;
import java.util.*;
import java.util.zip.*;
import java.net.*;
import java.sql.*;
import org.apache.log4j.*;

import org.apache.axis.attachments.Attachments;
import org.apache.axis.attachments.AttachmentPart;
import org.apache.axis.AxisFault;
import org.apache.axis.MessageContext;
import org.apache.axis.client.*;

import javax.xml.soap.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import javax.activation.FileDataSource;
import javax.activation.DataHandler;

public class CTIDelivery
{
	//////////////////////////////////////////////////////////////////////////
	//                                                                      //
	// deliver a print order to CTI Delivery Services                       //
	//                                                                      //
	//////////////////////////////////////////////////////////////////////////
	private static Logger logger = Logger.getLogger(CTIDelivery.class.getName());

	public String deliverOrder (String custId, String campId, String chunkId, String fileUrl) throws Exception
    {
		String status ="failure";		
		String fileName = generateOrder(custId, campId, chunkId, fileUrl);
		String orderId = submitOrder(custId, campId, chunkId, fileName);
		if (orderId != null) {
			boolean rc = updateOrder(custId, campId, chunkId, orderId, fileName);
			if (rc == true) {
				status = "success";
			}
		}
		return status;
    }
    
    // generate order in zip file from a campaign
    public String generateOrder(String custId, String campId, String chunkId, String fileUrl) throws Exception
    {
		Customer cust = new Customer(custId);
		String ctiGroupId = cust.s_cti_group_id;
		if (ctiGroupId == null || ctiGroupId.length() == 0) {
			throw new Exception ("Invalid CTI Group ID: " + ctiGroupId + " for customer " + custId);
		}			

		// make sure directory exists
		String deliveryDir = Registry.getKey("cti_delivery_dir");
		String dirName = deliveryDir + "\\" + custId;		
		File f = new File(dirName);
		if (!f.exists() || !f.isDirectory()) {
			throw new Exception ("CTI delivery directory (" + dirName + ") for customer " + custId + " does not exist");
		}			
		
		String fileName = dirName + "\\" + campId + "_" + chunkId + ".zip";
		
		ConnectionPool cp = ConnectionPool.getInstance();
		Connection conn = null;
		Statement stmt = null;		
		ResultSet rs = null;
		String sql = null;
		int rc = 0;
		
		try	{
			conn = cp.getConnection("CTIDelivery");
			stmt = conn.createStatement();

			// get doc_id
			sql = 
				"SELECT cti_doc_id " +
				"  FROM ccnt_content n, cque_campaign c " +
				" WHERE c.camp_id = " + campId + 
				"   AND c.cont_id = n.cont_id";
			rs = stmt.executeQuery(sql);
			String cti_doc_id = null;
			if (rs.next()) {
				cti_doc_id = rs.getString(1);
			}
			rs.close();
			
			// create manifest file
			String returnHostName = getReturnHostName();
			StringBuffer manifest = new StringBuffer(1024);			
			manifest.append("<p:manifest PackageID=\"" + campId + "\" ClientID=\"" + ctiGroupId + "\" PackageBrokerID=\"Britemoon1\" PackageServerID=\"CTI1\" xmlns:p=\"http://www.clicktactics.com/packageManifest\">\n");
			manifest.append("  <p:contents>\n");
			manifest.append("    <pi:items xmlns:pi=\"http://www.clicktactics.com/packageItem\">\n");
			manifest.append("      <pi:item PackageItemID=\"" + cti_doc_id + "\">\n");
			manifest.append("        <pi:customAttributes>\n");
			manifest.append("          <bm:britemoonInfo DocumentID=\"" + cti_doc_id + "\" CampaignID=\"" + campId + "\" ReturnHostName=\"" + returnHostName +"\" xmlns:bm=\"http://www.clicktactics.com/britemoon\"/>\n");
			manifest.append("        </pi:customAttributes>\n");
			manifest.append("      </pi:item>\n");
			manifest.append("    </pi:items>\n");
			manifest.append("  </p:contents>\n");
			manifest.append("</p:manifest>\n");

			// create zip file 
			String manFile = "Manifest.pkm";
			String csvFile = cti_doc_id + ".csv";
			String expFileUrl = fileUrl;
			
			// create zip file for output
			ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(fileName));			
			
			// add manifest file
			zos.putNextEntry(new ZipEntry(manFile));
			byte[] buf = manifest.toString().getBytes();
			zos.write(buf, 0, buf.length);
			zos.closeEntry();
			
			// copying export file from http url
			String localFileName = null;
			BufferedWriter fileOut = null;
			boolean ok = false;
			int max_retry = 5;
			long sleepInterval = 60000;
			while (max_retry > 0 && !ok) {
				// if this is a retry, sleep first
				if (max_retry < 5) {
					logger.info("CTIDelivery: URL read encountered an I/O problem, will try again in 1 minute if allowed");
					try	{ 
						Thread.sleep(sleepInterval); 
					}
					catch (Exception ex) {};
				}
				localFileName = dirName + "\\" + expFileUrl.substring(expFileUrl.lastIndexOf('/'));

				fileOut =
					new BufferedWriter(
							new OutputStreamWriter(
									new FileOutputStream(localFileName,false),"ISO-8859-1"));

				try
				{
					URL url = new URL(expFileUrl);
					
					BufferedReader in =
						new BufferedReader(
								new InputStreamReader(url.openStream(), "ISO-8859-1"));
					
					char[] b = new char[1024];
					int n;
					while ((n=in.read(b)) > 0) fileOut.write(b, 0, n);
					ok = true;
				}
				catch(MalformedURLException ex) {
					logger.info("Malformed URL exception: " + expFileUrl);	
					logger.error("Malformed URL exception: ", ex);				
				}
				catch(IOException ex) { 
					logger.info("IO exception while copying export file: " + expFileUrl);	
					logger.error("IO exception while copying export file: " , ex);				
				}
				fileOut.flush();
				fileOut.close();
				max_retry--;
			}
			
			// sanity check
			if (!ok) {
				throw new Exception ("error copying export file to local");
			}
			
			// add csv file by 
			zos.putNextEntry(new ZipEntry(csvFile));
			try
			{
				BufferedReader in =
					new BufferedReader(
							new InputStreamReader(
								new FileInputStream(localFileName), "ISO-8859-1"));

				String str;
				int line_count = 0;
				boolean header_line = true;
				while ((str = in.readLine()) != null)
				{
					if (line_count > 1 && str.length() > 2)
					{
						if (header_line)
						{
							// first line is assumed to be header
							str = getBritemoonHeader(custId,str);
							header_line = false;
						}
						// export put a delimiter at the end of the line too, we need to remove it
						str = str.substring(0, str.length() - 1);
						str = str + "\n";
						buf = str.getBytes("ISO-8859-1");
						if (buf.length > 0) zos.write(buf, 0, buf.length);
					}
					line_count++;
				}
				in.close();
			}
			catch(IOException ex)
			{ 
				logger.info("IO exception while copying export file: " + expFileUrl);	
				logger.error("IO exception while copying export file: " , ex);				
			}			
			zos.closeEntry();
			
			// done 
			zos.close();
		}
		catch(ZipException e){
			logger.info("Unable to create zip file: " + e.getMessage());
			throw new Exception("Unable to create zip file: " + e.getMessage());
		}
		catch (Exception ex) {
			logger.info("Exception trying to create zip file: " + ex.getMessage());
			throw new Exception("Exception trying to create zip file: " + ex.getMessage());			
		}
		finally {
			try	{
				if ( stmt != null ) stmt.close();
			}
			catch (SQLException se) { }
			if ( conn != null ) cp.free(conn); 
		}
		
		// sanity check
		if (!verifyOrder(fileName)) {
			return null;
		}
		
		return fileName;
    }
 
    public String getBritemoonHeader(String custId, String header) throws Exception
    {
		String britemoon_header = "";
		ConnectionPool cp = ConnectionPool.getInstance();
		Connection conn = null;
		Statement stmt = null;		
		ResultSet rs = null;
		String sql = null;
		try	{
			conn = cp.getConnection("CTIDelivery:getBritemoonHeader");
			stmt = conn.createStatement();
			
			StringTokenizer st = new StringTokenizer(header, "\t");
			while (st.hasMoreTokens()) {
				String displayName = st.nextToken();
				sql = 
					"SELECT a.attr_name " +
					"  FROM ccps_attribute a, ccps_cust_attr ca " +
					" WHERE ca.cust_id = " + custId +
					"   AND LOWER(ca.display_name) = LOWER('" + displayName + "')" +
					"   AND a.attr_id = ca.attr_id ";
				rs = stmt.executeQuery(sql);
				if (rs.next()) {
					britemoon_header += (new String(rs.getBytes(1), "ISO-8859-1")) + "\t";
				}
				rs.close();
			}
		}
		catch (Exception ex) {
			logger.info("Exception trying to get britemoon headers: " + ex.getMessage());
			throw new Exception("Exception trying to get britemoon headers: " + ex.getMessage());			
		}
		finally {
			try	{
				if ( stmt != null ) stmt.close();
			}
			catch (SQLException se) { }
			if ( conn != null ) cp.free(conn); 
		}
		return britemoon_header;
	}
   
    public boolean verifyOrder(String fileName)
    {
		if (fileName == null) {
			return false;
		}
		
		boolean zipFileOk = true;
		try {
			ZipInputStream zis = new ZipInputStream(new FileInputStream(fileName));
			boolean hasMore = true;
			while (hasMore) {
				ZipEntry entry = zis.getNextEntry();
				if (entry !=null ) {
					String name = entry.getName();
					long size = entry.getSize();
					long crc = entry.getCrc();
					logger.info("found entry=" + name + ",size=" + size + ",CRC=" + crc);
					if (crc < -1) {
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
		catch(Exception e) { 
			logger.info("Unable to verify file: " + fileName + " reason: " + e.getMessage());
			zipFileOk = false;
		}
		return zipFileOk;
    }
    
    // submit order to WS
    public String submitOrder(String sCustId, String sCampId, String chunkId, String fileName) throws Exception
    {
		// wsUrl (http://localhost:8080/axis/services/CTIOrder)
		// envFileName (soap.xml)
		// zipFileName (order.zip)
		
		String zipFileName = fileName;
          String sAttachmentFileName = zipFileName.substring(zipFileName.lastIndexOf("\\") + 1);
		
		String sOrderId = "";
		
		logger.info("Calling web services..");
		try {
			// 1. call WS
			
			logger.info("add zip attachment");
			FileDataSource file = new FileDataSource(zipFileName);
			DataHandler zipDH = new DataHandler(file);
			
			logger.info("Call web services=> ");
			
			BritemoonOrderPlacementService service = new BritemoonOrderPlacementServiceLocator();
			Vector vSvcs = Services.getByCust(ServiceType.CXCS_ORDER_DELIVERY, sCustId);
			com.britemoon.cps.imc.Service svc = (com.britemoon.cps.imc.Service) vSvcs.get(0);
			URL uServiceUrl = svc.getURL();
			//URL uServiceUrl = new URL("http://69.15.102.18/STIP/BritemoonOrderPlacementService.asmx");
			logger.info("*** OrderDelivery \n  URL to customer Web Service is:"+uServiceUrl.toString() + "\n*** OrderDelivery");
			
			if (uServiceUrl != null) {
				BritemoonOrderPlacementServiceSoap port = service.getBritemoonOrderPlacementServiceSoap(uServiceUrl);
				org.apache.axis.client.Stub stub = (org.apache.axis.client.Stub) port;
				stub._setProperty(Call.ATTACHMENT_ENCAPSULATION_FORMAT, Call.ATTACHMENT_ENCAPSULATION_FORMAT_DIME);
				stub.addAttachment(zipDH);
				sOrderId = port.pushOrderFile(sAttachmentFileName);
				logger.info("Order ID returned from WS:" + sOrderId);
			}
			else {
				throw new Exception("Cannot connect to customer Web Service--URL information could not be found.");
			}			
		}
		catch (AxisFault af) {
			logger.error("Exception: ", af);
		}
		catch (Exception ex) {
			logger.error("Exception: ",ex);
		}

		
		return sOrderId;
    }
    
    public boolean updateOrder(String sCustId, String sCampId, String sChunkId, String sOrderId, String sFileName) throws Exception
    {
          if (sCustId == null) {
               logger.error("Unable to update Print Order table with order information.");
               return false;
          }
          if (sCampId == null) {
               logger.error("Unable to update Print Order table with order information.");
               return false;
          }
          if (sChunkId == null) {
               logger.error("Unable to update Print Order table with order information.");
               return false;
          }
          if (sOrderId == null) {
               logger.error("Unable to update Print Order table with order information.");
               return false;
          }
          if (sFileName == null) {
               logger.error("Unable to update Print Order table with order information.");
               return false;
          }
               
		String sql =
			"UPDATE cxcs_delivery " +
			"   SET order_id = '" + sOrderId + "', " +
               " zip_file_name = '" + sFileName + "' " +
			" WHERE camp_id = " + sCampId +
			"   AND chunk_id = " + sChunkId;	   
		int rc = BriteUpdate.executeUpdate(sql);
		if (rc == 1) {
			return true;
		}
		return false;
    }

    
    public String getReturnHostName() 
    {
    	String name = Registry.getKey("return_host_name");	
		if (name == null || name == "")
		{
			try
			{
				java.net.InetAddress localMachine = java.net.InetAddress.getLocalHost();	
				name = localMachine.getHostName();
			}
			catch(Exception e) {}
		}
		return name;
	}
    
//	public static void main(String[] args) throws Exception {
//          CTIDelivery cd = new CTIDelivery();
//          try {
//               String sOrderId = cd.submitOrder("FE4E4B87-6FCB-4A2D-BA3D-488AED9BD6A8", "2105765", "12345", "F:\\Temp\\6E719DF5-8F5D-4B67-89BD-6FCB1991A734.ZIP");
//               System.out.println("returned from submitOrder...orderID:" + sOrderId);
//          } catch (Exception e) {
//               e.printStackTrace();
//          }
//    }
}
