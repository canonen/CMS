<table cellspacing="0" cellpadding="0" width="100%" border="0" class="listTable">
	<tr>
	<th>Created by</th>
	<th>Last Modified by</th>
	<th>Creation date</th>
	<th>Last Modify date</th>
	</tr>
	<tr>
		<td><%= HtmlUtil.escape(creator.s_user_name + " " + creator.s_last_name) %></td>
		<td><%= HtmlUtil.escape(modifier.s_user_name + " " + modifier.s_last_name) %></td>
		<td><%= HtmlUtil.escape(camp_edit_info.s_create_date) %></td>
		<td><%= HtmlUtil.escape(camp_edit_info.s_modify_date) %></td>
	</tr>
</table>
