<TABLE class="main" cellspacing="1" cellpadding="5" width="100%">
	<TR>
		<TD WIDTH="150" HEIGHT="25">Campaign: </TD>
		<TD WIDTH="400" HEIGHT="25"><%=HtmlUtil.escape(camp.s_camp_name)%></TD>
	</TR>
	<TR>
		<TD WIDTH="150" HEIGHT="25"><%=(isDynamicCampaign?"Default":"") %> Target Group: </TD>
		<TD WIDTH="400" HEIGHT="25"><%=HtmlUtil.escape(filter.s_filter_name)%></TD>
	</TR>

	<TR>
		<TD WIDTH="150" HEIGHT="25"># of recipients in <%=(isDynamicCampaign?"Default":"") %> Target Group: </TD>
		<TD WIDTH="400" HEIGHT="25">
		<%
		if(filter_statistic.s_finish_date!=null)
		{
			%>
			<%= filter_statistic.s_recip_qty %>&nbsp;&nbsp;<font color="red"><b>(Based on the <%=(isDynamicCampaign?"Default":"") %> Target Group's last update information)</b></font>
			<%
		}
		else
		{
			%>
			<font color="red"><b>Unknown - Target Group has not been updated</b></font>
			<%
		}
		%>
		</TD>
	</TR>
</TABLE>
