package com.britemoon.cps.ftp;

import com.britemoon.*;
import com.britemoon.cps.SleepTask;
import com.britemoon.cps.BriteTaskGeneric;
import com.britemoon.cps.BriteTimerGeneric;
import com.britemoon.cps.BriteTimer;
import com.britemoon.cps.BriteTask;
import com.britemoon.cps.BriteUpdate;
import com.britemoon.cps.ftp.FtpUtil;

import java.io.*;
import java.util.*;
import java.text.*;

import org.apache.log4j.*;
/**
 * Ftp downloads either a recipient import file, entity import file, or offer zip file from the ftp site.
 * This task just ftp downloads a file using data from FtpTask and stores a record about the 
 * file downloaded into cftp_ftp_file.
 * Subsequent tasks will read a row from cft_ftp_file and process the file appropriately.
 * 
 * @author lwilson
 * @param sTaskID  the taskID 
 *
 */
public class FtpTaskTask extends BriteTask
{
	String m_sTaskId = null;
	java.util.Date m_dDate = null;
	private static Logger logger = Logger.getLogger(FtpTaskTask.class.getName());
	
	public FtpTaskTask(String sTaskId) throws Exception
	{
		m_sTaskId = sTaskId;
		m_dDate = new java.util.Date();
		init();
	}

	private void init()
	{
		setTaskName("FtpTaskTask");

		setCustId("-1");
		setIdName("task_id");
		setId(m_sTaskId);
		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		String sMsg =
			"FtpTaskTask: task_id= " + m_sTaskId + " date='" + m_dDate + "'";
			
		try
		{
			logger.info(sMsg + " started");
			startFtpTaskTask();
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
	
	public void startFtpTaskTask() throws Exception
	{
			
		// === === ===

		FtpTask ftpTask = new FtpTask(m_sTaskId);
		setCustId(ftpTask.s_cust_id);
		int nFilesDownloaded = startFtpDownloadFiles(ftpTask, m_dDate);				

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

	private static int startFtpDownloadFiles(FtpTask ftpTask, java.util.Date dDate) throws Exception
	{
		int nFilesDownloaded = 0;
		
		Vector vFilesToDownload = FtpUtil.getFilesToDownload(ftpTask, dDate);
		
		for(Enumeration e = vFilesToDownload.elements(); e.hasMoreElements();)
		{
			String sFileNameRemote = (String) e.nextElement();
			startFtpFile(ftpTask, sFileNameRemote, dDate); 
			nFilesDownloaded++;
		}
		
		return nFilesDownloaded;
	}

	public static void startFtpFile
		(String sTaskId, String sFileNameRemote, java.util.Date dDate4ImportName)
			throws Exception
	{
		FtpTask ftpTask = new FtpTask(sTaskId);
		if(dDate4ImportName == null) dDate4ImportName = new java.util.Date();
		startFtpFile(ftpTask, sFileNameRemote, dDate4ImportName);
	}

	private static void startFtpFile
		(FtpTask ft, String sFileNameRemote, java.util.Date dDate4ImportName)
			throws Exception
	{
		FtpFile ff = new FtpFile();

		ff.s_task_id = ft.s_task_id;
		ff.s_file_name_remote = sFileNameRemote;

		ff.s_file_name_local =
			"FTP_t" + ft.s_task_id + "_" +
			createImportLocalFileName(ft.s_cust_id, ff.s_file_name_remote);

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

			//LW 4/2007:  This task stops when the files have been successfully downloaded 
			// and pgp decrypted.  The next task, will depend on the file type and will be
			// either ImportProcessTask or OfferProcess task.  
			if (ft.s_type_id.equals("30")) {
				ff.s_type_id = "30";
			} else if (ft.s_type_id.equals("20")) {
				ff.s_type_id = "20";
			} else if (ft.s_type_id.equals("10")) {
				ff.s_type_id = "10";
			}

			setStatusAndSave(ff, "3");
			
			
		
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
	
	private static String createImportLocalFileName (String sCustId, String sRemoteFileName)
	{
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss_SSS");		
		return "c" + sCustId + "_" + sdf.format(new java.util.Date()) + "_" + sRemoteFileName.replace(' ','_');
	}


}

