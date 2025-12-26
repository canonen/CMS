<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.upd.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);
AccessPermission canFilter = user.getAccessPermission(ObjectType.FILTER);

boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id,ObjectType.IMPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

boolean bCanWrite = can.bWrite;
boolean bCanExecute = can.bExecute;
boolean bCanFilter = canFilter.bWrite;

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

// === === ===

String sImportID = request.getParameter("import_id");

// === === ===

Import imp = new Import(sImportID);
Batch batch = new Batch(imp.s_batch_id);

// There was no this check before. It should be.
// But it is commented because referenced from one of admin pages
// and right now there is no time to fix it.
// if(!cust.s_cust_id.equals(batch.s_cust_id)) return; // customer does not match

// === === ===

int nUpdRuleId = Integer.parseInt(imp.s_upd_rule_id);
int nStatusID = Integer.parseInt(imp.s_status_id);

int nFullNameFlag = 1;
int nEmailTypeFlag = 1;

if(imp.s_full_name_flag != null) nFullNameFlag = Integer.parseInt(imp.s_full_name_flag);
if(imp.s_email_type_flag != null) nEmailTypeFlag = Integer.parseInt(imp.s_email_type_flag);

// === === ===

ImportStatistics imp_stats = new ImportStatistics(sImportID);

// === === ===

String sStatusName = null;
String sNewsletters = "";

// === === ===

ConnectionPool	cp = null;
Connection		conn = null;
Statement		stmt = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	// === === ===

	String sSql = 
		" SELECT isnull(s.display_name, s.status_name)" +
		" FROM cupd_import_status s " +
		" WHERE s.status_id = " + imp.s_status_id ;
	
	ResultSet rs = stmt.executeQuery(sSql);
	if(rs.next()) sStatusName = rs.getString(1);
	rs.close();

	// === === ===

	rs = stmt.executeQuery ("SELECT ISNULL(c.display_name, a.attr_name)" 
			+ " FROM cupd_import_newsletter n, ccps_cust_attr c, ccps_attribute a"
			+ " WHERE n.attr_id = c.attr_id"
			+ " AND c.attr_id = a.attr_id"
			+ " AND c.cust_id = " + cust.s_cust_id
			+ " AND n.import_id = " + sImportID );

	while(rs.next())
	{
		byte b [] = rs.getBytes(1);
		sNewsletters += (b!=null)?(((sNewsletters.length()>0)?", ":"")+(new String(b, "UTF-8"))):"";
	}
	rs.close();
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"Problem viewing Import Details",out,1);
}
finally
{
	if ( stmt != null ) stmt.close();
	if ( conn != null ) cp.free(conn); 
}

// === === ===

String sUpdRuleId = null;
switch (nUpdRuleId)
{
	case UpdateRule.DISCARD_DUPLICATES : sUpdRuleId = "Insert only new recipients discarding duplicates from import."; break;
	case UpdateRule.INSERT_ONLY_NEW_FIELDS : sUpdRuleId = "Insert only new fields not overwriting existing recipient data."; break;
	case UpdateRule.OVERWRITE_IGNORE_BLANKS : sUpdRuleId = "Update duplicates ignoring blank import fields."; break;
	case UpdateRule.OVERWRITE_WITH_BLANKS : sUpdRuleId = "Update duplicates including blank import fields."; break;
	default : sUpdRuleId = "";
}

// === === ===
	
boolean isApprover = false;
ApprovalRequest arRequest = null;
String sAprvlRequestId = request.getParameter("aprvl_request_id");
if (sAprvlRequestId == null) sAprvlRequestId = "";
if (sAprvlRequestId != null && !sAprvlRequestId.equals(""))
{
	arRequest = new ApprovalRequest(sAprvlRequestId);
}
else
{
	arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.IMPORT),sImportID);
}
 
if (arRequest != null && arRequest.s_approver_id != null && 
 		arRequest.s_approver_id.equals(user.s_user_id))
{
	sAprvlRequestId = arRequest.s_approval_request_id;
	isApprover = true;
}
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT>

	function a() { return confirm("Are you sure?"); }
	
	function PreviewURL(freshurl)
	{
		var window_features = 'toolbar=0,location=0,menubar=0,status=1,scrollbars=1,resizable=1,height=500,width=600';
		SmallWin = window.open(freshurl,'ImportWin',window_features);
	}
	
	function RequestApproval()
	{
		FT.action="../workflow/approval_request_edit.jsp?object_type=" + <%=ObjectType.IMPORT%>+ "&object_id=" + <%=sImportID%>;
		FT.submit();
	}

	function workflow_approve()
	{
		FT.action = "../workflow/approval_send.jsp"
		FT.disposition_id.value = "10"	// approve
		FT.submit()
	}

	function workflow_reject()
	{
		FT.action = "../workflow/approval_edit.jsp"
		FT.disposition_id.value = "90"	// reject
		FT.submit()
	}

	function workflow_approve_w_comments()
	{
		FT.action = "../workflow/approval_edit.jsp"
		FT.disposition_id.value = "10"	// approve
		FT.submit()
	}

</SCRIPT>

</HEAD>

<BODY>
<BR>
<!--
<div id="container">
<div class="gradient2"><p>Ieii euu ioi ou</p>
	<table class="table_cell_nifty" border="0" width="100%" id="table1">
		<tr>
			<td>&nbsp;asdadadadasdadsa
			<br><br><br></td>
		</tr>
	</table>
</div>

</div>
-->

<table cellspacing="0" cellpadding="4" border="0">
	<tr>
<%
if (bCanWrite)
{
	if( nStatusID == ImportStatus.PENDING_APPROVAL) //7
	{	 
		if (bWorkflow && can.bApprove && isApprover)
		{
%>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="workflow_approve()">Approve</a>
		</td>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="workflow_approve_w_comments()">Approve w/ Comments</a>
		</td>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="workflow_reject()">Reject</a>
		</td>
<%
		}
	} 
	if( nStatusID == 30)//ImportStatus.IN_STAGING
	{
		if (!bWorkflow || 
				(bWorkflow && can.bApprove && WorkflowUtil.isImportPending(sImportID)) ||
				(bWorkflow && WorkflowUtil.getImportDisposition(sImportID) == ApprovalDisposition.APPROVE))
		{
%>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onclick="if(a()) location.href='import_action.jsp?import_id=<%=sImportID%>&mode=commit<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>'">Commit</a>&nbsp;
		</td>
<%
		}
	
		if (!bWorkflow || 
			 (bWorkflow && can.bApprove && canFilter.bApprove && WorkflowUtil.isImportPending(sImportID)) ||
			 (bWorkflow && WorkflowUtil.getImportDisposition(sImportID) == ApprovalDisposition.APPROVE))
		{
%>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onClick="if(a()) location.href='import_action.jsp?import_id=<%=sImportID%>&mode=commit&filter=1<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>'">Commit &amp; Create Target Group</a>&nbsp;
		</td>
<%
		}
		if (bWorkflow && !can.bApprove && WorkflowUtil.isImportPending(sImportID))
		{
%>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onClick="RequestApproval()">Request Approval</a>&nbsp;
		</td>
<%
		}
%>
		<td align="left" valign="middle">
			<a class="newbutton" href="#" onClick="if(a()) location.href='import_action.jsp?import_id=<%=sImportID%>&mode=rollback<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>'">RollBack</a>&nbsp;
		</td>
<%
	}
	else if (nStatusID >= 50)
	{
	//ImportStatus.COMMIT_COMPLETE
%>
	<td align="left" valign="middle">
		<a class="newbutton" href="#" onClick="if(a()) location.href='import_action.jsp?import_id=<%=sImportID%>&mode=delete<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>'">Delete</a>
		&nbsp; The button will delete only the current import, not the recipients that belong to it.
	</td>
<%
	}
	else if (nStatusID == 7)
	{	
	//ImportStatus.PENDING_APPROVAL
%>
	<td align="left" valign="middle">
		<a class="resourcebutton" href="import_details.jsp?import_id=<%=sImportID%>">Refresh Status >></a>
	</td>
	<td align="left" valign="middle">
		<FONT COLOR="RED">This import is pending approval.  Please check with the approver for further information.</FONT>
	</td>
<%	
	}
	else
	{	
%>
	<td align="left" valign="middle">
		<a class="resourcebutton" href="import_details.jsp?import_id=<%=sImportID%>">Refresh Status >></a>
	</td>
	<td align="left" valign="middle">
		<FONT COLOR="RED">You are not allowed to delete this import, because it is in work by server just now.</FONT>
	</td>
<%	
	}
}
%>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>

	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width=650 colspan=3>
			<table class=listTable  cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th align="center" style="text-align:center">
						<span>Status:<%=" " + sStatusName%></span>
					</th>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>

<FORM  METHOD="POST" NAME="FT" ACTION="" TARGET="_self">

<input type="hidden" name="disposition_id" value="0"/>
<input type="hidden" name="object_type" value="<%=String.valueOf(ObjectType.IMPORT)%>"/>
<input type="hidden" name="object_id" value="<%=(sImportID != null)?sImportID:"0"%>"/>
<INPUT TYPE="hidden" NAME="aprvl_request_id"	value="<%=sAprvlRequestId%>">

<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td valign=top align=center width=650 colspan=3>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<td class="  heads" width="200">Import name : </td>
					<td class=" " width="475"><%= HtmlUtil.escape(imp.s_import_name) %></td>
				</tr>
				<tr>
					<td class="  heads" width="200">Batch : </td>
					<td class=" " width="475"><%= HtmlUtil.escape(batch.s_batch_name) %></td>
				</tr>
				<tr>
					<td class="  heads" width="200">Data begins on : </td>
					<td class=" " width="475"><%= (imp.s_first_row.equals("1"))?"1st":"2nd" %> row</td>
				</tr>
				<tr>
					<td class="  heads" width="200">Delimiter : </td>
					<td class=" " width="475">
<% if (imp.s_field_separator.equals("|")) { %>Pipe (|)
<% } else if (imp.s_field_separator.equals(";")) { %>Semi-Colon (;)
<% } else if (imp.s_field_separator.equals(",")) { %>Comma (,)
<% } else { %>Tab (\t) <% } %>
					</td>
				</tr>
<%	if ((imp.s_multi_value_field_separator != null) && (imp.s_multi_value_field_separator.length() > 0)){ %>			
				<tr>
					<td class="  heads" width="200">Multi-Value Field Delimiter</td>
					<td class=" " width="475">
<% if (imp.s_multi_value_field_separator.equals("|")) { %>Pipe (|)
<% } else if (imp.s_multi_value_field_separator.equals(";")) { %>Semi-Colon (;)
<% } else if (imp.s_multi_value_field_separator.equals(",")) { %>Comma (,)
<% } else { %>Tab (\t) <% } %>
					</td>
				</tr>
<%	} %>
<%	if (!bStandardUI) { %>
				<tr>
					<td class="  heads" width="200">Import Rule : </td>
					<td class=" " width="475"><%= sUpdRuleId %></td>
				</tr>
				<tr>
					<td class="  heads" width="200">Full Name Processing : </td>
					<td class=" " width="475">Recipient full name was <%=(nFullNameFlag == 0)?"not":""%> calculated.</td>
				</tr>
<%	} %>
				<!--<tr><td class="  heads" width="200">Email Type Processing : </td><td width="425">Recipient email type and confidence was <%=(nEmailTypeFlag==0)?"not":""%> calculated for duplicates.</td></tr>-->
<%	if (sNewsletters.length() > 0) { %>
				<tr>
					<td class="  heads" width="200">Newsletters : </td>
					<td class=" " width="475"><%= sNewsletters %></td>
				</tr>
<%	} %>

				<tr>
					<td class="  heads" width="200">Total records in import file : </td>
					<td class=" " width="475"><%=(imp_stats.s_tot_rows!=null)?imp_stats.s_tot_rows:"N/A"%></td>
				</tr>
				<tr>
					<td class="  heads" width="200">Bad Rows in Import File : </td>
					<td class=" " width="475"><FONT COLOR="RED"><%=(imp_stats.s_bad_rows!=null)?imp_stats.s_bad_rows:"N/A"%></FONT></td>
				</tr>
				<tr>
					<td class="  heads" width="200">Warning Recipients : </td>
					<td class=" " width="475">
						<table BORDER=0>
							<tr>
								<td width="100"><FONT COLOR="RED"><%=(imp_stats.s_warning_recips!=null)?imp_stats.s_warning_recips:"N/A"%></FONT> records</td>
								<td>
<%	if ((imp_stats.s_warning_recips != null) && (!imp_stats.s_warning_recips.equals ("0"))) { %>
									<a class="subactionbutton" href="#" onclick="PreviewURL('import_browse_recs.jsp?type=3&import_id=<%=sImportID%>');">View and Export Records</a>
<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td class="  heads" width="200">Invalid Recipients : </td>
					<td class=" " width="475">
						<table BORDER=0>
							<tr>
								<td width="100"><FONT COLOR="RED"><%=(imp_stats.s_bad_fingerprints!=null)?imp_stats.s_bad_fingerprints:"N/A"%></FONT> records</td>
								<td>
<%	if ((imp_stats.s_bad_fingerprints != null) && (!imp_stats.s_bad_fingerprints.equals ("0"))) { %>
									<a class="subactionbutton" href="#" onclick="PreviewURL('import_browse_recs.jsp?type=5&import_id=<%=sImportID%>');">View and Export Records</a>
<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="  heads" width="200">Invalid Emails : </td>
					<td class=" " width="475">
						<table BORDER=0>
							<tr>
								<td width="100"><FONT COLOR="RED"><%=(imp_stats.s_bad_emails!=null)?imp_stats.s_bad_emails:"N/A"%></FONT> records</td>
								<td>
<%	if ((imp_stats.s_bad_emails != null) && (!imp_stats.s_bad_emails.equals ("0"))) { %>
									<a class="subactionbutton" href="#" onclick="PreviewURL('import_browse_recs.jsp?type=1&import_id=<%=sImportID%>');">View and Export Records</a>
<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="  heads" width="200">Duplicates in the files : </td>
					<td class=" " width="475">
						<table BORDER=0>
							<tr> 
								<td width="100"><FONT COLOR="RED"><%=(imp_stats.s_file_dups!=null)?imp_stats.s_file_dups:"N/A"%></FONT> records</td>
								<td>
<%	if ((imp_stats.s_file_dups != null) && (!imp_stats.s_file_dups.equals ("0"))) { %>
									<a class="subactionbutton" href="#" onclick="PreviewURL('import_browse_recs.jsp?type=2&import_id=<%=sImportID%>');">View and Export Records</a>
<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td class="  heads" width="200">Total after invalids : </td>
					<td class=" " width="475"><%=(imp_stats.s_tot_recips!=null)?imp_stats.s_tot_recips:"N/A"%> recipients</td>
				</tr>
				<tr>
					<td class="  heads" width="200">Duplicates in the DB : </td>
					<td class=" " width="475">
						<table BORDER=0>
							<tr>
								<td width="100"><%=(imp_stats.s_dup_recips!=null)?imp_stats.s_dup_recips:"N/A"%> records</td>
								<td>
<%	if ((imp_stats.s_dup_recips != null) && (!imp_stats.s_dup_recips.equals ("0"))) { %>
									<a class="subactionbutton" href="#" onclick="PreviewURL('import_browse_recs.jsp?type=4&import_id=<%=sImportID%>');">View and Export Records</a>
<%	} %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="  heads" width="200">Committed : </td>
					<td class=" " width="475"><%=(imp_stats.s_num_committed!=null)?imp_stats.s_num_committed:"N/A"%> recipients</td>
				</tr>
				<tr>
					<td class="  heads" width="200">Left to commit : </td>
					<td class=" " width="475"><%=(imp_stats.s_left_to_commit!=null)?imp_stats.s_left_to_commit:"N/A"%> recipients</td>
				</tr>
<%	if (imp_stats.s_error_message != null) { %>
				<tr>
					<td class="  heads" width="200"><FONT COLOR="RED">Error</FONT></td>
					<td class=" " width="475"><%=imp_stats.s_error_message%></td>
				</tr>
<% } %>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</FORM>
<%
if (( nStatusID >= 30 && nStatusID < 70 ) || nStatusID == 7) //ImportStatus.IN_STAGING
{ 
	String sImportURL = null;
	try
	{
		if ((imp.s_import_file == null) || (imp.s_import_file.trim().equals(""))) 
		{
			String sErrMsg = 
				"import_detail.jsp ERROR: " +
				"import_file is not specified. import_id = " + imp.s_import_id;
			throw new Exception ();
		}

		// === === ===

		Vector services = Services.getByCust(ServiceType.RUPD_IMPORT_RESULT_FILE_VIEW, cust.s_cust_id);
		Service service = (Service) services.get(0);

		sImportURL = service.getURL().toString();
		sImportURL +=
			"?cust_id=" + cust.s_cust_id +
			"&import_id=" + imp.s_import_id +
			"&file_type=preview" +
			"&import_file=" + imp.s_import_file.trim();

		HttpURLConnection huc = null;
		try
		{
			URL url = new URL(sImportURL);
			huc = (HttpURLConnection) url.openConnection();
			huc.setDoOutput(false);
			huc.setDoInput(true);

			BufferedReader inRCP = new BufferedReader(new InputStreamReader(huc.getInputStream(),"UTF-8"));
%>
<PRE>
<%
			for(String sLine = inRCP.readLine(); sLine != null; sLine = inRCP.readLine()){
				out.println(sLine);

			} 

%>
</PRE>
<%
			inRCP.close();

			if (huc.getResponseCode()!= HttpServletResponse.SC_OK)
			{
				throw new IOException ("import_detail.jsp ERROR: " + huc.getResponseMessage());
			}
		}
		catch(Exception ex) { throw ex; }
		finally { if(huc!=null) huc.disconnect(); }
	}
	catch(Exception ex)
	{
		logger.error("import_details.jsp ERROR: cannot get data from url: " + sImportURL,ex);
		
%>
<H5 align>Cannot access preview file.</H5>
<BR><BR>
<%
	} 
}
%>
</BODY>
</HTML>
