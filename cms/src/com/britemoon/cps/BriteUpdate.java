package com.britemoon.cps;

import java.sql.*;
import java.util.logging.Logger;

public class BriteUpdate
{
	private static Logger logger = Logger.getLogger(BriteUpdate.class.getName());

	final public static int executeUpdate(String sSql) throws SQLException
	{
		int iReturnCode = 0;
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection("BriteUpdate.executeUpdate()");
			iReturnCode = executeUpdate(sSql, conn);
		}
		catch(SQLException ex) { throw ex; }
		finally { if (conn != null) cp.free(conn); }
		
		return iReturnCode;
	}
	
	final public static int executeUpdate(String sSql, Connection conn) throws SQLException
	{
		int iReturnCode = 0;
		Statement stmt = null;
		try
		{
			stmt = conn.createStatement();
			iReturnCode = stmt.executeUpdate(sSql);
		}
		catch(SQLException ex) { throw ex; }
		finally { if(stmt != null) stmt.close(); }
		return iReturnCode;
	}
}
