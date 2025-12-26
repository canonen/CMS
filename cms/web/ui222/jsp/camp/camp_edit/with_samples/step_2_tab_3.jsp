
	<table class="main" cellspacing="1" cellpadding="2" width="100%">
		<tr <%=(isPrintCampaign?"style=\"display:none;\"":"")%> >
			<td width="150" height="25">Exclusion List</td>
			<td width="400" height="25">
				<select name="exclusion_list_id" size="1">
					<option value="">----- Choose exclusion list -----</option>
					<%=getExclusionListOptionsHtml(stmt, cust.s_cust_id, camp_list.s_exclusion_list_id)%>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				Exclude recipients who have received a campaign in the previous 
				<input type="text" name="camp_frequency" size="5" value="<%=HtmlUtil.escape(camp_send_param.s_camp_frequency)%>"> days.
			</td>
		</tr>
		<tr style="display:none;">
			<td width="150">Subset Sendout</td>
			<td width="400" height="25">
				<p>
					How many
					&nbsp;
					<input type="text" size="9" name="recip_qty_limit" value="<%=HtmlUtil.escape(camp_send_param.s_recip_qty_limit)%>">
					&nbsp;
					<input type="checkbox" name="randomly" <%=("0".equals(camp_send_param.s_randomly)?"":" checked")%>>
					Randomly
				</p>
			</td>
		</tr>
        <% if (!isPrintCampaign) { %>
		<tr>
			<td width="150">Maximum Sent Out Per Hour<br>(0 for no limit)</td>
			<td width="400" height="25">
				<input type="text" size="8" name="limit_per_hour" value="<%=HtmlUtil.escape(camp_send_param.s_limit_per_hour)%>">
			</td>
		</tr>	
        <% } %>
	</table>