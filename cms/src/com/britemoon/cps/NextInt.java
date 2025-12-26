package com.britemoon.cps;

import java.sql.*;


public class NextInt
{
	final private static String sNextIntGetSql =
		" EXEC usp_ccps_next_int_get2 @cust_id=?, @increment=?";

	public static String get(String sCustId) throws SQLException
	{
		return get(sCustId, 1);
	}
	
	public static String get(String sCustId, int iIncrement) throws SQLException
	{
		String sNextInt = null;
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("NextInt.get()");

			PreparedStatement pstmt = null;
			try
			{
				pstmt = conn.prepareStatement(sNextIntGetSql);
				pstmt.setString(1, sCustId);
				pstmt.setInt(2, iIncrement);
				ResultSet rs = pstmt.executeQuery();

				if (rs.next()) sNextInt = rs.getString(1);
				rs.close();
			}
			catch(SQLException sqlex) { throw sqlex; }
			finally { if(pstmt != null) pstmt.close(); }
		}
		catch(SQLException sqlex) { throw sqlex; }
		finally { if(conn != null) cp.free(conn); }
		return sNextInt;
	}
}
