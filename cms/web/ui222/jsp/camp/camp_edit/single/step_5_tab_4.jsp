<table class="main" cellspacing="1" cellpadding="2" width="100%" border="0">
	<tr>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Test ID:</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Type</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Status</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>Created</b></td>
		<td align="left" valign="middle" nowrap class="CampHeader"><b>PV IQ</b></td>
	</tr>
<%
	if( camp.s_camp_id != null )
	{
		//Grab this campaign's history by looking for origin_camp_id = CAMPAIGN_ID
		boolean hasHistory = false;
		String temp_camp_id = "";
		String temp_test_type_id = "";
		String temp_test_type_name = "";
		String temp_status = "";
		String temp_create_date = "";
		String temp_pv_iq = "";
		
		sSql = 
			"SELECT	c.camp_id CampId," +
			"	    h.pv_test_type_id PvTestTypeId," +
			"	    s.display_name TestStatus," +
			"       isnull(h.test_date,'') TestDate," +
			"	    isnull(h.pv_iq, '') PvIq" +
			"  FROM cque_campaign c," +
			"	    cque_camp_pv_hist h," +
			"	    cque_camp_status s" +
			" WHERE c.cust_id = " + cust.s_cust_id + 
			"   AND c.type_id = 1" +
            "   AND c.mode_id in (30,40)" +
			"   AND c.origin_camp_id = " + camp.s_camp_id +
			"   AND c.camp_id = h.camp_id" +
			"   AND c.status_id = s.status_id" +
			" UNION " +
			"SELECT	null CampId," +
			"	    h.pv_test_type_id PvTestTypeId," +
			"	    'Done' TestStatus," +
			"       isnull(h.test_date,'') TestDate," +
			"	    isnull(h.pv_iq, '') PvIq" +
			"  FROM cque_camp_pv_hist h" +
			" WHERE h.origin_camp_id = " + camp.s_camp_id +
			"   AND h.camp_id IS NULL" +
			" ORDER BY TestDate DESC";

		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			hasHistory = true;
			temp_camp_id = rs.getString(1);
			if (temp_camp_id == null) temp_camp_id = "---";
			
			temp_test_type_id = rs.getString(2);
			if (temp_test_type_id.equals("1")) temp_test_type_name = "eDelivery Tracker";
			if (temp_test_type_id.equals("2")) temp_test_type_name = "eContent Scorer";
			if (temp_test_type_id.equals("3")) temp_test_type_name = "eDesign Optimizer";
			
			temp_status = rs.getString(3);
			if (temp_status == null) temp_status = "";
			
			temp_create_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(4));
			if (temp_create_date.equals("Jan 1, 1900 12:00 AM")) temp_create_date = "";
			
			temp_pv_iq = rs.getString(5);
%>
	<tr>
		<td align="left" valign="middle"><%=temp_camp_id%></td>
		<td align="left" valign="middle"><%=temp_test_type_name%></td>
		<td align="left" valign="middle"><%=temp_status%></td>
		<td align="left" valign="middle" nowrap><%=temp_create_date.replaceAll(",","")%></td>
		<td align="left" valign="middle"><%=temp_pv_iq%>&nbsp;&nbsp;<a href="javascript:pv_report_popup('<%= temp_test_type_id%>', '<%=temp_pv_iq %>');" class="resourcebutton">View PV Report</a></td>
	</tr>
<%
		}
		rs.close();
		if (hasHistory == false)
		{
%>
	<tr>
		<td class="CampHeader" colspan="7">No Deliverability Tests Have Been Sent For This Campaign</td>
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