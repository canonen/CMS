	<table class="listTable" cellspacing="1" cellpadding="2" width="100%">
		<tr>
			<td align="left" valign="middle">Campaign Name</TD>
		</tr>
		<tr>
			<td align="left" valign="middle">
			    <input TYPE="text" NAME="camp_name" value="<%= camp.s_camp_name %>" SIZE="40" MAXLENGTH="50" <% if (camp.s_type_id.equals("5") || isPrintCampaign ) { %>onChange="if (document.all.export_name.value != null) { document.all.export_name.value = this.value; }" <% } %>>
			</td>
		</tr>
		<tbody<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
		<tr>
			<td align="left" valign="middle">Categories</TD>
		</tr>
		<tr>
			<td align="left" valign="middle">
				<select multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="4">
					<%=buildCategoriesHtml(stmt, cust.s_cust_id, camp.s_camp_id, sSelectedCategoryId)%>
				</select>
				<%
				if(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
				{
					%>
					<input type="hidden" name="categories" value="<%= sSelectedCategoryId %>">
					<%
				}
				%>
			</td>
		</tr>
                
        <!-- allow save category button if the campaign is done -->
        
       <%
       if (can.bWrite && bWasFinalCampSent && bWasSamplesetSent && canSampleSet) { 
       %>
        <tr>
            <td align="left" valign="middle"> <a class="savebutton" href="#" onClick="saveCategories();">Save Categories</a>
            </td>
        </tr>
        <% 
        } 
        %>
                
		</tbody>
	</table>