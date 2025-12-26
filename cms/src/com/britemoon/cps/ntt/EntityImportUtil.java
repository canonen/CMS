package com.britemoon.cps.ntt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;
import com.britemoon.cps.ftp.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.*;
import org.apache.log4j.*;

public class EntityImportUtil
{
	private static Logger logger = Logger.getLogger(EntityImportUtil.class.getName());
	public static EntityImport setupFtpImport
		(String sTemplateId, FtpFile ff, java.util.Date dDate4ImportName) throws Exception
	{
		EntityImport ei = createImport(sTemplateId, ff.s_file_name_local, dDate4ImportName);

		// === === ===
						
		FtpFileAssignments ffa = new FtpFileAssignments(ff.s_file_id);
		ffa.s_entity_import_id = ei.s_import_id;
		ffa.save();
		
		// === === ===			
			
		setupRCP(ei.s_import_id, ffa.s_recip_import_id);
		
		return ei;
	}
	
	private static EntityImport createImport
		(String sTemplateId, String sFileName, java.util.Date dDate4ImportName) throws Exception
	{
		EntityImportTemplate eit = new EntityImportTemplate(sTemplateId);
		
		// === === ===
				
		if( dDate4ImportName == null ) dDate4ImportName = new java.util.Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		
		// === === ===
		
		EntityImport imp = new EntityImport();

		imp.s_import_name = eit.s_template_name + " " + sdf.format(dDate4ImportName);
		imp.s_template_id = sTemplateId;
		imp.s_cust_id = eit.s_cust_id;
		imp.s_status_id = String.valueOf(ImportStatus.DOWNLOADED);
		imp.s_file_url = Registry.getKey("import_url_dir");
		imp.s_file_name = sFileName;
		
		imp.save();

		// === === ===

		return imp;
	}

	public static EntityImport setupRCP
		(String sEntityImportId, String sRecipImportId) throws Exception
	{
		EntityImport imp = null;
		String sSql = null;
		try
		{
			imp = retrieve4RCP(sEntityImportId, sRecipImportId);
			send2RCP(imp);

			sSql = 
				" UPDATE cntt_entity_import SET status_id = 10" +
				" WHERE import_id = " + imp.s_import_id;
			BriteUpdate.executeUpdate(sSql); 
		}
		catch (Exception ex)
		{
			sSql =
				" UPDATE cntt_entity_import SET status_id = 70" +
				" WHERE import_id = " + imp.s_import_id;

			try { BriteUpdate.executeUpdate(sSql); }
			catch (Exception exx) { logger.error("Exception: ", exx); }
			
			sSql =
				" INSERT cntt_entity_import_statistics (import_id, error_msg)" +
				" VALUES (" + imp.s_import_id + ",'" + ex.getMessage().replaceAll("'","''") + "')";

			try { BriteUpdate.executeUpdate(sSql); }
			catch (Exception exx) { logger.error("Exception: ", exx); }
			
			throw ex;			
		}
		return imp;
	}

	private static EntityImport retrieve4RCP
		(String sEntityImportId, String sRecipImportId) throws Exception
	{

		EntityImport imp = new EntityImport(sEntityImportId);
		
		EntityImportTemplate eit = new EntityImportTemplate(imp.s_template_id);

		// === === ===
		
		EntityImportTemplateAttrs eitas = new EntityImportTemplateAttrs();
		eitas.s_template_id = eit.s_template_id;
		eitas.retrieve();
				
		eit.m_EntityImportTemplateAttrs = eitas;
			
		// === === ===

		EntityImportSyncInfo eisi = new EntityImportSyncInfo();
		eisi.s_entity_import_id = sEntityImportId;
		eisi.s_recip_import_id = sRecipImportId;
		
		imp.m_EntityImportSyncInfo = eisi;		
			
		// === === ===

		imp.m_EntityImportTemplate = eit;
		
		return imp;
	}
	
	private static void send2RCP(EntityImport imp) throws Exception
	{
		String sRequest = imp.toXml();

		String sResponse =
			Service.communicate(ServiceType.RUPD_IMPORT_SETUP, imp.s_cust_id, sRequest);

		// === === ===
		
		try { XmlUtil.getRootElement(sResponse); }
		catch(Exception ex)
		{
			String sErrMsg =
				"\r\nEntityImportUtil.send2RCP() ERROR:" + 
				"\r\nsRequest = \r\n" + sRequest +
				"\r\nsResponse = \r\n" + sResponse;				
			
			logger.error("Exception: " + sErrMsg, ex);
			throw ex;
		}
	}
}
