<table class="main" cellspacing="1" cellpadding="1" width="100%">
	<tr>
		<td width="150" height="25">
			Choose Variables
		</td>
		<td height="25">
            <% if (!isPrintCampaign) { %>
			<input type="checkbox" name="from_name_flag" value="1"<%=((cs.s_from_name_flag!=null)?" checked":"")%>>From Name<br>
			<input type="checkbox" name="from_address_flag" value="1"<%=((cs.s_from_address_flag!=null)?" checked":"")%>>From Address<br>
			<input type="checkbox" name="subject_flag" value="1"<%=((cs.s_subject_flag!=null)?" checked":"")%>>Subject<br>
			<% if (isDynamicCampaign) { %>			
			<input type="checkbox" name="reply_to_flag" value="1"<%=((cs.s_reply_to_flag!=null)?" checked":"")%>>Reply To<br>
            <% } %>
            <% } %>
			<input type="checkbox" name="cont_flag" value="1"<%=((cs.s_cont_flag!=null)?" checked":"")%>>Content<br>
			<input type="checkbox" name="send_date_flag" value="1"<%=((cs.s_send_date_flag!=null)?" checked":"")%>>Send Date<br>
		</td>
	</tr>
</table>
