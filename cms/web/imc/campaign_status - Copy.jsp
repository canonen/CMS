<%@ page
	language="java"
	import="com.britemoon.cps.que.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			com.britemoon.cps.imc.*,
			com.britemoon.cps.xcs.cti.*,
			com.britemoon.cps.xcs.*,
			com.britemoon.cps.xcs.dts.*,
			com.britemoon.cps.xcs.dts.ws.*,
			com.britemoon.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.text.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
Element eRoot = XmlUtil.getRootElement(request);

Element e = XmlUtil.getChildByName(eRoot,"camp_status");

if(e!=null)
{
	CampStatus cs = new CampStatus(e);
	cs.save();
	
	String sCampId   = XmlUtil.getChildTextValue(e, "camp_id");
	String sStatusId = XmlUtil.getChildTextValue(e, "status_id");
	String sCustId   = XmlUtil.getChildTextValue(e, "cust_id");		
	String sChunkId  = XmlUtil.getChildTextValue(e, "chunk_id");
	
	String sUpdateStatusOnly = XmlUtil.getChildTextValue(e, "update_status_only");
	if (sUpdateStatusOnly != null && sUpdateStatusOnly.equals("Y"))
	{
		e = XmlUtil.getChildByName(eRoot,"camp_statistic");
		if (e != null)
		{
			CampStatistic cstat = new CampStatistic(e);
			cstat.save();
		}		  
		logger.info("Updating status only for check daily campaign with no recipients, camp_id = " + sCampId);		
		return;
	}
	
	Campaign camp = new Campaign(sCampId);
	
	boolean isPrintCampaign = false;
	if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
		isPrintCampaign = false;
	}

	// trigger export for non_email when the campaign is done (60)
	// trigger export for print campaign when the campaign is being processed (55)
	if ( (camp.s_type_id.equals("5") && sStatusId.equals("60")) ||
		 (isPrintCampaign && sStatusId.equals("55")) )
	{
		logger.info("Receiving campaign status update for: ");
		logger.info("          cust_id   = " + sCustId);
		logger.info("          camp_id   = " + sCampId);
		logger.info("          chunk_id  = " + sChunkId);
		logger.info("          status_id = " + sStatusId);
		logger.info(" update_status_only = " + sUpdateStatusOnly);

		/* export parameters */
		String sViewFields	    = null;
		String sDelimiter	    = null; 
		String sExportName	    = null;
		String[] sCategories    = null;
		
		/* obtain fields, delimiter, export name, categories from database */
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		String sSql = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("imc/campaign_status.jsp");
			stmt = conn.createStatement();

			if (isPrintCampaign)
			{
				// get cont ids
				String sContIdList = null;
				sSql = 
					"SELECT DISTINCT cont_id " +
					"  FROM cque_campaign " +
					" WHERE origin_camp_id = " + camp.s_origin_camp_id;
				rs = stmt.executeQuery(sSql);
				while (rs.next()) {
					if (sContIdList == null) {
						sContIdList = rs.getString(1);
					}
					else {
						sContIdList +=  "," + rs.getString(1);
					}
				}
				rs.close();
				logger.info("camp_id = "  + camp.s_origin_camp_id + ", cont_id = " + sContIdList);
				
				if (sContIdList != null)
				{
					// get saved cti_doc_attrs
					String sSavedAttrIdList = null;
					sSql = "SELECT DISTINCT attr_id FROM cxcs_cti_doc_attrs WHERE cont_id in (" + sContIdList + ") ORDER BY attr_id";
					rs = stmt.executeQuery(sSql);
					while (rs.next())
					{
						if (sSavedAttrIdList == null) sSavedAttrIdList = rs.getString(1);
						else sSavedAttrIdList +=  "," + rs.getString(1);
					}
					rs.close();
					logger.info("sSavedAttrIdList= " + sSavedAttrIdList);
											
					// call WS to populate the cxcs_cti_doc_attrs table
					try
					{
						StringTokenizer contIdList = new StringTokenizer(sContIdList, ",");
						while (contIdList.hasMoreTokens())
						{
							String contId = contIdList.nextToken();
							logger.info("calling web service to populate cxcs_cti_doc_attrs table for cont_id = " + contId);
							CTIDocAttributeWS docAttr = new CTIDocAttributeWS();
							docAttr.getDocAttributes(sCustId, contId);
						}
					}
					catch (Exception ex)
					{
						logger.info("oops! unable to call web services! changing camp status to ERROR for " + camp.s_camp_id);
						camp.s_status_id = String.valueOf(CampaignStatus.ERROR);
						camp.save();
					}
					
					// get new cti_doc_attrs
					String sNewAttrIdList = null;
					sSql = "SELECT DISTINCT attr_id FROM cxcs_cti_doc_attrs WHERE cont_id in (" + sContIdList + ") ORDER BY attr_id";
					rs = stmt.executeQuery(sSql);
					while (rs.next()) {
						if (sNewAttrIdList == null) {
							sNewAttrIdList = rs.getString(1);
						}
						else {
							sNewAttrIdList +=  "," + rs.getString(1);
						}
					}
					rs.close();
					logger.info("sNewAttrIdList= " + sNewAttrIdList);

					if (sNewAttrIdList != null && !sNewAttrIdList.equals(sSavedAttrIdList)) {
						// delete cti_doc_attrs from cque_camp_export_attr
						sSql = 
							"DELETE cque_camp_export_attr " +
							" WHERE camp_id = " + camp.s_origin_camp_id + 
							"   AND attr_id IN ( " + sSavedAttrIdList + ")";
						BriteUpdate.executeUpdate(sSql);
						logger.info("Deleting sSaveAttrIdList= " + sSavedAttrIdList);
						
						// get max seq no
						int next_seq_no = 0;
						sSql = "SELECT MAX(seq) FROM cque_camp_export_attr WHERE camp_id = " + camp.s_origin_camp_id;
						rs = stmt.executeQuery(sSql);
						if (rs.next()) next_seq_no = rs.getInt(1);
						rs.close();
						
						// insert new attr to cque_camp_export_attr table
						StringTokenizer attrIdList = new StringTokenizer(sNewAttrIdList, ",");
						while (attrIdList.hasMoreTokens())
						{
							String attrId = attrIdList.nextToken();
							next_seq_no++;
							sSql = 
								" INSERT INTO cque_camp_export_attr (camp_id, seq, attr_id) " +
								" VALUES (" + camp.s_origin_camp_id + "," + next_seq_no + "," + attrId + ")";
							BriteUpdate.executeUpdate(sSql);
						}
						logger.info("Saving sNewAttrIdList= " + sNewAttrIdList);
					}
				}
			}

			sSql = "SELECT export_name, delimiter FROM cque_camp_export WHERE camp_id = " + camp.s_origin_camp_id;
			rs = stmt.executeQuery(sSql);
			if (rs.next())
			{
				sExportName = rs.getString(1);
				sDelimiter = rs.getString(2);
				if (sDelimiter.equals("\\t")) sDelimiter = "\t";
			}
			rs.close();
			
			sSql = "SELECT DISTINCT attr_id FROM cque_camp_export_attr WHERE camp_id = " + camp.s_origin_camp_id;
			rs = stmt.executeQuery(sSql);
			while (rs.next())
			{
				if (sViewFields == null) sViewFields = rs.getString(1);
				else sViewFields += "," + rs.getString(1);
			}
			rs.close();
			
			sSql =
				" SELECT category_id FROM ccps_object_category " +
				" WHERE cust_id = " + sCustId + 
				" AND object_id = " + camp.s_origin_camp_id + 
				" AND type_id = 190 ";
				
			rs = stmt.executeQuery(sSql);
			Vector vec = new Vector();
			while (rs.next())
			{
				String val = rs.getString(1);
				vec.addElement(val);
			}
			rs.close();
			sCategories = new String[vec.size()];
			vec.copyInto(sCategories);
		}
		catch (Exception ex)
		{
			logger.error("Campaign Status Error!\r\n",ex);
		}
		finally
		{
			try { if (stmt != null) stmt.close(); }
			catch (Exception ex2) { }
			if (conn != null) cp.free(conn);
		}
		
		// xml to send to RCP
		
		String outXml="";			
		outXml = "<RecipRequest>\n" + "<cust_id>"+sCustId+"</cust_id>\n";
		outXml += "<camp_id>"+sCampId+"</camp_id>\n";
		if (sChunkId != null && !sChunkId.equals(""))
		{
			outXml += "<chunk_id>"+sChunkId+"</chunk_id>\n";
		}
		outXml += "<action>ExpCampSent</action>\n";
		outXml += "<num_recips>all</num_recips>\n" +
			"<attr_list>"+sViewFields+"</attr_list>\n" +
			"<delimiter>"+sDelimiter+"</delimiter>\n" +
			"</RecipRequest>\n";
		
		String PARAMS = "";
		PARAMS += "ExpCampSent; ";
		PARAMS += "camp_id="+sCampId+"; ";
		if (sChunkId != null && !sChunkId.equals("")) {
			PARAMS += "chunk_id="+sChunkId+"; ";	
		}
		PARAMS += "attr_list="+sViewFields+"; delimiter=''"+(sDelimiter.equals("\t")?"\\t":sDelimiter)+"''; ";
		
		/* Send request to RCP, the RCP should create */
		String sMsg = Service.communicate(ServiceType.REXP_EXPORT_SETUP, sCustId, outXml);
		logger.info("Request for Export:\n"+outXml);
		/* Receive response and save export */
		String fileUrl = "";
		try
		{
			Element eDetails = XmlUtil.getRootElement(sMsg);
			fileUrl = XmlUtil.getChildCDataValue(eDetails,"file_url");
			if (fileUrl == null) {
				//Probably an error
				String error = XmlUtil.getChildCDataValue(eDetails,"error");
				if (error == null)
					throw new Exception("");
				else
					throw new Exception(error);
			}
		} catch (Exception ex) {
			throw new Exception("RCP could not setup the export.  Please check the RCP system: "+ex.getMessage());
		}
		
		// add sample id to export name
		if (camp.s_sample_id != null)
		{
			if (camp.s_sample_id.equals("0")) sExportName += "-Final";
			else sExportName += "-Sample " + camp.s_sample_id;
		}

		// add chunk id to export name
		if (sChunkId != null && !sChunkId.equals("")) sExportName += " (" + sChunkId + ")";


		sSql =
			" INSERT cexp_export_file (type_id, cust_id, export_name, file_url, status_id, params) " +
			" VALUES (1," + sCustId + ",'" + sExportName + "', '" + fileUrl + "', " + ExportStatus.PROCESSING + ", '" + PARAMS + "')";
		BriteUpdate.executeUpdate(sSql);

		// get the file_id back
		String fileId = "";
		ConnectionPool cp2 = null;
		Connection conn2 = null;
		Statement stmt2 = null;
		ResultSet rs2 = null;
		try
		{
			cp2 = ConnectionPool.getInstance();
			conn2 = cp2.getConnection("imc/campaign_status_2.jsp");
			stmt2 = conn2.createStatement();
			String sSql2 = "SELECT file_id FROM cexp_export_file WHERE file_url = '"+fileUrl+"'";
			rs2 = stmt2.executeQuery(sSql2);
			if (rs2.next()) fileId = rs2.getString(1);
			rs2.close();
		}
		catch (Exception ex)
		{
			logger.error("Campaign Status Error!\r\n", ex);
		} 
		finally
		{
			try { if (stmt2 != null) stmt2.close(); } 
			catch (Exception ex2) { }
			if (conn2 != null) cp2.free(conn2);
		}

		if (fileUrl != null && fileUrl.length() > 0)
		{
			// update origin camp to contain the latest export's file_url
			sSql = "UPDATE cque_camp_export SET file_url = '" + fileUrl + "' WHERE camp_id = " + camp.s_origin_camp_id;
			BriteUpdate.executeUpdate(sSql);
			// create file_url for current camp (update in case of auto-respond)
			try
			{
				sSql =
					" INSERT cque_camp_export (camp_id, export_name, delimiter, file_url) " +
					" VALUES (" + camp.s_camp_id + ",'" +  sExportName + "','" + sDelimiter + "','" + fileUrl + "')";
				BriteUpdate.executeUpdate(sSql);
			}
			catch (Exception ex)
			{
				sSql =
					" UPDATE cque_camp_export SET file_url = '" + fileUrl + "'" +
					" WHERE camp_id = " + camp.s_camp_id;
				BriteUpdate.executeUpdate(sSql);
			}
		}
		
        /* save categories for export */	  
		int l = ( sCategories == null )?0:sCategories.length;
		if ( l > 0)
		{
			for(int i=0; i<l ;i++)
			{
				sSql =
					" INSERT ccps_object_category (cust_id,  object_id, type_id, category_id) " +
	                " SELECT " + sCustId +  ", file_id, " +  ObjectType.EXPORT + ", " +  sCategories[i] + 
					"   FROM cexp_export_file " + 
                    "  WHERE file_url = '" + fileUrl + "'";
				BriteUpdate.executeUpdate(sSql);
			}
		}

		/* queue campaign in cque_camp_print_order */
		if (isPrintCampaign)
		{
			sSql = 
				"INSERT cxcs_delivery (camp_id, chunk_id, file_id, create_date) " +
				" VALUES (" + sCampId + "," + sChunkId + "," + fileId + ", getDate() )";
			BriteUpdate.executeUpdate(sSql);
		}
	}
		
	// when the main campaign is done (60) or waiting (57), send the PV sendout test
	if (sStatusId.equals("60") || sStatusId.equals("57"))
	{
		System.out.println("Send out any pending PV sendout test");
		String sSql =
			"UPDATE cque_campaign" +
			"   SET status_id = " + CampaignStatus.SENT_TO_RCP +
			" WHERE status_id = " + CampaignStatus.DRAFT +
			"   AND type_id = " + CampaignType.TEST +
			"   AND mode_id = " + CampaignMode.DELIVERABILITY_SENDOUT +
			"   AND origin_camp_id = " + camp.s_origin_camp_id;

		BriteUpdate.executeUpdate(sSql);
		
		// do rcp setup for each pv sendout test
		ConnectionPool cp3 = null;
		Connection conn3 = null;
		Statement stmt3 = null;
		ResultSet rs3 = null;
		try	{
			cp3 = ConnectionPool.getInstance();
			conn3 = cp3.getConnection("imc/campaign_status_3.jsp");
			stmt3 = conn3.createStatement();
			String sSql3 = 
				"SELECT camp_id" +
				"  FROM cque_campaign" +
				" WHERE status_id = " + CampaignStatus.SENT_TO_RCP +
				"   AND type_id = " + CampaignType.TEST +
				"   AND mode_id = " + CampaignMode.DELIVERABILITY_SENDOUT +
				"   AND origin_camp_id = " + camp.s_origin_camp_id;
			rs3 = stmt3.executeQuery(sSql3);
			while (rs3.next()) {
				CampSetupUtil.doRcpSetup(rs3.getString(1));
			}
			rs3.close();
		}
		catch (Exception ex) {
			logger.error("Campaign Status Error!\r\n", ex);
		} 
		finally	{
			try { if (stmt3 != null) stmt3.close(); } 
			catch (Exception ex3) { }
			if (conn3 != null) cp3.free(conn3);
		}	
	}
	

}

e = XmlUtil.getChildByName(eRoot,"camp_statistic");
if(e!=null)
{
	CampStatistic cstat = new CampStatistic(e);
	cstat.save();
}
%>
