package com.britemoon.cps.ftp;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;

import org.apache.log4j.Logger;

import com.britemoon.cps.BriteTaskGeneric;
import com.britemoon.cps.BriteTimerGeneric;
import com.britemoon.cps.BriteTimer;
import com.britemoon.cps.BriteTask;
import com.britemoon.cps.ConnectionPool;
import com.britemoon.cps.ftp.FtpFile;
import com.britemoon.cps.ntt.EntityImportUtil;
import com.britemoon.cps.upd.ImportTemplateUtil;
import com.britemoon.cps.upd.ImportTemplateUtilHyatt;
import com.britemoon.cps.ftp.FtpTaskImportTemplate;

/**
 * Loads either a recipient import file or entity import file.
 * 
 * @author lwilson
 * @param sFileID  the fileid of the import file in cft_ftp_file
 * @param sTaskID  the taskID 
 * @param sFileName cft_ftp_file.file_name_local 
 *
 */
public class ImportProcessTask extends BriteTask {
	String m_sTaskID = null;
	String m_sFileID = null;
	String m_sFileName = null;
	java.util.Date m_dDate = null;
	private static Logger logger = Logger.getLogger(ImportProcessTask.class.getName());

	public ImportProcessTask(String sFileID, String sTaskID, String sFileName) throws Exception
	{
		m_sTaskID = sTaskID;
		m_sFileID = sFileID;
		m_sFileName = sFileName;
		m_dDate = new java.util.Date();
		init();
	}

	private void init()
	{
		setTaskName("ImportProcessTask");

		setCustId("-1");
		setIdName("task_id");
		setId(m_sTaskID);
		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		String sMsg =
			"ImportProcessTask: file_id = "+ m_sFileID + " task_id= " + m_sTaskID + " date='" + m_dDate + "'";
		if(!mayStart(m_sTaskID, m_dDate)) {
			logger.info(sMsg + " finished because previous linked task has not finished.");
			return;
		}
		try
		{
			logger.info(sMsg + " started");
			setupImports(m_sFileID, m_sTaskID, m_sFileName, m_dDate);
			logger.info(sMsg + " finished");
		}
		catch(Exception ex)
		{
			logger.info(sMsg + " finished WITH ERROR:");
			logger.error("Exception: ", ex);
		}
	}

	private static boolean mayStart(String sTaskID, java.util.Date dDate) throws Exception
	{
		// Check if linked ftp import has compleded succesfully by checking to see
		// if the file assignments table (or in the case of hyatt, the cftp_ftp_file_hyatt table
		// has a row count greater than zero for the previously task to which this task is linked.
		boolean bNumRows = false;
		ConnectionPool cp = ConnectionPool.getInstance();
		Connection conn = null;
		Statement stmt = null;

		FtpTaskSchedule fts = new FtpTaskSchedule(sTaskID);

		if (fts.s_linked_task_id == null) return true;

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		String sDate = sdf.format(dDate);
		String sSql = null;
		ResultSet rs = null;
		conn = cp.getConnection("ImportProcessTask.mayStart");
		stmt = conn.createStatement();

		try {
			sSql = 
				" SELECT recip_import_id" +
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

			rs = stmt.executeQuery(sSql);
			if (rs.next())
			{
				bNumRows = true;
			} else {
				bNumRows = false;
			}
			rs.close();
		} catch (SQLException sqle) {
			logger.error(sqle.getMessage(), sqle);
		} finally {
			try { if (stmt != null) stmt.close(); }
			catch (SQLException sqle) { }
			if (conn != null) cp.free(conn);
		}

		if (bNumRows) return true;


		// === hyatt ===

		try {
			rs = null;
			conn = cp.getConnection("ImportProcessTask.mayStart");
			stmt = conn.createStatement();
			sSql = 
				"	SELECT import_id " +
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

			rs = stmt.executeQuery(sSql);
			if (rs.next())
			{
				bNumRows= true;
			} else {
				bNumRows =  false;
			}
			rs.close();
		} catch (SQLException sqle) {
			logger.error(sqle.getMessage(), sqle);
		} finally {
			try { if (stmt != null) stmt.close(); }
			catch (SQLException sqle) { }
			if (conn != null) cp.free(conn);
		}


		// === === ===

		return bNumRows;
	}

	private static void setupImports(String sFileID, String sTaskID, String sFileName, java.util.Date dDate4ImportName)
	throws Exception
	{
		FtpFile ff = new FtpFile(sFileID);
		FtpTaskImportTemplate ftit = new FtpTaskImportTemplate(ff.s_task_id);

//		=== === ===

		if ((ftit.s_recip_import_template_id == null) && (ftit.s_entity_import_template_id == null))
		{
			String sErrMsg =
				"ImportProcessTask.setupImports() ERROR:" +
				" no import template specified for ftp_task" +
				" task_id = " + ff.s_task_id;
			ff.s_error_msg = sErrMsg;
			setStatusAndSave(ff, "5");
			throw new Exception(sErrMsg);
		}

//		=== === ===

		if ((ftit.s_recip_import_template_id != null) || (ftit.s_entity_import_template_id != null))
		{
			// recipient + entity in one file
			// do parsing here and then setup recipient and entity imports
		}

//		=== === ===

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

//		=== === ===

		if (ftit.s_entity_import_template_id != null)
		{
			EntityImportUtil.setupFtpImport(ftit.s_entity_import_template_id, ff, dDate4ImportName);
		}
		
		setStatusAndSave(ff, "4");
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

}




