package com.britemoon.cps;

import java.sql.Connection;
import java.sql.PreparedStatement;
import org.apache.log4j.*;
import javax.servlet.http.HttpSession;

public class SessionMonitor
{
	private static Logger logger = Logger.getLogger(SessionMonitor.class.getName());
	private static String sSql =
		" EXEC usp_cadm_session_log_save" +
		" @session_id=?," +
		" @cust_id=?," +
		" @cust_name=?," +
		" @user_id=?," +
		" @user_name=?," +
		" @last_url=?," +
		" @phone=?";		

	public static void update(HttpSession session)
	{
		update(session, null);
	}
	
	public static void update(HttpSession session, String sLastUrl)
	{
		if(session == null) return;
		
		Customer cust = (Customer) session.getAttribute("cust");
		User user = (User) session.getAttribute("user");

		if((cust == null) || (user == null)) return;


		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("SessionMonitor.update()");
			
			PreparedStatement pstmt = null;
			try
			{
				pstmt = conn.prepareStatement(sSql);
				
				pstmt.setString(1, session.getId());
				pstmt.setString(2, cust.s_cust_id);
				
				if(cust.s_cust_name == null) pstmt.setString(3, cust.s_cust_name);
				else pstmt.setBytes(3, cust.s_cust_name.getBytes("UTF-8"));
				
				pstmt.setString(4, user.s_user_id);
				
				if(user.s_user_name == null) pstmt.setString(5, user.s_user_name);
				else pstmt.setBytes(5, user.s_user_name.getBytes("UTF-8"));

				pstmt.setString(6, sLastUrl);

				if(user.s_phone == null) pstmt.setString(7, user.s_phone);
				else pstmt.setBytes(7, user.s_phone.getBytes("UTF-8"));
				
				pstmt.executeUpdate();
			}
			catch(Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch(Exception ex) { logger.error("Exception: ", ex);}
		finally { if (conn!=null) cp.free(conn); }
	}
}
