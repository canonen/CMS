<table cellspacing="1" cellpadding="3" width="100%" border="0">
	<tr>
		<td class="row_heading">Created by</td>
		<td class="row4"><%= HtmlUtil.escape(creator.s_user_name + " " + creator.s_last_name) %>&nbsp;</td>
		<td class="row_heading">Last Modified by</td>
		<td class="row4"><%= HtmlUtil.escape(modifier.s_user_name + " " + modifier.s_last_name) %>&nbsp;</td>
	</tr>
	<tr>
		<td class="row_heading">Creation date</td>
		<td class="row4"><%= HtmlUtil.escape(camp_edit_info.s_create_date) %>&nbsp;</td>
		<td class="row_heading">Last Modify date</td>
		<td class="row4"><%= HtmlUtil.escape(camp_edit_info.s_modify_date) %>&nbsp;</td>
	</tr>
</table>
