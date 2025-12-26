<%
nTabHeaderId = 0;
nTabPageId = 0;

boolean step2_tabs_show = false;
boolean step2_tab1_show = true;
boolean step2_tab2_show = false;
boolean step2_tab3_show = false;

String step2_tab_width = "150";
String step2_colspan = " colspan=\"4\"";

if (canStep2) step2_tab2_show = true;
if (canStep3) step2_tab3_show = true;

if (step2_tab1_show || step2_tab2_show || step2_tab3_show) step2_tabs_show = true;

if (!step2_tab2_show && !step2_tab3_show)
{
	step2_tab_width = "500";
	step2_colspan = " colspan=\"2\"";
}
if (step2_tab2_show && !step2_tab3_show)
{
	step2_tab_width = "350";
	step2_colspan = " colspan=\"3\"";
}

if (!step2_tabs_show) step2_colspan = "";

%>

<table class="listTable" id="tab_<%=(++nTabId)%>" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
<%
if (step2_tabs_show)
{
	%>
		<td class="Tab_ON" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');" valign="middle" nowrap align="center">Campaign Settings</td>
	<%
	if (step2_tab2_show)
	{
		%>
		<td class="Tab_OFF" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');" valign="middle" nowrap align="center">Advanced Settings</td>
		<%
	}
	if (step2_tab3_show)
	{
		%>
		<td class="Tab_OFF" id="tab_<%=nTabId%>_header_<%=(++nTabHeaderId)%>" width="150" onclick="switchSteps('tab_<%=nTabId%>', 'tab_<%=nTabId%>_header_<%=nTabHeaderId%>', 'tab_<%=nTabId%>_page_<%=nTabHeaderId%>');" valign="middle" nowrap align="center">Restrictions</td>
		<%
	}
	%>
		<td  valign="middle" nowrap align="center" width="<%= step2_tab_width %>">&nbsp;</td>
	<%
}
else
{
	%>
		<td  valign="center" nowrap align="middle">&nbsp;</td>
	<%
}
%>
	</tr>
	<tr>
		<td class="Tab_GREY" valign="top" align="left" width="650"<%= step2_colspan %>><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650"<%= step2_colspan %>>

<%@ include file="step_2_tab_1.jsp"%>
			
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650"<%= step2_colspan %>>
			
<%@ include file="step_2_tab_2.jsp"%>			

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="tab_<%=nTabId%>_page_<%=(++nTabPageId)%>" style="display:none;">
	<tr>
		<td class=fillTab valign="top" align="center" width="650"<%= step2_colspan %>>

<%@ include file="step_2_tab_3.jsp"%>

		</td>
	</tr>
	</tbody>
</table>
