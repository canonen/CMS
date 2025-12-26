

package com.britemoon.cps.xcs.cti;

import com.britemoon.cps.*;

import org.apache.ws.security.WSPasswordCallback;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.UnsupportedCallbackException;
import java.io.IOException;
import java.sql.*;
import org.apache.log4j.*;

public class StipPWCallbackClient implements CallbackHandler {

	private static Logger logger = Logger.getLogger(StipPWCallbackClient.class.getName());
	public void handle(Callback[] callbacks)
			throws UnsupportedCallbackException 
	{
		logger.info("starting StipPWCallbackClient...");

		ConnectionPool cp = null;
		Connection conn = null;

		int i = 0;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("StipPWCallbackClient.handle()");

			Statement stmt = null;

			try 
			{
				stmt = conn.createStatement();

				for (i = 0; i < callbacks.length; i++) 
				{
					//System.out.println("callbacks[] is a:" + callbacks[i].getClass().getName());

					if (callbacks[i] instanceof org.apache.ws.security.WSPasswordCallback) 
					{
						//System.out.println("callback is a callback");
						WSPasswordCallback pc = (WSPasswordCallback) callbacks[i];
						/*
						* here call a function/method to lookup the password for
						* the given identifier (e.g. a user name or keystore alias)
						* e.g.: pc.setPassword(passStore.getPassword(pc.getIdentfifier))
						* for Testing we supply a fixed name here.
						*/
						String sSql =
							" SELECT password" +
							" FROM cxcs_ws_password " +
							" WHERE user_name = '" + pc.getIdentifer() +"'";
		
//System.out.println("callback : "+pc.getIdentifer());
						ResultSet rs = stmt.executeQuery(sSql);
		
						if (rs.next())
						{
							String sPwd = rs.getString(1);
//System.out.println("password : "+sPwd);
							pc.setPassword(sPwd);
						}
						rs.close();
//						if (pc.getIdentifer().equalsIgnoreCase("user")) 
//						{
//							pc.setPassword("password");
//						}
					}
					else
					{
/*
						System.out.println("callbacks[i] is " + callbacks[i].getClass().getName());
						System.out.println("callbacks[i]" + callbacks[i]);
						System.out.println("Callback is NOT a WSCallback");
						System.out.flush();
*/
						throw new UnsupportedCallbackException(callbacks[i], "Unrecognized Callback");
					}
				}
			} 
			catch (SQLException ex) 
			{ 
				throw ex; 
			}
			finally 
			{ 
				if (stmt!=null) stmt.close(); 
			}
		}
		catch (SQLException ex) 
		{ 
			logger.error("Exception: ",ex);
			throw new UnsupportedCallbackException(callbacks[i], "Callback Error" + ex.toString());
		}
		finally 
		{ 
			if ( conn != null ) cp.free(conn); 
		}
	}
}







