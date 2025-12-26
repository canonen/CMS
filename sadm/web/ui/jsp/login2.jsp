<%@ page
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.net.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="header.jsp"%>
<%
try	
{
	String sCustName = BriteRequest.getParameter(request, "company");

	if ( sCustName != null )
	{
	
		Customer cust = new Customer(null, sCustName);
		if((cust.s_cust_id != null)&&(CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)))
		{
			Vector services = Services.getByCust(ServiceType.CCPS_CUST_LOGIN, cust.s_cust_id);
			Service service = (Service) services.get(0);

			URL url = service.getURL();
			String sUrl = url.toString();

			// this is wrong but fast and easy solution for https ...
			if(request.isSecure())
			{
				sUrl = sUrl.replaceAll("http:","https:");
				sUrl = sUrl.replaceAll(":80",":443");
			}

			sUrl += "?company=" + URLEncoder.encode(sCustName, "UTF-8");
			response.sendRedirect(sUrl);
			return;
		}
	}
	
	//Set uitype session variable
	//session.setAttribute("uitype", "standard");
%>

<HTML>

<HEAD>
	<TITLE>Login</TITLE>
	<%@ include file="header.html" %>
	<BASE target="_self">
	<SCRIPT>if(top!=this)top.location.href=this.location.href;</SCRIPT>
<link rel="stylesheet" href="http://cms.revotas.com/cms/ui/css/style.css" TYPE="text/css"/>
</HEAD>

<BODY class="login">
	
<font face=arial size=1>
<FORM method="POST" action="login2.jsp">
<center><br><br><br><br><br><br>

<table width=250 cellpadding=1 cellspacing=1 border=0>
	<tr>
		<td width=250>

	<TABLE border="0" align="left" cellpadding=3 cellspacing=1>
	<tr>
		<td colspan=2 align=center style="font-family:arial;color:#990000;font-size:10px;">
			Please try again
		</td>
	</tr>
		<TR>
			<TD></TD>
			<TD align="left" valign=bottom>&nbsp;REVOTAS | MEDIA</TD>
		</TR>
	<TR>
		<TD nowrap>Company name:</TD>
		<TD>
			<INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="company" size="32" value="<%=(sCustName==null)?"":sCustName%>">
		</TD>
	</TR>
	<TR>
		<TD nowrap>&nbsp;</TD>
		<TD align="left"><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="submit" value=" Next >>> "></TD>
	</TR>
</TABLE>

		</TD>
	</TR>
</TABLE>

</FORM>
</BODY>

</HTML>

<%
}
catch(Exception ex)
{
	logger.error("Exception: ", ex);
}
finally
{
}
%>
