<table class="main" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td width="150" height="25" nowrap>Number of <%=(isDynamicCampaign?"dynamic":"sample") %> campaigns to be created: </td>
		<td width="400" height="25" nowrap>
			<input type="text" size="3" name="camp_qty" value="<%= HtmlUtil.escape(cs.s_camp_qty) %>" onkeyup="updateCurrent();">
		</td>
	</tr>
	<tr style="display:<%=(isDynamicCampaign?"none":"inline") %>">
		<td WIDTH="150" align="left" valign="middle" rowspan="2">
			Sample campaigns will use:
		</td>
		<td align="left" valign="middle">
			<input type="radio" name="split_type" <%=(cs.s_recip_percentage!=null)?" checked":""%> onclick="switch_split_type();updateCurrent();">
			<input type="text"<%=(cs.s_recip_qty!=null)?" disabled":""%> name="recip_percentage" size=3 value="<%= HtmlUtil.escape(cs.s_recip_percentage) %>" onkeyup="updateCurrent();">
			% of target group, split evenly across <span id="num_camps_1"><%= HtmlUtil.escape(cs.s_camp_qty) %></span> sample campaigns
		</td>
	</tr>
	<tr style="display:<%=(isDynamicCampaign?"none":"inline") %>">
		<td align="left" valign="middle">
			<input type="radio" name="split_type" <%=(cs.s_recip_qty!=null)?" checked":""%> onclick="switch_split_type();updateCurrent();">
			<input type="text"<%=(cs.s_recip_percentage!=null)?" disabled":""%> name="recip_qty" size=10 value="<%= (filter_statistic.s_finish_date!=null)?filter_statistic.s_recip_qty:"0" %>" onkeyup="updateCurrent();">
			&nbsp; recipients from the target group, split evenly across <span id="num_camps_2"><%= HtmlUtil.escape(cs.s_camp_qty) %></span> sample campaigns
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<input type="checkbox" name="final_camp_flag" value="1"<%=((cs.s_final_camp_flag!=null)||(nRetrieve < 1))?" checked":""%> onClick="updateCurrent();">
			&nbsp;Also, create a Final Campaign and use the <%=(isDynamicCampaign?"un-matched recipients of default target group":"remainder of target group for that final campaign") %> 
		</td>
	</tr>
</table>
<br>
<table class="main" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td align="left" valign="middle" style="padding:5px;">
			<b> <%=(isDynamicCampaign?"Dynamic Campaigns":"Sample Sets") %> to be created:</b>
		<%
		if(filter_statistic.s_finish_date!=null)
		{
			//nothing
		}
		else
		{
			%>
			<br><font color="red"><b>Target Group has not been updated</b></font> - some calculations will not work with out updated target group counts
			<%
		}
		%>
		</td>
	</tr>
	<tr>
		<td align="left" valign="middle" style="padding:5px;">
		<span id="sample_sets_show">Please enter information above</span>
		</td>
	</tr>
</table>
<SCRIPT>

	function updateCurrent()
	{
		var camps = FT.camp_qty.value;

		num_camps_1.innerHTML = camps + "&nbsp;";
		num_camps_2.innerHTML = camps + "&nbsp;";

		var perc_recips = 0;
		var num_recips = 0;
		var recips_per_sample = 0;
		var final_camp = 0;
		var final_recips = 0;

		var total_recips = <%= (filter_statistic.s_finish_date!=null)?filter_statistic.s_recip_qty:"0" %>;
		var is_dynamic_campaign = <%= (isDynamicCampaign?"true":"false") %>
		perc_recips = new Number(FT.recip_percentage.value);
		num_recips = new Number(FT.recip_qty.value);

		if ((camps == "") || (camps == "0"))
		{
			sample_sets_show.innerHTML = "Please enter valid information above";
		}
		else
		{
			if ((FT.split_type[0].checked == true) && ((perc_recips > 100) || (perc_recips == 0) || (perc_recips == "")))
			{
				sample_sets_show.innerHTML = "Please enter valid information above";
			}
			else if ((FT.split_type[1].checked == true) && ((num_recips > total_recips) || (num_recips == 0) || (num_recips == "")))
			{
				sample_sets_show.innerHTML = "Please enter valid information above";
			}
			else
			{
				var showHTML = "";
				if (!is_dynamic_campaign)
				{
					showHTML = "Create " + camps + " sample campaigns";
				}
				else
				{
					showHTML = "Create " + camps + " dynamic campaigns";
				}
				if (FT.final_camp_flag.checked == true)
				{
					final_camp = 1;
				}

				if (FT.split_type[0].checked == true)
				{
					if (!is_dynamic_campaign)
					{
						showHTML += ", split across " + perc_recips + "% of the target group<br><br>";
						final_recips = (100 - perc_recips) + "%";
						recips_per_sample = new Number(perc_recips / camps).toFixed(2);
						for (i = 1; i <= camps; i++)
						{
							showHTML += "Sample #" + i + " will be sent to approx. " + recips_per_sample + "%<br>";
						}
					}
				}
				else
				{
					if (!is_dynamic_campaign) 
					{
						showHTML += ", split across " + num_recips + " recipients from the target group<br><br>";
					}
					final_recips = total_recips - num_recips;
					recips_per_sample = new Number(num_recips / camps).toFixed(0);
					for (i = 1; i <= camps; i++)
					{
						if (!is_dynamic_campaign) 
						{
							showHTML += "Sample #" + i + " will be sent to approx. " + recips_per_sample + " recipients<br>";
						}
					}
				}
				if (is_dynamic_campaign) 
				{
					showHTML += ", each use 100% of the dynamic target group that match the default target group";
				}
				
				if (final_camp == 1)
				{
					if (is_dynamic_campaign)
					{
						showHTML += "<br>A final campaign will be sent to the remaining recipients of the default target group";
					}
					else
					{ 
						if (FT.split_type[0].checked == true)
						{
							showHTML += "<br>A final campaign will be sent to the remaining " + final_recips + " of the target group";
						}
						else 
						{
							showHTML += "<br>A final campaign will be sent to the remaining " + final_recips + " recipients from the target group";
						}
					}
				}
				else
				{
					if (FT.split_type[0].checked == true)
					{
						showHTML += "<br>There will be <b>no</b> final campaign, meaning the remaining " + final_recips + " of the target group <b>will not be sent at all</b>";
					}
					else
					{
						showHTML += "<br>There will be <b>no</b> final campaign, meaning the remaining " + final_recips + " recipients from the target group <b>will not be sent at all</b>";
					}
				}

				sample_sets_show.innerHTML = showHTML;
			}
		}
	}
	
	function switch_split_type()
	{
		FT.recip_qty.disabled = FT.split_type[0].checked;
		FT.recip_percentage.disabled = FT.split_type[1].checked;
	}
</SCRIPT>