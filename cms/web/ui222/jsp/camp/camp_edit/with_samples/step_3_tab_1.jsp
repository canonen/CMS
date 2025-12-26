<table class="main" cellspacing="1" cellpadding="2" width="100%">
<%
if (isDynamicCampaign && !tabHeading.equals("Final"))
{
	%>
	<tr>
		<td width="150" height="25">Logic Element</td>
		<td width="400" height="25" nowrap>
			<select name="filter_id<%=sSampleId%>" size="1">
				<option value="">-----  Choose logic element  -----</option>
				<%=getLogicBlockOptionsHtml(stmt, cust.s_cust_id, camp_sample.s_filter_id, sSelectedCategoryId)%>
			</select>
			
			<% if (!tabHeading.equals("Final")) { %>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Priority&nbsp;
			<select name="priority<%=sSampleId%>" size="1">
				<% 
					if (camp_sampleset.s_camp_qty != null) {
						int samplePriority = -1;
						try { samplePriority = Integer.parseInt(camp_sample.s_priority); }
						catch (Exception e) {};
						if (samplePriority == -1) {
							try { samplePriority = Integer.parseInt(sSampleId); }
							catch (Exception e) {};
						}						
						int nMaxPriority = Integer.parseInt(camp_sampleset.s_camp_qty);						
						for (int p=1; p <= nMaxPriority; p++) {
				%>
				<option value="<%=p%>" <%=(samplePriority == p?"selected":"")%>><%=p%></option>
				<%      }
					}
				%>
			</select>
			<% } %>
		</td>
	</tr>	
	<%
}	

if(!isPrintCampaign && camp_sampleset.s_from_name_flag != null)
{
	%>
	<tr>
		<td width="100" height="25">From Name</td>
		<td width="450" height="25">
			<input type="text" name="from_name<%=sSampleId%>" value="<%=HtmlUtil.escape(camp_sample.s_from_name)%>" size="25" maxlength="50">&nbsp;
			<% if (canFromNamePers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
		</td>
	</tr>
	<%
}

if(!isPrintCampaign && camp_sampleset.s_from_address_flag != null)
{
	%>
	<tr>
		<td width="100" height="25" rowspan="2">From Address</td>
		<td width="450" height="25">
			<nobr>
			<%=(canFromAddrPers)?"":"<div name='divfa1"+sSampleId+"' style='display:none'>"%>
			<INPUT TYPE="radio" NAME="fa1<%=sSampleId%>" onClick="checkFrom(this, '<%=sSampleId%>')"<%=camp_sample.s_from_address==null?" CHECKED":""%>>
			<%=(canFromAddrPers)?"":"</div>"%>
			<select name="from_address_id<%=sSampleId%>" size="1" onClick="checkFrom(FT.fa1<%=sSampleId%>, '<%=sSampleId%>')">
				<option value="">-----  Choose address  -----</option>
				<%=getFromAddressOptionsHtml(stmt, cust.s_cust_id,  camp_sample.s_from_address_id)%>
			</select>
			</nobr>
		</td>
	</tr>
	<tr<%=(canFromAddrPers)?"":" style='display:none'"%>>
		<td width="450">
			<nobr>
			<INPUT TYPE="radio" NAME="fa2<%=sSampleId%>" onClick="checkFrom(this, '<%=sSampleId%>')"<%=camp_sample.s_from_address!=null?" CHECKED":""%>>
			<input type="text" name="from_address<%=sSampleId%>" value="<%=HtmlUtil.escape(camp_sample.s_from_address)%>" size="25" maxlength="255" onClick="checkFrom(FT.fa2<%=sSampleId%>, '<%=sSampleId%>')">
			<% if (canFromAddrPers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
			</nobr>
		</td>
	</tr>
	<%
}

if(camp_sampleset.s_subject_flag != null)
{
	%>
	<tr>
		<td width="100" height="25" nowrap>Subject</td>
		<td width="450" height="25">
			<input type="text" name="subj_html<%=sSampleId%>" value="<%=HtmlUtil.escape(camp_sample.s_subject_html)%>" size="40" maxlength="150"> 
			<% if (canSubjectPers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
		<%
		if(!isPrintCampaign && camp_sampleset.s_cont_flag == null)
		{
			%>
			&nbsp;&nbsp;
			<a class="resourcebutton" href="javascript:score_popup(document.all.cont_id[document.all.cont_id.selectedIndex].value,<% if (sSampleId.equals("")) { out.print("''"); } else { out.print(sSampleId);} %>);">Score</a>
			<%
		}
		%>
		</td>
	</tr>
	<%
}

if (isDynamicCampaign && camp_sampleset.s_reply_to_flag != null)
{
	%>
	<tr>
		<td width="100" height="25" nowrap>Reply To</td>
		<td width="450" height="25">
			<input type="text" name="reply_to<%=sSampleId%>" value="<%=HtmlUtil.escape(camp_sample.s_reply_to)%>" size="40" maxlength="150"> 
			<a class="resourcebutton" href="javascript:pers_popup()">Personalize</a>
		</td>
	</tr>
	<%
}

if(camp_sampleset.s_cont_flag != null)
{
	%>
	<tr>
		<td width="100" height="25">Content	</td>
		<td width="450" colspan="2" height="25">
			<select name="cont_id<%=sSampleId%>" size="1">
				<option value="">-----  Choose content  -----</option>
				<%=getContOptionsHtml(stmt, cust.s_cust_id, camp_sample.s_cont_id, sSelectedCategoryId, isPrintCampaign)%>
			</select>
			&nbsp;&nbsp;
			<a class="resourcebutton" href="javascript:dynamic_popup(FT.<%= (sSampleId.equals(""))?"cont_id":"cont_id" + sSampleId %>[FT.<%= (sSampleId.equals(""))?"cont_id":"cont_id" + sSampleId %>.selectedIndex].value);">Preview</a>
            <% if (!isPrintCampaign) { %>
            &nbsp;&nbsp;
            <a class="resourcebutton" href="javascript:score_popup(FT.<%= (sSampleId.equals(""))?"cont_id":"cont_id" + sSampleId %>[FT.<%= (sSampleId.equals(""))?"cont_id":"cont_id" + sSampleId %>.selectedIndex].value,<%=(sSampleId.equals(""))?"''":sSampleId%>);">Score</a>
            <% } %>
		</td>
	</tr>
	<%
}

if(camp_sampleset.s_send_date_flag != null)
{
	%>
	<tr>
		<td width="100" valign="middle">Send Start Date </td>
		<td width="450">
			<table>
				<tr>
					<td width="100">
						<input name="start_date_switch<%=sSampleId%>" id="start_date_switch<%=sSampleId%>_now" value="now" type="radio"<%=((camp_sample.s_send_date==null)?" checked":"")%>>&nbsp;<label for="start_date_switch<%=sSampleId%>_now">Now</label>&nbsp;
					</td>
					<td width="450" nowrap>
						<input name="start_date_switch<%=sSampleId%>" id="start_date_switch<%=sSampleId%>_specified" value="" type="radio"<%=((camp_sample.s_send_date!=null)?" checked":"")%>>&nbsp;<label for="start_date_switch<%=sSampleId%>_specified">Specific Date:</label>&nbsp; 
						<select name="start_date_year<%=sSampleId%>" onchange="FT.start_date_switch<%=sSampleId%>_specified.checked=true;FT.start_date_switch<%=sSampleId%>_now.checked=false;">
							<%=getYearOptionsHtml(camp_sample.s_send_date)%>
						</select>
						<select name="start_date_month<%=sSampleId%>" onchange="FT.start_date_switch<%=sSampleId%>_specified.checked=true;FT.start_date_switch<%=sSampleId%>_now.checked=false;">
							<%=getMonthOptionsHtml(camp_sample.s_send_date)%>
						</select>
						<select name="start_date_day<%=sSampleId%>" onchange="FT.start_date_switch<%=sSampleId%>_specified.checked=true;FT.start_date_switch<%=sSampleId%>_now.checked=false;">
							<%=getDayOptionsHtml(camp_sample.s_send_date)%>
						</select>
						<select name="start_date_hour<%=sSampleId%>" onchange="FT.start_date_switch<%=sSampleId%>_specified.checked=true;FT.start_date_switch<%=sSampleId%>_now.checked=false;">
							<%=getHourOptionsHtml(camp_sample.s_send_date)%>
						</select>
						(EST)
						<input name="start_date<%=sSampleId%>" type="hidden" value="">
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
<%
sInTypes = "2,5,7";

if (!canSpecTest) sInTypes = "2";
%>
<table class="main" cellspacing="1" cellpadding="2" width="100%">
    <% if (!isPrintCampaign) { %>
	<tr>
		<td width="100" height="30">Testing List</td>
		<td height="30" width="450">
			<select name="test_list_id<%=sSampleId%>" size="1" onChange="checkDynamic('<%=sSampleId%>');">
				<option value="">---  Choose test list  -----</option>
				<%= getTestListOptionsHtml(stmt, cust.s_cust_id, camp_sample.s_test_list_id, sInTypes) %>
			</select>
<%
		if( can.bExecute && !bIsDone && !isSending && !isTesting)
		{
			if(("".equals(sSampleId))||(!bWasSamplesetSent))
			{
%>
			<a class="actionbutton" href="javascript:send_test('<%= sSampleId %>');">SEND A TEST &gt;</a>
<%
			}
		}
%>
		</td>
	</tr>

	<tr id="dynamicExtra<%=sSampleId%>" style="display:none;">
		<td colspan="3">
			Number recipients to include in dynamic test
			&nbsp;
			<input type="text" size="9" name="test_recip_qty_limit" value="<%=HtmlUtil.escape(camp_send_param.s_test_recip_qty_limit)%>">
		</td>
	</tr>
    <% } %>
</table>
