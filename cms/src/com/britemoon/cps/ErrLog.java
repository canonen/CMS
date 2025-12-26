package com.britemoon.cps;

import javax.servlet.jsp.JspWriter;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.util.Calendar;

public class ErrLog
{
    public static String sErrFileName;
	static {
		Calendar today = Calendar.getInstance();
		String date = today.get(Calendar.YEAR)+"-"+(today.get(Calendar.MONTH)+1)+"-"+today.get(Calendar.DATE);
		sErrFileName = Registry.getKey("error_log_file")+"."+date+".txt";
	}

    public static void put(Object o, Exception ex, String sMsg)
    {
		put(o, ex, sMsg, null, 0);
    }

	public static void put(Object o, Exception ex, String sMsg, JspWriter out, int iDebugLevel)
	{

		String sLogMsg = prepareLogMsg (o, ex, sMsg);
		
		System.err.println(sLogMsg);
		if (sErrFileName != null) {
			try
			{
				BufferedWriter bwErrLog = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(sErrFileName, true), "ISO-8859-1"));;
				bwErrLog.write(sLogMsg+"\r\n");
				bwErrLog.flush();
				bwErrLog.close();
			}
			catch (Exception ex2) {}
		}

		if ((out != null) && (iDebugLevel > 0))
		{
			try
			{
				out.println("<PRE>");
				out.println(sLogMsg);
				out.println("</PRE>");				
			}
			catch (IOException ioEx){}
		}
	}

	private static String prepareLogMsg (Object o, Exception ex, String sMsg)
	{
		StringWriter sw = new StringWriter();
		
		sw.write("\r\n");
		sw.write("=== *** === ErrLog === *** ===");
		sw.write("\r\n");
		sw.write(new java.util.Date().toString());
		sw.write("\r\n");
		sw.write("Class: " + o.getClass().getName());
		sw.write("\r\n");

		if ( sMsg != null )
		{
			sw.write("Message: " + sMsg);
			sw.write("\r\n");
		}

		sw.write(ex.getClass().getName());
		sw.write("\r\n");		
		sw.write("Exception message: " + ex.getMessage());
		sw.write("\r\n");
		
		StackTraceElement[] ste = ex.getStackTrace();
		int n = ste.length;
		for(int i = 0; i < n; i++)
		{
			sw.write(ste[i].toString());
			sw.write("\r\n");
		}
		
		sw.write("=== *** === ****** === *** ===");
		sw.write("\r\n");

		return sw.toString();
	}
}