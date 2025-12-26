<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.tgt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="wvalidator.jsp"%>
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

if (CAMP_ID != null && CAMP_ID.equals("null")) {
	CAMP_ID = "";
}

if (request.getParameter("step") == null ) 
{
	STEP = "1";
}

Customer cSuper = ui.getSuperiorCustomer();

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
	String		CAMP_NAME				= "";
	String		FROM_NAME				= cSuper.s_cust_name;
	String		SUBJ_HTML				= "";
	String		RESPONSE_FRWD_ADDR		= "";
	String		START_DATE				= "";
	String		END_DATE				= "";
	String		RECIP_QTY_LIMIT			= "0";
	String		QUEUE_DATE				= "";
	String		EXCLUSION_LIST_ID		= "";
	String		LIMIT_PER_HOUR			= "5000";
	String		REPLY_TO	 			= user.s_email;
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
			" FROM cque_campaign c with(nolock) " +
			"	LEFT OUTER JOIN cque_camp_send_param p with(nolock) ON c.camp_id = p.camp_id" +
			"	LEFT OUTER JOIN cque_camp_list l with(nolock) ON c.camp_id = l.camp_id" +
			"	LEFT OUTER JOIN cque_msg_header h with(nolock)  ON c.camp_id = h.camp_id" +
			"	LEFT OUTER JOIN cque_schedule s with(nolock)  ON c.camp_id = s.camp_id" +
			"	INNER JOIN cque_linked_camp lc with(nolock)  ON c.camp_id  = lc.camp_id" +
			"	INNER JOIN (cque_camp_edit_info e with(nolock)" +
			"			INNER JOIN ccps_user u1 with(nolock) ON e.creator_id  = u1.user_id" +
			"			INNER JOIN ccps_user u2 with(nolock) ON e.modifier_id = u2.user_id)" +
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
			FROM_NAME				= new String(rs.getBytes(9),"UTF-8");
			SUBJ_HTML				= new String(rs.getBytes(10),"UTF-8");
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
			"  FROM cque_campaign with(nolock) " +
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
			" FROM cque_campaign c with(nolock) " +
			"	LEFT OUTER JOIN cque_camp_statistic s with(nolock) ON c.camp_id = s.camp_id" +
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
				" FROM ccps_category c with(nolock)" +
					" LEFT OUTER JOIN ccps_object_category oc with(nolock)" +
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
	String contentName = "";
	if (null != CONT_ID)
	{
		if (!CONT_ID.equals(""))
		{
			rs = stmt.executeQuery(
				" SELECT cei.wizard_id, c.cont_name" +
				"  FROM ccnt_content c with(nolock), ccnt_cont_edit_info cei with(nolock)" +
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
				contentName = new String(rs.getBytes(2),"UTF-8");
				contentName = contentName.replace("??","ş");
			}
			rs.close();
		}
	}
	
	String contEditFrame = "cont_template_login.jsp?enter_wizard=1";

	if ((WizardID != null && !WizardID.equals("")) && (STEP.equals("3"))) {
		contEditFrame = "ctm/pageedit.jsp?isEdit=true&contentID=" + WizardID;
	}

	/* get target group for step 2 */
	String filterHtml_s2 = "";
	String sSql = "";
	if ( (CATEGORY_ID == null) || (CATEGORY_ID.equals("0")) )
	{
		sSql =
			" SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
			" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
			" FROM ctgt_filter with(nolock)" +
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
			" FROM ctgt_filter f with(nolock), ccps_object_category oc with(nolock)" +
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
	String filterHtml_s4 = "";
	String filterHtml_s4_id = ""; 
	if (FILTER_ID != null && !FILTER_ID.equals("") && !FILTER_ID.equals("null")) {
		if ( (CATEGORY_ID == null) || (CATEGORY_ID.equals("0")) )
		{
			sSql =
				" SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
				" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
				" FROM ctgt_filter with(nolock)" +
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
				" FROM ctgt_filter f with(nolock), ccps_object_category oc with(nolock)" +
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
				filterHtml_s4_id = sFilterId;
			}
		}
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<HEAD>
	 <%@ include file="../header.html" %>
	<meta http-equiv="X-UA-Compatible" content="IE=9" />

	<link rel="stylesheet" href="../mini/default.css" TYPE="text/css">
	 <script language="javascript" src="../../js/tab_script.js"></script>
	 <script language="javascript" src="../mini/jquery.js"></script>
	 <script language="javascript" src="../mini/jquery.iframe-auto-height.plugin.js"></script>
	 <script language="javascript" src="../mini/bootstrap-tooltip.js"></script>
	 <script language="javascript" src="../mini/bootstrap.min.js"></script>

	 <script language="javascript">	
	 
	function makesure() {
		if (confirm('Kampanyayı başlatmak istediğinize emin misiniz?')) {
			send();
		}
		else {
			return false;
		}
	}

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
	
	var stepNumber = <%	if(STEP.equals("4")) out.print("4"); else out.print("1"); %>;
	
	
	function switchSteps(stepNum)
	{
		var frm = document.FT;
		frm.step.value = stepNum;
		
		var elem = document.getElementById('step'+stepNum);
		var cont = document.getElementById('block1_Step'+stepNum);
		
		stepNumber = stepNum;
		
		if(stepNum == 1)
		document.getElementById("downbtn").style.display = 'none';
		else
		document.getElementById("downbtn").style.display = '';
		
		for(var i = 1; i < 5; i++)
		{
			
			for(var i = 1; i < stepNum; i++)
			{
				document.getElementById('step'+i).className = '';
			}
			
			for(var i = 4; i > stepNum; i--)
			{
				document.getElementById('step'+i).className = 'disabled';
			}
			
			if(i == stepNum)
			{
				document.getElementById('step'+stepNum).className = 'current';
			}
			break;
		}
		
		
		
		for(var i = 1; i < 5; i++)
		{
			document.getElementById('block1_Step'+i).style.display = 'none';
		}
		
		if(stepNum == '4') 
		{
			<% if( !isDone && !isSending && !isTesting && can.bWrite) { %>
				save();
			<% } else { %>
				switchSteps(stepNum);
			<% } %>
		} 
		else 
		{
			<%
			if (null != CONT_ID)
			{
				if( !CONT_ID.equals(""))
				{
					%>
					if (stepNum == '3')	{
						window.frames["selectContent"].document.location.href = "/cms/ui/jsp/mini/ctm/pageedit.jsp?isEdit=true&contentID=<%= WizardID %>";
					}
					<%
				}
			}
			%>
			cont.style.display = 'block';
		}
	}		
	
	function previewContent(url)
	{
		winpops = window.open(url,"","toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=700,height=600,left = 100,top = 100")
	}
	
	function stepUpNDown(position)
	{
		if(position == 'down')
		{
			if(stepNumber == 1)
			{
				return false;
			}
			else 
			{
				if(stepNumber == 2)
				{
					document.getElementById("downbtn").style.display = 'none';
				}	
				if(stepNumber == 4)
				{
					document.getElementById("upbtn").style.display = '';
				}				
				stepNumber--;
				switchSteps(stepNumber);
			}
		}
		else 
		{
			if(stepNumber == 4)
			{
				return false;
			}
			else
			{
				if(stepNumber == 1)
				{
					document.getElementById("downbtn").style.display = '';
				}
				if(stepNumber == 3)
				{
					document.getElementById("upbtn").style.display = 'none';
				}
				
				stepNumber++;
				switchSteps(stepNumber);
				
			}
		}
	}
	
$(document).ready(function() {
	
	<%	if(STEP.equals("4")) out.print("document.getElementById('upbtn').style.display = 'none';");%>
	
	$('#persfield').change(function() {
		var usePers = $('#persfield').is(':checked');
		if(usePers) 
			$('#persfieldvalue').css('display','inline');
		else 
			$('#persfieldvalue').css('display','none');
	});
});
	
	</script>
</HEAD>
<BODY ONLOAD="<%= (!can.bWrite)?"disable_forms();":"" %>">

	<%
		String activeTab = "home";
		
		if(request.getParameter("a") != null)
		{
				String param = request.getParameter("a");
				
				if(param.equals("campaigns"))
					activeTab = "campaigns";
				else if(param.equals("reports"))
					activeTab = "reports";
		}
	%>
	<div id="wrapper">
		
		<ul id="tabnav">
				<li>
					<a class="" href="home.jsp?a=home">Hesap Özeti</a>
				</li>
				<li>
					<a class="active" href="campaigns.jsp?a=campaigns">Kampanyalar</a>
				</li>
				<li>
					<a class="" href="reports.jsp?a=reports">Raporlar</a>
				</li>
				<li>
					<a class="" href="help.jsp?a=help">Yardım</a>
				</li>
			</ul>
			<div style="clear:both"></div>
		<div id="container">
			
			
			
			<div id="main-container">
<%
if (can.bWrite)
{
	%>
	
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td align="left">
				<a target="_blank" href="help.jsp?a=help" class="zbuttons zbuttons-medium zbuttons-light-gray">
					<span class="zicon zicon-black zicon-help"></span>
					<span class="zlabel">Yardım</span>
				</a>
			</td>

			<%
			if(isDone) {
				out.println("<td align='center'><div style='font-size:11px;' class='error-box'>Bu kampanya gönderilmiş durumda !!<div></td><td width='300px;'></td>");
			}	
			%>
			<td align="right">
				<%
				if( !isDone && !isSending && !isTesting)
				{
					%>
						<a href="#" onclick="savenexit();" class="zbuttons zbuttons-medium zbuttons-blue">
							<span class="zicon zicon-white zicon-save"></span>
							<span class="zlabel">Kaydet &amp; Çık</span>
						</a>
					<%
				}
				else if ((isTesting || isSending) && (null != CAMP_ID))
				{
					%>
						<a class="resourcebutton" href="wizard.jsp?camp_id=<%= CAMP_ID %>">Yenile</a>
					<%
				}
				%>
			</td>
		</tr>
	</table>

<%
}
%>

<div class="wizard-content">
	<div id="wizard-menu-container">
			<ul id="wizard-menu">
				<li class="stepli1 ">
					<a class="<%if (request.getParameter("step") != null) {out.println("");}else{out.println("current");}%>" id="step1" onclick="switchSteps('1');" href="javascript:void(null);">
						<span>Kampanya Adı</span>
					</a>
				</li>
				<li class="stepli2">
					<a class="<%if (request.getParameter("step") != null) {out.println("");}else{out.println("disabled");}%>" id="step2" onclick="switchSteps('2');" href="javascript:void(null);">
						<span>Hedef Grup</span>
					</a>
				</li>
				<li class="stepli3">
					<a class="<%if (request.getParameter("step") != null) {out.println("");}else{out.println("disabled");}%>" id="step3" onclick="switchSteps('3');" href="javascript:void(null);">
						<span>İçerik</span>
					</a>
				</li>
				<li class="stepli4">
					<a class="<%if (request.getParameter("step") != null) {out.println("end current");}else{out.println("disabled");}%> lastchild" id="step4" onclick="switchSteps('4');" href="javascript:void(null);">
						<span>Gönder</span>
					</a>
				</li>
			</ul>
		
			<a id="upbtn" onclick="javascript:stepUpNDown('up');" href="#" class="zbuttons zbuttons-normal zbuttons-steps pabsoluter">
				<span class="zicon zicon-black zicon-next"></span>
				<span class="zlabel">Devam Et</span>
			</a>
		
			<a id="downbtn" onclick="javascript:stepUpNDown('down');" href="#" style="display:<%if(STEP.equals("4")) out.print(""); else out.println("none");%>" class="zbuttons zbuttons-normal zbuttons-steps pabsolutel">
				<span class="zicon zicon-black zicon-prev"></span>
				<span class="zlabel">Geri Dön</span>
			</a>
		</div>
			

<!---- START Status Description Area //---->
<% if( tmpStatus >= CampaignStatus.SENT_TO_RCP && tmpStatus <= CampaignStatus.READY_TO_BE_QUEUED ) { %>
<div class="notification-box">
<% if( tmpType == 1 ) { %>
	<b>Bilgilendirme!</b> Test işleminiz başlatılmıştır. Her hangi bir hatanın oluşmaması için test kampanyanızı kontrol ettikten sonra
	gerçek kampanyanızı başlatın.
<% } else { %>
	<b>Bilgilendirme!</b> Kampanya işleminiz başlatılmıştır.
<%	} %>
</div>
<%	} %>

<% if( tmpStatus >= CampaignStatus.RECIPS_QUEUED && tmpStatus <= CampaignStatus.READY_TO_SEND ) { %>
<div class="notification-box">
<% if( tmpType == 1 ) { %>
	You have <%= RecipsQueued %> tests <%= DescStatusText %>
<% } else { %>
	You have <%= RecipsQueued %> recipients <%= DescStatusText %>
<%	} %>
</div>
<%	} %>

<% if( tmpStatus == CampaignStatus.BEING_PROCESSED ) { %>
<div class="notification-box">
<% if( tmpType == 1 ) { %>
	You have sent <%= RecipsSent %> out of <%= RecipsQueued %> tests
<%  } else if( tmpType == 3 || tmpType == 4 ) { %>
	Your campaign has sent <%= RecipsSent %> recipients thus far
<% } else { %>
	You have sent to <%= RecipsSent %> out of <%= RecipsQueued %> total recipients
<%	} %>
</div>
<%	} %>

<% if( tmpStatus == CampaignStatus.CANCELLED ) { %>
<div class="notification-box">
Your campaign was cancelled. 
It had sent <%= RecipsSent %> recipients out of <%= RecipsQueued %> total recipients before being cancelled.</b></font>						
</div>
<%	} %>

<% if( tmpStatus == CampaignStatus.ERROR ) { %>
<div class="notification-box">
<font color="red"><b>Your campaign has generated an error. 
Please confirm that your Target Group has recipients or contact Support for more assistance.</b></font>
</div>
<%	} %>

<!---- START Status Description Area End //---->

<table cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr>
		<td>
<FORM METHOD="POST" NAME="FT" ACTION="wizard_save.jsp">
<!-- Block Step 1 Content -->
<div id="block1_Step1" style="margin-top:5px;<%if (request.getParameter("step") != null) {out.println(";display:none;");}%>">
	<table cellpadding="0" cellspacing="0" width="100%" class="list-table noborder-p8">
		<tr>
			<td style="border-bottom:none" colspan="2" class="desc-texts">Aşağıda ki kutucuğa kampanya ismini girin. Kampanyaları ayrıştırabilmek için kampanyanıza eşsiz bir isim verin.</td>
		</tr>
		<tr>
			<td class="htexts" width="100">Kampanya Adı</td>
			<td><INPUT id="camp_name" class="inputtexts" TYPE="text" NAME="camp_name" value="<%=CAMP_NAME%>" SIZE="40" MAXLENGTH="50"></td>
		</tr>
	</table>
</div>
<!-- Block Step 1 Content End -->

<!-- Block Step 2 Content -->
<div id="block1_Step2" style="margin-top:5px;display:none;">
	<table cellpadding="0" cellspacing="0" width="100%" class="list-table noborder-p8">
		<tr>
			<td style="border-bottom:none" colspan="2" class="desc-texts">Kampanyanızı hangi hedef gruba göndereceğinizi seçin.</td>
		</tr>
		<tr>
			<td class="htexts" width="160">Gönderilecek Hedef Grup</td>
			<td>
				<select name="filter_id" size="1" id="filter_id">
					<option selected value="">---  Bir hedef grup seçin ---------</option>
					<%= filterHtml_s2 %>
				</select>
			</td>
		</tr>
	
	</table>
</div>
<!-- Block Step 2 Content -->

<!-- Block Step 3 Content -->
<div id="block1_Step3" style="margin-top:5px;display:none;">
	<iframe src="<%= contEditFrame %>" style="overflow-y:auto;overflow-x:hidden" height="500" width="100%" name="selectContent" id="selectContent" scrolling="yes" frameborder="0" class="scontent"></iframe>
</div>
<!-- Block Step 3 Content -->

<!-- Block Step 4 Content -->
<%
FilterStatistic filter_stat = null;
int p_set_sendout_total = 0;
int t_recip_qty = 0;
boolean disableSending = false;

if(!filterHtml_s4.equals("")) 
{
	filter_stat = new FilterStatistic(filterHtml_s4_id);
	t_recip_qty = (filter_stat.s_recip_qty == null) ? Integer.parseInt("0"): Integer.parseInt(filter_stat.s_recip_qty); 
	
	CustCredit cc = new CustCredit(cust.s_cust_id);

	int p_remaining_credit = Integer.parseInt(cc.s_remaining_credit);
	int p_used_credit = Integer.parseInt(cc.s_used_credit);
	
	disableSending = false;

	//if(p_remaining_credit == 0) 
	//{
	//	disableSending = true;
	//}
	//else if(p_remaining_credit < t_recip_qty)
	//{
	//	p_set_sendout_total = p_remaining_credit;
		//cc.s_used_credit = Integer.toString(p_used_credit + p_set_sendout_total);
		//cc.s_remaining_credit = Integer.toString(p_remaining_credit - p_set_sendout_total);
		//cc.saveWithSync();
	//}
	//else
	//{
		
		p_set_sendout_total = t_recip_qty;
		//cc.s_used_credit = Integer.toString(p_used_credit + p_set_sendout_total);
		//cc.s_remaining_credit = Integer.toString(p_remaining_credit - p_set_sendout_total);
		//cc.saveWithSync();
	//}
	//RECIP_QTY_LIMIT = Integer.toString(p_set_sendout_total);
	//RECIP_QTY_LIMIT = Integer.toString(0);
	//RECIP_QTY_LIMIT = '0';
}


%>
<div id="block1_Step4" style="margin-top:5px<%if (request.getParameter("step") == null) {out.println(";display:none;");}%>">
<select style="display:none" name="test_list_id" size="1">
<option selected value="">---  Bir test listesi seçin  -----</option>
<%
rs = stmt.executeQuery("SELECT l.list_id, l.list_name, t.type_name FROM cque_email_list l with(nolock) , cque_list_type t with(nolock) " +
					"WHERE l.type_id = t.type_id AND (l.type_id = 2 OR l.type_id = 5) AND list_name not like 'ApprovalRequest(%)' " +
					"AND l.cust_id =" + cust.s_cust_id + " ORDER BY l.list_id DESC");
while( rs.next() ) { 
%>
<option value="<%=rs.getString(1)%>"> <%=new String(rs.getBytes(2),"ISO-8859-1")%> (<%=new String(rs.getBytes(3),"ISO-8859-1")%>) </option>
<%	} rs.close(); %>
</select>


<div class="camp-section">
	<div class="camp-section-info">
		<div class="camp-section-header">Kampanya Adı</div>
		<div class="camp-section-desc"><span><%=CAMP_NAME%></span></div>
	</div>
	<div class="camp-section-edit"><a href="#" onclick="javascript:switchSteps('1')">düzenle</a></div>
	<div style="clear:both"></div>
</div>

<div class="camp-section">
	<input class="inputtexts rofield" type="hidden" readonly="readonly" name="from_name" value="<%=FROM_NAME%>" size="40" maxlength="50">
	<div class="camp-section-header">Gönderen Adı</div>
	<div class="camp-section-desc">Emaillerinizde gönderen adı alanında <span><%=FROM_NAME%></span> gözükecektir.</div>
	<div style="clear:both"></div>
</div>

<div class="camp-section">
	<input type="hidden" class="inputtexts" name="reply_to" value="<%=user.s_email%>" size="40" maxlength="255">
	<div class="camp-section-header">Cevap Email</div>
	<div class="camp-section-desc">Emaillerinize gelen cevaplar <span><%=user.s_email%></span> adresine gelecektir.</div>
	<div style="clear:both"></div>
</div>

<%
	String fromAddrView = "";
	int fromAddrId = 0;

	rs = stmt.executeQuery("SELECT TOP 1 from_address_id, prefix+'@'+[domain] FROM ccps_from_address with(nolock) WHERE cust_id = "+cust.s_cust_id+" ORDER BY from_address_id DESC");
	for(int j=1;rs.next(); j++)
	{ 
			fromAddrId = rs.getInt(1);
			fromAddrView = rs.getString(2);
			out.println("<input class='inputtexts' type='hidden' name='from_address_id' value='"+Integer.toString(fromAddrId)+" '>");
	}
	rs.close();
%>

<input class="inputtexts" type="hidden" name="response_frwd_addr" value="<%=fromAddrView%>" size="40" maxlength="255">
				
<div class="camp-section">
	
	<div class="camp-section-info">
		<div class="camp-section-header">Hedef Grup</div>
		<div class="camp-section-desc">
	
	<%
		if(filterHtml_s4.equals(""))
			out.println("<span style='color:#FF0000'>Hedef Grup Seçilmedi</span> ");
		else
			out.println("Emailleriniz <span>"+filterHtml_s4+"</span> listesinden <span style='font-size:20px;color:#FF0000;'>"+ p_set_sendout_total + "</span> kişiye gönderilecektir. <br><i>Kredinizin yetmediği durumda, kalan kredi kadar gönderim yapılacaktır.</i></span>");
	%>
	
		</div>
	</div>
	<div class="camp-section-edit"><a href="#" onclick="javascript:switchSteps('2')">düzenle</a></div>
	<div style="clear:both"></div>
</div>

<div class="camp-section">
	<div class="camp-section-info">
		<div class="camp-section-header">İçerik</div>
		<div class="camp-section-desc">
	<%
	String sIframeSrc = "../blank.jsp";
	if ((null != CONT_ID) && (!CONT_ID.equals(""))) 
	{
		sIframeSrc = "../cont/cont_preview_2.jsp?cont_id=" + CONT_ID + "&contType=2";
	}
	
	if(contentName.equals(""))
		out.println("<span style='color:#FF0000'>İçerik Oluşturulmadı</span>");
	else
		out.println("Email içeriği olarak <span>"+contentName+"</span> gönderilecektir. ");
	%>
	<%
	if ((null != CONT_ID) && (!CONT_ID.equals(""))) 
	{
	%>
			İçeriğinizi önizlemek için <a href="javascript:previewContent('<%=sIframeSrc%>');">buraya</a> tıklayın. 
	<%
	}
	%>
				
		</div>
		</div>
	<div class="camp-section-edit"><a href="#" onclick="javascript:switchSteps('3')">düzenle</a></div>
	<div style="clear:both"></div>
</div>

<div class="camp-section">
	<div class="camp-section-header">Email Başlığı</div>
	<div class="camp-section-desc">
		Emailinizin konu başlığını belirleyin.
		<div style="margin-bottom:5px;margin-top:10px;line-height: 20px;">
			<input checked="checked" id="persfield" style="display:block;float:left" type="checkbox" name="personalize" value=""> 
			<label style="display:block;float:left">Email konusunun başınında özelleştirilmiş isim kullan (örn: Onur Kaplan)</label>
			<div style="clear:both;"></div>
		</div>
		<input style="color:#666666" disabled="disabled" id="persfieldvalue" value="Merhaba !*pnmfull;*!, " class="inputtexts" type="text" name="persfield" style="width:120px">
		<input class="inputtexts" type="text" name="subj_html" value="<%=SUBJ_HTML%>" size="40" maxlength="150">
	</div>
	<div style="clear:both"></div>
</div>


	<%
	if( !isDone && !isSending && !isTesting && can.bExecute && !disableSending)
	{
	%>		
		<a href="#" onclick="return makesure();" class="zbuttons zbuttons-normal zbuttons-green mta5">
			<span class="zicon zicon-white zicon-confirm"></span>
			<span class="zlabel"><%= (isHyatt)?"Onay bekliyor":"Kampanyayı Başlat" %></span>
		</a>
	<%
	}


	if(disableSending) {
		out.println("<div style='font-size:11px;' class='error-box'><b>Üzgünüz!</b> krediniz bu kampanyayı başlatmak için yeterli değil.</div>");
	}
	%>
</div>
<!-- Block Step 4 Content -->
<%
if(isDone){
//	out.println("zzzc");
}
%>	

<table id="Tabs_Table1" class="listTable" cellspacing="0" cellpadding="0" width="100%">	



	<!-- Step 5 tab: campaign history -->
	<tbody class=EditBlock id=block1_Step5 style="display:none;">
	<tr>
		<td style="padding: 5px;" valign="top" colspan="5">
			<ul id="tabnav2">
				<li><a id="tab6_Step1" class="active" onclick="toggleTabs('tab6_Step','block6_Step',1,3,'active','noClassPassiveTab');" href="javascript:void(0)">Kampanya Geçmişi</a></li>
				<li><a id="tab6_Step2" class="noClassPassiveTab" href="javascript:void(0)" onclick="toggleTabs('tab6_Step','block6_Step',2,3,'active','noClassPassiveTab');">Test Geçmişi</a></li>
				<li><a id="tab6_Step3" class="noClassPassiveTab" onclick="toggleTabs('tab6_Step','block6_Step',3,3,'active','noClassPassiveTab');" href="javascript:void(0)">Kullanıcı Geçmişi</a></li>
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
									" FROM cque_campaign c with(nolock)" +
									"	LEFT OUTER JOIN cque_camp_statistic s with(nolock) ON c.camp_id = s.camp_id" +
									"	INNER JOIN cque_camp_edit_info e with(nolock) ON c.camp_id = e.camp_id" +
									"	INNER JOIN cque_camp_type t with(nolock) ON c.type_id = t.type_id" +
									"	INNER JOIN cque_camp_status a with(nolock) ON c.status_id = a.status_id" +
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
								<td align="left" valign="middle" nowrap class="CampHeading"><b>Oluşturulma Tarihi</b></td>
								<td>&nbsp;&nbsp;</td>
								<td align="left" valign="middle" nowrap><%=history[0]%></td>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td align="left" valign="middle" nowrap class="CampHeading"><b>Durum</b></td>
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
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Durum</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Sıraya Alınan</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b># Gönderilen</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Oluşturulma</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Başlama</b></td>
								<td align="left" valign="middle" nowrap class="CampHeader"><b>Bitiş</b></td>
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
									" FROM cque_campaign c with(nolock) " +
									"	LEFT OUTER JOIN cque_camp_edit_info e with(nolock) ON c.camp_id = e.camp_id" +
									"	LEFT OUTER JOIN cque_camp_statistic s with(nolock) ON c.camp_id = s.camp_id" +
									"	INNER JOIN cque_camp_type t with(nolock) ON c.type_id = t.type_id" +
									"	INNER JOIN cque_camp_status a with(nolock) ON c.status_id = a.status_id" +
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
								<td class="CampHeader" colspan="7">Bu kampanya için hiç test gönderilmemiş!</td>
							</tr>		
						<%
								}
							}
							else
							{
						%>
							<tr>
								<td class="CampHeader" colspan="7">Kaydet butonuna bastıktan sonra bu alan kampanya geçmişini gösterecektir.</td>
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
								<td class="CampHeader"><b>Oluşturan</b></td>
								<td><%= history[1] %></td>
								<td class="CampHeader"><b>En son güncelleyen</b></td>
								<td><%= history[3] %></td>
							</tr>
							<tr>
								<td class="CampHeader"><b>Oluşturulma tarihi</b></td>
								<td><%= history[0] %></td>
								<td class="CampHeader"><b>Son güncellenme tarihi</b></td>
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
<INPUT TYPE="hidden" NAME="mode" value="save">
<INPUT TYPE="hidden" NAME="clone" value="false">
<INPUT TYPE="hidden" NAME="type_id" value="<%=CAMP_TYPE_ID%>">
<INPUT TYPE="hidden" NAME="form_flag"	value="0">
<SELECT NAME="type_id2" SIZE="1" DISABLED style="display:none;">
<%
	rs = stmt.executeQuery("SELECT type_id, display_name FROM cque_camp_type with(nolock) ");
	while( rs.next() ) { 
%>
	<OPTION value="<%=rs.getString(1)%>"> <%=rs.getString(2)%> </OPTION>
<%	} rs.close(); %>
</SELECT>
<SELECT NAME="status_id" SIZE="1" DISABLED style="display:none;">
<%
	rs = stmt.executeQuery("SELECT status_id, display_name FROM cque_camp_status with(nolock)");
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

<select name="linked_camp_id" size="1" style="display:none;">
	<option selected value="">---  Choose Campaign ----------------------</option>
<%	String campTypes = "3";
	if ( (CATEGORY_ID == null) || (CATEGORY_ID.equals("0")) ) {
		rs = stmt.executeQuery("SELECT DISTINCT origin_camp_id, camp_name" +
						" FROM cque_campaign with(nolock)" +
						" WHERE type_id in ("+campTypes+")" +
						" AND cust_id = " + cust.s_cust_id +
						" AND status_id > 0 " +
						" AND origin_camp_id IS NOT NULL" +
						" ORDER BY origin_camp_id DESC");
	} else {
		rs = stmt.executeQuery(	"SELECT DISTINCT c.origin_camp_id, c.camp_name" +
						" FROM cque_campaign c with(nolock), ccps_object_category oc with(nolock)" +
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
	rs = stmt.executeQuery("SELECT a.attr_name FROM ccps_cust_attr ca with(nolock), ccps_attribute a with(nolock)" +
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
<INPUT TYPE="hidden" NAME="recip_qty_limit" VALUE="<%=p_set_sendout_total%>" style="display:none;">
<INPUT TYPE="hidden" NAME="limit_per_hour" VALUE="5000" style="display:none;">
<br><br>
</FORM>
</div>

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
//FT.from_address_id.value="<%=HtmlUtil.escape(FROM_ADDRESS_ID)%>";
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
	 <script type="text/javascript">
		//$("[rel=tooltip]").tooltip();		
	</script>
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