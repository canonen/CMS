<%
nTabHeaderId = 0;
nTabPageId = 0;

boolean step4_tab1_show = true;
boolean step4_tab2_show = false;

String step4_tab_width = "350";
String step4_colspan = " colspan=\"3\"";

if (canQueueStep) step4_tab2_show = true;
if (!step4_tab2_show)
{
	step4_tab_width = "500";
	step4_colspan = " colspan=\"2\"";
}
%>

<table id="tab_<%=(++nTabId)%>" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EditTabOn" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');" valign="middle" nowrap align="center">Send Out</td>
	<%
	if (step4_tab2_show)
	{
		%>
		<td class="EditTabOff" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');" valign="middle" nowrap align="center">Advanced Options</td>
		<%
	}
	%>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="<%= step4_tab_width %>">&nbsp;</td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"<%= step4_colspan %>><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="140"<%= step4_colspan %>>

<%@ include file="step_4_tab_1.jsp"%>

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="140"<%= step4_colspan %>>

<%@ include file="step_4_tab_2.jsp"%>

		</td>
	</tr>
	</tbody>
</table>
