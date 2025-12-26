<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.w3c.dom.*,org.apache.log4j.*"
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

Customer cSuper = ui.getSuperiorCustomer();
Customer cActive = ui.getActiveCustomer();

boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

String sSysName = ui.getProp("sys_name");
%>
<html>
<head>
<title></title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<link rel="stylesheet" href="../../css/style2.css" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
<script language="JavaScript">
	
	function loadAdminNote(id)
	{
		var newWin;
        var url = "admin_note_get.jsp?note_id=" + id;
        var windowName = "admin_note_get";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
	function loadUserNote(id)
	{
		var newWin;
        var url = "user_note_get.jsp?note_id=" + id;
        var windowName = "user_note_get";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
</script>
</head>
<body topmargin="7" leftmargin="2" marginheight="2" marginwidth="0">
<br>
<DIV id=tsnazzy><B class=ttop><B class=tb1></B><B class=tb2></B><B 
class=tb3></B><B class=tb4></B></B>
	<div class="tip tboxcontent">
Welcome to <%= sSysName %><%= (!isHyatt)?(", "+user.s_user_name):"" %>
	</div>
	<B class=tbottom><B class=tb4></B><B 
class=tb3></B><B class=tb2></B><B class=tb1></B></B></DIV>

 
<%
ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("welcome.jsp");
	stmt = conn.createStatement();

	String sClassAppend = "";
	String sSql = "";
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;
	if (sSelectedCategoryId == null) sSelectedCategoryId = "0";
	
	String	campaignType			= "Error";

	int		curPage					= 1;
	int		amount					= 5;
	
	int		hasSeenAdminNote		= 0;

	int		hasUserNotesAccess		= 0;
	int		hasAdminNotesAccess		= 1;
	
	String	sNoteId					= null;
	String	sParentId				= cSuper.s_cust_id;
	String	sNoteCustId				= cSuper.s_cust_id;
	Customer cNote 					= null;
	
	sSql = "EXEC usp_ccps_cust_parent_chain_get @cust_id = " + cSuper.s_cust_id;
	rs = stmt.executeQuery(sSql);

	while (rs.next())
	{
		sParentId = rs.getString(1);
	}
	rs.close();
	
	%>
<table cellpadding="5" cellspacing="0" border="0" class="layout" style="width:700px;">
	<col width="60%">
	<col width="40%">
	<tr>
		<td align="left" valign="top">
		<%
		String sRequest = new String("<request><note_id></note_id></request>");
		String sResponse = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest);      
		Element eRoot = XmlUtil.getRootElement(sResponse);        
		if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
		{
			sNoteId = XmlUtil.getChildTextValue(eRoot, "note_id");			
			%>
			<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent" style="padding: 3px;">
			<iframe src="system_note_info_get.jsp?win=false&note_id=<%= sNoteId %>" name=systemnotebox width="100%" height="145" scrolling="no" frameborder="0">
			[Your user agent does not support frames or is currently configured]
			</iframe></div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>			
</div>
			<br><br>
			<%
			sNoteId = null;
		}
		else
		{
			if (hasAdminNotesAccess == 1)
			{
				sSql = "SELECT TOP 1 note_id, cust_id FROM chom_user_note WHERE (cust_id = '" + sParentId + "' OR cust_id = '" + cSuper.s_cust_id + "') AND admin=1 AND published = 1 ORDER BY cust_id, modify_date DESC";
				rs = stmt.executeQuery(sSql);

				if (rs.next())
				{
					sNoteId = rs.getString(1);
					sNoteCustId = rs.getString(2);
				}
				rs.close();
				
				if (sNoteId != null)
				{
					hasSeenAdminNote = 1;
					cNote = new Customer(sNoteCustId);
					%>
		
					
					<table cellspacing="0" cellpadding="0" width="100%" border="0">
						<tr>
							<td class="listHeading" valign="center" nowrap align="left">
								<%= cNote.s_cust_name %> Announcement
								<br><br>
								<iframe src="admin_note_get.jsp?note_id=<%= sNoteId %>&win=false" name=usernotebox width="100%" height="145" scrolling="no" frameborder="0">
								[Your user agent does not support frames or is currently configured]
								</iframe>
							</td>
						</tr>
					</table>
					
					<br><br>
					<%
				}
			}
		}
		
		AccessPermission canNote = user.getAccessPermission(ObjectType.USER_NOTES);
		
		AccessPermission canCamp = user.getAccessPermission(ObjectType.CAMPAIGN);
		AccessPermission canRept = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
		AccessPermission canCont = user.getAccessPermission(ObjectType.CONTENT);
		
		String campClass = "EditTabOn";
		String reptClass = "EditTabOff";
		String contClass = "EditTabOff";
		
		int hasAssetAccess = 1;
		int showCamp = 0;
		int showRept = 0;
		int showCont = 0;
		
		if (canCamp.bRead)
		{
			campClass = "EditTabOn";
			reptClass = "EditTabOff";
			contClass = "EditTabOff";
			showCamp = 1;
		}
		else if (canRept.bRead)
		{
			campClass = "EditTabOff";
			reptClass = "EditTabOn";
			contClass = "EditTabOff";
			showRept = 1;
		}
		else if (canCont.bRead)
		{
			campClass = "EditTabOff";
			reptClass = "EditTabOff";
			contClass = "EditTabOn";
			showCont = 1;
		}
		else
		{
			hasAssetAccess = 0;
			campClass = "EditTabOff";
			reptClass = "EditTabOff";
			contClass = "EditTabOff";
		}
		
		if (hasAssetAccess == 1)
		{
			%>
			<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent" style="padding: 3px;">
			<table cellspacing="0" cellpadding="0" width="95%" border="0">
				<tr>
					<td class="listHeading" valign="center" nowrap align="left">
						Recent Assets
						<br><br>
						<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
							<tr>
								<% if (canCamp.bRead) { %><td class=<%= campClass %> id=tab1_Step1 width=100 onclick="toggleTabs('tab1_Step','block1_Step',1,3,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Campaigns</td><% } %>
								<% if (canRept.bRead) { %><td class=<%= reptClass %> id=tab1_Step2 width=100 onclick="toggleTabs('tab1_Step','block1_Step',2,3,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Reports</td><% } %>
								<% if (canCont.bRead) { %><td class=<%= contClass %> id=tab1_Step3 width=100 onclick="toggleTabs('tab1_Step','block1_Step',3,3,'EditTabOn','EditTabOff');" valign=center nowrap align=middle>Content</td><% } %>
								<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
							</tr>
							<tr>
								<td class=fillTabbuffer valign=top align=left width=100% colspan=4><img height=2 src="../../images/blank.gif" width=1></td>
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
						String s_finish_date;
						String d_created_date;
						String d_modified_date;
						String d_start_date;
						String d_finish_date;
						String s_qty_queued;
						String s_qty_sent;
						String s_approval_flag;
						String s_queue_daily_flag;
						String s_sample_qty;
						String s_sample_qty_sent;
						String s_final_flag;

						if(canCamp.bRead)
						{
							%>
							<tbody class=EditBlock id=block1_Step1<%= (showCamp==0)?" style=\"display:none;\"":"" %>>
							<tr>
								<td class=fillTab valign=top align=left colspan=4>
									&nbsp;&nbsp;&nbsp;<a target="_top" class="resourcebutton" href="../index.jsp?tab=Camp&sec=1" title="View All Campaigns">All Campaigns</a>&nbsp;&nbsp;&nbsp;
									<br><br>
									<%
										int recAmount = 0;

										sSql = "EXEC usp_cque_camp_list_get_all 4" + 
											"," + cust.s_cust_id +
											"," + sSelectedCategoryId +
											",2";
											
										rs = stmt.executeQuery(sSql);
										
										int campCount = 0;

										while( rs.next() )
										{
											if (campCount == 0)
											{
												%>
									<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
										<tr>
											<th class="subsectionheader" valign="middle" width="50%">Campaigns</th>
											<th class="subsectionheader" valign="middle" width="25%">Status</th>
											<th class="subsectionheader" valign="middle" width="25%">Type</th>
										</tr>
												<%
											}
											
											if (campCount % 2 != 0) sClassAppend = "_Alt";
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
											d_finish_date		= rs.getString(13);
											s_created_date		= rs.getString(14);
											s_modified_date		= rs.getString(15);
											s_start_date		= rs.getString(16);
											s_finish_date		= rs.getString(17);
											s_qty_queued		= rs.getString(18);
											s_qty_sent			= rs.getString(19);
											s_approval_flag		= rs.getString(20);
											s_queue_daily_flag	= rs.getString(21);
											s_sample_qty		= rs.getString(22);
											s_sample_qty_sent	= rs.getString(23);
											s_final_flag		= rs.getString(24);
											%>
										<tr>
											<td class="listItem_Data<%= sClassAppend %>"><a target="_top" href="../index.jsp?tab=Camp&sec=1&url=<%= URLEncoder.encode("camp/camp_edit.jsp?camp_id=" + s_origin_camp_id + "&type_id=2","UTF-8") %>" target"=_self"><%= s_camp_name %></a></td>
											<td class="listItem_Title<%= sClassAppend %>"><%= s_status_name %></td>
											<td class="listItem_Data<%= sClassAppend %>">(<%= s_type_id_name %>)</td>
										</tr>
											<%
										}
										rs.close();
											
										if (campCount == 0)
										{
											%>
									<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
										<tr>
											<th class="subsectionheader" valign="middle" width="50%">Campaigns</th>
											<th class="subsectionheader" valign="middle" width="25%">Status</th>
											<th class="subsectionheader" valign="middle" width="25%">Type</th>
										</tr>
											<%
										}
											recAmount = 0;

											sSql =
												"EXEC usp_cque_camp_list_get_all 5" + 
												"," + cust.s_cust_id +
												"," + sSelectedCategoryId +
												",2";
											rs = stmt.executeQuery(sSql);

											//campCount = 0;

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
											d_finish_date		= null;
											s_created_date		= null;
											s_modified_date		= null;
											s_start_date		= null;
											s_finish_date		= null;
											s_qty_queued		= null;
											s_qty_sent			= null;
											s_approval_flag		= null;
											s_queue_daily_flag	= null;
											s_sample_qty		= null;
											s_sample_qty_sent	= null;
											s_final_flag		= null;
												    
											sClassAppend = "";

											while( rs.next() )
											{
												if (campCount % 2 != 0) sClassAppend = "_Alt";
												else sClassAppend = "";
												
												campCount++;
												recAmount++;
												
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
												d_finish_date		= rs.getString(13);
												s_created_date		= rs.getString(14);
												s_modified_date		= rs.getString(15);
												s_start_date		= rs.getString(16);
												s_finish_date		= rs.getString(17);
												s_qty_queued		= rs.getString(18);
												s_qty_sent			= rs.getString(19);
												s_approval_flag		= rs.getString(20);
												s_queue_daily_flag	= rs.getString(21);
												s_sample_qty		= rs.getString(22);
												s_sample_qty_sent	= rs.getString(23);
												s_final_flag		= rs.getString(24);

												//Page logic
												if ((recAmount <= (curPage-1)*amount) || (recAmount > curPage*amount)) continue;
												%>
											<tr>
												<td class="listItem_Data<%= sClassAppend %>"><a target="_top" href="../index.jsp?tab=Camp&sec=1&url=<%= URLEncoder.encode("camp/camp_edit.jsp?camp_id=" + s_origin_camp_id + "&type_id=2","UTF-8")%>" target"=_self"><%= s_camp_name %></a></td>
												<td class="listItem_Title<%= sClassAppend %>"><%= s_status_name %></td>
												<td class="listItem_Data<%= sClassAppend %>">(<%= s_type_id_name %>)</td>
											</tr>
												<%
											}
											rs.close();
											%>
										<% if (campCount == 0) { %>
											<tr>
												<td class="listItem_Title" colspan="3" align="left" valign="middle">There are currently no draft campaigns being worked on</td>
											</tr>
										<% } %>
									</table>
								</td>
							</tr>
							</tbody>
							<%
						}
						
						if(canRept.bRead)
						{
							%>
							<tbody class=EditBlock id=block1_Step2<%= (showRept==0)?" style=\"display:none;\"":"" %>>
							<tr>
								<td class=fillTab valign=top align=left colspan=4>
									&nbsp;&nbsp;&nbsp;<a target="_top" class="resourcebutton" href="../index.jsp?tab=Rept&sec=1">All Reports</a>&nbsp;&nbsp;&nbsp;
									<br><br>
									<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
										<tr>
											<th class="subsectionheader" valign="middle" width="75%">Reports</th>
											<th class="subsectionheader" valign="middle" width="25%">Status</th>
										</tr>
							<%
							sSql = "EXEC usp_crpt_camp_list @cust_id=" + cust.s_cust_id + "";

							if (sSelectedCategoryId!=null)
								sSql +=",@category_id=" + sSelectedCategoryId;
							
							int reportCount = 0;

							if (stmt.execute(sSql))
							{
								rs = stmt.getResultSet();
								while (rs.next())
								{
									//if (rs.getString(11).equals("Complete"))
									//{
										if (reportCount % 2 != 0)
										{
											sClassAppend = "_Alt";
										}
										else
										{
											sClassAppend = "";
										}
										
										++reportCount;
										if ((reportCount <= (curPage-1)*amount) || (reportCount > curPage*amount)) continue;
										%>
										<tr>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><a target="_top" href="../index.jsp?tab=Rept&sec=1&url=<%= URLEncoder.encode("report/report_redirect.jsp?act=VIEW&id=" + rs.getString("Id"),"UTF-8") %>"><%= new String(rs.getBytes("CampName"), "UTF-8") %></a></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><%= rs.getString("UpdateStatus") %></td>
										</tr>
										<%
									//}
								}
								rs.close();
							}
							
							if (reportCount == 0)
							{
								%>
										<tr>
											<td class="listItem_Title" colspan="3" align="left" valign="middle">There are currently no Reports</td>
										</tr>
								<%
							}
							%>
									</table>
								</td>
							</tr>
							</tbody>
							<%
						}
						
						if(canCont.bRead)
						{
							%>
							<tbody class=EditBlock id=block1_Step3<%= (showCont==0)?" style=\"display:none;\"":"" %>>
							<tr>
								<td class=fillTab valign=top align=left colspan=4>
									&nbsp;&nbsp;&nbsp;<a target="_top" class="resourcebutton" href="../index.jsp?tab=Cont&sec=1" title="View All Content">All Content</a>&nbsp;&nbsp;&nbsp;
									<br><br>
									<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
										<tr>
											<th class="subsectionheader" valign="middle" width="75%">Content</th>
											<th class="subsectionheader" valign="middle" width="25%">Modified Date</th>
										</tr>
									<%
									int contCount = 0;
									
									sSql = "Exec dbo.usp_ccnt_list_get @type_id="+ContType.CONTENT+", @CustomerId="+cust.s_cust_id;
									if (sSelectedCategoryId != null) sSql += ",@category_id="+sSelectedCategoryId;
									
									rs = stmt.executeQuery(sSql);

									String contID = "";
									
									while (rs.next())
									{
										if (contCount % 2 != 0)
										{
											sClassAppend = "_Alt";
										}
										else
										{
											sClassAppend = "";
										}
										
										++contCount;

										//Top 5 logic
										if (contCount <= (curPage-1)*amount) continue;
										else if (contCount > curPage*amount) continue;
										
										contID = rs.getString(1);
										%>
										<tr>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><a target="_top" href="../index.jsp?tab=Cont&sec=1&url=<%= URLEncoder.encode("cont/cont_edit.jsp?cont_id=" + contID,"UTF-8") %>"><%= new String(rs.getBytes(2),"UTF-8") %></a></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" nowrap><%= rs.getString(5) %></td>
										</tr>
										<%
									}
									rs.close();
									
									if (contCount == 0)
									{
										%>
										<tr>
											<td class="listItem_Title" colspan="2" align="left" valign="middle">There is currently no Content</td>
										</tr>
										<%
									}
									%>
									</table>
								</td>
							</tr>
							</tbody>
							<%
						}
						%>
						</table>
					</td>
				</tr>
			</table>
			</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>			
</div>
			<%
		}
		%>
		</td>
		<td align="left" valign="top">
			<%
			if(hasAdminNotesAccess == 1)
			{
				if (hasSeenAdminNote == 0)
				{
					sNoteId = null;
					sSql = "SELECT TOP 1 note_id, cust_id FROM chom_user_note WHERE (cust_id = '" + sParentId + "' OR cust_id = '" + cSuper.s_cust_id + "') AND admin=1 AND published = 1 ORDER BY cust_id, modify_date DESC";
					rs = stmt.executeQuery(sSql);

					if (rs.next())
					{
						sNoteId = rs.getString(1);
						sNoteCustId = rs.getString(2);
					}
					rs.close();
					
					if (sNoteId != null)
					{
						cNote = new Customer(sNoteCustId);
						%>
						<table cellspacing="0" cellpadding="0" width="100%" border="0">
							<tr>
								<td class="listHeading" valign="center" nowrap align="left">
									<%= cNote.s_cust_name %> Announcement
									<br><br>
									<iframe src="admin_note_get.jsp?note_id=<%= sNoteId %>&win=false" name=usernotebox width="100%" height="225" scrolling="no" frameborder="0">
									[Your user agent does not support frames or is currently configured]
									</iframe>
								</td>
							</tr>
						</table>
						<br><br>
						<%
					}
				}
				%>
			<!--<table cellspacing="0" cellpadding="0" width="100%" border="0">
				<tr>
					<td class="listHeading" valign="center" nowrap align="left">
						Recent Admin Notes
						<br><br>
						<table cellspacing="0" cellpadding="0" width="100%" border="0">
							<tr>
								<td>
									<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
										<tr>
											<th class="subsectionheader" align="left" valign="middle" width="50%">Subject</th>
											<th class="subsectionheader" align="left" valign="middle" width="25%" nowrap>User</th>
											<th class="subsectionheader" align="left" valign="middle" width="25%" nowrap>Modified Date</th>
										</tr>
				<%
				if (sNoteId == null)
				{
					sNoteId = "-999"; 
				}
				
				sSql = "EXEC usp_chom_user_note_list_get_published @cust_id=" + cust.s_cust_id + ",@admin=1,@exclude_id="+ sNoteId;
				
				int iCount = 0;
				rs = stmt.executeQuery(sSql);
				
				String sId = "";
				String sSubj = "";
				String sUserID = "";
				String sUser = "";
				String dDate = "";
				String sDate = "";

				while (rs.next())
				{
					
					if (iCount % 2 != 0) sClassAppend = "_Alt";
					else sClassAppend = "";
					
					++iCount;

					sId = rs.getString(1);
					sSubj = rs.getString(2);
					sUserID = rs.getString(3);
					sUser = rs.getString(4);
					dDate = rs.getString(5);
					sDate = rs.getString(6);
					
					if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
					%>
										<tr>
											<td class="listItem_Title<%= sClassAppend %>" align="left" valign="middle" width="50%"><a href="javascript:loadAdminNote('<%= sId %>');"><%= sSubj %></a></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="25%" nowrap><%= sUser %></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="25%" nowrap><%= sDate %></td>
										</tr>
					<%
				}
				rs.close();
				
				if (iCount == 0)
				{
					%>
										<tr>
											<td class="listItem_Data" colspan="3">There are currently no Admin Notes</td>
										</tr>
					<%
				}
				%>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<br>//-->
				<%
			}
			
			if (canNote.bRead)
			{
				hasUserNotesAccess = 1;            
				%>
				<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent" style="padding: 3px;">
			<table cellspacing="0" cellpadding="0" width="95%" border="0" > 
				<tr>
					<td class="listHeading" valign="center" nowrap align="left">
						Recent User Notes
						<br><br>
						<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
							<tr>
								<th class="subsectionheader" align="left" valign="middle" width="50%">Subject</th>
								<th class="subsectionheader" align="left" valign="middle" width="25%" nowrap>User</th>
								<th class="subsectionheader" align="left" valign="middle" width="25%" nowrap>Modified Date</th>
							</tr>
					<%
					
					sSql = "EXEC usp_chom_user_note_list_get_published @cust_id=" + cust.s_cust_id + ",@admin=0,@exclude_id="+ sNoteId;
					
					int iCount = 0;
					rs = stmt.executeQuery(sSql);
					
					String sId = "";
					String sSubj = "";
					String sUserID = "";
					String sUser = "";
					String dDate = "";
					String sDate = "";

					while (rs.next())
					{
						
						if (iCount % 2 != 0) sClassAppend = "_Alt";
						else sClassAppend = "";
						
						++iCount;

						sId = rs.getString(1);
						sSubj = rs.getString(2);
						sUserID = rs.getString(3);
						sUser = rs.getString(4);
						dDate = rs.getString(5);
						sDate = rs.getString(6);
						
						if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
						%>
							<tr>
								<td class="listItem_Title<%= sClassAppend %>" align="left" valign="middle" width="50%"><a href="javascript:loadUserNote('<%= sId %>');"><%= sSubj %></a></td>
								<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="25%" nowrap><%= sUser %></td>
								<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="25%" nowrap><%= sDate %></td>
							</tr>
						<%
					}
					rs.close();
					
					if (iCount == 0)
					{
						%>
							<tr>
								<td class="listItem_Data" colspan="3" align="left" valign="middle">There are currently no User Notes</td>
							</tr>
						<%
					}
					%>
						</table>
					</td>
				</tr>
			</table>
			</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>			
</div>
<br>
<% 
	if(user.s_user_name.equals("Tech") && user.s_last_name.equals("Support"))
	{
	%>
		<a href="https://cms.revotas.com/cms/ui/jsp/bill/bill_form.jsp" style="display:block;background:url(https://cms.revotas.com/cms/ui/ooo/images/newbilling.png);background-repeat:no-repeat;width:236px;height:65px;"><span style="color: white;display: block;font-size: 11px;font-weight: bold;margin-left: 12px;margin-top: 15px;">Campaign Delivery Summary</span></a>
	<%		
	} else {
	%>
		<a href="https://login.revotas.com/cms/ui/jsp/bill/bill_form.jsp" style="display:block;background:url(https://cms.revotas.com/cms/ui/ooo/images/newbilling.png);background-repeat:no-repeat;width:236px;height:65px;"><span style="color: white;display: block;font-size: 11px;font-weight: bold;margin-left: 12px;margin-top: 15px;">Campaign Delivery Summary</span></a>
	<%
}
 %>
			
			
				<%
			}
			%>
		</td>
	</tr>
</table>
<%
}
catch(Exception ex)
{ 
	//ErrLog.put(this,ex,"welcome.jsp",out,1);
	throw new Exception(ex);
}
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception e) {}
	if (conn != null) cp.free(conn);
}
%>
</body>
</html>
