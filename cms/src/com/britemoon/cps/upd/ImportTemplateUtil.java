package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.upd.*;
import com.britemoon.cps.tgt.*;
import com.britemoon.cps.ftp.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.*;
import org.apache.log4j.*;

public class ImportTemplateUtil
{
	private static Logger logger = Logger.getLogger(ImportTemplateUtil.class.getName());
	public static Import setupImport
		(String sTemplateId, FtpFile ff, java.util.Date dDate4ImportName)
			throws Exception
	{
		ImportTemplate it = new ImportTemplate(sTemplateId);
		it.m_Batch = new Batch(it.s_batch_id);
		return setupImport (it, ff, dDate4ImportName);
	}
	
	private static Import setupImport
		(ImportTemplate it, FtpFile ff, java.util.Date dDate4ImportName)
			throws Exception
	{
		Import imp = createImport(it, ff, dDate4ImportName);
		imp.save();
		
		FtpFileAssignments ffa = new FtpFileAssignments(ff.s_file_id);
		ffa.s_recip_import_id = imp.s_import_id;
		ffa.save();

		ImportUtil.setupRCP(imp.s_import_id);

		// === === ===

		if ("1".equals(it.s_filter_per_import_flag))
		{
			try
			{
				FilterUtil.createIpmortFilter(it.m_Batch.s_cust_id, imp.s_import_id, imp.s_import_name);
			}
			catch(Exception ex) 
			{ 
				logger.error("Exception: ", ex);
			}
		}
		
		// === === ===
				
		return imp;
	}

	public static Import createImport
		(ImportTemplate it, FtpFile ff, java.util.Date dDate4ImportName)
			throws Exception
	{
		String sImportName = null;
		if ("1".equals(it.s_name_import_as_file_flag))
		{
			sImportName = ff.s_file_name_remote;
		}
		else
		{
			sImportName = getStandardImportName(ff, dDate4ImportName);
		}
		
		String sLocalFileName = ff.s_file_name_local;
		return createImport(it, sImportName, sLocalFileName);
	}

	public static String getStandardImportName
		(FtpFile ff, java.util.Date dDate4ImportName)
			throws Exception
	{
		FtpTask ft = new FtpTask(ff.s_task_id);
		if(ft.s_date_format == null) ft.s_date_format = "MMddyyyy";
		if(dDate4ImportName == null) dDate4ImportName = new java.util.Date();
		SimpleDateFormat sdf = new SimpleDateFormat(ft.s_date_format);	
		String sImportName = "FTP_" + ff.s_task_id + "_" + sdf.format(dDate4ImportName);
		return sImportName;
	}

	private static Import createImport(ImportTemplate it, String sImportName, String sLocalFileName) throws Exception
	{
		Import imp = createImportPrototype(it);
		
		imp.s_import_name = sImportName;
		imp.s_import_file = sLocalFileName;
	
		return imp;
	}
	
	public static Import createImportPrototype(ImportTemplate it) throws Exception
	{
		Import imp = new Import();
		
		imp.s_import_id = null;
		imp.s_batch_id = it.s_batch_id;
		imp.s_import_name = null;
		imp.s_status_id = String.valueOf(ImportStatus.DOWNLOADED);
		imp.s_import_date = null;
		imp.s_field_separator = it.s_field_separator;
		imp.s_first_row = it.s_first_row;
		imp.s_import_file = null;
		imp.s_upd_rule_id = it.s_upd_rule_id;
		imp.s_import_url = Registry.getKey("import_url_dir");
		imp.s_full_name_flag = it.s_full_name_flag;
		imp.s_email_type_flag = it.s_email_type_flag;
		imp.s_type_id = it.s_type_id;
		imp.s_upd_hierarchy_id = it.s_upd_hierarchy_id;
		imp.s_auto_commit_flag = it.s_auto_commit_flag;
		imp.s_multi_value_field_separator = it.s_multi_value_field_separator;

		// === === ===		
		
		imp.m_FieldsMappings = getFieldsMappings(it.s_template_id);
		
		return imp;		
	}
	
	public static FieldsMappings getFieldsMappings(String sTemplateId) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("FtpImportUtil.getFieldsMappings()");
			stmt = conn.createStatement();			
			return getFieldsMappings(sTemplateId, stmt);
		}
		catch(Exception ex) { throw ex; }
		finally
		{
			if (stmt != null) 
			{ 
				try 
				{ 
					stmt.close(); 
				} catch(Exception ex) 
				{ 
					logger.error("Exception: ", ex);
				}  
			}
			if (conn != null) 
			{ 
				try 
				{ 
					cp.free(conn); 
				} catch(Exception ex) 
				{ 
					logger.error("Exception: ",ex);
				} 
			}
		}
	}

	public static FieldsMappings getFieldsMappings(String sTemplateId, Statement stmt) throws SQLException
	{
		FieldsMappings fms = new FieldsMappings();

		String sSql = 
			" SELECT attr_id FROM cupd_import_template_attr" +
			" WHERE template_id = " + sTemplateId +
			" ORDER BY seq";

		ResultSet rs = stmt.executeQuery(sSql);
		for(int i=0; rs.next(); i++)
		{
			FieldsMapping fm = new FieldsMapping();
			fm.s_attr_id = rs.getString(1);
			fm.s_seq = String.valueOf(i);
			fms.add(fm);					
		}
		rs.close();
		
		return fms;
	}
}

/*
	private static void setImportIdLabel(FtpFile ff, String sImportId) throws SQLException
	{
		String sSql = 
			" UPDATE cftp_ftp_file" +
			" SET import_id=" + sImportId + 
			" WHERE file_id=" + ff.s_file_id;
			
		BriteUpdate.executeUpdate(sSql);

		ff.s_import_id = sImportId;
	}	

	public static String generateFileNameRoot(FtpTask ft, java.util.Date dDate)
	{
		if(ft.s_date_format == null) ft.s_date_format = "MMddyyyy";
		SimpleDateFormat sdf = new SimpleDateFormat(ft.s_date_format);	
		return sdf.format(dDate);
	}
*/

