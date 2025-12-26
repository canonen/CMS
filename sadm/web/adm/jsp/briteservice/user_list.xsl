<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="no" encoding="UTF-8"/>

<xsl:template match="customer">
	<table class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
		<tr>
			<td class="listBox" valign="top" align="left">
				<xsl:call-template name="users" />
			</td>
		</tr>
	</table>
</xsl:template>

<xsl:template name="users">

	<table class="layout" style="width:100%; height:100%;" cellpadding="0" cellspacing="0" border="0">
		<col />
		<tr height="21">
			<td valign="top" style="padding:0px;">
				<table class="listTable layout" style="width:100%;" cellpadding="2" cellspacing="0">
					<col width="30" />
					<col width="200" />
					<col width="150" />
					<col width="60" />
					<col width="14" />
					<tr>
						<th>&#160;</th>
						<th>User Name</th>
						<th>Phone</th>
						<th>&#160;</th>
						<th><img src="icoRefresh.gif" alt="Refresh Customer List" style="cursor:hand;" onclick="refreshCust();"></img></th>
					</tr>
				</table>
			</td>
		</tr>
<xsl:choose>
	<xsl:when test="/customer/users/user">
		<tr>
			<td valign="top" style="padding:0px;">
				<div style="width:100%; height:100%; overflow-y:scroll;">
				<table id="item_list" class="layout" style="width:100%;" cellpadding="0" cellspacing="0" border="0">
					<col width="30" />
					<col width="200" />
					<col width="150" />
					<col width="60" />
					<col width="14" />
				<xsl:for-each select="/customer/users/user">
					<xsl:sort select="user_name" order="ascending"/>
					<xsl:if test="status_id = 30">
					<tr class="dataRow">
						<xsl:attribute name="id">parent_row_<xsl:value-of select="user_id" /></xsl:attribute>
						<td style="padding:2px; cursor:pointer;">
						<a class="resourcebutton" style="width:15px; text-align:center;">
						<xsl:attribute name="href">javascript:toggleDetails('<xsl:value-of select="user_id" />');</xsl:attribute>
						<xsl:attribute name="id">link_<xsl:value-of select="user_id" /></xsl:attribute>+</a>
						</td>
						<td><xsl:value-of select="user_name" />&#160;<xsl:value-of select="last_name" /></td>
						<td><xsl:value-of select="phone" /></td>
						<td align="center" valign="middle" colspan="2">
						<a class="resourcebutton"><xsl:attribute name="href">javascript:userLogin('<xsl:value-of select="/customer/login_name" />','<xsl:value-of select="login_name" />','<xsl:value-of select="password" />');</xsl:attribute>login</a>
						</td>
					</tr>
					<tr style="display:none;">
						<xsl:attribute name="id">row_<xsl:value-of select="user_id" /></xsl:attribute>
						<td colspan="4" class="dataExpand">
							<table cellspacing="0" cellpadding="1" border="0">
								<tr>
									<td class="dataExpandCell">
										<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%;">
											<col width="100" />
											<col />
											<col width="100" />
											<col />
											<tr class="noselect">
												<td valign="middle"><b>Company</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="/customer/login_name" /></td>
												<td valign="middle"><b>Position</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="position" /></td>
											</tr>
											<tr class="noselect">
												<td valign="middle"><b>UserName</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="login_name" /></td>
												<td valign="middle"><b>Email</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="email" /></td>
											</tr>
											<tr class="noselect">
												<td valign="middle"><b>Password</b></td>
												<td valign="middle" class="canSelect">n/a</td>
												<td valign="middle"><b>Phone</b></td>
												<td valign="middle" class="canSelect"><xsl:value-of select="phone" /></td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					</xsl:if>
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
						<td valign="middle" align="center">There are currently no users for that customer</td>
					</tr>
				</table>
			</td>
		</tr>
	</xsl:otherwise>
</xsl:choose>
	</table>

</xsl:template>
</xsl:stylesheet>