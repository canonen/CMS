<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "original_cust_id");
if(sCustId == null)
{
	out.println("ERROR: sCustId == null");
	return;
}

Customer cust = new Customer(sCustId);
if(cust.s_cust_id == null)
{
	out.println("ERROR: Customer does not exist");
	return;
}

String sHayattSettings = BriteRequest.getParameter(request, "hayatt_settings");

%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>

<BODY>
<FORM method="post" action="cust_clone_hyatt.jsp">
<INPUT type="hidden" name="original_cust_id" value="<%=cust.s_cust_id%>">
<INPUT type="hidden" name="hayatt_settings" value="<%=HtmlUtil.escape(sHayattSettings)%>">

<H5>Verify pasted data:</H5>
Note: all the data is for "update" but not for "create" or "delete".<BR>
For example: cloned users will be updated with specified data.<BR>
But if user 2 does not exist in original customer it will not be created.<BR>
If data for user 2 is not specified, it will not be deleted<BR>
as well as users 3,4,5 if they exist for original customer.<BR>
<BR>
<TABLE border="1" cellspacing="0" cellpadding="1">
	<TR>
		<TH>N</TH>	
		<TH>Spirit<BR>Code</TH>
		<TH>Customer<BR>Name</TH>
		<TH>Customer<BR>Login<BR>Name</TH>
		<TH>Street<BR>Address<BR>1</TH>
		<TH>Street<BR>Address<BR>2</TH>
		<TH>City</TH>
		<TH>State</TH>
		<TH>Zip</TH>
		<TH>Country</TH>
		<TH>User<BR>Name<BR>1</TH>
		<TH>User<BR>Phone<BR>1</TH>
		<TH>User<BR>Email<BR>1</TH>
		<TH>User<BR>Login<BR>1</TH>
		<TH>User<BR>Pass<BR>1</TH>
		<TH>User<BR>Name<BR>2</TH>		
		<TH>User<BR>Phone<BR>2</TH>
		<TH>User<BR>Email<BR>2</TH>
		<TH>User<BR>Login<BR>2</TH>
		<TH>User<BR>Pass<BR>2</TH>
	</TR>		
<%
	if(sHayattSettings != null)
	{
		BufferedReader br = new BufferedReader(new StringReader(sHayattSettings));
		int n = 0;
		for(String sLine = br.readLine(); sLine != null; sLine = br.readLine())
		{
			n++;
%>
	<TR>
		<TD nowrap><%=n%></TD>	
<%
			String[] sCells = sLine.split("\t");
			for(int i=0; i < sCells.length; i++)
			{
%>
		<TD nowrap><%=HtmlUtil.escape(sCells[i])%></TD>
<%
			}
%>
	</TR>
<%
		}
	}
%>
	<TR>
		<TD colspan=20 align=center>
<INPUT type=submit style="width: 75%;" value="Create customers">
		</TD>
	</TR>
</TABLE>

</FORM>
</BODY>
</HTML>
