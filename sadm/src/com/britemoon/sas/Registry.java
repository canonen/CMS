package com.britemoon.sas;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.Date;
import java.util.Iterator;
import java.util.Hashtable;
import org.apache.log4j.*;
public class Registry
{
	private static Registry m_rInstance = null;
	public static Hashtable hRegistry = null; 
	//log4j implementation
	private static Logger logger = Logger.getLogger(Registry.class.getName());
	public static String getKey(String sKeyName)
	{
		return (String) hRegistry.get(sKeyName);
	}

	public static void init(ServletContext sc)
	{
		if (m_rInstance == null) m_rInstance = new Registry();

		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("Registry.setup()");
			
			Statement stmt = null;
			try
			{
				stmt = conn.createStatement();
				String sSql =
					" SELECT key_name, key_value" +
					" FROM sadm_registry" +
					" ORDER BY key_name";

				ResultSet rs = stmt.executeQuery(sSql);

				Hashtable hNewRegistry = new Hashtable();
				
				byte[] b = null;
				String sKeyName = null;
				String sKeyValue = null;
				while (rs.next())
				{
					b = rs.getBytes(1);
					sKeyName = (b==null)?null:new String(b, "UTF-8");
					
					b = rs.getBytes(2);
					sKeyValue = (b==null)?null:new String(b, "UTF-8");
				
					hNewRegistry.put(sKeyName, sKeyValue);
				}
				rs.close();
				
				hRegistry = hNewRegistry;
				sc.setAttribute("Registry", m_rInstance);				
			}
			catch(Exception ex) { throw ex; }
			finally {if ( stmt != null ) stmt.close();}
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ", ex);			 
		}
		finally { if ( conn != null ) cp.free(conn); }
	}
}