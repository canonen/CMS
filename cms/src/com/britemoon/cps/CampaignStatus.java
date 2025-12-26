package com.britemoon.cps;

import java.io.StringWriter;

final public class CampaignStatus
{
	final public static int DRAFT 				= 0;
	final public static int PENDING_EDITS 	= 5;   // approval has been requested for the campaign.  Approval is needed before it can be sent to RCP.
	final public static int PENDING_APPROVAL 	= 7;   // approval has been requested for the campaign.  Approval is needed before it can be sent to RCP.
	final public static int SENT_TO_RCP 		= 10;
	final public static int RECIP_LIST_CREATED  = 15; // rque_message table was populated with recip ids
	final public static int READY_TO_BE_QUEUED 	= 20; // rque_msg_cont table was populated with cont ids
	final public static int RECIPS_QUEUED		= 30; // rque_msg_xml table was populated with xml

	final public static int JTK_SETUP_COMPLETE	= 40;
	final public static int READY_TO_SEND		= 50; // cps done with jtk, inb, mailer setup
	final public static int BEING_PROCESSED		= 55; // sending is going on
	final public static int WAITING				= 57; // periodic (S2F,AR) campaign is waiting to be started again
	final public static int DONE				= 60;

	final public static int ERROR				= 70;
	final public static int ERROR_ON_QUEUING	= 72;
	final public static int ERROR_ON_CHUNK		= 76;
	final public static int CANCELLED			= 80;
	final public static int DELETED		        = 90;

	// === === ===

	public static String getDisplayName(int iCampStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iCampStatus)
		{
			case DRAFT:					sDisplayName = "Draft"; break;
			case PENDING_EDITS:		sDisplayName = "Pending Edits"; break;
			case PENDING_APPROVAL:		sDisplayName = "Pending Approval"; break;
			case SENT_TO_RCP:			sDisplayName = "Preprocessing Target Group"; break;
			case RECIP_LIST_CREATED:	sDisplayName = "Recipient List Created"; break;
			case READY_TO_BE_QUEUED:	sDisplayName = "Waiting To Be Queued"; break;
			case RECIPS_QUEUED:			sDisplayName = "Queued"; break;

			case JTK_SETUP_COMPLETE:	sDisplayName = "Links Setup"; break;
			case READY_TO_SEND:			sDisplayName = "Ready To Send"; break;
			case BEING_PROCESSED:		sDisplayName = "Sending"; break;
			case WAITING:				sDisplayName = "Waiting"; break;
			case DONE:					sDisplayName = "Done"; break;

			case ERROR:					sDisplayName = "Error"; break;
			case ERROR_ON_QUEUING:		sDisplayName = "Error on Queuing"; break;
			case ERROR_ON_CHUNK:		sDisplayName = "Error on Chunk"; break;
			case CANCELLED:				sDisplayName = "Cancelled"; break;			
			case DELETED:				sDisplayName = "Deleted"; break;			
		}

		return sDisplayName;
	}
	// === === ===

	public static String toHtmlOptions()
	{
		return toHtmlOptions(-1);
	}

	public static String toHtmlOptions(String sSelected)
	{
		int iSelected = -1;
		try	{ iSelected = Integer.parseInt(sSelected); }
		catch(Exception ex) {}
		return toHtmlOptions(iSelected);
	}
	
	public static String toHtmlOptions(int iSelected)
	{
		StringWriter sw = new StringWriter();

		sw.write("\r\n");
		sw.write("<OPTION value=\"" + DRAFT + "\"" + ((iSelected == DRAFT)?" selected":"") + ">Draft</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SENT_TO_RCP + "\"" + ((iSelected == SENT_TO_RCP)?" selected":"") + ">Preprocessing Target Group</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + RECIP_LIST_CREATED + "\"" + ((iSelected == RECIP_LIST_CREATED)?" selected":"") + ">Recipient List Created</OPTION>\r\n");
		sw.write("<OPTION value=\"" + READY_TO_BE_QUEUED + "\"" + ((iSelected == READY_TO_BE_QUEUED)?" selected":"") + ">Waiting To Be Queued</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + RECIPS_QUEUED + "\"" + ((iSelected == RECIPS_QUEUED)?" selected":"") + ">Queued</OPTION>\r\n");

		sw.write("<OPTION value=\"" + JTK_SETUP_COMPLETE + "\"" + ((iSelected == JTK_SETUP_COMPLETE)?" selected":"") + ">Links Setup</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + READY_TO_SEND + "\"" + ((iSelected == READY_TO_SEND)?" selected":"") + ">Ready To Send</OPTION>\r\n");
		sw.write("<OPTION value=\"" + BEING_PROCESSED + "\"" + ((iSelected == BEING_PROCESSED)?" selected":"") + ">Being Processed</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + WAITING + "\"" + ((iSelected == WAITING)?" selected":"") + ">Waiting</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DONE + "\"" + ((iSelected == DONE)?" selected":"") + ">Done</OPTION>\r\n");		

		sw.write("<OPTION value=\"" + ERROR + "\"" + ((iSelected == ERROR)?" selected":"") + ">Error</OPTION>\r\n");
		sw.write("<OPTION value=\"" + ERROR_ON_QUEUING + "\"" + ((iSelected == ERROR_ON_QUEUING)?" selected":"") + ">Error on Queuing</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + ERROR_ON_CHUNK + "\"" + ((iSelected == ERROR_ON_CHUNK)?" selected":"") + ">Error on Chunk</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CANCELLED + "\"" + ((iSelected == CANCELLED)?" selected":"") + ">Cancelled</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + DELETED + "\"" + ((iSelected == DELETED)?" selected":"") + ">Deleted</OPTION>\r\n");		

		return sw.toString();
	}
}

