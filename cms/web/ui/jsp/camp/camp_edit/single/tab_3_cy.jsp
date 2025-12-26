<%
boolean step4_tab1_show = true;
boolean step4_tab2_show = false;

String step4_tab_width = "350";
String step4_colspan = " colspan=\"3\"";

if (canQueueStep) step4_tab2_show = true;
if (!step4_tab2_show)
{
	step4_tab_width = "500";
	step4_colspan = " colspan=\"2\"";
}
%>

<table id="Tabs_Table5" cellspacing="0" cellpadding="2" width="100%" border="0" class="listTable">
</thead>
	<tr>
		<th class="Tab_ON" id="tab5_Step1" width="150" onclick="toggleTabs('tab5_Step','block5_Step',1,2,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">Send Out</th>
	<%
	if (step4_tab2_show)
	{
		%>
		<th class="Tab_OFF campaign_header" id="tab5_Step2" width="150" onclick="toggleTabs('tab5_Step','block5_Step',2,2,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">Advanced Options</th>
		<%
	}
	%>
	</tr>

	</thead>
	<tbody class="EditBlock" id="block5_Step1">
	<tr>
		<td class="" valign="top" align="center" width="650"<%= step4_colspan %>>

<table class="" cellspacing="0" cellpadding="2" width="100%">
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
		<td width="150" class="campaign_header" valign="middle" nowrap>Send Start Date </td>
		<td width="400">
			<table cellspacing="0" cellpadding="2" border="0">
				<tr>
					<td width="25%" class="campaign_header">
						<input name="start_date_switch" id="start_date_switch_now" value="now" type="radio"<%=((bNowChecked)?" checked":"")%>><label for="start_date_switch_now">&nbsp;Now</label>&nbsp;&nbsp;&nbsp;
					</td>
					<td class="campaign_header" nowrap>
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
						<input name="start_date" type="hidden" value="">
					</td>
					<td class="campaign_header" nowrap>						

						<select name="start_time_zone">
						<%=getTimeZone(schedule.s_start_date)%>
						</select>
						
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
					<td class="campaign_header" nowrap>
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
						(EST)
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

</table>


		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block5_Step2" style="display:none;">
	<tr>
		<td class="" valign="top" align="center" width="650"<%= step4_colspan %>>


<script language="javascript">
	
	function toggleSection(obj, sec)
	{
		var tItem = document.getElementById(sec);
		if (tItem.style.display == "none")
		{
			tItem.style.display = "";
			obj.innerText = "Hide Additional Options";
		}
		else
		{
			tItem.style.display = "none";
			obj.innerText = "Additional Options";
		}
	}
	
</script>

<%
if( camp.s_type_id.equals("2") )
{
%>
	<input type="hidden" name="queue_daily_flag" value="<%=HtmlUtil.escape(camp_send_param.s_queue_daily_flag)%>">
	<table class="" cellspacing="0" cellpadding="2" width="100%">
		<tr<%=(camp_send_param.s_queue_daily_flag!=null)?" style='display: none'":""%>>
			<td width="150" class="campaign_header" valign="middle">Queue Start Date </td>
			<td width="500">
				<table>
					<tr>
						<td class="campaign_header">
							<input name="queue_date_switch" value="now" id="queue_date_switch_now" type="radio"<%=((camp_send_param.s_queue_date==null)?" checked":"")%>><label for="queue_date_switch_now">&nbsp;Now</label>&nbsp;
						</td>
						<td class="campaign_header" nowrap align="left">
							<input name="queue_date_switch" value="" id="queue_date_switch_specified" type="radio"<%=((camp_send_param.s_queue_date!=null)?" checked":"")%>><label for="queue_date_switch_specified">&nbsp;Specific date:</label>&nbsp; 
							<select name="queue_date_year" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getYearOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_month" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getMonthOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_day" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getDayOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_hour" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getHourOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							(EST)
							<input name="queue_date" type="hidden" value="">
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr<%=(camp_send_param.s_queue_daily_flag==null)?" style='display: none'":""%>>
			<td align="left" valign="middle">
				When queuing: 
				<% int nQWeekdayMask = Integer.parseInt(camp_send_param.s_queue_daily_weekday_mask); %>
			</td>
			<td>
				<table cellspacing="0" cellpadding="1" border="0">
					<tr>
						<td class="campaign_header">
							start at: 
							<select name=queue_daily_hour>
								<%=getHourOptionsHtml(camp_send_param.s_queue_daily_time)%>
							</select>
							<input name="queue_daily_time" type="hidden" value="">&nbsp;
							<a href="javascript:void(0);" onclick="toggleSection(this, 'queue_adv');" class="button_res">Additional Options</a>
						</td>
					</tr>
					<tr id="queue_adv" style="display:none;">
						<td>
							<table cellspacing="0" cellpadding="1" border="0">
								<tr>
									<td align="left" valign="middle" rowspan="2">queue only on:</td>
									<td align="center" valign="bottom" width="30"><label for="q_wk_mon">Mon</label></td>
									<td align="center" valign="bottom" width="30"><label for="q_wk_tue">Tue</label></td>
									<td align="center" valign="bottom" width="30"><label for="q_wk_wed">Wed</label></td>
									<td align="center" valign="bottom" width="30"><label for="q_wk_thu">Thu</label></td>
									<td align="center" valign="bottom" width="30"><label for="q_wk_fri">Fri</label></td>
									<td align="center" valign="bottom" width="30"><label for="q_wk_sat">Sat</label></td>
									<td align="center" valign="bottom" width="30"><label for="q_wk_sun">Sun</label></td>
								</tr>
								<tr>
									<td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_mon" type="checkbox" value="2"<%=((nQWeekdayMask&2)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_tue" type="checkbox" value="4"<%=((nQWeekdayMask&4)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_wed" type="checkbox" value="8"<%=((nQWeekdayMask&8)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_thu" type="checkbox" value="16"<%=((nQWeekdayMask&16)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_fri" type="checkbox" value="32"<%=((nQWeekdayMask&32)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_sat" type="checkbox" value="64"<%=((nQWeekdayMask&64)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_sun" type="checkbox" value="1"<%=((nQWeekdayMask&1)>0)?" checked":""%>></td>
								</tr>
							</table>
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
	<table class="" cellspacing="0" cellpadding="2" width="100%">
		<tr>
			<td width="150" class="campaign_header">Queue Start Date </td>
			<td width="500">
				<table>
					<tr>
						<td class="campaign_header">
							<input name="queue_date_switch" value="now" id="queue_date_switch_now" type="radio"<%=((camp_send_param.s_queue_date==null)?" checked":"")%>><label for="queue_date_switch_now">&nbsp;Now</label>&nbsp;
						</td>
						<td nowrap align="left" class="campaign_header">
							<input name="queue_date_switch" value="" id="queue_date_switch_specified" type="radio"<%=((camp_send_param.s_queue_date!=null)?" checked":"")%>><label for="queue_date_switch_specified">&nbsp;Specific date:</label>&nbsp; 
							<select name="queue_date_year" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getYearOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_month" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getMonthOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_day" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getDayOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_hour" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
								<%=getHourOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							(EST)
							<input name="queue_date" type="hidden" value="">
						</td>
					</tr>
				</table>
			</td>
		</tr>
<%	if( camp.s_type_id.equals("5") ) { %>
				<input type="hidden" name="delay" value="0">		
				<input type="hidden" name="day_delay" size=4 value="0">
				<input type="hidden" name="hour_delay" size=4 value="0">
<%	} else { %>
		<tr>
			<td width="150">Send delay (optional)</td>
			<td width="500">
				<input type="hidden" name="delay" value="<%=camp_send_param.s_delay%>">		
				<input type="text" name="day_delay" size=4 value="0">
				Days
				&nbsp;
				<input type="text" name="hour_delay" size=4 value="0">
				Hours
				&nbsp;&nbsp;&nbsp;
				(0 means ASAP)
			</td>
		</tr>
<%
	}
}
%>
		<tr>
			<td width="150" align="left" valign="middle" class="campaign_header" nowrap>
				When sending:
				<% int nSWeekdayMask = Integer.parseInt(schedule.s_start_daily_weekday_mask); %>
				<input name="start_daily_weekday_mask" type="hidden" value="0">
			</td>
			<td width="500">
				<table cellspacing="0" cellpadding="1" border="0">
					<tr>
						<td class="campaign_header">
							start at:
							<select name=start_daily_hour>
								<%=getHourOptionsHtml(schedule.s_start_daily_time)%>
								<option<%=((schedule.s_start_daily_time==null)?" selected":"")%>>any time</option>
							</select>&nbsp;
                            <a href="javascript:void(0);" onclick="toggleSection(this, 'start_adv');" class="button_res">Additional Options</a>
                        </td>
					</tr>
					<tr id="start_adv" style="display:none;">
						<td>
							<table cellspacing="0" cellpadding="1" border="0" width="400">
								<tr>
									<td align="left" valign="middle" nowrap rowspan="2">send only on:</td>
									<td align="center" valign="bottom" width="30"><label for="wk_mon">Mon</label></td>
									<td align="center" valign="bottom" width="30"><label for="wk_tue">Tue</label></td>
									<td align="center" valign="bottom" width="30"><label for="wk_wed">Wed</label></td>
									<td align="center" valign="bottom" width="30"><label for="wk_thu">Thu</label></td>
									<td align="center" valign="bottom" width="30"><label for="wk_fri">Fri</label></td>
									<td align="center" valign="bottom" width="30"><label for="wk_sat">Sat</label></td>
									<td align="center" valign="bottom" width="30"><label for="wk_sun">Sun</label></td>
								</tr>
								<tr>
									<td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_mon" type="checkbox" value="2"<%=((nSWeekdayMask&2)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_tue" type="checkbox" value="4"<%=((nSWeekdayMask&4)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_wed" type="checkbox" value="8"<%=((nSWeekdayMask&8)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_thu" type="checkbox" value="16"<%=((nSWeekdayMask&16)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_fri" type="checkbox" value="32"<%=((nSWeekdayMask&32)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_sat" type="checkbox" value="64"<%=((nSWeekdayMask&64)>0)?" checked":""%>></td>
									<td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_sun" type="checkbox" value="1"<%=((nSWeekdayMask&1)>0)?" checked":""%>></td>
								</tr>
								<tr>
									<td align="left" valign="middle" nowrap>and only send until: </td>
									<td colspan="7" width="100%">
										<select name=end_daily_hour>
											<%=getHourOptionsHtml(schedule.s_end_daily_time)%>
											<option<%=((schedule.s_end_daily_time==null)?" selected":"")%>>end of the day</option>
										</select>
										<input name="start_daily_time" type="hidden" value="">
										<input name="end_daily_time" type="hidden" value="">				
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>

<%	if (camp.s_type_id.equals("2")) { %>
        <% if (!isPrintCampaign) { %>
		<tr>
			<td align="left" class="campaign_header" valign="middle">
				Stop sending:
			</td>
			<td align="left" valign="middle">
				<table cellspacing="0" cellpadding="1" border="0">
					<tr>
						<td class="campaign_header">
							<input name="end_date_switch" value="never" id="end_date_switch_never" type="radio"<%=((schedule.s_end_date==null)?" checked":"")%>>
							<label for="end_date_switch_never">When All Messages Are Sent</label>
						</td>
					</tr>
					<tr>
						<td class="campaign_header">
							<input name="end_date_switch" value="" id="end_date_switch_specified" type="radio"<%=((schedule.s_end_date!=null)?" checked":"")%>>						
							<label for="end_date_switch_specified">End on a Specific Date:</label>
							<select name=end_date_year onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
								<%=getYearOptionsHtml(schedule.s_end_date)%>
							</select>
							<select name=end_date_month onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
								<%=getMonthOptionsHtml(schedule.s_end_date)%>
							</select>
							<select name=end_date_day onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
								<%=getDayOptionsHtml(schedule.s_end_date)%>
							</select>
							<select name=end_date_hour onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
								<%=getHourOptionsHtml(schedule.s_end_date)%>
							</select>
							(EST)
							<input name="end_date" type="hidden" value="">
						</td>
					</tr>
				</table>
			</td>
		</tr>
        <% } %>
		<tr<%=(camp_send_param.s_queue_daily_flag==null)?" style='display: none'":""%>>
			<td>&nbsp;</td>
			<td align="left" valign="middle">
				<input type="checkbox" id="msg_per_recip_limit" name="msg_per_recip_limit"<%=(camp_send_param.s_msg_per_recip_limit==null)?"":" checked"%>>
				<label for="msg_per_recip_limit">Allow recipients to participate many times in the campaign</label>
			</td>
		</tr>
        <% if (isPrintCampaign) { %>
				<input type="hidden" size="8" name="limit_per_hour" value="0">
        <% } else { %>
		<tr>
			<td>&nbsp;</td>
			<td class="campaign_header">
				Maximum Sent Out Per Hour
				&nbsp;&nbsp;
				<input type="text" size="8" name="limit_per_hour" value="<%=HtmlUtil.escape(camp_send_param.s_limit_per_hour)%>">
				(0 for no limit)
			</td>
		</tr>	
        <% } %>
<%	} %>
	</table>

		</td>
	</tr>
	
	
	</tbody>
	<tbody>
	<tr>
			<td align=center colspan="2" style="padding:10px;">
			<%
			if( !isDone && !isSending && !isTesting && !isPending && (!isPendingEdits || (isPendingEdits && isApprover)) && can.bExecute)
			{
				%>
				<a class="buttons-action" href="javascript:send();">Start Campaign</a>
				<%
			}
			%>
			</td>
		</tr>	
	<tbody>
</table>

