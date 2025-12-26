<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function openModal(sURL, oArgs, iX, iY)
	{
		window.showModalDialog(sURL, oArgs, "dialogWidth:" + iX + "px;dialogHeight:" + iY + "px;help:0;status:0;scroll:0;center:1");
	}
	
</script>
</HEAD>
<BODY>
				<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent" style="padding: 3px;">
			<table cellspacing="0" cellpadding="0" width="95%" border="0" > 
				<tr>
					<td class="listHeading" valign="center" nowrap align="center">
						To execute SMS campaigns contact us operasyon@revotas.com
						<br><br>
						
					</td>
				</tr>
			</table>
			</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>			
</div>
			<br></BODY>
