<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.imc.*"
	import="com.britemoon.cps.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="java.security.MessageDigest"
	import="java.security.NoSuchAlgorithmException" 
	import="org.w3c.dom.*"
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


<%@page import="sun.misc.BASE64Encoder"%>
<%@page import="com.sun.org.apache.xerces.internal.impl.dv.util.Base64"%><HTML>

<HEAD>
	<TITLE>Billing Summary</TITLE>
	<%@ include file="../header.html" %>
    <script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
    <script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>
        <style>
    	html, body {
    		background-color:#4f4f4f;
    		color:#FFFFFF;
    		font-family:Tahoma;
    		font-size:11px;
    	}
    	#containerTable {
    		border:2px solid #3A3A3A;
    		border-collapse:collapse;
    	}
    	#containerTable td {
    		color:#FFFFFF;
    		font-family:Tahoma;
    		font-size:11px;
    	}
    	select {
    		padding:4px;
    		font-size:11px;
    		font-family:Tahoma;
    		color:#4F4F4F;
    		border:1px solid #000000;
    	}
    	h1 {
    		font-size:11px;
    		color:#FFCC00;
    		margin-bottom:5px;
    		margin-top:5px;
    		font-family:Tahoma;
    	}
    	.buttons {
    		background-color:#FFBA00;
    		color:#000000;
    		border:1px solid #FF9900;
    		font-size:11px;
    		font-family:Tahoma;
    		padding:1px;
    		text-decoration:none;
    	}
    	th {
    		text-decoration:underline;
    		font-size:11px;
    		font-family:Arial;
    		color:#FFFFFF;
    		background-color: #3A3A3A;
    	}
    	.innerContainerTable {
    		
    	}
    	.innerContainerTable td {
    		
    	}
    </style>
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
        else {
            FILENAME = "export_" + 	((new java.util.Date()).getTime()) + ".txt";
        }
		
		if (DELIMITER == null) DELIMITER = ",";
		else if (DELIMITER.equals ("TAB")) DELIMITER = "\t";
		
		String sExportDir = Registry.getKey("import_data_dir");
		if (sExportDir == null)
		{
			throw new Exception("'import_data_dir' key is not found in registry");
			// sExportDir = "D:\\britemoon\\adm\\web\\export\\";
		}
		String sExportUrl = Registry.getKey("import_url_dir");
		if (sExportUrl == null)
		{
			throw new Exception("'import_url_dir' key is not found in registry");
			// sExportUrl = "http://192.168.0.226:80/sadm/export/";
		}
		
		
		
		//Hash Customer ID
		
		String custIdHash = cust.s_cust_id;
		byte[] defaultBytes = custIdHash.getBytes();
		String hashId = "";
		
		try{
			MessageDigest algorithm = MessageDigest.getInstance("MD5");
			algorithm.reset();
			algorithm.update(defaultBytes);
			byte messageDigest[] = algorithm.digest();
		            
			StringBuffer hexString = new StringBuffer();
			for (int i=0;i<messageDigest.length;i++) {
				hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
			}
			
			hashId = hexString.toString();
			
		}catch(NoSuchAlgorithmException nsae){
		            
		}
		

		s_file_name = sExportDir + hashId + "/"  + FILENAME;
		s_file_url = sExportUrl + hashId + "/"  + FILENAME;
		
		String cust_file_dir = sExportDir + hashId;
		
		File theDir = new File(cust_file_dir);
		
		if (!theDir.exists()) {
		    theDir.mkdirs();
		}		
		
		fileOut = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(s_file_name,false),"ISO-8859-1"));
		fileOut.write("Partner Name"+DELIMITER+"Client Name"+DELIMITER+"Emails Sent"+DELIMITER+"Prints Sent"+"\r\n");
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
					"   AND c.status_id = 3" +
					" ORDER BY c.cust_name ASC";
			}
			else {
				sql = 
					"SELECT DISTINCT c.cust_id, c.cust_name " +
					"  FROM ccps_cust_partner cp, ccps_customer c " +
					" WHERE cp.partner_id = " + PARTNER +
					"   AND cp.cust_id = c.cust_id" +
					"   AND c.status_id = 3" +
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

<% 
if(user.s_user_name.equals("Tech") && user.s_last_name.equals("Support"))
{
%>
	<a href='http://cms.revotas.com/cms/ui/jsp/bill/bill_form.jsp' style="color:white;text-decoration:none"><< Go back</a>
<%		
} else {
%>
	<a href='http://login.revotas.com/cms/ui/jsp/bill/bill_form.jsp' style="color:white;text-decoration:none"><< Go back</a>
<%
}
%>


  <br>
    <h1>Delivery Summary &nbsp;&nbsp;(from <%=sDateFrom%> to <%=sDateTo%>)</h1>
  <br>
  <table id="containerTable" cellpadding="10" cellspacing="0" border="0" width="100%">
<%
		if (doExport) {
%>
    <tr>
      <td align="left" valign="middle" colspan="6" style="background-color:#575757;">
			Right-click on the Export names below and select [Save Target As...] to <FONT COLOR="RED">download the export</FONT> onto your local computer.
			<br>
			Click on the Preview buttons to preview the export.
      </td>
    </tr>
    <tr>
      <td>
	      Export Name: <a style='color:#FFFFFF;text-decoration:underline;font-size:13px;' href="<%=s_file_url%>"><%=FILENAME%></a>
          &nbsp;&nbsp; <a class="buttons" style="text-decoration:none;" href="javascript:ExportWin('<%=s_file_url%>');">Preview</a>
      </td>
    </tr>
<%
		}
%>
    <tr>
      <td align="left" valign="top" style="">
        <table class="innerContainerTable" cellpadding="10" cellspacing="0" border="0" width="100%">
	      <tr>
            <th align="left"  valign="middle" width=50% nowrap>Client Name</th>
            <th align="left" valign="middle" width=50% nowrap>Emails Sent</th>
          </tr>
<%		
		byte[] bVal		= new byte [8000];
		String sVal		= null;
		StringWriter sw = new StringWriter();
	    String sPartnerName = null;
		String sCustName = null;
		String sCustId = null;
		String sSent = null;
		String sPrintSent = null;
		Element eRoot = null;
		
		for (int n=0; n < custList.length; n++) {			
			sCustId = custList[n];			
			// get customer info
			sql =
				" SELECT c.cust_name, p.partner_name" +
				"   FROM ccps_customer c " +
				"   LEFT OUTER JOIN  ccps_cust_partner cp ON c.cust_id = cp.cust_id " +
				"   LEFT JOIN ccps_partner p ON cp.partner_id = p.partner_id " +
				"  WHERE c.cust_id = " + sCustId;
			rs = stmt.executeQuery(sql);
			if (rs.next()) {
				sCustName = rs.getString(1);
				sPartnerName = rs.getString(2);
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
		    sListXML = null;
			try {
				//System.out.println("Sending request=\n" + sRequestXML);			
				// first try
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
		    <td class="listItem_Data" align="left"  valign="middle" width=40% nowrap><%=sCustName%></td>
		    <td class="listItem_Data" align="left" valign="middle" width=20% nowrap>RCP Timeout Error:<%=saved_ex.getMessage()%></td>
	      </tr>
<%
				if (doExport) {
    				fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"RCP Timeout"+DELIMITER+"--"+"\r\n");
				}
			    continue;																													 
			}
			
			// sanity check?
			eRoot = null;
			try
			{
				eRoot = XmlUtil.getRootElement(sListXML);
			}
			catch(Exception ex) {
				saved_ex = ex;
			}
			if (eRoot == null) {
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=40% nowrap><%=sCustName%></td>
		    <td class="listItem_Data" align="left" valign="middle" width=20% nowrap>RCP Error:<%=saved_ex.getMessage()%></td>
	      </tr>
<%
				if (doExport) {
					fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"RCP Error"+DELIMITER+"--"+"\r\n");
				}
			    continue;																													 
			}

			sCustId = XmlUtil.getChildTextValue(eRoot,"CustId");
			sSent = XmlUtil.getChildTextValue(eRoot,"Sent");
			sPrintSent = XmlUtil.getChildTextValue(eRoot,"PrintSent");

            if (doExport) {
		        fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+sSent+DELIMITER+sPrintSent+"\r\n");
			}
			

%>
<%
			String bgcolor = "";
			if(n%2==0) {
				bgcolor = "#575757";
			} else {
				bgcolor = "#4F4F4F";	
			}
%>
	      <tr style='background-color:<%=bgcolor%>'>
		    <td class="listItem_Data" align="left"  valign="middle" width=40% nowrap><%=sCustName%></td>
		    <td class="listItem_Data" align="left" valign="middle" width=20% nowrap><%=sSent%></td>
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
