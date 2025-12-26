<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.wfl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%  
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);
boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

String STEP = request.getParameter("step");
String CATEGORY_ID = request.getParameter("category_id");
String CAMP_ID = request.getParameter("camp_id");
String CAMP_TYPE_ID = "2"; // we only deal with standard campaigns
boolean STANDARD_UI = true;

if ((CATEGORY_ID == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
{
	CATEGORY_ID = ui.s_category_id;
}

if (STEP == "" || STEP == "null" || STEP == null) {
	STEP = "1";
}

if (CAMP_ID != null && CAMP_ID.equals("null")) {
	CAMP_ID = "";
}
 
boolean isPrintCampaign = false;

ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 
boolean	isDone			= false;
boolean isTesting		= false;
boolean isSending		= false;

int tmpType				= 0;
int tmpStatus			= 0;
String StatusCampID		= "0";
String RecipsQueued		= "0";
String RecipsSent		= "0";
String DescStatusText	= "";	
String[] history		= new String[4];
String sql				= "";

String		ORIGIN_CAMP_ID			= "";
String		STATUS_ID				= "0";
String		FILTER_ID				= "";
String		CONT_ID					= "";
String		TEST_LIST_ID			= "";
String		FROM_ADDRESS_ID			= "";
String		CAMP_NAME				= "New Campaign";
String		FROM_NAME				= "";
String		SUBJ_HTML				= "";
String		RESPONSE_FRWD_ADDR		= "";
String		START_DATE				= "";
String		END_DATE				= "";
String		RECIP_QTY_LIMIT			= "0";
String		QUEUE_DATE				= "";
String		EXCLUSION_LIST_ID		= "";
String		LIMIT_PER_HOUR			= "0";
String		REPLY_TO	 			= "";
String		MSG_PER_EMAIL821_LIMIT	= "0";
String		LINKED_CAMP_ID			= "";

history[0] = "";
history[1] = "";
history[2] = "";
history[3] = "";

String filterHtml_s2 = "";
String sSql = "";
String contEditFrame = "../cont/cont_template_login.jsp?enter_wizard=1";
String filterHtml_s4 = "No Audience Selected";
StringBuilder test_list_option = new StringBuilder();
StringBuilder from_address_option = new StringBuilder();
StringBuilder linked_camp_option = new StringBuilder();
StringBuilder type_id2_option = new StringBuilder();
StringBuilder status_id_option = new StringBuilder();
StringBuilder oneHistory_tr = new StringBuilder();
StringBuilder report_tr = new StringBuilder();


String htmlCategories = "";
String CURRENT_TIME = null;
boolean nonEmailFinger = false;

boolean oneHistory = false;
boolean nonTestSent = false;
 
String histTemp[] = new String[9];
String WizardID = "";	
try	{
	
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("wizard.jsp");
	stmt = conn.createStatement();
	 
	if ( CAMP_ID != null && !CAMP_ID.equals("") && !CAMP_ID.equals("null")) {
		/* for editing, get stored values from database using the camp_id */
		sql =
			"SELECT c.camp_id, " +
			"	c.type_id, " +
			"	c.status_id, " +
			"	c.filter_id, " +
			"	c.cont_id, " +
			"	isnull(l.test_list_id,''), " +
			"	isnull(h.from_address_id,''), " +
			"	c.camp_name, " +
			"	isnull(h.from_name,''), " +
			"	isnull(h.subject_html,''), " +
			"	isnull(p.response_frwd_addr,''), " +
			"	CONVERT(varchar(25), isnull(s.start_date,''), 0), " +
			"	p.recip_qty_limit, " +
			"	isnull(l.exclusion_list_id,''), " +
			"	p.limit_per_hour, " +
			"	e.create_date, " +
			"	u1.user_name, " +
			"	e.modify_date, " +
			"	u2.user_name, " +
			"	isnull(h.reply_to,''), " +
			"	p.msg_per_email821_limit, " +
			"	isnull(lc.linked_camp_id,''), " +
			"	CONVERT(varchar(25), isnull(s.end_date,''), 0), " +
			"	CONVERT(varchar(25), isnull(p.queue_date,''), 0) " +
//			"	s.end_date, " +
//			"	p.queue_date " +
			" FROM cque_campaign c" +
			"	LEFT OUTER JOIN cque_camp_send_param p ON c.camp_id = p.camp_id" +
			"	LEFT OUTER JOIN cque_camp_list l ON c.camp_id = l.camp_id" +
			"	LEFT OUTER JOIN cque_msg_header h ON c.camp_id = h.camp_id" +
			"	LEFT OUTER JOIN cque_schedule s ON c.camp_id = s.camp_id" +
			"	INNER JOIN cque_linked_camp lc ON c.camp_id  = lc.camp_id" +
			"	INNER JOIN (cque_camp_edit_info e" +
			"			INNER JOIN ccps_user u1 ON e.creator_id  = u1.user_id" +
			"			INNER JOIN ccps_user u2 ON e.modifier_id = u2.user_id)" +
			"		ON c.camp_id  = e.camp_id" +
			" WHERE c.camp_id  = " + CAMP_ID + 
			"	AND c.cust_id  = " + cust.s_cust_id;

		rs = stmt.executeQuery(sql);
		if ( rs.next() )	{
			ORIGIN_CAMP_ID			= rs.getString(1);
			CAMP_TYPE_ID			= rs.getString(2);
			STATUS_ID				= rs.getString(3);
			FILTER_ID				= rs.getString(4);
			CONT_ID					= rs.getString(5);
			TEST_LIST_ID			= rs.getString(6);
			FROM_ADDRESS_ID			= rs.getString(7);
			CAMP_NAME				= new String(rs.getBytes(8),"UTF-8");
			FROM_NAME				= new String(rs.getBytes(9),"ISO-8859-1");
			SUBJ_HTML				= new String(rs.getBytes(10),"ISO-8859-1");
			RESPONSE_FRWD_ADDR		= rs.getString(11);
			START_DATE				= rs.getString(12);
			RECIP_QTY_LIMIT			= rs.getString(13);
			EXCLUSION_LIST_ID		= rs.getString(14);
			LIMIT_PER_HOUR			= rs.getString(15);
			history[0]			  = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(16));
			history[1]			  = rs.getString(17);
			history[2]			  = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(18));
			history[3]			  = rs.getString(19);
			REPLY_TO				= rs.getString(20);
			MSG_PER_EMAIL821_LIMIT  = rs.getString(21);
			LINKED_CAMP_ID		  = rs.getString(22);
			END_DATE				= rs.getString(23);
			QUEUE_DATE				= rs.getString(24);						
		}
		rs.close(); 

		history[0] = ( history[0] == null ) ? "" : history[0].replaceAll(",","");
		history[1] = ( history[1] == null ) ? "" : history[1];
		history[2] = ( history[2] == null ) ? "" : history[2].replaceAll(",","");
		history[3] = ( history[3] == null ) ? "" : history[3];

		/* Find out what state this campaign is in based on camps with CAMP_ID origin_camp_id */
		sql =
			"SELECT type_id, " +
			"		status_id, " +
			"		camp_id " +
			"  FROM cque_campaign " +
			" WHERE origin_camp_id = " + CAMP_ID + 
			" ORDER BY camp_id";
		rs = stmt.executeQuery(sql);
		while (rs.next()) {
			tmpType = rs.getInt(1);
			tmpStatus = rs.getInt(2);
			StatusCampID = rs.getString(3);
			
			if (tmpType == 1) {
				//Test, see if it is in the middle of testing
				if (tmpStatus < CampaignStatus.DONE) {
					isTesting = true;
					break;
				}
			}
			else {
				//Normal campaign
				STATUS_ID = String.valueOf(tmpStatus);
				if (tmpStatus < CampaignStatus.DONE) {
					isSending = true;
					break;
				}
				else {
					isDone = true;
					break;
				}
			}		
		}
				
		/* Status Description Info */
		sql =
			" SELECT c.camp_id, " +
			"	s.recip_queued_qty, " +
			"	s.recip_sent_qty, " +
			"	c.status_id" +
			" FROM cque_campaign c " +
			"	LEFT OUTER JOIN cque_camp_statistic s ON c.camp_id = s.camp_id" +
			" WHERE c.camp_id = " + StatusCampID +
			"	AND c.cust_id= " + cust.s_cust_id;
		rs = stmt.executeQuery(sql);
		
		int sDescStatusID = 0;
		while (rs.next()) {
			RecipsQueued = rs.getString(2);
			RecipsSent = rs.getString(3);
			sDescStatusID = rs.getInt(4);
		}
		
		if ( sDescStatusID == CampaignStatus.READY_TO_BE_QUEUED || 
			 sDescStatusID == CampaignStatus.RECIPS_QUEUED || 
			 sDescStatusID == CampaignStatus.JTK_SETUP_COMPLETE ) {
			DescStatusText = "queued to send";
		}
		else {
			DescStatusText = "ready to send";
		}
	}
	
	// begin here
	
	//Categories

	if (null != CONT_ID)
	{
		if (!CONT_ID.equals(""))
		{
			sql =
				" SELECT c.category_id, c.category_name, oc.object_id" +
				" FROM ccps_category c" +
					" LEFT OUTER JOIN ccps_object_category oc" +
					" ON (c.category_id = oc.category_id" +
						" AND c.cust_id = oc.cust_id" +
						" AND oc.object_id="+CAMP_ID+
						" AND oc.type_id="+ObjectType.CAMPAIGN+")" +
				" WHERE c.cust_id="+cust.s_cust_id;

			rs = stmt.executeQuery(sql);
			
			String sCategoryId = null;
			String sCategoryName = null;
			String sObjectId = null;
			
			while (rs.next())
			{
				sCategoryId = rs.getString(1);
				sCategoryName = new String(rs.getBytes(2), "ISO-8859-1");
				sObjectId = rs.getString(3);
				
				htmlCategories += "<OPTION value=\""+sCategoryId+"\" "+(((sObjectId!=null)||((CATEGORY_ID!=null)&&(CATEGORY_ID.equals(sCategoryId))))?"selected":"")+">" +
					sCategoryName+
					"</OPTION>";
			}
		}
	}
	
	/* why do we need the current date? */

	rs = stmt.executeQuery("SELECT CONVERT(varchar(25), getdate(), 0)");
	if (rs.next())
		CURRENT_TIME = rs.getString(1);
	rs.close();
	CURRENT_TIME = (CURRENT_TIME == null)?"":CURRENT_TIME;
	

	if (null != CONT_ID)
	{
		if (!CONT_ID.equals(""))
		{
			rs = stmt.executeQuery(
				" SELECT cei.wizard_id, c.cont_name" +
				"  FROM ccnt_content c, ccnt_cont_edit_info cei" +
				" WHERE c.cust_id = " + cust.s_cust_id +
				"	AND c.status_id <> 90" +
				"	AND c.type_id = 20" +
				"	AND c.origin_cont_id IS NULL" +
				"	AND c.cont_id = " + CONT_ID +
				"	AND c.cont_id = cei.cont_id " +
				" ORDER BY c.cont_id DESC");
			
			while( rs.next() )
			{
				WizardID = rs.getString(1);
			}
			rs.close();
		}
	}
	

	//System.out.println("wizard is = " + WizardID);	
	if ((WizardID != null && !WizardID.equals("")) && (STEP.equals("3"))) {
		contEditFrame = "/cms/ui/jsp/ctm/pageedit.jsp?isEdit=true&contentID=" + WizardID;
	}

	/* get target group for step 2 */

	if ( (CATEGORY_ID == null) || (CATEGORY_ID.equals("0")) )
	{
		sSql =
			" SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
			" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
			" FROM ctgt_filter" +
			" WHERE cust_id = " + cust.s_cust_id +
			" AND origin_filter_id IS NULL" +
			" AND filter_name IS NOT NULL" +
			" AND type_id=" + FilterType.MULTIPART +
			" AND usage_type_id=" + FilterUsageType.REGULAR +
			" AND status_id <> " + FilterStatus.DELETED +  
			" AND ISNULL(aprvl_status_flag,1) <> 0" +	
			((FILTER_ID!=null && !FILTER_ID.equals(""))?" OR filter_id = " + FILTER_ID:"") +
			" ORDER BY 1 DESC";
	}
	else
	{
		sSql =
			" SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
			" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
			" FROM ctgt_filter f, ccps_object_category oc" +
			" WHERE (f.cust_id = " + cust.s_cust_id +
			" AND f.origin_filter_id IS NULL" +
			" AND f.filter_name IS NOT NULL" +
			" AND f.type_id=" + FilterType.MULTIPART +
			" AND f.filter_id = oc.object_id" +
			" AND f.usage_type_id=" + FilterUsageType.REGULAR +
			" AND f.status_id <> " + FilterStatus.DELETED +	  
				" AND status_id <> " + FilterStatus.PENDING_APPROVAL +		 
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + CATEGORY_ID + ")" +
			((FILTER_ID!=null && !FILTER_ID.equals(""))?" OR f.filter_id = " + FILTER_ID:"") +
			" ORDER BY 1 DESC";	
	}
	rs = stmt.executeQuery(sSql);
	String sFilterId = "";
	String sFilterName = "";
	String sDeleted = "0";
	while( rs.next() )
	{
		sFilterId = rs.getString(1);
		sFilterName = new String(rs.getBytes(2),"UTF-8");
		sDeleted = rs.getString(3);
		
		filterHtml_s2 += "<OPTION value=\"" + ((sDeleted.equals("1"))?"":sFilterId) + "\"" + ((sFilterId.equals(FILTER_ID))?" selected":"") + ">";
		filterHtml_s2 += HtmlUtil.escape(sFilterName);
		filterHtml_s2 += "</OPTION>\r\n";
	}

	// get target group for step 4

	if (FILTER_ID != null && !FILTER_ID.equals("") && !FILTER_ID.equals("null")) {
		if ( (CATEGORY_ID == null) || (CATEGORY_ID.equals("0")) )
		{
			sSql =
				" SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
				" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
				" FROM ctgt_filter" +
				" WHERE cust_id = " + cust.s_cust_id +
				" AND origin_filter_id IS NULL" +
				" AND filter_name IS NOT NULL" +
				" AND type_id=" + FilterType.MULTIPART +
				" AND usage_type_id=" + FilterUsageType.REGULAR +
				" AND status_id <> " + FilterStatus.DELETED +  
				" AND ISNULL(aprvl_status_flag,1) <> 0" +	
				((FILTER_ID!=null && !FILTER_ID.equals(""))?" OR filter_id = " + FILTER_ID:"") +
				" ORDER BY 1 DESC";
		}
		else
		{
			sSql =
				" SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
				" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
				" FROM ctgt_filter f, ccps_object_category oc" +
				" WHERE (f.cust_id = " + cust.s_cust_id +
				" AND f.origin_filter_id IS NULL" +
				" AND f.filter_name IS NOT NULL" +
				" AND f.type_id=" + FilterType.MULTIPART +
				" AND f.filter_id = oc.object_id" +
				" AND f.usage_type_id=" + FilterUsageType.REGULAR +
				" AND f.status_id <> " + FilterStatus.DELETED +	  
					" AND status_id <> " + FilterStatus.PENDING_APPROVAL +		 
				" AND oc.type_id = " + ObjectType.FILTER +
				" AND oc.cust_id = " + cust.s_cust_id +
				" AND oc.category_id = " + CATEGORY_ID + ")" +
				((FILTER_ID!=null && !FILTER_ID.equals(""))?" OR f.filter_id = " + FILTER_ID:"") +
				" ORDER BY 1 DESC";	
		}
		rs = stmt.executeQuery(sSql);
		sFilterId = "";
		sFilterName = "";
		sDeleted = "0";
		while( rs.next() )
		{
			sFilterId = rs.getString(1);
			sFilterName = new String(rs.getBytes(2),"UTF-8");
			sDeleted = rs.getString(3);
			
			if (sFilterId.equals(FILTER_ID))
			{
				filterHtml_s4 = HtmlUtil.escape(sFilterName);
			}
		}
	}
	
	
	rs = stmt.executeQuery("SELECT l.list_id, l.list_name, t.type_name FROM cque_email_list l, cque_list_type t " +
			"WHERE l.type_id = t.type_id AND (l.type_id = 2 OR l.type_id = 5) AND list_name not like 'ApprovalRequest(%)' " +
			"AND l.cust_id =" + cust.s_cust_id + " ORDER BY l.list_id DESC");
	while( rs.next() ) {  
		test_list_option.append("<option value="+rs.getString(1)+"> "+ new String(rs.getBytes(2),"ISO-8859-1") +" ( " + new String(rs.getBytes(3),"ISO-8859-1") + " ) </option>");
	  }  
	rs.close();
	
	 
	rs = stmt.executeQuery("SELECT from_address_id, prefix+'@'+[domain] FROM ccps_from_address WHERE cust_id = "+cust.s_cust_id+" ORDER BY from_address_id DESC");
	while( rs.next() ) { 
		 from_address_option.append("<option value="+rs.getString(1)+">"+rs.getString(2)+"</option>");
	 }
	rs.close();
 
	
	rs = stmt.executeQuery("SELECT a.attr_name FROM ccps_cust_attr ca, ccps_attribute a " +
		"WHERE ca.cust_id = "+cust.s_cust_id+" AND ca.attr_id = a.attr_id AND ca.fingerprint_seq IS NOT NULL");
	while (rs.next()) {
	if (!rs.getString(1).equals("email_821"))
		nonEmailFinger = true;
	}
		 
	String campTypes = "3";
	if ( (CATEGORY_ID == null) || (CATEGORY_ID.equals("0")) ) {
		rs = stmt.executeQuery("SELECT DISTINCT origin_camp_id, camp_name" +
						" FROM cque_campaign" +
						" WHERE type_id in ("+campTypes+")" +
						" AND cust_id = " + cust.s_cust_id +
						" AND status_id > 0 " +
						" AND origin_camp_id IS NOT NULL" +
						" ORDER BY origin_camp_id DESC");
	} else {
		rs = stmt.executeQuery(	"SELECT DISTINCT c.origin_camp_id, c.camp_name" +
						" FROM cque_campaign c, ccps_object_category oc" +
						" WHERE c.type_id in ("+campTypes+")" +
						" AND c.cust_id = " + cust.s_cust_id +
						" AND c.status_id > 0 " +
						" AND origin_camp_id IS NOT NULL" +
						" AND ((c.origin_camp_id = oc.object_id" +
						" AND oc.type_id = " + ObjectType.CAMPAIGN +
						" AND oc.cust_id = " + cust.s_cust_id +
						" AND oc.category_id = " + CATEGORY_ID + ")" +
						((LINKED_CAMP_ID.length()>0)? " OR c.origin_camp_id = "+LINKED_CAMP_ID:"") + ")" +
						" ORDER BY c.origin_camp_id DESC");
	}
	while( rs.next() ) { 
		linked_camp_option.append("<option value="+rs.getString(1)+"> "+ new String(rs.getBytes(2),"ISO-8859-1") +"</option>");
   }
   rs.close(); 
   
  
   	rs = stmt.executeQuery("SELECT type_id, display_name FROM cque_camp_type");
   	while( rs.next() ) { 
   		type_id2_option.append("<OPTION value="+rs.getString(1)+">"+rs.getString(2)+"</OPTION>");
   	}
   	rs.close(); 
	
   	
   	 
	rs = stmt.executeQuery("SELECT status_id, display_name FROM cque_camp_status");
	while( rs.next() ) { 
		status_id_option.append("<OPTION value="+rs.getString(1)+">"+rs.getString(2)+"</OPTION>");
	}
	rs.close(); 
 
	  
	if( ORIGIN_CAMP_ID != null && !ORIGIN_CAMP_ID.equals("") && !ORIGIN_CAMP_ID.equals("null") ) {
		//Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
		 
		 sSql = 
					" SELECT" +
					"	isnull(e.create_date,'')," +
					"	isnull(s.start_date,'')," +
					"	isnull(s.finish_date,'')," +
					"	t.display_name," +
					"	a.display_name," +
					"	s.recip_queued_qty," +
					"	s.recip_sent_qty," +
					"	c.camp_id," +
					"	c.approval_flag," +
					"	t.type_id " +
					" FROM cque_campaign c" +
					"	LEFT OUTER JOIN cque_camp_edit_info e ON c.camp_id = e.camp_id" +
					"	LEFT OUTER JOIN cque_camp_statistic s ON c.camp_id = s.camp_id" +
					"	INNER JOIN cque_camp_type t ON c.type_id = t.type_id" +
					"	INNER JOIN cque_camp_status a ON c.status_id = a.status_id" +
					" WHERE c.cust_id ="+cust.s_cust_id+" " +
					"	AND (c.type_id = 1) " +
					"	AND ISNULL(c.mode_id,0) != 20  " +
					"	AND c.origin_camp_id = "+ORIGIN_CAMP_ID+" " +
					" ORDER BY modify_date DESC";
			 
				rs = stmt.executeQuery(sSql);
				while (rs.next())
				{
					oneHistory = true;
					histTemp[0] = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(1));
					if (histTemp[0].equals("Jan 1, 1900 12:00 AM")) histTemp[0] = "";
					histTemp[1] = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(2));
					if (histTemp[1].equals("Jan 1, 1900 12:00 AM")) histTemp[1] = "";
					histTemp[2] = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(3));
					if (histTemp[2].equals("Jan 1, 1900 12:00 AM")) histTemp[2] = "";
					histTemp[3] = rs.getString(4);
					if (histTemp[3] == null) histTemp[3] = "";
					histTemp[4] = rs.getString(5);
					if (histTemp[4] == null) histTemp[4] = "";
					histTemp[5] = rs.getString(6);
					if (histTemp[5] == null) histTemp[5] = "";
					histTemp[6] = rs.getString(7);
					if (histTemp[6] == null) histTemp[6] = "";
					histTemp[7] = rs.getString(8);
					histTemp[8] = rs.getString(9);
					if (histTemp[8] == null || histTemp[8].equals("0"))
						histTemp[8] = "No";
					else
						histTemp[8] = "Yes";
						
					//type is > 1, nonTest campaign
					if (rs.getInt(10) > 1) nonTestSent = true;	
					
					oneHistory_tr.append("<tr>");
					oneHistory_tr.append("<td align='left' valign='middle'>"+histTemp[7]+"</td>");
					oneHistory_tr.append("<td align='left' valign='middle'>"+histTemp[4]+"</td>");
					oneHistory_tr.append("<td align='left' valign='middle'>"+histTemp[5]+"</td>");
					oneHistory_tr.append("<td align='left' valign='middle'>"+histTemp[6]+"</td>");
					oneHistory_tr.append("<td align='left' valign='middle' nowrap>"+histTemp[0].replaceAll(",","")+"</td>");
					oneHistory_tr.append("<td align='left' valign='middle' nowrap>"+histTemp[1].replaceAll(",","")+"</td>");
					oneHistory_tr.append("<td align='left' valign='middle' nowrap>"+histTemp[2].replaceAll(",","")+"</td>");
					oneHistory_tr.append("</tr>");
		 
				}
				rs.close();
				 	
				if (oneHistory == false)
				{	
					oneHistory_tr.append("<tr>");
					oneHistory_tr.append("<td class='CampHeader' colspan='7'>No Tests Have Been Sent For This Campaign</td>");
					oneHistory_tr.append("</tr>");
			  	}		
				
  	}else{
  		oneHistory_tr.append("<tr>");
		oneHistory_tr.append("<td class='CampHeader' colspan='7'>This area will show Campaign History information once you click the Save button.</td>");
		oneHistory_tr.append("</tr>");
  	}  
	
	
	 
	//Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
		if( ORIGIN_CAMP_ID != null && !ORIGIN_CAMP_ID.equals("") && !ORIGIN_CAMP_ID.equals("null") )
		{
			String sCreateDate = null;
			String sStartDate = null;
			String sFinishDate = null;
			String sTypeDisplayName = null;
			String sStatusDisplayName = null;
			String sRecpQueuedQty = null;
			String sRecpSendQty = null;
			int nCampId = 0;
			String sApprovalFlag = null;
			String sTypeId = null;

			boolean hasHistory = false;

			sSql = 
				" SELECT " +
				"	isnull(e.create_date,''), " +
				"	isnull(s.start_date,''), " +
				"	isnull(s.finish_date,''), " +
				"	t.display_name, " +
				"	a.display_name, " +
				"	s.recip_queued_qty, " +
				"	s.recip_sent_qty, " +
				"	c.camp_id, " +
				"	c.approval_flag, " +
				"	t.type_id " +
				" FROM cque_campaign c" +
				"	LEFT OUTER JOIN cque_camp_statistic s ON c.camp_id = s.camp_id" +
				"	INNER JOIN cque_camp_edit_info e ON c.camp_id = e.camp_id" +
				"	INNER JOIN cque_camp_type t ON c.type_id = t.type_id" +
				"	INNER JOIN cque_camp_status a ON c.status_id = a.status_id" +
				" WHERE cust_id ="+cust.s_cust_id+" " +
				" 	AND (c.type_id = "+CAMP_TYPE_ID+") " +
				"	AND origin_camp_id = "+ORIGIN_CAMP_ID+" " +
			    " ORDER BY modify_date DESC";

			rs = stmt.executeQuery(sSql);
			while (rs.next())
			{
				oneHistory = true;
				sCreateDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(1));
				if (sCreateDate.equals("Jan 1, 1900 12:00 AM")) sCreateDate = "";
				sStartDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(2));
				if (sStartDate.equals("Jan 1, 1900 12:00 AM")) sStartDate = "";
				sFinishDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(3));
				if (sFinishDate.equals("Jan 1, 1900 12:00 AM")) sFinishDate = "";
				sTypeDisplayName = rs.getString(4);
				if (sTypeDisplayName == null) sTypeDisplayName = "";
				sStatusDisplayName = rs.getString(5);
				if (sStatusDisplayName == null) sStatusDisplayName = "";
				sRecpQueuedQty = rs.getString(6);
				if (sRecpQueuedQty == null) sRecpQueuedQty = "";
				sRecpSendQty = rs.getString(7);
				if (sRecpSendQty == null) sRecpSendQty = "";
				nCampId = rs.getInt(8);
				sApprovalFlag = rs.getString(9);
				if (sApprovalFlag == null || sApprovalFlag.equals("0"))
					sApprovalFlag = "No";
				else
					sApprovalFlag = "Yes";

				//type is > 1, nonTest campaign
				if (rs.getInt(10) > 1) nonTestSent = true;
				
				report_tr.append("<tr>");
				report_tr.append("<td align='left' valign='middle' width=100 class='CampHeader'><b>Campaign ID</b></td>");
				report_tr.append("<td>"+nCampId+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeader'><b>Status</b></td>");
				report_tr.append("<td>"+ sStatusDisplayName+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeader'><b>Approved</b></td>");
				report_tr.append("<td>"+ sApprovalFlag+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeader'><b># Queued</b></td>");
				report_tr.append("<td id='campDetailTD'>"+ sRecpQueuedQty+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeader'><b># Sent</b></td>");
				report_tr.append("<td>"+ sRecpSendQty+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeader'><b>Created on</b></td>");
				report_tr.append("<td align='left' valign='middle' nowrap >"+sCreateDate.replaceAll(",","")+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeader'><b>Started on</b></td>");
				report_tr.append("<td align='left' valign='middle' nowrap >"+sStartDate.replaceAll(",","")+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeader'><b>Finished on</b></td>");
				report_tr.append("<td align='left' valign='middle' nowrap >"+sFinishDate.replaceAll(",","")+"</td>");
				report_tr.append("</tr>");
	  
			}
			rs.close();
			if (!oneHistory || !nonTestSent)
			{ 
				report_tr.append("<tr>");
				report_tr.append("<td align='left' valign='middle' colspan='8' class='CampHeader'><b>Campaign ID:</b> "+(Integer.parseInt(ORIGIN_CAMP_ID)+1)+"</td>");
				report_tr.append("</tr><tr>");
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeading'>Created on </td>");
				report_tr.append("<td>&nbsp;&nbsp;</td>");
				report_tr.append("<td align='left' valign='middle' nowrap>"+history[0]+"</td>");
				report_tr.append("<td>&nbsp;&nbsp;&nbsp;</td>"); 
				report_tr.append("<td align='left' valign='middle' nowrap class='CampHeading'>Status</td>");
				report_tr.append("<td>&nbsp;&nbsp;</td>");
				report_tr.append("<td align='left' valign='middle' nowrap>Draft</td>");
				report_tr.append("<td bgcolor='#FFFFFF' width='100%'>&nbsp;&nbsp;&nbsp;</td>");
				report_tr.append("</tr>");
	  		}
	}
	else
	{
		report_tr.append("<tr>");
		report_tr.append("<td>&nbsp;&nbsp;&nbsp;</td>");
		report_tr.append("<td class='CampHeader' colspan='9'>This area will show Campaign History information once you click the Save button.</td>");
		report_tr.append("</tr>");
 
	}
 			
	if (CONT_ID != null && !CONT_ID.equals("")) {
		rs = stmt.executeQuery("" +
			"SELECT 1 FROM ccnt_content WHERE cont_id = "+CONT_ID+" AND status_id <> 90");
		if (!rs.next()) CONT_ID = "";
	 }	
	rs.close();	  
	 
}
catch(Exception ex)
{  
	ErrLog.put(this,ex,"wizard.jsp",out,1);
}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn); 
}
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Quick Campaigns </title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
 
  <link rel="stylesheet" href="../report/assets/css/bootstrap.min.css">
  <link rel="stylesheet" href="../report/assets/css/daterangepicker/daterangepicker.css">
  <link rel="stylesheet" href="../report/assets/css/font-awesome.min.css">
 
  <link rel="stylesheet" href="../report/assets/css/ionicons.min.css">
 
  <link rel="stylesheet" href="../report/assets/css/AdminLTE.css">
  <link rel="stylesheet" href="../report/assets/css/Style.css">
  <link rel="stylesheet" href="../report/assets/css/DataTable/dataTables.bootstrap.min.css">
  <link rel="stylesheet" href="../report/assets/css/skin-blue.min.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <!-- Google Font -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
  <link rel="stylesheet" href="../report/assets/css/wizard.css">


<style> 
td {
	font-size: 12px;
	vertical-align: middle !important; 
	border-top:none !important;
}
th {
	font-size: 12px;
	background-color: #ecf0f5;
	border: 1px solid #f2f2f2 !important;
	vertical-align: middle !important;
}
.w100{ width:100px !important; }
.h150{ height:150px; }
.bg{ background-color:#f8f8f8; }
.border{ border-top:none; }
ul{ list-style:none; } 
.w100y{ width:100% !important; }
#step4-table input{ width:100% !important; }
.nav-tabs-custom { background-color:#f8f8f8; }
.fnt {font-family: 'Source Sans Pro', 'Helvetica Neue', Helvetica, Arial, sans-serif;	font-weight: 400;}
.field_error{font-size:12px;color:red;}

.bdr_c{ border-color:#0097bc }

.btn-primary {
    background-color: #59C8E6 ;
    border-color: #59C8E6 ;
}
.btn-success {
    background-color: #A587BE    ;
    border-color: #A587BE   ;
}
</style>
</head>



<body class="hold-transition">
<section class="content-header" style="margin-left:20px;margin-right:20px;" >


 		 
 
<%
if (can.bWrite)
{
	  if( !isDone && !isSending && !isTesting)
		{ 
				%> 
		  		<a class="btn btn-warning fnt" href="#" onclick="save();" >Save</a>
				<a class="btn btn-warning fnt" href="#" onclick="savenexit();" >Save &amp; Exit</a>
				 
			  <%
		}
		else if ((isTesting || isSending) && (null != CAMP_ID))
		{	%> 
		 		 <a href="wizard.jsp?camp_id=<%= CAMP_ID %>" class="btn btn-primary fnt">Refresh</a>
			 <%
		}
		if( CAMP_ID != null )
		{
			%> 
			 	<a class="btn btn-warning fnt" href="#" onclick="clone();" >Clone</a> 
		  	<%
		}
				 
}
%> 

<% if( tmpStatus >= CampaignStatus.SENT_TO_RCP && tmpStatus <= CampaignStatus.READY_TO_BE_QUEUED ) { %>
	<div class="row">
	   <div class="col-md-8 col-md-offset-2">
	    	 
		 		
		 	<div class="progress progress-md active">
			   <div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%">
			     <span class="sr-only">25% Complete</span>
			   	<% if( tmpType == 1 ) { %>
				 				<p><b>Your test process has started</b></p>
				 <% } else { %>
				 				<p><b>Your campaign process has started</b></p>
				 <%	} %>
			 
				 </div>
			 </div>	 
				 
		 
	  </div>
	</div>	 
					 
<%	} %>

<% if( tmpStatus >= CampaignStatus.RECIPS_QUEUED && tmpStatus <= CampaignStatus.READY_TO_SEND ) { %>
  	<div class="row">
	  <div class="col-md-8 col-md-offset-2"> 
		 <div class="progress progress-md active">
			 <div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100" style="width: 50%">
			     <span class="sr-only">50% Complete</span>
				 		<p>
						<% if( tmpType == 1 ) { %>
						   <b>You have <%= RecipsQueued %> tests <%= DescStatusText %></b>
						 <% } else { %>
						   <b>You have <%= RecipsQueued %> recipients <%= DescStatusText %></b>
					 	<%	} %>
					 	</p>
			 	</div>
			</div>
	  	</div>
	</div>
				
				
			 
<%	} %>

<% if( tmpStatus == CampaignStatus.BEING_PROCESSED ) { %>
<div class="row">
  <div class="col-md-8 col-md-offset-2"> 
		 <div class="progress progress-md active">
			 <div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100" style="width: 75%">
			     <span class="sr-only">75% Complete</span>
			
				<p> 
			 
					<% if( tmpType == 1 ) { %>
					        <b>You have sent <%= RecipsSent %> out of <%= RecipsQueued %> tests</b>
			        <%  } else if( tmpType == 3 || tmpType == 4 ) { %>
				         	<b>Your campaign has sent <%= RecipsSent %> recipients thus far</b>
			       	<%  } else { %>
						  <b>You have sent to <%= RecipsSent %> out of <%= RecipsQueued %> total recipients</b>
			         <%	} %>
				</p>
			</div>
		</div>
	  </div>
	</div>
					 
<%	} %>
<% if( tmpStatus == CampaignStatus.CANCELLED ) { %>
	
<div class="row">
  <div class="col-md-8 col-md-offset-2">
 	<div class="progress progress-md active">
        <div class="progress-bar progress-bar-warning progress-bar-striped" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
                <span class="sr-only">0% cancelled</span>
             	<p> 
					<b>Your campaign was cancelled. 
					It had sent <%= RecipsSent %> recipients out of <%= RecipsQueued %> total recipients before being cancelled.</b> 
							
			    </p>
		</div>
	</div>
  </div>
</div>
					 
<%	} %>
<% if( tmpStatus == CampaignStatus.ERROR ) { %>
	 
<div class="row">
  <div class="col-md-8 col-md-offset-2">
 		<div class="progress progress-md active">
     	   <div class="progress-bar progress-bar-warning progress-bar-striped" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
                <span class="sr-only">0% error</span>
 			<p> 
				 <b>Your campaign has generated an error. 
					Please confirm that your Target Group has recipients or contact Support for more assistance.</b>
		 	 </p>
			</div>
		</div>
	  </div>
	</div>
	  
					 
<%	} %>
</section>
<div>
	<!-- multistep form -->
 
<FORM id="msform"  METHOD="POST" NAME="FT" ACTION="wizard_save.jsp">
	<div id="test">
	 
	<ul id="progressbar">
		<li class="active">Campaign Name</li>
		<li>Audience</li> 
		<li>Content</li>
		<li>Send Campaign</li>
		<li>Logs</li>
	</ul>
	</div>
	<!-- fieldsets -->
	<fieldset>
		
		<div class="row">
			<div class="col-md-6 col-md-offset-3"> 
				<h2 class="fs-title">Enter Your Campaign Name</h2>
				<h3 class="fs-subtitle">This is step 1</h3>
				<span class="fs-subtitle">Enter a unique name for your campaign in the text box below.<br/>This name is what will show up in the Reporting section.</span>
				<br/><br/><br/>
					 <INPUT TYPE="text" NAME="camp_name" value="<%=CAMP_NAME%>"  placeholder="New Campaign" /> 
					 <span id="camp-name" class="field_error"></span>
				  <br/>
			 </div>
		</div>
		<button type="button"   class="next action-button" />Next</button>
		
	</fieldset>
	<fieldset>
			<div class="row">
					<div class="col-md-6 col-md-offset-3"> 
							<h2 class="fs-title">Select Your Audience</h2>
							<h3 class="fs-subtitle">This is step 2</h3>
							<h3 class="fs-subtitle">From the drop down list below,<br/>select which group of recipients you would like to send to.</h3>
								<select name="filter_id" size="1">
									<option selected value="">---  Choose target group  ---------</option>
									<%= filterHtml_s2 %>
								</select>
								<% if (canTGPreview) { %>
								<br><br>
							<!-- 	<a class="resourcebutton" href="javascript:targetgroup_popup(document.all.item('filter_id')[document.all.item('filter_id').selectedIndex].value);">Preview This Audience</a>
							 -->
							 	 <button id="filter-preview" class="btn btn-warning">Preview This Audience</button><br/>
								 <span id="filter-name" class="field_error"></span>
								<% } %>
					</div>
			</div>
		<br/>
		<input type="button" name="previous" class="previous action-button" value="Previous" />
		<input type="button" name="next" class="next action-button" value="Next" />
	</fieldset>
	<fieldset>
		<div class="row">
				<div class="col-md-6 col-md-offset-3"> 
					<h2 class="fs-title">Create Your Content</h2>
					<h3 class="fs-subtitle">This is step 3</h3>		
					<h3 class="fs-subtitle">Use the section below to name and edit the content you would like to send out with this campaign:</h3>
				</div>
				
				 <iframe style="width: 100%;height:100vh;position: relative;" src="<%= contEditFrame %>" border="0" name="selectContent" frameborder="0" scrolling="auto" id="selectContent"></iframe> 
	  
		 </div>
		 
		<input type="button" name="previous" class="previous action-button" value="Previous" />
		<!-- <input type="submit" name="submit" class="submit action-button" value="Submit" /> -->
			 
			
			<%  if (CAMP_ID != null  ) { %>
								<input type="button" name="next" class="next action-button" value="Next" />
				<% } %>
	</fieldset>
	
	<fieldset>
		<h2 class="fs-title">Send Your Campaign</h2>
		<h3 class="fs-subtitle">This is step 4</h3> 
		
		<div class="row">
		
			<div class="col-md-6 col-md-offset-3"> 
		   		<table id="step4-table" class="table" >
						<tr>
							 <td> 
							 	<select name="test_list_id" >
									<option selected="" value="">---  Choose test list  -----</option>
									<%= test_list_option  %>
				 				</select>
							</td>
							<td class="w100">
							 		<% 
									if( !isDone && !isSending && !isTesting && can.bExecute) {  %>
										<button id="send_test" type="button" class="btn btn-primary">Send A Test</button>
									<% } %>
							</td>
						</tr>
					</table>	
						<table class="table" >
						<tr>
							<td class="w100">Campaign Name:</td>
							<td><span id="last-camp-name"><%=CAMP_NAME%></span></td>
							<td class="w100"><button id="edit-camp-name" type="button" class="btn btn-warning">Modify</button></td>
						</tr>
						<tr>
							<td class="w100">From Name:</td>
							<td><input type="text" name="from_name" value="<%=FROM_NAME%>" /> </td>
							<td class="w100"></td>
						</tr>
						<tr>
							<td>From Address</td>
							<td>
								<select name="from_address_id">
										<option selected="" value="">---  Choose address  ------</option>
										 <%=from_address_option %>
								</select>
							</td>
							<td></td>
						</tr>
						<tr>
							<td>To</td>
							<td>
							<span id="last-filter-name"><%= filterHtml_s4 %></span>			
							</td>
							<td><button type="button"  id="edit-filter-name"  class="btn btn-warning">Modify</button></td>
						</tr>
						<tr>
							<td>Subject</td>
							<td>
							 	<input  type="text" name="subj_html" value="<%=SUBJ_HTML%>" />	
							 </td>
							<td></td>
						</tr>
						<tr>
							<td>Reply To</td>
							<td>
								<input type="text" name="response_frwd_addr" value="<%=RESPONSE_FRWD_ADDR%>"  <%=(isHyatt?" onChange=\"FT.reply_to.value=this.value\"":"")%>/>
							</td>
							<td></td>
						</tr>
						<tr>
							<td>Content</td>
							<td><button  id="content-preview"    type="button" class="btn btn-primary pull-right">Preview</button></td>
							<td><button  id="edit-content-name"  type="button" class="btn btn-warning">Modify </button></td>
						</tr>
						<tr>
							<td colspan="3"><%
									String sIframeSrc = "../blank.jsp";
									if ((null != CONT_ID) && (!CONT_ID.equals(""))) 
									{
										sIframeSrc = "../cont/cont_preview_2.jsp?cont_id=" + CONT_ID + "&contType=2";
									}
									%>
									<iframe id="prevContent" style="width:100%; height:100%;" src="<%=sIframeSrc%>" frameborder="0" scrolling="yes"></iframe></td>
													 
												
						</tr>
					
					</table>
				 
				 
					 
			</div>
		</div>
		  
			<br/>
			<input type="button" name="previous" class="previous action-button" value="Previous" /> 
				<%  if (CAMP_ID != null  ) { %>
			 	<input type="button" name="next" class="next action-button" value="Next" /> 
			  <% } %>

			 <%
			 if( !isDone && !isSending && !isTesting && can.bExecute) { %>
			  <a id="launch_camp" class="btn btn-primary" href="#" onclick="send();"><%= (isHyatt)?"Request Approval":"Launch Campaign" %></a>
			 <% } %> 
		 
	</fieldset>
	<fieldset>
	<div class="row">
		<div class="col-md-6 col-md-offset-3 bg"> 
			 	<h3 class="fs-subtitle">This is step 5</h3>
		  
          <div class="nav-tabs-custom">
            <ul class="nav nav-tabs">
              <li class="active"><a href="#activity" data-toggle="tab">Campaign History</a></li>
              <li><a href="#timeline" data-toggle="tab">Testing History</a></li>
              <li><a href="#settings" data-toggle="tab">User History</a></li>
            </ul>
            <div class="tab-content">
              <div class="active tab-pane" id="activity">
			   
				<table class="table">
						 <% out.println(report_tr); %>
					
				 </table>
					
              </div>
              <!-- /.tab-pane -->
              <div class="tab-pane" id="timeline">
			   
						<table class="table">
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Test ID:</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Status</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Queued</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Sent</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Created</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Started</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Finished</b></td>
							</tr>
							
							 	<% out.println(oneHistory_tr);   %>
						</table>
			  
			  
              </div>
              <!-- /.tab-pane -->

              <div class="tab-pane" id="settings">
			   			<table class="table">
							<tr>
								<td class="CampHeader"><b>Created by</b></td>
								<td><%= history[1] %></td>
								<td class="CampHeader"><b>Last Modified by</b></td>
								<td><%= history[3] %></td>
							</tr>
							<tr>
								<td class="CampHeader"><b>Creation date</b></td>
								<td><%= history[0] %></td>
								<td class="CampHeader"><b>Last Modify date</b></td>
								<td><%= history[2] %></td>
							</tr>
						</table> 
			  
              </div>
              <!-- /.tab-pane -->
            </div>
            <!-- /.tab-content -->
          </div>
          <!-- /.nav-tabs-custom -->
    
		
		
		</div>
	 </div>
		 
		<input type="button" name="previous" class="previous action-button" value="Previous" /> 
	</fieldset>
	
	<!-- form inputs -->
<input type="hidden" name="step" value="<%= STEP %>">
<input type="hidden" name="cont_id" value="">
<%=(CATEGORY_ID!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+CATEGORY_ID+"\">":""%>
<INPUT TYPE="hidden" NAME="camp_id"	value="<%= ((CAMP_ID!=null)?CAMP_ID:"") %>">
<INPUT TYPE="hidden" NAME="current_time"	value="<%=CURRENT_TIME%>">
<INPUT TYPE="hidden" NAME="start_date"	value=''>  <%--"<%=START_DATE%>">  --%>
<INPUT TYPE="hidden" NAME="end_date"	value=''> <%--"<%=END_DATE%>"> --%>
<INPUT TYPE="hidden" NAME="queue_date"	value=''>  <%--"<%=QUEUE_DATE%>"> --%>
<INPUT TYPE="hidden" NAME="mode"		value="save">
<INPUT TYPE="hidden" NAME="clone"		value="false">
<INPUT TYPE="hidden" NAME="type_id"		value="<%=CAMP_TYPE_ID%>">
<INPUT TYPE="hidden" NAME="form_flag"	value="0">
<SELECT NAME="type_id2" SIZE="1" DISABLED style="display:none;">
	<%=type_id2_option %>
</SELECT>
<SELECT NAME="status_id" SIZE="1" DISABLED style="display:none;">
<%=status_id_option %>
</SELECT>
		
<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="4" width="55" style="display:none;"<%//=!canCat.bRead?" style=\"display:'none'\"":""%>>
	<%= htmlCategories %>
</SELECT>
<%=(!canCat.bExecute && (CATEGORY_ID != null) && !(CATEGORY_ID.equals("0")))
?"<INPUT type=hidden name=\"categories\" value=\""+CATEGORY_ID+"\">"
:""%>
<%
	SUBJ_HTML 		= SUBJ_HTML.replaceAll("\"","&#34");
%>
				
<input type="text" name="reply_to" value="<%=REPLY_TO%>" size="40" maxlength="255" style="display:none;">

<select name="linked_camp_id" size="1" style="display:none;">
	<option selected value="">---  Choose Campaign ----------------------</option>
	<%=linked_camp_option %>
</select>

<% if (nonEmailFinger) { %>
	<input type="checkbox" name="msg_per_email821_limit" style="display:none;">
<%	} %>
<INPUT TYPE="hidden" NAME="exclusion_list_id" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="auto_respond_list_id" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="auto_respond_attr_id" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="randomly" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="delay" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="queue_daily_time" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="camp_frequency" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="recip_qty_limit" VALUE="0" style="display:none;">
<INPUT TYPE="hidden" NAME="limit_per_hour" VALUE="0" style="display:none;">
 
 
</form>

 
</div>
<!-- ./wrapper -->
 

<script src="../report/assets/js/jquery.min.js"></script>
<script src="../report/assets/js/bootstrap.min.js"></script>
<script src="../report/assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="../report/assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="../report/assets/js/demo.js"></script>

<script src="../report/assets/js/daterangepicker/moment.min.js"></script>
<script src="../report/assets/js/daterangepicker/daterangepicker.js"></script>

<script type="text/javascript" src="../report/assets/js/FushionCharts/fusioncharts.js"></script>
<script type="text/javascript" src="../report/assets/js/FushionCharts/fusioncharts.theme.fint.js"></script>

<!-- DataTables -->
<script src="../report/assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="../report/assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script src="../report/assets/js/jquery.easing.min.js"></script>
<script>
 
  $(function () {
    
    $('#example1').DataTable({
		"lengthMenu": [[10, 25, 50, 100,-1], [10, 25, 50, 100, "All"]]

	});
  })
 </script>
 
 <script>
 
 	
	//jQuery time
	 var current_fs, next_fs, previous_fs; //fieldsets
	 var left, opacity, scale; //fieldset properties which we will animate
	 var animating; //flag to prevent quick multi-click glitches
	 var form=$("#msform");
	 
	 <% if (null != STEP && STEP.equals("4") ) { %>
 			moveSteps4(<%=STEP%>,true);
 	 <% } %>
 	 
 	 <% if (null != STEP && STEP.equals("5") ) { %>
 			disable_form();
		<% } %>
 
	 //------------------------------------------------------
	 function moveSteps(stepNum)
		{		
			var frm = document.FT;
			frm.step.value = stepNum;
			if (stepNum == "4") {
				<% if( !isDone && !isSending && !isTesting && can.bWrite) { %>
					save();
				<% } else { %>
						moveSteps4(stepNum,false);
				<% } %>
			}
			else {
				<%
				if (null != CONT_ID)
				{
					if( !CONT_ID.equals(""))
					{
						%>
						if (stepNum == "3")	{
							window.frames["selectContent"].document.location.href = "/cms/ui/jsp/ctm/pageedit.jsp?isEdit=true&contentID=<%= WizardID %>";
						}
						<%
					}
				}
				%>
					 
			}
				
		}
	 

	  	function disable_form()
		 {
	  		  $("#msform input[name='camp_name']").prop("disabled", true);	
	  		  $("#msform select[name='filter_id']").prop("disabled", true);	
	  		  $("#msform input[name='from_name']").prop("disabled", true);	
	  		  $("#msform select[name='from_address_id']").prop("disabled", true);
	  		  $("#msform input[name='subj_html']").prop("disabled", true);
	  		  $("#msform input[name='response_frwd_addr']").prop("disabled", true);
	  		
	  		   
	  		  $("#send_test").prop("disabled", true);
	  		  $("#edit-camp-name").prop("disabled", true);
	  		  $("#edit-filter-name").prop("disabled", true);
	  		  $("#edit-content-name").prop("disabled", true);
	  		  $("#launch_camp").prop("disabled", true);
	  		  
	  		
		 }

	 
	 	function savenexit() { doit(-1); }

		function save() { doit(0); }
		
		function clone() { doit(1); }
		function clone2destination() { doit(5); }
		
		function send_test(sample_id) { doit(2); }
		function send() { doit(3); }
		
		function doit(flag)
		{
			switch( flag )
			{
				case -1: FT.mode.value="save_n_exit"; break;
				case 0: FT.mode.value="save"; break;
				case 1: FT.mode.value="clone"; break;
				case 2: FT.mode.value="send_test"; break;
				case 3: FT.mode.value="send_camp"; break;
		        case 5: {
					FT.mode.value="clone2destination"; break;
					flag = 1; //simulate "clone" for validation
				}
			}
 
			if( ! are_settings_valid(flag) ) return false;

		    if (( flag == 2 ) || (flag == 3)) {
				if( ! confirm('Are you sure?') ) return false;
			}
			FT.reply_to.value=FT.response_frwd_addr.value;
			FT.submit();

		}

		function isEmailOrPers(str) {
			return (isEmail(str) || isPers(str));
		}

		function isEmail(str)
		{
			var supported = 0;
			if (window.RegExp)
			{
				var tempStr = "a";
				var tempReg = new RegExp(tempStr);
				if (tempReg.test(tempStr)) supported = 1;
			}
			
			if (!supported) 
			  return (str.indexOf(".") > 2) && (str.indexOf("@") > 0);
			var r1 = new RegExp("(@.*@)|(\\.\\.)|(@\\.)|(^\\.)");
			var r2 = new RegExp("^.+\\@(\\[?)[a-zA-Z0-9\\-\\.]+\\.([a-zA-Z]{2,3}|[0-9]{1,3})(\\]?)$");
			return ((!r1.test(str) && r2.test(str))); 
		}

		function isPers(str)
		{
			return ((str.indexOf("!*") > -1) 
				&& (str.indexOf(";") > -1) 
				&& (str.indexOf("*!") > -1) 
				&& (str.indexOf(";") > str.indexOf("!*")+2) 
				&& (str.indexOf("*!") > str.indexOf(";")));
		}
		
		function are_settings_valid(flag)
		{
			FT.camp_name.value = FT.camp_name.value.replace(/(^\s*)|(\s*$)/g, '');
			FT.response_frwd_addr.value = FT.response_frwd_addr.value.replace(/(^\s*)|(\s*$)/g, '');

			FT.subj_html.value = FT.subj_html.value.replace(/(^\s*)|(\s*$)/g, '');

		    if ( FT.camp_name.value == "" ) {
				alert("You must specify a <Campaign Name> ...");
				return false;
			}

		    if (flag > 0) {		
		        if ( FT.subj_html.value.length == 0) {
				    alert("You must include a campaign subject ...");
				    return false;
			    }
		    }

			FT.queue_date.value = FT.start_date.value;

			var dateQue = new Date(Date.parse(FT.queue_date.value));
			var dateStr = new Date(Date.parse(FT.start_date.value));

			if (dateQue > dateStr) { alert("The <Queue Date> specified is after the <Start Date> ..."); return false; }

		    if (flag > 1) {
		        if ( (FT.form_flag.value == "0") && ( FT.filter_id.value == "" ) ) {
					alert("You should choose a <Target group> ...");
					return false;
				}
		        if ( FT.cont_id.value == "" ) {
					alert("You should choose <Content> ...");
					return false;
				}
		        if ( FT.from_address_id.value == "" ) {
					alert("You should choose <From address> ...");
					return false;
				}
		        if ( FT.from_name.value == "" ) {
					alert("You should choose <From name> ...");
					return false;
				}
				if(( FT.response_frwd_addr.value != "" ) && (!isEmailOrPers(FT.response_frwd_addr.value)))
				{
					alert("Please enter a valid <Response forwarding> ...");
					return false;
				}
		        if( FT.response_frwd_addr.value == "" ) {
					alert("You should specify <Response forwarding> ...");
					return false;
				}
		        if( flag == 2 && FT.test_list_id.value == "" ) {
					alert("You should choose a <Test list> ...");
					return false;
				}
			}

			return true;
		}

		FT.type_id2.value=<%=HtmlUtil.escape(CAMP_TYPE_ID)%>;
		FT.status_id.value=<%=HtmlUtil.escape(STATUS_ID)%>;
		
		FT.cont_id.value="<%=HtmlUtil.escape(CONT_ID)%>";
		FT.from_address_id.value="<%=HtmlUtil.escape(FROM_ADDRESS_ID)%>";
		FT.filter_id.value="<%=HtmlUtil.escape(FILTER_ID)%>";
		FT.test_list_id.value="<%=HtmlUtil.escape(TEST_LIST_ID)%>";
		FT.recip_qty_limit.value="<%=HtmlUtil.escape(RECIP_QTY_LIMIT)%>";
		FT.limit_per_hour.value="<%=HtmlUtil.escape(LIMIT_PER_HOUR)%>";
		FT.linked_camp_id.value="<%=HtmlUtil.escape(LINKED_CAMP_ID)%>";

		<% if (nonEmailFinger) { %>
			FT.msg_per_email821_limit.checked = <%= MSG_PER_EMAIL821_LIMIT.equals("0")?"false":"true" %>;
		<% } %>
		 
 
	 //----------------------------------------------------------
	 
	 $(document).on("click","#send_test", function(e) {
 		 e.preventDefault(); 
 		// var camp_name=form.find('input[name="camp_name"]').val();
 		// var filter_id=form.find('select[name="filter_id"]').val(); 
 		 send_test();
 	 
 	});
 	
 	$(document).on("click","#content-preview", function(e) {
		 		 e.preventDefault();   
		 		
		 		 <% 
			 		String cIframeSrc = "../blank.jsp";
					if ((null != CONT_ID) && (!CONT_ID.equals(""))) 
					{
						sIframeSrc = "../cont/cont_preview_2.jsp?cont_id=" + CONT_ID + "&contType=2";
					}
		 	 	%>
		 	 		var URL="<%=sIframeSrc%>";
		 	 		windowName = 'targetgroup_window';
			    	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
			    	SmallWin = window.open(URL, windowName, windowFeatures);
				 
		 	 
	 });
	  
	 $(document).on("change",'select[name="filter_id"]', function(e) {
			e.preventDefault();
			var filter_name= document.all.item('filter_id')[document.all.item('filter_id').selectedIndex].text;
		 	$(this).parent().find(".field_error").text("");
			$("#last-filter-name").text(filter_name);
		});
 
 	$(document).on("keyup",'input[name="camp_name"]', function(e) {
		e.preventDefault(); 
		$(this).parent().find(".field_error").text("");
	});
 
 	$(document).on("click","#filter-preview", function(e) {
 		e.preventDefault(); 
 		var button = $(this);
 		var filter_id= document.all.item('filter_id')[document.all.item('filter_id').selectedIndex].value;
 		if(filter_id==""){
 			 button.parent().find(".field_error").html("Please make a selection");
 		  	 return;
 		}
 		targetgroup_popup(filter_id);
 	 
 	});
 	 
    
    $(document).on("click","#edit-camp-name", function(e) {
		e.preventDefault();
	  
		if(animating) return false;
		animating = true;
		
		current_fs = $(this).parent().parent().parent().parent().parent().parent().parent();
		previous_fs= form.find("fieldset:first");
		 
	 
		$("fieldset").each(function(i, el){
			if ( i !== 0) { 
				 $(this).css({'transform': 'scale(1)' }); 
			 } 
	 	});
	 	$("#progressbar li").each(function(){
			 $(this).removeClass("active");
	 	});
	 	
	  	$("#progressbar li:first").addClass("active");
	 	$("#progressbar li").eq($("fieldset").index(current_fs)).removeClass("active");
		  
		previous_fs.show();  
		current_fs.animate({opacity: 0}, {
			step: function(now, mx) {
				  			
				scale = 0.8 + (1 - now) * 0.2; 
				left = ((1-now) * 50)+"%"; 
				opacity = 1 - now;
				current_fs.css({'left': left});
				previous_fs.css({'transform': 'scale('+scale+')', 'opacity': opacity});
			}, 
			duration: 800, 
			complete: function(){
				current_fs.hide();
				animating = false;
			}, 
			//this comes from the custom easing plugin
			easing: 'easeInOutBack'
		});
	 
	});
    
    $(document).on("click","#edit-filter-name", function(e) {
		e.preventDefault();
	  
		if(animating) return false;
		animating = true;
		
		var fielset_id=1;
		
		current_fs = $(this).parent().parent().parent().parent().parent().parent().parent();
		previous_fs= form.find("fieldset").eq(fielset_id);
		 
		$("fieldset").each(function(i, el){
			if ( i !== 1) { 
				 $(this).css({'transform': 'scale(1)' }); 
			 } 
	 	});
	 	$("#progressbar li").each(function(i,el){
	 		 if(i >=fielset_id+1){
	 			 $(this).removeClass("active"); 
	 		 }
		 });
		
		$("#progressbar li:first").addClass("active");
	 	$("#progressbar li").eq($("fieldset").index(current_fs)).removeClass("active");
		  
		previous_fs.show();  
		current_fs.animate({opacity: 0}, {
			step: function(now, mx) {
				  			
				scale = 0.8 + (1 - now) * 0.2; 
				left = ((1-now) * 50)+"%"; 
				opacity = 1 - now;
				current_fs.css({'left': left});
				previous_fs.css({'transform': 'scale('+scale+')', 'opacity': opacity});
			}, 
			duration: 800, 
			complete: function(){
				current_fs.hide();
				animating = false;
			}, 
			//this comes from the custom easing plugin
			easing: 'easeInOutBack'
		});
	 
	});
 	
    
    $(document).on("click","#edit-content-name", function(e) {
		e.preventDefault();
		moveSteps(3);
		if(animating) return false;
		animating = true;
	 
		var fielset_id=2;
		
		current_fs = $(this).parent().parent().parent().parent().parent().parent().parent();
		previous_fs= form.find("fieldset").eq(fielset_id);
		 
		$("fieldset").each(function(i, el){
			if ( i !== 1) { 
				 $(this).css({'transform': 'scale(1)' }); 
			 } 
	 	});
	 	$("#progressbar li").each(function(i,el){
	 		 if(i >=fielset_id+1){
	 			 $(this).removeClass("active"); 
	 		 }
		 });
		
		$("#progressbar li:first").addClass("active");
	 	$("#progressbar li").eq($("fieldset").index(current_fs)).removeClass("active");
		  
		previous_fs.show();  
		current_fs.animate({opacity: 0}, {
			step: function(now, mx) {
				  			
				scale = 0.8 + (1 - now) * 0.2; 
				left = ((1-now) * 50)+"%"; 
				opacity = 1 - now;
				current_fs.css({'left': left});
				previous_fs.css({'transform': 'scale('+scale+')', 'opacity': opacity});
			}, 
			duration: 800, 
			complete: function(){
				current_fs.hide();
				animating = false;
			}, 
			//this comes from the custom easing plugin
			easing: 'easeInOutBack'
		});
	 
	});
function targetgroup_popup(filterID)
    {
    	URL = '/cms/ui/jsp/filter/filter_preview.jsp?filter_id=' + filterID;
    	windowName = 'targetgroup_window';
    	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
    	SmallWin = window.open(URL, windowName, windowFeatures);
    }

	function moveSteps4(fielset_id,durum){
		 
		if(animating) return false;
		animating = true; 
		current_fs = form.find("fieldset").eq(2);
		next_fs = form.find("fieldset").eq(fielset_id-1);
		
		if(durum){
			
			$("#progressbar li").each(function(i,el){
		 		 if(i <=fielset_id-1){
		 			 $(this).addClass("active"); 
		 		 }
			 });
		}
		
		 
		$("#progressbar li").eq($("fieldset").index(next_fs)).addClass("active");
	 	next_fs.show(); 
		 
		current_fs.animate({opacity: 0}, {
			step: function(now, mx) {
				 
			  	scale = 1 - (1 - now) * 0.2;
				left = (now * 50)+"%";
				 
				opacity = 1 - now;
				current_fs.css({'transform': 'scale('+scale+')'});
				next_fs.css({'left': left, 'opacity': opacity});
			}, 
			duration: 800, 
			complete: function(){
				current_fs.hide();
				animating = false;
			}, 
			 easing: 'easeInOutBack'
		});
	  
	}

    
$(function() {

$(".next").click(function(){
	
  	 var field_index=$(this).parent().index(); 
	 
  	 if(field_index=="1"){
  		 
  		var CAMP_NAME		=form.find('input[name="camp_name"]').val();
  		 if(CAMP_NAME==""){
  			 $("#camp-name").html("Please do not leave it empty.");
  			 return;
  		 }else{
  			 $("#last-camp-name").html(CAMP_NAME);
  			 
  		 }
  	 }
  	if(field_index=="2"){
 		 
  		 var filter_id= document.all.item('filter_id')[document.all.item('filter_id').selectedIndex].value;
 		if(filter_id==""){
 			$("#filter-name").html("Please make a selection");
 			 return;
 		}else{
 			var filter_name= document.all.item('filter_id')[document.all.item('filter_id').selectedIndex].text;
 			 $("#last-filter-name").html(filter_name);
 		}
  	 }
   
	if(animating) return false;
	animating = true; 
	current_fs = $(this).parent();
	next_fs = $(this).parent().next();
	 
	$("#progressbar li").eq($("fieldset").index(next_fs)).addClass("active");
	
	next_fs.show(); 
	current_fs.animate({opacity: 0}, {
		step: function(now, mx) {
		  	scale = 1 - (1 - now) * 0.2;
			left = (now * 50)+"%";
			opacity = 1 - now;
			current_fs.css({'transform': 'scale('+scale+')'});
			next_fs.css({'left': left, 'opacity': opacity});
		}, 
		duration: 800, 
		complete: function(){
			current_fs.hide();
			animating = false;
		}, 
		//this comes from the custom easing plugin
		easing: 'easeInOutBack'
	});
});



$(".previous").click(function(){
	if(animating) return false;
	animating = true;
	
	current_fs = $(this).parent();
	previous_fs = $(this).parent().prev();
	
	//de-activate current step on progressbar
	$("#progressbar li").eq($("fieldset").index(current_fs)).removeClass("active");
	
	//show the previous fieldset
	previous_fs.show(); 
	//hide the current fieldset with style
	current_fs.animate({opacity: 0}, {
		step: function(now, mx) {
			//as the opacity of current_fs reduces to 0 - stored in "now"
			//1. scale previous_fs from 80% to 100%
			scale = 0.8 + (1 - now) * 0.2;
			//2. take current_fs to the right(50%) - from 0%
			left = ((1-now) * 50)+"%";
			//3. increase opacity of previous_fs to 1 as it moves in
			opacity = 1 - now;
			current_fs.css({'left': left});
			previous_fs.css({'transform': 'scale('+scale+')', 'opacity': opacity});
		}, 
		duration: 800, 
		complete: function(){
			current_fs.hide();
			animating = false;
		}, 
		//this comes from the custom easing plugin
		easing: 'easeInOutBack'
	});
});

$(".submit").click(function(){
	return false;
})

});
</script>
 
</body>
</html>


 