<%
	CampSample camp_sample = null;
	String sSampleId = "";

// ********** JM
     CampApproveDAO cDAO = new CampApproveDAO();
     boolean bWasSent = false;
     boolean bIsApproved = false;
     String sActiveCampId = null;
     String sActiveCampIdMain = null;
     String sApproveRestart = null;
     String sCancelConfirm = null;

// ********** JM

// ********** KU

	String tabHeading = "";
	String tabQty = "";
	String sInTypes = "2,5,7";
	
	// added as a part of release 6.0 (New button added 'Set Done' similar action as cancel
	String sSetDoneConfirm = null;
	boolean bIsCancelled = false;

// ********** KU

%>
<TABLE width="650" border="0" cellspacing="0" cellpadding="2">
	<TR <%=((camp_sampleset.s_final_camp_flag == null)?" style='display: none'":"")%>>
		<td colspan="2">
<%
	camp_sample = new CampSample();
	camp_sample.s_camp_id = camp.s_camp_id;
	camp_sample.s_sample_id = "0";
	camp_sample.s_from_name = msg_header.s_from_name;
	camp_sample.s_from_address = msg_header.s_from_address;
	camp_sample.s_from_address_id = msg_header.s_from_address_id;
	camp_sample.s_subject_html = msg_header.s_subject_html;
	camp_sample.s_subject_text = msg_header.s_subject_text;
	camp_sample.s_subject_aol = msg_header.s_subject_aol;
	camp_sample.s_cont_id = camp.s_cont_id;
	camp_sample.s_send_date = schedule.s_start_date;
	camp_sample.s_test_list_id = camp_list.s_test_list_id;

	int nRecipPct = (camp_sampleset.s_recip_percentage!=null)?Integer.parseInt(camp_sampleset.s_recip_percentage):0;
	nRecipPct = 100 - nRecipPct;
	int nRecipQty = (camp_sampleset.s_recip_qty!=null)?Integer.parseInt(camp_sampleset.s_recip_qty):0;
	int nFilterQty = (filter_statistic.s_recip_qty!=null)?Integer.parseInt(filter_statistic.s_recip_qty):0;
	nRecipQty = nFilterQty - nRecipQty;
	tabHeading = "Final";
	if (isDynamicCampaign)
	{
		tabQty = "";
	}
	else
	{
		tabQty = (nRecipPct < 100)?nRecipPct+"%":"";
	}
	tabQty += (nRecipQty <= 0)?"Remaining recipients":"";
	tabQty += ((nRecipQty < nFilterQty) && (nRecipQty > 0))?nRecipQty+" recipients":"";
%>
<%@ include file="step_3_tab.jsp"%>
<%

	// ********** JM
	if (canApprove.bExecute && bWasFinalCampSent && !finalIsPending)
	{
		
		sActiveCampId = cDAO.getActiveCamp(camp.s_camp_id, null);
		sActiveCampIdMain = sActiveCampId;
		bIsApproved = cDAO.getApprovedStatus(sActiveCampId);
		Campaign campTmp = new Campaign(sActiveCampId);
        int iStatusId;
        if (campTmp == null || campTmp.s_status_id == null) 
             iStatusId = 0;
        else
             iStatusId = Integer.parseInt(campTmp.s_status_id);

        bIsDone = (iStatusId >= 60);
	
		// added as a part of release 6.0 (New button added 'Set Done' similar action as cancel
		bIsCancelled = (iStatusId == 80);
		// release 6.0 end
		
		if (iStatusId <= 50)
		{
			//Campaign hasn't begun yet.
			sApproveRestart = "Approve";
			sCancelConfirm = "You are cancelling a campaign that has not been sent to any recipients.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
			// added as a part of Release 6.0 (New button 'Set done' is added
			sSetDoneConfirm =
				"You are setting campaign to Done status and has not been sent to any recipients. To perform any edits to this campaign you will need to clone it first. " + 
				"Continue with Set Done?";
		}
		else
		{
			//Campaign is processing
			sApproveRestart = "Restart";
			sCancelConfirm = "You are about to cancel this campaign.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
			// added as a part of Release 6.0 (New button 'Set done' is added
			sSetDoneConfirm =
				"You are setting campaign to Done status. To perform any edits to this campaign you will need to clone it first. " + 
				"Continue with Set Done?";
		}
		%>
		
		<table cellspacing="0" cellpadding="0" width="100%" border="0">
			<tr>
				<td class="listHeading" valign="middle" nowrap align="left">
		<%
		if (!bIsDone)
		{
			if (bIsApproved)
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
			&nbsp;&nbsp;/&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sCancelConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=cancel&cust_id=<%=cust.s_cust_id%>'">Cancel</a>
			/&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sSetDoneConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=setdone&cust_id=<%=cust.s_cust_id%>'">Set Done</a>				
			<%
		}
		else
		{
			// Final campaign is no longer processing (i.e., bIsDone = true)
			%>
			Status: <%= CampaignStatus.getDisplayName(iStatusId ) %>
			<%
		}
		%>
	
				</td>
			</tr>
		</table>
		<br>
	<%
	}
	else
	{
		%>
		<br>
		<%
	}

	// ********** JM
%>
		</td>
	</TR>
<%
	if(camp_sampleset.s_camp_qty != null)
	{
		int nSampleCount = Integer.parseInt(camp_sampleset.s_camp_qty);
		nRecipQty = (camp_sampleset.s_recip_qty!=null)?Integer.parseInt(camp_sampleset.s_recip_qty)/nSampleCount:0;
		nRecipPct = (camp_sampleset.s_recip_percentage!=null)?Integer.parseInt(camp_sampleset.s_recip_percentage)/nSampleCount:0;
		
		for(int i=1; i < nSampleCount + 1; i++)
		{
			sSampleId = String.valueOf(i);
			camp_sample = new CampSample(camp.s_camp_id, sSampleId);
			if (!isDynamicCampaign)
			{
				tabHeading = "Sample&nbsp;" + i;
				tabQty = (nRecipQty > 0)?nRecipQty+" recipients":"";
				tabQty += (nRecipPct > 0)?nRecipPct+"%":"";
			}
			else 
			{
				tabHeading = "Campaign&nbsp;" + i;
				tabQty = (nRecipQty > 0)?nRecipQty+" recipients":"";
				tabQty += "";
			}
			sActiveCampId = cDAO.getActiveCamp(camp.s_camp_id, String.valueOf(i));
			bWasSent = cDAO.getSentStatus(sActiveCampId);
			bIsApproved = cDAO.getApprovedStatus(sActiveCampId);
			Campaign campTmp = new Campaign(sActiveCampId);
			int iStatusId;
			if (campTmp == null || campTmp.s_status_id == null) 
			   iStatusId = 0;
			else
			   iStatusId = Integer.parseInt(campTmp.s_status_id);

			bIsDone = (iStatusId >= 60);
%>
	<TR>
		<TD colspan="2">
<%@ include file="step_3_tab.jsp"%>
<%
			// ********** JM

			if (canApprove.bExecute && bWasSamplesetSent && !samplesArePending)
			{
				if (iStatusId <= 50)
				{
					//Campaign hasn't begun yet.
					sApproveRestart = "Approve";
					sCancelConfirm = "You are cancelling a campaign that has not been sent to any recipients.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
					//Added as a part of release 6.0, 
					sSetDoneConfirm = "You are setting campaign to Done status that has not been sent to any recipients.  To perform any edits to this campaign you will need to clone it first.  Continue with Set Done?";
				}
				else
				{
					//Campaign is processing
					sApproveRestart = "Restart";
					sCancelConfirm = "You are about to cancel this campaign.  To perform any edits to this campaign you will need to clone it first.  Continue with Cancel?";
					//Added as a part of release 6.0, 
					sSetDoneConfirm = "You are setting campaign to Done status. To perform any edits to this campaign you will need to clone it first.  Continue with Set Done?";
				}
				%>
				<table cellspacing="0" cellpadding="0" width="100%" border="0">
				<tr>
					<td class="listHeading" valign="middle" nowrap align="left">
				<%
				if (bWasSent && !bIsDone)
				{
					if (!(isPrintCampaign && (iStatusId == CampaignStatus.BEING_PROCESSED))) {
						if (bIsApproved)
						{
							%>
							<a class="deletebutton" href="camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=suspend">Suspend</a>
							<%
						}
						else
						{
							%>
							<a class="actionbutton" href="camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=approve">Approve</a>
							<%
						}
						%>
						&nbsp;&nbsp;/&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sCancelConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=cancel&cust_id=<%=cust.s_cust_id%>'">Cancel</a>
						/&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sSetDoneConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampId%>&action=setdone&cust_id=<%=cust.s_cust_id%>'">Set Done</a>	
						<%
					}
				}
				else
				{
					// Final campaign is no longer processing (i.e., bIsDone = true)
					%>
					Status: <%= CampaignStatus.getDisplayName(iStatusId ) %>
					<%
				}
			%>
					</td>
				</tr>
			</table>
			<br>
			<%
			}
			else
			{
				%>
				<br>
				<%
			} 

		// ********** JM
%>
		</TD>
	</TR>

<%
		}
	}
%>
	<TR>
		<TD colspan="2">
<%@ include file="step_3b.jsp"%>
		</TD>
	</TR>

<% if(bIsCancelled)
	{ 
	%>
	<TR>
		<TD>
			&nbsp;&nbsp;<a class="deletebutton" href="#" onClick="if (confirm('<%=sSetDoneConfirm%>')) location.href='camp_approve.jsp?camp_id=<%=sActiveCampIdMain%>&action=setdone&cust_id=<%=cust.s_cust_id%>'">Set Done</a>			
		</TD>
	</TR>
<% } %>
</TABLE>