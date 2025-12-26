package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.io.*;
import java.sql.*;
import javax.servlet.http.*;
import javax.servlet.*;
import java.util.*; 
import org.apache.log4j.*;

public class campaignRequest extends HttpServlet
{
	private static Logger logger = Logger.getLogger(campaignRequest.class.getName());

	public void doGet (HttpServletRequest request, HttpServletResponse response)
	{
		response.setHeader("Expires", "0");
		response.setHeader("Pragma", "no-cache");
		response.setHeader("Cache-Control", "no-store, no-cache, max-age=0");

		response.setContentType("text/xml;charset=UTF-8");
		PrintWriter out = null;

		try
		{
			out = response.getWriter();

			out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n");
			out.println("<CampaignDefinitionList>\r\n");
			out.println("<!--  Britemoon Campaign Processing System  -->\r\n");

			try
			{
				printCampaignDefinitionListXml(request, out);
			}
			catch(Exception ex) { throw ex;	}
			finally
			{
				out.println("</CampaignDefinitionList>\r\n");			
			}
		}
		catch (Exception ex)
		{
			logger.info("Error: " + ex.getMessage());		
			logger.error("Exception: ", ex);
		}
		finally
		{
			if (out!=null)
			{
				out.flush();
				out.close();
			}
		}
	}
	
	private void printCampaignDefinitionListXml(HttpServletRequest request, PrintWriter out) throws Exception
	{
		String sCustIDs = request.getParameter("CustomerId");
		String sCampType = request.getParameter("CampaignType");
		String sMSGServer = request.getParameter("MSGServer");
	
		if (sCustIDs==null) throw new Exception ("Customer Ids required!");				
		if (sCampType==null) throw new Exception ("Campaign Type required!");
		if (sMSGServer==null) throw new Exception ("Mailer Id required!");		

		// === Print request info ===

		String sIpAddress = request.getRemoteAddr();
		
		String sMsg =
			"\r\n" +
			"Campaign Request (" + new java.util.Date() + "):\r\n" +
			" MailerIP=" + sIpAddress +
			" MailerID=" + sMSGServer +
			" CampType=" + sCampType +
			"\r\n";

		out.println("<!-- " + sMsg + " -->\r\n");
		logger.info(sMsg + " CustIDs=" + sCustIDs + "\r\n");

		// === === ===

		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this  + ".serveCampRequest()");
			stmt = conn.createStatement();
		
			printCampsXml(sCustIDs, sCampType, stmt, out);
		}
		catch(Exception ex)
		{
			out.println("<!-- Campaign Request ERROR:" + ex.getMessage() + " -->\r\n");
			throw ex;
		}
		finally
		{
			if (stmt != null) stmt.close();
			if (conn != null) cp.free(conn);
		}
	}

	private void printCampsXml(String sCustIDs, String sCampType, Statement stmt, PrintWriter out) throws Exception
	{
		String sSql = "EXEC usp_cque_camp_request_list_get '" + sCustIDs +"', "+sCampType;

		ResultSet rs = stmt.executeQuery(sSql);			

		int nCampCount = 0;
		while (rs.next())
		{
			String sCampID = rs.getString(1);
			try
			{
				String sCampaign = getCampaignDefinitionXml(sCampID);
				out.println(sCampaign);
			}
			catch(Exception ex)
			{
				String sErrMsg =
					"Campaign Request ERROR: CampID=" + sCampID + " ErrMsg=" + ex.getMessage();
				out.println("<!-- " + sErrMsg + " -->\r\n");
				logger.info("Error: " + sErrMsg);
				logger.error("Exception: " , ex);
			}
			nCampCount++;
		}
		rs.close();

		if(nCampCount == 0)
		{
			out.println("<!-- Operation Successful:  No matching Campaign definition currently queued. -->\r\n");
		}
	}

	private String getCampaignDefinitionXml(String sCampID) throws Exception
	{
		Campaign camp = new Campaign(sCampID);
				
		// === === ===
		
		String sCampaignDefinitionXml =
			"<CampaignDefinition>\r\n" + 
			"<CampaignID>" + camp.s_camp_id + "</CampaignID>\r\n" + 
			"<CampaignName><![CDATA[" + camp.s_camp_name + "]]></CampaignName>\r\n" + 
			"<CampaignStatus>" + camp.s_status_id + "</CampaignStatus>\r\n" + 
			"<CustID>" + camp.s_cust_id + "</CustID>\r\n";

		// === insert Chunk URL ===

		Vector svs = Services.getByCust(ServiceType.RQUE_CHUNK_REQUEST, camp.s_cust_id);
		Service sv = (Service) svs.get(0);
		String sURL = sv.getURL().toString();
		
		sCampaignDefinitionXml +=
			"<PullRecipientURL>" + sURL +
			"?CustID=" + camp.s_cust_id +				
			"&amp;CampID=" + camp.s_camp_id +
			"</PullRecipientURL>\r\n";

		// === === ===

		CampXml camp_xml = new CampXml();
		camp_xml.s_camp_id = camp.s_camp_id;
		if( camp_xml.retrieve() > 0 ) sCampaignDefinitionXml += camp_xml.s_camp_xml;
		else throw new Exception("Could not retrieve campaign xml!");

		sCampaignDefinitionXml += "</CampaignDefinition>\r\n";
		
		return sCampaignDefinitionXml;
	}	
}
