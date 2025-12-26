
<table class="main" cellspacing="1" cellpadding="2" width="100%" border="0">
	<tr>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Name</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>ID</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Status</b></td>
		<!-- td align="left" valign="middle" nowrap class="CampHeader"><b># Total</b></td -->
		<td align="left" valign="middle" nowrap class="CampHeader"><b># Queued</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b># Sent</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Created</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Started</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Finished</b></td>
	</tr>
<%
	if( camp.s_camp_id != null )
	{
		int nCampId = 0;
		int nSampleId = 0;
		String sCampName = null;
		String sTypeId = null;
		String sTypeDisplayName = null;
		int nStatusId = 0;
		String sStatusDisplayName = null;
		String sApprovalFlag = null;
		String sStartDate = null;
		String sFinishDate = null;
		String sRecpTotalQty = null;
		String sRecpQueuedQty = null;
		String sRecpSendQty = null;
		String sCreateDate = null;

		boolean hasHistory = false;
		boolean hasSamples = false;
		String sampleQueueId = "";
		
		CampStatDetails csds = null;

		sSql = 
			" SELECT" +
				" c.camp_id," +
				" c.camp_name, " +
				" t.type_id, " +
				" t.display_name," +
				" a.status_id," +
				" a.display_name," +
				" c.approval_flag," +
				" CONVERT(varchar(32),s.start_date,100)," +
				" CONVERT(varchar(32),s.finish_date,100)," +
				" s.recip_total_qty," +
				" s.recip_queued_qty," +
				" s.recip_sent_qty," +
				" CONVERT(varchar(32),e.create_date,100)," +
				" ISNULL(c.sample_id,0)" +
			" FROM cque_campaign c WITH(NOLOCK)" +
				" LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
					" ON c.camp_id = s.camp_id " +
				" LEFT OUTER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
					" ON c.camp_id = e.camp_id " +
				" INNER JOIN cque_camp_type t WITH(NOLOCK)" +
					" ON c.type_id = t.type_id " +
				" INNER JOIN cque_camp_status a WITH(NOLOCK)" +
					" ON c.status_id = a.status_id " +
			" WHERE c.type_id != 1" +
				" AND c.origin_camp_id = " + camp.s_camp_id +
			" ORDER BY e.create_date DESC";

		rs = stmt.executeQuery(sSql);
		byte[] b = null;
		while (rs.next())
		{
			nCampId = rs.getInt(1);

			b = rs.getBytes(2);
			sCampName = (b==null)?null:new String(b, "UTF-8");

			sTypeId = rs.getString(3);
			sTypeDisplayName = rs.getString(4);
			nStatusId = rs.getInt(5);
			sStatusDisplayName = rs.getString(6);
			sApprovalFlag = rs.getString(7);
			sStartDate = rs.getString(8);
			sFinishDate = rs.getString(9);
			sRecpTotalQty = rs.getString(10);
			sRecpQueuedQty = rs.getString(11);
			sRecpSendQty = rs.getString(12);
			sCreateDate = rs.getString(13);
			nSampleId = rs.getInt(14);

			if("1".equals(sTypeId)) sCampName += " (Test)";
			
			if (!(nSampleId == 0)) hasSamples = true;
%>
	<tr>
		<td align="left" valign="middle"><%=HtmlUtil.escape(sCampName)%></td>
		<td align="left" valign="middle"><%=nCampId%></td>
		<td align="left" valign="middle"><%=HtmlUtil.escape(sStatusDisplayName)%></td>
		<!-- td align="left" valign="middle"><%=HtmlUtil.escape(sRecpTotalQty)%></td -->
		<td align="left" valign="middle">
			<%=HtmlUtil.escape(sRecpQueuedQty)%>
            <% if (!isPrintCampaign) { %>
			<%
			csds = new CampStatDetails();
			csds.s_camp_id = String.valueOf(nCampId);
			csds.retrieve();
			
			if (csds.size() != 0)
			{
				sampleQueueId = String.valueOf(nCampId);
				
				if (nSampleId == 0)
				{
					%>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showCampDetails('<%=nCampId%>', 'queue');" class="resourcebutton">Details</a>
					<%
				}
			}
			%>
            <% } %>
		</td>
		<td align="left" valign="middle"><%=HtmlUtil.escape(sRecpSendQty)%></td>
		<td align="left" valign="middle"><%=HtmlUtil.escape(sCreateDate)%></td>
		<td align="left" valign="middle"><%=HtmlUtil.escape(sStartDate)%></td>
		<td align="left" valign="middle"><%=(nStatusId < CampaignStatus.DONE)?"":HtmlUtil.escape(sFinishDate)%></td>
	</tr>
<%
			hasHistory = true;
		}
		rs.close();
		
		if (hasSamples == true)
		{
			%>
    <% if (!isPrintCampaign) { %>
	<tr>
		<td colspan="8">
		    <%=(isDynamicCampaign?"Dynamic Campaigns ":"Sample Set ") %> 
			 Summary: 
			<%
			csds = new CampStatDetails();
			csds.s_camp_id = sampleQueueId;
			csds.retrieve();
			
			if(csds.size() != 0)
			{
				%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showCampDetails('<%=nCampId%>', 'queue');" class="resourcebutton">Details</a>
				<%
			}
			%>
		</td>
	</tr>
    <% } %>
			<%
		}
	}
	else
	{
%>
	<tr>
		<td class="CampHeader" colspan="8">
			This area will show Campaign History information once you click the Save button.
		</td>
	</tr>
<%
	}
%>
</table>
