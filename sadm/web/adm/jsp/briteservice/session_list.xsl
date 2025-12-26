<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="no" encoding="UTF-8"/>

<xsl:template match="machine">
	<table class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
		<tr>
			<td class="listBox" valign="top" align="left">
				<xsl:call-template name="sessions" />
			</td>
		</tr>
	</table>
</xsl:template>

<xsl:template name="sessions">

	<table class="layout" style="width:100%; height:100%;" cellpadding="0" cellspacing="0" border="0">
		<col />
		<tr height="30">
			<td valign="top" style="padding:0px;">
				<table class="listTable layout" style="width:100%;" cellpadding="2" cellspacing="0">				
					<col width="80" />
					<col width="50" />
					<col width="120" />
					<col width="50" />
					<col width="120" />
					<col width="80" />
					<col width="80" />
					<col width="80" />
					<col width="80" />
					<col />
					<col width="20" />
					<tr>
						<th>Server</th>
						<th>Cust ID</th>
						<th>Cust Name</th>
						<th>User ID</th>
						<th>User Name</th>
						<th>Phone</th>						
						<th>Login Time</th>
						<th>Last Access Time</th>
						<th>Idle Time (sec)</th>
						<th>Last URL</th>
						<th><img src="icoRefresh.gif" alt="Refresh Customer List" style="cursor:hand;" onclick="refreshCust();"></img></th>	
					</tr>
				</table>
			</td>
		</tr>
<xsl:choose>
	<xsl:when test="/machine/sessions/session">
		<tr>
			<td valign="top" style="padding:0px;">
				<div style="width:100%; height:100%; overflow-y:scroll;">
				<table id="users_list" class="layout" style="width:100%;" cellpadding="0" cellspacing="0" border="0">
					<col width="80" />
					<col width="50" />
					<col width="120" />
					<col width="50" />
					<col width="120" />
					<col width="80" />
					<col width="80" />
					<col width="80" />
					<col width="80" />
					<col />
					<col width="20" />
				<xsl:for-each select="/machine/sessions/session">
					<xsl:sort select="user_name" order="ascending"/>
					<tr class="dataRow">
						<td>&#160;<xsl:value-of select="cps" /></td>
						<td>&#160;<xsl:value-of select="cust_id" /></td>	
						<td>&#160;<xsl:value-of select="cust_name" /></td>
						<td>&#160;<xsl:value-of select="user_id" /></td>						
						<td>&#160;<xsl:value-of select="user_name" /></td>
						<td>&#160;<xsl:value-of select="phone" /></td>
						<td>&#160;<xsl:value-of select="login_time" /></td>
						<td>&#160;<xsl:value-of select="last_access_time" /></td>
						<td>&#160;<xsl:value-of select="idle_time" /></td>
						<td colspan="2">&#160;<xsl:value-of select="last_url" /></td>
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
						<td valign="middle" align="center">There are currently no users currently logged in for that customer</td>
					</tr>
				</table>
			</td>
		</tr>
	</xsl:otherwise>
</xsl:choose>
	</table>

</xsl:template>
</xsl:stylesheet>