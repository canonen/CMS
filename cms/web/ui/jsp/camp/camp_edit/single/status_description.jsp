<%
{
	String sRecipsQueued		= "0";
	String sRecipsSent			= "0";
	String sDescStatusText		= "";

	if(StatusCampID != null)
	{
		CampStatistic camp_statistic = new CampStatistic();
		camp_statistic.s_camp_id = StatusCampID;
		if(camp_statistic.retrieve() > 0)
		{
			sRecipsQueued = camp_statistic.s_recip_queued_qty;
			sRecipsSent = camp_statistic.s_recip_sent_qty;
		}
	}

//	int nDescStatusID = Integer.parseInt(camp.s_status_id);
//	if((nDescStatusID == CampaignStatus.READY_TO_BE_QUEUED)	|| (nDescStatusID == CampaignStatus.RECIPS_QUEUED)) //|| nDescStatusID == CampaignStatus.JTK_SETUP_COMPLETE
	if((tmpStatus == CampaignStatus.READY_TO_BE_QUEUED)	|| (tmpStatus == CampaignStatus.RECIPS_QUEUED)) //|| nDescStatusID == CampaignStatus.JTK_SETUP_COMPLETE
	{
		sDescStatusText = "queued to send";
	}
	else sDescStatusText = "ready to send";

	if (SendCampApproved == null || SendCampApproved == "null") SendCampApproved = "0";

	// === === ===

	String sNotApproved = "Your campaign has not been approved and will not sendout on the specified time until it has been approved.";
%>
<tr>
	<th align="center" valign="middle"><%= (!isTesting)?sCampTypeLabel:"Test" %>&nbsp;Campaign:&nbsp;<%= CampaignStatus.getDisplayName(tmpStatus) %></th>
</tr>
<%
	if( tmpStatus == CampaignStatus.DRAFT )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
		Once you click Start Campaign or Send A Test, 
		relevant information about the status of your campaign will appear here.
	</td>
</tr>
<%
	}
	else if( (tmpStatus == CampaignStatus.SENT_TO_RCP) || (tmpStatus == CampaignStatus.RECIP_LIST_CREATED) || (tmpStatus == CampaignStatus.READY_TO_BE_QUEUED) )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
	<% if( tmpType == 1 && tmpMode == 0) { %>
		<FONT color="red"><B>Your test process has started</B></FONT>
	<% } else if( tmpType == 1 && tmpMode != 0) { %>
		<FONT color="red"><B>The campaign statistics are currently calculating</B></FONT>
	<% } else { %>
		<FONT color="red"><B>Your campaign process has started</B></FONT>
	<%	} %>
	<% if( !SendCampApproved.equals("1") && tmpStatus < CampaignStatus.DONE && tmpType != 1 ) { %>
		<BR><FONT color="red"><B><%= sNotApproved %></B></FONT>
	<%	} %>
	</td>
</tr>
<%
	}
	//tmpStatus == CampaignStatus.JTK_SETUP_COMPLETE -- taken out for v5.0
	else if( tmpStatus == CampaignStatus.RECIPS_QUEUED || tmpStatus == CampaignStatus.READY_TO_SEND )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
	<% if( tmpType == 1 ) { %>
		<FONT color="red"><B>You have <%= sRecipsQueued %> tests <%= sDescStatusText %></B></FONT>
	<% } else { %>
		<FONT color="red"><B>You have <%= sRecipsQueued %> recipients <%= sDescStatusText %></B></FONT>
	<%	} %>
	<% if( !SendCampApproved.equals("1") && tmpStatus < CampaignStatus.DONE  && tmpType != 1 ) { %>
		<BR><FONT color="red"><B><%= sNotApproved %></B></FONT>
	<%	} %>
	</td>
</tr>
<%
	}
	else if( tmpStatus == CampaignStatus.BEING_PROCESSED )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
	<% if( tmpType == 1 ) { %>
		<FONT color="red"><B>You have sent <%= sRecipsSent %> out of <%= sRecipsQueued %> tests</B></FONT>
	<%  } else if( tmpType == 3 || tmpType == 4 ) { %>
		<FONT color="red"><B>Your campaign has sent <%= sRecipsSent %> recipients thus far</B></FONT>
	<% } else { %>
		<FONT color="red"><B>You have sent to <%= sRecipsSent %> out of <%= sRecipsQueued %> total recipients</B></FONT>
	<%	} %>
	<% if( !SendCampApproved.equals("1") && tmpStatus < CampaignStatus.DONE && tmpType != 1  ) { %>
		<BR><FONT color="red"><B><%= sNotApproved %></B></FONT>
	<%	} %>
	</td>
</tr>
<%
	}
	else if( tmpStatus == CampaignStatus.WAITING )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
		<FONT color="red"><B>Your campaign has sent <%= sRecipsSent %> recipients thus far</B></FONT>
	<% if( !SendCampApproved.equals("1") && tmpStatus < CampaignStatus.DONE && tmpType != 1  ) { %>
		<BR><FONT color="red"><B><%= sNotApproved %></B></FONT>
	<%	} %>
	</td>
</tr>
<%
	}
	else if( tmpStatus == CampaignStatus.CANCELLED )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
		<FONT color="red"><B>Your campaign was cancelled. 
		It had sent <%= sRecipsSent %> recipients out of <%= sRecipsQueued %> total recipients before being cancelled.</B></FONT>
	</td>
</tr>
<%
	}
	else if( tmpStatus == CampaignStatus.ERROR )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
		<FONT color="red"><B>Your campaign has generated an error. 
		Please confirm that your Target Group has recipients or contact Support for more assistance.</B></FONT>
	</td>
</tr>
<%
	}
	else if ( tmpStatus == CampaignStatus.DONE && camp.s_type_id.equals("4") )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
		<FONT color="red"><B>Your auto campaign has been completed and is no longer processing new recipients.</B></FONT>
	</td>
</tr>
<%
	}
	else if( tmpStatus == CampaignStatus.DONE && camp.s_type_id.equals("5") )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
		This campaign has completed sending.<BR>
		Your campaign sent <%= sRecipsSent %> recipients out of <%= sRecipsQueued %> total recipients.<BR>
	    Right-click on the Export Name below and select [Save Target As...] to <FONT COLOR="RED">download the export</FONT> onto your local computer.
	</td>
</tr>
<%
	}
	else if( tmpStatus == CampaignStatus.DONE && ((!camp.s_type_id.equals("4")) && (!camp.s_type_id.equals("1"))) )
	{
%>
<tr>
	<td valign="top" align="center" style="padding:10px;" width="100%">
		This campaign has completed sending.<BR>
		Your campaign sent <%= sRecipsSent %> recipients out of <%= sRecipsQueued %> total recipients.
	</td>
</tr>
<%
	}
}
%>