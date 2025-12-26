package com.britemoon.cps.imc;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.util.Vector;
import org.apache.log4j.*;

public class Services
{
	private static Logger logger = Logger.getLogger(Services.class.getName());
	public static String m_sRetrieveSql =
		"EXEC usp_cimc_services_get @service_type_id=?, @mod_inst_id=?, @cust_id=?";
	
	public static String getRetrieveSql() { return m_sRetrieveSql; }

	// === === ===

	public static Vector getByType(int iServiceType) throws SQLException
	{
		return get(iServiceType, null, null);
	}

	public static Vector getByModInst(int iServiceType, String sModInstId) throws SQLException
	{
		return get(iServiceType, sModInstId, null);
	}
	
	public static Vector getByCust(int iServiceType, String sCustId) throws SQLException
	{
		return get(iServiceType, null, sCustId);
	}
	//release 5.9 xxxPV[all functions] added for retrieving delivery tracker xml from PV
	public static Vector getByCustPV(int iServiceType, String sCustId,String sRequest) throws SQLException
	{
		return getPV(iServiceType, null, sCustId,sRequest);
	}
	
	private static Vector get(int iServiceType, String sModInstId, String sCustId)
		throws SQLException
	{
		Vector vServices = new Vector();

		String s_type_id = null;
		String s_mod_inst_id = null;
		String s_cust_id = null;
		
		String s_protocol = null;
		String s_host = null;	
		String s_port = null;
		String s_path = null;
		
		// === === ===
	
		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection("Services.get()");
			
			PreparedStatement pstmt = null;
			try
			{
				pstmt = conn.prepareStatement(getRetrieveSql());

				pstmt.setInt(1, iServiceType);
				pstmt.setString(2, sModInstId);
				pstmt.setString(3, sCustId);
				
				ResultSet rs = pstmt.executeQuery();

				while (rs.next())
				{
					Service s = new Service();
					
					s.s_type_id = rs.getString(1);
					s.s_mod_inst_id = rs.getString(2);
					s.s_cust_id = rs.getString(3);
				
					s.s_protocol = rs.getString(4);
					s.s_host = rs.getString(5);
					s.s_port = rs.getString(6);
					s.s_path = rs.getString(7);

					vServices.add(s);
				}
				rs.close();
			}
			catch(SQLException sqlex) { throw sqlex; }
			finally { if(pstmt != null) pstmt.close(); }
		}
		catch(SQLException sqlex) { throw sqlex; }
		finally { if(conn != null) cp.free(conn); }
		
		return vServices;
	}
	
	private static Vector getPV(int iServiceType, String sModInstId, String sCustId,String sRequest)
	throws SQLException
{
	Vector vServices = new Vector();

	String s_type_id = null;
	String s_mod_inst_id = null;
	String s_cust_id = null;
	
	String s_protocol = null;
	String s_host = null;	
	String s_port = null;
	String s_path = null;
	
	// === === ===

	ConnectionPool cp = null;
	Connection conn = null;
	try
	{
		cp = ConnectionPool.getInstance();			
		conn = cp.getConnection("Services.get()");
		
		PreparedStatement pstmt = null;
		try
		{
			pstmt = conn.prepareStatement(getRetrieveSql());

			pstmt.setInt(1, iServiceType);
			pstmt.setString(2, sModInstId);
			pstmt.setString(3, sCustId);
			
			ResultSet rs = pstmt.executeQuery();

			while (rs.next())
			{
				Service s = new Service();
				
				s.s_type_id = rs.getString(1);
				s.s_mod_inst_id = rs.getString(2);
				s.s_cust_id = rs.getString(3);
			
				s.s_protocol = rs.getString(4);
				s.s_host = rs.getString(5);
				s.s_port = rs.getString(6);
				s.s_path = rs.getString(7);
				s.s_path = s.s_path + sRequest;

					vServices.add(s);
				}
				rs.close();
			}
			catch(SQLException sqlex) { throw sqlex; }
			finally { if(pstmt != null) pstmt.close(); }
		}
		catch(SQLException sqlex) { throw sqlex; }
		finally { if(conn != null) cp.free(conn); }
		
		return vServices;
	}
}
