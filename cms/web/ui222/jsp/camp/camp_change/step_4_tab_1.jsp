<table class="main" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td width="150" valign="middle">Send Start Date </td>
		<td width="400">
			<table cellspacing="0" cellpadding="2" border="0">
				<tr>
					<td width="25%">
						<input name="start_date_switch" value="now" type="radio"<%=((schedule.s_start_date==null)?" checked":"")%>>&nbsp;Now&nbsp;&nbsp;&nbsp;
					</td>
					<td nowrap>
						<input name="start_date_switch" value="" type="radio"<%=((schedule.s_start_date!=null)?" checked":"")%>>&nbsp;Specific date:&nbsp; 
						<select name="start_date_year">
							<%=getYearOptionsHtml(schedule.s_start_date)%>
						</select>
						<select name="start_date_month">
							<%=getMonthOptionsHtml(schedule.s_start_date)%>
						</select>
						<select name="start_date_day">
							<%=getDayOptionsHtml(schedule.s_start_date)%>
						</select>
						<select name="start_date_hour">
							<%=getHourOptionsHtml(schedule.s_start_date)%>
						</select>
						(EST)
						<input name="start_date" type="hidden" value="">
					</td>
				</tr>
			</table>
					</td>
	</tr>
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
						<input name="end_date_switch" value="never" type="radio"<%=((bEndDateNever)?" checked":"")%>>&nbsp;Never&nbsp;
					</td>
					<td nowrap>
						<input name="end_date_switch" value="" type="radio"<%=((!bEndDateNever)?" checked":"")%>>&nbsp;Specific date:&nbsp; 
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
</table>
<br>
<table class="main" cellspacing="1" cellpadding="4" border="0" width="100%">
	<tr>
		<td align="center" valign="middle" style="padding:10px;">
			<a class="actionbutton" href="#" onClick="update();" TARGET="_self">Re-Launch Campaign</a>
		</td>
	</tr>
</table>
