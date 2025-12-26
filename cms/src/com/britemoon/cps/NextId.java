package com.britemoon.cps;

import java.sql.*;

public class NextId
{
	final private static String sNextIdGetSql =
		" EXEC usp_ccps_next_id_get2 @cust_id=?, @type_id=?, @increment=?";

	public static String get(String sCustId , int iIdType) throws SQLException
	{
		return get(sCustId, iIdType, 1);
	}

	public static String get(String sCustId , int iIdType, int iIncrement) throws SQLException
	{
		String sNextId = null;
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("NextId.get()");

			PreparedStatement pstmt = null;
			try
			{
				pstmt = conn.prepareStatement(sNextIdGetSql);
				pstmt.setString(1, sCustId);
				pstmt.setInt(2, iIdType);
				pstmt.setInt(3, iIncrement);
				ResultSet rs = pstmt.executeQuery();

				if (rs.next()) sNextId = rs.getString(1);
				rs.close();
			}
			catch(SQLException sqlex) { throw sqlex; }
			finally { if(pstmt != null) pstmt.close(); }
		}
		catch(SQLException sqlex) { throw sqlex; }
		finally { if(conn != null) cp.free(conn); }
		return sNextId;
	}
}
