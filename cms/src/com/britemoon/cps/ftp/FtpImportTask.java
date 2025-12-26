package com.britemoon.cps.ftp;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.upd.*;
import com.britemoon.cps.ntt.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.*;
import org.apache.log4j.*;

public class FtpImportTask extends BriteTask
{
	String m_sTaskId = null;
	java.util.Date m_dDate = null;
	private static Logger logger = Logger.getLogger(FtpImportTask.class.getName());
	
	public FtpImportTask(String sTaskId) throws Exception
	{
		m_sTaskId = sTaskId;
		m_dDate = new java.util.Date();
		init();
	}

	private void init()
	{
		setTaskName("FtpImportTask");

		setCustId("-1");
		setIdName("task_id");
		setId(m_sTaskId);
		setStringComment("Grab ftp import file from date = " + m_dDate);

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		String sMsg =
			"FtpImportTask: task_id=" + m_sTaskId + " date='" + m_dDate + "'";
			
		try
		{
			logger.info(sMsg + " started");
			startFtpImportTask();
			logger.info(sMsg + " finished");
		}
		catch(Exception ex)
		{
			logger.info(sMsg + " finished WITH ERROR:");
			if (ex instanceof com.jscape.inet.ftp.FtpException)
			{
				// Scott claimed it is inconvinient
				// to see too much about ftp errors
				logger.info("com.jscape.inet.ftp.FtpException: " + ex.getMessage());
			}
			else logger.error("Exception: ", ex);
		}
	}
	
	public void startFtpImportTask() throws Exception
	{
		if(!mayStart(m_sTaskId, m_dDate)) return;
		
		// === === ===

		FtpTask ft = new FtpTask(m_sTaskId);
		setCustId(ft.s_cust_id);
		int nFilesDownloaded = startFtpImportTask(ft, m_dDate);				

		// === === ===
				
		if( nFilesDownloaded > 0 )
		{
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
			String sDate = sdf.format(m_dDate);
				
			String sSql = 
				" EXEC usp_cftp_ftp_task_schedule_tweak" +
				"  @task_id=" + m_sTaskId +
				", @last_start_date='" + sDate + "'";

			BriteUpdate.executeUpdate(sSql);
		}
	}

	private static int startFtpImportTask(FtpTask ft, java.util.Date dDate) throws Exception
	{
		int nFilesDownloaded = 0;
		
		Vector vFilesToDownload = FtpUtil.getFilesToDownload(ft, dDate);
		
		for(Enumeration e = vFilesToDownload.elements(); e.hasMoreElements();)
		{
			String sFileNameRemote = (String) e.nextElement();
			startFtpImportTask(ft, sFileNameRemote, dDate); 
			nFilesDownloaded++;
		}
		
		return nFilesDownloaded;
	}

	public static void startFtpImportTask
		(String sTaskId, String sFileNameRemote, java.util.Date dDate4ImportName)
			throws Exception
	{
		FtpTask ft = new FtpTask(sTaskId);
		if(dDate4ImportName == null) dDate4ImportName = new java.util.Date();
		startFtpImportTask(ft, sFileNameRemote, dDate4ImportName);
	}

	private static void startFtpImportTask
		(FtpTask ft, String sFileNameRemote, java.util.Date dDate4ImportName)
			throws Exception
	{
		FtpFile ff = new FtpFile();

		ff.s_task_id = ft.s_task_id;
		ff.s_file_name_remote = sFileNameRemote;

		ff.s_file_name_local =
			"FTP_t" + ft.s_task_id + "_" +
			ImportUtil.createImportLocalFileName(ft.s_cust_id, ff.s_file_name_remote);

		setStatusAndSave(ff, "1");

		// === === ===

		try
		{
			File fLocalFile  = FtpUtil.download(ft, ff);
			
			// === === ===
					
			if("1".equals(ft.s_pgp_flag))
			{
				setStatusAndSave(ff, "2");
				FtpUtil.decryptPgpFile(fLocalFile);
			}

			// === === ===

			setStatusAndSave(ff, "3");
			setupImports(ff, dDate4ImportName);
			
			// === === ===
						
			setStatusAndSave(ff, "4");
		}
		catch(Exception ex)
		{
			ff.s_error_msg = ex.getMessage();
			setStatusAndSave(ff, "5");
			throw ex;
		}
		
		// === === ===
		
		try { FtpUtil.renameRemoteFile(ft, ff); }
		catch (Exception ex) { logger.error("Exception: ", ex); }
	}
	
	private static void setupImports(FtpFile ff, java.util.Date dDate4ImportName)
			throws Exception
	{
		FtpTaskImportTemplate ftit = new FtpTaskImportTemplate(ff.s_task_id);
		
		// === === ===
				
		if ((ftit.s_recip_import_template_id == null) && (ftit.s_entity_import_template_id == null))
		{
			String sErrMsg =
				"FtpImportTask.setupImports() ERROR:" +
				" no import template specified for ftp_task" +
				" task_id = " + ff.s_task_id;
			throw new Exception(sErrMsg);
		}
		
		// === === ===

		if ((ftit.s_recip_import_template_id != null) || (ftit.s_entity_import_template_id != null))
		{
			// recipient + entity in one file
			// do parsing here and then setup recipient and entity imports
		}

		// === === ===
		
		if (ftit.s_recip_import_template_id != null)
		{
			if (ImportTemplateUtilHyatt.isItHyattTemplate(ftit.s_recip_import_template_id))
			{
				ImportTemplateUtilHyatt.setupImports(ftit.s_recip_import_template_id, ff, dDate4ImportName);
			}
			else
			{
				ImportTemplateUtil.setupImport(ftit.s_recip_import_template_id, ff, dDate4ImportName);
			}
		}
		
		// === === ===
				
		if (ftit.s_entity_import_template_id != null)
		{
			EntityImportUtil.setupFtpImport(ftit.s_entity_import_template_id, ff, dDate4ImportName);
		}
	}

	private static void setStatusAndSave(FtpFile ff, String sStatusId)
	{
		try
		{
			ff.s_status_id = sStatusId;
				
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
			ff.s_finish_date = sdf.format(new java.util.Date());
			
			ff.save();
		}
		catch(Exception ex)
		{
			logger.error("Exception: ", ex);
		}	
	}
	
	private static boolean mayStart(String sTaskId, java.util.Date dDate) throws Exception
	{
		// === check if linked ftp import has compleded succesfully ===

		FtpTaskSchedule fts = new FtpTaskSchedule(sTaskId);

		if (fts.s_linked_task_id == null) return true;

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		String sDate = sdf.format(dDate);
		
		String sSql = 
			" UPDATE cftp_ftp_file_assignments" +
			"	SET recip_import_id = recip_import_id" +
			"	FROM" +
			"		cftp_ftp_file ff," +			
			"		cftp_ftp_task_schedule fts," +
			"		cftp_ftp_file_assignments ffa" + 
			"	WHERE" +
			"		ffa.file_id = ff.file_id AND"+
			"		ff.task_id = fts.task_id AND" +
			"		fts.task_id = " + fts.s_linked_task_id + " AND" +
			"		DATEDIFF(dd, ff.start_date, '" + sDate + "') = 0 AND" +
			"		ff.status_id = 4 AND" +
			"		ffa.recip_import_id IS NOT NULL";

		int nRowsUpdated = BriteUpdate.executeUpdate(sSql);
		if (nRowsUpdated > 0) return true;
		
		// === hyatt ===

		sSql = 
			" UPDATE cftp_ftp_file_hyatt" +
			"	SET import_id = import_id" +
			"	FROM" +
			"		cftp_ftp_file ff," +			
			"		cftp_ftp_task_schedule fts," +
			"		cftp_ftp_file_hyatt ffh" + 
			"	WHERE" +
			"		ffh.file_id = ff.file_id AND"+
			"		ff.task_id = fts.task_id AND" +
			"		fts.task_id = " + fts.s_linked_task_id + " AND" +
			"		DATEDIFF(dd, ff.start_date, '" + sDate + "') = 0 AND" +
			"		ff.status_id = 4 AND" +
			"		ffh.import_id IS NOT NULL";

		nRowsUpdated = BriteUpdate.executeUpdate(sSql);
		if (nRowsUpdated > 0) return true;
		
		// === === ===

		return false;
	}
}

