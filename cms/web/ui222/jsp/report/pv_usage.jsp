<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<TITLE>Delivery Audits Usage</TITLE>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script src="../../js/scripts.js"></script>
</HEAD>

<SCRIPT>
function get_usage ()
{
	if (!validate_date()) {
		return;
	}
	var y1 = FT.year1.value;
	var m1 = FT.month1.value; 
	var d1 = FT.day1.value; 
	var y2 = FT.year2.value; 
	var m2 = FT.month2.value; 
	var d2 = FT.day2.value;  
	document.all.report.src = 'pv_usage_get.jsp?year1=' + y1 + '&month1=' + m1 + '&day1=' + d1 + '&year2=' + y2 + '&month2=' + m2 + '&day2=' + d2;
}

function validate_date ()
{
	if (!is_data_correct (FT.day1.value, FT.month1.value, FT.year1.value)) {
		alert ("Error: First date is out of range");
		return false;
	}
	if (!is_data_correct (FT.day2.value, FT.month2.value, FT.year2.value)) {
		alert ("Error: First date is out of range");
		return false;
	}
	
	if (FT.year1.value - 0 > FT.year2.value - 0) {
		alert ("Start year can not be greater than End one");
		return false;
	}
	if (FT.month1.value - 0 > FT.month2.value - 0 && FT.year1.value - 0 == FT.year2.value - 0) {
		alert ("Start month can not be greater than End one");
		return false;
	}
	if (FT.day1.value - 0 > FT.day2.value - 0 && 
		FT.month1.value - 0 == FT.month2.value  - 0 && 
		FT.year1.value - 0 == FT.year2.value - 0) {
		alert ("Start day can not be greater than End one");
		return false;
	}
    return true;
}

function is_data_correct (day, month, year)
{
	if (month - 0 == 1 || month - 0 == 3 || month - 0 == 5  || 
		month - 0 == 7 || month - 0 == 8 || month - 0 == 10 || month - 0 == 12)
		return true;
	if (month - 0 == 4 || month - 0 == 6 || month - 0 == 9  || month - 0 == 11) {
		if (day - 0 == 31)
			return false;
		else
			return true;
	}
	if (month - 0 == 2) {
		if (year - 0 == 2004) {
			if (day - 0 > 29)	
				return false;
			else	
				return true;
		}
		else {
			if (day - 0 > 28)
				return false;
			else	
				return true;
		}
	}
}

</SCRIPT>

<%
    String Months [] = { "", "January", "February", "March", "April", "May", "June", "July", 
						 "August", "September", "October", "November", "December"  };
    Calendar rightNow = Calendar.getInstance();
    int todayDay   = rightNow.get (Calendar.DAY_OF_MONTH);
    int todayMonth = rightNow.get (Calendar.MONTH) + 1;
    int todayYear  = rightNow.get (Calendar.YEAR);
%>

<BODY>

<FORM  METHOD="POST" NAME="FT" ACTION="pv_usage_form.jsp" TARGET="_self">
Date:&nbsp;&nbsp; from &nbsp 
<SELECT NAME="month1">
<%
  for (int i=1 ; i <= 12; i ++) {
	%><OPTION VALUE="<%=i%>" <%=(i==todayMonth) ?  "SELECTED" : ""%> ><%=Months [i]%></OPTION><%
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
  for (int i=2002 ; i <= 2007; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==todayYear) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
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
  for (int i=2002 ; i <= 2007; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==todayYear) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
</SELECT> &nbsp; &nbsp;
<INPUT type="button" value="get usage" onClick="get_usage();">
</FORM>
<IFRAME name="report" src="pv_usage_get.jsp?year1=<%= todayYear %>&month1=<%= todayMonth %>&day1=<%= "1" %>&year2=<%= todayYear %>&month2=<%= todayMonth %>&day2=<%= todayDay %>" style="width:100%; height:100%;" frameborder="0" border="0" scrolling="auto"></IFRAME>
</BODY>
</HTML>
