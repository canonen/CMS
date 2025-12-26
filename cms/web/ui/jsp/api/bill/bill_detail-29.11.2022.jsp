<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.imc.*"
	import="java.io.*"
	import="java.security.MessageDigest"
	import="java.security.NoSuchAlgorithmException" 
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	import="org.w3c.dom.*"
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
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

%>

<HTML>

<HEAD>
	<TITLE>Billing Summary</TITLE>
	<%@ include file="../header.html" %>
    <script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
    <script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>
    <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
         
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

	if ((CUSTOMER.length() == 0) && (PARTNER.length() == 0))
    {
		out.println("<h3>You must select either a partner or a customer!</h3>");
		out.println("Please back up your browser.");
		return;
	}

	BufferedWriter fileOut = null;
    String s_file_name = null;
    String s_file_url = null;
    boolean doExport = false;
    if (EXPORT != null && EXPORT.equals("on"))
    {
        doExport=true;
		if (FILENAME != null && !FILENAME.equals("") )
		{
			FILENAME = FILENAME.trim();		
            if (!FILENAME.toLowerCase().endsWith(".txt"))
            {
				FILENAME = FILENAME + ".txt";
			}
		}
        else
        {
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
		       nsae.printStackTrace();     
		}
		
		
		
		
		
		
		
		s_file_name = sExportDir + hashId + "/"  + FILENAME;
		s_file_url = sExportUrl + hashId + "/"  + FILENAME;

		String cust_file_dir = sExportDir + hashId;

		File theDir = new File(cust_file_dir);

		if (!theDir.exists()) {
		    theDir.mkdirs();
		}
		
		fileOut = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(s_file_name,false),"ISO-8859-1"));
		fileOut.write("Partner Name"+DELIMITER+"Client Name"+DELIMITER+"Campaign Date"+DELIMITER+"Campaign Name"+DELIMITER+"Campaign Type"+DELIMITER+"Email Sent"+DELIMITER+"Email Client Subtotal"+DELIMITER+"Email Subtotal"+DELIMITER+"Prints Sent"+DELIMITER+"Prints Client Subtotal"+DELIMITER+"Prints Subtotal"+"\r\n");
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
	
<% 
if(user.s_user_name.equals("Tech") && user.s_last_name.equals("Support"))
{
%>
	<a class=button_res href='http://cms.revotas.com/cms/ui/jsp/bill/bill_form.jsp'>Go back</a>
<%		
} else {
%>
	<a class=button_res href='http://login.revotas.com/cms/ui/jsp/bill/bill_form.jsp'>Go back</a>
<%
}
%>
	
<br><br>
  <table class="listTable" cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
    	<th>Campaign Summary&nbsp;&nbsp;(from <%=sDateFrom%> to <%=sDateTo%>)</th>
</tr>
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
	      Export Name: <a class=button_res href="<%=s_file_url%>"><%=FILENAME%></a>
          &nbsp;&nbsp; <a class="button_res" href="javascript:ExportWin('<%=s_file_url%>');">Preview</a>
      </td>
    </tr>
<%
		}
%>
    <tr>
      <td align="left" valign="top" style="">
        <table class="table-soft" cellpadding="0" cellspacing="0" border="0" width="100%">
	      <tr>
            <th align="left"  valign="middle" width=20% nowrap>Client Name</th>
            <th align="left"  valign="middle" width=10% nowrap>Campaign Date</th>
            <th align="left"  valign="middle" width=10% nowrap>Campaign Name</th>
            <th align="left"  valign="middle" width=10%>Campaign Type</th>
            <th align="left" valign="middle" width=10% nowrap>Email Sent</th>
            <th align="left" valign="middle" width=10% nowrap>Email Client Subtotal</th>
            <th align="left" valign="middle" width=10% nowrap>Email Subtotal</th>
          </tr>
<%		
		byte[] bVal		= new byte [8000];
		String sVal		= null;
		StringWriter sw = new StringWriter();
																								   
	    String sPartnerName = null;
		String sCustName = null;
		String sCustId = null;
		String sCampDate = null;
		String sCampName = null;
		String sCampType = null;
		String sSent = null;
		String sPrintSent = null;
		int clientSubtotal = 0;
		int printClientSubtotal = 0;
		int subtotal = 0;
		int printSubtotal = 0;
		Element eRoot = null;
		XmlElementList xelItems = null;
		Element eItem = null;
        int rows = 0;
		for (int n=0; n < custList.length; n++) {			
			// get deliveries stats from RCP for each client
			sCustId = custList[n];
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
			
            sRequestXML = "";
			sRequestXML += "<Request>\r\n";
			sRequestXML += "  <customer>"+sCustId+"</customer>\r\n";
			sRequestXML += "  <dateFrom>"+sDateFrom+"</dateFrom>\r\n";
			sRequestXML += "  <dateTo>"+sDateTo+"</dateTo>\r\n";
			sRequestXML += "</Request>\r\n";

			Exception saved_ex = null;
			try {
				//System.out.println("Sending request=\n" + sRequestXML);	
				// first try
				sListXML = Service.communicate(ServiceType.RRCP_BILLING_CAMP_REPORT, sCustId, sRequestXML);
				// second try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CAMP_REPORT, sCustId, sRequestXML);
				}
				// third try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CAMP_REPORT, sCustId, sRequestXML);
				}	
				// fourth try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CAMP_REPORT, sCustId, sRequestXML);
				}
				// fifth try
				if (sListXML == null || sListXML.length() == 0) {
					sListXML = Service.communicate(ServiceType.RRCP_BILLING_CAMP_REPORT, sCustId, sRequestXML);
				}
				//System.out.println("Getting response=\n" + sListXML);
			}
			catch(Exception ex) {
				saved_ex = ex;
			}
				
			// should we give up?
			if (sListXML == null || sListXML.length() == 0) {
                rows++;
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=20% nowrap><%=sCustName%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>RCP Timeout:<%=saved_ex.getMessage()%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>--</td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10%>--</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap>--</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap>--</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap><%=subtotal%></td>
	      </tr>
<%
				if (doExport) {
					fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"RCP Timeout"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+subtotal+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+printSubtotal+"\r\n");
				}
			    continue;																													 
			}
			// sanity check
			eRoot = null;
			try
			{
				eRoot = XmlUtil.getRootElement(sListXML);
			}
			catch(Exception ex) {
				saved_ex = ex;
			}
			if (eRoot == null) {
                rows++;
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=20% nowrap><%=sCustName%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>RCP Error:<%=saved_ex.getMessage()%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>--</td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10%>--</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap>--</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap>--</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap><%=subtotal%></td>
	      </tr>
<%
				if (doExport) {
					fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"RCP Error"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+subtotal+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+printSubtotal+"\r\n");
				}
			    continue;																													 
			}

			sSent = XmlUtil.getChildTextValue(eRoot,"Sent");
			xelItems = XmlUtil.getChildrenByName(eRoot, "Item");
			clientSubtotal = 0;
			if (xelItems == null || xelItems.getLength() == 0) {
                rows++;
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=20% nowrap><%=sCustName%></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>n/a</td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10% nowrap>n/a</td>
		    <td class="listItem_Data" align="left"  valign="middle" width=10%>n/a</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap>0</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap>0</td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap><%=subtotal%></td>
	      </tr>
<%
				if (doExport) {
					fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"n/a"+DELIMITER+"n/a"+DELIMITER+"n/a"+DELIMITER+"0"+DELIMITER+"0"+DELIMITER+subtotal+DELIMITER+"0"+DELIMITER+"0"+DELIMITER+printSubtotal+"\r\n");
				}
			}
			for (int j=0; j < xelItems.getLength(); j++) {
                rows++;
				eItem = (Element)xelItems.item(j);
				sCampName = XmlUtil.getChildCDataValue(eItem,"CampName");
				sCampType = XmlUtil.getChildTextValue(eItem,"TypeName");
				sCampDate = XmlUtil.getChildTextValue(eItem,"StartDate");
				sSent = XmlUtil.getChildTextValue(eItem,"Sent");
				sPrintSent = XmlUtil.getChildTextValue(eItem,"PrintSent");
				clientSubtotal += Integer.parseInt(sSent);
				subtotal += Integer.parseInt(sSent);
				printClientSubtotal += Integer.parseInt(sPrintSent);
				printSubtotal += Integer.parseInt(sPrintSent);

            	if (doExport) {
		        	fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+sCampDate+DELIMITER+sCampName+DELIMITER+sCampType+DELIMITER+sSent+DELIMITER+clientSubtotal+DELIMITER+subtotal+DELIMITER+sPrintSent+DELIMITER+printClientSubtotal+DELIMITER+printSubtotal+"\r\n");
				}	
%>
<%
			String classAppend = "";
			if(rows%2==0) {
				classAppend = "_Alt";
			} 
%>
	      <tr>
		    <td class="listItem_Data<%=classAppend%>" align="left"  valign="middle" width=20% nowrap><%=sCustName%></td>
		    <td class="listItem_Data<%=classAppend%>" align="left"  valign="middle" width=10% nowrap><%=sCampDate%></td>
		    <td class="listItem_Data<%=classAppend%>" align="left"  valign="middle" width=10% nowrap><%=sCampName%></td>
		    <td class="listItem_Data<%=classAppend%>" align="left"  valign="middle" width=10%><%=sCampType%></td>
		    <td class="listItem_Data<%=classAppend%>" align="left" valign="middle" width=10% nowrap><%=sSent%></td>
		    <td class="listItem_Data<%=classAppend%>" align="left" valign="middle" width=10% nowrap><%=clientSubtotal%></td>
		    <td class="listItem_Data<%=classAppend%>" align="left" valign="middle" width=10% nowrap><%=subtotal%></td>
	      </tr>
<%
		  }
        }
		if (rows == 0) {
			out.println("<td>no data available</td>");
		}
%>
        </table>
      </td>
    </tr>                           
  </table>
<%
    }
	catch(Exception ex)
	{
		ex.printStackTrace(response.getWriter());
        logger.error("XML Sent=");
        logger.error(sRequestXML);
        logger.error("XML Received=");
        logger.error(sListXML);
        logger.error("Exception: ",ex);
    }
    finally
    {
		if (fileOut!=null)
		{
			fileOut.flush();
			fileOut.close();
		}
	    if(conn!=null) cp.free(conn);
    }
%>
</BODY>
</HTML>
