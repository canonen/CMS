<table class="main" cellspacing="1" cellpadding="2" width="100%" border="0">
	<tr>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Test ID:</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Status</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b># Queued</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b># Sent</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Created</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Started</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Finished</b></td>
	</tr>
<%
	if( camp.s_camp_id != null )
	{
		//Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
		boolean oneHistory = false;
		boolean nonTestSent = false;
		String histTemp[] = new String[9];
		
		sSql = 
			" SELECT" +
				" isnull(e.create_date,'')," +
				" isnull(s.start_date,'')," +
				" isnull(s.finish_date,'')," +
				" t.display_name," +
				" a.display_name," +
				" s.recip_queued_qty," +
				" s.recip_sent_qty," +
				" c.camp_id," +
				" c.approval_flag," +
				" t.type_id " +
			" FROM cque_campaign c WITH(NOLOCK)" +
				" LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)" +
					" ON c.camp_id = s.camp_id " +
				" LEFT OUTER JOIN cque_camp_edit_info e WITH(NOLOCK)" +
					" ON c.camp_id = e.camp_id " +
				" INNER JOIN cque_camp_type t WITH(NOLOCK)" +
					" ON c.type_id = t.type_id " +
				" INNER JOIN cque_camp_status a WITH(NOLOCK)" +
					" ON c.status_id = a.status_id " +
			" WHERE c.cust_id ="+cust.s_cust_id+" " +
				" AND (c.type_id = 1) " +
	            " AND ISNULL(c.mode_id,0) not in (20,30,40) " +
				" AND c.origin_camp_id = "+camp.s_camp_id+" " +
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
		<td class="CampHeader" colspan="7">No Tests Have Been Sent For This Campaign</td>
	</tr>		
<%
		}
	}
	else
	{
%>
	<tr>
		<td class="CampHeader" colspan="7">This area will show Campaign History information once you click the Save button.</td>
	</tr>
<%
	}
%>
</table>