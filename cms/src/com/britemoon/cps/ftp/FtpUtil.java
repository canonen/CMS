package com.britemoon.cps.ftp;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.*;

import com.jscape.inet.ftp.Ftp;
import org.apache.log4j.*;


public class FtpUtil
{
	private static String sProcessedMarker = "processed";
	private static Logger logger = Logger.getLogger(FtpUtil.class.getName());
	
	public static Vector getFilesToDownload(FtpTask ft, java.util.Date dDate) throws Exception
	{
		String sFileNameMask = getFileNameMask(ft, dDate);
		return getFilesToDownload(ft, sFileNameMask);
	}
	
	public static Vector getFilesToDownload(FtpTask ft, String sFileNameMask) throws Exception
	{
		Enumeration eNameListing = null;
		
		Ftp ftp = null;
		try
		{
			ftp = new Ftp(ft.s_server, ft.s_username, ft.s_password);
			int nTimeout = getFtpConnectTimeout();
			ftp.setTimeout(nTimeout);
			ftp.connect();
			
			if (ft.s_directory != null) ftp.setDir(ft.s_directory);
			
			eNameListing = ftp.getDirListing(sFileNameMask);
		}
		catch(Exception ex) { throw ex; }
		finally
		{
			if (ftp != null) ftp.disconnect();
		}

		// === ignore files with processed marker ===
		
		Vector vFilesToDownload = new Vector();
		
		while(eNameListing.hasMoreElements())
		{
			com.jscape.inet.ftp.FtpFile ff =
				(com.jscape.inet.ftp.FtpFile) eNameListing.nextElement();
			if(ff.isDirectory()) continue;
			String sFileName  = ff.getFilename();
			if(sFileName.indexOf(sProcessedMarker) > -1)  continue;
			vFilesToDownload.add(sFileName);
		}
		
		return vFilesToDownload;
	}

	private static int getFtpConnectTimeout()
	{
		int nTimeout = 60 * 1000;
		
		try
		{
			String sTimeout = Registry.getKey("ftp_timeout");
			if (sTimeout != null) nTimeout = Integer.parseInt(sTimeout);
		}
		catch(Exception ex)
		{
			nTimeout = 60 * 1000;
		}
		
		return nTimeout;
	}

	private static String getFileNameMask(FtpTask ft, java.util.Date dDate)
	{
		String sFileNameMask = "";
		if( ft.s_filename_prefix != null ) sFileNameMask += ft.s_filename_prefix;
		
		if (ft.s_date_format != null)
		{
			SimpleDateFormat sdf = new SimpleDateFormat(ft.s_date_format);	
			sFileNameMask += sdf.format(dDate);
		}
		
		if( ft.s_filename_suffix != null ) sFileNameMask += ft.s_filename_suffix;
				
		return sFileNameMask;
	}

	public static File download(FtpTask ft, FtpFile ff) throws Exception
	{
		String sLocalDir = Registry.getKey("import_data_dir");
		
		// === === ===

		Ftp ftp = null;
		try
		{
			ftp = new Ftp(ft.s_server, ft.s_username, ft.s_password);
			ftp.setTimeout(15000);
			ftp.connect();
			
			if (ft.s_directory != null) ftp.setDir(ft.s_directory);
			ftp.setLocalDir(new File(sLocalDir));
			ftp.setAuto(false);
			ftp.setBinary();

			ftp.download(ff.s_file_name_local, ff.s_file_name_remote);
	    }
		catch(Exception ex) { throw ex; }
		finally
		{
			if (ftp != null) ftp.disconnect();
		}
		
		// === === ===
				
		// this check was here in previous version, so let it be
		File fLocalFile = new File(sLocalDir, ff.s_file_name_local);
		if (!fLocalFile.exists())
		{
			String sErrMsg = 
				"FTPUtil.download() ERROR: cannot find 'downloaded' file." +
				"\r\ntask_id = " + ff.s_task_id +
				"\r\nlocal_file = " + fLocalFile;
			throw new Exception(sErrMsg);
		}
		return fLocalFile;
	}

	public static void renameRemoteFile(FtpTask ft, FtpFile ff) throws Exception
	{
		//Rename file on ftp site
		Ftp ftp = null;
		try
		{
			ftp = new Ftp(ft.s_server, ft.s_username, ft.s_password);
			ftp.setTimeout(15000);
			ftp.connect();
			if (ft.s_directory != null) ftp.setDir(ft.s_directory);

			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss_SSS");	
			String sProcessedFileName = 
				ff.s_file_name_remote + "." + sProcessedMarker + "." + sdf.format(new java.util.Date());
				
			ftp.renameFile(ff.s_file_name_remote, sProcessedFileName);
	    }
		catch(Exception ex) { throw ex; }
		finally
		{
			if (ftp != null) ftp.disconnect(); 
		}
	}

	public static void decryptPgpFile(File fFile) throws Exception
	{
		String sFile = fFile.toString();
		File fPgpFile = new File(sFile + ".pgp");
		if(fPgpFile.exists()) fPgpFile.delete();
		if (!fFile.renameTo(fPgpFile))
		{
			String sErrMsg = 
				"FtpUtil.decryptPgpFile() ERROR: cannot rename the file to decrypt." +
				"\r\n " + fFile; 
			throw new Exception(sErrMsg);
		}
	
		// === === ===

        String[] cmd = new String[3];
		cmd[0] = "cmd.exe" ;
		cmd[1] = "/C" ;
		cmd[2] = "pgp +force +batchmode -z h4rp00n "+ fPgpFile + " -o " + fFile;
		
        Runtime rt = Runtime.getRuntime();
        Process proc = rt.exec(cmd);
		
		int nReturnCode = proc.waitFor(); // nReturnCode == 0 - normal termination
		
		// === === ===
		
		if (!fFile.exists() || fFile.length() < 1)
		{
			String sErrMsg = 
				"FtpUtil.decryptPgpFile() ERROR: cannot find 'decrypted' file. PGP command:" +
				"\r\n" + cmd[0] + " " + cmd[1] + " " + cmd[2];
			throw new Exception(sErrMsg);
		}
	}
}

/*
	public static String generateFileNameRoot(FtpTask ft, java.util.Date dDate)
	{
		if(ft.s_date_format == null) ft.s_date_format = "MMddyyyy";
		SimpleDateFormat sdf = new SimpleDateFormat(ft.s_date_format);	
		return sdf.format(dDate);
	}
*/

