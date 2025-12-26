package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.ftp.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.*;
import org.apache.log4j.*;
//import com.jscape.inet.ftp.*;

public class ImportTemplateUtilHyatt
{
	private static Logger logger = Logger.getLogger(ImportTemplateUtilHyatt.class.getName());
        
	public static boolean isItHyattTemplate(String sTemplateId)
	{
		boolean bIsItHyattTemplate = false;
		
		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImportTemplateUtilHyatt.isItHyattTemplate()");

			Statement stmt  = null;
			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT TOP 1 template_id" +
					" FROM cupd_import_template_hyatt" +
					" WHERE template_id = " + sTemplateId;

				ResultSet rs = stmt.executeQuery(sSql);
				bIsItHyattTemplate = rs.next();
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ", ex);
		}
		finally { if (conn!=null) cp.free(conn); }
	
		return bIsItHyattTemplate;
	}

	public static void setupImports
		(String sTemplateId, FtpFile ff, java.util.Date dDate4ImportName)
			throws Exception
	{
		ImportTemplate it = new ImportTemplate(sTemplateId);
		it.m_Batch = new Batch(it.s_batch_id);
		setupImports(it, ff, dDate4ImportName);
	}

	private static void setupImports
		(ImportTemplate it, FtpFile ff, java.util.Date dDate4ImportName)
			throws Exception
	{
		Hashtable htFiles = parseHotelFile(ff.s_file_name_local, it.s_field_separator);
		Vector vImportIds = createImports(it, ff, htFiles, dDate4ImportName);
		
		String sImportId = null;
		for (Enumeration e = vImportIds.elements(); e.hasMoreElements() ;)
		{
			sImportId = (String) e.nextElement();
			ImportUtil.setupRCP(sImportId);
		}		
	}

	private static Vector createImports
		(ImportTemplate it, FtpFile ff, Hashtable htFiles, java.util.Date dDate4ImportName)
			throws Exception
	{
		Vector vImportIds = new Vector();

		String sImportName = ImportTemplateUtil.getStandardImportName(ff, dDate4ImportName);
		Import impPrototype = createImportPrototype(it);
		
		// === === ===
	
		String sTemplateId = it.s_template_id;	
		String sHotelId = null;
		String sBatchId = null;		
		String sFile = null;
		File  fFile = null;		
		
		for (Enumeration e = htFiles.keys(); e.hasMoreElements() ;)
		{
			sHotelId = (String) e.nextElement();
           
			fFile = (File) htFiles.get(sHotelId);
			sFile = fFile.getName();
			
			impPrototype.s_import_id = null;
			impPrototype.s_import_name = sImportName + "_" + sHotelId;
			
			sBatchId = getBatchId(sTemplateId, sHotelId);
			
			if (sBatchId == null)
			{
				String sErrMsg = 
					"ImportTemplateUtilHyatt.createImports() WARNING: " +
					"\r\nbatch is not specified for template_id=" + sTemplateId + " hotel_id=" + sHotelId +
					"\r\nWarning ignored. Processing will continue to make Scott happy.";

				// throw new Exception(sErrMsg);
				logger.info(sErrMsg);
				continue;
			}

			impPrototype.s_batch_id = sBatchId;
			impPrototype.s_import_file = sFile;

			// === === ===
			
			impPrototype.m_FieldsMappings = getFieldsMappings(sTemplateId, sHotelId);
			
			// === === ===
						
			impPrototype.save();
			setImportIdLabel(ff, sHotelId, impPrototype.s_import_id);
			
			// === === ===
			
			vImportIds.add(impPrototype.s_import_id);
		}

		// === === ===

		return vImportIds;
	}

	private static Import createImportPrototype(ImportTemplate it) throws Exception
	{
		Import imp = new Import();
		
		imp.s_import_id = null;
		imp.s_batch_id = null;
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

		return imp;		
	}
	
	private static Hashtable parseHotelFile(String sFile, String sDelimiter) throws Exception
	{
		String sDir = Registry.getKey("import_data_dir");
		File fFile = new File(sDir, sFile);
		if (!fFile.exists())
		{
			String sErrMsg = 
				"ImportTemplateUtilHyatt.parseHotelFile(): "+
				"hotel file not found: " + fFile;
			throw new Exception(sErrMsg);
		}
		
		return parseHotelFile(fFile, sDelimiter);
	}
	
	private static Hashtable parseHotelFile(File fFile, String sDelimiter) throws Exception
	{
		Hashtable htFiles = new Hashtable();
		Hashtable htWriters = new Hashtable();		

		BufferedReader in = null;
		BufferedWriter err = null;
		try
		{
			in = new BufferedReader(new InputStreamReader(new FileInputStream(fFile),"UTF-8"));

			if(sDelimiter.equals("|")) sDelimiter = "\\|";
            // LW 1/2007: Hyatt PEP Phase 2 specifies a delimiter = ~;~  so the default delimiter will be set to ~;~
            if (sDelimiter == null) sDelimiter = "~;~";
			String[] sSplittedLine = null;
			String sHotelId = null;

			BufferedWriter writer = null;
			String sHeader = in.readLine();
						
			for(String sLine = in.readLine(); sLine != null; sLine = in.readLine())
			{
				try
				{
					sSplittedLine = sLine.split(sDelimiter);
					sHotelId = sSplittedLine[4];
					writer = (BufferedWriter) htWriters.get(sHotelId);
					if (writer == null)
					{
						String sHotelOutputFile = fFile + "_" + sHotelId + ".txt";
						File fHotelOutputFile = new File(sHotelOutputFile);
						
						writer = createWriter(sHotelOutputFile);
						writer.write(sHeader);
						
						htWriters.put(sHotelId, writer);
						htFiles.put(sHotelId, fHotelOutputFile);
					}
					writer.newLine();					
					writer.write(sLine);
				}
				catch(Exception ex)
				{
					if (err == null)
					{
						String sErrFile = fFile + "_errors.txt";
						err = createWriter(sErrFile);
					}
					err.write(sLine);
					err.newLine();
				}
			}
		}
		catch(Exception e) { throw e; }
		finally
		{
			if (in != null) 
			{	
				try 
				{ 
					in.close(); 
				} catch(Exception ex) 
				{ 
					logger.error("Exception: ",ex);
				}
			}
			if (err != null) 
			{
				try 
				{ 
					err.close(); 
				} catch(Exception ex) 
				{ 
					logger.error("Exception: ", ex);
				}
			}
			
			BufferedWriter writer = null;
			for (Enumeration e = htWriters.elements() ; e.hasMoreElements() ;)
			{
				try
				{
					writer = (BufferedWriter)e.nextElement();
					writer.close();
				}
				catch(Exception ex) 
				{ 
					logger.error("Exception: ",ex);
				}
			}
		}
		
		return htFiles;
	}

	private static BufferedWriter createWriter(String sFile)
		throws FileNotFoundException, UnsupportedEncodingException
	{
		return
				new	BufferedWriter(
					new OutputStreamWriter(
						new FileOutputStream(sFile),"UTF-8"));
	}
	
	private static String getBatchId(String sTemplateId, String sHotelId) throws Exception
	{
		String sBatchId = null;
		
		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImportTemplateUtilHyatt.getBatchId()");

			Statement stmt  = null;
			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT batch_id" +
					" FROM cupd_import_template_hyatt" +
					" WHERE template_id = " + sTemplateId +
					" AND hotel_id = '" + sHotelId + "'";

				ResultSet rs = stmt.executeQuery(sSql);
				if (rs.next()) sBatchId = rs.getString(1);
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ", ex);
		}
		finally { if (conn!=null) cp.free(conn); }
	
		return sBatchId;
	}
	
	private static FieldsMappings getFieldsMappings(String sTemplateId, String sHotelId)
		throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ImportTemplateUtilHyatt.getFieldsMappings()");
			stmt = conn.createStatement();			
			return getFieldsMappings(sTemplateId, sHotelId, stmt);
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

	private static FieldsMappings getFieldsMappings(String sTemplateId, String sHotelId, Statement stmt) throws SQLException
	{
		FieldsMappings fms = new FieldsMappings();

		String sSql = 
			" SELECT attr_id"+
			" FROM cupd_import_template_attr_hyatt" +
			" WHERE template_id = " + sTemplateId +
			" AND hotel_id = '" + sHotelId + "'" +
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
	
	private static void setImportIdLabel(FtpFile ff, String sHotelId, String sImportId) throws SQLException
	{
		String sSql = 
			" UPDATE cftp_ftp_file_hyatt" +
			" SET import_id=" + sImportId +
			" WHERE file_id=" + ff.s_file_id +
			" AND hotel_id='" + sHotelId + "'";

		int nRowsUpdated = BriteUpdate.executeUpdate(sSql);
		
		if (nRowsUpdated < 1)
		{
			sSql = 
				" INSERT cftp_ftp_file_hyatt" +
				" (file_id,hotel_id,import_id)" +
				" VALUES" +
				"(" + ff.s_file_id +
				",'" + sHotelId + "'" +
				"," + sImportId + ")";
				
			BriteUpdate.executeUpdate(sSql);
		}
	}		
}