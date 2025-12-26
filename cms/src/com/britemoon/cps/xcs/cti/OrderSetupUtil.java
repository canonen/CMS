package com.britemoon.cps.xcs.cti;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.upd.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.jtk.*;
import com.britemoon.cps.tgt.*;
import com.britemoon.cps.imc.*;

import java.sql.*;
import java.util.*;
import java.util.zip.*;
import java.util.regex.*;
import java.io.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class OrderSetupUtil
{
	// Registry variables needed:
	//   cti_data_dir
	//   cti_url_dir
	private static Logger logger = Logger.getLogger(OrderSetupUtil.class.getName());
	public static void unzipPackage (String sOrderID) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.unzipPackage()");
			Statement stmt = null;
			
			try 
			{
				stmt = conn.createStatement();
				unzipPackage (stmt, sOrderID);
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
	}			

	private static void unzipPackage (Statement stmt, String sOrderID) throws Exception
	{
		int BUFFER = 2048;
		boolean bHasManifest = false;
		boolean bHasCampaign = false;
		boolean bHasContent = false;
		boolean bHasImport = false;

		String sZipFile = null;
		int nFileID = 1;
		String sCustOrderID = null;
            String sCustID = null;

		String sSql =
			" SELECT TOP 1 f.file_name, f.file_id, o.cust_order_id, o.cust_id " +
			" FROM cxcs_file f, cxcs_order o" +
			" WHERE o.brite_order_id = "+sOrderID +
			" AND o.brite_order_id = f.brite_order_id" +
			" AND f.type_id = " + FileType.ZIP;

		ResultSet rs = stmt.executeQuery(sSql);
		if (rs.next())
		{
			sZipFile = rs.getString(1);
			nFileID = rs.getInt(2);
			sCustOrderID = rs.getString(3);
                 sCustID = rs.getString(4);
		}
		rs.close();
		
		String sFileDir = Registry.getKey("cti_staging_dir");
		sFileDir += (sCustID + "\\");
		sFileDir += (sCustOrderID + "\\");

		String sUrlDir = Registry.getKey("cti_url_dir");
		sUrlDir += (sCustID + "/");
		sUrlDir += (sCustOrderID + "/");

		BufferedOutputStream dest = null;
		BufferedInputStream is = null;
		ZipEntry entry;
		ZipFile zf = new ZipFile(sZipFile);
		
		Enumeration e = zf.entries();
		while (e.hasMoreElements()) 
		{
			entry = (ZipEntry) e.nextElement();
			logger.info("Extracting: " +entry.getName());
			String sFileName = entry.getName();
			is = new BufferedInputStream(zf.getInputStream(entry));
			int count;
			byte data[] = new byte[BUFFER];
			FileOutputStream fos = new FileOutputStream(sFileDir + sFileName);
			dest = new BufferedOutputStream(fos, BUFFER);
			while ((count = is.read(data, 0, BUFFER)) != -1) dest.write(data, 0, count);
			dest.flush();
			dest.close();
			is.close();
			
			nFileID++;
			//Get file type
			int nTypeID = getFileType(sFileName, sCustOrderID);
			//Insert row in file table
			if ((nTypeID == FileType.IMPORT) || (nTypeID == FileType.IMAGE))
			{
				sSql = 
					" INSERT cxcs_file (brite_order_id, file_id, type_id, file_name, file_url)" +
					" VALUES ("+sOrderID+","+nFileID+","+nTypeID+",'"+sFileDir + sFileName+"','"+sUrlDir + sFileName+"')";
				stmt.executeUpdate(sSql);
			}
			else
			{
				sSql = 
					" INSERT cxcs_file (brite_order_id, file_id, type_id, file_name)" +
					" VALUES ("+sOrderID+","+nFileID+","+nTypeID+",'"+sFileDir + sFileName+"')";
				stmt.executeUpdate(sSql);
			}

			if (nTypeID == FileType.CAMPAIGN) bHasCampaign = true;
			else if (nTypeID == FileType.CONTENT) bHasContent = true;
			else if (nTypeID == FileType.IMPORT) bHasImport = true;
			else if (nTypeID == FileType.MANIFEST) bHasManifest = true;
		}
		if (!bHasManifest) throw new Exception("Package missing Manifest XML");
		if (!bHasCampaign) throw new Exception("Package missing Campaign XML");
		if (!bHasContent) throw new Exception("Package missing Content XML");
		if (!bHasImport) throw new Exception("Package missing Import File");
	}

	private static int getFileType(String sFileName, String sOrderID) throws Exception
	{
		if (Pattern.matches(".*"+sOrderID.toUpperCase()+"\\.ZIP\\Z", sFileName.toUpperCase().trim())) return FileType.ZIP; //FileType.ZIP
		else if (Pattern.matches(".*MANIFEST\\.PKM\\Z", sFileName.toUpperCase().trim())) return FileType.MANIFEST; //FileType.IMAGE
		else if (Pattern.matches(".*"+sOrderID.toUpperCase()+"_BODY_\\d+\\.XML\\Z", sFileName.toUpperCase().trim())) return FileType.CONTENT; //FileType.CONTENT
		else if (Pattern.matches(".*"+sOrderID.toUpperCase()+"_LIST_\\d+\\.TXT\\Z", sFileName.toUpperCase().trim())) return FileType.IMPORT; //FileType.RECIP_LIST
		else if (Pattern.matches(".*"+sOrderID.toUpperCase()+"_CAMPAIGN\\.XML\\Z", sFileName.toUpperCase().trim())) return FileType.CAMPAIGN; //FileType.CAMPAIGN
		else if (Pattern.matches(".*\\.JPG\\Z", sFileName.toUpperCase().trim())) return FileType.IMAGE; //FileType.IMAGE
		else if (Pattern.matches(".*\\.GIF\\Z", sFileName.toUpperCase().trim())) return FileType.IMAGE; //FileType.IMAGE
		else if (Pattern.matches(".*\\.PNG\\Z", sFileName.toUpperCase().trim())) return FileType.IMAGE; //FileType.IMAGE
		else throw new Exception("Unknown File : " + sFileName);					
	}

	private static int getFileIndex(String sFileName) throws Exception
	{
		String sIndexID = sFileName.substring(sFileName.lastIndexOf("_")+1, sFileName.lastIndexOf("."));
		return Integer.parseInt(sIndexID);
	}

	// === Import ===
	
	public static void setupImport (String sOrderID) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.setupImport()");

			Statement stmt = null;
			try 
			{
				stmt = conn.createStatement();
				setupImport (sOrderID, stmt);
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
	}

	public static void setupImport(String sOrderID, Statement stmt) throws Exception
	{
		String sCustID = null;
		String sFileName = null;
		String sFileUrl = null;
		String sCustOrderID = null;
		String sImportID = null;
		Batch bBatch = null;
		
		String sSql =
			" SELECT o.cust_id, f.file_name, f.file_url, o.cust_order_id" +
			" FROM cxcs_order o, cxcs_file f" +
			" WHERE o.brite_order_id = f.brite_order_id" +
			" AND f.type_id = " + FileType.IMPORT +
			" AND o.brite_order_id = " + sOrderID;

		ResultSet rs = stmt.executeQuery(sSql);

		while (rs.next())
		{
			sCustID = rs.getString(1);
			sFileName = rs.getString(2);
			sFileUrl = rs.getString(3);
			sCustOrderID = rs.getString(4);

			if (bBatch == null)
			{
				bBatch = new Batch();
				
				bBatch.s_batch_id = null;
				bBatch.s_batch_name = sCustOrderID; //Create new batch for each order
				bBatch.s_cust_id = sCustID;
				bBatch.s_type_id = "1";
				bBatch.s_descrip = null;
			}
		
			Import imp = createImport(bBatch, sFileName, sFileUrl, sOrderID, sCustOrderID);

			if(bBatch.s_batch_id == null) bBatch = imp.m_Batch;
			else imp.m_Batch = bBatch;
			
			ImportUtil.setupRCP(imp.s_import_id);
		}
		rs.close();
	}

	private static Import createImport
		(Batch batch, String sFileName, String sFileUrl, String sOrderID, String sCustOrderID)
			throws Exception
	{
		int nIndexID = getFileIndex(sFileName);

		// === === ===

		Import imp = new Import();

		imp.s_import_id = null;
		imp.s_import_name = sCustOrderID + "_" + nIndexID; //Name Import same as Order
		imp.s_batch_id = batch.s_batch_id;

		imp.s_status_id = String.valueOf(ImportStatus.DOWNLOADED);
		imp.s_import_date = null;
		imp.s_field_separator = "\\t";
		imp.s_first_row = "2";
		imp.s_import_file = sFileName.substring(sFileName.lastIndexOf("\\")+1);
		imp.s_upd_rule_id = "30";
		// Import uses URL directory + filname with no path
		imp.s_import_url = sFileUrl.substring(0,sFileUrl.lastIndexOf("/")+1);
		imp.s_full_name_flag = "1";
		imp.s_email_type_flag = "0";
		imp.s_type_id = null;
		imp.s_upd_hierarchy_id = null;
		imp.s_auto_commit_flag = "1";
		imp.s_multi_value_field_separator = null;

		// === === ===

		if(batch.s_batch_id == null) imp.m_Batch = batch;

		// === === ===

		String[] sHeaders = getHeadersFromFile(sFileName);
		imp.m_FieldsMappings = getFieldsMappingsFromAttrNames(batch.s_cust_id, sHeaders);

		// === === ===
		
		imp.save();
		
		// === === ===

		String sSql = 
			" INSERT cxcs_order_brite_object (brite_order_id, brite_object_id, type_id, index_id)" +
			" VALUES (" + sOrderID + "," + imp.s_import_id + "," + ObjectType.IMPORT + "," + nIndexID + ")";	
		BriteUpdate.executeUpdate(sSql);
		
		sSql = 
			" INSERT cxcs_order_brite_object (brite_order_id, brite_object_id, type_id, index_id)" +
			" VALUES (" + sOrderID + "," + imp.s_batch_id + "," + ObjectType.BATCH + "," + nIndexID + ")";
		BriteUpdate.executeUpdate(sSql);
		
		// === === ===
		
		return imp;
	}
	
	private static String[] getHeadersFromFile(String sFileName) throws IOException
	{
		// read file first row to get attr mapping
		BufferedReader inb = null;
		try
		{
			inb =
				new BufferedReader(
					new InputStreamReader(
						new FileInputStream(sFileName),"UTF-8"));

			String sOneRow = inb.readLine();
			String [] sHeaders = sOneRow.split("\t");		
			return sHeaders;
		}
		catch(IOException ex) { throw ex; }
		finally { if(inb != null) inb.close(); }
	}
	
	private static FieldsMappings getFieldsMappingsFromAttrNames(String sCustID, String[] sAttrNames)
		throws Exception
	{
		FieldsMappings fms = new FieldsMappings();
		String sSql = 
			" SELECT a.attr_id FROM ccps_attribute a, ccps_cust_attr c" +
			" WHERE a.attr_name = ? AND c.attr_id = a.attr_id AND c.cust_id = " + sCustID;
			
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.setupImport()");

			PreparedStatement pstmt = null;
			ResultSet rs = null;
			
			for (int i=0; i < sAttrNames.length; i++)
			{
				String sAttrID = null;
				try 
				{
					pstmt = conn.prepareStatement(sSql);
					pstmt.setBytes(1, sAttrNames[i].getBytes("UTF-8"));
					rs = pstmt.executeQuery();
					if (rs.next()) sAttrID = rs.getString(1);
					rs.close();
				}
				catch(Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
				
				if (sAttrID == null)
					throw new Exception("Import Attribute not found: " + sAttrNames[i]);
					
				FieldsMapping fm = new FieldsMapping();
				fm.s_attr_id = sAttrID;
				fm.s_seq = String.valueOf(i+1);
				fms.add(fm);
			}
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return fms;
	}

	// === Campaign ===

	public static void setupCampaign (String sOrderID) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.setupCampaign()");

			Statement stmt = null;
			
			try 
			{
				stmt = conn.createStatement();
				setupCampaign(stmt, sOrderID);
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
	}

/*				
<Campaign CreationDate="6/7/2004 11:00:47 AM" DeliveryDate="6/8/2004 6:00 AM" OrderID="04052406759401">
<EmailHeader Index="1">
<Subject>
<![CDATA[ This is just a test ]]> 
</Subject>
<From>
<![CDATA[ Tester ]]> 
</From>
<FromAddress>
<![CDATA[ dhooks@clicktactics.com ]]> 
</FromAddress>
<Reply>
<![CDATA[ dhooks@clicktactics.com ]]> 
</Reply>
</EmailHeader>
</Campaign>
*/

	private static void setupCampaign (Statement stmt,String sOrderID) throws Exception
	{
		// get list of campaign files for order
		String sCustID = null;
		String sFileName = null;
		String sCustOrderID = null;
		String sCampID = null;
		String sSendDate = null;
		String sSubject = null;
		String sFromName = null;
		String sFromAddr = null;
		String sReplyToAddr = null;
		String sIndexID = null;

		String sSql =
			" SELECT o.cust_id, f.file_name, o.cust_order_id" +
			" FROM cxcs_order o, cxcs_file f" +
			" WHERE o.brite_order_id = f.brite_order_id" +
			" AND f.type_id = " + FileType.CAMPAIGN +
			" AND o.brite_order_id = " + sOrderID;

		ResultSet rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			sCustID = rs.getString(1);
			sFileName = rs.getString(2);
			sCustOrderID = rs.getString(3);

			// parse XML and setup Campaign

			Element eCamp = XmlUtil.getRootElement(new FileInputStream(sFileName));
			sSendDate = eCamp.getAttribute("DeliveryDate");
			if ((sSendDate == null) || (sSendDate.length() == 0)) throw new Exception ("Missing Campaign DeliveryDate.");
			
			XmlElementList xel = XmlUtil.getChildrenByName(eCamp, "EmailHeader");
			
			if (xel.getLength() == 0) throw new Exception ("Missing Campaign EmailHeader XML.");
			
			for (int i=0; i < xel.getLength(); i++)
			{
				Element eHeader = (Element)xel.item(i);
				sIndexID = eHeader.getAttribute("Index");
				
				sSubject = XmlUtil.getChildCDataValue(eHeader, "Subject");
				if (sSubject == null) throw new Exception ("Missing Campaign EmailHeader "+sIndexID+" Subject.");
				sFromName = XmlUtil.getChildCDataValue(eHeader, "From");
				if (sFromName == null) throw new Exception ("Missing Campaign EmailHeader "+sIndexID+" From.");
				sFromAddr = XmlUtil.getChildCDataValue(eHeader, "FromAddress");
				if (sFromAddr == null) throw new Exception ("Missing Campaign EmailHeader "+sIndexID+" FromAddress.");
				sReplyToAddr = XmlUtil.getChildCDataValue(eHeader, "Reply");
				if (sReplyToAddr == null) throw new Exception ("Missing Campaign EmailHeader "+sIndexID+" Reply.");

				Campaign camp = new Campaign();

				camp.s_type_id = String.valueOf(CampaignType.STANDARD);
				camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);
				camp.s_camp_name = sCustOrderID + "_" + sIndexID;
				camp.s_cust_id = sCustID;

				CampSendParam csp = new CampSendParam();
				csp.s_response_frwd_addr = sFromAddr;

				MsgHeader mh = new MsgHeader();
				mh.s_from_name = sFromName;
				mh.s_from_address = sFromAddr;
				mh.s_subject_html = sSubject;
				mh.s_subject_text = sSubject;
				mh.s_reply_to = sReplyToAddr;

				Schedule sch = new Schedule();
				sch.s_start_date = sSendDate;

				CampEditInfo cei = new CampEditInfo();
				CampList cl = new CampList();
				LinkedCamp lc = new LinkedCamp();

				camp.m_CampSendParam = csp;
				camp.m_MsgHeader = mh;
				camp.m_Schedule = sch;
				camp.m_CampEditInfo = cei;
				camp.m_CampList = cl;
				camp.m_LinkedCamp = lc;

				camp.save();
				
				String sSql2 =
					" INSERT cxcs_order_brite_object (brite_order_id, brite_object_id, type_id, index_id)" +
					" VALUES ("+sOrderID+","+camp.s_camp_id+","+ObjectType.CAMPAIGN+","+sIndexID+")";				
				BriteUpdate.executeUpdate(sSql2);
			}
		}
		rs.close();
	}

	// === Content ===

	public static void setupContent (String sOrderID) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.setupContent()");

			Statement stmt = null;
			try 
			{
				stmt = conn.createStatement();
				setupContent (stmt, sOrderID);
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
	}

/*
<ContentDef>
	<ContentName>
		<![CDATA[ blah ]]> 
	</ContentName>
	<ContentSendTypeID>1</ContentSendTypeID> 
	<ContentText>
		<![CDATA[ blah ]]> 
	</ContentText>
	<ContentHTML>
		<![CDATA[ blah ]]> 
	</ContentHTML>
	<Link>
		<LinkURL>
			<![CDATA[ http://www.somewhere.com ]]> 
		</LinkURL>
		<LinkName>
			<![CDATA[ somewhere ]]> 
		</LinkName>
	</Link>
</ContentDef>
*/

	public static void setupContent (Statement stmt, String sOrderID) throws Exception
	{
		// get list of content files for order
		String sCustID = null;
		String sFileName = null;
		String sIndexID = null;
		String sContName = null;
		String sContSendTypeID = null;
		String sContText = null;
		String sContHTML = null;

		String sLinkURL = null;
		String sLinkName = null;

		String sSql =
			" SELECT o.cust_id, f.file_name" +
			" FROM cxcs_order o, cxcs_file f" +
			" WHERE o.brite_order_id = f.brite_order_id" +
			" AND f.type_id = " + FileType.CONTENT +
			" AND o.brite_order_id = " + sOrderID;
			
		ResultSet  rs = stmt.executeQuery(sSql);

		while (rs.next())
		{
			sCustID = rs.getString(1);
			sFileName = rs.getString(2);

			int nIndexID = getFileIndex(sFileName);

			// parse XML and setup Content

			Element eCont = XmlUtil.getRootElement(new FileInputStream(sFileName));
			if (eCont == null) throw new Exception ("Missing Content "+nIndexID+" ContentDef.");
			sContName = XmlUtil.getChildCDataValue(eCont, "ContentName");
			if (sContName == null) throw new Exception ("Missing Content "+nIndexID+" ContentName.");
			sContSendTypeID = XmlUtil.getChildTextValue(eCont, "ContentSendTypeID");
			if (sContSendTypeID == null) throw new Exception ("Missing Content "+nIndexID+" ContentSendTypeID.");
			sContText = XmlUtil.getChildCDataValue(eCont, "ContentText");
			if (sContText == null) throw new Exception ("Missing Content "+nIndexID+" ContentText.");
			sContHTML = XmlUtil.getChildCDataValue(eCont, "ContentHTML");
			if (sContHTML == null) throw new Exception ("Missing Content "+nIndexID+" ContentHTML.");

			com.britemoon.cps.cnt.Content cont = new com.britemoon.cps.cnt.Content();

			cont.s_cont_name = sContName;
			cont.s_status_id = String.valueOf(ContStatus.READY);
			cont.s_cust_id = sCustID;
			cont.s_charset_id = sContSendTypeID;
			cont.s_type_id = String.valueOf(ContType.CONTENT);
		
			ContBody cb = new ContBody();
			cb.s_html_part = replaceImages(sOrderID, sContHTML);
			cb.s_text_part = replaceImages(sOrderID, sContText);

			ContSendParam csp = new ContSendParam();
			csp.s_send_html_flag = "1";
			csp.s_send_text_flag = "1";

			ContEditInfo cei = new ContEditInfo();	

			Links links = new Links();

			XmlElementList xel = XmlUtil.getChildrenByName(eCont, "Link");
			
			for (int i=0; i < xel.getLength(); i++)
			{
				Element eLink = (Element)xel.item(i);

				sLinkURL = XmlUtil.getChildCDataValue(eLink, "LinkURL");
				if (sLinkURL == null) throw new Exception ("Missing Content "+nIndexID+" LinkURL.");
				sLinkName = XmlUtil.getChildCDataValue(eLink, "LinkName");
				if (sLinkName == null) throw new Exception ("Missing Content "+nIndexID+" LinkName.");

				Link link = new Link();
				link.s_cust_id = sCustID;
				link.s_link_name = sLinkName;
				link.s_href = sLinkURL;
				
				links.add(link);
			}

			cont.m_ContBody = cb;
			cont.m_ContSendParam = csp;
			cont.m_ContEditInfo = cei;
			cont.m_Links = links;

			cont.save();

			String sSql2 =
				" INSERT cxcs_order_brite_object (brite_order_id, brite_object_id, type_id, index_id)" +
				" VALUES ("+sOrderID+","+cont.s_cont_id+","+ObjectType.CONTENT+","+nIndexID+")";
			BriteUpdate.executeUpdate(sSql2);
		}
		rs.close();
	}

	private static String replaceImages (String sOrderID, String sContent) throws Exception
	{
		// Put in full path for image URLs from ZIP file images
		ConnectionPool cp = null;
		Connection conn = null;

		String sResult = sContent;
		StringBuffer sbResult = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.replaceImages()");

			Statement stmt = null;
			
			try 
			{
				stmt = conn.createStatement();
				ResultSet rs = null;

				String sImageURL = null;
				String sImageName = null;

				String sSql = "SELECT DISTINCT f.file_url"
					+ " FROM cxcs_file f"
					+ " WHERE f.type_id = " + FileType.IMAGE
					+ " AND f.brite_order_id = "+sOrderID;

				rs = stmt.executeQuery(sSql);

				while (rs.next())
				{
					sImageURL = rs.getString(1);
					sImageName = sImageURL.substring(sImageURL.lastIndexOf("/")+1);

					for (int i = sResult.indexOf(sImageName); i >= 0; i = sResult.indexOf(sImageName, i+sImageURL.length()))
					{
						sbResult = new StringBuffer(sResult);
						sResult = sbResult.replace(i, i + sImageName.length(), sImageURL).toString();
					}
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex)  { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
		
		return sResult;
	}

	public static void setupFilter (String sOrderID) throws Exception
	{
		// Create Filters from Imports for Order 
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.setupFilter()");

			Statement stmt = null;
			
			try 
			{
				stmt = conn.createStatement();
				ResultSet rs = null;

				String sCustID = null;
				String sImportID = null;
				String sIndexID = null;
				String sCustOrderID = null;

				String sSql = "SELECT o.cust_id, bo.brite_object_id, bo.index_id, o.cust_order_id"
					+ " FROM cxcs_order_brite_object bo, cxcs_order o"
					+ " WHERE bo.brite_order_id = o.brite_order_id"
					+ " AND bo.type_id = " + ObjectType.IMPORT
					+ " AND o.brite_order_id = " + sOrderID;

				rs = stmt.executeQuery(sSql);
				while (rs.next())
				{
					sCustID = rs.getString(1);
					sImportID = rs.getString(2);
					sIndexID = rs.getString(3);
					sCustOrderID = rs.getString(4);

					String sImportName = sCustOrderID + "_" + sIndexID;
					Filter parentFilter = FilterUtil.createIpmortFilter (sCustID, sImportID, sImportName);

//	System.out.println("parentFilter saved : "+parentFilter.s_filter_id);

					sSql = "INSERT ctgt_preview_attr (filter_id, attr_id, display_seq)"
						+ " SELECT "+parentFilter.s_filter_id+", attr_id, max(seq)"
						+ " FROM cupd_fields_mapping WHERE import_id = "+sImportID
						+ " AND attr_id > 0"
						+ " GROUP BY attr_id";
					BriteUpdate.executeUpdate(sSql);
//	System.out.println("attributes saved");

					sSql =
						" INSERT cxcs_order_brite_object (brite_order_id, brite_object_id, type_id, index_id)" +
						" VALUES ("+sOrderID+","+parentFilter.s_filter_id+","+ObjectType.FILTER+","+sIndexID+")";
					BriteUpdate.executeUpdate(sSql);
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
	}
	
	public static void startCampaign (String sOrderID) throws Exception
	{
		// Associate Filter and Content with Campaign for this Order, then start campaign
		
		ConnectionPool cp = null;
		Connection conn = null;
		Connection conn2 = null;
		boolean bAutoCommit = true;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.startCampaign()");
			conn2 = cp.getConnection("OrderSetupUtil.startCampaign() 2");

			Statement stmt = null;
			Statement stmt2 = null;

			String sCampID = null;
			String sIndexID = null;
			String sContID = null;
			String sFilterID = null;

			String sNewCampID = null;

			try 
			{
				stmt = conn.createStatement();
				stmt2 = conn2.createStatement();
				ResultSet rs = null;
				ResultSet rs2 = null;
				
				String sSql = null;

// Query campaigns for order
				sSql = "SELECT bo.brite_object_id, bo.index_id"
					+ " FROM cxcs_order_brite_object bo WITH(NOLOCK)"
					+ " WHERE bo.type_id = " + ObjectType.CAMPAIGN
					+ " AND bo.brite_order_id = " + sOrderID;

				rs = stmt.executeQuery(sSql);
				while (rs.next())
				{
					sCampID = rs.getString(1);
					sIndexID = rs.getString(2);
					
// Query content for order + index
					sSql = "SELECT bo.brite_object_id"
						+ " FROM cxcs_order_brite_object bo"
						+ " WHERE bo.type_id = " + ObjectType.CONTENT
						+ " AND bo.brite_order_id = " + sOrderID
						+ " AND bo.index_id = " + sIndexID;

					rs2 = stmt2.executeQuery(sSql);
					if (rs2.next()) sContID = rs2.getString(1);
					else throw new Exception ("No Content for this Campaign, camp_id="+sCampID+", order_id="+sOrderID+", index_id="+sIndexID);
					rs2.close();

// Query filter for order + index
					sSql = "SELECT bo.brite_object_id"
						+ " FROM cxcs_order_brite_object bo"
						+ " WHERE bo.type_id = " + ObjectType.FILTER
						+ " AND bo.brite_order_id = " + sOrderID
						+ " AND bo.index_id = " + sIndexID;

					rs2 = stmt2.executeQuery(sSql);
					if (rs2.next()) sFilterID = rs2.getString(1);
					else throw new Exception ("No Filter for this Campaign, camp_id="+sCampID+", order_id="+sOrderID+", index_id="+sIndexID);
					rs2.close();

					Campaign camp = new Campaign(sCampID);
					
					camp.s_filter_id = sFilterID;
					camp.s_cont_id = sContID;
					
					camp.save();

					boolean bUseReservedCampId = true;

					sNewCampID = CampSetupUtil.prepareCamp4Setup(camp.s_camp_id, 0, bUseReservedCampId);
					
					sSql = "UPDATE cxcs_order_brite_object "
						+ " SET brite_object_id = " + sNewCampID
						+ " WHERE type_id = " + ObjectType.CAMPAIGN
						+ " AND brite_order_id = " + sOrderID
						+ " AND index_id = " + sIndexID;
					BriteUpdate.executeUpdate(sSql);

					String sApprovalFlag = "1";

					sSql =
						" UPDATE cque_schedule SET start_date=ISNULL(start_date, getdate())" +
						" WHERE camp_id = " + sNewCampID;
					BriteUpdate.executeUpdate(sSql);

					sSql =
						" UPDATE cque_camp_send_param SET" +
						" queue_date=ISNULL(queue_date, getdate()), delay=ISNULL(delay,0)" +
						" WHERE camp_id = " + sNewCampID;
					BriteUpdate.executeUpdate(sSql);

					createReadLink(sNewCampID);

					sSql =
						" UPDATE cque_campaign SET" +
						" status_id = " + CampaignStatus.SENT_TO_RCP +
						", approval_flag = " + sApprovalFlag +
						" WHERE camp_id = " + sNewCampID;
					BriteUpdate.executeUpdate(sSql);

					CampSetupUtil.doRcpSetup(sNewCampID);
				}
			}
			catch (Exception ex) 
			{
				throw ex;
			}
			finally
			{
				if (stmt2!=null) stmt2.close();
				if (stmt!=null) stmt.close();
			}
		}
		catch (Exception ex) 
		{
			throw ex;
		}
		finally
		{
			if ( conn2 != null ) cp.free(conn2);
			if ( conn != null ) cp.free(conn);
		}
	}


	private static void createReadLink(String sCampId) throws Exception
	{
		Campaign camp = new Campaign(sCampId);

		Link link = new Link();
		link.s_link_name = "read_link";
		link.s_cont_id = camp.s_cont_id;
		link.s_camp_id = camp.s_camp_id;
		link.s_cust_id = camp.s_cust_id;
		link.s_href = null;
		link.s_origin_link_id = null;
		link.save();
	}


	public static void setOrderStatus (String sOrderID) throws Exception
	{
		// Create Filters from Imports for Order 
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("OrderSetupUtil.setOrderStatus()");

			Statement stmt = null;
			
			try 
			{
				stmt = conn.createStatement();
				setOrderStatus (sOrderID, stmt);
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
	}
	
	private static void setOrderStatus (String sOrderID, Statement stmt) throws Exception
	{
		ResultSet rs = null;

		int nImports = 0;
		int nFilters = 0;
		int nCamps = 0;
		boolean bAllComplete = true;
		boolean bAnyError = false;
		int nOrderStatus = 0;
		String sMsg = "";

		// get order status
		String sSql = "SELECT o.status_id"
			+ " FROM cxcs_order o"
			+ " WHERE o.brite_order_id = " + sOrderID;
		rs = stmt.executeQuery(sSql);

		if (rs.next()) nOrderStatus = rs.getInt(1);
		
		// check if order has import(s) (if not, still processing don't do anything)
		// and that import status is not error
		
		sSql = "SELECT i.status_id"
			+ " FROM cxcs_order o, cxcs_order_brite_object bo, cupd_import i"
			+ " WHERE o.brite_order_id = bo.brite_order_id"
			+ " AND bo.type_id = " + ObjectType.IMPORT
			+ " AND bo.brite_object_id = i.import_id"
			+ " AND o.brite_order_id = " + sOrderID;
		rs = stmt.executeQuery(sSql);

		while (rs.next())
		{
			int nStatusID = rs.getInt(1);
			nImports++;

			if (nStatusID < ImportStatus.COMMIT_COMPLETE)
			{
				// Not DONE
				bAllComplete = false;
				rs.close();
				return; // still processing, no need to update Status
			}
			
			if ((nStatusID > ImportStatus.COMMIT_COMPLETE) && (nStatusID < ImportStatus.DELETED)){
				// ERROR
				bAnyError = true;
				sMsg += "Import Error";
				break;
			}
		}
		rs.close();

		if (nImports == 0) return; // setup still processing

		//Status >= IMPORT_COMPLETE
		// check if order has filter(s) (if not, still processing don't do anything)
		// and that filter status good

		if ((nOrderStatus >= OrderStatus.IMPORT_COMPLETE) && !bAnyError && bAllComplete)
		{
			sSql = "SELECT f.status_id"
				+ " FROM cxcs_order o, cxcs_order_brite_object bo, ctgt_filter f"
				+ " WHERE o.brite_order_id = bo.brite_order_id"
				+ " AND bo.type_id = " + ObjectType.FILTER
				+ " AND bo.brite_object_id = f.filter_id"
				+ " AND o.brite_order_id = " + sOrderID;
			rs = stmt.executeQuery(sSql);

			while (rs.next()) {
				int nStatusID = rs.getInt(1);
				nFilters++;

				if ((nStatusID > FilterStatus.READY) && (nStatusID < FilterStatus.DELETED)){
					// ERROR
					bAnyError = true;
					sMsg += "Filter Error";
					break;
				}
			}
			rs.close();

			if (!bAnyError)
			{
				if (nImports > nFilters) return; // not all Filters setup, still processing	

				// loop through campaigns for order, make sure all are DONE
				// if any not DONE, leave status
				// if any ERROR, set Order status ERROR_EXECUTING
				// if all DONE , set Order status COMPLETE

				sSql = "SELECT c.status_id"
					+ " FROM cxcs_order o, cxcs_order_brite_object bo, cque_campaign c"
					+ " WHERE o.brite_order_id = bo.brite_order_id"
					+ " AND bo.type_id = " + ObjectType.CAMPAIGN
					+ " AND bo.brite_object_id = c.camp_id"
					+ " AND o.brite_order_id = " + sOrderID;
				rs = stmt.executeQuery(sSql);
				
				while (rs.next())
				{
					int nStatusID = rs.getInt(1);
					nCamps++;

					if (nStatusID < CampaignStatus.DONE)
					{
						// Not DONE
						bAllComplete = false;
						rs.close();
						return; // still processing, no need to update Status
					}
					if ((nStatusID > CampaignStatus.DONE) && (nStatusID < CampaignStatus.CANCELLED))
					{
						// ERROR
						bAnyError = true;
						sMsg += "Campaign Error";
						break;
					}
				}
				rs.close();
			}
		}

		if (bAnyError)
		{
			int nOrderErrorStatus = OrderStatus.ERROR_EXECUTING;
			if (nOrderStatus < OrderStatus.EXECUTING) nOrderErrorStatus = OrderStatus.ERROR_PROCESSING;
			sSql = "UPDATE cxcs_order"
				+ " SET status_id = " + nOrderErrorStatus + ", status_date = getdate(),"
				+ " status_desc = '" + sMsg + "'" 
				+ " WHERE brite_order_id = "+sOrderID;
			BriteUpdate.executeUpdate(sSql);

			OrderStatusClient osc = new OrderStatusClient();		
			osc.sendBriteStatus(sOrderID, nOrderErrorStatus);
		}
		else if ((bAllComplete) && (nCamps == nImports) && (nCamps == nFilters))
		{
			sSql = "UPDATE cxcs_order"
				+ " SET status_id = " + OrderStatus.COMPLETE + ", status_date = getdate(),"
				+ " status_desc = 'Complete'" 
				+ " WHERE brite_order_id = "+sOrderID;
			BriteUpdate.executeUpdate(sSql);

			OrderStatusClient osc = new OrderStatusClient();		
			osc.sendBriteStatus(sOrderID, OrderStatus.COMPLETE);
		}	
	}
}






