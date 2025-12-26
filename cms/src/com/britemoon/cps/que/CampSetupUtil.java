package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.adm.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.imc.*;
import com.britemoon.cps.tgt.*;

import java.sql.*;
import java.io.*;
import java.text.*;
import java.util.*;
import java.util.regex.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampSetupUtil
{
	private static Logger logger = Logger.getLogger(CampSetupUtil.class.getName());
	public static String prepareCamp4Setup(String sCampId, int nSampleId) throws Exception
	{
		return prepareCamp4Setup(sCampId, nSampleId, false);
	}
	
	public static String prepareCamp4Setup(String sCampId, int nSampleId, boolean bUseReservedCampId)
		throws Exception
	{
		String sNewCampId = null;
		
		sNewCampId = cloneCampFull(sCampId, nSampleId, bUseReservedCampId);

		Campaign new_camp = new Campaign(sNewCampId);
        if (!String.valueOf(CampaignType.NON_EMAIL).equals(new_camp.s_type_id))
		{
			if (new_camp.s_media_type_id == null || new_camp.s_media_type_id.equals("1") )
			{
				ContUtil.parseContBody(new_camp.s_cont_id);
			}
		}

		return sNewCampId;
	}

	public static String cloneCampFull(String sCampId, int nSampleId) throws Exception
	{
		return cloneCampFull(sCampId, nSampleId, false);
	}
	
	public static String cloneCampFull(String sCampId, int nSampleId, boolean bUseReservedCampId)
		throws Exception
	{
		String sNewCampId = null;
		
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CampSetupUtil.cloneCampFull()");
			String sSql =
				" EXEC usp_cque_camp_clone_full_2" +
				" @camp_id=?, @sample_id=?, @use_reserved_camp_id=?";
				
			PreparedStatement pstmt = null;
			try
			{
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCampId);
				pstmt.setInt(2, nSampleId);	
				pstmt.setInt(3, ((bUseReservedCampId)?1:0));
				ResultSet rs = pstmt.executeQuery();
				if(rs.next()) sNewCampId = rs.getString(1);
				rs.close();
			}
			catch(Exception ex)	{ throw ex; }
			finally { if( pstmt != null ) pstmt.close(); }
		}
		catch(Exception ex)	{ throw ex; }
		finally { if( conn != null ) cp.free(conn); }
		
		return sNewCampId;
	}

	private static void validateXml(String sXml) throws Exception
	{
		try { XmlUtil.getRootElement(sXml); }
		catch(Exception ex)
		{
			String sErrMsg = 
				"CampSetupUtil.validateXml() ERROR: " +
				"invalid XML:\r\n" + sXml;
			throw new Exception(sErrMsg);
		}
	}
	
	// === RCP ===
		
	public static void doRcpSetup(String sCampId) throws Exception
	{
		Campaign camp = new Campaign();
		camp.s_camp_id = sCampId;
		if(camp.retrieve() < 1)
			throw new Exception("CampSetupUtil.doRcpSetup() ERROR: campaign " + sCampId + " does not exist");
		
		String sRcpSetupXml = buildCampXml4Rcp(sCampId);
		String sResponse = Service.communicate(ServiceType.RQUE_CAMPAIGN_SETUP, camp.s_cust_id, sRcpSetupXml);
		processRcpCampSetupResponse(sResponse);
		
		CampSetupStatus cssSetupStatus = new CampSetupStatus(sCampId);
		cssSetupStatus.s_rcp_status = "1";
		cssSetupStatus.save();
	}
	
	public static String buildCampXml4Rcp(String sCampId) throws Exception
	{
		Campaign camp = new Campaign();
		camp.s_camp_id = sCampId;
		CampRetrieveUtil.retrieve4Rcp(camp);
		return camp.toXml();
	}

	public static void processRcpCampSetupResponse(String sXml) throws Exception
	{
		validateXml(sXml);
	}

	// === JTK ===
	
	public static void doJtkSetup(String sCampId) throws Exception
	{
		doJtkSetupOld(sCampId);

		CampSetupStatus cssSetupStatus = new CampSetupStatus(sCampId);
		cssSetupStatus.s_jtk_status = "1";
		cssSetupStatus.save();
	}
	
	public static void doJtkSetupOld(String sCampID) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CampSetup.setupJtk()");

			Statement stmt = null;
			try
			{
				stmt = conn.createStatement();
				doJtkSetupOld(sCampID, stmt);
			}
			catch(Exception ex) { throw ex; }
			finally { if( stmt != null ) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if( conn != null ) cp.free(conn); }
	}

	private static void doJtkSetupOld(String sCampID, Statement stmt) throws Exception
	{
		Campaign camp = new Campaign(sCampID);
		
		// === === ===

		StringWriter swXMLjtk = new StringWriter();
		StringWriter swXMLrcp = new StringWriter();

		swXMLjtk.write("<links>");
		swXMLrcp.write("<links>");
		
		int nLinksSent = 0;
		if(!String.valueOf(CampaignType.NON_EMAIL).equals(camp.s_type_id))
		{
			if (camp.s_media_type_id == null || camp.s_media_type_id.equals("1") )
			{
				nLinksSent = doJtkSetupOld(sCampID, stmt, swXMLjtk, swXMLrcp);
			}
		}
		else
		{
			nLinksSent = doJtkSetupOldNonEmail(sCampID, stmt, swXMLrcp);
		}

		swXMLjtk.write("</links>");
		swXMLrcp.write("</links>");

		// === === ===

		if(!String.valueOf(CampaignType.NON_EMAIL).equals(camp.s_type_id))
		{
			if (camp.s_media_type_id == null || camp.s_media_type_id.equals("1") )
			{			
				String sJtkResponse =
					Service.communicate(ServiceType.AJTK_CONTENT_LINK_SETUP, camp.s_cust_id, swXMLjtk.toString());
					
				int nLinksRecieved  = processJtkCampSetupResponse(sJtkResponse, stmt.getConnection());
				
				if ( nLinksSent != nLinksRecieved )
				{
					String sErrMsg = "nLinksSent (" + nLinksSent + ") != nLinksRecieved (" + nLinksRecieved + ")";
					throw new Exception(sErrMsg);
				}
			}
		}
		else
		{
			// Send read link to rcp for non-email campaign
			// This is not a good place for that
			// it has nothing to do with JTK setup
			// and the whole swXMLrcp stuff seems useless
			// sould be rewritten at some point
			Service.notify(ServiceType.RJTK_CAMP_LINK_SETUP, camp.s_cust_id, swXMLrcp.toString());		
		}
	}

	private static int doJtkSetupOldNonEmail(String sCampID, Statement stmt, StringWriter swXMLrcp)
		throws Exception
	{
		String sSql = null;
		ResultSet rs = null;

		String sCustID = null;
		String sLinkedCampID = null;
		
		sSql =
			" SELECT c.cust_id" +
			"   FROM cque_campaign c" +
			" WHERE c.camp_id = " + sCampID;

		rs = stmt.executeQuery(sSql);
		
		if (rs.next())
		{
			sCustID = rs.getString(1);
			rs.close();
		}
		else
		{
			rs.close();
			throw new Exception("CampSetup ERROR: Campaign does not exist");
		}
		
		swXMLrcp.write("<cust_id>" + sCustID + "</cust_id>");
		swXMLrcp.write("<camp_id>" + sCampID + "</camp_id>");

		sSql =
			" SELECT l.link_id" +
			"   FROM cjtk_link l" +
			"  WHERE l.link_name = 'read_link' AND l.camp_id = " + sCampID;
			
		rs = stmt.executeQuery(sSql);

		String sLinkID = null;
		byte[] bVal = new byte[255];

		int nLinksSent = 0;
		while(rs.next())
		{
			swXMLrcp.write("<link>");
			sLinkID = rs.getString(1);			
			swXMLrcp.write("<link_id>" + sLinkID + "</link_id>");
			swXMLrcp.write("<href><![CDATA[]]></href>");
			swXMLrcp.write("<link_name><![CDATA[read_link]]></link_name>");
			swXMLrcp.write("</link>");

			nLinksSent++;
		}
		rs.close();
		
		return nLinksSent;
	}

	private static int doJtkSetupOld(String sCampID, Statement stmt, StringWriter swXMLjtk, StringWriter swXMLrcp)
		throws Exception
	{
		String sSql = null;
		ResultSet rs = null;

		sSql =
			" DELETE cjtk_jtk_link" +
			" FROM cjtk_link l, cjtk_jtk_link j, cque_campaign c" +
			" WHERE j.link_id = l.link_id" +
			"	AND l.cont_id = c.cont_id" +
			"	AND c.camp_id = " + sCampID;
		
		stmt.executeUpdate(sSql);

		String sCustID = null;
		String sLinkedCampID = null;
		String sLinkAppendText = null;
		Campaign camp = new Campaign(sCampID);
		
		sSql =
			" SELECT c.cust_id, lc.linked_camp_id, sp.link_append_text" +
			" FROM cque_campaign c, cque_linked_camp lc, cque_camp_send_param sp" +
			" WHERE c.camp_id = lc.camp_id" +
			" AND c.camp_id = sp.camp_id" +
			" AND c.camp_id = " + sCampID;

		rs = stmt.executeQuery(sSql);
		
		if (rs.next())
		{
			sCustID = rs.getString(1);
			sLinkedCampID = rs.getString(2);
			byte[] b = rs.getBytes(3);
			sLinkAppendText = (b == null)?null:new String(b,"UTF-8");
			rs.close();
		}
		else
		{
			rs.close();
			throw new Exception("CampSetup ERROR: Campaign does not exist");
		}

		if (sLinkedCampID !=null)
		{
			// Get actual sent camp_id, or latest test camp_id if real campaign not sent yet
			sSql =
				" SELECT TOP 1 camp_id FROM cque_campaign" +
				" WHERE origin_camp_id = " + sLinkedCampID +
				" ORDER BY type_id DESC, camp_id DESC";
				
			rs = stmt.executeQuery(sSql);
			if (rs.next()) sLinkedCampID = rs.getString(1);
			rs.close();
		}

		String sCustLinkAppend = null;
		sSql = "EXEC usp_ccps_link_append_get @cust_id = "+sCustID;
		rs = stmt.executeQuery(sSql);
		if (rs.next())
		{
			byte[] b = rs.getBytes(1);
			sCustLinkAppend = (b!=null)?(new String(b,"UTF-8")):null;
		}
		rs.close();
		
		if (sCustLinkAppend != null)
		{
			Vector vContAttrs = new Vector();
			sSql = "SELECT a.attr_name, c.attr_value"
				+ " FROM ccps_cont_attr a, ccps_cont_attr_value c"
				+ " WHERE a.attr_id = c.attr_id"
				+ " AND c.cust_id = "+sCustID;
				
			rs = stmt.executeQuery(sSql);
			while (rs.next())
			{
				String[] sContAttr = new String[2];
				sContAttr[0] = rs.getString(1);
				byte[] b = rs.getBytes(2);
				sContAttr[1] = (b!=null)?(new String(b,"UTF-8")):null;
				vContAttrs.add(sContAttr);
			}
			rs.close();
			
			String [] sCampDateAttr = { "camp_date", "" };
			vContAttrs.add(sCampDateAttr);
			
			for (int i=0; i<vContAttrs.size(); i++)
			{
				String[] sContAttr = (String[])vContAttrs.get(i);
				sCustLinkAppend = replaceContAttr(sCustLinkAppend,sContAttr[0],sContAttr[1]);
			}
		}	


		// ===
		
		Service service = null;
		Vector services = Services.getByCust(ServiceType.AJTK_CONTENT_LINK_SETUP, sCustID);
		service = (Service) services.get(0);

		VanityDomains vds = new VanityDomains();
		vds.s_cust_id = sCustID;
		vds.s_mod_inst_id = service.s_mod_inst_id;
		vds.retrieve();

		Enumeration eVanityDomains = vds.elements();
		VanityDomain vd = null;
		if (eVanityDomains.hasMoreElements()) vd = (VanityDomain)eVanityDomains.nextElement();

		// ===

		swXMLjtk.write("<cust_id>" + sCustID + "</cust_id>");
		swXMLjtk.write("<camp_id>" + sCampID + "</camp_id>");
		if (vd != null)
			swXMLjtk.write("<vanity_domain>" + vd.s_domain + "</vanity_domain>");

		swXMLrcp.write("<cust_id>" + sCustID + "</cust_id>");
		swXMLrcp.write("<camp_id>" + sCampID + "</camp_id>");

		sSql =
			" SELECT l.link_id, l.href, l.link_name" +
			" FROM cjtk_link l, cque_campaign c" +
			" WHERE l.cont_id = c.cont_id" +
			" AND c.camp_id =" + sCampID;
			
		rs = stmt.executeQuery(sSql);

		String sLinkID = null;
		byte[] bVal = new byte[255];

		int nLinksSent = 0;
		while(rs.next())
		{
			swXMLjtk.write("<link>");
			swXMLrcp.write("<link>");
			sLinkID = rs.getString(1);
			
			swXMLjtk.write("<link_id>" + sLinkID + "</link_id>");
			swXMLrcp.write("<link_id>" + sLinkID + "</link_id>");
						
			bVal = rs.getBytes(2);
			String sLinkUrl = null;
			String sTmpAppend = null;
			boolean bTmpAppendAdded = false;
			if (bVal!=null)
			{
				sLinkUrl = new String(bVal,"UTF-8");
				sLinkUrl = replaceLinkedCampID(sLinkUrl, sLinkedCampID);
				if (sCustLinkAppend != null) {
					sTmpAppend = replaceContAttr(sCustLinkAppend,"link_id",sLinkID);
					bTmpAppendAdded = true;
				}
				
				
			}
                        
			swXMLjtk.write("<fwd_brt_params>0</fwd_brt_params>");
		
			bVal = rs.getBytes(3);
			if (bVal!=null)
			{
				String sLinkName = new String(bVal, "UTF-8");
				if (sCustLinkAppend != null) {
					sTmpAppend = replaceContAttr(sTmpAppend,"link_name", sLinkName);
					bTmpAppendAdded = true;
				}
			}
			
			if (camp.s_camp_name != null) {
				if (sCustLinkAppend != null) {
					sTmpAppend = replaceContAttr(sTmpAppend,"camp_name",camp.s_camp_name);
					bTmpAppendAdded = true;
				}
			}

			if (camp.s_camp_code != null) {
				if (sCustLinkAppend != null) {
					sTmpAppend = replaceContAttr(sTmpAppend,"camp_code",camp.s_camp_code);
					bTmpAppendAdded = true;
				}
			}

			if (sLinkUrl != null) {
	            if (bTmpAppendAdded){
	                sLinkUrl = appendLinkText(sLinkUrl, sTmpAppend);
	            }
	            else {
	                 sLinkUrl = appendLinkText(sLinkUrl, sLinkAppendText);
	            }
	                        
	            swXMLjtk.write("<destination_url><![CDATA[" + sLinkUrl + "]]></destination_url>");
				swXMLrcp.write("<href><![CDATA[" + sLinkUrl + "]]></href>");			
			}
			swXMLrcp.write("</link>");
            swXMLjtk.write("</link>");

			nLinksSent++;
		}
		rs.close();
		
		return nLinksSent;
	}

	public static int processJtkCampSetupResponse(String sResponse, Connection conn) throws Exception
	{
		Element e = XmlUtil.getRootElement(sResponse);
		
		XmlElementList elLinks = XmlUtil.getChildrenByName(e,"jtk_link");
		int l = elLinks.getLength();

		Element eLink = null;
		
		String sLinkId = null;
		String sHtmlTrackingUrl = null;
		String sTextTrackingUrl = null;
		String sAolTrackingUrl = null;

		int nLinksRecieved = 0;
		String sSql =
			"INSERT cjtk_jtk_link (link_id,html_tracking_url,text_tracking_url,aol_tracking_url)" +
			" VALUES (?,?,?,?)";

		PreparedStatement pstmt = null;

		for (int i = 0; i < l; ++i )
		{
			eLink = (Element)elLinks.item(i);
			
			sLinkId = XmlUtil.getChildTextValue(eLink, "link_id");
			sHtmlTrackingUrl = XmlUtil.getChildCDataValue(eLink, "html_tracking_url");
			sTextTrackingUrl = XmlUtil.getChildCDataValue(eLink, "text_tracking_url");
			sAolTrackingUrl = XmlUtil.getChildCDataValue(eLink, "aol_tracking_url");

			try
			{
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sLinkId);			
				pstmt.setString(2, sHtmlTrackingUrl);
				pstmt.setString(3, sTextTrackingUrl);
				pstmt.setString(4, sAolTrackingUrl);
				pstmt.executeUpdate();
			}
			catch(Exception ex) { throw ex; }
			finally	{ if(pstmt!=null) pstmt.close(); }
			
			if((sHtmlTrackingUrl != null) && (sAolTrackingUrl != null)) nLinksRecieved++;
		}
		return nLinksRecieved;
	}

	// === INB === // v 3.xx on Lotus Notes is not supported any more
	
	public static void doInbSetup(String sCampId) throws Exception
	{
		Campaign camp = new Campaign();
		camp.s_camp_id = sCampId;
		if(camp.retrieve() < 1)
			throw new Exception("CampSetupUtil.doInbSetup() ERROR: campaign " + sCampId + " does not exist");
		
		String sInbSetupXml = buildCampXml4Inb(sCampId);
		
		String sResponse = Service.communicate(ServiceType.AINB_CAMPAIGN_NOTIFY, camp.s_cust_id, sInbSetupXml);
		processInbCampSetupResponse(sResponse);

		CampSetupStatus cssSetupStatus = new CampSetupStatus(sCampId);
		cssSetupStatus.s_inb_status = "1";
		cssSetupStatus.save();
	}

	public static String buildCampXml4Inb(String sCampId) throws Exception
	{
		Campaign camp = new Campaign(sCampId);

		String sCharsetId = new Content(camp.s_cont_id).s_charset_id;
		String sFrwdAddr = new CampSendParam(sCampId).s_response_frwd_addr;
		String sStartDate = new Schedule(sCampId).s_start_date;

		StringWriter sw = new StringWriter();

		sw.write("<campaign>");

		if( camp.s_camp_id != null ) sw.write("<camp_id>" + camp.s_camp_id + "</camp_id>");
		if( camp.s_camp_name != null ) sw.write("<camp_name><![CDATA[" + camp.s_camp_name + "]]></camp_name>");
		if( camp.s_cust_id != null ) sw.write("<cust_id>" + camp.s_cust_id + "</cust_id>");
		if( camp.s_type_id != null ) sw.write("<type_id>" + camp.s_type_id + "</type_id>");
		if( sCharsetId != null ) sw.write("<charset_id>" + sCharsetId + "</charset_id>");		
		if( camp.s_origin_camp_id != null ) sw.write("<origin_camp_id>" + camp.s_origin_camp_id + "</origin_camp_id>");
		if( sFrwdAddr != null )
		{
			sw.write("<camp_frwd_param>");
			if( camp.s_camp_id != null ) sw.write("<camp_id>" + camp.s_camp_id + "</camp_id>");
			sw.write("<frwd_addr><![CDATA[" + sFrwdAddr + "]]></frwd_addr>");	
			sw.write("</camp_frwd_param>");
		}
		if( sStartDate != null ) sw.write("<start_date>" + sStartDate + "</start_date>");
			
		MsgHeader msg_header = new MsgHeader();
		msg_header.s_camp_id = sCampId;
		if (msg_header.retrieve() > 0)
		{
			msg_header.m_sMainElementName = "camp_header"; //for backward compatibility
			sw.write(msg_header.toXml());
		}

		sw.write("</campaign>");

		return sw.toString();
	}

	public static void processInbCampSetupResponse(String sXml) throws Exception
	{
		validateXml(sXml);	
	}

	// === MAILER ===
	
	public static void doMailerSetup(String sCampId) throws Exception
	{
		CampSetupStatus cssSetupStatus = new CampSetupStatus(sCampId);
		if(cssSetupStatus.s_jtk_status == null)
			throw new Exception("CampSetupUtil.doMailerSetup ERROR: JTK setup should run before MAILER setup!");
	
		// === === ===

		try
		{
			String sXml = buildCampXml4Mailer(sCampId);
			validateXml("<some_wrapping_tag>" + sXml + "</some_wrapping_tag>"); // validate xml just in case

			// === === ===
			
			CampXml camp_xml = new CampXml();
			camp_xml.s_camp_id = sCampId;
			camp_xml.s_camp_xml = sXml;
			camp_xml.save();
			
			// === === ===

			String sSql =
				" UPDATE cque_campaign" +
				" SET status_id=" + CampaignStatus.READY_TO_SEND +
				" WHERE camp_id=" + sCampId;
				
			BriteUpdate.executeUpdate(sSql);				
		}
		catch(Exception ex)
		{
			String sSql =
				" UPDATE cque_campaign" +
				" SET status_id=" + CampaignStatus.ERROR +
				" WHERE camp_id=" + sCampId;

			BriteUpdate.executeUpdate(sSql); 
			throw ex;
		}

		// === === ===

		cssSetupStatus.s_mailer_status = "1";
		cssSetupStatus.save();
	}

	public static String buildCampXml4Mailer(String sCampID) throws Exception
	{
		String sXml = null;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CampSetupUtil.buildCampXml4Mailer()");

			Statement stmt = null;
			try
			{
				stmt = conn.createStatement();
				sXml = buildCampXml4Mailer(sCampID, stmt);
			}
			catch(Exception ex) { throw ex; }
			finally	{ if( stmt != null ) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if( conn != null ) cp.free(conn); }

		return sXml;
	}
	
	private static String buildCampXml4Mailer(String sCampID, Statement stmt) throws Exception
	{
		// String sSql = "DELETE cque_camp_xml WHERE camp_id = " + sCampID;
		// stmt.executeUpdate(sSql);

		String sCustID = null;
		String sLinkedCampID = null;

		String sSql =
			" SELECT c.cust_id, lc.linked_camp_id" +
			" FROM cque_campaign c, cque_linked_camp lc" +
			" WHERE" +
			" c.camp_id = lc.camp_id" +
			" AND c.camp_id = " + sCampID;

		ResultSet rs = stmt.executeQuery(sSql);
		
		if (rs.next())
		{
			sCustID = rs.getString(1);
			sLinkedCampID = rs.getString(2);
			rs.close();
		}
		else
		{
			rs.close();
			throw new Exception("CampSetup ERROR: Campaign does not exist");
		}

		if (sLinkedCampID !=null)
		{
			// Get actual sent camp_id, or latest test camp_id if real campaign not sent yet
			sSql =
				" SELECT TOP 1 camp_id FROM cque_campaign" +
				" WHERE origin_camp_id = " + sLinkedCampID +
				" ORDER BY type_id DESC, camp_id DESC";
				
			rs = stmt.executeQuery(sSql);
			if (rs.next()) sLinkedCampID = rs.getString(1);
			rs.close();
		}

		// === === ===

		StringWriter swXML = new StringWriter();
		
		// === === ===

		Vector vMacro = new Vector();

		String strMacro1=null;
		strMacro1="CampaignID";
		vMacro.add(strMacro1);

		String strMacro2=null;
		strMacro2="RecipID";
		vMacro.add(strMacro2);

		String strMacro3=null;
		strMacro3="EmailClientType";
		vMacro.add(strMacro3);

		String strMacro4=null;
		strMacro4="SendEmail";
		vMacro.add(strMacro4);

		sSql = "EXEC usp_cque_macro_attr_get "+sCustID;
		rs=stmt.executeQuery(sSql);
		byte[] b = null;
		while (rs.next())
		{
			b = rs.getBytes("attr_name");
			if( b == null ) continue;
			String strMacroValue = new String(b,"UTF-8").trim();
			vMacro.add(strMacroValue);
		}
		rs.close();

		sSql =
			" SELECT" +
			"	g.type_id," +
			"	ch.charset_name," +
			"	ISNULL(m.from_name,' ')," +
			"	m.from_address," +
			"	m.from_address_id," +
			"	ISNULL(m.subject_text,' ')," +
			"	ISNULL(m.subject_html,' ')," +
			"	ISNULL(m.subject_aol,' ')," +
			"	g.cont_id, g.filter_id," +
			"	ISNULL(csp.send_text_flag,0)," +
			"	ISNULL(csp.send_html_flag,0)," +
			"	ISNULL(csp.send_aol_flag,0)," +
			"	m.reply_to," +
			"	g.pv_iq" +
			" FROM" +
			"	cque_campaign g," +
			"	cque_msg_header m," +
			"	ccnt_content c," +
			"	ccnt_cont_send_param csp," +			
			"	ccnt_charset ch" +
			" WHERE" +
			"		g.cont_id = c.cont_id" +
			"  AND  csp.cont_id = c.cont_id" +
			"  AND  c.charset_id = ch.charset_id" +
			"  AND  g.camp_id = m.camp_id" +
			"  AND  g.camp_id = " + sCampID;
			
		// will also need content_types in above query

		String sMValue = null;
		int nCampType = 0;

		String sTestSubj = null;
		String sFromName = null;
		String sFromAddr = null;
		String sFromAddrID = null;
		String sSubjectText = null;
		String sSubjectHTML = null;
		String sSubjectAol = null;
		String sSendContentID = null;
		String sSendTgtGrpID = null;
		String sEnableText = null;
		String sEnableHTML = null;
		String sEnableAol = null;
		String sSendReplyToAddr821 = null;
		String sPvIq = null;
		
		rs = stmt.executeQuery(sSql);
		if (rs.next()) 
		{
			nCampType = rs.getInt(1);
			swXML.write("<InternationalSendType>"+rs.getString(2)+"</InternationalSendType>\r\n");
			
			b = rs.getBytes(3);
			sFromName = (b!=null)?new String(b,"UTF-8").trim():"";
			b = rs.getBytes(4);
			sFromAddr = (b!=null)?new String(b,"UTF-8").trim():"";
			
			sFromAddrID = rs.getString(5);
			
			b = rs.getBytes(6);			
			sSubjectText = (b!=null)?new String(b,"UTF-8").trim():"";
			
			b = rs.getBytes(7);			
			sSubjectHTML = (b!=null)?new String(b,"UTF-8").trim():"";
			
			b = rs.getBytes(8);			
			sSubjectAol = (b!=null)?new String(b,"UTF-8").trim():"";
			
			sSendContentID = rs.getString(9);
			sSendTgtGrpID = rs.getString(10);
			sEnableText = rs.getString(11);
			sEnableHTML = rs.getString(12);
			sEnableAol = rs.getString(13);
			b = rs.getBytes(14);
			sSendReplyToAddr821 = (b!=null)?new String(b,"UTF-8").trim():"";
			sPvIq = rs.getString(15);
			if (sPvIq != null) {
				swXML.write("<PvIq>"+sPvIq+"</PvIq>\r\n");
			}
		}
		rs.close();

		sTestSubj = "";
		if (nCampType == CampaignType.TEST) 
		{
			sSql =
				" SELECT l.type_id" +
				" FROM cque_camp_list c, cque_email_list l" +
				" WHERE c.test_list_id = l.list_id" +
				" AND c.camp_id = " + sCampID;

			rs = stmt.executeQuery(sSql);
			int nTypeID = 0;
			if (rs.next()) nTypeID = rs.getInt(1);
			rs.close();
			// Add recip_id for Dynamic Content Test
			if (sPvIq == null) {
				sTestSubj = (nTypeID == 7)?"[TEST �@RCP.RecipID;�]: ":"[TEST]: ";
			}
		}


		if (sFromAddrID != null)
		{
			sSql =
				" SELECT f.prefix + '@' + f.domain" +
				" FROM ccps_from_address f" +
				" WHERE f.from_address_id = "+sFromAddrID;

			rs = stmt.executeQuery(sSql);
			String sVal = null;
			if (rs.next())
			{
				b = rs.getBytes(1);
				sVal = (b!=null)?new String(b,"UTF-8").trim():null;
			}
			rs.close();
			sFromAddr = (sVal!=null)?sVal:sFromAddr;
		}

		// === === ===

		for (int i=0; i<vMacro.size(); i++)
		{
			sMValue = (String)vMacro.get(i);
			sFromName = changeMacroValueName(sFromName,sMValue);
			sFromAddr = changeMacroValueName(sFromAddr,sMValue);
			sSubjectText = changeMacroValueName(sSubjectText,sMValue);
			sSubjectHTML = changeMacroValueName(sSubjectHTML,sMValue);
			sSubjectAol = changeMacroValueName(sSubjectAol,sMValue);
			sSendReplyToAddr821 = changeMacroValueName(sSendReplyToAddr821,sMValue);
		}

		// === === ===
		
		swXML.write("<SendFromName><![CDATA["+sFromName+"]]></SendFromName>\r\n");
		swXML.write("<SendFromAddr821><![CDATA["+sFromAddr+"]]></SendFromAddr821>\r\n");
		swXML.write("<SendSubjectText><![CDATA["+sTestSubj+sSubjectText+"]]></SendSubjectText>\r\n");
		swXML.write("<SendSubjectHTML><![CDATA["+sTestSubj+sSubjectHTML+"]]></SendSubjectHTML>\r\n");
		swXML.write("<SendSubjectAOL><![CDATA["+sTestSubj+sSubjectAol+"]]></SendSubjectAOL>\r\n");
		swXML.write("<SendContentID>"+sSendContentID+"</SendContentID> \r\n");
		swXML.write("<SendTgtGrpID>"+sSendTgtGrpID+"</SendTgtGrpID> \r\n");
		swXML.write("<EnableText>"+sEnableText+"</EnableText>\r\n");
		swXML.write("<EnableHTML>"+sEnableHTML+"</EnableHTML>\r\n");
		swXML.write("<EnableAOL>"+sEnableAol+"</EnableAOL>\r\n");

		// === === ===
		
		CustSendParam csp = new CustSendParam(sCustID);
		String sErrorsToAddr = csp.s_error_to_address; //SendErrorToAddr821
		
		//String sSenderAddr = csp.s_sender_address;
		String sSenderAddr = sFromAddr;

		if((sErrorsToAddr == null) || (sSenderAddr == null))
		{
			if (sFromAddrID != null)
			{
				 if (sErrorsToAddr == null) sErrorsToAddr = sFromAddr;
				 if (sSenderAddr == null) sSenderAddr = sFromAddr;			 
			}
			else 
			{
				sSql =
					" SELECT TOP 1 f.prefix + '@' + f.domain" +
					" FROM ccps_from_address f" +
					" WHERE f.cust_id = " + sCustID + " ORDER by f.from_address_id";
				rs = stmt.executeQuery(sSql);
				
				String sFirstFromAddress = null;
				if (rs.next())
				{
					b = rs.getBytes(1);
					sFirstFromAddress = (b!=null)?new String(b,"UTF-8").trim():null;
				}
				rs.close();

				if (sErrorsToAddr == null) sErrorsToAddr = sFirstFromAddress;
				if (sSenderAddr == null) sSenderAddr = sFirstFromAddress;			 
			}
		}
		
		// === === ===
				
		if (sSendReplyToAddr821 != null)
			swXML.write("<SendReplyToAddr821>"+sSendReplyToAddr821+"</SendReplyToAddr821>\r\n");
		if (sErrorsToAddr != null)
			swXML.write("<SendErrorsToAddr821>"+sErrorsToAddr+"</SendErrorsToAddr821>\r\n");
		if (sSenderAddr != null)
			swXML.write("<SenderAddr821>"+sSenderAddr+"</SenderAddr821>\r\n");
		
		// === Unsub Msg ===

		String sUnsubPosition = "1";
		String sUnsubText = "";
		String sUnsubHTML = "";
		String sUnsubAol = "";

		sSql = "EXEC usp_cque_camp_unsub_msg_get "+sCustID+", "+sCampID;
		rs= stmt.executeQuery(sSql);
		if (rs.next())
		{
			sUnsubPosition = rs.getString(1);
			b = rs.getBytes(2);
			sUnsubText = (b!=null)?new String(b,"UTF-8"):" ";
			b = rs.getBytes(3);			
			sUnsubHTML = (b!=null)?new String(b,"UTF-8"):" ";
			b = rs.getBytes(4);			
			sUnsubAol = (b!=null)?new String(b,"UTF-8"):" ";
		}

		// === Jump Tracking ===

		byte[] bRedirectUrl = new byte[4000];
		String sRedirectUrl = null;					
		Vector vRedirectUrl = new Vector();
		Vector vHtmlTrackingUrl = new Vector();
		Vector vTextTrackingUrl = new Vector();
		Vector vAolTrackingUrl = new Vector();
		
		String sReadHTML = "";
		String sReadAol = "";

		rs = stmt.executeQuery(sSql);
		sSql  =
			" SELECT l.href, j.html_tracking_url," +
			" j.text_tracking_url, j.aol_tracking_url" +
			" FROM cjtk_link l, cjtk_jtk_link j, cque_campaign c" +
			" WHERE l.cont_id = c.cont_id" +
			" AND l.link_id = j.link_id" +
			" AND c.camp_id =" + sCampID +
			" ORDER BY len(l.href) DESC";
		
		rs=stmt.executeQuery(sSql);
		while (rs.next())
		{
			bRedirectUrl = rs.getBytes(1);
			if (bRedirectUrl != null) 
				sRedirectUrl = new String(bRedirectUrl,"UTF-8");
			else
				sRedirectUrl = null;

			if (sRedirectUrl==null)
			{
				//------------------- Add 'Bug' image ----------------
				sReadHTML += "<IMG SRC=\"" + new String(rs.getBytes(2),"UTF-8") +"\" height=1 width=1 style=\"display:none\">";
				sReadAol += "<IMG SRC=\"" + new String(rs.getBytes(4),"UTF-8") +"\" height=1 width=1 style=\"display:none\">";
			}
			else
			{
				vRedirectUrl.add(sRedirectUrl);
				vHtmlTrackingUrl.add(new String(rs.getBytes(2),"UTF-8"));
				vTextTrackingUrl.add(new String(rs.getBytes(3),"UTF-8"));
				vAolTrackingUrl.add(new String(rs.getBytes(4),"UTF-8"));
			}
		}
		rs.close();

		sSql = "EXEC usp_cque_camp_cont_get " + sCampID;
		rs = stmt.executeQuery(sSql);
		swXML.write("<SendContent>\r\n");

		String sParagraphID = null;
		String strHTML = null;
		String strText = null;
		String strAol = null;
		while (rs.next())
		{
			sParagraphID = rs.getString(1);
			b = rs.getBytes(2);
			strText = (b!=null)?new String(b,"UTF-8"):" ";
			b = rs.getBytes(3);
			strHTML = (b!=null)?new String(b,"UTF-8"):" ";
			b = rs.getBytes(4);
			strAol = (b!=null)?new String(b,"UTF-8"):" ";

			//------------------- Replace Jump Tracking URLs -------------
			
			strHTML = replaceJumpTracking(strHTML, vRedirectUrl, vHtmlTrackingUrl);
			strText = replaceJumpTracking(strText, vRedirectUrl, vTextTrackingUrl);
			strAol  = replaceJumpTracking(strAol,  vRedirectUrl, vAolTrackingUrl);

			//------------------- Replace Linked Campaign ID -------------
			
			strHTML = replaceLinkedCampID(strHTML, sLinkedCampID);
			strText = replaceLinkedCampID(strText, sLinkedCampID);
			strAol  = replaceLinkedCampID(strAol,  sLinkedCampID);

			//------------------ Substitute Macro ------------------

			for (int i=0; i<vMacro.size(); i++)
			{
				sMValue = (String)vMacro.get(i);
				strHTML = changeMacroValueName(strHTML,sMValue);
				strText = changeMacroValueName(strText,sMValue);
				strAol = changeMacroValueName(strAol,sMValue);
			}

			swXML.write("<Paragraph>\r\n");
			swXML.write("  <ParagraphID>"+sParagraphID+"</ParagraphID>\r\n");
			swXML.write("  <ParagraphText><![CDATA["+(!strText.equals(" ")?strText:"")+"]]></ParagraphText>\r\n");
			swXML.write("  <ParagraphHTML><![CDATA["+(!strHTML.equals(" ")?strHTML:"")+"]]></ParagraphHTML>\r\n");
			swXML.write("  <ParagraphAOL><![CDATA["+(!strAol.equals(" ")?strAol:"")+"]]></ParagraphAOL>\r\n");
			swXML.write("</Paragraph>\r\n");
		}

		//------------------- Replace Jump Tracking URLs -------------
		
		sUnsubHTML = replaceJumpTracking(sUnsubHTML, vRedirectUrl, vHtmlTrackingUrl);
		sUnsubText = replaceJumpTracking(sUnsubText, vRedirectUrl, vTextTrackingUrl);
		sUnsubAol  = replaceJumpTracking(sUnsubAol,  vRedirectUrl, vAolTrackingUrl);

		//------------------ Substitute Macro ------------------

		for (int i=0; i<vMacro.size(); i++)
		{
			sMValue = (String)vMacro.get(i);
			sUnsubHTML = changeMacroValueName(sUnsubHTML,sMValue);
			sUnsubText = changeMacroValueName(sUnsubText,sMValue);
			sUnsubAol = changeMacroValueName(sUnsubAol,sMValue);
			sReadHTML = changeMacroValueName(sReadHTML,sMValue);
			sReadAol = changeMacroValueName(sReadAol,sMValue);
		}

		swXML.write("<UnsubMsg>\r\n");
		swXML.write("  <Position>"+sUnsubPosition+"</Position>\r\n");
		swXML.write("  <UnsubText><![CDATA["+sUnsubText+"]]></UnsubText>\r\n");
		swXML.write("  <UnsubHTML><![CDATA["+sUnsubHTML+"]]></UnsubHTML>\r\n");
		swXML.write("  <UnsubAOL><![CDATA["+sUnsubAol+"]]></UnsubAOL>\r\n");
		swXML.write("</UnsubMsg>\r\n");

		swXML.write("<ReadLink>\r\n");
		swXML.write("  <ReadLinkHTML><![CDATA["+sReadHTML+"]]></ReadLinkHTML>\r\n");
		swXML.write("  <ReadLinkAOL><![CDATA["+sReadAol+"]]></ReadLinkAOL>\r\n");
		swXML.write("</ReadLink>\r\n");

		swXML.write("</SendContent>\r\n");

		return swXML.toString();
	}

	private static String changeMacroValueName(String strTarget, String oldMacro)
	{
		Pattern p = Pattern.compile("!\\*"+oldMacro+";(.*?)\\*!");
		Matcher m = p.matcher(strTarget);
		return m.replaceAll("�@RCP."+oldMacro+";$1�");
	}

	private static String replaceJumpTracking
				(String strTarget, Vector vRedirectUrl, Vector vTrackingUrl)
				throws Exception
	{
		String sRedirectUrl = null;
		String sTrackingUrl = null;
								
		StringBuffer sbTarget;
		String strParameters;
		
		int nUrlCount = vRedirectUrl.size();
		for(int j = 0; j < nUrlCount; ++j)
		{
			sRedirectUrl = (String) vRedirectUrl.get(j);
			sTrackingUrl = (String) vTrackingUrl.get(j);

			for (int i = strTarget.indexOf(sRedirectUrl); i >= 0; i = strTarget.indexOf(sRedirectUrl, i))
			{
				sbTarget = new StringBuffer(strTarget);
				strTarget = sbTarget.replace(i, i + sRedirectUrl.length(), sTrackingUrl).toString();
			}
		}
		return strTarget;
	}

	private static String replaceLinkedCampID(String strTarget, String strLinkedID)
	{
		if (strLinkedID == null) return strTarget;

		Pattern p = Pattern.compile("!\\*linked_camp_id\\*!");
		Matcher m = p.matcher(strTarget);
		return m.replaceAll(strLinkedID);
	}

	private static String replaceContAttr (String sContent, String sAttrName, String sAttrValue) throws Exception
	{
		String sResult = sContent;
		if ((sContent == null) || (sAttrName == null)) return sResult;

		String tmp;
		int offset,i,j,k;

		tmp = sResult;
		offset = 0;
		i = tmp.indexOf("!*"+sAttrName+";");
		while (i != -1) {
			tmp = tmp.substring(i);
			j = tmp.indexOf("*!");
			if (j != -1) {
				if (sAttrValue.length() == 0) {
					k = tmp.indexOf(";");
					if (k != -1 && k < j) {
						//Use default since attr_value was not provided
						sAttrValue = tmp.substring(k+1,j);
					}
				}
				if (sAttrName.toLowerCase().indexOf("date") > -1) {
					// try to interpret AttrValue as a DateFormat, and replace with current date
					// if fails, then AttrValue is entered as is
					try {
						String sTmp = null;
						String sDateFormat = sAttrValue;
						// DateFormat m = minutes, M = month
						// If date format has m, but not M, assume meant month for m and replace
						sDateFormat = ((sDateFormat.indexOf("M")<0)&&(sDateFormat.indexOf("m")>-1))?sDateFormat.replace('m','M'):sDateFormat; 
						// Day in month and year should be lowercase
						sDateFormat = sDateFormat.replace('Y','y'); 
						sDateFormat = sDateFormat.replace('D','d'); 
						SimpleDateFormat sdf = new SimpleDateFormat(sDateFormat);
						sTmp = sdf.format(new java.util.Date());
						sAttrValue = sTmp;
					} catch (Exception ignore) 
					{ 
						logger.error("CampSetupUtil.replaceContAttr(): Problem with DateFormat "+sAttrName+" = '"+sAttrValue+"'.",ignore);
					}
				}
				sResult = sResult.substring(0,offset+i)+sAttrValue+tmp.substring(j+2);

				offset += sAttrValue.length()+i-2;
				tmp = tmp.substring(j);
				i = tmp.indexOf("!*"+sAttrName+";");
			} else {
				i = -1;
			}
		}
		return sResult;
	}


	private static String appendLinkText(String sLink, String sAppendText)
	{
		if (sLink == null) return sLink;
		String sResult = sLink.trim();
		if ((sAppendText != null) && (sAppendText.trim().length() > 0))
		{
			sAppendText = sAppendText.trim();
			sAppendText = ((sAppendText.charAt(0) == '?') || (sAppendText.charAt(0) == '&'))?sAppendText.substring(1):sAppendText;
			sResult += ((sResult.indexOf("?") > -1)?"&":"?")+sAppendText;
		}

		return sResult;
	}
}
