<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			java.sql.*,java.io.*,
			java.util.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

     boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.CAMPAIGN);

     // get object (asset) information from request parameters and database if necessary
     // get object ID and type from request
     String sCampId = BriteRequest.getParameter(request,"camp_id");
     String sSampleId = BriteRequest.getParameter(request,"sample_id");
     // get other object info for display
     Campaign camp = new Campaign(sCampId);
     MsgHeader msghdr = new MsgHeader(sCampId);
//     System.out.println("in approval_request_edit_camp.jsp...camp_id:" + sCampId + ";origin_camp_id?:" + camp.s_origin_camp_id);

	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

	boolean isPrintCampaign = (camp.s_media_type_id != null && camp.s_media_type_id.equals("2"));
	//isPrintCampaign = true;
     // get Approvers for customer, asset
     Hashtable htApprovers = WorkflowUtil.getApprovers(cust.s_cust_id,ObjectType.CAMPAIGN);
     String sSelectedCategoryId = null;
     String sFilterOptions = FilterRetrieveUtil.getOptionsHtml(cust.s_cust_id, "0", sSelectedCategoryId);
     String sErrors = null;
     
     String sFromAddress = null;

     if (msghdr.s_from_address != null)
     {
          sFromAddress = msghdr.s_from_address;
     }
     else
     {
          PreparedStatement pstmt = null;
          ResultSet rs = null;
          ConnectionPool cp = null;
          Connection conn  = null;
          String sSql = null;

          try
          {

               cp = ConnectionPool.getInstance();
               conn = cp.getConnection("approval_request_edit_camp.jsp");
               sSql = "Select prefix +'@' + domain " +
                         "from ccps_from_address " +
                         "where from_address_id = ?";

               pstmt = conn.prepareStatement(sSql);
               pstmt.setString(1,msghdr.s_from_address_id);
               rs = pstmt.executeQuery();

               if (rs.next())
               {
                    sFromAddress = rs.getString(1);
               }
               else
               {
                    sFromAddress = "";
               }
               rs.close();
               pstmt.close();
          } catch (SQLException sqle) {
               logger.error("Error retrieving From Address info.",sqle);
               sFromAddress = "could not retrieve from database";
          } finally {
               if(pstmt != null) pstmt.close();
               if(conn != null) cp.free(conn);
          }
     }

     
%>

<html>
<head>
<title>Request Approval for Campaign</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>

<body>
<form name="FT" method="post" action="approval_request_send.jsp">

<%
	if(!can.bWrite || !bWorkflow)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

%>
<input type="hidden" name="object_type" value="<%=ObjectType.CAMPAIGN%>">
<input type="hidden" name="object_id" value="<%=sCampId%>">
<input type="hidden" name="sample_id" value="<%=sSampleId%>">

<!--- Step 0 Campaign Summary information----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;Campaign Summary Information</td>
	</tr>
</table>
<br>
<!---- Step 0 Info----->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab valign=top align=left width=650>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
				<tr>
					<td width="125" align="left" valign="middle">Name: </td>
					<td align="left" valign="middle"><%=HtmlUtil.escape(camp.s_camp_name)%> </td>
				</tr>
<%	if (!isPrintCampaign) { %>
				<tr>
					<td width="125" align="left" valign="middle">From Name: </td>
					<td align="left" valign="middle"><%= HtmlUtil.escape(msghdr.s_from_name) %> </td>
				</tr>
				<tr>
					<td width="125" align="left" valign="middle">From Address: </td>
					<td align="left" valign="middle"><%= HtmlUtil.escape(sFromAddress) %> </td>
				</tr>
				<tr>
					<td width="125" align="left" valign="middle">Subject: </td>
					<td align="left" valign="middle">
						<%=HtmlUtil.escape(msghdr.s_subject_html) %>
					</td>
				</tr>
<% } %>
			</table>
		</td>
	</tr>
     </tbody>
</table>
<br><br>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Select Approver</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
				<tr>
					<td width="150">Choose Approver</td>
					<td>
						<select name=approver size=1>
					<%
					if (htApprovers != null)
					{
						Enumeration eApprovers = htApprovers.keys();
						String sApproverId = null;
						while (eApprovers.hasMoreElements())
						{
							sApproverId = (String) eApprovers.nextElement();
							%>
							<option value=<%=sApproverId%>><%=(String)htApprovers.get(sApproverId)%></option>
							<%
						}
					}
					%>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<%	int nStep = 2;
	if (!isPrintCampaign) { %>
<!----Step 3 Header ---->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step <%=nStep%>:</b> Email Options</td>
	</tr>
</table>
<br>
<!---Step 3 Info------->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
				<tr>
					<td align="left" valign="middle">
						<input type="checkbox" name="send_test" id="send_test" onclick="ShowTestOptions()"><label for="send_test">&nbsp;Send Test email to approver?</label>
					</td>
				</tr>
				<tr id="test_options" style="display:none;">
					<td align="left" valign="middle">
						<table cellspacing="0" cellpadding="2" border="0">
							<tr>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td>
									<input type="checkbox" name="test_html" id="test_html" <%=((ui.n_ui_type_id == UIType.HYATT_USER)?" checked disabled":"")%>><label for="test_html">&nbsp;HTML</label>
								</td>
								<td>
									<input type="checkbox" name="test_text" id="test_text" <%=((ui.n_ui_type_id == UIType.HYATT_USER)?" checked disabled":"")%>><label for="test_text">&nbsp;Text</label>
								</td>
                                        <%
                                             if (ui.n_ui_type_id != UIType.HYATT_USER) {
                                        %>
                                                  <td>
                                                       <input type="checkbox" name="test_multipart" id="test_multipart"><label for="test_multipart">&nbsp;Multi-part</label>
                                                  </td>
                                        <% } %>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="dynamic_test" style="display:none;">
					<td align="left" valign="middle">
						<input type="checkbox" name="test_dynamic" id="test_dynamic" onclick="ShowDynamicTestOptions()"><label for="test_dynamic">&nbsp;Dynamic test?</label>
					</td>
				</tr>
				<tr id="dynamic_options" style="display:none;">
					<td align="left" valign="middle">
						<table cellspacing="0" cellpadding="2" border="0" width="100%">
							<tr>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td>
									Number of recipients: <input type="text" name="dynamic_recip_qty" size="5" maxlength="5">
								</td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td>
									<input type=checkbox name="dynamic_filter" id="dynamic_filter"><label for="dynamic_filter">&nbsp;Use different Target Group for dynamic test?</label>
								</td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;</td>
								<td>
									Target Group to use for dynamic test:
									<select name="dynamic_test_filter" size="1" >
										<%=sFilterOptions%>
									</select>
								</td>
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
<br><br>
<%		nStep++;
	} %>

<!----Step 2 Header ---->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step <%=nStep%>:</b> Add Comments</td>
	</tr>
</table>
<br>
<!---Step 2 Info------->
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
				<tr>
					<td align="left" valign="top">
						Add Comments to Approver:
						<br>
						<textarea  name="aprvl_request_comment" cols="60" rows="10" style="width:500px; height:200px;"></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock>
	<tr>
		<td class=fillTab>
			<table class=main border="0" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<a class="actionbutton" href="#" onclick="SendRequest()">Send Approval Request</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<script language="javascript">

function ShowTestOptions()
{
	var oRow = document.getElementById("test_options");
	
	if (oRow.style.display == "")
	{
		oRow.style.display = "none";
	}
	else
	{
		oRow.style.display = "";
	}

<%      if (ui.n_ui_type_id != UIType.HYATT_USER && ui.n_ui_type_id != UIType.HYATT_ADMIN) { %>
          oRow = document.getElementById("dynamic_test");
	
          if (oRow.style.display == "")
          {
               oRow.style.display = "none";
          }
          else
          {
               oRow.style.display = "";
          }
<% } %>
}

function ShowDynamicTestOptions()
{
	var oRow = document.getElementById("dynamic_options");
	
	if (oRow.style.display == "")
	{
		oRow.style.display = "none";
	}
	else
	{
		oRow.style.display = "";
	}
}

function SendRequest()
{
     undisable_forms();
     FT.submit();
}

     function undisable_forms()
     {
          var l = document.forms.length;
          for(var i=0; i < l; i++)
          {
               var m = document.forms[i].elements.length;
               for(var j=0; j < m; j++) document.forms[i].elements[j].disabled = false;
          }
     }

</script>
</body>
</html>

