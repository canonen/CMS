<table id="Tabs_Table6" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EditTabOn" id="tab6_Step1" width="120" onclick="switchSteps('Tabs_Table6', 'tab6_Step1', 'block6_Step1');" valign="center" nowrap align="middle">Campaign History</td>
<% if (!camp.s_type_id.equals("5") && !isPrintCampaign) { %>
		<td class="EditTabOff" id="tab6_Step2" width="120" onclick="switchSteps('Tabs_Table6', 'tab6_Step2', 'block6_Step2');" valign="center" nowrap align="middle">Testing History</td>
<% } %>
		<td class="EditTabOff" id="tab6_Step3" width="120" onclick="switchSteps('Tabs_Table6', 'tab6_Step3', 'block6_Step3');" valign="center" nowrap align="middle">User History</td>
<% if ((canPvDesignOptimizer && canUserPvDesignOptimizer.bRead) || 
       (canPvContentScorer && canUserPvContentScorer.bRead) || 
       (canPvDeliveryTracker && canUserPvDeliveryTracker.bRead) ) { %>	
		<td class="EditTabOff" id="tab6_Step4" width="120" onclick="switchSteps('Tabs_Table6', 'tab6_Step4', 'block6_Step4');" valign="center" nowrap align="middle">Deliverability History</td>
<% } %>		
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100">&nbsp;</td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650" colspan="4"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tbody class="EditBlock" id="block6_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="150" colspan="5">

<%@ include file="step_5_tab_1.jsp"%>

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block6_Step2" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" height="150" colspan="5">

<%@ include file="step_5_tab_2.jsp"%>

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block6_Step3" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="left" width="650" height="150" colspan="5">

<%@ include file="step_5_tab_3.jsp"%>

		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block6_Step4" style="display:none;">
	<tr>
		<td class="fillTab" valign="top" align="left" width="650" height="150" colspan="5">

<%@ include file="step_5_tab_4.jsp"%>

		</td>
	</tr>
	</tbody>
</table>
