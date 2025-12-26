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
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
%>
<HTML>

<HEAD>
	<TITLE>Billing Summary</TITLE>
	<%@ include file="../header.html" %>
    <script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
    <script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<SCRIPT>
function get_summary ()
{
	if (!validate_date()) {
		return;
	}
	FT.action = "bill_summary.jsp";
	FT.submit ();
}

function get_price ()
{
	if (!validate_date()) {
		return;
	}
	FT.action = "bill_price.jsp";
	FT.submit ();
}

function get_detail ()
{
	if (!validate_date()) {
		return;
	}
	FT.action = "bill_detail.jsp";
	FT.submit ();
}

function get_exp_list ()
{
	FT.action = "bill_exp_list.jsp";
	FT.submit ();
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
		} else if (year - 0 == 2012) {
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

	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null; 
	String sClassAppend = "";
    String sSQL = null;

    try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("mod_customer.jsp");
		stmt = conn.createStatement();

%>

<BODY>
<%


%>
<FORM  METHOD="POST" NAME="FT" ACTION="bill_form.jsp" TARGET="_self">

<div class="page_header">Billing Summary</div>
<div class="page_desc">See how many emails sent per campaing over your system</div>

<table cellpadding="10" cellspacing="0" width="100%" border="0" class="listTable">
<tr>
	<th>Billing Summary</th>
</tr>
<tr>
<td>
Date: from &nbsp 
<SELECT NAME="month1">
<%
  for (int i=1 ; i <= 12; i ++) {
	%><OPTION VALUE="<%=i%>" <%=(i==1) ?  "SELECTED" : ""%> ><%=Months [i]%>(<%=i%>)</OPTION><%
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
  for (int i=2009 ; i <= 2030; i ++)
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
	%><OPTION VALUE="<%=i%>" <%=(i==todayMonth) ?  "SELECTED" : ""%> ><%=Months [i]%>(<%=i%>)</OPTION><%
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
  for (int i=2009 ; i <= 2030; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==todayYear) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
</SELECT> 
</td>
</tr>
<tr>
<td>
<input type="hidden" name="customer" value="<%=cust.s_cust_id%>"/>
<input type="hidden" name="partner" value=""/>
<INPUT TYPE="checkbox" NAME="export">generate export named
<INPUT TYPE="text" NAME="filename" size=25 style="font-size:11px;font-family:Tahoma;padding:3px;border:1px solid #000000;color:#4F4F4F;">&nbsp;with delimiter
<INPUT TYPE="radio" NAME="delim" VALUE="TAB" CHECKED>Tab
<INPUT TYPE="radio" NAME="delim" VALUE=";">Semicolon (;)
<INPUT TYPE="radio" NAME="delim" VALUE=",">Comma (,)
<INPUT TYPE="radio" NAME="delim" VALUE="|">Pipe (|)
</td>
</tr>
<tr>
<td>
<a class="button_res" href="#" onClick="get_summary();">Delivery Summary</a>
<a class="button_res" href="#"  onClick="get_detail();">Campaign Summary</a>
<BR><BR>

To get the list of all previosly generated exports, click the following button
<BR><BR>
<a class="button_res" href="#"  onClick="get_exp_list();">Previous Exports</a>


</td>
</tr>
</table>
</FORM>
<%  }
	catch(Exception ex) {
	    ex.printStackTrace(response.getWriter());
	    logger.error("Exception: ",ex);
    }
    finally {
	    if(conn!=null) cp.free(conn);
    }
%>
</BODY>
</HTML>
