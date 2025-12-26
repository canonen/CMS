<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">

<table class="camp-single-form" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle" class="campaign_header" width="1%"> Campaign Name </td>
		<td><input TYPE="text" class="inputtexts" NAME="camp_name" value="<%= camp.s_camp_name %>" SIZE="40" MAXLENGTH="50" <% if (camp.s_type_id.equals("5") || isPrintCampaign ) { %>onChange="if (document.all.export_name.value != null) { document.all.export_name.value = this.value; }" <% } %>></td>
	</tr>
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

<%
if (!STANDARD_UI && !isPrintCampaign)
{
%>
    <tbody<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
        <tr>
            <td align="left" valign="middle">Categories</TD>

            <td align="left" valign="middle">
                <select multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="4">
                    <%=buildCategoriesHtml(stmt, cust.s_cust_id, camp.s_camp_id, sSelectedCategoryId)%>
                </select>
                <%
                if(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0"))) { 
                %>
                <input type="hidden" name="categories" value="<%= sSelectedCategoryId %>">
                <%
                } 
                %>
                
        <%
            if( isDone && can.bWrite) {
        %>
        
            
            <a class="buttons-save" href="#" onClick="saveCategories();">Save Categories</a>
           
        <% 
        } 
        %>                
            </td>
       
        
        <!-- allow save category button if the campaign is done -->

         </tr>
        </tbody>    
    <% 
  } 
 %>                
        
	<tr>
		<td width="150" height="25" nowrap class="campaign_header">From Name</td>
		<td   height="25">
			<input class="inputtexts" type="text" name="from_name" value="<%=HtmlUtil.escape(msg_header.s_from_name)%>" size="25" maxlength="255">
			<% if (canFromNamePers) { %><a class="button_res" href="javascript:pers_popup()">Personalize</a><% } %>
		</td>
	</tr>
	<tr>
		<td width="150" height="25" class="campaign_header">From Address</td>
		<td   height="25" style=padding:0>
			<table cellspacing="0" cellpadding="0" border="0"  >
				<tr>
					<td style="border:none">
						<nobr>
						<%=(canFromAddrPers)?"":"<div name='divfa1' style='display:none'>"%>
						<input type="radio" name="fa1" onClick="checkFrom(this)"<%=msg_header.s_from_address==null?" checked":""%>>
						<%=(canFromAddrPers)?"":"</div>"%>
						<select class="styled-select" name="from_address_id" onClick="checkFrom(FT.fa1)">
							<option value="">-----  Choose address  -----</option>
							<%=getFromAddressOptionsHtml(stmt, cust.s_cust_id, msg_header.s_from_address_id)%>
						</select>
						</nobr>
					</td>
				</tr>
				<tr<%=(canFromAddrPers)?"":" style='display:none'"%>>
					<td  style="border:none">
						<nobr>
						<input type="radio" name="fa2" onClick="checkFrom(this)"<%=msg_header.s_from_address!=null?" checked":""%>>
						<input class="inputtexts" type="text" name="from_address" value="<%=HtmlUtil.escape(msg_header.s_from_address)%>" size="25" maxlength="255" onClick="checkFrom(FT.fa2)">
						<% if (canFromAddrPers) { %><a class="button_res" href="javascript:pers_popup()">Personalize</a><% } %>
						</nobr>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td width="150" height="25" nowrap class="campaign_header">Subject</td>
		<td   height="25">
			<input class="inputtexts" type="text" name="subj_html" value="<%=HtmlUtil.escape(msg_header.s_subject_html)%>" size="40" maxlength="150">
				<% if (canSubjectPers) { %><a class="button_res" href="javascript:pers_popup()">Personalize</a><% } %>
		</td>
	</tr>
    <% } %>
	<tr>
		<td width="150" height="25" class="campaign_header">Content	</td>
		<td   colspan="2" height="25">
			<select name="cont_id" size="1">
				<option value="">-----  Choose content  -----</option>
				<%=getContOptionsHtml(stmt, cust.s_cust_id, camp.s_cont_id, sSelectedCategoryId, isPrintCampaign)%>
			</select>
			&nbsp;&nbsp;
			<a class="button_res" href="javascript:dynamic_popup(FT.cont_id[FT.cont_id.selectedIndex].value);">Preview</a>
            <% if (!isPrintCampaign) { %>
			
     	    <a class="button_res" href="javascript:score_popup(FT.cont_id[FT.cont_id.selectedIndex].value);">Score</a><img src="/cms/ui/images/newyellow.png"/>
            <% } %>
		</td>
	</tr>
<%
if (camp.s_type_id.equals("3")) 
{
	%>
	<tr>
		<td width="150" height="25"><input type="radio" name="fr1" onclick="setFormFlag(this,'1');">Form</td>
		<td   height="25">
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
		<td width="150" height="25" class="campaign_header">
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
		<td   height="25" nowrap>
			<select name="filter_id" size="1" <%=(camp.s_type_id.equals("3"))?"onChange=\"setFormFlag(FT.fr2,'0');\"":""%>>
				<option value="">-----  Choose target group  -----</option>
				<%=getFilterOptionsHtml(stmt, cust.s_cust_id, camp.s_filter_id, sSelectedCategoryId)%>
			</select>
			<% if (canTGPreview) { %>
			&nbsp;&nbsp;
			<a class="button_res" href="javascript:targetgroup_popup(FT.filter_id[FT.filter_id.selectedIndex].value);">Preview</a>
			<% } %>
		</td>
	</tr>
<% if (camp.s_type_id.equals("5") || isPrintCampaign) { %>
			<input type="hidden" name="response_frwd_addr"  size="40" maxlength="255" value="">
<% } else { %>
	<tr>
		<td width="150" height="25" class="campaign_header">Response Forwarding</td>
		<td   height="25">
			<input class="inputtexts" type="text" name="response_frwd_addr"  size="40" maxlength="255" value="<%= HtmlUtil.escape(camp_send_param.s_response_frwd_addr) %>"<%=(isHyatt?" onChange=\"FT.reply_to.value=this.value\"":"")%>>
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
		<td>
			<table cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td style="border:none"><input type="radio" id="ar_send_type_0" name="ar_send_type" value="0" checked> The Subscriber (Confirmation Email)</td>
				</tr>
				<tr>
					<td style="border:none"><input type="radio" id="ar_send_type_1" name="ar_send_type" value="1"> Emails On This List: (One email per subscriber or email everyone on the list)</td>
				</tr>
				<tr>
					<td style="border:none"><select name="auto_respond_list_id">
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
			</td>
				</tr>
				<tr>
					<td style="border:none">
					
						<input type="radio" id="ar_send_type_2" name="ar_send_type" value="2"> One Email: 
									<input class="inputtexts" type="text" size="30" name="ar_send_list_one_email">
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
					</td>
				</tr>
				<tr>
					<td style="border:none">
								<input type="radio" id="ar_send_type_3" name="ar_send_type" value="3"> Email from an attribute: 
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
			</table>

			
		</td>
	</tr>
	<%
    }
}
%>

	<tr>
		<td width="" height="25" class="campaign_header">Reply To</td>
		<td width="" height="25"><input class="inputtexts" type="text" name="reply_to" value="<%= HtmlUtil.escape(msg_header.s_reply_to) %>" size="40" maxlength="255">
	        <a class="button_res" href="javascript:pers_popup()">Personalize</a>
		</td>
	</tr>
<%
if (!STANDARD_UI && !isPrintCampaign){

		if (!camp.s_type_id.equals("3")) //Seed List won't work with S2F since only sends to friend recips
		{
			%>
			<tr>
				<td width="" height="25" class="campaign_header">Seed List (optional)</td>
				<td width="" height="25">
					<select name="seed_list_id" size="1">
						<option value="">-----  Do not use a seed list  -----</option>
						<%=getFilterOptionsHtml(stmt, cust.s_cust_id, camp.s_seed_list_id, sSelectedCategoryId)%>
					</select>
				</td>
			</tr>
			<%
		}

		if(camp.s_type_id.equals("2") )
		{
			%>
			<tr <%=(isPrintCampaign?"style=\"display:none;\"":"")%> >
				<td width="150" height="25 "class="campaign_header">
					<%= STANDARD_UI?"Link to a Send-to-Friend":"Link to a Send-to-Friend or Auto-Respond Campaign" %>
				</td>
				<td width="" height="25">
					<select name="linked_camp_id" size="1">
						<option value="">-----  Choose Campaign -----</option>
						<%String sLinkedcampTypes = ((STANDARD_UI)?"3":"3,4");%>
						<%=getLinkedCampOptionsHtml(stmt, cust.s_cust_id, linked_camp.s_linked_camp_id, sSelectedCategoryId, sLinkedcampTypes)%>
					</select>
				</td>
			</tr>
			<%
		}

		if( camp.s_type_id.equals("4") )
		{
			%>
			<tr>
				<td colspan="2" class="campaign_header">
					Allow recipients to participate  many times in the campaign:
					<input type="checkbox" name="msg_per_recip_limit"<%=(camp_send_param.s_msg_per_recip_limit==null)?"":" checked"%>>
				</td>
			</tr>
			<%

		}

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

		CustFeature cs = new CustFeature();
		boolean bHyatt = false;
		bHyatt = cs.exists(user.s_cust_id, Feature.HYATT);
		if (nonEmailFinger)
		{
		 if (!bHyatt) {
			%>
			<tr <%=(isPrintCampaign?"style=\"display:none;\"":"")%> >
				<td colspan="2" class="campaign_header">
					For duplicate email addresses send to only one:
					<input type="checkbox" name="msg_per_email821_limit"<%=("0".equals(camp_send_param.s_msg_per_email821_limit)?"":" checked")%>>
				</td>
			</tr>
			<%
			} else {
			%>
			<tr <%=(isPrintCampaign?"style=\"display:none;\"":"")%> >
				<td colspan="2" class="campaign_header">
					For duplicate email addresses send to only one:
					     <input type="checkbox" name="msg_per_email821_limit"<%=("0".equals(camp_send_param.s_msg_per_email821_limit)?"checked":"")%>>
				</td>
			</tr>
		<%
			}
		}

		boolean bFeat = false;
		bFeat = cs.exists(user.s_cust_id, Feature.BRITE_TRACK);
		%>
		    <% if (!isPrintCampaign) { %>
			<tr>
				<td width="" height="25" class="campaign_header">Text to append to tracking links</td>
				<td width="" height="25">
					<input class="inputtexts" type="text" name="link_append_text" value="<%= HtmlUtil.escape(camp_send_param.s_link_append_text) %>" size="60" maxlength="255">
					<a class="button_res" href="javascript:pers_popup()">Personalize</a>
				<%
				if (bFeat)
				{
					%>
					<br><br>
					<a href="javascript:addBriteTrack();" class="button_res">Add RevoTrack</a>
					<%
				}
				%>
				</td>
			</tr>
			<tr>
				<td width="" height="25" class="campaign_header">Campaign Code</td>
				<td width="" height="25">
					<input class="inputtexts" type="text" name="camp_code" value="<%= HtmlUtil.escape(camp.s_camp_code) %>" size="60" maxlength="255">					
				</td>
			</tr>
		    <% } %>

   <% } %>



<%
if (canStep3)
{
	%>
		<tr <%=(isPrintCampaign?"style=\"display:none;\"":"")%> >
			<td width="150" height="25" class="campaign_header">Exclusion List</td>
			<td   height="25">
				<select name="exclusion_list_id" size="1">
					<option value="">----- Choose exclusion list -----</option>
					<%=getExclusionListOptionsHtml(stmt, cust.s_cust_id, camp_list.s_exclusion_list_id)%>
				</select>
			</td>
		</tr>
	<%
	if( !camp.s_type_id.equals("3") )
	{
		%>
		<tr>
			<td colspan="2" class="campaign_header" style="background-color:#f2f2f2">
				Exclude recipients who have received a campaign in the previous 
				<input style="width:70px" class="inputtexts" type="text" name="camp_frequency" size="5" value="<%=HtmlUtil.escape(camp_send_param.s_camp_frequency)%>"> days.
			</td>
		</tr>
		<%
	}

	if( camp.s_type_id.equals("2") )
	{
		%>
		<tr>
			<td width="150" class="campaign_header">Subset Sendout</td>
			<td   height="25" class="campaign_header">
				<p>
					How many
					&nbsp;
					<input class="inputtexts" style="width:70" type="text" size="9" name="recip_qty_limit" value="<%=HtmlUtil.escape(camp_send_param.s_recip_qty_limit)%>">
					&nbsp;
					<input type="checkbox" name="randomly" <%=("0".equals(camp_send_param.s_randomly)?"":" checked")%>>
					Randomly
				</p>
			</td>
		</tr>
<!--
		<tr>
			<td width="150">Maximum Sent Out Per Hour<br>(0 for no limit)</td>
			<td   height="25">
				<input type="text" size="8" name="limit_per_hour" value="<%=HtmlUtil.escape(camp_send_param.s_limit_per_hour)%>">
			</td>
		</tr>	 
-->
		<%
	}
	%>
	
	<%
}
%>	
</table>
</fmt:bundle>