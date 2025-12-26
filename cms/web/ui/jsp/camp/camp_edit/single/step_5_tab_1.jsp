
<table class="main" cellspacing="1" cellpadding="5" width="100%">
<%
	if( camp.s_camp_id != null )
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

		//Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
		boolean oneHistory = false;
		boolean nonTestSent = false;

		sSql = 
			" SELECT " +
				" isnull(e.create_date,''), " +
				" isnull(s.start_date,''), " +
				" isnull(s.finish_date,''), " +
				" t.display_name, " +
				" a.display_name, " +
				" s.recip_queued_qty, " +
				" s.recip_sent_qty, " +
				" c.camp_id, " +
				" c.approval_flag, " +
				" t.type_id " +
			" FROM cque_campaign c WITH(NOLOCK)" +
				" LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
					" ON c.camp_id = s.camp_id " +
				" INNER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
					" ON c.camp_id = e.camp_id " +
				" INNER JOIN cque_camp_type t WITH(NOLOCK)" +
					" ON c.type_id = t.type_id " +
				" INNER JOIN cque_camp_status a WITH(NOLOCK)" +
					" ON c.status_id = a.status_id " +
			" WHERE cust_id ="+cust.s_cust_id+" " +
				" AND (c.type_id = "+camp.s_type_id+") " +
				" AND c.origin_camp_id = "+camp.s_camp_id+" " +
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
			if (Integer.valueOf(camp.s_status_id).intValue() < CampaignStatus.DONE) sFinishDate = "";
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
            <% if (!isPrintCampaign) { %>
			<%
			CampStatDetails csds = new CampStatDetails();
			csds.s_camp_id = String.valueOf(nCampId);
			csds.retrieve();
			
			if(csds.size() != 0)
			{
				%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showCampDetails('<%=nCampId%>', 'queue');" class="resourcebutton">Details</a>
				<% 
			}
			%>
            <% } %>
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
		<td align="left" valign="middle" colspan="8" class="CampHeader"><b>Campaign ID:</b> <%=(Integer.parseInt(camp.s_camp_id)+1)%></td>
	</tr>
	<tr>
		<td align="left" valign="middle" nowrap class="CampHeading">Created on </td>
		<td>&nbsp;&nbsp;</td>
		<td align="left" valign="middle" nowrap><%=camp_edit_info.s_create_date%></td>
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
