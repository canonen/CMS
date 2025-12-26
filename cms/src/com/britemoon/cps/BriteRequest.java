package com.britemoon.cps;

import java.util.Enumeration;
import javax.servlet.ServletRequest;

public class BriteRequest
{
	public static String getParameter(ServletRequest request, String name)
	{
		return clean(request.getParameter(name));
	}

	public static Enumeration getParameterNames(ServletRequest request)
	{
		return request.getParameterNames();
	}
	
	public static String[] getParameterValues(ServletRequest request, String name)
	{
		String[] sResults = null;
		String[] sOriginals = request.getParameterValues(name);
		
		if(sOriginals == null) return sResults;
		
		int nLength = sOriginals.length;
		sResults = new String[nLength];

		for (int i = 0; i < nLength; i++)
			sResults[i] = clean(sOriginals[i]);

		return sResults;		
	}
	
	private static String clean(String sOriginal)
	{
		String sResult = null;
		if ( sOriginal == null ) return sResult;
		
		sOriginal = sOriginal.trim();
		if ( sOriginal.length() == 0 ) return sResult;

		try { sResult = new String(sOriginal.getBytes("ISO-8859-1"), "UTF-8"); }
		catch(Exception ex) { sResult = null; }

		return sResult;
	}
}