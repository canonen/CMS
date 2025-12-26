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
    <% } else { %>
	<tr>
		<td width="150" height="25">From Name</td>
		<td width="400" height="25">
			<input type="text" name="from_name" value="<%=HtmlUtil.escape(msg_header.s_from_name)%>" size="25" maxlength="255">
			<% if (canFromNamePers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
		</td>
	</tr>
	<tr>
		<td width="150" height="25">From Address</td>
		<td width="400" height="25">
			<table cellspacing="1" cellpadding="1" border="0" width="400">
				<tr>
					<td>
						<nobr>
						<%=(canFromAddrPers)?"":"<div name='divfa1' style='display:none'>"%>
						<input type="radio" name="fa1" onClick="checkFrom(this)"<%=msg_header.s_from_address==null?" checked":""%>>
						<%=(canFromAddrPers)?"":"</div>"%>
						<select name="from_address_id" size="1" onClick="checkFrom(FT.fa1)">
							<option value="">-----  Choose address  -----</option>
							<%=getFromAddressOptionsHtml(stmt, cust.s_cust_id, msg_header.s_from_address_id)%>
						</select>
						</nobr>
					</td>
				</tr>
				<tr<%=(canFromAddrPers)?"":" style='display:none'"%>>
					<td>
						<nobr>
						<input type="radio" name="fa2" onClick="checkFrom(this)"<%=msg_header.s_from_address!=null?" checked":""%>>
						<input type="text" name="from_address" value="<%=HtmlUtil.escape(msg_header.s_from_address)%>" size="25" maxlength="255" onClick="checkFrom(FT.fa2)">
						<% if (canFromAddrPers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
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
				<% if (canSubjectPers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
		</td>
	</tr>
    <% } %>
	<tr>
		<td width="150" height="25">Content	</td>
		<td width="400" colspan="2" height="25">
			<select name="cont_id" size="1">
				<option value="">-----  Choose content  -----</option>
				<%=getContOptionsHtml(stmt, cust.s_cust_id, camp.s_cont_id, sSelectedCategoryId, isPrintCampaign)%>
			</select>
			&nbsp;&nbsp;
			<a class="resourcebutton" href="javascript:dynamic_popup(FT.cont_id[FT.cont_id.selectedIndex].value);">Preview</a>
            <% if (!isPrintCampaign) { %>
			&nbsp;&nbsp;
     	    <a class="resourcebutton" href="javascript:score_popup(FT.cont_id[FT.cont_id.selectedIndex].value);">Score</a>
            <% } %>
		</td>
	</tr>
<%
if (camp.s_type_id.equals("3")) 
{
	%>
	<tr>
		<td width="150" height="25"><input type="radio" name="fr1" onclick="setFormFlag(this,'1');">Form</td>
		<td width="400" height="25">
			<select name="form_id" size="1" onchange="setFormFlag(FT.fr1,'1');">
				<option value="">-----  Choose Form  -----</option>
			<%
			sSql = 
				" SELECT form_id, form_name" +
				" FROM csbs_form" +
				" WHERE cust_id = " + cust.s_cust_id +
				" AND type_id = 3 ORDER BY form_id";
			
			String sFormId = null;	
			rs = stmt.executeQuery(sSql);
			while( rs.next() )
			{
				sFormId = rs.getString(1);
				%>
				<option value="<%=sFormId%>" <%= ((sFormId.equals(linked_camp.s_form_id))?" selected":"") %>>
					<%= HtmlUtil.escape(new String(rs.getBytes(2),"UTF-8")) %>
				</option>
				<%
			}
			%>
			</select>
		</td>
	</tr>
	<%
}
%>
<% } %>
	<tr>
		<td width="150" height="25">
		<%
		if(camp.s_type_id.equals("3"))
		{
			%>
			<input type=radio name="fr2" onClick="setFormFlag(this,'0');">
			<%
		}
		%>
			Target Group
		</td>
		<td width="400" height="25" nowrap>
			<select name="filter_id" size="1" <%=(camp.s_type_id.equals("3"))?"onChange=\"setFormFlag(FT.fr2,'0');\"":""%>>
				<option value="">-----  Choose target group  -----</option>
				<%=getFilterOptionsHtml(stmt, cust.s_cust_id, camp.s_filter_id, sSelectedCategoryId)%>
			</select>
			<% if (canTGPreview) { %>
			&nbsp;&nbsp;
			<a class="resourcebutton" href="javascript:targetgroup_popup(FT.filter_id[FT.filter_id.selectedIndex].value);">Preview</a>
			<% } %>
		</td>
	</tr>
<% if (camp.s_type_id.equals("5") || isPrintCampaign) { %>
			<input type="hidden" name="response_frwd_addr"  size="40" maxlength="255" value="">
<% } else { %>
	<tr>
		<td width="150" height="25">Response Forwarding</td>
		<td width="400" height="25">
			<input type="text" name="response_frwd_addr"  size="40" maxlength="255" value="<%= HtmlUtil.escape(camp_send_param.s_response_frwd_addr) %>"<%=(isHyatt?" onChange=\"FT.reply_to.value=this.value\"":"")%>>
		</td>
	</tr>
<% } %>
<%
if (camp.s_type_id.equals("4"))
{
    if (isPrintCampaign) { %>
			<input type="hidden" id="ar_send_type_0" name="ar_send_type" value="0" checked>
			<input type="hidden" id="ar_send_type_1" name="ar_send_type" value="1">
<%  } else {
	%>
	<tr>
		<td width="150" height="25">Send Email To</td>
		<td width="400" height="25">
			<input type="radio" id="ar_send_type_0" name="ar_send_type" value="0" checked>The Subscriber (Confirmation Email)<br>
			<input type="radio" id="ar_send_type_1" name="ar_send_type" value="1">Emails On This List: (One email per subscriber or email everyone on the list)<br>&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="auto_respond_list_id">
				<option value="">--- Choose a Notification List ----</option>
			<%
			sSql =
				" SELECT list_id, CASE status_id WHEN " + EmailListStatus.DELETED + " THEN '*Deleted* ' + list_name ELSE list_name END, " + 
				" status_id, type_id" +
				" FROM cque_email_list " +
				" WHERE type_id IN (4,6)" +
				" AND cust_id =" + cust.s_cust_id +
				" AND (status_id = '" + EmailListStatus.ACTIVE + "'" +
				((camp_list.s_auto_respond_list_id!=null)?" OR list_id = " + camp_list.s_auto_respond_list_id:"") +
				") ORDER BY list_id DESC";
			
			String sArListId = null;
			String sArListName = null;
			String sStatusID = null;
			String sTypeID = null;
			int iStatusID = 0;
			
			rs = stmt.executeQuery(sSql);
			
			while(rs.next())
			{ 
				sArListId = rs.getString(1);
				sArListName = new String(rs.getBytes(2),"UTF-8");
				sStatusID = rs.getString(3);
				sTypeID = rs.getString(4);
		
				iStatusID = Integer.parseInt(sStatusID);
				%>
				<option value="<%= ((iStatusID == EmailListStatus.DELETED)?"":sArListId) %>" <%=((sArListId.equals(camp_list.s_auto_respond_list_id))?" selected":"")%>>
					<%= HtmlUtil.escape(sArListName) %>
					(<%= (sTypeID.equals("4"))?"One per subscriber":"Everyone on the list" %>)
				</option>
				<%
			}
			rs.close();
			%>
			</select>
			<br>

			<input type="radio" id="ar_send_type_2" name="ar_send_type" value="2">One Email: 
			<input type="text" size="30" name="ar_send_list_one_email">
			<select name="ar_send_list_one_type">
			<%
			sSql =
				" SELECT email_type_id, email_type_name" +
				" FROM ccps_email_type WHERE email_type_id <> 0";
			rs = stmt.executeQuery(sSql);
			while(rs.next())
			{
				%>
				<option value=<%=rs.getString(1)%>><%=rs.getString(2)%></option>
				<%
			}
			%>
			</select>
			<br>
			<input type="radio" id="ar_send_type_3" name="ar_send_type" value="3">Email from an attribute: 
			<select name="auto_respond_attr_id">
			<%
			sSql =
				" SELECT attr_id, display_name " +
				" FROM ccps_cust_attr" +
				" WHERE cust_id = " + cust.s_cust_id +
				" AND display_seq IS NOT NULL " +
				" ORDER BY display_seq";

			String sArAttrId = null;
			rs = stmt.executeQuery(sSql);
			while (rs.next())
			{
				sArAttrId = rs.getString(1);
				%>
				<option value="<%=sArAttrId%>"<%=sArAttrId.equals(camp_list.s_auto_respond_attr_id)?" selected":""%>>
					<%=HtmlUtil.escape(new String(rs.getBytes(2),"UTF-8"))%>
				</option>
				<%
			}
			%>
			</select>
		</td>
	</tr>
	<%
    }
}
%>
</table>
