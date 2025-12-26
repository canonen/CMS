<table class="listTable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td width="150">Queue Start Date </td>
		<td width="400">
			<table>
				<tr>
					<td width="25%">
						<input name="queue_date_switch" id="queue_date_switch_now" value="now" type="radio"<%=((camp_send_param.s_queue_date==null)?" checked":"")%>>&nbsp;Now&nbsp;
					</td>
					<td nowrap>
						<input name="queue_date_switch" id="queue_date_switch_specified" value="" type="radio"<%=((camp_send_param.s_queue_date!=null)?" checked":"")%>>&nbsp;Specific date:&nbsp; 
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
						<!--(EST)-->
						<input name="queue_date" type="hidden" value="">
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>