package com.britemoon.sas.delivery;

import com.britemoon.*;
import com.britemoon.cps.ServiceType;
import com.britemoon.cps.XmlElementList;
import com.britemoon.cps.XmlUtil;
import com.britemoon.sas.*;
import com.britemoon.sas.imc.*;

import java.io.*;
import java.text.*;
import java.sql.*;
import java.util.*;

import org.apache.log4j.Logger;
import org.w3c.dom.*;

public class DeliveryMonitorTask extends BriteTask
{
	private static Logger logger = Logger.getLogger(AccessMask.class.getName());	
	public DeliveryMonitorTask()
	{
		init();
	}
	
	private void init()
	{	
		setTaskName("DeliveryMonitorTask");
		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		logger.info(this + " started at " + new java.util.Date());
		startStatic();
		logger.info(this + " finished at " + new java.util.Date());
	}
	
	public static void startStatic() throws Exception
	{
		String sErrMsg = "DeliveryMonitorTask ERROR: cannot run task";

		Connection conn = null;
		PreparedStatement stmt = null;
		ResultSet rs = null;
		try	{
			// create a db connection to the delivery (pmta) database
			conn = DriverManager.getConnection(Registry.getKey("delivery_db_connection_string"));
			String sql = " EXECUTE usp_brite_campaign_save" +
				  		 "	@camp_id=?," +
				  		 "	@cust_id=?," +
				  		 "	@camp_name=?," +
				  		 "	@cust_name=?," +
				  		 "	@start_date=?," +
				  		 "	@recip_total_qty=?," +
				  		 "	@recip_sent_qty=?," +
	  		 			 "	@type_id=?";
			stmt = conn.prepareStatement(sql);
			rs = null;
			
			// 	query each cps to get camp info
			String started_past_hours    = Registry.getKey("delivery_start_past_hours");
			String completed_past_hours  = Registry.getKey("delivery_completed_past_hours");
			String hm_camp_bounce_limit  = Registry.getKey("delivery_hm_camp_bounce_limit");
			String hm_camp_deliver_limit = Registry.getKey("delivery_hm_camp_deliver_limit");
			String hm_camp_deliver_wait  = Registry.getKey("delivery_hm_camp_deliver_wait");
			Map map = getAllActiveCPS();
			logger.info(" found " + map.size() + " CPS ");
			for (Iterator it = map.keySet().iterator(); it.hasNext(); ) {
				String sModInstId = (String) it.next();
				String sIP =(String) map.get(sModInstId);
				logger.info(" querying CPS at " + sIP);
				String sRequest = "<Request>" +
						   		  "  <started_past_hours>" + started_past_hours + "</started_past_hours>" +
						   		  "  <completed_past_hours>" + completed_past_hours + "</completed_past_hours>" +
						   		  "</Request>";
				Vector services = Services.getByModInst(ServiceType.CCPS_DELIVERY_CAMP_INFO, sModInstId);
				if (services.isEmpty()) {
					logger.info(" CCPS_DELIVERY_CAMP_INFO service not defined for IP = " + sIP + ", mod_inst_id = " + sModInstId);
					continue;
				}
				Service service = (Service) services.get(0);
				String sResponse = null;
				try	{
					logger.info(" connecting to CPS at " + sIP);
					service.connect();
					service.send(sRequest);
					logger.info(" waiting for response from CPS at " + sIP);
					sResponse = service.receive();
				}
				catch (Exception e) {}
				finally { service.disconnect();}
				logger.info(" response = \n" + sResponse);
				//logger.info(" processing result from CPS at " + sIP);
				// process delivery camp info
				int count = 0;
				try	{
					Element eRoot = XmlUtil.getRootElement(sResponse);
					XmlElementList xelItems = XmlUtil.getChildrenByName(eRoot, "CampaignInfo");
					for (int n=0; n < xelItems.getLength(); n++) {
						Element eItem = (Element)xelItems.item(n);
						stmt.setString(1, XmlUtil.getChildTextValue(eItem,"camp_id"));
						stmt.setString(2, XmlUtil.getChildTextValue(eItem,"cust_id"));
						stmt.setString(3, XmlUtil.getChildCDataValue(eItem,"camp_name"));
						stmt.setString(4, XmlUtil.getChildCDataValue(eItem,"cust_name"));
						stmt.setString(5, XmlUtil.getChildTextValue(eItem,"start_date"));
						stmt.setString(6, XmlUtil.getChildTextValue(eItem,"recip_queue_qty"));
						stmt.setString(7, XmlUtil.getChildTextValue(eItem,"recip_sent_qty"));
						stmt.setString(8, XmlUtil.getChildTextValue(eItem,"type_id"));
						rs = stmt.executeQuery();
						rs.close();
						count++;
					}
				}
				catch (Exception e) {
					logger.info(sErrMsg + " => " + e);
					throw e;
				};					
				logger.info(" found " + count + " campaigns from " + sIP);
			}
			stmt.close();
			sql = "EXECUTE usp_update_brite_campaigns " +
				  " @started_past_hours=?," + 
				  " @hm_camp_bounce_limit=?," + 
				  " @hm_camp_deliver_limit=?," + 
				  " @hm_camp_deliver_wait=?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, started_past_hours);
			stmt.setString(2, hm_camp_bounce_limit);
			stmt.setString(3, hm_camp_deliver_limit);
			stmt.setString(4, hm_camp_deliver_wait);
			rs = stmt.executeQuery();
			rs.next();
			int rc = rs.getInt(1);
			rs.close();
			logger.info(" deleted " + rc + " campaigns started over " + started_past_hours + " hours ago");
		}
		catch(Exception ex)
		{
			logger.info(sErrMsg + " => " + ex);
			throw ex;
		}
		finally 
		{
			try	 {
				if ( stmt != null ) stmt.close();
			}
			catch (SQLException se1) { }
			try	 {
				if ( conn != null ) conn.close(); 
			}	
			catch (SQLException se2) { }	
		}
		
	}
	
	public static Map getAllActiveCPS ()
	{
		Map map = new LinkedHashMap();
		ConnectionPool cp = null;
		Connection conn = null;
		Statement	stmt = null;
		ResultSet	rs = null; 
		String sql = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("DeliveryMonitorTask.getAllCPS");
			stmt = conn.createStatement();
			sql = 
				"select distinct mi.mod_inst_id, ma.ip_address" +
				"  from sadm_customer c with(nolock)" +
				"  left outer join sadm_cust_mod_inst cmi with(nolock) on c.cust_id = cmi.cust_id" +
				"  left outer join sadm_mod_inst mi with(nolock) on mi.mod_inst_id = cmi.mod_inst_id" +
				"  left outer join sadm_module mo with(nolock) on mo.mod_id = mi.mod_id" +
				" inner join sadm_machine ma with(nolock) on ma.machine_id = mi.machine_id" +
				" where c.status_id = 3 and UPPER(mo.abbreviation) = 'CCPS'" +
				" order by 1";

			String sModInstId = null;
			String sIP = null;

			rs = stmt.executeQuery(sql);
			while (rs.next()) {
				sModInstId = rs.getString(1);
				sIP = rs.getString(2);
				if (!map.containsKey(sModInstId)) {
					map.put(sModInstId, sIP);	
				}
			}
			rs.close();
		}
		catch(Exception ex) {}
		finally	{
			try	 {
				if ( stmt != null ) stmt.close();
			}
			catch (SQLException se) { }
			if ( conn != null ) cp.free(conn); 
		}
		return map;
	}
}
