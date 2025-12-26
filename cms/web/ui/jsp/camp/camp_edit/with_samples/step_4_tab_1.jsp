<table class="listTable" cellspacing="1" cellpadding="2" width="100%">
<%
if(camp_sampleset.s_send_date_flag == null)
{
	%>
	<%
	boolean bNowChecked = true;
	boolean bSpecificChecked = false;

	bNowChecked = (schedule.s_start_date==null);
	bSpecificChecked = (schedule.s_start_date!=null);
	%>
	<tr>
		<td width="150" valign="middle">Send Start Date </td>
		<td width="400">
			<table>
				<tr>
					<td width="25%">
						<input name="start_date_switch" id="start_date_switch_now" value="now" type="radio"<%=((bNowChecked)?" checked":"")%>>&nbsp;<label for="start_date_switch_now">Now</label>&nbsp;
					</td>
					<td nowrap>
						<input name="start_date_switch" id="start_date_switch_specified" value="" type="radio"<%=((bSpecificChecked)?" checked":"")%>>&nbsp;<label for="start_date_switch_specified">Specific Date:</label>&nbsp; 
						<select name="start_date_year" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">
							<%=getYearOptionsHtml(schedule.s_start_date)%>
						</select>
						<select name="start_date_month" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">
							<%=getMonthOptionsHtml(schedule.s_start_date)%>
						</select>
						<select name="start_date_day" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">
							<%=getDayOptionsHtml(schedule.s_start_date)%>
						</select>
						<select name="start_date_hour" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">
							<%=getHourOptionsHtml(schedule.s_start_date)%>
						</select>
						<!--(EST)-->
						<input name="start_date" type="hidden" value="">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%
}
else
{
	%>
	<tr>
		<td valign="middle" align="center" style="padding:10px;" colspan="2">Send Date information was assigned to each Sample Campaign above.</td>
	</tr>
	<%
}
%>
	<tr>
		<td align="center" colspan="2" style="padding:10px;">
<%
if(can.bExecute)
{
	if((!bWasFinalCampSent) && (!bWasSamplesetSent) && (!isSending) && (!isTesting))
	{
		%>
		&nbsp;&nbsp;&nbsp;
		<a class="actionbutton" href="javascript:send_sampleset();">SEND <%=(isDynamicCampaign?"DYNAMIC CAMPAIGNS":"SAMPLESET") %> >></a>
		&nbsp;&nbsp;&nbsp;
		<%
	}

	if((camp_sampleset.s_final_camp_flag != null)&&(!bWasFinalCampSent))
	{
		%>
		<a class="actionbutton" href="javascript:send_final_campaign();">SEND FINAL CAMPAIGN >></a>
		&nbsp;&nbsp;&nbsp;
		<%
	}
}
%>
		</td>
	</tr>
</table>
