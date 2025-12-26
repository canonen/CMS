<%
nTabHeaderId = 0; nTabPageId = 0;

String sCalcCampID = null;
rs = stmt.executeQuery("SELECT max(camp_id) FROM cque_campaign"
		+ " WHERE type_id = "+CampaignType.TEST
		+ " AND status_id = "+CampaignStatus.DONE
		+ " AND mode_id = "+CampaignMode.CALC_ONLY
		+ " AND origin_camp_id = "+camp.s_camp_id);
		
if (rs.next()) sCalcCampID = rs.getString(1);
rs.close();

if ((!bIsDone && !isSending && !isTesting && !isPrintCampaign) || (sCalcCampID != null))
{
	%>
<table id="tab_<%=(++nTabId)%>" cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class="EmptyTab" align="center" nowrap valign="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>" >
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
	<%
	if ((!bIsDone && !isSending && !isTesting) && (can.bExecute))
	{
		%>
				<tr>
					<td>Calculate Recipient Statistics</td>
					<td valign=center style="padding:10px;">
						<a class="subactionbutton" href="javascript:send_calc();">Calculate Statistics ></a>
					</td>
				</tr>
		<%
	}
	
	if (sCalcCampID != null)
	{
		String sCalcDate = null;
		rs = stmt.executeQuery("SELECT convert(varchar(255), finish_date, 100) FROM cque_camp_statistic WHERE camp_id = "+sCalcCampID);
		if (rs.next()) sCalcDate = rs.getString(1);
		rs.close();
		%>	
				<tr>
					<td>Last Calculation Date: <%=sCalcDate%></td>
		<%
		CampStatDetails csds = new CampStatDetails();
		csds.s_camp_id = sCalcCampID;
		csds.retrieve();
		
		if(csds.size() != 0)
		{
			%>
					<td style="padding:10px;"><a href="javascript:showCampDetails('<%= sCalcCampID %>', 'stats');" class="resourcebutton">View Calculation Details</a></td>
			<%
		}
		else
		{
			%>
					<td style="padding:10px;">&nbsp;</td>
			<%
		}
		%>
				</tr>
		<%			
	}
	%>
			</table>
		</td>
	</tr>
	</tbody>
</table>
	<%
}
%>