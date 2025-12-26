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

boolean showStep1 = false;
boolean showStep2 = false;
boolean showStep3 = false;
boolean showStep4 = false;
boolean showStep5 = false;

String classStep1 = "SpecialTabOff";
String classStep2 = "SpecialTabOff";
String classStep3 = "SpecialTabOff";
String classStep4 = "SpecialTabOff";
String classStep5 = "SpecialTabOff";

String styleStep1 = " style=\"display:none;\"";
String styleStep2 = " style=\"display:none;\"";
String styleStep3 = " style=\"display:none;\"";
String styleStep4 = " style=\"display:none;\"";
String styleStep5 = " style=\"display:none;\"";

if (STEP.equals("1")) {
	showStep1 = true;
	classStep1 = "SpecialTabOn";
	styleStep1 = "";
}
else if (STEP.equals("2")) {
	showStep2 = true;
	classStep2 = "SpecialTabOn";
	styleStep2 = "";
}
else if (STEP.equals("3")) {
	showStep3 = true;
	classStep3 = "SpecialTabOn";
	styleStep3 = "";
}
else if (STEP.equals("4")) {
	showStep4 = true;
	classStep4 = "SpecialTabOn";
	styleStep4 = "";
}
else if (STEP.equals("5")) {
	showStep5 = true;
	classStep5 = "SpecialTabOn";
	styleStep5 = "";
}
else {
	showStep1 = true;
	classStep1 = "SpecialTabOn";
	styleStep1 = "";
}

boolean isPrintCampaign = false;

ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

try	{
	
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("wizard.jsp");
	stmt = conn.createStatement();
	
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
			CAMP_NAME				= new String(rs.getBytes(8),"ISO-8859-1");
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

		/* debug 
		System.out.println("ORIGIN_CAMP_ID="+ORIGIN_CAMP_ID);
		System.out.println("CAMP_TYPE_ID="+CAMP_TYPE_ID);
		System.out.println("STATUS_ID="+STATUS_ID);
		System.out.println("FILTER_ID="+FILTER_ID);
		System.out.println("CONT_ID="+CONT_ID);
		System.out.println("TEST_LIST_ID="+TEST_LIST_ID);
		System.out.println("FROM_ADDRESS_ID="+FROM_ADDRESS_ID);
		System.out.println("CAMP_NAME="+CAMP_NAME);
		System.out.println("FROM_NAME="+FROM_NAME);
		System.out.println("SUBJ_HTML="+SUBJ_HTML);
		System.out.println("RESPONSE_FRWD_ADDR="+RESPONSE_FRWD_ADDR);
		System.out.println("START_DATE="+START_DATE);
		System.out.println("RECIP_QTY_LIMIT="+RECIP_QTY_LIMIT);
		System.out.println("EXCLUSION_LIST_ID="+EXCLUSION_LIST_ID);
		System.out.println("LIMIT_PER_HOUR="+LIMIT_PER_HOUR);
		System.out.println("history[0]="+history[0]);
		System.out.println("history[1]="+history[1]);
		System.out.println("history[2]="+history[2]);
		System.out.println("history[3]="+history[3]);
		System.out.println("REPLY_TO="+REPLY_TO);
		System.out.println("MSG_PER_EMAIL821_LIMIT="+MSG_PER_EMAIL821_LIMIT);
		System.out.println("LINKED_CAMP_ID="+LINKED_CAMP_ID);
		System.out.println("END_DATE="+END_DATE);
		System.out.println("QUEUE_DATE="+QUEUE_DATE); 
		*/

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
	String htmlCategories = "";
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
	String CURRENT_TIME = null;
	rs = stmt.executeQuery("SELECT CONVERT(varchar(25), getdate(), 0)");
	if (rs.next())
		CURRENT_TIME = rs.getString(1);
	rs.close();
	CURRENT_TIME = (CURRENT_TIME == null)?"":CURRENT_TIME;
	
	String WizardID = "";	
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
	
	String contEditFrame = "../cont/cont_template_login.jsp?enter_wizard=1";
	//System.out.println("wizard is = " + WizardID);	
	if ((WizardID != null && !WizardID.equals("")) && (STEP.equals("3"))) {
		contEditFrame = "/cms/ui/jsp/ctm/pageedit.jsp?isEdit=true&contentID=" + WizardID;
	}

	/* get target group for step 2 */
	String filterHtml_s2 = "";
	String sSql = "";
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
	String filterHtml_s4 = "No Audience Selected";
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
%>
<HTML>
<HEAD>
	 <%@ include file="../header.html" %>
	 <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	 <script language="javascript" src="../../js/tab_script.js"></script>
	 <script language="javascript">
	 
	 function WizardswitchSteps(tab_id, tab_page_header_id, tab_page_body_id)
	 {
	 	if (tab_id == "" || tab_page_header_id == "" || tab_page_body_id == "") return;

	 	Wizarddisable_all_tab_pages(tab_id);

	 	var tab_page_header = eval(tab_page_header_id);
	 	var tab_page_body = eval(tab_page_body_id);

	 	tab_page_header.className = "SpecialTabOn";
	 	tab_page_body.style.display = "";
		
		if (tab_page_header_id == "tab1_Step2")
		{
			FT.filter_id.style.display = "";
			FT.test_list_id.style.display = "none";
			FT.from_address_id.style.display = "none";
		}
		else if (tab_page_header_id == "tab1_Step4")
		{
			FT.filter_id.style.display = "none";
			FT.test_list_id.style.display = "";
			FT.from_address_id.style.display = "";
		}
		else
		{
			FT.filter_id.style.display = "none";
			FT.test_list_id.style.display = "none";
			FT.from_address_id.style.display = "none";
		}
	 }

	 function Wizarddisable_all_tab_pages(tab_id)
	 {
		var t = document.getElementById(tab_id);
		
		for(var i = 0; i < 1; i++)
		{
			for(var j = 0; j < 4; j++)
			{
				if(t.rows[i].cells[j].className = 'SpecialTabOn')
				{
					t.rows[i].cells[j].className = 'SpecialTabOff'
				}
			}
		}
		
	 	for (i=0; i < t.tBodies.length; i++)
	 	{
	 		if (t.tBodies[i].className == "EditBlock")
	 		{
	 			t.tBodies[i].style.display = "none";
	 		}
	 	}
		
	}
		
	function moveSteps(stepNum)
	{		
		var frm = document.FT;
		frm.step.value = stepNum;
		if (stepNum == "4") {
			<% if( !isDone && !isSending && !isTesting && can.bWrite) { %>
				save();
			<% } else { %>
				WizardswitchSteps("Tabs_Table1", "tab1_Step" + stepNum, "block1_Step" + stepNum);
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
				WizardswitchSteps("Tabs_Table1", "tab1_Step" + stepNum, "block1_Step" + stepNum);
		}
			
	}
		
	</script>

	<style type="text/css">
	
	a {
	outline: none;
	}
	ul#tabnav2 {
		border-bottom: 1px solid #D1D1D1;
		list-style-type: none;
		margin: 5px 0 0;
		padding: 3px 0;
		text-align: left;
	}

	ul#tabnav2 li { 
		display: inline;
	}

	#tabnav2 li a.active  { 
		color: #333333;
		font-weight: bold;
		padding-top: 3px;
		position: relative;
	}

	ul#tabnav2 li a { 
		background: url("../../ooo/images/1x30gri.png") repeat-x scroll 0 0 transparent;
		border-color: #D1D1D1;
		border-style: solid solid none;
		border-width: 1px 1px medium;
		color: #696969;
		font-family: tahoma;
		font-size: 11px;
		font-weight: normal;
		margin-right: 0;
		padding: 3px 15px;
		text-decoration: none;
	}
	.ul#tabnav2 li a:hover {
		text-decoration:none;
		color:#000000;
	}
	
	.prevborder {
		border-right:1px dotted #DDDDDD;
	}
	.nextborder {
		border-left:1px dotted #DDDDDD;
	}
	.SpecialTabOn, .SpecialTabOff {
		background: url("../../ooo/images/1x30gri.png") repeat-x scroll 0 0 transparent;
		border-left: medium none;
		border-right: 1px solid #D1D1D1;
		border-top: medium none;
		border-bottom:1px solid #C9C8C8;
		color: #333333;
		cursor: default;
		font-family: Tahoma;
		font-size: 11px;
		font-weight: bold;
		padding: 6px;
		cursor:pointer;
	}
	.SpecialTabOff {
		font-weight:normal !important;
		font-weight:normal;
		color:#696969 !important;
		color:#696969;
	}
	.specialTabOn {
		background: none repeat scroll 0 0 #ffffff !important;
		background: none repeat scroll 0 0 #ffffff;
		border-bottom: medium none !important;
		border-bottom: medium none;
	}
	.stepHeaders {
		font: 13px/12px Tahoma !important;
		font: 13px/12px Tahoma;
		color: #00759B !important;
		color: #00759B; 
	}
	<!--		
		.prevActive
		{
			font-weight: bold;
		}
		
		.prevDisabled
		{
			color: #999999;
		}
		
		.nextActive
		{
			font-weight: bold;
		}
		
		.nextDisabled
		{
			color: #999999;
		}
		
		TABLE.wizardLayout
		{
			table-layout: fixed;
			width: 100%;
			height: 100%;
		}
		
		table.mnuBar, td.mnuBar
		{
			color: #ffffff;
			padding-top: 3px;
			padding-bottom: 3px;
			padding-left: 7px;
			padding-right: 7px;
			background-color: #7288AC;
			border: #abc0e7 1px solid;
			border-right: #00377a 1px solid;
			border-bottom: #00377a 1px solid;
		}
		
	//-->
	</style>
</HEAD>
<BODY ONLOAD="<%= (!can.bWrite)?"disable_forms();":"" %>">
<table cellspacing="0" cellpadding="0" border="0" width="100%">
	
<%
if (can.bWrite)
{
	%>
	<tr height="30">
		<td>
			<table cellpadding="1" cellspacing="0" border="0">
				<tr>
				<%
				if( !isDone && !isSending && !isTesting)
				{
					%>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="save();">Save</a>
					</td>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="savenexit();">Save &amp; Exit</a>
					</td>
					<%
				}
				else if ((isTesting || isSending) && (null != CAMP_ID))
				{
					%>
					<td vAlign="middle" align="left">
						<a class="resourcebutton" href="wizard.jsp?camp_id=<%= CAMP_ID %>">Refresh</a>
					</td>
					<%
				}
				if( CAMP_ID != null )
				{
					%>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="clone();">Clone</a>
					</td>
					<%
				}
				%>
				</tr>
			</table>
		</td>
	</tr>
<%
}
%>
<!---- START Status Description Area //---->
<% if( tmpStatus >= CampaignStatus.SENT_TO_RCP && tmpStatus <= CampaignStatus.READY_TO_BE_QUEUED ) { %>
	<tr height="70">
		<td>
			<table cellspacing=0 cellpadding=0 width="100%" border=0>
			
				<tr>
					<td valign=top align=center width="100%">
						<table cellspacing="1" cellpadding="0" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
								<% if( tmpType == 1 ) { %>
									<font color="red"><b>Your test process has started</b></font>
								<% } else { %>
									<font color="red"><b>Your campaign process has started</b></font>
								<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%	} %>

<% if( tmpStatus >= CampaignStatus.RECIPS_QUEUED && tmpStatus <= CampaignStatus.READY_TO_SEND ) { %>
	<tr height="70">
		<td>
			<table cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td valign=top align=center width="100%">
						<table cellspacing="1" cellpadding="0" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
								<% if( tmpType == 1 ) { %>
									<font color="red"><b>You have <%= RecipsQueued %> tests <%= DescStatusText %></b></font>
								<% } else { %>
									<font color="red"><b>You have <%= RecipsQueued %> recipients <%= DescStatusText %></b></font>
								<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%	} %>

<% if( tmpStatus == CampaignStatus.BEING_PROCESSED ) { %>
	<tr height="75">
		<td>
			<table cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td valign=top align=center width="100%">
						<table cellspacing="1" cellpadding="0" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
								<% if( tmpType == 1 ) { %>
									<font color="red"><b>You have sent <%= RecipsSent %> out of <%= RecipsQueued %> tests</b></font>
								<%  } else if( tmpType == 3 || tmpType == 4 ) { %>
									<font color="red"><b>Your campaign has sent <%= RecipsSent %> recipients thus far</b></font>
								<% } else { %>
									<font color="red"><b>You have sent to <%= RecipsSent %> out of <%= RecipsQueued %> total recipients</b></font>
								<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%	} %>
<% if( tmpStatus == CampaignStatus.CANCELLED ) { %>
	<tr height="75">
		<td>
			<table cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td valign=top align=center width="100%">
						<table cellspacing="1" cellpadding="0" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
									<font color="red"><b>Your campaign was cancelled. 
									It had sent <%= RecipsSent %> recipients out of <%= RecipsQueued %> total recipients before being cancelled.</b></font>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%	} %>
<% if( tmpStatus == CampaignStatus.ERROR ) { %>
	<tr height="75">
		<td>
			<table cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td valign=top align=center width="100%">
						<table cellspacing="1" cellpadding="0" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
									<font color="red"><b>Your campaign has generated an error. 
									Please confirm that your Target Group has recipients or contact Support for more assistance.</b></font>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%	} %>
<!---- END Status Description Area //---->
	<tr>
		<td>
<FORM METHOD="POST" NAME="FT" ACTION="wizard_save.jsp">
<table id="Tabs_Table1" class="listTable" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td width="%20" class="<%= classStep1 %>" id="tab1_Step1" valign="center" nowrap align="middle" onclick="moveSteps('1');">1. Campaign Name</td>
		<td width="%20" class="<%= classStep2 %>" id="tab1_Step2" valign="center" nowrap align="middle" onclick="moveSteps('2');">2. Audience</td>
		<td width="%20" class="<%= classStep3 %>" id="tab1_Step3" valign="center" nowrap align="middle" onclick="moveSteps('3');">3. Content</td>
		<td width="%20" class="<%= classStep4 %>" id="tab1_Step4" valign="center" nowrap align="middle" onclick="moveSteps('4');">4. Send Campaign</td>
		<td width="%20" style="border-right:none;" class="<%= classStep5 %>" id="tab1_Step5" valign="center" nowrap align="middle" onclick="moveSteps('5');">Logs</td>
	</tr>
	<tr>
		<td colspan="5">&nbsp;</td>
	</tr>
	<!-- Step 1 tab: get campaign name -->
	<tbody class=EditBlock id=block1_Step1<%= styleStep1 %>>
	<tr >
		<td class="stepHeaders" valign="middle" align="center" colspan=5><b>Step 1:</b> Enter Your Campaign Name</td>
	</tr>
	<tr>
		<td valign=top align=center colspan=5>
			<table width="100%" cellspacing=1 cellpadding=10 align=center border=0>
				<tr>
					<td width="150" align="left" valign="middle" nowrap class="prevborder">
						<p align="right" class="prevDisabled">&laquo; Previous Step</p>
						<p align="right">&nbsp;</p>
					</td>
					<td align="center" valign="middle">
						<p>Enter a unique name for your campaign in the text box below.<br>This name is what will show up in the Reporting section.</p>
						<p><INPUT class="inputtexts" TYPE="text" NAME="camp_name" value="<%=CAMP_NAME%>" SIZE="40" MAXLENGTH="50"></p>
					</td>
					<td align="right" width="150px" valign="middle" nowrap class="nextborder">
						<p align="left" class="nextActive">Next Step &raquo;</p>
						<p align="left"><a class="subactionbutton" href="javascript:moveSteps('2');">Select Your Audience</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	</tbody>
	
	<!-- Step 2 tab: select audience (target group) -->
	<tbody class=EditBlock id=block1_Step2<%= styleStep2 %>>
	<tr>
		<td class="stepHeaders"  valign=middle align=center colspan=5><b>Step 2:</b> Select Your Audience</td>
	</tr>
	<tr>
		<td valign=top align=center colspan=5>
			<table width="100%" cellspacing=1 cellpadding=10 align=center border=0>
				<tr>
					<td width="150" align="left" valign="middle" nowrap class="prevborder">
						<p align="right" class="prevActive">&laquo; Previous Step</p>
						<p align="right"><a class="subactionbutton" href="javascript:moveSteps('1');">Name Your Campaign</a></p>
					</td>
					<td align="center" valign="middle">
						<p>From the drop down list below,<br>select which group of recipients you would like to send to.</p>
						<p>
							<select name="filter_id" size="1">
								<option selected value="">---  Choose target group  ---------</option>
								<%= filterHtml_s2 %>
							</select>
							<% if (canTGPreview) { %>
							<br><br>
							<a class="resourcebutton" href="javascript:targetgroup_popup(document.all.item('filter_id')[document.all.item('filter_id').selectedIndex].value);">Preview This Audience</a>
							<% } %>
						</p>
					</td>
					<td align="right" width="150px" valign="middle" nowrap class="nextborder">
						<p align="left" class="nextActive">Next Step &raquo;</p>
						<p align="left"><a class="subactionbutton" href="javascript:moveSteps('3');">Create Your Content</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	</tbody>
	
	<!-- Step 3 tab: select content -->
	<tbody class=EditBlock id=block1_Step3<%= styleStep3 %>>
	<tr>
		<td class="stepHeaders" valign=middle align=center colspan=5><b>Step 3:</b> Create Your Content</td>
	</tr>
	<tr>
		<td valign=top align=center colspan=5>
			<table width="100%" cellspacing=1 cellpadding=10 align=center border=0>

				<tr>
					<td width="150" align="left" valign="top" nowrap class="prevborder">
						<p align="right" class="prevActive">&laquo; Previous Step</p>
						<p align="right"><a class="subactionbutton" href="javascript:moveSteps('2');">Select Your Audience</a></p>
					</td>
					<td align="center" valign="middle">
						<table cellspacing="0" cellpadding="0" border="0" width="100%">
							<tr>
								<td>Use the section below to name and edit the content you would like to send out with this campaign:</td>
							</tr>
							<tr>
								<td><iframe style="width:100%;height:350px;" src="<%= contEditFrame %>" border="0" name="selectContent" frameborder="0" scrolling="auto" id="selectContent"></iframe></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	
	<!-- Step 4 tab: send/test campaign -->
	<tbody class=EditBlock id=block1_Step4<%= styleStep4 %>>
	<tr>
		<td class="stepHeaders" valign=middle align=center colspan=5><b>Step 4:</b> Send Your Campaign</td>
	</tr>
	<tr>
		<td valign=top align=center colspan=5>
			<table width="100%" cellspacing=1 cellpadding=10 align=center border=0>

				<tr>
					<td width="150" align="left" valign="top" nowrap class="prevborder">
						<p align="right" class="prevActive">&laquo; Previous Step</p>
						<p align="right"><a class="subactionbutton" href="javascript:moveSteps('3');">Edit Your Content</a></p>
					</td>
					<td align="center" valign="middle">
						<table width="100%" cellspacing=1 cellpadding=2>

							<tr height="30">
								<td colspan=2>
									<table cellspacing="0" cellpadding="4" width="100%">
										<tr>
											<td align="left" valign="middle" nowrap>
												<select name="test_list_id" size="1">
													<option selected value="">---  Choose test list  -----</option>
												<%
													rs = stmt.executeQuery("SELECT l.list_id, l.list_name, t.type_name FROM cque_email_list l, cque_list_type t " +
																		"WHERE l.type_id = t.type_id AND (l.type_id = 2 OR l.type_id = 5) AND list_name not like 'ApprovalRequest(%)' " +
																		"AND l.cust_id =" + cust.s_cust_id + " ORDER BY l.list_id DESC");
													while( rs.next() ) { 
												%>
													<option value="<%=rs.getString(1)%>"> <%=new String(rs.getBytes(2),"ISO-8859-1")%> (<%=new String(rs.getBytes(3),"ISO-8859-1")%>) </option>
												<%	} rs.close(); %>
												</select>&nbsp;
												<%
												if( !isDone && !isSending && !isTesting && can.bExecute)
												{
												%>
													<a class="buttons-subaction" href="#" onclick="send_test();">Send A Test</a>
												<%
												}
												%>
											</td>
											<td align="right" valign="middle" nowrap>
												<%
												if( !isDone && !isSending && !isTesting && can.bExecute)
												{
												%>
													<a class="buttons-action" href="#" onclick="send();"><%= (isHyatt)?"Request Approval":"Launch Campaign" %></a>
												<%
												}
												%>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td nowrap>Campaign Name</td>
								<td align="left" valign="middle"><b><%=CAMP_NAME%></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="resourcebutton" href="javascript:moveSteps('1');">modify</a></td>
							</tr>
							<tr>
								<td nowrap>From Name</td>
								<td align="left" valign="middle"><input class="inputtexts" type="text" name="from_name" value="<%=FROM_NAME%>" size="40" maxlength="50"></td>
							</tr>
							<tr height="25">
								<td nowrap>From Address </td>
								<td>
									<select name="from_address_id" size="1">
										<option selected value="">---  Choose address  ------</option>
										<%
										rs = stmt.executeQuery("SELECT from_address_id, prefix+'@'+[domain] FROM ccps_from_address WHERE cust_id = "+cust.s_cust_id+" ORDER BY from_address_id DESC");
										while( rs.next() )
										{ 
											%>
											<option value="<%=rs.getString(1)%>"> <%=rs.getString(2)%> </option>
											<%
										}
										rs.close();
										%>
									</select>
								</td>
							</tr>
							<tr height="25">
								<td>To:</td>
								<td nowrap>
									<%= filterHtml_s4 %>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="resourcebutton" href="javascript:moveSteps('2');">modify</a>
								</td>
							</tr>
							<tr height="25">
								<td nowrap>Subject</td>
								<td>
									<input class="inputtexts" type="text" name="subj_html" value="<%=SUBJ_HTML%>" size="40" maxlength="150">
								</td>
							</tr>
							<tr height="25">
								<td nowrap>Response Forwarding</td>
								<td nowrap>
									<input class="inputtexts" type="text" name="response_frwd_addr" value="<%=RESPONSE_FRWD_ADDR%>" size="40" maxlength="255"<%=(isHyatt?" onChange=\"FT.reply_to.value=this.value\"":"")%>>
								</td>
							</tr>
							<tr height="25">
								<td colspan="2">Content&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="resourcebutton" href="javascript:moveSteps('3');">modify</a></td>
							</tr>
							<tr>
								<td align=left colspan="2">

<%
String sIframeSrc = "../blank.jsp";
if ((null != CONT_ID) && (!CONT_ID.equals(""))) 
{
	sIframeSrc = "../cont/cont_preview_2.jsp?cont_id=" + CONT_ID + "&contType=2";
}
%>
<iframe id="prevContent" style="width:100%; height:100%;" src="<%=sIframeSrc%>" frameborder="0" scrolling="yes"></iframe>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>	
		</td>
	</tr>
	</tbody>
	
	<!-- Step 5 tab: campaign history -->
	<tbody class=EditBlock id=block1_Step5<%= styleStep5 %>>
	<tr>
		<td style="padding: 5px;" valign="top" colspan="5">
			<ul id="tabnav2">
				<li><a id="tab6_Step1" class="active" onclick="toggleTabs('tab6_Step','block6_Step',1,3,'active','noClassPassiveTab');" href="javascript:void(0)">Campaign History</a></li>
				<li><a id="tab6_Step2" class="noClassPassiveTab" href="javascript:void(0)" onclick="toggleTabs('tab6_Step','block6_Step',2,3,'active','noClassPassiveTab');">Testing History</a></li>
				<li><a id="tab6_Step3" class="noClassPassiveTab" onclick="toggleTabs('tab6_Step','block6_Step',3,3,'active','noClassPassiveTab');" href="javascript:void(0)">User History</a></li>
			</ul>	
								
			<table id="Tabs_Table6" style="width:100%; height:100%;" cellspacing=0 cellpadding=0 border=0>

				<tbody class=EditBlock id=block6_Step1>
				<tr>
					<td  valign=top align=center colspan=4>
						<table  cellspacing="1" cellpadding="5" width="100%">
						<%
							//Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
							boolean oneHistory = false;
							boolean nonTestSent = false;
							
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
						%>
							<tr>
								<td align="left" valign="middle" width=100 class="CampHeader"><b>Campaign ID</b></td>
								<td> <%=nCampId%></td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Status</b></td>
								<td> <%=sStatusDisplayName%></td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Approved?</b></td>
								<td> <%=sApprovalFlag%></td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Queued</b></td>
								<td id="campDetailTD">
									<%=sRecpQueuedQty%>
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Sent</b> </td>
								<td><%=sRecpSendQty%></td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Created on</b> </td>
								<td align="left" valign="middle" nowrap><%=sCreateDate.replaceAll(",","")%></td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Started on</b> </td>
								<td align="left" valign="middle" nowrap><%=sStartDate.replaceAll(",","")%></td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Finished on</b> </td>
								<td align="left" valign="middle" nowrap><%=sFinishDate.replaceAll(",","")%></td>
							</tr>
						<%
								}
								rs.close();
								if (!oneHistory || !nonTestSent)
								{
									//Supply the campID for the campaign if it was not sent out yet
						%>
							<tr>
								<td align="left" valign="middle" colspan="8" class="CampHeader"><b>Campaign ID:</b> <%=(Integer.parseInt(ORIGIN_CAMP_ID)+1)%></td>
							</tr>
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeading">Created on </td>
								<td>&nbsp;&nbsp;</td>
								<td align="left" valign="middle" nowrap><%=history[0]%></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td align="left" valign="middle" nowrap class="CampHeading">Status</td>
								<td>&nbsp;&nbsp;</td>
								<td align="left" valign="middle" nowrap>Draft</td>
								<td bgcolor="#FFFFFF" width="100%">&nbsp;&nbsp;&nbsp;</td>
							</tr>
						<%
								}
							}
							else
							{
						%>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td class="CampHeader" colspan="9">
									This area will show Campaign History information once you click the Save button.
								</td>
							</tr>
						<%
							}
						%>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block6_Step2 style="display:none;">
				<tr>
					<td valign=top align=center colspan=4>
						<table cellspacing="1" cellpadding="2" width="100%" border="0">
							<tr>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Test ID:</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Status</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Queued</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Sent</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Created</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Started</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Finished</b></td>
							</tr>
						<%
							if( ORIGIN_CAMP_ID != null && !ORIGIN_CAMP_ID.equals("") && !ORIGIN_CAMP_ID.equals("null") )
							{
								//Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
								oneHistory = false;
								nonTestSent = false;
								String histTemp[] = new String[9];
								
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
						%>
							<tr>
								<td align="left" valign="middle"><%=histTemp[7]%></td>
								<td align="left" valign="middle"><%=histTemp[4]%></td>
								<td align="left" valign="middle"><%=histTemp[5]%></td>
								<td align="left" valign="middle"><%=histTemp[6]%></td>
								<td align="left" valign="middle" nowrap><%=histTemp[0].replaceAll(",","")%></td>
								<td align="left" valign="middle" nowrap><%=histTemp[1].replaceAll(",","")%></td>
								<td align="left" valign="middle" nowrap><%=histTemp[2].replaceAll(",","")%></td>
							</tr>
						<%
								}
								rs.close();
								if (oneHistory == false)
								{
						%>
							<tr>
								<td class="CampHeader" colspan="7">No Tests Have Been Sent For This Campaign</td>
							</tr>		
						<%
								}
							}
							else
							{
						%>
							<tr>
								<td class="CampHeader" colspan="7">This area will show Campaign History information once you click the Save button.</td>
							</tr>
						<%
							}
						%>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block6_Step3 style="display:none;">
				<tr>
					<td  valign=top align=left colspan="4">
						<table  cellspacing="1" cellpadding="3" width="100%" border="0">
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
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	</tbody>
</table>

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
<%
	rs = stmt.executeQuery("SELECT type_id, display_name FROM cque_camp_type");
	while( rs.next() ) { 
%>
	<OPTION value="<%=rs.getString(1)%>"> <%=rs.getString(2)%> </OPTION>
<%	} rs.close(); %>
</SELECT>
<SELECT NAME="status_id" SIZE="1" DISABLED style="display:none;">
<%
	rs = stmt.executeQuery("SELECT status_id, display_name FROM cque_camp_status");
	while( rs.next() ) { 
%>
	<OPTION value="<%=rs.getString(1)%>"> <%=rs.getString(2)%> </OPTION>
<%	} rs.close(); %>
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
<%	String campTypes = "3";
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
						((LINKED_CAMP_ID.length()>0)?
							" OR c.origin_camp_id = "+LINKED_CAMP_ID:"") + ")" +
						" ORDER BY c.origin_camp_id DESC");
	}
	while( rs.next() ) { 
	%>
	<option value="<%=rs.getString(1)%>"> <%=new String(rs.getBytes(2),"ISO-8859-1")%> </option>
<%	} rs.close(); %>
</select>

<%
	boolean nonEmailFinger = false;	
	rs = stmt.executeQuery("SELECT a.attr_name FROM ccps_cust_attr ca, ccps_attribute a " +
						"WHERE ca.cust_id = "+cust.s_cust_id+" AND ca.attr_id = a.attr_id AND ca.fingerprint_seq IS NOT NULL");
	while (rs.next()) {
		if (!rs.getString(1).equals("email_821"))
			nonEmailFinger = true;
	}
	if (nonEmailFinger) {
%>
	<input type="checkbox" name="msg_per_email821_limit" style="display:none;">
<%
	}
%>
<INPUT TYPE="hidden" NAME="exclusion_list_id" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="auto_respond_list_id" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="auto_respond_attr_id" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="randomly" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="delay" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="queue_daily_time" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="camp_frequency" VALUE="" style="display:none;">
<INPUT TYPE="hidden" NAME="recip_qty_limit" VALUE="0" style="display:none;">
<INPUT TYPE="hidden" NAME="limit_per_hour" VALUE="0" style="display:none;">
<br><br>
</FORM>

<SCRIPT LANGUAGE="JavaScript">
<%@ include file="../../js/scripts.js" %>
<%@ include file="../camp/camp_edit/single/js_popup.jsp" %>
<%@ include file="wizard_camp_save.jsp" %>


FT.type_id2.value=<%=HtmlUtil.escape(CAMP_TYPE_ID)%>;
FT.status_id.value=<%=HtmlUtil.escape(STATUS_ID)%>;
<%
if (CONT_ID != null && !CONT_ID.equals("")) {
rs = stmt.executeQuery("" +
	"SELECT 1 FROM ccnt_content WHERE cont_id = "+CONT_ID+" AND status_id <> 90");
if (!rs.next()) CONT_ID = "";
}
%>

FT.cont_id.value="<%=HtmlUtil.escape(CONT_ID)%>";
FT.from_address_id.value="<%=HtmlUtil.escape(FROM_ADDRESS_ID)%>";
FT.filter_id.value="<%=HtmlUtil.escape(FILTER_ID)%>";
FT.test_list_id.value="<%=HtmlUtil.escape(TEST_LIST_ID)%>";
FT.recip_qty_limit.value="<%=HtmlUtil.escape(RECIP_QTY_LIMIT)%>";
FT.limit_per_hour.value="<%=HtmlUtil.escape(LIMIT_PER_HOUR)%>";
FT.linked_camp_id.value="<%=HtmlUtil.escape(LINKED_CAMP_ID)%>";

<%
	if (nonEmailFinger) {
%>
FT.msg_per_email821_limit.checked = <%= MSG_PER_EMAIL821_LIMIT.equals("0")?"false":"true" %>;
<% } %>


</SCRIPT>
</BODY>
</HTML>
<%	
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
