package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import javax.mail.*;
import javax.mail.internet.*;
import java.net.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class UserNotifyTask extends BriteTask
{
	private User m_Usr = null;
	private ServletContext m_Context = null;
	private static Logger logger = Logger.getLogger(UserNotifyTask.class.getName());
	public UserNotifyTask(String sUserId, ServletContext context) throws Exception
	{
		m_Context = context;
		User usr = new User(sUserId);
		init(usr);
	}
		
	public UserNotifyTask(User usr)
	{
		init(usr);
	}
	
	private void init(User usr)
	{
		m_Usr = usr;
		
		// === === ===
		
		setTaskName("UserNotifyTask");
		
		setCustId(m_Usr.s_cust_id);
		setIdName("User");
		setId(m_Usr.s_user_id);
		setStringComment(m_Usr.s_user_name + " " + m_Usr.s_last_name);

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		String sUserId = m_Usr.s_user_id;
		logger.info(this + " user_id = " + sUserId + " started at " + new java.util.Date());
		startStatic(sUserId);
		logger.info(this + " user_id = " + sUserId + " finished at " + new java.util.Date());
	}
	
	public void startStatic(String sUserId) throws Exception
	{
		String s_email_to = "";
		String s_email_from = "";
		String s_pass_exp_date = "";
		String s_cps_url = "";
		String s_new_notify_date = "";
		String s_remaining_days = "";
		
		Properties p_Props = null;
		CustUiSettings cui = new CustUiSettings(m_Usr.s_cust_id);
		p_Props = UIEnvironment.loadProps(m_Context, cui.s_config_file);
		
		s_email_to = m_Usr.s_email;
		s_email_from = p_Props.getProperty("from_address");
		s_remaining_days = m_Usr.remainingPassDays();
		
		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			Statement stmt  = null;
			ResultSet rs = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("UserNotifyTask");

			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT isNULL(CONVERT(VARCHAR(32), pass_exp_date, 100), 'Unknown'), GETDATE() as 'exp1'" +
					" FROM ccps_user u" +
					" WHERE	u.user_id = '" + sUserId + "'";
					
				rs = stmt.executeQuery(sSql);

				while (rs.next())
				{
					s_pass_exp_date = rs.getString(1);
					s_new_notify_date = rs.getString(2);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) { logger.error("Exception: ", ex);}
		finally { if (conn!=null) cp.free(conn); }
		
		Vector services = com.britemoon.cps.imc.Services.getByCust(ServiceType.CCPS_CUST_LOGIN, m_Usr.s_cust_id);
		com.britemoon.cps.imc.Service service = (com.britemoon.cps.imc.Service) services.get(0);
		
		URL u = null;
		u = service.getURL();
		s_cps_url = u.toString();
		
		Properties props = new Properties();
		props.put("mail.smtp.host", Registry.getKey("mail_smtp_host"));
		Session s = Session.getInstance(props,null);
		
		logger.info("UserNotifyTask >> SMTP Info Set");
		
		String sEmailText = "<html><head></head><body>\n";
		sEmailText += "<style type=text/css>\n";
		sEmailText += "TABLE, TD { font-family:Verdana; font-size:8pt; }\n";
		sEmailText += "TH { align:left; text-align:left; background-color:#3E3E87; color:#FFFFFF; font-family:Verdana; font-size:8pt; }\n";
		sEmailText += "</style>\n";
		sEmailText += "<table cellspacing=0 cellpadding=3 border=0>\n";
		sEmailText += "<tr><th colspan=2><b>Password Expiration Notification</b></th></tr>\n";
		sEmailText += "<tr><td colspan=2>Your password is about to expire. Please log in to your email marketing system and change your password.</td></tr>\n";
		sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n";
		sEmailText += "<tr><th colspan=2>Important Info</th></tr>\n";
		sEmailText += "<tr><td><b>Password Expiration Date:</b></td><td>" + s_pass_exp_date + "</td></tr>\n";
		sEmailText += "<tr><td><b>Days Remaining:</b></td><td>" + s_remaining_days + "</td></tr>\n";
		sEmailText += "<tr><td><b>Log In URL:</b></td><td>" + s_cps_url + "</td></tr>\n";
		sEmailText += "<tr><td colspan=2>&nbsp;</td></tr></table></body></html>\n";
		
		logger.info("UserNotifyTask >> EMail HTML Built");
		
		MimeMessage message = new MimeMessage(s);
		
		logger.info("UserNotifyTask >> Message Created");
		
		InternetAddress from = new InternetAddress(s_email_from);
		message.setFrom(from);
		
		logger.info("UserNotifyTask >> From Address Set");
		
		InternetAddress to = new InternetAddress(s_email_to);
		message.addRecipient(Message.RecipientType.TO, to);
		
		logger.info("UserNotifyTask >> To Address Set");
		
		String subject = "Password Expiration Alert";
		message.setSubject(subject);
		message.setContent(sEmailText, "text/html");
		
		logger.info("UserNotifyTask >> Subject and Content Set");
		
		Transport.send(message);
		
		logger.info("UserNotifyTask >> Message Sent");
		
		String sSql =
			" UPDATE ccps_user" +
			" SET pass_notify_date = GETDATE()" + 
			" WHERE user_id = '" + m_Usr.s_user_id + "'";
		BriteUpdate.executeUpdate(sSql);
		
		logger.info("UserNotifyTask >> User Updated");
	}
}
