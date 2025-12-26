package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;

import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.*;

import org.apache.log4j.*;

public class SimpleMailer
{
	private static Logger logger = Logger.getLogger(SimpleMailer.class.getName());
	
	public SimpleMailer() 
	{
	}
	
	public boolean sendText(String mailFrom, String mailTo, String subj, String body, String pviq)
	{
		return sendSimple(mailFrom, mailTo, subj, body, pviq, "text/plain");
	}
	
	public boolean sendHtml(String mailFrom, String mailTo, String subj, String body, String pviq)
	{
		return sendSimple(mailFrom, mailTo, subj, body, pviq, "text/html");
	}
	
	public boolean sendBoth(String mailFrom, String mailTo, String subj, String textBody, String htmlBody, String pviq)
	{
		return sendMultipart(mailFrom, mailTo, subj, textBody, htmlBody, pviq);
	}
	
	private boolean sendSimple (String mailFrom, String mailTo, String subj, String body, String pviq, String contentType)
	{
		boolean ok = false;
		try {			
			Properties props = new Properties();
			String sHost = Registry.getKey("mail_smtp_host");
			props.put("mail.smtp.host", sHost);
			String sPort = Registry.getKey("mail_smtp_port");
			if (sPort != null) {
				props.put("mail.smtp.port", sPort);	
			}
			Session session = Session.getInstance(props,null);
			MimeMessage message = new MimeMessage(session);
		
			message.addHeader("X-PVIQ", pviq);
		
			message.setFrom(new InternetAddress(mailFrom));
		
			String[] sRecipients = mailTo.split(",");
			for (int i=0; i<sRecipients.length; i++) {
				message.addRecipient(Message.RecipientType.TO, new InternetAddress(sRecipients[i]));
			}
		
			message.setSubject(subj);
		
			message.setContent(body, contentType);
			
			Transport.send(message);
			
			ok = true;
		}
		catch (Exception e) {
			logger.info("Error sending smtp email to " + mailTo);
			logger.error("Exception: " , e);
		}
		return ok;
	}
	
	private boolean sendMultipart(String mailFrom, String mailTo, String subj, String textBody, String htmlBody, String pviq)
	{
		boolean ok = false;
		try {			
			Properties props = new Properties();
			String sHost = Registry.getKey("mail_smtp_host");
			props.put("mail.smtp.host", sHost);
			Session session = Session.getInstance(props,null);
			MimeMessage message = new MimeMessage(session);
		
			message.addHeader("X-PVIQ", pviq);
		
			message.setFrom(new InternetAddress(mailFrom));
		
			String[] sRecipients = mailTo.split(",");
			for (int i=0; i<sRecipients.length; i++) {
				message.addRecipient(Message.RecipientType.TO, new InternetAddress(sRecipients[i]));
			}
		
			message.setSubject(subj);
		
			MimeMultipart multipart = new MimeMultipart();
			multipart.setSubType("alternative");
			
			MimeBodyPart htmlBodyPart = new MimeBodyPart();
			htmlBodyPart.setContent(htmlBody, "text/html");
			multipart.addBodyPart(htmlBodyPart);
			
			MimeBodyPart textBodyPart = new MimeBodyPart();
			textBodyPart.setContent(textBody, "text/plain");
			multipart.addBodyPart(textBodyPart);
			
			message.setContent(multipart);
			
			Transport.send(message);
			
			ok = true;
		}
		catch (Exception e) {
			logger.info("Error sending smtp email to " + mailTo);
			logger.error("Exception: " , e);

		}
		return ok;
	}

}
