<table class=listTable cellspacing=1 cellpadding=1 width="100%">
<%
if (!isPrintCampaign && camp_sampleset.s_from_name_flag == null)
{
	%>
	<tr>
		<td width="150" height="25">From Name</td>
		<td width="400" height="25">
			<input type="text" name="from_name" value="<%=HtmlUtil.escape(msg_header.s_from_name)%>" size="25" maxlength="50"> 
			<% if (canFromNamePers) { %><a class="resourcebutton" href="#" onclick="pers_popup()">Personalize</a><% } %>
		</td>
	</tr>
	<%
}

if (!isPrintCampaign && camp_sampleset.s_from_address_flag == null)
{
	%>
	<tr>
		<td width="150" height="25" rowspan="2">From Address</td>
		<td width="400" height="25">
			<nobr>
			<%=(canFromAddrPers)?"":"<div name='divfa1' style='display:none'>"%>
			<INPUT TYPE="radio" NAME="fa1" onClick="checkFrom(this, '')"<%=msg_header.s_from_address==null?" CHECKED":""%>>
			<%=(canFromAddrPers)?"":"</div>"%>
			<select name="from_address_id" size="1" onClick="checkFrom(FT.fa1, '')">
				<option value="">-----  Choose address  -----</option>
				<%=getFromAddressOptionsHtml(stmt, cust.s_cust_id, msg_header.s_from_address_id)%>
			</select>
			</nobr>
		</td>
	</tr>
	<tr<%=(canFromAddrPers)?"":" style='display:none'"%>>
		<td>
			<nobr>
			<INPUT TYPE="radio" NAME="fa2" onClick="checkFrom(this, '')"<%=msg_header.s_from_address!=null?" CHECKED":""%>>
			<input type="text" name="from_address" value="<%=HtmlUtil.escape(msg_header.s_from_address)%>" size="25" maxlength="255" onClick="checkFrom(FT.fa2, '')">
			<% if (canFromAddrPers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
			</nobr>
		</td>
	</tr>
	<%
}

if (!isPrintCampaign && camp_sampleset.s_subject_flag == null)
{
	%>
	<tr>
		<td width="150" height="25" nowrap>Subject</td>
		<td width="400" height="25">
				    <%
		      	
		    String msg="";
		    String mes=msg_header.s_subject_html;
			StringBuilder sw = new StringBuilder();
		    StringBuilder sb=new StringBuilder();
		  
		if(mes!=null)
		{
			char ch = 0;
			int n = 0;
			int len = mes.length();
			for(int i = 0; i < len; i ++)
			{
				ch = mes.charAt(i);
				n = ch;
				if
				(
					(n == 32)
					||
					((n >= 48)&&(n <= 57))
					||
					((n >= 65)&&(n <= 90))
					||
					((n >= 97)&&(n <= 122))
				) sb.append(ch);
				else 
					{
					//sw.append("&#" + (int)ch + ";");
					int c=mes.codePointAt(i);
					if(!(Integer.toHexString(c).startsWith("d")))
					{
		    	                sb.append("&#x"+Integer.toHexString(c)+";");
                                // System.out.println(i+" "+"&#x"+Integer.toHexString(c)+";"+ch);  
					
					}
					else
					{
						if(Integer.toHexString(c).equals("d6") || Integer.toHexString(c).equals("dc"))
						{
							sb.append("&#x"+Integer.toHexString(c)+";");
							
						}
						
						
						
					}
                                      

					
					}
			}
		
			msg= sb.toString();
		}
		else
		{
		 msg="";	
		}
		    
		    %>
		<p id="rvts_emoji_title" class="lead emoji-picker-container"><input type="text" name="subj_html" value="<%=msg%>" size="40" maxlength="150" data-emojiable="true" data-emoji-input="unicode"></p>
			<% if (canSubjectPers) { %><a class="resourcebutton" href="javascript:pers_popup()">Personalize</a><% } %>
		</td>
	</tr>
	<%
}

if (camp_sampleset.s_cont_flag == null)
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
			<a class="resourcebutton" href="javascript:dynamic_popup(FT.cont_id[FT.cont_id.selectedIndex].value);">Preview</a>
<%  if (!isPrintCampaign && camp_sampleset.s_subject_flag == null) { %>
            &nbsp;&nbsp;
			<a class="resourcebutton" href="javascript:main_score_popup(FT.cont_id[FT.cont_id.selectedIndex].value);">Score</a>
<% } %>
		</td>
	</tr>
	<%
}
%>
	<tr>
		<td class="campaign_header" width="150" height="25">
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
<% if (isPrintCampaign) { %>
			<input type="hidden" name="response_frwd_addr"  size="40" maxlength="255" value="">
<% } else { %>

	<tr>
		<td width="150" height="25">Response Forwarding</td>
		<td width="400" height="25">
			<input type="text" name="response_frwd_addr"  size="40" maxlength="255" value="<%=HtmlUtil.escape(camp_send_param.s_response_frwd_addr)%>"<%=(isHyatt?" onChange=\"FT.reply_to.value=this.value\"":"")%>>
		</td>
	</tr>
<% } %>
</table>
