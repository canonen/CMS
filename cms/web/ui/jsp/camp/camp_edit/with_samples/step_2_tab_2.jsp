<table class="listTable" cellspacing="1" cellpadding="2" width="100%">
    <% if (!isPrintCampaign && camp_sampleset.s_reply_to_flag == null) { %>
	<tr<%=((STANDARD_UI)?"style=' display: none'":"")%>>
		<td width="150" height="25">Reply To</td>
		<td width="400" height="25">
			<input type="text" name="reply_to" value="<%=HtmlUtil.escape(msg_header.s_reply_to)%>" size="40" maxlength="255">
	        <a class="resourcebutton" href="javascript:pers_popup()">Personalize</a>
		</td>
	</tr>
    <% } %>
	<tr>
		<td width="150" height="25">Seed List (optional)</td>
		<td width="400" height="25">
			<select name="seed_list_id" size="1">
				<option value="">-----  Do not use a seed list  -----</option>
				<%=getFilterOptionsHtml(stmt, cust.s_cust_id, camp.s_seed_list_id, sSelectedCategoryId)%>
			</select>
		</td>
	</tr>
	<tr <%=(isPrintCampaign?"style=\"display:none;\"":"")%> >
		<td width="150" height="25">
			<%= STANDARD_UI?"Link to a Send-to-Friend":"Link to a Send-to-Friend or Auto-Respond Campaign" %>
		</td>
		<td width="400" height="25">
			<select name="linked_camp_id" size="1">
				<option value="">-----  Choose Campaign -----</option>
				<%String sLinkedcampTypes = ((STANDARD_UI)?"3":"3,4");%>
				<%=getLinkedCampOptionsHtml(stmt, cust.s_cust_id, linked_camp.s_linked_camp_id, sSelectedCategoryId, sLinkedcampTypes)%>
			</select>
		</td>
	</tr>
<%
boolean nonEmailFinger = false;
sSql = 
	" SELECT attr_name" +
	" FROM ccps_attribute a, ccps_cust_attr c " +
	" WHERE a.attr_id = c.attr_id" +
	" AND c.cust_id = " + cust.s_cust_id +
	" AND fingerprint_seq IS NOT NULL";
	
rs = stmt.executeQuery(sSql);
while (rs.next()) if (!rs.getString(1).equals("email_821")) nonEmailFinger = true;
rs.close();

if (nonEmailFinger)
{
	%>
	<tr <%=(isPrintCampaign?"style=\"display:none;\"":"")%> >
		<td colspan="2">
			For duplicate email addresses send to only one:
			<input type="checkbox" name="msg_per_email821_limit"<%=("0".equals(camp_send_param.s_msg_per_email821_limit)?"":" checked")%>>
		</td>
	</tr>
	<%
}

CustFeature cs = new CustFeature();
boolean bFeat = false;
bFeat = cs.exists(user.s_cust_id, Feature.BRITE_TRACK);
%>
    <% if (!isPrintCampaign) { %>
	<tr>
		<td width="150" height="25">Text to append to tracking links</td>
		<td width="400" height="25">
			<input type="text" name="link_append_text" value="<%= HtmlUtil.escape(camp_send_param.s_link_append_text) %>" size="60" maxlength="255">
	        <a class="resourcebutton" href="javascript:pers_popup()">Personalize</a>
		<%
		if (bFeat)
		{
			%>
			<br><br>
			<a href="javascript:addBriteTrack();" class="resourcebutton">Add RevoTrack</a>
			<%
		}
		%>
		</td>
	</tr>
	<tr>
		<td width="150" height="25">Campaign Code</td>
		<td width="400" height="25">
			<input type="text" name="camp_code" value="<%= HtmlUtil.escape(camp.s_camp_code) %>" size="60" maxlength="255">					
		</td>
	</tr>
    <% } %>
</table>
