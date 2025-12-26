<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.net.*"
	import="java.sql.*"
	import="java.util.*"
	contentType="text/html;charset=UTF-8"%>

<%@ page import="org.apache.log4j.*"%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>

<%@ include file="../header.jsp"%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>

<%
String Months [] = { "", "January", "February", "March", "April", "May",
	"June", "July", "August", "September", "October", "November", "December"  };

Calendar rightNow = Calendar.getInstance();
int todayDay   = rightNow.get (Calendar.DAY_OF_MONTH);
int todayMonth = rightNow.get (Calendar.MONTH) + 1;
int todayYear  = rightNow.get (Calendar.YEAR);
%>
<BODY>
<H2>Revotas Internal Report</H2>
<BR>Select date range and / or set of customers / partners to browse.

<FORM  METHOD="POST" NAME="FT" ACTION="admin_camp_report.jsp" TARGET="_self">

Date: from &nbsp 
<SELECT NAME="month1">
<%
  for (int i=1 ; i <= 12; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==1) ?  "SELECTED" : ""%> ><%=Months [i]%></OPTION><%
  }
%>
</SELECT>
<SELECT NAME="day1">
<%
  for (int i=1 ; i <= 31; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==1) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
</SELECT>
<SELECT NAME="year1">
<%
  for (int i=2001 ; i <= 2005; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==2001) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
</SELECT> &nbsp 
to &nbsp 
<SELECT NAME="month2">
<%
  for (int i=1 ; i <= 12; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==todayMonth) ?  "SELECTED" : ""%> ><%=Months [i]%></OPTION><%
  }
%>
</SELECT>
<SELECT NAME="day2">
<%
  for (int i=1 ; i <= 31; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==todayDay) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
</SELECT>
<SELECT NAME="year2">
<%
  for (int i=2001 ; i <= 2005; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==todayYear) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
</SELECT> &nbsp &nbsp &nbsp
<BR><BR>
Select customer:
<SELECT NAME="customer">

<OPTION VALUE="" SELECTED > &lt;----- Select Customer -----&gt; </OPTION>
<OPTION VALUE="0" > ALL CUSTOMERS </OPTION>

<%
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool		cp				= null;
Connection			conn 			= null;

try
{

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("admin_camp_report_form.jsp");
	stmt = conn.createStatement();

	rs = stmt.executeQuery ("SELECT cust_id, cust_name FROM ccps_customer WHERE cust_id > 0");
	while ( rs.next() ) { 
		%><OPTION VALUE="<%=rs.getInt(1)%>"> <%=rs.getString(2)%> </OPTION><%
	}
	rs.close();
%>
</SELECT>
<BR>
&nbsp;&nbsp;&nbsp;&nbsp;
<b>---- OR ------</b>
<BR>
Select partner:&nbsp;&nbsp;&nbsp;
<SELECT NAME="partner">
<OPTION VALUE="" SELECTED > &lt;------ Select Partner -------&gt; </OPTION>
<OPTION VALUE="0" > ALL PARTNERS </OPTION>
<%
	rs = stmt.executeQuery ("SELECT partner_id, partner_name FROM ccps_partner");
	while ( rs.next() )
	{ 
		%><OPTION VALUE="<%=rs.getInt(1)%>"> <%=rs.getString(2)%> </OPTION><%
	}
	rs.close();
}
catch(Exception ex)
{ 
	logger.error("Admin Report Error", ex);
	throw ex;
}
finally
{
	try { if ( stmt != null ) stmt.close(); }
	catch (SQLException se) { }
	if ( conn  != null ) cp.free (conn); 
}
%>

</SELECT>

<BR><BR>

<IMG STYLE="cursor:hand" SRC="../../images/search.gif" onClick="try_submit();">
</FORM>
</BODY>

<SCRIPT>

function try_submit ()
{
 if (!is_data_correct (FT.day1.value, FT.month1.value, FT.year1.value))
 {
	alert ("Error: First date is out of range");  	return 0;
 }
 if (!is_data_correct (FT.day2.value, FT.month2.value, FT.year2.value))
 {
	alert ("Error: First date is out of range");  	return 0;
 }

 if (FT.year1.value - 0 > FT.year2.value - 0)
 {
	alert ("Start year can not be greater than End one");  	return 0;
 }
 if (FT.month1.value - 0 > FT.month2.value - 0 && FT.year1.value - 0 == FT.year2.value - 0)
 {
	alert ("Start month can not be greater than End one");  	return 0;
 }
 if (FT.day1.value - 0 > FT.day2.value - 0 && 
	FT.month1.value - 0 == FT.month2.value  - 0 && 
	FT.year1.value - 0 == FT.year2.value - 0)
 {
	alert ("Start day can not be greater than End one");  	return 0;
 }
 FT.submit ();
}


function is_data_correct (day, month, year)
{
 if (month - 0 == 1 || month - 0 == 3 || month - 0 == 5  || 
     month - 0 == 7 || month - 0 == 8 || month - 0 == 10 || month - 0 == 12)
	return true;
 if (month - 0 == 4 || month - 0 == 6 || month - 0 == 9  || month - 0 == 11)
 {
	if (day - 0 == 31)	return false;
	else			return true;
 }
 if (month - 0 == 2)
 {
	if (year - 0 == 2004)	
	{
		if (day - 0 > 29)	return false;
		else			return true;
	}
	else
	{
		if (day - 0 > 28)	return false;
		else			return true;
	}
 }
}
</SCRIPT>

</BODY>
</HTML>

