package com.britemoon.cps.wfl;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.imc.*;
import com.britemoon.cps.jtk.*;
import com.britemoon.cps.upd.*;
import com.britemoon.cps.tgt.*;

import java.sql.*;
import java.util.*;
import java.net.*;
import java.util.*;
import java.util.zip.*;
import java.util.regex.*;
import java.io.*;
import javax.mail.*;
import javax.mail.internet.*;
import org.w3c.dom.*;
import javax.servlet.http.HttpServletResponse;
import org.apache.log4j.*;

public class WorkflowEmailUtil
{
	private static Logger logger = Logger.getLogger(WorkflowEmailUtil.class.getName());
	public static void sendRequestorEmail(ApprovalRequest arRequest) throws Exception
	{
		/* sending email back to requestor after approval action has been submitted */
		try
		{
			Properties props = new Properties();
			String sHost = Registry.getKey("mail_smtp_host");
			// System.out.println("SMTP host to send email to requestor is:" + sHost);
			props.put("mail.smtp.host", sHost);
			Session s = Session.getInstance(props,null);

			User uRequestor 			= new User(arRequest.s_requestor_id);
			User uApprover 				= new User(arRequest.s_approver_id);
			ApprovalTask atApproval 	= new ApprovalTask(arRequest.s_aprvl_id);
			String sApprovalResponse 	= null, sResponseMsg = null;
			int iDispositionId 			= Integer.parseInt(arRequest.s_disposition_id);
			int iObjectType 			= Integer.parseInt(atApproval.s_object_type);

			if (iDispositionId == ApprovalDisposition.APPROVE)
			{
				sApprovalResponse = "approved";
				sResponseMsg = " has been approved";
			}
			else if (iDispositionId == ApprovalDisposition.REJECT)
			{
				sApprovalResponse = "rejected";
				sResponseMsg = " has been rejected";
			}
			else if (iDispositionId == ApprovalDisposition.EDITING)
			{
				sApprovalResponse = "Approver Making Edits";
				sResponseMsg = " is being edited by the approver";
			}

			MimeMessage message = new MimeMessage(s);

			InternetAddress from = new InternetAddress(uApprover.s_email);
			message.setFrom(from);

			// System.out.println("setting TO address for email to:"+uRequestor.s_email);
			InternetAddress to 	= new InternetAddress(uRequestor.s_email);
			message.addRecipient(Message.RecipientType.TO, to);

			// System.out.println("setting CC address for email to:"+uApprover.s_email);
			InternetAddress cc = new InternetAddress(uApprover.s_email);
			message.addRecipient(Message.RecipientType.CC, cc);

			String subject = "Approval Response - " + sApprovalResponse;
			// add object type name, object name, object ID

			message.setSubject(subject);

			String sEmailText = "<html><head></head><body>\n";
			sEmailText += "<style type=text/css>\n";
			sEmailText += "TABLE, TD { font-family:Verdana; font-size:8pt; }\n";
			sEmailText += "TH { align:left; text-align:left; background-color:#3E3E87; color:#FFFFFF; font-family:Verdana; font-size:8pt; }\n";
			sEmailText += "</style>\n";
			sEmailText += "<table cellspacing=0 cellpadding=3 border=0>\n";
			sEmailText += "<tr><th><b>Approval Response</b></th></tr>\n";

			sEmailText += "<tr><td>Your request for approval for " +
								ObjectType.getDisplayName(iObjectType) +
								" " + WorkflowUtil.getObjectName(iObjectType,atApproval.s_object_id) +
								sResponseMsg;

//			if (iObjectType == ObjectType.IMPORT && iDispositionId == ApprovalDisposition.REJECT)
//			{
//				sEmailText += " and the import has been rolled back.";
//			}

			sEmailText += "</td></tr>\n";

			if (arRequest.s_aprvl_comment != null)
			{
				sEmailText += "<tr><td>&nbsp;</td></tr>\n" +
								"<tr><th>Approver Comments</th></tr>\n" +
								"<tr><td>" +
								arRequest.s_aprvl_comment.replaceAll("\n", "<br>") +
								"</td></tr>\n";
			}

//			if (!(iObjectType == ObjectType.IMPORT && iDispositionId == ApprovalDisposition.REJECT))
//			{
				String sLinkURL = "";
				sLinkURL =
					WorkflowUtil.getApprovalUrl(Integer.parseInt(atApproval.s_object_type), atApproval.s_object_id, atApproval.s_cust_id, true) +
					URLEncoder.encode("&aprvl_request_id=" + arRequest.s_approval_request_id, "UTF-8");

				sEmailText += "<tr><td>&nbsp;</td></tr>\n" +
								"<tr><th>View " + ObjectType.getDisplayName(Integer.parseInt(atApproval.s_object_type)) + "</th></tr>\n" +
								"<tr><td>Login to the system, then copy and paste this into the browser:</td></tr>\n" +
								"<tr><td>" + sLinkURL + "</td></tr>\n";
//			}

			sEmailText += "<tr><td>&nbsp;</td></tr></table></body></html>\n";

			message.setContent(sEmailText, "text/html");

			Transport.send(message);
		}
		catch (Exception ex)
		{
			throw ex;
		}
	}

	public static void sendCampApprovalRequestEmail(String sAprvlRequestId, String sCampId) throws Exception
	{
		boolean bSamples = false;
		try
		{
			// System.out.println("in sendCampApprovalRequestEmail...camp_id:" + sCampId);
			ApprovalRequest arRequest 	= new ApprovalRequest(sAprvlRequestId);
			Campaign camp 				= new Campaign(sCampId);
			Customer cust = new Customer(arRequest.s_cust_id);

			// check for sampleset info
			CampSampleset cSet 			= new CampSampleset();
			cSet.s_camp_id 				= camp.s_origin_camp_id;

			if (cSet.retrieve() > 0)
				bSamples = true;

			// get statistics details
			CampStatDetails csds = new CampStatDetails();
			csds.s_camp_id = sCampId;
			csds.retrieve();
			Enumeration eDetails = csds.elements();

			Properties props = new Properties();
			String sHost = Registry.getKey("mail_smtp_host");
			props.put("mail.smtp.host", sHost);
			Session s = Session.getInstance(props,null);
			// System.out.println("SMTP host to send email to requestor is:" + sHost);

			User uRequestor = new User(arRequest.s_requestor_id);
			User uApprover = new User(arRequest.s_approver_id);

			MimeMessage message = new MimeMessage(s);

			InternetAddress from = new InternetAddress(uRequestor.s_email);
			message.setFrom(from);

			// System.out.println("setting To address for email to:"+uApprover.s_email);
			InternetAddress to = new InternetAddress(uApprover.s_email);
			message.addRecipient(Message.RecipientType.TO, to);

			// System.out.println("setting cc address for email to:"+uRequestor.s_email);
			InternetAddress cc = new InternetAddress(uRequestor.s_email);
			message.addRecipient(Message.RecipientType.CC, cc);

			if (camp.s_camp_name.indexOf("Sample -1") != -1)
				camp.s_camp_name = camp.s_camp_name.substring(0,camp.s_camp_name.indexOf("Sample -1") -2);

			String subject = "Request for Approval - Campaign: " + camp.s_camp_name;

			if (bSamples)
			{
				if (camp.s_sample_id == null)
				{
					// final campaign
					subject += " (final campaign of sampleset campaign)";
				}
				else
				{
					subject += " (all samples of sampleset campaign)";
				}
			}

			message.setSubject(subject);

			String sEmailText = "<html><head></head><body>\n" +
								"<style type=text/css>\n" +
								"TABLE, TD { font-family:Verdana; font-size:8pt; }\n" +
								"TH { align:left; text-align:left; background-color:#3E3E87; color:#FFFFFF; font-family:Verdana; font-size:8pt; }\n" +
								"</style>\n" +
								"<table cellspacing=0 cellpadding=3 border=0>\n" +
								"<tr><th colspan=2><b>Approval Request</b></th></tr>\n";

			sEmailText += "<tr><td colspan=2>Your approval has been requested for Campaign: " + camp.s_camp_name + "</td></tr>\n" +
							"<tr><td><nobr><b>Customer: </b></nobr></td><td>" + cust.s_cust_name + "</td></tr>\n" +
							"<tr><td><nobr><b>Requestor: </b></nobr></td><td>" + uRequestor.s_user_name + " " + uRequestor.s_last_name + " (" + uRequestor.s_email + ")</td></tr>\n" +
							"<tr><td><nobr><b>Request Date: </b></nobr></td><td>" + arRequest.s_request_date + "</td></tr>\n" +
							"<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2><b>Campaign Statistics:</b></th></tr>\n";

			if (!bSamples)
			{
				// Single or Final campaign
				sEmailText += "<tr><td colspan=2>\n" +
								"<table cellspacing=0 cellpadding=3 border=0>\n" +
								getSingleCalculations(camp,eDetails) +
								"</table></td></tr>";
			}
			else
			{
				sEmailText += "<tr><td colspan=2>\n" +
								"<table cellspacing=0 cellpadding=3 border=0>\n" +
								getSamplesetCalculations(camp,eDetails) +
								"</table></td></tr>";
			}

			sEmailText += "<tr><td colspan=2>(NOTE:  These statistics are a current snapshot.  The numbers may be different when the campaign is actually run)</td></tr>\n";

			if (arRequest.s_request_comment != null)
			{
				sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
								"<tr><th colspan=2>Requestor Comments</th></tr>\n" +
								"<tr><td colspan=2>" +
								arRequest.s_request_comment.replaceAll("\n", "<br>") +
								"</td></tr>\n";
			}

			String sLinkURL = "";
/*			sLinkURL = WorkflowUtil.getApprovalUrl(ObjectType.CAMPAIGN, sCampId, camp.s_cust_id, true) +
						URLEncoder.encode("&aprvl_request_id=" + arRequest.s_approval_request_id);

			sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2>Approval View of Campaign</th></tr>\n" +
							"<tr><td colspan=2>Login to the system, then copy and paste this into the browser:</td></tr>\n" +
							"<tr><td colspan=2>" + sLinkURL + "</td></tr>";
*/
			sLinkURL = "http://" + WorkflowUtil.getCustCPSHost(arRequest.s_cust_id) + "/ccps/ui/jsp/index.jsp?tab=Home&sec=4";

			sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2>All Pending Approval Assets</th></tr>\n" +
							"<tr><td colspan=2>Login to the system, then copy and paste this into the browser:</td></tr>\n" +
							"<tr><td colspan=2>" + sLinkURL + "</td></tr>";

			message.setContent(sEmailText, "text/html");

			Transport.send(message);

			java.util.Calendar cal = java.util.Calendar.getInstance();
			arRequest.s_email_sent_date = "" + cal.get(Calendar.YEAR) + "-" + (cal.get(Calendar.MONTH)+1) + "-" + cal.get(Calendar.DAY_OF_MONTH) + " " + cal.get(Calendar.HOUR_OF_DAY) + ":" + cal.get(Calendar.MINUTE);
			arRequest.save();
		}
		catch (Exception ex)
		{
			throw ex;
		}
	}

	private static String getSingleCalculations(Campaign camp, Enumeration eDetails) throws Exception
	{
		String sReturn = "";

		int iCount = 0;

		String sName = "";
		String sValue = "";

		String oldName = "";
		String oldValue = "";

		CampStatDetail csd = null;
		while (eDetails.hasMoreElements())
		{
			csd = (CampStatDetail)eDetails.nextElement();

			iCount++;

			oldName = sName;
			oldValue = sValue;

			sName = HtmlUtil.escape(csd.s_detail_name);
			sValue = HtmlUtil.escape(csd.s_integer_value);

			if ("Step".equals(sName.substring(0, 4)))
			{
				if ("Step 1".equals(sName))
				{
					sName = "Step 1: Target Group Calculations";
				}
				else if ("Step 2".equals(sName))
				{
					sName = "Step 2: Campaign Calculations";
				}
				else if ("Step 3".equals(sName))
				{
					sName = "Step 3: Final Campaign Count (including Seed List)";
				}

				if (iCount != 1)
				{
					sReturn += "<tr><td colspan=3>&nbsp;</td></tr>\n";
				}

				sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
							"<th colspan=2>" + sName + "</th></tr>\n";

				if (!("".equals(oldName)))
				{
					sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
								"<td align=left>" + oldName + "</td>" +
								"<td align=right>" + oldValue + "</td></tr>\n";
				}

				iCount = 0;
			}
			else
			{
				sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
							"<td align=left>";

				if (sName.indexOf("Count") >= 1)
				{
					sReturn += "<b>" + sName + "</b>";
				}
				else
				{
					sReturn += sName;
				}

				sReturn += "</td>" +
							"<td align=right><nobr>" + sValue + "</nobr></td>" +
							"</tr>\n";
			}
		}

		/*
		String sOrigFilterQty = null, sUnsubsQty = null, sBBackQty = null, sIneligibleRecipsQty = null, sTGTotalQty = null;
		String sRecAlreadyQty = null, sCampCount = null, sSeedListQty = null, sSeedListDupsQty = null, sFinalCampCount = null;
		CampStatistic cstat = new CampStatistic(camp.s_camp_id);

		sReturn +=	  "<tr><td><b>Total recipient count: </b></td><td>" + cstat.s_recip_total_qty + "</td></tr>\n";
		CampStatDetail csd = null;
		int iDetailId = -1;

		while (eDetails.hasMoreElements() )
		{
			csd = (CampStatDetail)eDetails.nextElement();
			iDetailId = Integer.parseInt(csd.s_detail_id);
			switch (iDetailId)
			{
				case 2:		sOrigFilterQty = csd.s_integer_value;
				break;
				case 3:		sUnsubsQty = csd.s_integer_value;
				break;
				case 4:		sBBackQty = csd.s_integer_value;
				break;
				case 5:		sIneligibleRecipsQty = csd.s_integer_value;
				break;
				case 6:		sTGTotalQty = csd.s_integer_value;
				break;
				case 8:		sRecAlreadyQty = csd.s_integer_value;
				break;
				case 9:		sCampCount = csd.s_integer_value;
				break;
				case 11:	sSeedListQty = csd.s_integer_value;
				break;
				case 12:	sSeedListDupsQty = csd.s_integer_value;
				break;
				case 13:	sFinalCampCount = csd.s_integer_value;
				break;
			}
		}

		if (sOrigFilterQty != null)
		{
			sReturn +=  "<tr><td><b>Recipients Matching Target Group Criteria (including unsubscribes and bouncebacks): </b></td><td>" + sOrigFilterQty + "</td></tr>\n";

			if (sUnsubsQty != null)
				sReturn +=  "<tr><td><b>Unsubscribe Exclusions: </b></td><td>" + sUnsubsQty + "</td></tr>\n";
			if (sBBackQty != null)
				sReturn +=  "<tr><td><b>Bounceback Exclusions: </b></td><td>" + sBBackQty + "</td></tr>\n";
			if (sIneligibleRecipsQty != null)
				sReturn +=  "<tr><td><b>Ineligible Recipients: </b></td><td>" + sIneligibleRecipsQty + "</td></tr>\n";
			if (sTGTotalQty != null)
				sReturn +=  "<tr><td><b>Total Recipients in Target Group: </b></td><td>" + sTGTotalQty + "</td></tr>\n";
			if (sRecAlreadyQty != null)
				sReturn +=  "<tr><td><b>Recipients that have already received this campaign: </b></td><td>" + sRecAlreadyQty + "</td></tr>\n";
			if (sCampCount != null)
				sReturn +=  "<tr><td><b>Campaign Count: </b></td><td>" + sCampCount + "</td></tr>\n";
			if (sSeedListQty != null)
				sReturn +=  "<tr><td><b>Recipients in Seed List: </b></td><td>" + sSeedListQty + "</td></tr>\n";
			if (sSeedListDupsQty != null)
				sReturn +=  "<tr><td><b>Duplicates removed from Seed List: </b></td><td>" + sSeedListDupsQty + "</td></tr>\n";
			if (sFinalCampCount != null)
				sReturn +=  "<tr><td><b>Final Campaign Count: </b></td><td>" + sFinalCampCount + "</td></tr>\n";
		}
		*/

		return sReturn;
	}

	private static String getSamplesetCalculations(Campaign camp, Enumeration eDetails) throws Exception
	{
		/* gets calculations for a calc_only test campaign that has a sampleset.  This test campaign was run for either all samples,
		* or for the final campaign.  Therefore, this method needs to calculate appropriately.  I.e., if the test was run for all samples,
		* calculate the numbers, and retrieve sample specific data for all samples.  If the test was run for the final campaign, calculate
		* the numbers for the entire campaign minus all samples, and retrieve data for the final campaign.*/

		String sReturn = "";

		CampSampleset cSampleset 	= new CampSampleset(camp.s_origin_camp_id);
		CampStatistic cstat 		= new CampStatistic(camp.s_camp_id);
		int iSampleQty 				= Integer.parseInt(cSampleset.s_camp_qty);
		int iSamplesetRecipQty 		= 0;
		String sRecipPercentage 	= cSampleset.s_recip_percentage;
		String sSamplesetRecipQty 	= cSampleset.s_recip_qty;

		if (sSamplesetRecipQty == null || sSamplesetRecipQty.equals("null"))
		{
			if (sRecipPercentage == null)
			{
				throw new Exception("Cannot calculate sampleset numbers.  No values found for either recip_qty or recip_percentage for sampleset for camp:" + camp.s_origin_camp_id);
			}
			else
			{
				iSamplesetRecipQty = Integer.parseInt(cstat.s_recip_total_qty) * Integer.parseInt(sRecipPercentage) / 100;
			}
		}
		else
		{
			iSamplesetRecipQty = Integer.parseInt(sSamplesetRecipQty);
		}

		//sReturn += "<tr><td><b>Total Recipient Count for All Campaigns (all samples" +
		//			((cSampleset.s_final_camp_flag != null && cSampleset.s_final_camp_flag.equals("1"))?" and final campaign":"") + "): </b></td><td>" + cstat.s_recip_total_qty + "</td></tr>\n";

		int iCount = 0;

		String sName = "";
		String sValue = "";

		String oldName = "";
		String oldValue = "";

		CampStatDetail csd = null;
		while (eDetails.hasMoreElements())
		{
			csd = (CampStatDetail)eDetails.nextElement();

			iCount++;

			oldName = sName;
			oldValue = sValue;

			sName = HtmlUtil.escape(csd.s_detail_name);
			sValue = HtmlUtil.escape(csd.s_integer_value);

			if ("Step".equals(sName.substring(0, 4)))
			{
				if ("Step 1".equals(sName))
				{
					sName = "Step 1: Target Group Calculations";
				}
				else if ("Step 2".equals(sName))
				{
					sName = "Step 2: Campaign Calculations";
				}
				else if ("Step 3".equals(sName))
				{
					sName = "Step 3: Final Campaign Count (including Seed List)";
				}

				if (iCount != 1)
				{
					sReturn += "<tr><td colspan=3>&nbsp;</td></tr>\n";
				}

				sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
							"<th colspan=2>" + sName + "</th></tr>\n";

				if (!("".equals(oldName)))
				{
					sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
								"<td align=left>" + oldName + "</td>" +
								"<td align=right>" + oldValue + "</td></tr>\n";
				}

				iCount = 0;
			}
			else
			{
				sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
							"<td align=left>";

				if (sName.indexOf("Count") >= 1)
				{
					sReturn += "<b>" + sName + "</b>";
				}
				else
				{
					sReturn += sName;
				}

				sReturn += "</td>" +
							"<td align=right><nobr>" + sValue + "</nobr></td>" +
							"</tr>\n";
			}
		}

		/*
		String sOrigFilterQty = null, sUnsubsQty = null, sBBackQty = null, sIneligibleRecipsQty = null, sTGTotalQty = null;
		String sRecAlreadyQty = null, sCampCount = null, sSeedListQty = null, sSeedListDupsQty = null, sFinalCampCount = null;

		CampSampleset cSampleset 	= new CampSampleset(camp.s_origin_camp_id);
		CampStatistic cstat 		= new CampStatistic(camp.s_camp_id);
		int iSampleQty 				= Integer.parseInt(cSampleset.s_camp_qty);
		int iSamplesetRecipQty 		= 0;
		String sRecipPercentage 	= cSampleset.s_recip_percentage;
		String sSamplesetRecipQty 	= cSampleset.s_recip_qty;

		if (sSamplesetRecipQty == null || sSamplesetRecipQty.equals("null"))
		{
			if (sRecipPercentage == null)
			{
				throw new Exception("Cannot calculate sampleset numbers.  No values found for either recip_qty or recip_percentage for sampleset for camp:" + camp.s_origin_camp_id);
			}
			else
			{
				iSamplesetRecipQty = Integer.parseInt(cstat.s_recip_total_qty) * Integer.parseInt(sRecipPercentage) / 100;
			}
		}
		else
		{
			iSamplesetRecipQty = Integer.parseInt(sSamplesetRecipQty);
		}

		sReturn += "<tr><td><b>Total recipient count for all campaigns (all samples" +
					((cSampleset.s_final_camp_flag != null && cSampleset.s_final_camp_flag.equals("1"))?" and final campaign":"") + "): </b></td><td>" + cstat.s_recip_total_qty + "</td></tr>\n";

		// First get details for entire campaign
		CampStatDetail csd = null;
		int iDetailId = -1;

		while (eDetails.hasMoreElements())
		{
			csd = (CampStatDetail)eDetails.nextElement();
			iDetailId = Integer.parseInt(csd.s_detail_id);
			switch (iDetailId)
			{
				case 2:		sOrigFilterQty = csd.s_integer_value;
				break;
				case 3:		sUnsubsQty = csd.s_integer_value;
				break;
				case 4:		sBBackQty = csd.s_integer_value;
				break;
				case 5:		sIneligibleRecipsQty = csd.s_integer_value;
				break;
				case 6:		sTGTotalQty = csd.s_integer_value;
				break;
				case 8:		sRecAlreadyQty = csd.s_integer_value;
				break;
				case 9:		sCampCount = csd.s_integer_value;
				break;
				case 11:	sSeedListQty = csd.s_integer_value;
				break;
				case 12:	sSeedListDupsQty = csd.s_integer_value;
				break;
				case 13:	sFinalCampCount = csd.s_integer_value;
				break;
			}
		}

		sReturn += "<tr><td colspan=2><b>Breakdown of Total Recipient Count</b></td></tr>\n";

		if (sOrigFilterQty != null)
		{
			sReturn +=  "<tr><td><b>Recipients Matching Target Group Criteria (including unsubscribes and bouncebacks): </b></td><td>" + sOrigFilterQty + "</td></tr>\n";

			if (sUnsubsQty != null)
				sReturn +=  "<tr><td><b>Unsubscribe Exclusions: </b></td><td>" + sUnsubsQty + "</td></tr>\n";
			if (sBBackQty != null)
				sReturn +=  "<tr><td><b>Bounceback Exclusions: </b></td><td>" + sBBackQty + "</td></tr>\n";
			if (sIneligibleRecipsQty != null)
				sReturn +=  "<tr><td><b>Ineligible Recipients: </b></td><td>" + sIneligibleRecipsQty + "</td></tr>\n";
			if (sTGTotalQty != null)
				sReturn +=  "<tr><td><b>Total Recipients in Target Group: </b></td><td>" + sTGTotalQty + "</td></tr>\n";
			if (sRecAlreadyQty != null)
				sReturn +=  "<tr><td><b>Recipients that have already received this campaign: </b></td><td>" + sRecAlreadyQty + "</td></tr>\n";
			if (sCampCount != null)
				sReturn +=  "<tr><td><b>Campaign count: </b></td><td>" + sCampCount + "</td></tr>\n";
			if (sSeedListQty != null)
				sReturn +=  "<tr><td><b>Recipients in Seed List: </b></td><td>" + sSeedListQty + "</td></tr>\n";
			if (sSeedListDupsQty != null)
				sReturn +=  "<tr><td><b>Duplicates removed from Seed List: </b></td><td>" + sSeedListDupsQty + "</td></tr>\n";
			if (sFinalCampCount != null)
				sReturn +=  "<tr><td><b>Total Campaign count: </b></td><td>" + sFinalCampCount + "</td></tr>\n";
		}

		sReturn += "<tr><td><b>Total recipient count assigned to sampleset (all samples): </b></td><td>" + iSamplesetRecipQty + "</td></tr>\n";
		*/

		//if (cSampleset.s_final_camp_flag != null && cSampleset.s_final_camp_flag.equals("1"))
		//{
		//	sReturn += "<tr><td><b>Recipient Count for Final Campaign: </b></td><td>" + (Integer.parseInt(cstat.s_recip_total_qty) - iSamplesetRecipQty)  + "</td></tr>\n";
		//}

		if (camp.s_sample_id != null)
		{
			// this is for all samples
			sReturn += "<tr><td colspan=3>&nbsp;</td></tr>\n" +
						"<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
						"<td colspan=2><b>Breakdown by Sample</b></td></tr>\n";

			CampSampleBean cSample = null;

			for (int i = 1; i <= iSampleQty; i++)
			{
				sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
							"<td colspan=2>" +
							"<table cellspacing=0 cellpadding=3 border=0>\n" +
							"<tr><th colspan=2>Sample " + i + " Details:</th></tr>\n";

				cSample = new CampSampleBean(camp.s_origin_camp_id, String.valueOf(i));

				if (cSampleset.s_from_name_flag != null && cSampleset.s_from_name_flag.equals("1"))
				{
					sReturn += "<tr><td><b>From Name: </b></td><td>" + cSample.getFromName() + "</td></tr>\n";
				}
				if (cSampleset.s_from_address_flag != null && cSampleset.s_from_address_flag.equals("1"))
				{
					sReturn += "<tr><td><b>From Address: </b></td><td>" + cSample.getFromAddress() + "</td></tr>\n";
				}
				if (cSampleset.s_subject_flag != null && cSampleset.s_subject_flag.equals("1"))
				{
					sReturn += "<tr><td><b>Subject: </b></td><td>" + cSample.getSubjectHtml() + "</td></tr>\n";
				}
				if (cSampleset.s_cont_flag != null && cSampleset.s_cont_flag.equals("1"))
				{
					sReturn += "<tr><td><b>Content: </b></td><td>" + cSample.getContName() + "</td></tr>\n";
				}
				if (cSampleset.s_send_date_flag != null && cSampleset.s_send_date_flag.equals("1"))
				{
					sReturn += "<tr><td><b>Send Date: </b></td><td>" + cSample.getSendDate() + "</td></tr>\n";
				}

				sReturn += "<tr><td><b>Approximate Sample Recipient Count: </b></td><td>" + (iSamplesetRecipQty / iSampleQty) + "</td></tr>\n";

				sReturn += "</table></td></tr>\n";

				if (i < iSampleQty)
				{
					sReturn += "<tr><td>&nbsp;&nbsp;&nbsp;</td>" +
								"<td colspan=2><hr width=250></td></tr>\n";
				}
			}
		}

		return sReturn;
	}

	public static void sendFilterApprovalRequestEmail(String sAprvlRequestId, String sFilterId) throws Exception
	{
		try
		{
			ApprovalRequest arRequest 			= new ApprovalRequest(sAprvlRequestId);
			com.britemoon.cps.tgt.Filter filt 	= new com.britemoon.cps.tgt.Filter(sFilterId);
			FilterStatistic fstat 				= new FilterStatistic(sFilterId);
			Customer cust = new Customer(arRequest.s_cust_id);

			Properties props = new Properties();
			String sHost = Registry.getKey("mail_smtp_host");
			props.put("mail.smtp.host", sHost);
			Session s = Session.getInstance(props,null);
			// System.out.println("SMTP host to send email to requestor is:" + sHost);

			User uRequestor = new User(arRequest.s_requestor_id);
			User uApprover = new User(arRequest.s_approver_id);

			MimeMessage message = new MimeMessage(s);

			InternetAddress from = new InternetAddress(uRequestor.s_email);
			message.setFrom(from);

			// System.out.println(" setting To address for email to:"+uApprover.s_email);
			InternetAddress to = new InternetAddress(uApprover.s_email);
			message.addRecipient(Message.RecipientType.TO, to);

			// System.out.println("setting cc address for email to:"+uRequestor.s_email);
			InternetAddress cc = new InternetAddress(uRequestor.s_email);
			message.addRecipient(Message.RecipientType.CC, cc);

			String subject = "Request for Approval - Target Group: " + filt.s_filter_name;
			message.setSubject(subject);

			String sEmailText = "<html><head></head><body>\n" +
								"<style type=text/css>\n" +
								"TABLE, TD { font-family:Verdana; font-size:8pt; }\n" +
								"TH { align:left; text-align:left; background-color:#3E3E87; color:#FFFFFF; font-family:Verdana; font-size:8pt; }\n" +
								"</style>\n" +
								"<table cellspacing=0 cellpadding=3 border=0>\n" +
								"<tr><th colspan=2><b>Approval Request</b></th></tr>\n";

			sEmailText += "<tr><td colspan=2>Your approval has been requested for Target Group: " + filt.s_filter_name + "</td></tr>\n" +
							"<tr><td><nobr><b>Customer: </b></nobr></td><td>" + cust.s_cust_name + "</td></tr>\n" +
							"<tr><td><nobr><b>Requestor: </b></nobr></td><td>" + uRequestor.s_user_name + " " + uRequestor.s_last_name + " (" + uRequestor.s_email + ")</td></tr>\n" +
							"<tr><td><nobr><b>Request Date: </b></nobr></td><td>" + arRequest.s_request_date + "</td></tr>\n" +
							"<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2><b>Target Group Statistics:</b></th></tr>\n" +
							"<tr><td colspan=2>Recipient Count: " + fstat.s_recip_qty + "</td></tr>\n";

			if (arRequest.s_request_comment != null)
			{
				sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
								"<tr><th colspan=2>Requestor Comments</th></tr>\n" +
								"<tr><td colspan=2>" +
								arRequest.s_request_comment.replaceAll("\n", "<br>") +
								"</td></tr>\n";
			}

			String sLinkURL = "";
/*			sLinkURL = WorkflowUtil.getApprovalUrl(ObjectType.FILTER, sFilterId, filt.s_cust_id, true) +
						URLEncoder.encode("&aprvl_request_id=" + arRequest.s_approval_request_id);

			sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2>Approval View of Target Group</th></tr>\n" +
							"<tr><td colspan=2>Login to the system, then copy and paste this into the browser:</td></tr>\n" +
							"<tr><td colspan=2>" + sLinkURL + "</td></tr>";
*/
			sLinkURL = "http://" + WorkflowUtil.getCustCPSHost(arRequest.s_cust_id) + "/ccps/ui/jsp/index.jsp?tab=Home&sec=4";

			sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2>All Pending Approval Assets</th></tr>\n" +
							"<tr><td colspan=2>Login to the system, then copy and paste this into the browser:</td></tr>\n" +
							"<tr><td colspan=2>" + sLinkURL + "</td></tr>";

			message.setContent(sEmailText, "text/html");

			Transport.send(message);

			java.util.Calendar cal = java.util.Calendar.getInstance();
			arRequest.s_email_sent_date = "" + cal.get(Calendar.YEAR) + "-" + (cal.get(Calendar.MONTH)+1) + "-" + cal.get(Calendar.DAY_OF_MONTH) + " " + cal.get(Calendar.HOUR_OF_DAY) + ":" + cal.get(Calendar.MINUTE);
			arRequest.save();
		}
		catch (Exception ex)
		{
			throw ex;
		}
	}

	public static void sendApprovalRequestEmail(String sAprvlRequestId, String sObjectType, String sObjectId) throws Exception
	{
		/* Send email to approver */
		try
		{
			ApprovalRequest arRequest = new ApprovalRequest(sAprvlRequestId);
			int iObjectType = Integer.parseInt(sObjectType);
			Customer cust = new Customer(arRequest.s_cust_id);

			Properties props = new Properties();
			String sHost = Registry.getKey("mail_smtp_host");
			// System.out.println("SMTP host to send email to requestor is:" + sHost);
			props.put("mail.smtp.host", sHost);
			Session s = Session.getInstance(props,null);

			User uRequestor = new User(arRequest.s_requestor_id);
			User uApprover = new User(arRequest.s_approver_id);

			MimeMessage message = new MimeMessage(s);

			InternetAddress from = new InternetAddress(uRequestor.s_email);
			message.setFrom(from);

			// System.out.println(" setting To address for email to:"+uApprover.s_email);
			InternetAddress to = new InternetAddress(uApprover.s_email);
			message.addRecipient(Message.RecipientType.TO, to);

			// System.out.println("setting cc address for email to:"+uRequestor.s_email);
			InternetAddress cc = new InternetAddress(uRequestor.s_email);
			message.addRecipient(Message.RecipientType.CC, cc);

			String sObjectName = WorkflowUtil.getObjectName(Integer.parseInt(sObjectType),sObjectId);
			String sObjectTypeName = ObjectType.getDisplayName(Integer.parseInt(sObjectType));

			String subject = "Request for Approval - " + sObjectTypeName + ": " +
			sObjectName;
			message.setSubject(subject);

			String sEmailText = "<html><head></head><body>\n" +
								"<style type=text/css>\n" +
								"TABLE, TD { font-family:Verdana; font-size:8pt; }\n" +
								"TH { align:left; text-align:left; background-color:#3E3E87; color:#FFFFFF; font-family:Verdana; font-size:8pt; }\n" +
								"</style>\n" +
								"<table cellspacing=0 cellpadding=3 border=0>\n" +
								"<tr><th colspan=2><b>Approval Request</b></th></tr>\n";

			sEmailText += "<tr><td colspan=2>Your approval has been requested for " + sObjectTypeName + ": " + sObjectName + "</td></tr>\n" +
							"<tr><td><nobr><b>Customer: </b></nobr></td><td>" + cust.s_cust_name + "</td></tr>\n" +
							"<tr><td><nobr><b>Requestor: </b></nobr></td><td>" + uRequestor.s_user_name + " " + uRequestor.s_last_name + " (" + uRequestor.s_email + ")</td></tr>\n" +
							"<tr><td><nobr><b>Request Date: </b></nobr></td><td>" + arRequest.s_request_date + "</td></tr>\n" +
							"<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2><b>Details:</b></th></tr>\n";

			switch (iObjectType)
			{
				case ObjectType.USER:
					User u = new User(sObjectId);
					sEmailText += "<tr><td><b>Username: </b></td><td>" + u.s_user_name + " " + u.s_last_name + "\r\n" +
					"<tr><td><b>Position: </b></td><td>" + u.s_position + "\r\n" +
					"<tr><td><b>Email address: </b></td><td>" + u.s_email + "\r\n" +
					"<tr><td><b>Phone: </b></td><td>" + u.s_phone + "\r\n";
					break;
				case ObjectType.CONTENT:
					Content cont = new Content(sObjectId);
					sEmailText += "<tr><td><b>Content Name: </b></td><td>" + cont.s_cont_name + "\r\n";
					break;
				case ObjectType.IMPORT:
					ImportBean imp = new ImportBean(sObjectId);
					String sBadRows = imp.getBadRows();
					String sBadEmails = imp.getBadEmails();
					String sFileDups = imp.getFileDups();
					String sWarningRecips = imp.getWarningRecips();
					String sDupRecips = imp.getDupRecips();
					sEmailText += "<tr><td><b>Import Name: </b></td><td>" + imp.getImportName() + "</td></tr>\n" +
					"<tr><td><b>Batch Name: </b></td><td>" + imp.getBatchName() + "</td></tr>\n" +
					"<tr><td><b>Total records in import file: </b></td><td>" + imp.getTotRows() + "</td></tr>\n" +
					"<tr><td><b>Bad rows in import file: </b></td><td>" + ((sBadRows != null)?sBadRows:"--") + "</td></tr>\n" +
					"<tr><td><b>Unrecoverable email records: </b></td><td>" + ((sBadEmails != null)?sBadEmails:"--") + "</td></tr>\n" +
					"<tr><td><b>Duplicates in import file: </b></td><td>" + ((sFileDups != null)?sFileDups:"--") + "</td></tr>\n" +
					"<tr><td><b>Records generating a warning during processing: </b></td><td>" + ((sWarningRecips != null)?sWarningRecips:"--") + "</td></tr>\n" +
					"<tr><td><b>Duplicates in the DB: </b></td><td>" + ((sDupRecips != null)?sDupRecips:"--") + "</td></tr>\n" +
					"<tr><td><b>Total to be imported: </b></td><td>" + imp.getTotRecips() + "</td></tr>\n";
					break;
			}

			if (arRequest.s_request_comment != null)
			{
				sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
								"<tr><th colspan=2>Requestor Comments</th></tr>\n" +
								"<tr><td colspan=2>" +
								arRequest.s_request_comment.replaceAll("\n", "<br>") +
								"</td></tr>\n";
			}

			String sLinkURL = "";
/*			sLinkURL = WorkflowUtil.getApprovalUrl(Integer.parseInt(sObjectType), sObjectId, arRequest.s_cust_id, true) +
						URLEncoder.encode("&aprvl_request_id=" + arRequest.s_approval_request_id);

			sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2>Approval View of " + sObjectTypeName + "</th></tr>\n" +
							"<tr><td colspan=2>Login to the system, then copy and paste this into the browser:</td></tr>\n" +
							"<tr><td colspan=2>" + sLinkURL + "</td></tr>";
*/
			sLinkURL = "http://" + WorkflowUtil.getCustCPSHost(arRequest.s_cust_id) + "/ccps/ui/jsp/index.jsp?tab=Home&sec=4";

			sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n" +
							"<tr><th colspan=2>All Pending Approval Assets</th></tr>\n" +
							"<tr><td colspan=2>Login to the system, then copy and paste this into the browser:</td></tr>\n" +
							"<tr><td colspan=2>" + sLinkURL + "</td></tr>";

			message.setContent(sEmailText, "text/html");

			Transport.send(message);

			java.util.Calendar cal = java.util.Calendar.getInstance();
			arRequest.s_email_sent_date = "" + cal.get(Calendar.YEAR) + "-" + (cal.get(Calendar.MONTH)+1) + "-" + cal.get(Calendar.DAY_OF_MONTH) + " " + cal.get(Calendar.HOUR_OF_DAY) + ":" + cal.get(Calendar.MINUTE);
			arRequest.save();
		}
		catch (Exception ex)
		{
			throw ex;
		}
	}
}
