
<table id="listTable" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
<% if (!camp.s_type_id.equals("5")) { %>
		<td class="Tab_ON" id="tab2_Step1" width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign="center" nowrap align="middle">Campaign Settings</td>
<% } %>
		<td valign="center" nowrap align="middle" width="500">&nbsp;</td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td valign="top" align="center" width="650" colspan="2">

<%@ include file="step_2_tab_1.jsp"%>
			
		</td>
	</tr>
	</tbody>
</table>
