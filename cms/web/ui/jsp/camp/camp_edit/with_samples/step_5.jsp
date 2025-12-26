<% nTabHeaderId = 0; nTabPageId = 0; %>

<table class="listTable" id="tab_<%=(++nTabId)%>" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="Tab_ON" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');"  valign="middle" nowrap align="center">Campaign History</td>
        <% if (!isPrintCampaign) { %>
		<td class="Tab_OFF" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');"  valign="middle" nowrap align="center">Test History</td>
        <% } %>
		<td class="Tab_OFF" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');"  valign="middle" nowrap align="center">User History</td>
		<td class="EmptyTab" valign="middle" nowrap align="center" width="100">&nbsp;</td>
	</tr>
	<tr>
		<td class="Tab_GREY" valign="top" align="left" width="650" colspan="4"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class=EditBlock id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="200" colspan="4">

<%@ include file="step_5_tab_1.jsp"%>

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="200" colspan="4">

<%@ include file="step_5_tab_2.jsp"%>

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="left" width="650" height="200" colspan="4">

<%@ include file="step_5_tab_3.jsp"%>

		</td>
	</tr>
	</tbody>
</table>
