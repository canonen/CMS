<table class="main" cellspacing="1" cellpadding="2" width="100%">
<% if (camp.s_type_id.equals("5")) { %>
	<input type="hidden" name="from_name" value="">
	<input type="hidden" name="from_address_id" value="">
	<input type="hidden" name="from_address" value="">
    <input type="hidden" name="subj_html" value="non-email">
	<input type="hidden" name="cont_id" value="">
	<input type="radio"  name="fa1" style="display:none">
	<input type="radio"  name="fa2" style="display:none">
<% } else { %>
    <% if (isPrintCampaign) { %>
	    <input type="hidden" name="from_name" value="">
    	<input type="hidden" name="from_address_id" value="">
	    <input type="hidden" name="from_address" value="">
        <input type="hidden" name="subj_html" value="non-email">
    	<input type="radio"  name="fa1" style="display:none">
	    <input type="radio"  name="fa2" style="display:none">
    <% } %>
    <% if (!isPrintCampaign) { %>
	<tr>
		<td width="150" height="25">From Name</td>
		<td width="400" height="25">
			<input type="text" name="from_name" value="<%=HtmlUtil.escape(msg_header.s_from_name)%>" size="25" maxlength="255">
			<a class="resourcebutton" href="javascript:pers_popup()">Personalize</a>
		</td>
	</tr>
	<tr>
		<td width="150" height="25">From Address</td>
		<td width="400" height="25">
			<table cellspacing="1" cellpadding="1" border="0" width="400">
				<tr>
					<td>
						<nobr>
						<input type="radio" name="fa1" onClick="checkFrom(this)"<%=msg_header.s_from_address==null?" checked":""%>>
						<select name="from_address_id" size="1" onClick="checkFrom(FT.fa1)">
							<option value="">-----  Choose address  -----</option>
							<%=getFromAddressOptionsHtml(stmt, cust.s_cust_id, msg_header.s_from_address_id)%>
						</select>
						</nobr>
					</td>
				</tr>
				<tr>
					<td>
						<nobr>
						<input type="radio" name="fa2" onClick="checkFrom(this)"<%=msg_header.s_from_address!=null?" checked":""%>>
						<input type="text" name="from_address" value="<%=HtmlUtil.escape(msg_header.s_from_address)%>" size="25" maxlength="255" onClick="checkFrom(FT.fa2)">
						<a class="resourcebutton" href="javascript:pers_popup()">Personalize</a>
						</nobr>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td width="150" height="25" nowrap>Subject</td>
		<td width="400" height="25">
			<input type="text" name="subj_html" value="<%=HtmlUtil.escape(msg_header.s_subject_html)%>" size="40" maxlength="150">
			<a class="resourcebutton" href="javascript:pers_popup()">Personalize</a>
		</td>
	</tr>
    <% } %>
<%
	if(ContUtil.isContSimple(camp.s_cont_id))
	{
%>
	<tr>
		<td width="150" height="25">Content	</td>
		<td width="400" colspan="2" height="25">
			<select name="cont_id" size="1">
				<option value="">-----  Choose content  -----</option>
				<%=getContOptionsHtml(stmt, cust.s_cust_id, camp.s_cont_id, sSelectedCategoryId, isPrintCampaign)%>
			</select>
			&nbsp;&nbsp;
			<a class="resourcebutton" href="javascript:dynamic_popup(document.all.item('cont_id')[document.all.item('cont_id').selectedIndex].value);">Preview</a>
            <% if (!isPrintCampaign) { %>
			&nbsp;&nbsp;
     	    <a class="resourcebutton" href="javascript:score_popup(document.all.item('cont_id')[document.all.item('cont_id').selectedIndex].value);">Score</a>
            <% } %>
		</td>
	</tr>
<%
	}
	else
	{
%>
	<input type="hidden" name="cont_id" value="<%= camp.s_cont_id %>">
<%	
	}
}
%>
<% if (isPrintCampaign || camp.s_type_id.equals("5")) { %>
			<input type="hidden" name="response_frwd_addr"  size="40" maxlength="255" value="">
<% } else { %>
	<tr>
		<td width="150" height="25">Response Forwarding</td>
		<td width="400" height="25">
			<input type="text" name="response_frwd_addr"  size="40" maxlength="255" value="<%= HtmlUtil.escape(camp_send_param.s_response_frwd_addr) %>"<%=(isHyatt?" onChange=\"FT.reply_to.value=this.value\"":"")%>>
		</td>
	</tr>
<% } %>
<% if (!isPrintCampaign && canStep2) { %>
	<tr>
		<td width="150" height="25">Reply To</td>
		<td width="400" height="25">
			<input type="text" name="reply_to" value="<%= HtmlUtil.escape(msg_header.s_reply_to) %>" size="40" maxlength="255">
		</td>
	</tr>
<% } %>
<% if ((!isPrintCampaign && canStep2) && (camp.s_type_id.equals("2"))) { %>
	<tr>
		<td width="150">Maximum Sent Out Per Hour<br>(0 for no limit)</td>
		<td width="400" height="25">
			<input type="text" size="8" name="limit_per_hour" value="<%=HtmlUtil.escape(camp_send_param.s_limit_per_hour)%>">
		</td>
	</tr>
<% } %>

</table>

