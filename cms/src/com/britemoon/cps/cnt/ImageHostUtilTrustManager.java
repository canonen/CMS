package com.britemoon.cps.cnt;

import javax.net.ssl.*;
import org.apache.log4j.*;

public class ImageHostUtilTrustManager implements X509TrustManager
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(ImageHostUtilTrustManager.class.getName());
	
	public java.security.cert.X509Certificate[] getAcceptedIssuers()
	{
		return null;
	}

	public void checkClientTrusted(java.security.cert.X509Certificate[] certs, String authType)
	{
	}

	public void checkServerTrusted(java.security.cert.X509Certificate[] certs, String authType)
	{
	}
}
