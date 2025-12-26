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
	<table class="main" cellspacing="1" cellpadding="2" width="100%">
		<tr<%=(camp_send_param.s_queue_daily_flag!=null)?" style='display: none'":""%>>
			<td width="150" valign="middle">Queue Start Date </td>
			<td width="500">
				<table>
					<tr>
						<td>
							<input name="queue_date_switch" value="now" id="queue_date_switch_now" type="radio"<%=((camp_send_param.s_queue_date==null)?" checked":"")%>><label for="queue_date_switch_now">&nbsp;Now</label>&nbsp;
						</td>
						<td nowrap align="left">
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
						<td>
							start at: 
							<select name=queue_daily_hour>
								<%=getHourOptionsHtml(camp_send_param.s_queue_daily_time)%>
							</select>
							<input name="queue_daily_time" type="hidden" value="">&nbsp;
							<a href="javascript:void(0);" onclick="toggleSection(this, 'queue_adv');" class="resourcebutton">Additional Options</a>
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
	<table class="main" cellspacing="1" cellpadding="2" width="100%">
		<tr>
			<td width="150">Queue Start Date </td>
			<td width="500">
				<table>
					<tr>
						<td>
							<input name="queue_date_switch" value="now" id="queue_date_switch_now" type="radio"<%=((camp_send_param.s_queue_date==null)?" checked":"")%>><label for="queue_date_switch_now">&nbsp;Now</label>&nbsp;
						</td>
						<td nowrap align="left">
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
			<td width="150" align="left" valign="middle" nowrap>
				When sending:
				<% int nSWeekdayMask = Integer.parseInt(schedule.s_start_daily_weekday_mask); %>
				<input name="start_daily_weekday_mask" type="hidden" value="0">
			</td>
			<td width="500">
				<table cellspacing="0" cellpadding="1" border="0">
					<tr>
						<td>
							start at:
							<select name=start_daily_hour>
								<%=getHourOptionsHtml(schedule.s_start_daily_time)%>
								<option<%=((schedule.s_start_daily_time==null)?" selected":"")%>>any time</option>
							</select>&nbsp;
                            <a href="javascript:void(0);" onclick="toggleSection(this, 'start_adv');" class="resourcebutton">Additional Options</a>
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
			<td align="left" valign="middle">
				Stop sending:
			</td>
			<td align="left" valign="middle">
				<table cellspacing="0" cellpadding="1" border="0">
					<tr>
						<td>
							<input name="end_date_switch" value="never" id="end_date_switch_never" type="radio"<%=((schedule.s_end_date==null)?" checked":"")%>>
							<label for="end_date_switch_never">When All Messages Are Sent</label>
						</td>
					</tr>
					<tr>
						<td>
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
			<td>
				Maximum Sent Out Per Hour
				&nbsp;&nbsp;
				<input type="text" size="8" name="limit_per_hour" value="<%=HtmlUtil.escape(camp_send_param.s_limit_per_hour)%>">
				(0 for no limit)
			</td>
		</tr>	
        <% } %>
<%	} %>
	</table>