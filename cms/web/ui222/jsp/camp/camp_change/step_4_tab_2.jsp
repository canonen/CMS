<%
if( camp.s_type_id.equals("2") )
{
%>
	<input type="hidden" name="queue_daily_flag" value="<%=HtmlUtil.escape(camp_send_param.s_queue_daily_flag)%>">
	<table class="main" cellspacing="1" cellpadding="2" width="100%">
		<tr<%=(camp_send_param.s_queue_daily_flag!=null)?" style='display: none'":""%>>
			<td width="150" valign="middle">Queue Start Date </td>
			<td width="400">
				<table>
					<tr>
						<td>
							<input name="queue_date_switch" value="now" type="radio"<%=((camp_send_param.s_queue_date==null)?" checked":"")%>>&nbsp;Now&nbsp;
						</td>
						<td nowrap align="left">
							<input name="queue_date_switch" value="" type="radio"<%=((camp_send_param.s_queue_date!=null)?" checked":"")%>>&nbsp;Specific date:&nbsp; 
							<select name="queue_date_year">
								<%=getYearOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_month">
								<%=getMonthOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_day">
								<%=getDayOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_hour">
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
			<td valign="middle" width="100%" colspan="2">
				<table cellspacing="0" cellpadding="2" border="0">
					<tr>
						<td align="left" valign="middle" colspan="2">

	<% int nWeekdayMask = Integer.parseInt(camp_send_param.s_queue_daily_weekday_mask); %>
	Queue and send on: 
	<input name="queue_daily_weekday_mask" type="checkbox" value="2"<%=((nWeekdayMask&2)>0)?" checked":""%>> Mon 
	<input name="queue_daily_weekday_mask" type="checkbox" value="4"<%=((nWeekdayMask&4)>0)?" checked":""%>> Tue 
	<input name="queue_daily_weekday_mask" type="checkbox" value="8"<%=((nWeekdayMask&8)>0)?" checked":""%>> Wed 
	<input name="queue_daily_weekday_mask" type="checkbox" value="16"<%=((nWeekdayMask&16)>0)?" checked":""%>> Thu 
	<input name="queue_daily_weekday_mask" type="checkbox" value="32"<%=((nWeekdayMask&32)>0)?" checked":""%>> Fri 
	<input name="queue_daily_weekday_mask" type="checkbox" value="64"<%=((nWeekdayMask&64)>0)?" checked":""%>> Sat 
	<input name="queue_daily_weekday_mask" type="checkbox" value="1"<%=((nWeekdayMask&1)>0)?" checked":""%>> Sun 

							&nbsp;&nbsp;&nbsp;
							at:
							<select name=queue_daily_hour>
								<%=getHourOptionsHtml(camp_send_param.s_queue_daily_time)%>
							</select>
							<input name="queue_daily_time" type="hidden" value="">
						</td>
					</tr>
					<tr>
						<td align="left" valign="middle" colspan="2">
						</td>
					</tr>
					<tr>
						<td align="left" valign="middle">
							<input name="end_date_switch" value="never" type="radio"<%=((schedule.s_end_date==null)?" checked":"")%>>
							Never End
						</td>
						<td align="left" valign="middle" nowrap>
							<input name="end_date_switch" value="" type="radio"<%=((schedule.s_end_date!=null)?" checked":"")%>>						
							End on a Specific Date:
							<select name=end_date_year>
								<%=getYearOptionsHtml(schedule.s_end_date)%>
							</select>
							<select name=end_date_month>
								<%=getMonthOptionsHtml(schedule.s_end_date)%>
							</select>
							<select name=end_date_day>
								<%=getDayOptionsHtml(schedule.s_end_date)%>
							</select>
							<select name=end_date_hour>
								<%=getHourOptionsHtml(schedule.s_end_date)%>
							</select>
							(EST)
							<input name="end_date" type="hidden" value="">
						</td>
					</tr>
					<tr>
						<td align="left" valign="middle" colspan="2">
							<input type="checkbox" name="msg_per_recip_limit"<%=(camp_send_param.s_msg_per_recip_limit==null)?"":" checked"%>>
							Allow recipients to participate many times in the campaign
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<%
}
else
{
	%>
	<table class="main" cellspacing="1" cellpadding="2" width="100%">
		<tr>
			<td width="150">Queue Start Date </td>
			<td width="400">
				<table>
					<tr>
						<td>
							<input name="queue_date_switch" value="now" type="radio"<%=((camp_send_param.s_queue_date==null)?" checked":"")%>>&nbsp;Now&nbsp;
						</td>
						<td nowrap align="left">
							<input name="queue_date_switch" value="" type="radio"<%=((camp_send_param.s_queue_date!=null)?" checked":"")%>>&nbsp;Specific date:&nbsp; 
							<select name="queue_date_year">
								<%=getYearOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_month">
								<%=getMonthOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_day">
								<%=getDayOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							<select name="queue_date_hour">
								<%=getHourOptionsHtml(camp_send_param.s_queue_date)%>
							</select>
							(EST)
							<input name="queue_date" type="hidden" value="">
						</td>
					</tr>
				</table>
			</td>
		</tr>
<% if( camp.s_type_id.equals("5") ) { %>
				<input type="hidden" name="delay" value="0">		
				<input type="hidden" name="day_delay" size=4 value="0">
				<input type="hidden" name="hour_delay" size=4 value="0">
<% } else { %>
		<tr>
			<td width="150">Send delay (optional)</td>
			<td width="400">
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
<% } %>
	</table>
<%
}
%>