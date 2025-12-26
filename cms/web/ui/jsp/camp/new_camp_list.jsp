<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

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
AccessPermission canRept = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

// ********** JM
AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);

//Is it the standard ui?
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
if (sSelectedCategoryId == null) sSelectedCategoryId = "0";

String		TYPE_ID		= request.getParameter("type_id");
String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

String		STATUS_ID		= request.getParameter("status_id");
String		campaignType	= "Error";

int			curPage			= 1;
int			amount			= 0;

STATUS_ID	= (STATUS_ID	== null) ? "-1" : STATUS_ID;
curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

// ********** KU

if (samount == null) samount = ui.getSessionProperty("camp_list_page_size");
if ((samount == null)||("".equals(samount))) samount = "25";
try { amount = Integer.parseInt(samount); }
catch (Exception ex) { samount = "25"; amount = 25; }
ui.setSessionProperty("camp_list_page_size", samount);

if (TYPE_ID == null) TYPE_ID = ui.getSessionProperty("camp_list_type_id");
if ((TYPE_ID == null)||("".equals(TYPE_ID))) TYPE_ID = "2";
ui.setSessionProperty("camp_list_type_id", TYPE_ID);
	
// ********** KU

String sAutoQueueDailyFlag = request.getParameter("auto_queue_daily_flag");
if(sAutoQueueDailyFlag==null) sAutoQueueDailyFlag="0";

String sCampTypeLabel = "Standard";
String sFinishLabel = "Finish Date";
boolean useEnd = false;

if (TYPE_ID.equals("5")) {
	sCampTypeLabel = "Web/DM/Call";
}
else if (TYPE_ID.equals("4")) {
	sCampTypeLabel = "Automated";
	sFinishLabel = "End Date";
	useEnd = true;
}
else if (TYPE_ID.equals("3")) {
	sCampTypeLabel = "Send To Friend";
	sFinishLabel = "End Date";
	useEnd = true;
}
else if (TYPE_ID.equals("2")) {
	sCampTypeLabel = "Standard";
}

boolean showCamps = false;
boolean showCamp1 = false;
boolean showCamp2 = false;
boolean showCamp3 = false;
boolean showCamp4 = false;

String campWidth1 = "25%";
String campWidth2 = "25%";
String campWidth3 = "25%";
String campWidth4 = "25%";

boolean canS2F = ui.getFeatureAccess(Feature.S2F_CAMP);
boolean canAutoCamp = ui.getFeatureAccess(Feature.AUTO_CAMP);
boolean canWebDMCall = ui.getFeatureAccess(Feature.WEB_DM_CALL);
boolean canPrint = ui.getFeatureAccess(Feature.PRINT_ENABLED);

if (canS2F)
{
	showCamp1 = true;
	showCamp2 = true;
}
if (canAutoCamp)
{
	showCamp1 = true;
	showCamp3 = true;
}
if (canWebDMCall)
{
	showCamp1 = true;
	showCamp4 = true;
}

if (showCamp1)
{
	showCamps = true;
}

if (showCamp1 && showCamp2 && showCamp3 && !showCamp4)
{
	campWidth1 = "34%";
	campWidth2 = "33%";
	campWidth3 = "33%";
	campWidth4 = "";
}
if (showCamp1 && showCamp2 && !showCamp3 && showCamp4)
{
	campWidth1 = "34%";
	campWidth2 = "33%";
	campWidth3 = "";
	campWidth4 = "33%";
}
if (showCamp1 && !showCamp2 && showCamp3 && showCamp4)
{
	campWidth1 = "34%";
	campWidth2 = "";
	campWidth3 = "33%";
	campWidth4 = "33%";
}
if (showCamp1 && showCamp2 && !showCamp3 && !showCamp4)
{
	campWidth1 = "50%";
	campWidth2 = "50%";
	campWidth3 = "";
	campWidth4 = "";
}
if (showCamp1 && !showCamp2 && showCamp3 && !showCamp4)
{
	campWidth1 = "50%";
	campWidth2 = "";
	campWidth3 = "50%";
	campWidth4 = "";
}
if (showCamp1 && !showCamp2 && !showCamp3 && showCamp4)
{
	campWidth1 = "50%";
	campWidth2 = "";
	campWidth3 = "";
	campWidth4 = "50%";
}
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>

<script language="javascript">
	
	function openModal(sURL, oArgs, iX, iY)
	{
		window.showModalDialog(sURL, oArgs, "dialogWidth:" + iX + "px;dialogHeight:" + iY + "px;help:0;status:0;scroll:0;center:1");
	}
	
</script>
</HEAD>
<BODY class="paging_body" onLoad="innerFramOnLoad();">
	
<table style="width: 100%">
	<tr>
		<td class="page_header">Campaign Lists</td>
	</tr>
</table>

<%
if (can.bWrite)
{
%>


<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
	<table cellspacing="0" cellpadding="0" width="100%" border="0">
		<tr>

	<% if (canPrint)	{ %>
		
		<td class="main_button" valign="center" align="left"><img width="10" src="../../images/blank.gif"/></td>
		<td class="main_button" valign="center" align="left"><img width="45" src="../../images/45_45_new.png" onmouseout="this.src='../../images/45_45_new.png'" onmouseover="this.src='../../images/45_45_newg.png'"><br/>Print Campaign</td>
		<td class="main_button" valign="center" align="left"><img width="10" src="../../images/blank.gif"/></td>
		
	<% }
		String sEditHref = "camp_edit.jsp?type_id=" + TYPE_ID;
		if(sSelectedCategoryId != null) sEditHref += ("&category_id=" + sSelectedCategoryId);
		if("1".equals(sAutoQueueDailyFlag)) sEditHref += "&auto_queue_daily_flag=1";
			
	%>
		<!-- STANDARD -->
		<td nowrap="true" valign="middle" align="left"><img width="10" src="../../images/blank.gif"/></td>
		<td nowrap="true" valign="center" align="left"><a href="/cms/ui/jsp/camp/camp_edit.jsp?type_id=2&category_id=0&media_type_id=1"><img border="0" width="45" src="../../images/45_45_new.png" onmouseout="this.src='../../images/45_45_new.png'" onmouseover="this.src='../../images/45_45_newg.png'"><br/>New Campaign</a></td>
		<td nowrap="true" valign="middle" align="left"><img width="10" src="../../images/blank.gif"/></td>
		
		<!-- TRIGGER -->
		<td valign="middle" nowrap align="left">
		<a href="/cms/ui/jsp/camp/camp_edit.jsp?type_id=4&media_type_id=1&&category_id=0"><img border="0" width="45" src="../../images/45_45_new.png" onmouseout="this.src='../../images/45_45_new.png'" onmouseover="this.src='../../images/45_45_newg.png'"><br/>Trigger Campaign</a></td>
		<td valign="middle" nowrap align="left"><img width="10" src="../../images/blank.gif"/></td>

		<!-- CHECK DAILY -->
		<td valign="middle" nowrap align="left">
		<a href="/cms/ui/jsp/camp/camp_edit.jsp?type_id=2&media_type_id=1&&auto_queue_daily_flag=1&category_id=0"><img border="0" width="45" src="../../images/45_45_new.png" onmouseout="this.src='../../images/45_45_new.png'" onmouseover="this.src='../../images/45_45_newg.png'"><br/>Daily Campaign</a></td>
		<td valign="middle" nowrap align="left"><img width="10" src="../../images/blank.gif"/></td>
		<td width="100%" align="right" valign="middle" nowrap="true"></td>

		</tr>	
	</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>
</div>

<%
}
%>
<br>
<FORM METHOD="GET" NAME="FT" ID="FT" ACTION="camp_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<INPUT TYPE="hidden" NAME="type_id" VALUE="">
	<INPUT TYPE="hidden" NAME="auto_queue_daily_flag" VALUE="<%=sAutoQueueDailyFlag%>">	
	<table align="right" cellspacing="0" cellpadding="5" border="0">
		<tr<%=(!canCat.bRead)?" style=\"display:none\"":""%>>
			<td valign="middle" align="right">Category:&nbsp;</td>
			<td valign="middle" align="left"><%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId, "") %></td>
			<td valign="middle" align="right">&nbsp;</td>

			<td valign="middle" align="right">&nbsp;Paging:&nbsp;</td>
			<td valign="middle" align="left">
				<SELECT NAME="amount" SIZE="1">
					<OPTION VALUE=1000>ALL</OPTION>
					<OPTION VALUE=10>10</OPTION>
					<OPTION VALUE=25>25</OPTION>
					<OPTION VALUE=50>50</OPTION>
					<OPTION VALUE=100>100</OPTION>
				</SELECT>
			</td>
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);">Filter</a></td>
		</tr>
	</table>
</FORM>
<br><br><br>


<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">


			<table align="center" class="list_table" width="99.5%" border="0" cellspacing="0" cellpadding="2">
				<tr>
					<th align="left" nowrap>All Campaigns</TH>
					<th align="left" nowrap> &nbsp;</TH>
					<th align="left" nowrap></TH>
					<th align="left" nowrap></th>
					<th align="left" nowrap></th>
					<th align="left" nowrap>Refresh</TH>
				</tr>			


				<tr>
					<th class="list_name" align="left" nowrap>Campaign Name</th>
					<th class="list_name" align="left" nowrap>Type</th>
					<% if (canPrint) { %><th class="list_name" align="left" nowrap>Media</th><% } %>
					<th class="list_name" align="left" nowrap>Target Group</th>
					<th class="list_name" align="left" nowrap>Content</th>
					<th class="list_name" align="left" nowrap>Status</th>
					<% if (canApprove.bExecute) { %><th class="list_name" align="center" nowrap>Action</th><% } %>
				</tr>									
<%
String s_origin_camp_id;
String s_camp_id;
String s_camp_name;
String s_status_id;
String s_status_name;
String s_type_id;
String s_type_id_name;
String s_filter_name;
String s_cont_name;
String s_created_date;
String s_modified_date;
String s_start_date;
String s_end_date;
String s_finish_date;
String d_created_date;
String d_modified_date;
String d_start_date;
String d_end_date;
String d_finish_date;
String s_qty_queued;
String s_qty_sent;
String s_approval_flag;
String s_queue_daily_flag;
String s_sample_qty;
String s_sample_qty_sent;
String s_final_flag;
String s_media_type_id;
String s_media_type_id_name;

int recAmount = 0;

int campCount = 0;

CampApproveDAO cDAO;
String sActiveCampId = null;
String sApproveRestart = null;
String sCancelConfirm = null;
 
// added as a part of delivery 6.0 , new button 'Set Done' is added
 String sSetDoneConfirm = null;
      
String sClassAppend = "";

// === === ===
	
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String sSql =
		"EXEC usp_cque_camp_list_get_all 1" +
		"," + cust.s_cust_id +
		"," + sSelectedCategoryId +
		"," + TYPE_ID;
		
	ResultSet rs = stmt.executeQuery(sSql);
	while( rs.next() )
	{
		if (campCount == 0)
		{
		%>

		<%
		}
		//START SELECTING
		if (campCount % 2 != 0) sClassAppend = "_other";
		else sClassAppend = "";
		
		campCount++;
		
		s_origin_camp_id	= rs.getString(1);
		s_camp_id			= rs.getString(2);
		s_camp_name			= new String(rs.getBytes(3), "UTF-8");
		s_status_id			= rs.getString(4);
		s_status_name		= rs.getString(5);
		s_type_id			= rs.getString(6);
		s_type_id_name		= rs.getString(7);
		s_filter_name		= new String(rs.getBytes(8), "UTF-8");
		s_cont_name			= new String(rs.getBytes(9), "UTF-8");
		d_created_date		= rs.getString(10);
		d_modified_date		= rs.getString(11);
		d_start_date		= rs.getString(12);
		d_end_date			= rs.getString(13);
		d_finish_date		= rs.getString(14);
		s_created_date		= rs.getString(15);
		s_modified_date		= rs.getString(16);
		s_start_date		= rs.getString(17);
		s_end_date			= rs.getString(18);
		s_finish_date		= rs.getString(19);
		s_qty_queued		= rs.getString(20);
		s_qty_sent			= rs.getString(21);
		s_approval_flag		= rs.getString(22);
		s_queue_daily_flag	= rs.getString(23);
		s_sample_qty		= rs.getString(24);
		s_sample_qty_sent	= rs.getString(25);
		s_final_flag		= rs.getString(26);
		s_media_type_id		= rs.getString(27);
		s_media_type_id_name= rs.getString(28);
		
		cDAO = new CampApproveDAO();
		sActiveCampId = cDAO.getActiveCamp(s_origin_camp_id,null);
			%>
				<tbody id="Id2" onclick="location.href='camp_edit.jsp?camp_id=<%= s_origin_camp_id %>&type_id=<%= TYPE_ID %>&media_type_id=<%= s_media_type_id %><%= (sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"" %>'" onmouseover="do_effect('navhover')" onmouseout="do_effect('navoff')">
				<tr>
					<td class="list_row<%= sClassAppend %>"><a href="camp_edit.jsp?camp_id=<%= s_origin_camp_id %>&type_id=<%= TYPE_ID %>&media_type_id=<%= s_media_type_id %><%= (sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"" %>" target"=_self"><%= s_camp_name %></a></td>
					<td class="list_row<%= sClassAppend %>" nowrap><%= s_type_id_name %></td>
					<% if (canPrint) { %><td class="listItem_Data<%= sClassAppend %>" nowrap><%= s_media_type_id_name %></td><% } %>
					<!--<td class="list_row<%= sClassAppend %>" nowrap><%= s_start_date %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_qty_queued %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_qty_sent %></td>-->
					<td class="list_row<%= sClassAppend %>"><%= s_filter_name %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_cont_name %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_status_name %></td>
		<%
		if (canApprove.bExecute)
		{
			/*set up appropriate messages depending on current status of campaign */
			if (Integer.parseInt(s_status_id) <= 50) //Campaign hasn't begun yet.
			{
				sApproveRestart = "Approve";
				sCancelConfirm = "You are cancelling a campaign that has not been sent to any recipients.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
				// added as a part of release 6.0, new button 'set done' is added
				sSetDoneConfirm =
					"You are setting campaign to Done status and has not been sent to any recipients. " + 
					"Continue with Set Done?";
			}
			else //Campaign is processing
			{
				sApproveRestart = "Restart";
				sCancelConfirm = "You are about to cancel this campaign.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
				// added as a part of release 6.0, new button 'set done' is added
				sSetDoneConfirm =
					"You are setting campaign to Done status and has not been sent to any recipients. " + 
					"Continue with Set Done?";
			}
		
			%>
					<td class="list_row<%= sClassAppend %>" nowrap style="padding:5px;">
			<%
			if (Integer.parseInt(s_status_id) >= 10 &&
				Integer.parseInt(s_status_id) < 60  &&
				Integer.parseInt(s_type_id) != CampaignType.TEST) // campaign is being queued or processed
			{
			%>
			<%	if ("Sample Set".equals(s_type_id_name)) { %>
						<A class="list" title="Actions for campaigns containing Sample Campaigns must be processed from the detail edit page." HREF="camp_edit.jsp?camp_id=<%= s_origin_camp_id %>&type_id=<%= TYPE_ID %><%= (sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"" %>" TARGET=_self>Sampleset</A></TD>
			<%	} else { 
					if (!(s_media_type_id.equals("2") && (Integer.parseInt(s_status_id) == CampaignStatus.BEING_PROCESSED))) {
						if (s_approval_flag != null && s_approval_flag.equals("1")) { %>
						<a class="deletebutton" href="camp_approve.jsp?camp_id=<%= s_camp_id %>&action=suspend">Suspend</a>
					<%	} else { %>
						<a class="newbutton" href="camp_approve.jsp?camp_id=<%= s_camp_id %>&action=approve"><%=sApproveRestart%></a>
					<%	} %>
						&nbsp;/&nbsp;
						<a class="deletebutton" href="#" onClick="if (confirm('<%=sCancelConfirm%>')) location.href='camp_approve.jsp?camp_id=<%= s_camp_id %>&action=cancel&cust_id=<%=cust.s_cust_id%>'">Cancel</a>
						<!-- added as a part of delivery 6.0 , new button 'Set Done' is added -->
						&nbsp;/&nbsp;
						<a class="deletebutton" href="#" onClick="if (confirm('<%=sSetDoneConfirm%>')) location.href='camp_approve.jsp?camp_id=<%= s_camp_id %>&action=setdone&cust_id=<%=cust.s_cust_id%>'">Set Done</a>
					<%
					} else {
						out.print("&nbsp;");
					}
				}
			}
			else // campaign is either Done or in Draft state; therefore, no Approval actions can take place
			{
				%>		
					-----
				<%
			}
			%>
					</td>
			<%
		}
		%>
				</tr>
			</tbody>
		<%
	}
	rs.close();		
	//END OF SELECT
	//BEGIN DRAF SELECT
		recAmount = 0;

	sSql =
		"EXEC usp_cque_camp_list_get_all 2" + 
		"," + cust.s_cust_id +
		"," + sSelectedCategoryId +
		"," + TYPE_ID;
		
	rs = stmt.executeQuery(sSql);

	campCount = 0;

	s_origin_camp_id	= null;
	s_camp_id			= null;
	s_camp_name			= null;
	s_status_id			= null;
	s_status_name		= null;
	s_type_id			= null;
	s_type_id_name		= null;
	s_filter_name		= null;
	s_cont_name			= null;
	d_created_date		= null;
	d_modified_date		= null;
	d_start_date		= null;
	d_end_date			= null;
	d_finish_date		= null;
	s_created_date		= null;
	s_modified_date		= null;
	s_start_date		= null;
	s_end_date			= null;
	s_finish_date		= null;
	s_qty_queued		= null;
	s_qty_sent			= null;
	s_approval_flag		= null;
	s_queue_daily_flag	= null;
	s_sample_qty		= null;
	s_sample_qty_sent	= null;
	s_final_flag		= null;
	s_media_type_id		= null;
	s_media_type_id_name= null;

           
	sClassAppend = "";

	while( rs.next() )
	{
		if (campCount % 2 != 0) sClassAppend = "_other";
		else	sClassAppend = "";

		campCount++;
		
		s_origin_camp_id	= rs.getString(1);
		s_camp_id			= rs.getString(2);
		s_camp_name			= new String(rs.getBytes(3), "UTF-8");
		s_status_id			= rs.getString(4);
		s_status_name		= rs.getString(5);
		s_type_id			= rs.getString(6);
		s_type_id_name		= rs.getString(7);
		s_filter_name		= new String(rs.getBytes(8), "UTF-8");
		s_cont_name			= new String(rs.getBytes(9), "UTF-8");
		d_created_date		= rs.getString(10);
		d_modified_date		= rs.getString(11);
		d_start_date		= rs.getString(12);
		d_end_date			= rs.getString(13);
		d_finish_date		= rs.getString(14);
		s_created_date		= rs.getString(15);
		s_modified_date		= rs.getString(16);
		s_start_date		= rs.getString(17);
		s_end_date			= rs.getString(18);
		s_finish_date		= rs.getString(19);
		s_qty_queued		= rs.getString(20);
		s_qty_sent			= rs.getString(21);
		s_approval_flag		= rs.getString(22);
		s_queue_daily_flag	= rs.getString(23);
		s_sample_qty		= rs.getString(24);
		s_sample_qty_sent	= rs.getString(25);
		s_final_flag		= rs.getString(26);
		s_media_type_id		= rs.getString(27);
		s_media_type_id_name= rs.getString(28);

		%>
				<tbody id="Id2" onclick="location.href='camp_edit.jsp?camp_id=<%= s_origin_camp_id %>&type_id=<%= TYPE_ID %>&media_type_id=<%= s_media_type_id %><%= (sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"" %>'" onmouseover="do_effect('navhover')" onmouseout="do_effect('navoff')">
				<tr>
					<td class="list_row<%= sClassAppend %>"><a href="camp_edit.jsp?camp_id=<%= s_origin_camp_id %>&type_id=<%= TYPE_ID %>&media_type_id=<%= s_media_type_id %><%= (sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"" %>" target"=_self"><%= s_camp_name %></a></td>
					<td class="list_row<%= sClassAppend %>" nowrap><%= s_type_id_name %></td>
					<% if (canPrint) { %><td class="listItem_Data<%= sClassAppend %>" nowrap><%= s_media_type_id_name %></td><% } %>
					<!--<td class="list_row<%= sClassAppend %>" nowrap><%= s_start_date %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_qty_queued %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_qty_sent %></td>-->
					<td class="list_row<%= sClassAppend %>"><%= s_filter_name %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_cont_name %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_status_name %></td>
					<td class="list_row<%= sClassAppend %>" nowrap style="padding:5px;">-----</td>
				</tr>
			</tbody>
<%
	}
	rs.close();
	//END DRAFT SELECT


%>
<!--
			</table>
			
			
			<table class="listTable" width="100%" cellspacing="0" cellpadding="2">
				<tr>
					<th align="left" nowrap>Campaign NAme</th>
					<th align="left" nowrap>Type</th>
					<% if (canPrint) { %><th align="left" nowrap>Media</th><% } %>
					<th align="left" nowrap>Target group</th>
					<th align="left" nowrap>Content</th>
					<th align="left" nowrap>Status</th>
					<th align="left" nowrap><%= sFinishLabel %></th>
					<!--<% if (canRept.bRead) { %><th align="left" nowrap>Reporting</th><% } %>
				</tr>
-->				
<%
	recAmount = 0;
	campCount = 0;

	s_origin_camp_id	= null;
	s_camp_id			= null;
	s_camp_name			= null;
	s_status_id			= null;
	s_status_name		= null;
	s_type_id			= null;
	s_type_id_name		= null;
	s_filter_name		= null;
	s_cont_name			= null;
	d_created_date		= null;
	d_modified_date		= null;
	d_start_date		= null;
	d_end_date			= null;
	d_finish_date		= null;
	s_created_date		= null;
	s_modified_date		= null;
	s_start_date		= null;
	s_end_date			= null;
	s_finish_date		= null;
	s_qty_queued		= null;
	s_qty_sent			= null;
	s_approval_flag		= null;
	s_queue_daily_flag	= null;
	s_sample_qty		= null;
	s_sample_qty_sent	= null;
	s_final_flag		= null;
	s_media_type_id		= null;
	s_media_type_id_name= null;


	sSql =
		"EXEC usp_cque_camp_list_get_all 3" + 
		"," + cust.s_cust_id +
		"," + sSelectedCategoryId +
		"," + TYPE_ID;

	rs = stmt.executeQuery(sSql);

	while( rs.next() )
	{
		if (campCount % 2 != 0) sClassAppend = "_Other";
		else sClassAppend = "";
		
		campCount++;
		
		s_origin_camp_id	= rs.getString(1);
		s_camp_id			= rs.getString(2);
		s_camp_name			= new String(rs.getBytes(3), "UTF-8");
		s_status_id			= rs.getString(4);
		s_status_name		= rs.getString(5);
		s_type_id			= rs.getString(6);
		s_type_id_name		= rs.getString(7);
		s_filter_name		= new String(rs.getBytes(8), "UTF-8");
		s_cont_name			= new String(rs.getBytes(9), "UTF-8");
		d_created_date		= rs.getString(10);
		d_modified_date		= rs.getString(11);
		d_start_date		= rs.getString(12);
		d_end_date			= rs.getString(13);
		d_finish_date		= rs.getString(14);
		s_created_date		= rs.getString(15);
		s_modified_date		= rs.getString(16);
		s_start_date		= rs.getString(17);
		s_end_date			= rs.getString(18);
		s_finish_date		= rs.getString(19);
		s_qty_queued		= rs.getString(20);
		s_qty_sent			= rs.getString(21);
		s_approval_flag		= rs.getString(22);
		s_queue_daily_flag	= rs.getString(23);
		s_sample_qty		= rs.getString(24);
		s_sample_qty_sent	= rs.getString(25);
		s_final_flag		= rs.getString(26);
		s_media_type_id		= rs.getString(27);
		s_media_type_id_name= rs.getString(28);

		//Page logic
		if ((campCount <= (curPage-1)*amount) || (campCount > curPage*amount)) continue;
%>		
				<tbody id="Id2" onclick="location.href='camp_edit.jsp?camp_id=<%= s_origin_camp_id %>&type_id=<%= TYPE_ID %>&media_type_id=<%= s_media_type_id %><%= (sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"" %>" onmouseover="do_effect('navhover')" onmouseout="do_effect('navoff')">
				<tr>
					<td class="list_row<%= sClassAppend %>"><a href="camp_edit.jsp?camp_id=<%= s_origin_camp_id %>&type_id=<%= TYPE_ID %>&media_type_id=<%= s_media_type_id %><%= (sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"" %>"><%= s_camp_name %></a></td>
					<td class="list_row<%= sClassAppend %>" nowrap><%= s_type_id_name %></td>
					<% if (canPrint) { %><td class="list_row<%= sClassAppend %>" nowrap><%= s_media_type_id_name %></td><% } %>
					<td class="list_row<%= sClassAppend %>"><%= s_filter_name %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_cont_name %></td>
					<td class="list_row<%= sClassAppend %>"><%= s_status_name %></td>
			<!--
				<%	if (canRept.bRead) { %>
					<td class="listItem_Data<%= sClassAppend %>">
				<% 		if ((Integer.parseInt(s_status_id) == 60) && (!"Sample Set".equals(s_type_id_name)) && (!"Dynamic".equals(s_type_id_name))) { %>
							<a href="../index.jsp?tab=Camp&sec=1&url=<%= URLEncoder.encode("report/report_object.jsp?act=VIEW&id=" + s_camp_id, "UTF-8") %>" target="_top">View Report</a>
				<% 		} else { %>
							&nbsp;
				<%		} %> 
					</td>
				<%	} %>
				-->
					<td class="list_row<%= sClassAppend %>" nowrap><%= (useEnd)?s_end_date:s_finish_date %></td>
				</tr>
			</tbody>
<%
	}
	rs.close();
	if (campCount == 0)
	{
%>
				<tr>
					<td class="list_row" colspan="<%= (canRept.bRead)?"7":"6" %>" align="left" valign="middle">There are no completed campaigns.</td>
				</tr>
<%	} %>
			</TABLE>
			

</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>
</div>
<SCRIPT>

<%@ include file="../../js/scripts.js" %>

function innerFramOnLoad()
{

	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");

	<% 	if( TYPE_ID != null) { %>
	FT.type_id.value = <%= TYPE_ID %>;
	<% } %>

	FT.curPage.value = <%= curPage %>;
	FT.amount.value = <%= amount %>;

	// === === ===

	<% if( curPage > 1) { %>
	prevPage.style.display = "";
	firstPage.style.display = "";
	<% } %>

	<% if( campCount > (curPage*amount) ) { %>
	nextPage.style.display = "";
	lastPage.style.display = "";
	<% } %>

	//camp_count.innerHTML = <%= campCount %>;

	var recCount = new Number("<%= campCount %>");
	var perPage = new Number(FT.amount.value);
	var thisPage = new Number(FT.curPage.value);
	var catName = FT.category_id[FT.category_id.selectedIndex].text;

	var pageCount = new Number(Math.ceil(recCount / perPage));

	if (pageCount == 0) pageCount = 1;
	FT.pageCount.value = pageCount;
	
	var startRec = ((thisPage - 1) * perPage) + 1;
	var endRec = ((thisPage - 1) * perPage) + perPage;

	if (endRec >= recCount) endRec = recCount;
	if (perPage == 1000) perPage = "ALL";

	if (thisPage == 1)
	{
		firstPage.style.display = "none";
		prevPage.style.display = "none";
	}

	if (thisPage >= pageCount)
	{
		lastPage.style.display = "none";
		nextPage.style.display = "none";
	}

	var finalMessage = "";

	if (recCount == 0) finalMessage = "0 records";
	else
	{
		finalMessage =
			"Page " + thisPage + " of " + pageCount +
			" (records " + startRec + " to " + endRec + " of " + recCount + " records)";
	}

	document.getElementById("cat_1").innerHTML = catName;
	document.getElementById("rec_1").innerHTML = perPage;
	document.getElementById("page_1").innerHTML = finalMessage;
}

function GO(parm)
{
	switch( parm )
	{
		case 0:
				FT.curPage.value = 1;
				break;
		case 1:
				FT.curPage.value = <%= curPage + 1 %>;
				break;
		case 2:
				break;
		case -1:
				FT.curPage.value = <%= curPage - 1 %>;
				break;
		case 99:
				FT.curPage.value = FT.pageCount.value;
				break;
	}
	FT.submit();
}

</SCRIPT>
</BODY>
<%

}
catch(Exception ex) { throw ex; }
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception ex) {}
	if (conn != null) cp.free(conn);
}


%>
