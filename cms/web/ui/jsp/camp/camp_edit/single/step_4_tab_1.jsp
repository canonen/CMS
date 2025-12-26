<table class="main" cellspacing="1" cellpadding="2" width="100%">
	<%
	boolean bNowChecked = true;
	boolean bSpecificChecked = false;
	
	bNowChecked = (schedule.s_start_date==null);
	bSpecificChecked = (schedule.s_start_date!=null);
	
	if (isHyatt)
	{
		if (sCampId == null)
		{
			bNowChecked = false;
			bSpecificChecked = true;
		}
	}
	String sDeliverabilityInTypes = "10,11,12,13,14";
	%>
	<tr>
		<td width="150" valign="middle">Send Start Date </td>
		<td width="400">
			<table cellspacing="0" cellpadding="2" border="0">
				<tr>
					<td width="25%">
						<input name="start_date_switch" id="start_date_switch_now" value="now" type="radio"<%=((bNowChecked)?" checked":"")%>><label for="start_date_switch_now">&nbsp;Now</label>&nbsp;&nbsp;&nbsp;
					</td>
					<td nowrap>
						<input name="start_date_switch" id="start_date_switch_specified" value="" type="radio"<%=((bSpecificChecked)?" checked":"")%>><label for="start_date_switch_specified">&nbsp;Specific date:</label>&nbsp; 
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
	<% if (isHyatt) { %>
	<tr id="nowAlert">
		<td colspan="2" style="padding:5px;" align="center">
			Please select a start date <b><font color="red">no less than 3-5 business days</font></b> from today. Do not select Now.
		</td>
	</tr>
	<% } %>
<%
if( !camp.s_type_id.equals("2") && !camp.s_type_id.equals("5") )
{
	boolean bEndDateNever = true;
	if(schedule.s_end_date!=null) bEndDateNever = false;
	else if((camp.s_camp_id==null)&&(camp.s_type_id.equals("3"))) bEndDateNever = false;
%>
	<tr>
		<td width="150">End Date </td>
		<td width="400">
			<table>
				<tr>
					<td width="25%">
						<input name="end_date_switch" id="end_date_switch_now" value="never" type="radio"<%=((bEndDateNever)?" checked":"")%>><label for="end_date_switch_now">&nbsp;Never</label>&nbsp;
					</td>
					<td nowrap>
						<input name="end_date_switch" id="end_date_switch_specified" value="" type="radio"<%=((!bEndDateNever)?" checked":"")%>><label for="end_date_switch_specified">&nbsp;Specific date:</label>&nbsp; 
<%
	if(schedule.s_end_date == null)
	{
		rs = stmt.executeQuery("SELECT DATEADD(month, 2, getdate())");
		if (rs.next()) schedule.s_end_date = rs.getString(1);
		rs.close();
	}
%>
						<select name="end_date_year">
							<%=getYearOptionsHtml(schedule.s_end_date)%>
						</select>
						<select name="end_date_month">
							<%=getMonthOptionsHtml(schedule.s_end_date)%>
						</select>
						<select name="end_date_day">
							<%=getDayOptionsHtml(schedule.s_end_date)%>
						</select>
						<select name="end_date_hour">
							<%=getHourOptionsHtml(schedule.s_end_date)%>
						</select>
						<!--(EST)-->
						<input name="end_date" type="hidden" value="">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%
}
%>
<% 
   if ( canPvDeliveryTracker && canUserPvDeliveryTracker.bExecute && !isDone && !isSending && !isTesting && !isPending && (!isPendingEdits || (isPendingEdits && isApprover)) && can.bExecute)
   {
%>
	<tr>
		<td width="150" valign="middle">Delivery Tracker Test</td>
		<td width="400">
			<table cellspacing="0" cellpadding="2" border="0">
				<tr>
					<td width="60">
						<input name="pv_sendout_switch" id="pv_sendout_switch" type="checkbox"
						       onClick="if (FT.pv_sendout_switch.checked == false) {
						                  for (var i=0; i < FT.pv_sendout_list_ids.options.length; i++)
						                    FT.pv_sendout_list_ids.options[i].selected = false;
						                }
						                else {
						                  if (FT.pv_sendout_list_ids.options.length == 1)
						                    FT.pv_sendout_list_ids.options[0].selected = true;
						                }">Send to
					</td>
					<td nowrap>
						<select name="pv_sendout_list_ids" multiple size="<%=getTestListCount(stmt, cust.s_cust_id, sDeliverabilityInTypes)%>"
						        onChange="FT.pv_sendout_switch.checked = false;
						                  for (var i=0; i < FT.pv_sendout_list_ids.options.length; i++)
						                    if (FT.pv_sendout_list_ids.options[i].selected == true)
						                       FT.pv_sendout_switch.checked = true;">
							<%=getTestListOptionsHtml(stmt, cust.s_cust_id, camp_list.s_test_list_id, sDeliverabilityInTypes)%>
						</select>
					</td>
					<td nowrap>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<% } %>	
	<tr>
		<td align=center colspan="2" style="padding:10px;">
		<%
		if( !isDone && !isSending && !isTesting && !isPending && (!isPendingEdits || (isPendingEdits && isApprover)) && can.bExecute)
		{
			%>
			<a class="actionbutton" href="javascript:send();">START CAMPAIGN >></a>
			<%
		}
		%>
		</td>
	</tr>
</table>
