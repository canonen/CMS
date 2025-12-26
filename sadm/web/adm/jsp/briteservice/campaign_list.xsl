<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="no" encoding="UTF-8"/>

<xsl:template match="machine">
	<table class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
		<tr>
			<td class="listBox" valign="top" align="left">
				<xsl:call-template name="campaigns" />
			</td>
		</tr>
	</table>
</xsl:template>

<xsl:template name="campaigns">

	<table class="layout" style="width:100%; height:100%;" cellpadding="0" cellspacing="0" border="0">
		<col />
		<tr height="30">
			<td valign="top" style="padding:0px;">
				<table class="listTable layout" style="width:100%;" cellpadding="2" cellspacing="0">
					<col width="20" />				
					<col width="150" />
					<col width="60" />
					<col width="60" />
					<col width="150" />					
					<col width="100" />
					<col width="50" />
					<col width="20" />
					<tr>
						<th></th>
						<th>Camp Name</th>
						<th>Type</th>
						<th>Approved</th>
						<th>Problem</th>							
						<th>Actual Status</th>
						<th>Set Status</th>
						<th><img src="icoRefresh.gif" alt="Refresh Customer List" style="cursor:hand;" onclick="refreshCust();"></img></th>	
					</tr>
				</table>
			</td>
		</tr>
<xsl:choose>
	<xsl:when test="/machine/campaigns/campaign">
		<tr>
			<td valign="top" style="padding:0px;">
				<div style="width:100%; height:100%; overflow-y:scroll;">
				<table id="item_list" class="layout" style="width:100%;" cellpadding="0" cellspacing="0" border="0">
					<col width="20" />				
					<col width="150" />
					<col width="60" />
					<col width="60" />
					<col width="150" />					
					<col width="100" />
					<col width="50" />
					<col width="20" />
				<xsl:for-each select="/machine/campaigns/campaign">
					<xsl:sort select="camp_name" order="ascending"/>
					<tr class="dataRow">
						<xsl:attribute name="id">parent_row_<xsl:value-of select="camp_id" /></xsl:attribute>
						<td style="padding:2px; cursor:pointer;">
						<a class="resourcebutton" style="width:15px; text-align:center;">
						<xsl:attribute name="href">javascript:toggleDetails('<xsl:value-of select="camp_id" />');</xsl:attribute>
						<xsl:attribute name="id">link_<xsl:value-of select="camp_id" /></xsl:attribute>+</a>
						</td>
						<td><xsl:value-of select="camp_name" /></td>
						<td><xsl:value-of select="camp_type" /></td>
						<td>
							<xsl:if test="approved = 'no'">No
								<a class="resourcebutton">
									<xsl:attribute name="href">javascript:approveCamp('<xsl:value-of select="camp_id" />');</xsl:attribute>
									approve
								</a>
							</xsl:if>
							<xsl:if test="approved = 'yes'">Yes
								<a class="resourcebutton">
									<xsl:attribute name="href">javascript:suspendCamp('<xsl:value-of select="camp_id" />');</xsl:attribute>
									suspend
								</a>
							</xsl:if>							
						</td>
						<td><xsl:value-of select="problem" /></td>						
						<td>
							<xsl:value-of select="actual_status" />
						</td>
						<td align="center">
							<a class="resourcebutton">
								<xsl:attribute name="href">javascript:setCampStatus('<xsl:value-of select="camp_id" />','<xsl:value-of select="cps_status_id" />','<xsl:value-of select="rcp_status_id" />');</xsl:attribute>
								Set Status
							</a>
						</td>
						<td></td>
					</tr>
					<tr style="display:none;">
						<xsl:attribute name="id">row_<xsl:value-of select="camp_id" /></xsl:attribute>
						<td colspan="8" class="dataExpand">
							<table cellspacing="0" cellpadding="1" border="0">
								<tr>
									<td class="dataExpandCell">
										<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%;">
											<col width="100" />
											<col width="200"/>
											<col width="100" />
											<col width="200"/>
											<tr class="noselect">
												<td valign="middle"><b>Camp ID</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="camp_id" /></td>
												<td valign="middle"><b>CPS Status</b></td>
												<td valign="middle" class="canSelect">(<xsl:value-of select="cps_status_id" />) <xsl:value-of select="cps_status_name" /></td>
											</tr>
											<tr class="noselect">
												<td valign="middle"><b>Modified Date</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="modify_date" /></td>	
												<td valign="middle"><b>RCP Status</b></td>
												<td valign="middle" class="canSelect">(<xsl:value-of select="rcp_status_id" />) <xsl:value-of select="rcp_status_name" /></td>
											</tr>											
											<tr class="noselect">
												<td valign="middle"><b>Execute Date</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="execute_date" /></td>											
												<td valign="middle"><b>Qty Queued</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="qty_queued" /></td>
											</tr>
											<tr class="noselect">
												<td valign="middle"><b>Start Date</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="start_date" /></td>											
												<td valign="middle"><b>Qty Sent</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="qty_sent" /></td>
											</tr>
											<tr class="noselect">
												<td valign="middle"><b>End Date</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="end_date" /></td>											
												<td valign="middle"><b>Content</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="cont_name" /></td>
											</tr>
											<tr class="noselect">
												<td valign="middle"><b>Queue Date</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="queue_date" /></td>													
												<td valign="middle"><b>Target Group</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="filter_name" /></td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</xsl:for-each>
				</table>
				</div>
			</td>
		</tr>
	</xsl:when>
	<xsl:otherwise>
		<tr>
			<td valign="top" style="padding:0px;">
				<table class="listTable layout" style="width:100%; height:100%;" cellpadding="0" cellspacing="0">
					<tr>
						<td valign="middle" align="center">There are currently no active campaigns in for that customer</td>
					</tr>
				</table>
			</td>
		</tr>
	</xsl:otherwise>
</xsl:choose>
	</table>

</xsl:template>
</xsl:stylesheet>