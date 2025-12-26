<% nTabHeaderId = 0; nTabPageId = 0; %>

<table class="listTable" id="tab_<%=(++nTabId)%>" cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class="Tab_ON" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="100" valign="middle" nowrap align="center"><%= tabHeading %></td>
		<td class="EmptyTab" valign="middle" nowrap align="left" width="540">&nbsp;<%= tabQty %>&nbsp;</td>
	</tr>
	<tr>
		<td class="Tab_GREY" valign="top" align="left" width="640" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>" >
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%" colspan="2">

<%@ include file="step_3_tab_1.jsp"%>

		</td>
	</tr>
	</tbody>
</table>