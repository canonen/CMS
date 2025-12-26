<%
String sTabSize = "";
if (camp.s_type_id.equals("3"))
{
	sTabSize = "240";
}
else if (camp.s_type_id.equals("4"))
{
	sTabSize = "310";
}
else
{
	sTabSize = "250";
}

boolean step2_tabs_show = false;
boolean step2_tab1_show = false;
boolean step2_tab2_show = false;
boolean step2_tab3_show = false;

String step2_tab_width = "150";
String step2_tab_height = "195";
String step2_colspan = " colspan=\"4\"";

if (!camp.s_type_id.equals("5")) {
	step2_tab1_show = true;
}
if (camp.s_type_id.equals("5")) {
	step2_tab_height = "50";
}
if (isPrintCampaign) {
	step2_tab_height = "80";
}

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

<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
<%
if (step2_tabs_show)
{
	%>
		<td class="EditTabOn" id="tab2_Step1" width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign="center" nowrap align="middle">Campaign Settings</td>
	<%
	if (step2_tab2_show)
	{
		%>
		<td class="EditTabOff" id="tab2_Step2" width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign="center" nowrap align="middle">Advanced Settings</td>
		<%
	}
	if (step2_tab3_show)
	{
		%>
		<td class="EditTabOff" id="tab2_Step3" width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step3', 'block2_Step3');" valign="center" nowrap align="middle">Restrictions</td>
		<%
	}
	%>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="<%= step2_tab_width %>">&nbsp;</td>
	<%
}
else
{
	%>
		<td class="EmptyTab" valign="center" nowrap align="middle">&nbsp;</td>
	<%
}
%>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"<%= step2_colspan %>><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="<%=step2_tab_height%>"<%= step2_colspan %>>

<%@ include file="step_2_tab_1.jsp"%>
			
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block2_Step2" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="<%=step2_tab_height%>"<%= step2_colspan %>>
			
<%@ include file="step_2_tab_2.jsp"%>

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block2_Step3" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="<%=step2_tab_height%>"<%= step2_colspan %>>
			
<%@ include file="step_2_tab_3.jsp"%>

		</td>
	</tr>
	</tbody>
</table>
