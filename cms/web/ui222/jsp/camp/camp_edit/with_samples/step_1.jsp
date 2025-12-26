<% nTabHeaderId = 0; nTabPageId = 0; %>

<table id="tab_<%=(++nTabId)%>" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" align="center" nowrap valign="middle" width="275"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td align="center" nowrap valign="middle" width="15"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td class="EmptyTab" align="center" nowrap valign="middle" width="360"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="275"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td valign="top" align="left" width="15"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td class="fillTabbuffer" valign="top" align="left" width="360"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>">
	<tr>
		<td class="fillTab" valign="top" align="center" width="275">

<%@ include file="step_1_tab_1.jsp"%>

		</td>
		<td valign="top" align="center" width="15">&nbsp;&nbsp;&nbsp;</td>
		<td class="fillTab" valign="top" align="center" width="360">

<%@ include file="step_1_tab_2.jsp"%>

		</td>
	</tr>
	</tbody>
</table>
