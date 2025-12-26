package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.*;
import javax.servlet.ServletInputStream;
import org.apache.log4j.*;

public class ImportUtil
{
	private static Logger logger = Logger.getLogger(ImportUtil.class.getName());
	public static Import setupRCP(String sImportId) throws Exception
	{
		Import imp = null;
		String sSql = null;
		try
		{
			imp = setupRCP2(sImportId);

			sSql = 
				" UPDATE cupd_import SET status_id = 10" +
				" WHERE import_id = " + imp.s_import_id;
			BriteUpdate.executeUpdate(sSql); 
		}
		catch (Exception ex)
		{
			logger.error("Exception: ",ex);
			sSql =
				" UPDATE cupd_import SET status_id = 70" +
				" WHERE import_id = " + imp.s_import_id;

			try { BriteUpdate.executeUpdate(sSql); }
			catch (Exception exx) 
			{ 
				logger.error("Exception: ",exx);
			}
			
			sSql =
				" INSERT cupd_import_statistics (import_id, error_message)" +
				" VALUES (" + imp.s_import_id + ",'" + ex.getMessage().replaceAll("'","''") + "')";

			try { BriteUpdate.executeUpdate(sSql); }
			catch (Exception exx) 
			{ 
				logger.error("Exception: ",exx); 
			}
		}
		return imp;
	}

	private static Import setupRCP2(String sImportId) throws Exception
	{
		Import imp = new Import(sImportId);
		imp.m_Batch = new Batch(imp.s_batch_id);
		imp.m_FieldsMappings = retrieveFieldsMappings(sImportId);
		imp.m_ImportNewsletters = retrieveImportNewsletters(sImportId);

		// === === ===

		String sRequest = imp.toXml();
		String sResponse =
			Service.communicate(ServiceType.RUPD_IMPORT_SETUP, imp.m_Batch.s_cust_id, sRequest);

		// === === ===
		
		try { XmlUtil.getRootElement(sResponse); }
		catch(Exception ex)
		{
			String sErrMsg =
				"\r\nImportUtil.setupRCP() ERROR:" + 
				"\r\nsRequest = \r\n" + sRequest +
				"\r\nsResponse = \r\n" + sResponse;				
			
			logger.info(sErrMsg,ex);
			throw ex;
		}
		return imp;
	}
	
	private static FieldsMappings retrieveFieldsMappings(String sImportId) throws Exception
	{
		FieldsMappings fms = new FieldsMappings();
		fms.s_import_id = sImportId;
		if (fms.retrieve() < 1)
		{
			String sErrMsg = 
				"ImportUtil.retrieveFieldsMappings() ERROR: " +
				"FieldsMappings are absent. import_id = " + sImportId;
			throw new Exception(sErrMsg);
		}
		
		tweakEmailAttrsIds(fms);
		return fms;
	}
	
	private static void tweakEmailAttrsIds(FieldsMappings fms)
	{
		String sEmail821AttrId = String.valueOf(CommonAttrIds.EMAIL_821);
		String sEmailGenericAttrId = String.valueOf(CommonAttrIds.EMAILGENERIC);

		FieldsMapping fm = null;
		for (Enumeration e = fms.elements() ; e.hasMoreElements() ;)
		{
			fm = (FieldsMapping)e.nextElement();
			if(sEmail821AttrId.equals(fm.s_attr_id)) fm.s_attr_id = sEmailGenericAttrId;
		}
	}

	private static ImportNewsletters retrieveImportNewsletters(String sImportId) throws Exception
	{
		ImportNewsletters ins = new ImportNewsletters();
		ins.s_import_id = sImportId;
		ins.retrieve();
		return ins;
	}
		
	public static void sendImportActionToRCP(String sCustId, String sImportId, String sAction) throws Exception
	{
		String sDetailXML =
			"<import_action>" +
				"<cust_id>"+ sCustId +"</cust_id>" +
				"<import_id>"+sImportId+"</import_id>" +
				"<action>" + sAction + "</action>" +
			"</import_action>";

		Service.notify(ServiceType.RUPD_IMPORT_ACTION, sCustId, sDetailXML);
	}
	
	// === === ===
	
	// this should be rewritten
	public static HashMap downloadImport(ServletInputStream in, String sCustId) throws IOException
	{
		byte[] buf = new byte[16384];
		int nBufLength = buf.length;
		String sDataString = "";
		int nDataRead = 0;

		String sRequestDelimiter = "";
		int nRequestDelimiterLength = 0;
		String sHeaderString = "";
		String sParamName = "";
		String sParamValue = "";		

		boolean bIsNameParamSet=false;
		boolean bIsContentTypeParamSet=false;
		String sCRLF = "\r\n";
	
		nRequestDelimiterLength = in.readLine (buf, 0, nBufLength) - sCRLF.length();
		sRequestDelimiter = new String (buf, 0, nRequestDelimiterLength);
		nDataRead = nRequestDelimiterLength;
		
		//======================================================================

		HashMap aImportParameters = new HashMap();
		while (nDataRead > 0)
		{
			bIsNameParamSet=false;
			bIsContentTypeParamSet=false;
					
			while((nDataRead = in.readLine(buf, 0, nBufLength)) > 0)
			{	
				sHeaderString = new String (buf, 0, nDataRead);
				if (sHeaderString.equals("\r\n"))  break;
				if (!bIsNameParamSet)
				{
					bIsNameParamSet = ((sParamName = getParameterName (sHeaderString)) != null);
					if (sParamName.indexOf ("recipient_file") != -1)
					{
						sParamValue = getParameterValue (sHeaderString);
						if (sParamValue == null) sParamValue = "unknown_name";
					}
				}
				if (!bIsContentTypeParamSet)
				{
					bIsContentTypeParamSet = (sHeaderString.indexOf ("Content-Type:") != -1) ? true : false;
				}
			}

			if (bIsContentTypeParamSet)
			{
				aImportParameters.put (sParamName, sParamValue);			
				break;
			}
			else
			{
				sParamValue = "";
				while ((nDataRead = in.readLine (buf, 0, nBufLength)) > 0)
				{
					sDataString = new String (buf, 0, nDataRead);
					if(sDataString.startsWith (sRequestDelimiter))  break;
					else
					{
						if  (sParamValue.length() == 0)   sParamValue = sDataString;
						else sParamValue = sParamValue + "\r\n" + sDataString;
					}
					aImportParameters.put (sParamName, sParamValue);
				}
			}
		}
		
		// =====================================
		
		String sDataDir = Registry.getKey("import_data_dir");
	
		//==== Get filename to save into ===
		
		String sUserFilename = aImportParameters.get("recipient_file").toString();
		sUserFilename = sUserFilename.trim ();
		
		String sLocalFileName = createImportLocalFileName(sCustId, sUserFilename);
	
		aImportParameters.put("server_file_name", sLocalFileName);
	
		//=== Download file to local disk under the name of (...) ===
		
		File fOutFile = new File (sDataDir + sLocalFileName);
		FileOutputStream fosOutFile = new FileOutputStream (fOutFile);
		
		while ((nDataRead = in.readLine (buf, 0, nBufLength)) > 0)
		{
			sDataString = new String (buf, 0, nRequestDelimiterLength);
			if (sDataString.startsWith (sRequestDelimiter))  break;
			fosOutFile.write (buf, 0, nDataRead);
		}
		fosOutFile.close();
	
		//=== Erase last empty string in just downloaded file (if any) ===
		
		long len;
		byte[] buff = new byte [2];
		RandomAccessFile fraFile = new RandomAccessFile (fOutFile, "rw");
		while (true)
		{
			len = fraFile.length ();
			if (len < 2)	
				break;
			fraFile.seek (len-2);
			fraFile.read (buff);
	
			if (buff [0] == 0xD && buff [1] == 0xA ||
			    buff [0] == 0xA && buff [1] == 0xD)
				fraFile.setLength(len-2);
			else 	break;
		}
		fraFile.close();
		
		return aImportParameters;
	}
	
	public static String createImportLocalFileName (String sCustId, String sRemoteFileName)
	{
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss_SSS");		
		return "c" + sCustId + "_" + sdf.format(new java.util.Date()) + "_" + sRemoteFileName.replace(' ','_');
	}

	private static String getParameterName (String sSource)
	{
		String sParamName = null;
		String sSearch = "name=\"";
		int nBeginning = sSource.indexOf (sSearch) + sSearch.length();
		int nEnd = sSource.indexOf ("\"", nBeginning);
		sParamName = sSource.substring (nBeginning, nEnd);
		return sParamName;
	}

	private static String getParameterValue (String sSource)
	{
		String sParamName = null;
		String sSearch = "filename=\"";
		int nBeginning = sSource.indexOf (sSearch) + sSearch.length();
		int nEnd = sSource.indexOf ("\"", nBeginning);
		sParamName = sSource.substring (nBeginning, nEnd);
		// look for last file separator to get only filename, without path
		int nLastSeparator = sParamName.lastIndexOf (File.separator);
		if (nLastSeparator != -1)
		{
			sParamName = sParamName.substring (nLastSeparator + 1);
		}
		return sParamName;
	}
}	
	