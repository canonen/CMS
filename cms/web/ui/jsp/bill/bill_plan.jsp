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

<script language="JavaScript">

function update (custId)
{
	if (custId == "") return;
	FT.customer.value = custId;
	FT.submit ();
}

</script>	    

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
    String sql = null;

%>

<BODY>

<FORM  METHOD="POST" NAME="FT" ACTION="bill_plan_update.jsp" TARGET="_self">
<input type=hidden name=customer value="">
<table>
  <br>
    <center><b>Customer Billing Plans</b></center>
  <br>
  <table class="main" cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
      <td align="left" valign="top" style="padding:0px;">
        <table class="listTable" cellpadding="0" cellspacing="0" border="0" width="100%">
	      <tr>
	        <th align="left" valign="middle" width=30%>&nbsp;&nbsp;Partner Name</th>
            <th align="left" valign="middle" width=20% nowrap>&nbsp;&nbsp;Client Name</th>
            <th align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;Bill Plan&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=5% nowrap>&nbsp;&nbsp;Monthly Volume&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=5% nowrap>&nbsp;&nbsp;Terms&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;Start Date&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=20% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</th>
          </tr>
<%
    try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("mod_customer.jsp");
		stmt = conn.createStatement();
		sql =		
			"SELECT c.cust_id, c.cust_name, p.partner_name, pl.plan_name, cpl.volume, cpl.term, isnull(CONVERT(VARCHAR(32),cpl.term_start_date, 100), '---') " +
			"  FROM sadm_customer c " +
			"  LEFT OUTER JOIN  sadm_cust_partner cp ON c.cust_id = cp.cust_id " +
			"  LEFT JOIN sadm_partner p ON cp.partner_id = p.partner_id " +
			"  LEFT JOIN sadm_cust_plan cpl ON c.cust_id = cpl.cust_id " +
			"  LEFT JOIN sadm_plan pl ON cpl.plan_id = pl.plan_id " +
			" WHERE c.status_id = 3" +
			" ORDER BY c.cust_name";
		rs = stmt.executeQuery (sql);
		String sCustId = null;
		String sCustName = null;
		String sPartnerName = null;
		String sPlanName = null;
		String sVolume = null;
		String sTerm = null;
		String sStartDate = null;
		while ( rs.next() ) {
			sCustId = rs.getString(1);
			sCustName = rs.getString(2);
			sPartnerName = rs.getString(3);
			sPlanName = rs.getString(4);
			sVolume = rs.getString(5);
			sTerm = rs.getString(6);
			sStartDate = rs.getString(7);
			if (sPartnerName == null) {
				sPartnerName = "Direct";
			}
			if (sPlanName == null) {
				sPlanName = "---";
			}
			if (sVolume == null) {
				sVolume = "---";
			}
			if (sTerm == null) {
				sTerm = "---";
			}
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=30%>&nbsp;&nbsp;<%=sPartnerName%></a></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=20% nowrap>&nbsp;&nbsp;<%=sCustName%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sPlanName%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=5% nowrap>&nbsp;&nbsp;<%=sVolume%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=5% nowrap>&nbsp;&nbsp;<%=sTerm%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sStartDate%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=20% nowrap>&nbsp;&nbsp;<input type="button" value="view detail or update" onClick="update('<%=sCustId%>');">&nbsp;&nbsp;</td>
	      </tr>
<%
		}
		rs.close();
%>
        </table>
      </td>
    </tr>                           
  </table>
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
