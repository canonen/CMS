<%
int iShowTypeId = 2;

iShowTypeId = Integer.parseInt(camp.s_type_id);

String sCampTypeLabel = "Standard";

if(iShowTypeId == 5) sCampTypeLabel = "Web/DM/Call";
else if(iShowTypeId == 4) sCampTypeLabel = "Triggered";
else if(iShowTypeId == 3) sCampTypeLabel = "Send To Friend";
else if(iShowTypeId == 2) sCampTypeLabel = "Standard";

if("1".equals(sAutoQueueDailyFlag)) sCampTypeLabel = "Check Daily";

if (isPrintCampaign) {
	sCampTypeLabel = sCampTypeLabel + " Print";
}

%>
<table class="main" cellspacing="1" cellpadding="2" width="100%">
<%@ include file="status_description.jsp"%>
</table>
<%
if (canApprove.bExecute && isSending)
{
	%>
<table class="main" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td align="center" valign="middle" style="padding:10px;">
	<%
	sActiveCampId = cDAO.getActiveCamp(camp.s_camp_id, null);
	bWasSent = cDAO.getSentStatus(sActiveCampId);
	
	bIsApproved = cDAO.getApprovedStatus(sActiveCampId);
	String sApproveRestart = null;
	String sCancelConfirm = null;

	boolean bIsDone = false;
	Campaign campTmp = new Campaign(sActiveCampId);
	bIsDone = (Integer.parseInt(campTmp.s_status_id) >= 60);
	
	// added as a part of release 6.0 (New button added 'Set Done' similar action as cancel
	String sSetDoneConfirm = null;
	boolean bIsCancelled = false;
	bIsCancelled = (Integer.parseInt(campTmp.s_status_id) == 80);
	// release 6.0 end
	
	if (Integer.parseInt(campTmp.s_status_id) <= 50)
	{ 
		//Campaign hasn't begun yet.
		sApproveRestart = "Approve";
		sCancelConfirm =
			"You are cancelling a campaign that has not been sent to any recipients.  " + 
			"To perform any edits to this campaign you will need to clone it first.  " + 
			"Continue with Cancel?";
		// added as a part of Release 6.0 (New button 'Set done' is added
		sSetDoneConfirm =
			"You are setting campaign to Done status and has not been sent to any recipients. " + 
			"To perform any edits to this campaign you will need to clone it first.  " + 
			"Continue with Set Done?";
	}
	else
	{
		//Campaign is processing
		sApproveRestart = "Restart";
		sCancelConfirm =
			"You are about to cancel this campaign.  " + 
			"To perform any edits to this campaign you will need to clone it first.  " + 
			"Continue with Cancel?";
		// added as a part of Release 6.0 (New button 'Set done' is added
		sSetDoneConfirm =
			"You are setting campaign to Done status. " + 
			"To perform any edits to this campaign you will need to clone it first.  " + 
			"Continue with Set Done?";
	}

	if (bWasSent && !bIsDone)
	{
		if (!(isPrintCampaign && (Integer.parseInt(campTmp.s_status_id) == CampaignStatus.BEING_PROCESSED)))
		{
			if ( bIsApproved )
			{
				%>
			<a class="deletebutton" href="camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=suspend">Suspend</a>
				<%
			}
			else
			{
				%>
			<a class="savebutton" href="camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=approve"><%=sApproveRestart%></a>
				<%
			}
			%>
			&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sCancelConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=cancel&cust_id=<%=cust.s_cust_id%>'">Cancel</a>
			&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sSetDoneConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=setdone&cust_id=<%=cust.s_cust_id%>'">Set Done</a>
			<%
		} %>
		</td>
	</tr>
</table>
<BR>
     <% if (!isPrintCampaign) { %>
          <table class="main" cellspacing="1" cellpadding="2" width="100%">
               <tr>
                    <td width="50%" align="center" valign="top" style="padding:10px;">
                         If you need to make changes in current campaign click
                         <br><br>
                         <a class="subactionbutton" href="camp_change.jsp?camp_id=<%= sActiveCampId %>">Make Changes</a>
                    </td>
                    <td width="50%" align="center" valign="top" style="padding:10px;">
                         <table cellspacing="0" cellpadding="2" border="0" width="100%">
                              <tr>
                                   <th>Change History</th>
                              </tr>
                         <%
                         String histSQL = 
                                   " select camp_id, version_id, CONVERT(VARCHAR(32), update_date, 100) " +
                                   " from cque_camp_xml_hist with(nolock) " +
                                   " where camp_id = '" + sActiveCampId + "' " +
                                   " order by update_date desc";
				
                         String histDate = "";
					
                         rs = stmt.executeQuery(histSQL);
                         while (rs.next())
                         {
                              histDate = rs.getString(3);
                              %>
                              <tr>
                                   <td nowrap class="listItem_Data"><%= histDate %></td>
                              </tr>
                              <%
                         }
                         rs.close();
                         %>
                         </table>
                    </td>
               </tr>
          </table>
          <%   }
	}
	// release 6.0 : add 'set done' button
	else if(bIsCancelled)
	{
	%>
		&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sSetDoneConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=setdone&cust_id=<%=cust.s_cust_id%>'">Set Done</a>
		</td>
	</tr>
</table>
<%	} // end release 6.0 : set done button
	
	else { 
        %>
        </td>
    </tr>
</table>
        <%
	}
}

if( isPending )
{
	%>
<table class="main" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td align="center" valign="middle" style="padding:10px;">
	<%
	if (can.bApprove && isApprover)
	{
		%>
			<a href="#" class="savebutton" onClick="workflow_approve()">Approve Campaign</a>
		</td>
	</tr>
	<tr>
		<td align="center" valign="middle" style="padding:10px;">
			<a href="#" class="savebutton" onClick="workflow_approve_w_comments()">Approve Campaign w/ comments</a>
		</td>
	</tr>
	<tr>
		<td align="center" valign="middle" style="padding:10px;">
			<a href="#" class="subactionbutton" onClick="workflow_edit()">Edit Campaign</a>
		</td>
	</tr>
	<tr>
		<td align="center" valign="middle" style="padding:10px;">
		<a href="#" class="deletebutton" onClick="workflow_reject()">Reject Campaign</a>
		<%
	}
	else
	{
		%>
		This campaign is currently pending approval.
		<%
	}
	%>
          </td>
     </tr>
</table>
	<%
}
%>
