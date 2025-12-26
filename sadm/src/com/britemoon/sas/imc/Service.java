package com.britemoon.sas.imc;

import com.britemoon.*;
import com.britemoon.sas.*;

import java.io.*;
import java.net.*;
import java.sql.*;
import java.util.*;

import javax.servlet.http.HttpServletResponse;
import org.apache.log4j.*;

public class Service
{
	public String s_type_id = null;
	public String s_mod_inst_id = null;
	public String s_cust_id = null;

	public String s_protocol = null;
	public String s_host = null;
	public String s_port = null;
	public String s_path = null;

	private HttpURLConnection huc = null;
	//log4j implementation
	private static Logger logger = Logger.getLogger(Service.class.getName());
	// === === ===

	public URL getURL() throws MalformedURLException
	{
		//s_host = "127.0.0.1";
		return new URL(s_protocol, s_host, Integer.parseInt(s_port), s_path);
	}

	// === === ===

	public static String communicate(int nServiceTypeId, String sCustId, String sRequest)
		throws Exception
	{
		Service service = getFirstService(nServiceTypeId, sCustId);
		return communicate(service, sRequest);
	}

	public static String acquire(int nServiceTypeId, String sCustId, String sRequest)
		throws Exception
	{
		Service service = getFirstService(nServiceTypeId, sCustId);
		return acquire(service);
	}

	public static void notify(int nServiceTypeId, String sCustId, String sRequest)
		throws Exception
	{
		Service service = getFirstService(nServiceTypeId, sCustId);
		notify(service, sRequest);
	}

	private static Service getFirstService(int nServiceTypeId, String sCustId)
		throws Exception
	{
		Service service = null;
		try
		{
			Vector services = Services.getByCust(nServiceTypeId, sCustId);
			service = (Service) services.get(0);
		}
		catch(Exception ex)
		{
			String sErrMsg =
				"Service.getFirstService() FAILED to obtain "+
				" service type_id = " + nServiceTypeId + " for customer id = " + sCustId;
			logger.error(sErrMsg , ex);
			throw ex;
		}

		return service;
	}

	// === === ===

	public String communicate(String sRequest) throws Exception
		{ return communicate(this, sRequest, true, true); }

	public String acquire() throws Exception
		{ return communicate(this, null, false, true); }

	public void notify(String sRequest) throws Exception
		{ communicate(this, sRequest, true, false); }

	public static String communicate(Service service, String sRequest) throws Exception
		{ return communicate(service, sRequest, true, true); }

	public static String acquire(Service service) throws Exception
		{ return communicate(service, null, false, true); }

	public static void notify(Service service, String sRequest) throws Exception
		{ communicate(service, sRequest, true, false); }

	private static String communicate(Service service, String sRequest, boolean bDoOutput, boolean bDoInput)
		throws Exception
	{
		String sResponse = null;
		try
		{
			service.connect(bDoOutput, bDoInput);
			if(bDoOutput) service.send(sRequest);
			if(bDoInput) sResponse = service.receive();
		}
		catch(Exception ex) { throw ex;	}
		finally { service.disconnect(); }

		return sResponse;
	}

	// === === ===

	public void connect() throws MalformedURLException, IOException
	{
		connect(true, true);
	}

	public void connect(boolean bDoOutput, boolean bDoInput)
		throws MalformedURLException, IOException
	{
		URL url = getURL();
		huc = (HttpURLConnection) url.openConnection();
//		huc.setRequestProperty("Connection", "close");
		huc.setDoOutput(bDoOutput);

		bDoInput = true; // required for getResponseCode() in send()
		huc.setDoInput(bDoInput);
	}

	public void disconnect()
	{
		if ( huc!= null ) huc.disconnect();
	}

	// === === ===

	public void send(String s) throws IOException
	{
		OutputStream out = huc.getOutputStream();
		out.write(s.getBytes("UTF-8"));
		out.flush();
		out.close();

		if ((huc != null) && (huc.getResponseCode()!= HttpServletResponse.SC_OK))
		{
/*
			String sErrMsg =
				"Service.send() ERROR:\r\n" +
				"\tservice.getURL() =\r\n" +
				"" + getURL() + "\r\n" +
				"\tstring to be send:\r\n" +
				"" + s + "\r\n" +
				"\ts_type_id = " + s_type_id +
				"\ts_mod_inst_id = " + s_mod_inst_id +
				"\ts_cust_id = " + s_cust_id;
			System.out.println(sErrMsg);
			System.out.flush();
*/
			throw new IOException ("Service.send(): " + huc.getResponseMessage());
		}
	}

	public String receive() throws IOException
	{
		ByteArrayOutputStream out = new ByteArrayOutputStream();

		InputStream in = null;
		try
		{
			in = huc.getInputStream();
			byte[] b = new byte[16384];
			for(int n = in.read(b); n > 0; n = in.read(b)) out.write(b, 0, n);
		}
		catch(IOException ex) { throw ex; }
		finally { if (in != null) in.close(); }

		return out.toString("UTF-8");
	}

/*
	public String receive() throws IOException
	{
		StringWriter sw = new StringWriter();
		BufferedReader br = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8"));

		String sLine = null;
		for(sLine = br.readLine(); sLine != null; sLine = br.readLine())
		{
			sw.write(sLine);
			sw.write("\r\n");
		}

		return sw.toString();
	}
*/

	// === === ===

	protected void finalize()
	{
		disconnect();
	}
}
