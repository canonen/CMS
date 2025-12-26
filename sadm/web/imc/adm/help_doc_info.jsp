<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="javax.mail.*"
	import="javax.mail.internet.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sVolumeID = null;
String sVolumeHeading = null;
String sVolumeOrder = null;
String sVolumeApproved = null;
String sChapterID = null;
String sChapterHeading = null;
String sChapterOrder = null;
String sChapterApproved = null;
String sPageID = null;
String sPageHeading = null;
String sPageInternalHeading = null;
String sPageOrder = null;
String sPageApproved = null;

String oldVolumeID = "newVolume";
String newVolumeID = "newVolume";
String oldChapterID = "newChapter";
String newChapterID = "newChapter";

int vlCount = 0;
int chCount = 0;
int iCount = 0;

byte[] b = null;

String uniqueID = "help_doc_id";
				

try
{
	Element eNote = XmlUtil.getRootElement(request);  
	
	if (eNote == null)
	{
		out.println("<ERROR>Error retrieving XML in ADM->help_doc_info.jsp.  XML sent to ADM did not parse correctly.</ERROR>");
	}
	else
	{
		
		String sAction = XmlUtil.getChildTextValue(eNote,"action");
		
		if (sAction == null || sAction.equals(""))
		{
			out.println("<ERROR>Error retrieving XML in ADM->help_doc_info.jsp.  XML sent to ADM did not parse correctly.</ERROR>");
		}
		else
		{
		
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("help_doc_info.jsp");
			stmt = conn.createStatement();
		
			if (sAction.equals("helpdoc") || sAction.equals("faqdoc"))
			{
				logger.info("Support TOC Request >> Start");
				if (sAction.equals("helpdoc"))
				{
					logger.info("Support TOC Request >> Help Doc TOC");
					sSql =
						" select v.help_doc_id as 'VolumeID', " + 
						" v.display_heading as 'VolumeHeading', " + 
						" v.help_order as 'VolumeOrder', " + 
						" v.approved_flag as 'VolumeApproved', " +
						" c.help_doc_id as 'ChapterID', " + 
						" c.display_heading as 'ChapterHeading', " + 
						" c.help_order as 'ChapterOrder', " + 
						" c.approved_flag as 'ChapterApproved', " +
						" p.help_doc_id as 'PageID', " + 
						" p.display_heading as 'PageHeading', " + 
						" p.help_order as 'PageOrder', " + 
						" p.approved_flag as 'PageApproved' " +
						" from shlp_help_doc v with(nolock)" +
						" left outer join shlp_help_doc c with(nolock) on v.help_doc_id = c.parent_help_doc_id" +
						" left outer join shlp_help_doc p with(nolock) on c.help_doc_id = p.parent_help_doc_id" +
						" where (v.type_id = 101 or c.type_id = 102 or p.type_id = 103) and (v.approved_flag = 1 and c.approved_flag = 1 and p.approved_flag = 1)" +
						" order by 3, 7, 11";
						
					uniqueID = "help_doc_id";
				}
				else
				{
					logger.info("Support TOC Request >> FAQ TOC");
					sSql =
						" select v.faq_id as 'VolumeID', " + 
						" v.display_heading as 'VolumeHeading', " + 
						" v.faq_order as 'VolumeOrder', " + 
						" v.approved_flag as 'VolumeApproved', " +
						" c.faq_id as 'ChapterID', " + 
						" c.display_heading as 'ChapterHeading', " + 
						" c.faq_order as 'ChapterOrder', " + 
						" c.approved_flag as 'ChapterApproved', " +
						" p.faq_id as 'PageID', " + 
						" p.display_heading as 'PageHeading', " + 
						" p.faq_order as 'PageOrder', " + 
						" p.approved_flag as 'PageApproved'" +
						" from shlp_faq v with(nolock)" +
						" left outer join shlp_faq c with(nolock) on v.faq_id = c.parent_faq_id" +
						" left outer join shlp_faq p with(nolock) on c.faq_id = p.parent_faq_id" +
						" where (v.type_id = 201 or c.type_id = 202 or p.type_id = 203) and (v.approved_flag = 1 and c.approved_flag = 1 and p.approved_flag = 1)" +
						" order by 3, 7, 11";
						
					uniqueID = "faq_id";
				}
					
				rs = stmt.executeQuery(sSql);
				
				logger.info("Support TOC Request >> Begin XML");
				
				while (rs.next())
				{
					if (iCount == 0)
					{
						out.println("<books>");
					}
					
					sVolumeID = rs.getString(1);																
					b = rs.getBytes(2);
					sVolumeHeading = (b==null)?null:new String(b, "ISO-8859-1");
					sVolumeOrder  = rs.getString(3);
					sVolumeApproved  = rs.getString(4);
					
					sChapterID = rs.getString(5);
					b = rs.getBytes(6);
					sChapterHeading = (b==null)?null:new String(b, "ISO-8859-1");
					sChapterOrder  = rs.getString(7);
					sChapterApproved  = rs.getString(8);
					
					sPageID = rs.getString(9);
					b = rs.getBytes(10);
					sPageHeading = (b==null)?null:new String(b, "ISO-8859-1");
					sPageOrder  = rs.getString(11);
					sPageApproved  = rs.getString(12);
					
					newVolumeID = sVolumeHeading;

					newChapterID = sChapterHeading;
					
					if (newVolumeID.compareToIgnoreCase(oldVolumeID) == 0)
					{
						//nothing here
					}
					else
					{
						chCount = 0;
						//if (vlCount.compareTo("0") != 0)
						if (vlCount != 0)
						{
							out.println("</chapter>");
							out.println("</volume>");
						}
						
						out.println("<volume code=\"vl" + sVolumeID + "\" name=\"" + sVolumeHeading + "\">");

						vlCount++;
						oldVolumeID = newVolumeID;
					}
					
					if (sChapterHeading != null)
					{
						if (newChapterID.compareToIgnoreCase(oldChapterID) == 0)
						{
							//nothing here
							if (sPageHeading != null)
							{
								out.println("<page topic=\"vl" + sVolumeID + "-ch" + sChapterID + "-pg" + sPageID + "\" " + uniqueID + "=\"" + sPageID + "\">" + sPageHeading + "</page>");
							}
							chCount++;
						}
						else
						{
							if (chCount != 0)
							{
								out.println("</chapter>");
							}
							
							out.println("<chapter code=\"vl" + sVolumeID + "-ch" + sChapterID + "\" name=\"" + sChapterHeading + "\" " + uniqueID + "=\"" + sChapterID + "\">");
							
							if (sPageHeading != null)
							{
								out.println("<page topic=\"vl" + sVolumeID + "-ch" + sChapterID + "-pg" + sPageID + "\" " + uniqueID + "=\"" + sPageID + "\">" + sPageHeading + "</page>");
							}
							chCount++;
							oldChapterID = newChapterID;
						}
					}
					
					iCount++;
					
				}
				
				if (chCount != 0)
				{
					out.println("</chapter>");
				}
				
				if (vlCount != 0)
				{
					out.println("</volume>");
				}
				
				if (iCount != 0)
				{
					out.println("</books>");
				}
					
				rs.close();
	
				logger.info("Support TOC Request >> End XML");
	
			}
			else if (sAction.equals("helpview"))
			{
				
				String sHelpDocID = XmlUtil.getChildTextValue(eNote,"help_doc_id");
				String sFind = XmlUtil.getChildCDataValue(eNote,"criteria");
				
				String sParentHelpDocID = "0";
				String sTypeID = null;
				String sInternalHeading = null;	
				String sDisplayHeading = "Welcome";
				String sContentText = "Browse the Help navigation to the left or search for Help topics in the search bar above.";
				String sHelpOrder = null;
				String sApprovedFlag = null;

				String sParentID = null;
				String sParentLabel = null;
				
				if (sHelpDocID == null || sHelpDocID.equals(""))
				{
					out.println("<ERROR>Error retrieving XML in ADM->help_doc_info.jsp.  XML sent to ADM did not parse correctly.</ERROR>");
				}
				else
				{
					
					if ((null == sFind) || ("" == sFind) || ("0" == sFind))
					{
						sSql = "select help_doc_id, parent_help_doc_id, type_id, internal_heading, " +
								" display_heading, " +
								" content_text, " +
								" help_order, approved_flag" +
								" from shlp_help_doc with(nolock) where help_doc_id = '" + sHelpDocID + "'";
					}
					else
					{
						sSql = "select help_doc_id, parent_help_doc_id, type_id, internal_heading, " +
								" REPLACE(display_heading, '" + sFind + "', '<span style=\"background-color:yellow;color:black;\">" + sFind + "</span>')," +
								" REPLACE(content_text, '" + sFind + "', '<span style=\"background-color:yellow;color:black;\">" + sFind + "</span>')," +
								" help_order, approved_flag" +
								" from shlp_help_doc with(nolock) where help_doc_id = '" + sHelpDocID + "'";
					}
					
					rs = stmt.executeQuery(sSql);
					
					while (rs.next())
					{
						sParentHelpDocID = rs.getString(2);
						
						sTypeID = rs.getString(3);
						
						b = rs.getBytes(4);
						sInternalHeading = (b==null)?null:new String(b, "ISO-8859-1");
						
						b = rs.getBytes(5);
						sDisplayHeading = (b==null)?null:new String(b, "ISO-8859-1");
						
						b = rs.getBytes(6);
						sContentText = (b==null)?null:new String(b, "ISO-8859-1");
						
						sHelpOrder = rs.getString(7);
						
						sApprovedFlag = rs.getString(8);
					}
					
					out.println("<HelpDocPage>");
					out.println("	<DisplayHeading>");
					out.println("		<![CDATA[" + sDisplayHeading + "]]>");
					out.println("	</DisplayHeading>");
					out.println("	<ContentText>");
					out.println("		<![CDATA[" + sContentText + "]]>");
					out.println("	</ContentText>");
					
					rs.close();
					
					String sChildID = null;
					String sChildHeading = null;
					
					iCount = 0;
					
					sSql = "select help_doc_id, display_heading from shlp_help_doc with(nolock) where approved_flag = 1 and type_id = 103 and (parent_help_doc_id = '" + sHelpDocID + "' or parent_help_doc_id = '" + sParentHelpDocID + "') order by help_order";
					
					rs = stmt.executeQuery(sSql);
					
					while (rs.next())
					{
						if (iCount == 0)
						{
							out.println("<SubTopics>");
						}
						
						sChildID = rs.getString(1);
						sChildHeading = rs.getString(2);
						
						out.println("<HelpDocPage>");
						out.println("	<HelpDocID>" + sChildID + "</HelpDocID>");
						out.println("	<DisplayHeading>");
						out.println("		<![CDATA[" + sChildHeading + "]]>");
						out.println("	</DisplayHeading>");
						out.println("</HelpDocPage>");
						
						iCount++;
					}
					
					if (iCount != 0)
					{
						out.println("</SubTopics>");
					}
					
					rs.close();
					
					out.println("</HelpDocPage>");
				}
				
			}
			else if (sAction.equals("faqview"))
			{
				
				String sFAQID = XmlUtil.getChildTextValue(eNote,"faq_id");
				String sFind = XmlUtil.getChildCDataValue(eNote,"criteria");
				
				String sParentFAQID = "0";
				String sTypeID = null;
				String sDisplayHeading = "Welcome";	
				String sAskQuestion = "Browse the FAQ navigation to the left.";
				String sGivenAnswer = "";
				String sFAQOrder = null;
				String sApprovedFlag = null;

				String sParentID = null;
				String sParentLabel = null;
				
				if (sFAQID == null || sFAQID.equals(""))
				{
					out.println("<ERROR>Error retrieving XML in ADM->help_doc_info.jsp.  XML sent to ADM did not parse correctly.</ERROR>");
				}
				else
				{
					
					if ((null == sFind) || ("" == sFind) || ("0" == sFind))
					{
						sSql = "select faq_id, parent_faq_id, type_id," +
							" display_heading," +
							" ask_question," +
							" given_answer," +
							" faq_order, approved_flag" +
							" from shlp_faq with(nolock) where faq_id = '" + sFAQID + "'";
					}
					else
					{
					sSql = "select faq_id, parent_faq_id, type_id," +
							" REPLACE(display_heading, '" + sFind + "', '<span style=\"background-color:yellow;color:black;\">" + sFind + "</span>') As 'DisplayHeading'," +
							" REPLACE(ask_question, '" + sFind + "', '<span style=\"background-color:yellow;color:black;\">" + sFind + "</span>') As 'AskQuestion'," +
							" REPLACE(given_answer, '" + sFind + "', '<span style=\"background-color:yellow;color:black;\">" + sFind + "</span>') As 'GivenAnswer'," +
							" faq_order, approved_flag" +
							" from shlp_faq with(nolock) where faq_id = '" + sFAQID + "'";
					}
					
					rs = stmt.executeQuery(sSql);
					
					while (rs.next())
					{
						sParentFAQID = rs.getString(2);
						
						sTypeID = rs.getString(3);
						
						b = rs.getBytes(4);
						sDisplayHeading = (b==null)?null:new String(b, "ISO-8859-1");
						
						b = rs.getBytes(5);
						sAskQuestion = (b==null)?null:new String(b, "ISO-8859-1");
						
						b = rs.getBytes(6);
						sGivenAnswer = (b==null)?null:new String(b, "ISO-8859-1");
						
						sFAQOrder = rs.getString(7);
						
						sApprovedFlag = rs.getString(8);
					}
					
					rs.close();
					
					out.println("<FAQPage>");
					out.println("	<DisplayHeading>");
					out.println("		<![CDATA[" + sDisplayHeading + "]]>");
					out.println("	</DisplayHeading>");
					out.println("	<AskQuestion>");
					out.println("		<![CDATA[" + sAskQuestion + "]]>");
					out.println("	</AskQuestion>");
					out.println("	<GivenAnswer>");
					out.println("		<![CDATA[" + sGivenAnswer + "]]>");
					out.println("	</GivenAnswer>");
					out.println("</FAQPage>");
					
				}
				
			}
			else if (sAction.equals("helpsearch") || sAction.equals("faqsearch"))
			{
				
				out.println("<searchResults>");
				
				String sFind = XmlUtil.getChildCDataValue(eNote,"criteria");
				
				if (sAction.equals("helpsearch"))
				{
					sSql =
						" select v.help_doc_id as 'VolumeID', " + 
						" v.display_heading as 'VolumeHeading', " + 
						" v.help_order as 'VolumeOrder', " + 
						" v.approved_flag as 'VolumeApproved'," +
						" c.help_doc_id as 'ChapterID', " + 
						" c.display_heading as 'ChapterHeading', " + 
						" c.help_order as 'ChapterOrder', " + 
						" c.approved_flag as 'ChapterApproved'," +
						" p.help_doc_id as 'PageID', " + 
						" p.display_heading as 'PageHeading', " + 
						" p.help_order as 'PageOrder', " + 
						" p.approved_flag as 'PageApproved'" +
						" from shlp_help_doc v with(nolock)" +
						" left outer join shlp_help_doc c with(nolock) on v.help_doc_id = c.parent_help_doc_id" +
						" left outer join shlp_help_doc p with(nolock) on c.help_doc_id = p.parent_help_doc_id" +
						" where (v.type_id = 101 or c.type_id = 102 or p.type_id = 103) and (v.approved_flag = 1 and c.approved_flag = 1 and p.approved_flag = 1)" +
						" and (LOWER(p.display_heading) like '%" + sFind + "%' or LOWER(p.content_text) LIKE '%" + sFind + "%')" +
						" order by 3, 7, 11";
				}
				else
				{
					sSql =
						" select v.faq_id as 'VolumeID', " + 
						" v.display_heading as 'VolumeHeading', " + 
						" v.faq_order as 'VolumeOrder', " + 
						" v.approved_flag as 'VolumeApproved', " +
						" c.faq_id as 'ChapterID', " + 
						" c.display_heading as 'ChapterHeading', " + 
						" c.faq_order as 'ChapterOrder', " + 
						" c.approved_flag as 'ChapterApproved', " +
						" p.faq_id as 'PageID', " + 
						" p.display_heading as 'PageHeading', " + 
						" p.faq_order as 'PageOrder', " + 
						" p.approved_flag as 'PageApproved'" +
						" from shlp_faq v with(nolock)" +
						" left outer join shlp_faq c with(nolock) on v.faq_id = c.parent_faq_id" +
						" left outer join shlp_faq p with(nolock) on c.faq_id = p.parent_faq_id" +
						" where (v.type_id = 201 or c.type_id = 202 or p.type_id = 203) and (v.approved_flag = 1 and c.approved_flag = 1 and p.approved_flag = 1)" +
						" and (LOWER(p.display_heading) like '%" + sFind + "%' or LOWER(p.ask_question) LIKE '%" + sFind + "%' or LOWER(p.given_answer) LIKE '%" + sFind + "%')" +
						" order by 3, 7, 11";
				}
					
				rs = stmt.executeQuery(sSql);
				
				while (rs.next())
				{
					sVolumeID = rs.getString(1);																
					b = rs.getBytes(2);
					sVolumeHeading = (b==null)?null:new String(b, "ISO-8859-1");
					sVolumeOrder  = rs.getString(3);
					sVolumeApproved  = rs.getString(4);
					
					sChapterID = rs.getString(5);
					b = rs.getBytes(6);
					sChapterHeading = (b==null)?null:new String(b, "ISO-8859-1");
					sChapterOrder  = rs.getString(7);
					sChapterApproved  = rs.getString(8);
					
					sPageID = rs.getString(9);
					b = rs.getBytes(10);
					sPageHeading = (b==null)?null:new String(b, "ISO-8859-1");
					sPageOrder  = rs.getString(11);
					sPageApproved  = rs.getString(12);
					
					newVolumeID = sVolumeHeading;

					newChapterID = sChapterHeading;
					
					out.println("	<resultItem>");
					out.println("		<VolumeID>");
					out.println("			<![CDATA[" + sVolumeID + "]]>");
					out.println("		</VolumeID>");
					out.println("		<VolumeHeading>");
					out.println("			<![CDATA[" + sVolumeHeading + "]]>");
					out.println("		</VolumeHeading>");
					out.println("		<ChapterID>");
					out.println("			<![CDATA[" + sChapterID + "]]>");
					out.println("		</ChapterID>");
					out.println("		<ChapterHeading>");
					out.println("			<![CDATA[" + sChapterHeading + "]]>");
					out.println("		</ChapterHeading>");
					out.println("		<PageID>");
					out.println("			<![CDATA[" + sPageID + "]]>");
					out.println("		</PageID>");
					out.println("		<PageHeading>");
					out.println("			<![CDATA[" + sPageHeading + "]]>");
					out.println("		</PageHeading>");
					out.println("	</resultItem>");
					
				}
				
				out.println("</searchResults>");
				
			}
			else if (sAction.equals("supportcreate"))
			{
				//support submission
				
				String New_Ticket_ID = "";
				String Further_Info = "";
				
				String s_ticket_id			= XmlUtil.getChildCDataValue(eNote,"ticket_id");
				String s_cust_id			= XmlUtil.getChildCDataValue(eNote,"cust_id");
				String s_cust_name			= XmlUtil.getChildCDataValue(eNote,"cust_name");
				String s_user_id			= XmlUtil.getChildCDataValue(eNote,"user_id");
				String s_user_name			= XmlUtil.getChildCDataValue(eNote,"user_name");
				String s_email_from			= XmlUtil.getChildCDataValue(eNote,"email_from");
				String s_email_to			= XmlUtil.getChildCDataValue(eNote,"email_to");
				String s_email_cc			= XmlUtil.getChildCDataValue(eNote,"email_cc");
				String s_phone				= XmlUtil.getChildCDataValue(eNote,"phone");
				String s_subject			= XmlUtil.getChildCDataValue(eNote,"subject");
				String s_original_issue		= XmlUtil.getChildCDataValue(eNote,"original_issue");
				String s_further_info		= XmlUtil.getChildCDataValue(eNote,"further_info");
				String s_resolution_info	= XmlUtil.getChildCDataValue(eNote,"resolution_info");
				String s_browser_info		= XmlUtil.getChildCDataValue(eNote,"browser_info");
				
				sSql = " EXECUTE usp_shlp_support_ticket_save" +
						" @ticket_id=?, @cust_id=?, @user_id=?," +
						" @subject=?, @original_issue=?, @further_info=?";

				try
				{
					pstmt = conn.prepareStatement(sSql);
				
					pstmt.setString(1, "");
			
					pstmt.setString(2, s_cust_id);
			
					pstmt.setString(3, s_user_id);
			
					if(s_subject == null) pstmt.setString(4, s_subject);
					else pstmt.setBytes(4, s_subject.getBytes("ISO-8859-1"));
			
					if(s_original_issue == null) pstmt.setString(5, s_original_issue);
					else pstmt.setBytes(5, s_original_issue.getBytes("ISO-8859-1"));
			
					if(s_further_info == null) pstmt.setString(6, s_further_info);
					else pstmt.setBytes(6, s_further_info.getBytes("ISO-8859-1"));
					
					rs = pstmt.executeQuery();

					while (rs.next())
					{
						s_ticket_id = rs.getString(1);
					}
					rs.close();
				}
				catch(Exception ex)
				{
					throw new Exception(sSql+"\r\n"+ex.getMessage());
				}
				finally
				{
					if(pstmt != null) pstmt.close();
				}
				
				logger.info("Support Request >> Saved To Database");
				
				if(s_original_issue == null) s_original_issue = "";
				if(s_further_info == null) s_further_info = "";
				
				logger.info("Support Request >> Cleaned Variables");
				
				Properties props = new Properties();
				props.put("mail.smtp.host", Registry.getKey("mail_smtp_host"));
				Session s = Session.getInstance(props,null);
				
				logger.info("Support Request >> SMTP Info Set");
				
				String sEmailText = "<html><head></head><body>\n";
				sEmailText += "<style type=text/css>\n";
				sEmailText += "TABLE, TD { font-family:Verdana; font-size:8pt; }\n";
				sEmailText += "TH { align:left; text-align:left; background-color:#3E3E87; color:#FFFFFF; font-family:Verdana; font-size:8pt; }\n";
				sEmailText += "</style>\n";
				sEmailText += "<table cellspacing=0 cellpadding=3 border=0>\n";
				sEmailText += "<tr><th colspan=2><b>Support Request</b></th></tr>\n";
				sEmailText += "<tr><td><b>Support Ticket #:</b></td><td>" + s_cust_id + "-" + s_ticket_id + "</td></tr>\n";
				sEmailText += "<tr><td><b>Area of Request:</b></td><td>" + s_subject + "</td></tr>\n";
				sEmailText += "<tr><td><b>Request From:</b></td><td>" + s_user_name + "</td></tr>\n";
				sEmailText += "<tr><td><b>Customer:</b></td><td>" + s_cust_name + " (" + s_cust_id + ")</td></tr>\n";
				sEmailText += "<tr><td><b>Email Address:</b></td><td>" + s_email_from + "</td></tr>\n";
				sEmailText += "<tr><td><b>Phone:</b></td><td>" + s_phone + "</td></tr>\n";
				sEmailText += "<tr><td><b>Technical Info:</b></td><td>" + s_browser_info + "</td></tr>\n";
				sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n";
				sEmailText += "<tr><th colspan=2>Question/Problem</th></tr>\n";
				sEmailText += "<tr><td colspan=2>" + s_original_issue.replaceAll("\n", "<br>") + "</td></tr>\n";
				sEmailText += "<tr><td colspan=2>&nbsp;</td></tr>\n";
				sEmailText += "<tr><th colspan=2>Specific Items</th></tr>\n";
				sEmailText += "<tr><td colspan=2>" + s_further_info.replaceAll("\n", "<br>") + "</td></tr>\n";
				sEmailText += "<tr><td colspan=2>&nbsp;</td></tr></table></body></html>\n";
				
				logger.info("Support Request >> EMail HTML Built");
				
				MimeMessage message = new MimeMessage(s);
				
				logger.info("Support Request >> Message Created");
				
				InternetAddress from = new InternetAddress(s_email_from);
				message.setFrom(from);
				
				logger.info("Support Request >> From Address Set");
				
				InternetAddress to = new InternetAddress(s_email_to);
				message.addRecipient(Message.RecipientType.TO, to);
				
				//if (!("null".equals(s_email_cc)) && !("".equals(s_email_cc)))
				//{
				//	InternetAddress cc = new InternetAddress(s_email_cc);
				//	message.addRecipient(Message.RecipientType.CC, cc);
				//}
				
				logger.info("Support Request >> To/Cc Address Set");
				
				String subject = "Support Ticket # " + s_cust_id + "-" + s_ticket_id;
				message.setSubject(subject);
				message.setContent(sEmailText, "text/html");
				
				logger.info("Support Request >> Subject and Content Set");
				
				Transport.send(message);
				
				logger.info("Support Request >> Message Sent");
				
				out.println("<SupportTicket><ticket_id><![CDATA[" + s_ticket_id + "]]></ticket_id></SupportTicket>");
			}
			else
			{
				out.println("<ERROR>Error retrieving XML in ADM->help_doc_info.jsp.  XML sent to ADM did not parse correctly.</ERROR>");
			}
		}
	}
}
catch(Exception ex)
{ 
	logger.error("Exception: ", ex);
	ex.printStackTrace(new PrintWriter(out));	
}
finally
{
	if(stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
	out.flush();
}
%>
