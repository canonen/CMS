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
<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<TITLE>Billing Summary</TITLE>
	<%@ include file="../header.html" %>
    <link rel="stylesheet" href="/sadm/adm/css/style.css" type="text/css">
    <script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
    <script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>
</HEAD>

<SCRIPT>
function update()
{
	if (!validate_date()) {
		return;
	}
	if (FT.plan.value == "2" || FT.plan.value == "3") {
		if (!parseInt(FT.volume.value)) {
			alert("Invalid monthly volume");
			return;			  
		}
		if (parseInt(FT.volume.value) < 0) {
			alert("Negative monthly volume");
			return;			  
		}
		if (!parseInt(FT.term.value)) {
			alert("Invalid terms of commitment");
			return;			  
		}
		if (parseInt(FT.term.value) < 0) {
			alert("Negative terms of commitment");
			return;			  
		}
	}
    FT.save.value="1";
	FT.submit ();
}

function validate_date ()
{
	if (!is_data_correct (FT.day.value, FT.month.value, FT.year.value)) {
		alert ("Error: Term starting date is out of range");
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
    int selectedDay   = rightNow.get (Calendar.DAY_OF_MONTH);
    int selectedMonth = rightNow.get (Calendar.MONTH) + 1;
    int selectedYear  = rightNow.get (Calendar.YEAR);

	String CUSTOMER = request.getParameter("customer");
    if (CUSTOMER.length() == 0) {
		out.println("<h3>Attempting to update invalid customer!</h3>");
		out.println("Please back up your browser.");
		return;
	}

    String SAVE = request.getParameter("save");
	String YEAR = request.getParameter("year");
	String MONTH = request.getParameter("month");
	String DAY = request.getParameter("day");
	String PLAN = request.getParameter("plan");
    String VOLUME = request.getParameter("volume");
    String TERM = request.getParameter("term");

	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null; 
	String sClassAppend = "";
    String sql = null;

%>

<BODY>

<FORM  METHOD="POST" NAME="FT" ACTION="bill_plan_update.jsp" TARGET="_self">
<H2>Customer Billing Plan</H2>
<%
    try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("mod_customer.jsp");
		stmt = conn.createStatement();
        // see if we need to save data first
		if (SAVE != null && SAVE.equals("1")) {
			sql = 
				"DELETE FROM sadm_cust_plan " +
				" WHERE cust_id = " + CUSTOMER;
			int rc = stmt.executeUpdate(sql);			
			if ( PLAN.equals("3") || PLAN.equals("2") ) {
				sql = 
					"INSERT INTO sadm_cust_plan (cust_id, plan_id, term_start_date, term, volume) " +
					" VALUES (" + CUSTOMER + "," + PLAN + ",'" + YEAR + "-" + MONTH + "-" + DAY + "'," + TERM + "," + VOLUME + ")";
			}
			else {
				sql = 
					"INSERT INTO sadm_cust_plan (cust_id, plan_id, term_start_date, term, volume) " +
					" VALUES (" + CUSTOMER + "," + PLAN + ", '" + YEAR + "-" + MONTH + "-" + DAY + "',null,null)";
			}
			int rc2 = stmt.executeUpdate(sql);
		}
        // get updated data
		sql =		
			"SELECT c.cust_name, p.partner_name, pl.plan_id, pl.plan_name, cpl.volume, cpl.term, " +
		    "       YEAR(cpl.term_start_date), MONTH(cpl.term_start_date), DAY(cpl.term_start_date) " + 
			"  FROM sadm_customer c " +
			"  LEFT OUTER JOIN  sadm_cust_partner cp ON c.cust_id = cp.cust_id " +
			"  LEFT JOIN sadm_partner p ON cp.partner_id = p.partner_id " +
			"  LEFT JOIN sadm_cust_plan cpl ON c.cust_id = cpl.cust_id " +
			"  LEFT JOIN sadm_plan pl ON cpl.plan_id = pl.plan_id " +
			" WHERE c.cust_id = " + CUSTOMER;
		rs = stmt.executeQuery (sql);
		String sCustName = null;
		String sPartnerName = null;
		String sPlanId = null;
		String sPlanName = null;
		String sVolume = null;
		String sTerm = null;
		int iStartYear = 0;
		int iStartMonth = 0;
		int iStartDay = 0;
		if ( rs.next() ) {
			sCustName = rs.getString(1);
			sPartnerName = rs.getString(2);
			sPlanId = rs.getString(3);
			sPlanName = rs.getString(4);
			sVolume = rs.getString(5);
			sTerm = rs.getString(6);
			iStartYear = rs.getInt(7);
			iStartMonth = rs.getInt(8);
			iStartDay = rs.getInt(9);
			if (sPartnerName == null) {
				sPartnerName = "Direct";
			}
			if (sVolume == null) {
				sVolume = "";
			}
			if (sTerm == null) {
				sTerm = "";
			}
            if (iStartYear > 0) {
				selectedYear = iStartYear;
				selectedMonth = iStartMonth;
				selectedDay = iStartDay;
			}
		}
		rs.close();
%>
<INPUT type="hidden" name="customer" value="<%=CUSTOMER%>">
Customer: <B><%=sCustName%></B><BR>
Partner: <B><%=sPartnerName%></B><BR>
Select customer:
<SELECT NAME="plan">
<OPTION VALUE="" SELECTED > &lt;----- Select Plan -----&gt; </OPTION>
<%
	rs = stmt.executeQuery ("SELECT plan_id, plan_name FROM sadm_plan");
	while ( rs.next() ) {
        String id = rs.getString(1); 
        String name = rs.getString(2); 
		%><OPTION VALUE="<%=id%>" <%=(id.equals(sPlanId) ?  "SELECTED" : "")%> > <%=name%> </OPTION><%
	}
	rs.close();
%>
</SELECT>
<BR>
Monthly Volume:
<INPUT TYPE=text NAME="volume" value="<%=sVolume%>">
<BR>
Terms of commitment:
<INPUT TYPE=text NAME="term" value="<%=sTerm%>"> in months
<BR>
Term Starting Date:
<SELECT NAME="month">
<%
  for (int i=1 ; i <= 12; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==selectedMonth) ?  "SELECTED" : ""%> ><%=Months [i]%></OPTION><%
  }
%>
</SELECT>
<SELECT NAME="day">
<%
  for (int i=1 ; i <= 31; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==selectedDay) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
</SELECT>
<SELECT NAME="year">
<%
  for (int i=2002 ; i <= 2007; i ++)
  {
	%><OPTION VALUE="<%=i%>" <%=(i==selectedYear) ?  "SELECTED" : ""%> ><%=i%></OPTION><%
  }
%>
<BR>
<INPUT type="hidden" name="save" value="0">
<BR>
<INPUT type="button" value="update" onClick="update();" alt="update">
<%  }
	catch(Exception ex) {
	    ex.printStackTrace(response.getWriter());
	    logger.error("Exception: ",ex);
    }
    finally {
	    if(conn!=null) cp.free(conn);
    }
%>
</FORM>
</BODY>
</HTML>
