package com.britemoon.cps;

import java.io.*;
import java.util.logging.Logger;

public class StdLog
{
	private static Logger logger = Logger.getLogger(StdLog.class.getName());
	public static void put(Object o, String sMsg)
	{
		String sLogMsg = prepareLogMsg (o, sMsg);
		logger.info(sLogMsg);
	}
	
	private static String prepareLogMsg (Object o, String sMsg)
	{
		StringWriter sw = new StringWriter();
		sw.write("\r\n");		
		sw.write("=== *** === StdLog === *** ===");
		sw.write("\r\n");
		sw.write(new java.util.Date().toString());
		sw.write("\r\n");
		sw.write("Class: " + o.getClass().getName());
		sw.write("\r\n");
		sw.write(sMsg);
		sw.write("\r\n");
		sw.write("=== *** === ****** === *** ===");
		sw.write("\r\n");
		return sw.toString();
	}
}