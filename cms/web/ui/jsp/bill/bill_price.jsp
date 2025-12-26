<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.imc.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
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
	<script language="javascript">
	function ExportWin(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,location=no,status=yes,height=600,width=500';
		SmallWin = window.open(freshurl,'ExportWin',window_features);
	}
	</script>
<BODY>
<%
	String YEAR1	= request.getParameter("year1");
	String MONTH1	= request.getParameter("month1");
	String DAY1	    = request.getParameter("day1");
	String YEAR2	= request.getParameter("year2");
	String MONTH2	= request.getParameter("month2");
	String DAY2	    = request.getParameter("day2");
	String CUSTOMER = request.getParameter("customer");
	String PARTNER  = request.getParameter("partner");
	String CALC     = request.getParameter("calc");
	String EXPORT   = request.getParameter("export");
	String FILENAME = request.getParameter("filename");
	String DELIMITER= request.getParameter("delim");

    //System.out.println("date from =" + YEAR1 + "-" + MONTH1 + "-" + DAY1 + " to " + YEAR2 + "-" + MONTH2 + "-" + DAY2);
    //System.out.println("customer= " + CUSTOMER);
    //System.out.println("partner= " + PARTNER);
    //System.out.println("export= " + EXPORT);
    //System.out.println("filename= " + FILENAME);
    //System.out.println("delim= " + DELIMITER);

    if ((CUSTOMER.length() == 0) && (PARTNER.length() == 0)) {
		out.println("<h3>You must select either a partner or a customer!</h3>");
		out.println("Please back up your browser.");
		return;
	}

	BufferedWriter fileOut = null;
    String s_file_name = null;
    String s_file_url = null;
    boolean doExport = false;
    if (EXPORT != null && EXPORT.equals("on")) {
        doExport=true;
		if (FILENAME != null && !FILENAME.equals("") ) {
			FILENAME = FILENAME.trim();		
            if (!FILENAME.toLowerCase().endsWith(".txt")) {
				FILENAME = FILENAME + ".txt";
			}
		}
        else
        {
            FILENAME = "export_" + 	((new java.util.Date()).getTime()) + ".txt";
        }

		if (DELIMITER == null) DELIMITER = ",";
		else if (DELIMITER.equals ("TAB")) DELIMITER = "\t";
		
		String sExportDir = Registry.getKey("sas_export_dir");
		if (sExportDir == null)
		{
			throw new Exception("'sas_export_dir' key is not found in registry");
			// sExportDir = "D:\\britemoon\\adm\\web\\export\\";
		}
		String sExportUrl = Registry.getKey("sas_export_url");
		if (sExportUrl == null)
		{
			throw new Exception("'sas_export_url' key is not found in registry");
			// sExportUrl = "http://192.168.0.226:80/sadm/export/";
		}

		s_file_name = sExportDir + FILENAME;
		s_file_url = sExportUrl + FILENAME;
		
		fileOut = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(s_file_name,false),"ISO-8859-1"));
		fileOut.write("Partner Name"+DELIMITER+"Client Name"+DELIMITER+"Bill Plan"+DELIMITER+"Emails Sent This Period"+DELIMITER+"Total Sent Since Start of Term"+DELIMITER+"Extra Sent Since Start of Term"+DELIMITER+"Price of This Period"+DELIMITER+"Price of Extra Since Start of Term"+DELIMITER+"\r\n");
	}

	String sRequestXML = "";
	String sListXML = "";
	
    String sDateFrom =  YEAR1 + "-" + MONTH1 + "-" + DAY1;
    String sDateTo =  YEAR2 + "-" + MONTH2 + "-" + DAY2;

	ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    String sql = null;
    try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
		String[] custList = null;
		Vector vec = new Vector();
		if ( CUSTOMER.length() == 0 ) {
			//load all of the customers for specified partner
			if ( PARTNER.equals("0") ) {
				sql =
					"SELECT DISTINCT c.cust_id, c.cust_name " +
					"  FROM ccps_cust_partner cp, ccps_customer c" +
					" WHERE cp.cust_id = c.cust_id" +
					"   AND c.status_id = 3 " +
					" ORDER BY c.cust_name ASC";
			}
			else {
				sql = 
					"SELECT DISTINCT c.cust_id, c.cust_name " +
					"  FROM ccps_cust_partner cp, ccps_customer c" +
					" WHERE cp.partner_id = " + PARTNER +
					"   AND cp.cust_id = c.cust_id" +
					"   AND c.status_id = 3 " +
					" ORDER BY c.cust_name ASC";				
			}
			rs = stmt.executeQuery(sql);
			while (rs.next()) {
				vec.add(rs.getString(1));
			}
			rs.close();			
			if (vec.size() == 0) {
				out.println("<h3> That partner has no customers assigned to it!</h3>");
				out.println("Please add customers to that partner and try again.");
				return;
			}
			custList = new String[vec.size()];
			vec.copyInto(custList);
		}
		else if ( CUSTOMER.equals("0") ) {
			//load all of the customers
			sql =
				"SELECT DISTINCT cust_id, cust_name " +
				"  FROM ccps_customer " +
				" WHERE status_id = 3 " +
				" ORDER BY cust_name ASC";
			rs = stmt.executeQuery(sql);
			while (rs.next()) {
				vec.add(rs.getString(1));
			}
			rs.close();			
			if (vec.size() == 0) {
				out.println("<h3> There are no customers available in the system!</h3>");
				return;
			}
			custList = new String[vec.size()];
			vec.copyInto(custList);
		}
		else {
			custList = CUSTOMER.split(",");
		}
%>
  <br>
    <center><b>Billing Summary&nbsp;&nbsp;(from <%=sDateFrom%> to <%=sDateTo%>)</b></center>
  <br>
  <table class="main" cellpadding="0" cellspacing="0" border="0" width="100%">
<%
		if (doExport) {
%>
    <tr>
      <td align="left" valign="middle" colspan="6">
			Right-click on the Export names below and select [Save Target As...] to <FONT COLOR="RED">download the export</FONT> onto your local computer.
			<br>
			Click on the Preview buttons to preview the export.
      </td>
    </tr>
    <tr>
      <td>
	      Export Name: &nbsp; &nbsp; <a href="<%=s_file_url%>"><%=FILENAME%></a>
          <a class="resourcebutton" href="javascript:ExportWin('<%=s_file_url%>');">Preview</a>
      </td>
    </tr>
<%
		}
%>
    <tr>
      <td align="left" valign="top" style="padding:0px;">
        <table class="listTable" cellpadding="0" cellspacing="0" border="0" width="100%">
	      <tr>
	        <th align="left"  valign="middle" width=20%>&nbsp;&nbsp;Partner Name</th>
            <th align="left"  valign="middle" width=20%>&nbsp;&nbsp;Client Name</th>
            <th align="right" valign="middle" width=10%>&nbsp;&nbsp;Bill Plan&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=10%>Emails Sent This Period</th>
            <th align="right" valign="middle" width=10%>Total Sent Since Start of Term</th>
            <th align="right" valign="middle" width=10%>Extra Sent Since Start of Term</th>
            <th align="right" valign="middle" width=10%>Price of This Period</th>
            <th align="right" valign="middle" width=10%>Price of Extra Since Start of Term</th>
          </tr>
<%		
		byte[] bVal		= new byte [8000];
		String sVal		= null;
		StringWriter sw = new StringWriter();
																								   
	    String sPartnerName = null;
		String sCustName = null;
		String sCustId = null;
		String sSent = null;
		String sPlan = null;
        int iMaxVolume = 0;
        int iAccruedVolume = 0;
        int iExtraVolume = 0;
        String sTermStartDate = null;
		String sPrice = null;
		String sExtraPrice = null;
		Element eRoot = null;

		for (int n=0; n < custList.length; n++) {			
			sCustId = custList[n];
			sql =
				" SELECT c.cust_name, p.partner_name, pl.plan_name, " +
				"        ISNULL(cpl.term,0) * ISNULL(cpl.volume,0), " +
				"        ISNULL(CONVERT(VARCHAR(32),cpl.term_start_date, 120), '---') " +
				"   FROM ccps_customer c " +
				"   LEFT OUTER JOIN  ccps_cust_partner cp ON c.cust_id = cp.cust_id " +
				"   LEFT JOIN ccps_partner p ON cp.partner_id = p.partner_id " +
				"   LEFT JOIN sadm_cust_plan cpl ON c.cust_id = cpl.cust_id " +
				"   LEFT JOIN sadm_plan pl ON cpl.plan_id = pl.plan_id " +
				"  WHERE c.cust_id = " + sCustId;
			rs = stmt.executeQuery(sql);
			if (rs.next()) {
				sCustName = rs.getString(1);
				sPartnerName = rs.getString(2);
				sPlan = rs.getString(3);
                iMaxVolume = rs.getInt(4);
                sTermStartDate = rs.getString(5);
			}
			rs.close();
			if (sPartnerName == null) {
				sPartnerName = "Direct";
			}

			// get deliveries stats from RCP for each client
            sRequestXML = "";
			sRequestXML += "<Request>\r\n";
			sRequestXML += "  <customer>"+sCustId+"</customer>\r\n";
			sRequestXML += "  <dateFrom>"+sDateFrom+"</dateFrom>\r\n";
			sRequestXML += "  <dateTo>"+sDateTo+"</dateTo>\r\n";
			sRequestXML += "</Request>\r\n";

		    Exception saved_ex = null;
			try {
				//System.out.println("Sending request=\n" + sRequestXML);			
				sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
				// second try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
				}
				// third try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
				}				
				// fourth try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
				}
				// fifth try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
				}
				//System.out.println("Getting response=\n" + sListXML);
			}
			catch(Exception ex) {
				saved_ex = ex;
			}

			// should we give up?
			if (sListXML == null || sListXML.length() == 0) {
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=20%>&nbsp;&nbsp;<%=sPartnerName%></a></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=20% nowrap>&nbsp;&nbsp;<%=sCustName%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sPlan%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right"  valign="middle" width=10% nowrap>&nbsp;&nbsp;RCP Error:<%=saved_ex.getMessage()%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;--&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;--&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;--&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;--&nbsp;&nbsp;</td>
	      </tr>
<%
			    continue;																													 
			}

			eRoot = XmlUtil.getRootElement(sListXML);
			sSent = XmlUtil.getChildTextValue(eRoot,"Sent");
            // find accrued volume since term started
			iAccruedVolume = 0;
			iExtraVolume = 0;
            if (iMaxVolume > 0) {
	            sRequestXML = "";	
				sRequestXML += "<Request>\r\n";
				sRequestXML += "  <customer>"+sCustId+"</customer>\r\n";
				sRequestXML += "  <dateFrom>"+sTermStartDate+"</dateFrom>\r\n";
				sRequestXML += "  <dateTo>"+sDateTo+"</dateTo>\r\n";
				sRequestXML += "</Request>\r\n";

				sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
			    saved_ex = null;
				try {
					//System.out.println("Sending request=\n" + sRequestXML);			
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
					// second try
					if (sListXML == null || sListXML.length() == 0) {
						sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
					}
					// third try
					if (sListXML == null || sListXML.length() == 0) {
						sListXML = Service.communicate(ServiceType.RRCP_BILLING_CLIENT_REPORT, sCustId, sRequestXML);
					}				
					//System.out.println("Getting response=\n" + sListXML);
				}
				catch(Exception ex) {
					saved_ex = ex;
				}
				
				// should we give up?
				if (sListXML == null || sListXML.length() == 0) {
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=20%>&nbsp;&nbsp;<%=sPartnerName%></a></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=20% nowrap>&nbsp;&nbsp;<%=sCustName%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sPlan%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sSent%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right"  valign="middle" width=10% nowrap>&nbsp;&nbsp;RCP Error:<%=saved_ex.getMessage()%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;--&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;--&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;--&nbsp;&nbsp;</td>
	      </tr>
<%
			        continue;																													 
				}
				eRoot = XmlUtil.getRootElement(sListXML);
	        	iAccruedVolume = Integer.parseInt(XmlUtil.getChildTextValue(eRoot,"Sent"));
                if (iAccruedVolume > iMaxVolume) {
					iExtraVolume = iAccruedVolume - iMaxVolume;
				}
            }

			// calc price
			if (sPlan != null) {
				sql = " EXEC usp_sadm_bill_calc @cust_id=" + sCustId + ", @sent=" + sSent + ", @extra=" + iExtraVolume;
				rs = stmt.executeQuery(sql);
				if (rs.next()) {
					sPrice = rs.getString(1);
					sExtraPrice = rs.getString(2);
				}
			    rs.close();
			}
            if (doExport) {
		        fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+sPlan+DELIMITER+sSent+DELIMITER+iAccruedVolume+DELIMITER+iExtraVolume+DELIMITER+sPrice+DELIMITER+sExtraPrice+"\r\n");
			}
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=20%>&nbsp;&nbsp;<%=sPartnerName%></a></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=20% nowrap>&nbsp;&nbsp;<%=sCustName%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sPlan%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sSent%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=iAccruedVolume%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=iExtraVolume%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sPrice%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=sExtraPrice%>&nbsp;&nbsp;</td>
	      </tr>
<%
       }
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
		if (fileOut!=null) {
			fileOut.flush();
			fileOut.close();
		}
	    if(conn!=null) cp.free(conn);
    }
%>
</BODY>
</HTML>
