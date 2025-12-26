package com.britemoon.cps.rpt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.tgt.*;
import com.britemoon.cps.imc.*;
import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ReportUtil
{
	private static Logger logger = Logger.getLogger(ReportUtil.class.getName());

	public static boolean isNewReport(String sCampID) throws Exception
	{	
        ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt = null;
        String sql = null;
        ResultSet rs = null;       
        int count = 0;
        
        try {
             cp = ConnectionPool.getInstance();
             conn = cp.getConnection("ReportUtil.isNewReport");
             stmt = conn.createStatement();
             sql = "SELECT COUNT(*) FROM crpt_camp_summary WHERE camp_id = "+sCampID;
             rs = stmt.executeQuery(sql);
             rs.next();
             count = rs.getInt(1);
             rs.close();
        }
        catch (Exception e) {
        	throw e;
        }
        finally {
        	try { 	
        		if( stmt != null ) stmt.close(); 
        	} catch (Exception e) {}
        	if( conn != null ) cp.free(conn); 
        }
        return (count == 0);
	}
	
	public static boolean isDynamicContentReportCustomer(String sCustID) throws Exception
	{	
        ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt = null;
        String sql = null;
        ResultSet rs = null;       
        int count = 0;
        
        try {
             cp = ConnectionPool.getInstance();
             conn = cp.getConnection("ReportUtil.isDynamicContentReportCustomer");
             stmt = conn.createStatement();
             sql = "SELECT COUNT(*) FROM ccps_cust_feature " +
             	   " WHERE cust_id = "+sCustID +
             	   "   AND feature_id = " + Feature.DYNAMIC_CONTENT_REPORTING;
             rs = stmt.executeQuery(sql);
             rs.next();
             count = rs.getInt(1);
             rs.close();
        }
        catch (Exception e) {
        	throw e;
        }
        finally {
        	try { 	
        		if( stmt != null ) stmt.close(); 
        	} catch (Exception e) {}
        	if( conn != null ) cp.free(conn); 
        }
        return (count > 0);
	}
	
	public static void setupReportCache (String sCustID, String sCampID, String sFilterID) throws Exception
	{
		String sTempCacheID = "-" + NextInt.get(sCustID);
		String sCacheID = sTempCacheID;

		// send filter into to RCP
		try {
			FilterUtil.sendFilterUpdateRequestToRcp(sFilterID); 
		}
		catch (Exception ex) 
		{
			logger.error("Exception: ",ex); 
		}

		// create report cache

		StringWriter swXML = new StringWriter();

		swXML.write("<camp_reports>\r\n");
		swXML.write("  <camp_report_cache>\r\n");
		swXML.write("    <camp_id>"+sCampID+"</camp_id>\r\n");
		swXML.write("    <cust_id>"+sCustID+"</cust_id>\r\n");
		swXML.write("    <cache_id>"+sCacheID+"</cache_id>\r\n");
		swXML.write("    <cache_start_date></cache_start_date>\r\n");
		swXML.write("    <cache_end_date></cache_end_date>\r\n");
		swXML.write("    <filter_id>"+sFilterID+"</filter_id>\r\n");
		swXML.write("    <attr_id></attr_id>\r\n");
		swXML.write("    <attr_value1></attr_value1>\r\n");
		swXML.write("    <attr_value2></attr_value2>\r\n");
		swXML.write("    <attr_operator></attr_operator>\r\n");
		swXML.write("    <user_id></user_id>\r\n");
		swXML.write("    <temp_cache_id>"+sTempCacheID+"</temp_cache_id>\r\n");
		swXML.write("  </camp_report_cache>\r\n");
		swXML.write("</camp_reports>\r\n");

		String sCacheXml = Service.communicate(ServiceType.RRPT_CAMPAIGN_REPORT_CACHE, sCustID, swXML.toString());
		Element e = XmlUtil.getRootElement(sCacheXml);

		if (e == null) throw new Exception("Malformed Campaign Report xml.");

		sCampID = XmlUtil.getChildTextValue(e, "camp_id");
		sCustID = XmlUtil.getChildTextValue(e, "cust_id");
		sCacheID = XmlUtil.getChildTextValue(e, "cache_id");
		sTempCacheID = XmlUtil.getChildTextValue(e, "temp_cache_id");

		if ((sCampID == null) || (sCustID == null)) throw new Exception("Campaign not specified.");

		ConnectionPool	cp		= null;
		Connection		conn	= null;
		PreparedStatement pstmt	= null;
		String 			sql 	= null;
		ResultSet		rs		= null; 

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ReportUtil.setupReportCache");

		    sql = "INSERT crpt_camp_summary_cache (camp_id, cust_id, cache_id, filter_id, user_id) " +
			 	  "SELECT camp_id, cust_id, " + sTempCacheID +"," + sFilterID + ",0" + 
			 	  "  FROM cque_campaign WHERE camp_id = " + sCampID;
			pstmt = conn.prepareStatement(sql);
			pstmt.executeUpdate();
			pstmt.close();
		}
        catch (Exception ex) {
        	throw ex;
        }
        finally {
             try { 	
        		if( pstmt != null ) pstmt.close(); 
             } catch (Exception ex2) {}
             if (conn != null) cp.free(conn);
        }
	}
	
}
