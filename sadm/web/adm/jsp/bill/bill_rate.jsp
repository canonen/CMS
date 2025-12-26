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

function delete1(vol)
{
	if (!parseInt(vol)) {
		alert("Trying to delete invalid monthly emails under");
		return;
	}
    FT.action.value="1";
    FT.plan.value="1";
    FT.volume.value=vol;
	FT.submit();
}
function delete2(vol)
{
	if (!parseInt(vol)) {
		alert("Trying to delete invalid monthly emails under");
		return;
	}
    FT.action.value="1";
    FT.plan.value="2";
    FT.volume.value=vol;
	FT.submit();
}
function delete3(vol)
{
	if (!parseInt(vol)) {
		alert("Trying to delete invalid monthly emails under");
		return;
	}
    FT.action.value="1";
    FT.plan.value="3";
    FT.volume.value=vol;
	FT.submit();
}

function add1()
{
	if (!parseInt(FT.volume1.value)) {
		alert("Trying to add invalid monthly emails under");
		return;			  
	}
    if (parseInt(FT.volume1.value) < 0) {
		alert("Trying to add negative monthly emails under");
		return;			  
	}
	if (!parseFloat(FT.each1.value)) {
		alert("Trying to add invalid cost per email in cents");
		return;			  
	}
	cc_each = Math.round(parseFloat(FT.each1.value) * 100); 
	if (cc_each < 0) {
		alert("Trying to add negative cost per email in cents");
		return;			  
	}
    FT.action.value="2";
    FT.plan.value="1";
    FT.volume.value=FT.volume1.value;
    FT.each.value=cc_each;
	FT.submit();
}

function add2()
{
	var cc_each = 0;
	var cc_extra = 0;
	if (!parseInt(FT.volume2.value)) {
		alert("Trying to add invalid monthly emails under");
		return;			  
	}
    if (parseInt(FT.volume2.value) < 0) {
		alert("Trying to add invalid monthly emails under");
		return;			  
	}
	if (!parseFloat(FT.each2.value)) {
		alert("Trying to add invalid cost per email in cents");
		return;			  
	}
	cc_each = Math.round(parseFloat(FT.each2.value) * 100); 
	if (cc_each < 0) {
		alert("Trying to add negative cost per email in cents");
		return;			  
	}
	if (!parseFloat(FT.extra2.value)) {
		alert("Trying to add invalid cost per extra email in cents");
		return;			  
	}
	cc_extra = Math.round(parseFloat(FT.extra2.value) * 100); 
	if (cc_extra < 0) {
		alert("Trying to add negative cost per extra email in cents");
		return;			  
	}
    FT.action.value="2";
    FT.plan.value="2";
    FT.volume.value=FT.volume2.value;
    FT.each.value=cc_each;
    FT.extra.value=cc_extra;
	FT.submit();
}

function add3()
{
	var cc_each = 0;
	var cc_extra = 0;
	if (!parseInt(FT.volume3.value)) {
		alert("Trying to add invalid monthly emails under");
		return;			  
	}
    if (parseInt(FT.volume3.value) < 0) {
		alert("Trying to add invalid monthly emails under");
		return;			  
	}
	if (!parseFloat(FT.each3.value)) {
		alert("Trying to add invalid cost per month in dollars");
		return;			  
	}
	cc_each = Math.round(parseFloat(FT.each3.value) * 10000); 
	if (cc_each < 0) {
		alert("Trying to add negative cost per mothn in dollars");
		return;			  
	}
	if (!parseFloat(FT.extra3.value)) {
		alert("Trying to add invalid cost per extra email in cents");
		return;			  
	}
	cc_extra = Math.round(parseFloat(FT.extra3.value) * 100); 
	if (cc_extra < 0) {
		alert("Trying to add negative cost per extra email in cents");
		return;			  
	}
    FT.action.value="2";
    FT.plan.value="3";
    FT.volume.value=FT.volume3.value;
    FT.each.value=cc_each;
    FT.extra.value=cc_extra;
	FT.submit();
}

</SCRIPT>
<%
    String ACTION = request.getParameter("action");
	String PLAN = request.getParameter("plan");
	String VOLUME = request.getParameter("volume");
	String EACH = request.getParameter("each");
	String EXTRA = request.getParameter("extra");

    //System.out.println("EACH="+EACH);
    //System.out.println("EXTRA="+EXTRA);

	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null; 
	String sClassAppend = "";
    String sql = null;
%>

<BODY>
<FORM  METHOD="POST" NAME="FT" ACTION="bill_rate.jsp" TARGET="_self">
<input type=hidden name="action" value="">
<input type=hidden name="plan" value="">
<input type=hidden name="volume" value="">
<input type=hidden name="each" value="">
<input type=hidden name="extra" value="">
<table>
  <br>
    <center><b>Revotas Billing Rates</b></center>
  <br>
  <table class="main" cellpadding="0" cellspacing="0" border="0" width="100%">
<%
    try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("mod_customer.jsp");
		stmt = conn.createStatement();
		String sPlanId = null;
		String sPlanName = null;
		String sVolume = null;
		String sCcEach = null;
		String sCcVolume = null;
		String sCcExtra = null;
		String sDlEach = null;
		String sDlVolume = null;
		String sDlExtra = null;

        // see if we need to delete data
		if ( (ACTION != null) && (ACTION.equals("1")) ) {
			if (PLAN != null && VOLUME != null) {
				int plan = Integer.parseInt(PLAN);
				int volume = Integer.parseInt(VOLUME);
				sql = 
					"DELETE FROM sadm_rate " +
					" WHERE plan_id = " + plan + 
					"   AND volume = " + volume;
				int rc = stmt.executeUpdate(sql);
			}
		}

        // see if we need to add data
		if ( (ACTION != null) && (ACTION.equals("2")) ) {
			if ( (PLAN != null) && (PLAN.equals("1")) ) {
				int plan = Integer.parseInt(PLAN);
				int volume = Integer.parseInt(VOLUME);
				int cc_each = Integer.parseInt(EACH);
				sql = 
				    "DELETE FROM sadm_rate " +
					" WHERE plan_id = " + plan + 
					"   AND volume = " + volume;
				int rc = stmt.executeUpdate(sql);
				sql = 
				    "INSERT INTO sadm_rate (plan_id, volume, cc_each, cc_volume, cc_extra) " +
				"VALUES (" + plan + "," + volume + "," + cc_each  + ",null,null)";
				rc = stmt.executeUpdate(sql);
			}
			if ( (PLAN != null) && (PLAN.equals("2")) ) {
				int plan = Integer.parseInt(PLAN);
				int volume = Integer.parseInt(VOLUME);
				int cc_each = Integer.parseInt(EACH);
				int cc_extra = Integer.parseInt(EXTRA);
				sql = 
				    "DELETE FROM sadm_rate " +
					" WHERE plan_id = " + plan + 
					"   AND volume = " + volume;
				int rc = stmt.executeUpdate(sql);
				sql = 
				    "INSERT INTO sadm_rate (plan_id, volume, cc_each, cc_volume, cc_extra) " +
				"VALUES (" + plan + "," + volume + "," + cc_each  + ",null," + cc_extra + ")";
				rc = stmt.executeUpdate(sql);
			}
			if ( (PLAN != null) && (PLAN.equals("3")) ) {
				int plan = Integer.parseInt(PLAN);
				int volume = Integer.parseInt(VOLUME);
				int cc_each = Integer.parseInt(EACH);
				int cc_extra = Integer.parseInt(EXTRA);
				sql = 
				    "DELETE FROM sadm_rate " +
					" WHERE plan_id = " + plan + 
					"   AND volume = " + volume;
				int rc = stmt.executeUpdate(sql);
				sql = 
				    "INSERT INTO sadm_rate (plan_id, volume, cc_each, cc_volume, cc_extra) " +
				"VALUES (" + plan + "," + volume + ",null," + cc_each  + "," + cc_extra + ")";
				rc = stmt.executeUpdate(sql);
			}
		}

        // get updated data

		// Revotas Plan A
        sPlanId = "1";
%>
    <tr>
	  <td align=middle>
		<b>Revotas Plan A (a la carte)</b>
	  </td>
    </tr>
    <tr>
      <td align="left" valign="top" style="padding:0px;">
        <table class="listTable" cellpadding="0" cellspacing="0" border="0" width="100%">
	      <tr>
            <th align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;Monthly emails under&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;Cost per email in cents&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</th>
          </tr>
<%
		sql =
			"SELECT p.plan_id, p.plan_name, r.volume, r.cc_each, CAST(CAST(r.cc_each/100.0 AS MONEY) AS VARCHAR(25)) " +
			"  FROM sadm_plan p " +
			"  LEFT OUTER JOIN  sadm_rate r ON p.plan_id = r.plan_id " +
			" WHERE p.plan_id = " + sPlanId +
		" ORDER BY p.plan_id, r.volume";
		rs = stmt.executeQuery (sql);
		while ( rs.next() ) {
			sPlanId = rs.getString(1);
			sPlanName = rs.getString(2);
			sVolume = rs.getString(3);
			sCcEach = rs.getString(4);
			sDlEach = rs.getString(5);
%>
	      <tr>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sVolume%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sDlEach%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<input type="button" value="delete" onClick="delete1('<%=sVolume%>');">&nbsp;&nbsp;</td>
	      </tr>
<%
		}
		rs.close();
%>
          <tr> 
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="volume1" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="each1" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<input type="button" value="add" onClick="add1();">&nbsp;&nbsp;</td>
	      </tr>
        </table>
      </td>
    </tr> 
<%                          
		// Revotas Plan B
        sPlanId = "2";
%>
    <tr>
	  <td align=middle>
		<b>Revotas Plan B (monthly commitment)</b>
	  </td>
    </tr>
    <tr>
      <td align="left" valign="top" style="padding:0px;">
        <table class="listTable" cellpadding="0" cellspacing="0" border="0" width="100%">
	      <tr>
            <th align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;Monthly emails under&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;Cost per email in cents&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;Cost per extra email in cents&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</th>
          </tr>
<%
		sql =
			"SELECT p.plan_id, p.plan_name, r.volume, r.cc_each, r.cc_extra, " +
		    "       CAST(CAST(r.cc_each/100.0 AS MONEY) AS VARCHAR(25)), " +
		    "       CAST(CAST(r.cc_extra/100.0 AS MONEY) AS VARCHAR(25)) " +
			"  FROM sadm_plan p " +
			"  LEFT OUTER JOIN  sadm_rate r ON p.plan_id = r.plan_id " +
			" WHERE p.plan_id = " + sPlanId +
		" ORDER BY p.plan_id, r.volume";
		rs = stmt.executeQuery (sql);
		while ( rs.next() ) {
			sPlanId = rs.getString(1);
			sPlanName = rs.getString(2);
			sVolume = rs.getString(3);
			sCcEach = rs.getString(4);
			sCcExtra = rs.getString(5);
			sDlEach = rs.getString(6);
			sDlExtra = rs.getString(7);
%>
	      <tr>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sVolume%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sDlEach%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sDlExtra%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<input type="button" value="delete" onClick="delete2('<%=sVolume%>');">&nbsp;&nbsp;</td>
	      </tr>
<%
		}
		rs.close();
%>
	      <tr>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="volume2" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="each2" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="extra2" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<input type="button" value="add" onClick="add2();">&nbsp;&nbsp;</td>
	      </tr>
        </table>
      </td>
    </tr>   
<%                        
		// MS CRM
        sPlanId = "3";
%>
    <tr>
	  <td align=middle>
		<b>MS CRM (monthly commitment)</b>
	  </td>
    </tr>
    <tr>
      <td align="left" valign="top" style="padding:0px;">
        <table class="listTable" cellpadding="0" cellspacing="0" border="0" width="100%">
	      <tr>
            <th align="right" valign="top" width=30% nowrap>&nbsp;&nbsp;Monthly emails under&nbsp;&nbsp;</th>
            <th align="right" valign="top" width=30% nowrap>&nbsp;&nbsp;Cost per month in dollars&nbsp;&nbsp;</th>
            <th align="right" valign="top" width=30% nowrap>&nbsp;&nbsp;Cost per extra email in cents&nbsp;&nbsp;</th>
            <th align="right" valign="top" width=10% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</th>
          </tr>
<%
		sql =
			"SELECT p.plan_id, p.plan_name, r.volume, r.cc_volume, r.cc_extra," +
		    "       CAST(CAST(r.cc_volume/10000.0 AS MONEY) AS VARCHAR(25)), " +
		    "       CAST(CAST(r.cc_extra/100.0 AS MONEY) AS VARCHAR(25)) " +
			"  FROM sadm_plan p " +
			"  LEFT OUTER JOIN  sadm_rate r ON p.plan_id = r.plan_id " +
			" WHERE p.plan_id = " + sPlanId +
		" ORDER BY p.plan_id, r.volume";
		rs = stmt.executeQuery (sql);
		while ( rs.next() ) {
			sPlanId = rs.getString(1);
			sPlanName = rs.getString(2);
			sVolume = rs.getString(3);
			sCcVolume = rs.getString(4);
			sCcExtra = rs.getString(5);
			sDlVolume = rs.getString(6);
			sDlExtra = rs.getString(7);
%>
	      <tr>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sVolume%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sDlVolume%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=sDlExtra%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<input type="button" value="delete" onClick="delete3('<%=sVolume%>');">&nbsp;&nbsp;</td>
	      </tr>
<%
		}
		rs.close();
%>
		  <tr>
            <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="volume3" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="each3" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;<input type=text name="extra3" value="">&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<input type="button" value="add" onClick="add3();">&nbsp;&nbsp;</td>
	      </tr>
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
</FROM>
</BODY>
</HTML>
