<table class="listTable" cellspacing="1" cellpadding="3" width="100%" border="0">
	<tr>
		<td class="CampHeader"><b>Created by</b></td>
		<td><%= HtmlUtil.escape(creator.s_user_name + " " + creator.s_last_name) %></td>
		<td class="CampHeader"><b>Last Modified by</b></td>
		<td><%= HtmlUtil.escape(modifier.s_user_name + " " + modifier.s_last_name) %></td>
	</tr>
	<tr>
		<td class="CampHeader"><b>Creation date</b></td>
		<td><%= HtmlUtil.escape(camp_edit_info.s_create_date) %></td>
		<td class="CampHeader"><b>Last Modify date</b></td>
		<td><%= HtmlUtil.escape(camp_edit_info.s_modify_date) %></td>
	</tr>
</table>