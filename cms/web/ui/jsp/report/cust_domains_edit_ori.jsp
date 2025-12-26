<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<%

%>

<BODY>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onClick="trySubmit();">Save</a>
		</td>

		<td align="left" valign="middle">
			View: <A class="subactionbutton" href="report_settings_edit.jsp"><B>Report Settings</B></A>
		</td>
	</tr>
</table>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="cust_domains_save.jsp" TARGET="_self">

<table class=listTable cellspacing=0 cellpadding=2>
	<tr>
		<th colspan="2">Report Domains</th>
	<tr>
<%
        
        
        int maxDomainsOnReport = 20;
        if ((cust.s_max_domains_on_report != null) && (cust.s_max_domains_on_report.length() > 0)) {
        	maxDomainsOnReport = Integer.parseInt(cust.s_max_domains_on_report); 
            }
        
 	CustDomains domains = new CustDomains(cust.s_cust_id);
	
	if (domains.size() == 0) domains = new CustDomains("0");
%>
<!-- <%=domains.s_cust_id%> -->
<%
	int i = 0;
	String sClassAppend = "";
	for (Enumeration e = domains.elements(); e.hasMoreElements() ;) {
		CustDomain cd = (CustDomain)e.nextElement();
		i++;

		if (i % 2 == 0)
		{
			sClassAppend = "_other";
		}
		else
		{
			sClassAppend = "";
		}
%>
	<tr>
		<td align=right class="list_row<%= sClassAppend %>"><%=i%> : </td>
		<td class="listItem_Data<%= sClassAppend %>"><INPUT type="text" size="50" name="domain<%=i%>" value="<%=cd.s_domain%>"></td>
	</tr>
<%
	}
	for (; i < maxDomainsOnReport ; i++) {
		if (i % 2 == 0)
		{
			sClassAppend = "_other";
		}
		else
		{
			sClassAppend = "";
		}
%>
	<tr>
		<td align=right class="list_row<%= sClassAppend %>"><%=i+1%> : </td>
		<td class="listItem_Data<%= sClassAppend %>"><INPUT type="text" size="50" name="domain<%=i+1%>" value=""></td>
	</tr>
<%	
	}
%>
</table>
<br><br>
<SCRIPT LANGUAGE="JavaScript">


function trySubmit()
{
	FT.submit();
}

</SCRIPT>
</BODY>

</HTML>
<%
%>