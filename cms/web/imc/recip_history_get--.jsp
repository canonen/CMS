<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			com.britemoon.cps.imc.*, 
			com.britemoon.cps.cnt.*, 
			com.britemoon.cps.que.*, 
			com.britemoon.cps.sbs.*, 
			com.britemoon.cps.tgt.*, 
			java.io.*, 
			java.sql.*, 
			java.util.*, 
			java.util.*, 
			java.sql.*, 
			org.w3c.dom.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String sSql = null;

byte[] b = null;

int iCount = 0;

ConnectionPool	cp		= null;
Connection 		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null;

try
{
	Element eNote = XmlUtil.getRootElement(request);  
	
	if (eNote == null)
	{
		out.println("<ERROR level=\"1\">Error retrieving XML in CPS->recip_history_get.jsp.  XML sent to CPS did not parse correctly.</ERROR>");
	}
	else
	{
		
		String sAction = XmlUtil.getChildTextValue(eNote,"action");
		
		if (sAction == null || sAction.equals(""))
		{
			out.println("<ERROR level=\"2\">Error retrieving XML in CPS->recip_history_get.jsp.  XML sent to CPS did not parse correctly.</ERROR>");
		}
		else
		{
			String sCustID = XmlUtil.getChildTextValue(eNote,"cust_id");

			if ((sCustID == null) || (sCustID.trim().equals("")))
			{
				throw new Exception ("No recip_history_get.jsp Customer specified.");
			}
		
			try
			{
				cp = ConnectionPool.getInstance();
				conn = cp.getConnection(this);
				stmt = conn.createStatement();
			}
			catch (SQLException e)
			{
				throw new Exception ("Could not open db");
			}
			
			if ((sAction.equals("camp")) || (sAction.equals("camp_before")) || (sAction.equals("camp_after")))
			{
				String sRecipID = XmlUtil.getChildTextValue(eNote,"recip_id");
				String selectMsgID = XmlUtil.getChildTextValue(eNote,"msg_id");
				
				if ((sRecipID == null) || (sRecipID.trim().equals("")))
				{
					throw new Exception ("No recip_history_get.jsp Recipient specified.");
				}

				if ((selectMsgID == null) || (selectMsgID.trim().equals("")))
				{
					selectMsgID = "";
				}
				
				String sRequest = "";	 
			
				String sMsgID = "";	 
				String sCampID = "";	 
				String sSendDate = "";	 
				String sSendDateTxt = "";	 
				String iReceived = "";	 
				String iBBack = "";	 
				String iUnsub = "";	 
				String iOpen = "";	 
				String iClick = "";	 
				String iVisit = "";	 
				String iSubs = "";
				
				String sOriginCampID = "";
				String sSampleID = "";
				String sTypeID = "";
				String sCampName = "";
				String sFromName = "";
				String sFromAddress = "";
				String sContentID = "";
				String sContentName = "";
				String sFilterID = "";
				String sFilterName = "";
				String sResponseForwarding = "";
				String sSubjectLine = "";	 
				
				String sEventID = "";	 
				String sEventName = "";	 
				String sEventTypeID = "";	 
				String sEventTypeName = "";	 
				String sEventDate = "";	 
				String sEventDateTxt = "";	 
				String sEventSourceID = "";

				sRequest = new String("<request><action>" + sAction + "</action><recip_id>" + sRecipID + "</recip_id><cust_id>" + sCustID + "</cust_id><msg_id>" + selectMsgID + "</msg_id></request>");	
				
				String sResponse = Service.communicate(ServiceType.RRCP_RECIP_HISTORY_GET, sCustID, sRequest);      
				Element eRoot = XmlUtil.getRootElement(sResponse);
				//System.out.println("xml=" + sResponse); 
				       
				if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
				{
					XmlElementList xelEvents = null;
					Element eEvent = null;
					int nCount = 0;
					
					XmlElementList xelCamps = XmlUtil.getChildrenByName(eRoot, "message");
					Element eCamp = null;
					int tCount = xelCamps.getLength();

					out.println("<recipient_history>");
				
					if (tCount > 0)
					{
						for (int t=0; t < tCount; t++)
						{
							sMsgID = "";	 
							sCampID = "";	 
							sSendDate = "";	 
							sSendDateTxt = "";	 
							iReceived = "";	 
							iBBack = "";	 
							iUnsub = "";	 
							iOpen = "";	 
							iClick = "";	 
							iVisit = "";	 
							iSubs = "";
							
							sOriginCampID = "";
							sSampleID = "";
							sTypeID = "";
							sCampName = "";
							sFromName = "";
							sFromAddress = "";
							sContentID = "";
							sContentName = "";
							sFilterID = "";
							sFilterName = "";
							sResponseForwarding = "";
							sSubjectLine = "";
							
							eCamp = (Element) xelCamps.item(t);
							
							sMsgID 			= XmlUtil.getChildTextValue(eCamp, "msg_id");
							sCampID 		= XmlUtil.getChildTextValue(eCamp, "camp_id");
							sSendDate 		= XmlUtil.getChildCDataValue(eCamp, "send_date");
							sSendDateTxt 	= XmlUtil.getChildCDataValue(eCamp, "send_date_txt");
							iReceived 		= XmlUtil.getChildTextValue(eCamp, "received");
							iBBack 			= XmlUtil.getChildTextValue(eCamp, "bback");
							iUnsub 			= XmlUtil.getChildTextValue(eCamp, "unsub");
							iOpen 			= XmlUtil.getChildTextValue(eCamp, "read_qty");
							iClick 			= XmlUtil.getChildTextValue(eCamp, "click_qty");
							iVisit 			= XmlUtil.getChildTextValue(eCamp, "visit_qty");
							iSubs 			= XmlUtil.getChildTextValue(eCamp, "sub_qty");
							
							out.println("<message>");
							out.println("	<msg_id>" + sMsgID + "</msg_id>");
							out.println("	<camp_id>" + sCampID + "</camp_id>");
							out.println("	<send_date><![CDATA[" + sSendDate + "]]></send_date>");
							out.println("	<send_date_txt><![CDATA[" + sSendDateTxt + "]]></send_date_txt>");
							out.println("	<received>" + iReceived + "</received>");
							out.println("	<bback>" + iBBack +"</bback>");
							out.println("	<unsub>" + iUnsub + "</unsub>");
							out.println("	<read_qty>" + iOpen + "</read_qty>");
							out.println("	<click_qty>" + iClick + "</click_qty>");
							out.println("	<visit_qty>"+ iVisit + "</visit_qty>");
							out.println("	<sub_qty>" + iSubs + "</sub_qty>");
							
							sSql = "select origin_camp_id, isnull(sample_id, 0) from cque_campaign with(nolock) where camp_id = '" + sCampID + "'";
							
							rs = stmt.executeQuery(sSql);
							
							while (rs.next())
							{
								sOriginCampID = rs.getString(1);
								sSampleID = rs.getString(2);
							}
							
							rs.close();
							
							CampSampleset camp_sampleset = new CampSampleset();
							camp_sampleset.s_camp_id = sOriginCampID;
							
							if(camp_sampleset.retrieve() > 0)
							{
								Campaign 			camp 				= new Campaign();
								CampEditInfo 		camp_edit_info 		= null;
								CampList 			camp_list 			= null;
								CampSendParam 		camp_send_param 	= null;
								MsgHeader 			msg_header 			= null;
								Schedule 			schedule 			= null;
								LinkedCamp 			linked_camp 		= null;
								FilterStatistic 	filter_statistic 	= null;
								FromAddress 	fa 					= null;
								
								camp.s_camp_id = sOriginCampID;
								if(camp.retrieve() < 1) throw new Exception("Campaign does not exist");
								
								camp_send_param 	= new CampSendParam(sOriginCampID);
								schedule 			= new Schedule(sOriginCampID);
								msg_header 			= new MsgHeader(sOriginCampID);
								camp_list 			= new CampList(sOriginCampID);
								camp_edit_info 		= new CampEditInfo(sOriginCampID);
								linked_camp 		= new LinkedCamp(sOriginCampID);
								filter_statistic 	= new FilterStatistic(camp.s_filter_id);
								camp_sampleset 		= new CampSampleset(sOriginCampID);
								
								sCampName = camp.s_camp_name;
								sTypeID = camp.s_type_id;
								
								if (camp_sampleset.s_from_name_flag == null)
								{
									sFromName = msg_header.s_from_name;
								}
								
								if (camp_sampleset.s_from_address_flag == null)
								{
									if (msg_header.s_from_address == null)
									{
										fa = new FromAddress(msg_header.s_from_address_id);
										sFromAddress = fa.s_prefix + "@" + fa.s_domain;
									}
									else
									{
										sFromAddress = msg_header.s_from_address;
									}
								}
								
								if (camp_sampleset.s_subject_flag == null)
								{
									sSubjectLine = msg_header.s_subject_html;
								}
								
								if (camp_sampleset.s_cont_flag == null)
								{
									sContentID = camp.s_cont_id;
									
									Content cont = new Content(sContentID);
									sContentName = cont.s_cont_name;
								}
								
								sFilterID = camp.s_filter_id;
								
								com.britemoon.cps.tgt.Filter tGroup = new com.britemoon.cps.tgt.Filter(sFilterID);
								sFilterName = tGroup.s_filter_name;
								
								sResponseForwarding = camp_send_param.s_response_frwd_addr;
								
								CampSample camp_sample = null;
								
								if ("0".equals(sSampleID))
								{
									camp_sample = new CampSample();
									camp_sample.s_camp_id = camp.s_camp_id;
									camp_sample.s_sample_id = "0";
									camp_sample.s_from_name = msg_header.s_from_name;
									camp_sample.s_from_address = msg_header.s_from_address;
									camp_sample.s_from_address_id = msg_header.s_from_address_id;
									camp_sample.s_subject_html = msg_header.s_subject_html;
									camp_sample.s_cont_id = camp.s_cont_id;
								}
								else
								{
									if(camp_sampleset.s_camp_qty != null)
									{
										camp_sample = new CampSample(camp.s_camp_id, sSampleID);
									}
								}
								
								if(camp_sampleset.s_from_name_flag != null)
								{
									sFromName = camp_sample.s_from_name;
								}
								
								if(camp_sampleset.s_from_address_flag != null)
								{
									if (camp_sample.s_from_address == null)
									{
										fa = new FromAddress(camp_sample.s_from_address_id);
										sFromAddress = fa.s_prefix + "@" + fa.s_domain;
									}
									else
									{
										sFromAddress = camp_sample.s_from_address;
									}
								}
								
								if(camp_sampleset.s_subject_flag != null)
								{
									sSubjectLine = camp_sample.s_subject_html;
								}
								
								if(camp_sampleset.s_cont_flag != null)
								{
									sContentID = camp_sample.s_cont_id;
									
									Content cont = new Content(sContentID);
									sContentName = cont.s_cont_name;
								}
								
							}
							else
							{
								Campaign 		camp 				= new Campaign();
								CampEditInfo 	camp_edit_info 		= null;
								CampList 		camp_list 			= null;
								CampSendParam 	camp_send_param 	= null;
								MsgHeader 		msg_header 			= null;
								Schedule 		schedule 			= null;
								LinkedCamp 		linked_camp 		= null;
								FromAddress 	fa 					= null;
								
								camp.s_camp_id = sCampID;
								if(camp.retrieve() < 1) throw new Exception("Campaign does not exist");
								
								camp_send_param 	= new CampSendParam(sOriginCampID);
								schedule 			= new Schedule(sOriginCampID);
								msg_header 			= new MsgHeader(sOriginCampID);
								camp_list 			= new CampList(sOriginCampID);
								camp_edit_info 		= new CampEditInfo(sOriginCampID);
								
								sTypeID = camp.s_type_id;
								sCampName = camp.s_camp_name;
								sFromName = msg_header.s_from_name;
								
								if (msg_header.s_from_address == null)
								{
									fa = new FromAddress(msg_header.s_from_address_id);
									sFromAddress = fa.s_prefix + "@" + fa.s_domain;
								}
								else
								{
									sFromAddress = msg_header.s_from_address;
								}
								
								sSubjectLine = msg_header.s_subject_html;
								sContentID = camp.s_cont_id;
								
								Content cont = new Content(sContentID);
								sContentName = cont.s_cont_name;
								
								sFilterID = camp.s_filter_id;
								
								com.britemoon.cps.tgt.Filter tGroup = new com.britemoon.cps.tgt.Filter(sFilterID);
								sFilterName = tGroup.s_filter_name;
								
								if (camp.s_type_id.equals("3"))
								{
									sFilterID = linked_camp.s_form_id;
									
									Form frm = new Form(sFilterID);
									sFilterName = "FORM: " + frm.s_form_name;
								}
								
								sResponseForwarding = camp_send_param.s_response_frwd_addr;
								
							}
							
							out.println("	<origin_camp_id>" + sOriginCampID + "</origin_camp_id>");
							out.println("	<sample_id>" + sSampleID + "</sample_id>");
							out.println("	<type_id>" + sTypeID + "</type_id>");
							out.println("	<camp_name><![CDATA[" + sCampName + "]]></camp_name>");
							out.println("	<from_name><![CDATA[" + sFromName + "]]></from_name>");
							out.println("	<from_address><![CDATA[" + sFromAddress + "]]></from_address>");
							out.println("	<cont_id>" + sContentID + "</cont_id>");
							out.println("	<cont_name><![CDATA[" + sContentName + "]]></cont_name>");
							out.println("	<filter_id>" + sFilterID + "</filter_id>");
							out.println("	<filter_name><![CDATA[" + sFilterName + "]]></filter_name>");
							out.println("	<response_forwarding><![CDATA[" + sResponseForwarding + "]]></response_forwarding>");
							out.println("	<subject_html><![CDATA[" + sSubjectLine + "]]></subject_html>");
							
							xelEvents = XmlUtil.getChildrenByName(eCamp, "event");
							eEvent = null;
							nCount = xelEvents.getLength();
							
							if (nCount > 0)
							{
								for (int n=0; n < nCount; n++)
								{
									sEventID 		= "";
									sEventTypeID 	= "";
									sEventName 		= "";
									sEventTypeName 	= "";
									sEventDate 		= "";
									sEventDateTxt 	= "";
									sEventSourceID 	= "";
									
									eEvent = (Element) xelEvents.item(n);
									
									sEventID 		= XmlUtil.getChildTextValue(eEvent, "event_id");
									sEventTypeID 	= XmlUtil.getChildTextValue(eEvent, "type_id");
									sEventName 		= XmlUtil.getChildCDataValue(eEvent, "event_name");
									sEventTypeName 	= XmlUtil.getChildCDataValue(eEvent, "event_type");
									sEventDate 		= XmlUtil.getChildCDataValue(eEvent, "event_date");
									sEventDateTxt 	= XmlUtil.getChildCDataValue(eEvent, "event_date_txt");
									sEventSourceID 	= XmlUtil.getChildTextValue(eEvent, "source_id");
									
									out.println("		<event>");
									out.println("			<event_id>" + sEventID + "</event_id>");
									out.println("			<type_id>" + sEventTypeID + "</type_id>");
									out.println("			<event_name><![CDATA[" + sEventName + "]]></event_name>");
									out.println("			<event_type><![CDATA[" + sEventTypeName + "]]></event_type>");
									out.println("			<event_date><![CDATA[" + sEventDate + "]]></event_date>");
									out.println("			<event_date_txt><![CDATA[" + sEventDateTxt + "]]></event_date_txt>");
									out.println("			<source_id>" + sEventSourceID + "</source_id>");
									out.println("		</event>");
									
								}
							}
							
							out.println("</message>");
						}
					}
					out.println("</recipient_history>");
				}
			}
			else if (sAction.equals("update_hist"))
			{
				String sRecipID = XmlUtil.getChildTextValue(eNote,"recip_id");
				
				if ((sRecipID == null) || (sRecipID.trim().equals("")))
				{
					throw new Exception ("No recip_history_get.jsp Recipient specified.");
				}
								
				String sRequest = "";
				
				sRequest = new String("<request><action>" + sAction + "</action><recip_id>" + sRecipID + "</recip_id><cust_id>" + sCustID + "</cust_id></request>");	

				String sResponse = Service.communicate(ServiceType.RRCP_RECIP_HISTORY_GET, sCustID, sRequest);      
				Element eRoot = XmlUtil.getRootElement(sResponse);
				//System.out.println("xml=" + sResponse); 

				if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
				{
					out.println(sResponse);
				}
			}
			else
			{
				out.println("<ERROR level=\"3\">Error retrieving XML in CPS->recip_history_get.jsp.  XML sent to CPS did not parse correctly.</ERROR>");
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
