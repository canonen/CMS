package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import org.apache.log4j.*;

/* this class will run a thread to capture InputStream in a StringBuffer */
class StreamGobbler extends Thread
{
    InputStream is;
    StringBuffer sb;
    private static Logger logger = Logger.getLogger(StreamGobbler.class.getName());

    StreamGobbler(InputStream is)
    {
        this.is = is;
		this.sb = new StringBuffer();
    }
    
    public void run()
    {
        try {
			/* create reader */
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader br = new BufferedReader(isr);
			/* capture data */
            String line=null;
            while ( (line = br.readLine()) != null) {
				sb.append(line + "\n");
			}
		} catch (IOException ioe) {
			logger.error("Exception: ", ioe);  
		}
    }
	
	/* return the captured data */
	public StringBuffer getBuffer()
	{
		return this.sb;
	}

}

/* this class will run a thrad to push String data to a OutputStream */
class StreamBlower extends Thread
{
    OutputStream os;
	String s;
    private static Logger logger = Logger.getLogger(StreamBlower.class.getName());
    StreamBlower(OutputStream os, String s)
    {
        this.os = os;
        this.s = s;
    }
    
    public void run()
    {
        try	{
			/* create writer */
			OutputStreamWriter osw = new OutputStreamWriter(os);
			BufferedWriter bw = new BufferedWriter(osw);
			/* create reader */
			StringReader sr = new StringReader(s);
			BufferedReader br = new BufferedReader(sr);
			/* copy reader to writer */
            String line=null;
            while ( (line = br.readLine()) != null) {
				bw.write(line, 0, line.length());
				bw.newLine();
				bw.flush();				
			}
			bw.close();
		} catch (IOException ioe) {
			logger.error("Exception: ", ioe);  
		}
    }
}

/* 

	This class will execute an external command (spamassassin 2.6.1) using the test mode (-t) 
	to check for spam. Email is being passed in as String and result is analysized and parsed.
   
   	This class does lots of text manipulations based on the expected output format of 
	spamassassin 2.6.1. If a different version of the software is installed, it may be necessary
	to change some of the text manipulation logic.

	In general, the spamassassin will return the spam status, score and test performed via the
	X-Spam-XXX headers.
	
	In test mode, it will also return a detailed description of each test performed and
	the scores assigned. This is found in the email body in the form of:

** start of verbatim text of a spam details *
Content analysis details:   (8.8 points, 5.0 required)

 pts rule name              description
---- ---------------------- --------------------------------------------------
 0.3 NO_REAL_NAME           From: does not include a real name
 0.3 TO_MALFORMED           To: has a malformed address
 2.8 SUBJ_VIAGRA            Subject includes "viagra"
 1.9 BEST_PORN              BODY: Possible porn - Best, Largest, Most Porn
 2.4 FREE_PORN              BODY: Possible porn - Free Porn
 1.1 NO_DNS_FOR_FROM        Domain in From header has no MX or A DNS records


** end of verbatim text of a spam details *
		
	Below are two samples of expected output format of a spam and non-spam messages:

** start of verbatim text of a spam email **
Received: from localhost [127.0.0.1] by DEV009
        with SpamAssassin (2.61 1.212.2.1-2003-12-09-exp);
        Tue, 20 Jan 2004 18:18:50 -0500
From: admin@localhost
To: you@localhost
Subject: viagra for sale
Date: Wed, 16 Jan 2004 12:34:56 +0500
X-Spam-Flag: YES
X-Spam-Checker-Version: SpamAssassin 2.61 (1.212.2.1-2003-12-09-exp) on DEV009
X-Spam-Status: Yes, score=8.8 required=5.0 tests=BEST_PORN,FREE_PORN,
        NO_DNS_FOR_FROM,NO_REAL_NAME,SUBJ_VIAGRA,TO_MALFORMED autolearn=no
        version=2.61
X-Spam-Level: ********
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="----------=_400DB75A.4A500000"

This is a multi-part message in MIME format.

------------=_400DB75A.4A500000
Content-Type: text/plain
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Spam detection software, running on the system "DEV009", has
identified this incoming email as possible spam.  The original message
has been attached to this so you can view it (if it isn't spam) or block
similar future email.  If you have any questions, see
admin@britemoon.com for details.

Content preview:  We sell cheap viagra and offer free porn services!
  [...]

Content analysis details:   (8.8 points, 5.0 required)

 pts rule name              description
---- ---------------------- --------------------------------------------------
 0.3 NO_REAL_NAME           From: does not include a real name
 0.3 TO_MALFORMED           To: has a malformed address
 2.8 SUBJ_VIAGRA            Subject includes "viagra"
 1.9 BEST_PORN              BODY: Possible porn - Best, Largest, Most Porn
 2.4 FREE_PORN              BODY: Possible porn - Free Porn
 1.1 NO_DNS_FOR_FROM        Domain in From header has no MX or A DNS records



------------=_400DB75A.4A500000
Content-Type: message/rfc822; x-spam-type=original
Content-Description: original message before SpamAssassin
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

From: admin@localhost
To: you@localhost
Date: Wed, 16 Jan 2004 12:34:56 +0500
Subject: viagra for sale

We sell cheap viagra and offer free porn services!


------------=_400DB75A.4A500000--
** end of verbatim text **

** start of verbatim text of a non-spam email **	
From: admin@localhost
To: you@localhost
Date: Wed, 16 Jan 2004 12:34:56 +0500
Subject: hello
X-Spam-Checker-Version: SpamAssassin 2.61 (1.212.2.1-2003-12-09-exp) on DEV009
X-Spam-Status: No, score=4.4 required=5.0 tests=NO_DNS_FOR_FROM,NO_REAL_NAME,
        SUB_HELLO,TO_MALFORMED autolearn=no version=2.61
X-Spam-Level: ****

We just want to say hello

Spam detection software, running on the system "DEV009", has
identified this incoming email as possible spam.  The original message
has been attached to this so you can view it (if it isn't spam) or block
similar future email.  If you have any questions, see
admin@britemoon.com for details.

Content preview:  We just want to say hello [...]

Content analysis details:   (4.4 points, 5.0 required)

 pts rule name              description
---- ---------------------- --------------------------------------------------
 0.3 NO_REAL_NAME           From: does not include a real name
 2.7 SUB_HELLO              Subject starts with "Hello"
 0.3 TO_MALFORMED           To: has a malformed address
 1.1 NO_DNS_FOR_FROM        Domain in From header has no MX or A DNS records


** end of verbatim text **

	
    */

public class SpamFilter
{
	String 		 _from;		// email from
	String 		 _to;		// email to	
	String 		 _subject;	// email subject
	String 		 _body;		// email body
	String	 	 _format;	// email format
	private static Logger logger = Logger.getLogger(SpamFilter.class.getName());
	
	int 	_errorCode;
	String 	_status;
	String 	_explanation;
	boolean _isSpam;
	String 	_hits;
	String 	_required;
	
	public SpamFilter() 
	{
		_from = new String("admin@britemoon.com");
		_to = new String("user@britemoon.com");
		_subject = new String("content scoring");
		_body = new String("");
		_format = new String("text");
		_errorCode = 0;
		_status = new String("");
		_explanation = new String("");
		_isSpam = false;
		_hits = new String("0.0");
		_required = new String("5.0");
	}
	
	public void from (String from)
	{
		if (from != null) _from = from;
		{
			_from = from;
		}
	}
	
	public void to (String to)
	{
		if (to != null) 
		{
			_to = to;	
		}
	}
	
	public void subject (String subject)
	{
		if (subject != null) 
		{
			_subject = subject;
		}
	}
	
	public void body (String body)
	{
		if (body != null) 
		{
			_body = body;
		}
	}
	
	public void format (String format)
	{
		if (format != null)
		{
			_format = format;
		}
	}
	
	/* check for spam */
	public void checkForSpam()
	{
        try	{
			
			/* set up external command that works with Windows 2000, NT, XP */
            String[] cmd = new String[3];
			cmd[0] = "cmd.exe" ;
			cmd[1] = "/C" ;
			String sa_cmd = Registry.getKey("spamassassin_cmd");
			if (sa_cmd == null || sa_cmd.length() == 0) {
				sa_cmd = "spamassassin -L -t";
			}
			cmd[2] = sa_cmd;
			
			/* get Runtime and set up i/o threads */
            Runtime rt = Runtime.getRuntime();
            Process proc = rt.exec(cmd);

			/* assemble email message */
			StringBuffer message = new StringBuffer();
			message.append("From: " + _from + "\n");
			message.append("To: " + _to + "\n");
			SimpleDateFormat formatter = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z");
			java.util.Date d = new java.util.Date();
			message.append("Date: " + formatter.format(d) + "\n");
			message.append("Subject:" + _subject + "\n");
			message.append("\n\n");
			message.append(_body + "\n");
			
			//System.out.println("message =\n" + message.toString());
			/* our input is the Runtime's output */
            StreamBlower  inputBlower   = new StreamBlower (proc.getOutputStream(), message.toString());
			/* our output is the Runtime's input */
            StreamGobbler outputGobbler = new StreamGobbler(proc.getInputStream());
            
            /* kick off I/O threads */
            inputBlower.start();
            outputGobbler.start();
            
            /* wait for command completion and check error code */
			_errorCode = proc.waitFor();
			
			// get output and check for spam
			StringBuffer osb = outputGobbler.getBuffer();
			String info = osb.toString();
			//System.out.println("info =\n" + info);
			int start = info.indexOf("X-Spam-Status:");
			int end = info.indexOf("X-Spam-Level:");
			String status = new String();
			if (start > 0 && end > 0) {
				status = info.substring(start+15,end);
				_status = status;
				//System.out.println("Status: " + status);
				start = status.indexOf("score=");
				end = status.indexOf(" required");
				if (start > 0 && end > 0) 
				{
					_hits = status.substring(start+6,end);
				}
				//System.out.println("Hits: " + _hits);
				start = status.indexOf("required=");
				end = status.indexOf(" tests");
				if (start > 0 && end > 0) 
				{
					_required = status.substring(start+9,end);
				}
				//System.out.println("Required: " + _required);				
				if (info.indexOf("X-Spam-Status: Yes") > 0) {
					_isSpam = true;
				}
				//System.out.println("Explanation:");
				start = info.indexOf("Content analysis details:");
				if (start > 0) {
					String analysis = info.substring(start);
					//System.out.println(analysis);
					start = analysis.indexOf("\n pts ");
					if (start > 0) 
					{
						analysis = analysis.substring(start);
					}
					end = analysis.indexOf("\n\n");
					//System.out.println(end);
					if (end > 0) {
						String explanation = analysis.substring(0, end);
						//System.out.println(explanation);							
						_explanation = explanation;
					}
				}
			}
        } 
		catch (Throwable t) {
            logger.error("Exception: ", t);
		}
    }
	
	public String getBriteReport()
	{
		if (_explanation == null) 
		{
			return new String("");
		}
		int idx = 0;
		String text = _explanation + "\n";
		/* remove heading rows (first two) */
		idx = text.indexOf("----\n");
		if (idx > 0) 
		{
			text = text.substring(idx+5);
		}
		/* now text should be formated like this:
		    9.99 ABC DEF
			9.99 XXX XYZ
		 */ 
		String line = new String("");
		String score = new String("");
		String rule = new String("");
		String display = new String("");
		String descrip = new String("");
		StringBuffer report = new StringBuffer();
		idx = text.indexOf("\n");
		while (idx > 0) 
		{
			line = text.substring(0, idx);
			text = text.substring(idx+1);
			line = line.trim();
			idx = line.indexOf(" ");
			if (idx > 0) 
			{
				score = line.substring(0, idx);
				line = line.substring(idx);
				line = line.trim();
				idx = line.indexOf(" ");
				if (idx > 0) 
				{
					rule = line.substring(0, idx);
					descrip = line.substring(idx);
				}
			}
			
			try 
			{
				//System.out.println("rule name = " + rule + " , score = " + score);
				if (!score.equals("0.0"))
				{		
					display = getBriteExplanation(rule, descrip);
					//System.out.println("display = " + display);	
					if (display != null) 
					{
						report.append("<tr><td>" + score + "</td>" + display + "</tr>");
					}
					else 
					{
						report.append("<tr><td>" + score + "</td><td>" + rule + "</td><td>&nbsp;</td></tr>");
					}
				}
			}
			catch (SQLException sqle) 
			{
			}		
			idx = text.indexOf("\n");
		}
		return report.toString();
		
	}
	
	/* DB Methods */
	private String getBriteExplanation(String sRuleName, String descrip) throws SQLException
	{
		PreparedStatement	pstmt			= null;
	    ResultSet			rs				= null; 
	    ConnectionPool		cp				= null;
	    Connection			conn 			= null;
		
		int    nReturnCode = 0;
		
		String sDisplayName = "";
		String sDisplayDescrip = "";
		
		if (sRuleName == null) 
		{
			return new String("");
		}
		
		try 
		{
			cp = ConnectionPool.getInstance();
	        conn = cp.getConnection("CcntBriteScoreMap");

			String sRetrieveSql = "SELECT display_name, display_descrip " + 
				"FROM ccnt_brite_score_rule WHERE rule_name = ?";
			
	        //System.out.println("SQL to retrieve brite score rule:");
	        //System.out.println(sRetrieveSql);

	        pstmt = conn.prepareStatement(sRetrieveSql);
	        pstmt.setString(1, sRuleName);
	        
	        rs = pstmt.executeQuery();
	        if (rs.next())
	        {
	        	sDisplayName = rs.getString("display_name");
			   	sDisplayDescrip = rs.getString("display_descrip");
	        }
			else 
			{
				sDisplayName = sRuleName;
				if (descrip != null && !descrip.equals("")) 
				{
					sDisplayDescrip = descrip;
				}
				else 
				{
					sDisplayDescrip = "Description not available";
				}
			}
	        rs.close();
	           
		}
		catch (SQLException sqle) {
	        //System.out.println("SQL Exception thrown." + sqle);
	     	logger.error("Exception: ", sqle);
			throw sqle;   
	    }
		catch (Exception e) 
		{
		    logger.error("Exception: ", e);
			//System.out.println("Exception thrown.");
		}
		finally {
	        if (pstmt != null) {
	        	pstmt.close();
	        }
	        cp.free(conn);
	    }
		
		return new String("<td>" + sDisplayName + "</td><td>" + sDisplayDescrip + "</td>");
	}
	
	public int errorCode()
	{
		return _errorCode;
	}
	
	public String status()
	{
		return _status;
	}

	public String explanation()
	{
		return _explanation;
	}
	
	public boolean isSpam()
	{
		return _isSpam;
	}
	
	public String hits()
	{
		return _hits;
	}
	
	public String required()
	{
		return _required;
	}
	
}
