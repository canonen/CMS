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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	JsonObject data = new JsonObject();
	JsonArray array	= new JsonArray();
	String YEAR1	= request.getParameter("year1");
	String MONTH1	= request.getParameter("month1");
	String DAY1	    = request.getParameter("day1");
	String YEAR2	= request.getParameter("year2");
	String MONTH2	= request.getParameter("month2");
	String DAY2	    = request.getParameter("day2");
	String CUSTOMER = cust.s_cust_id;
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
			
		}catch(NoSuchAlgorithmException nSAE){
		            out.println(nSAE);
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
				data = new JsonObject();
				data.put("cust_id",rs.getString(1));
				array.put(data);
			}
			rs.close();

			custList = new String[array.length()];
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
				data = new JsonObject();
				data.put("cust_id",rs.getString(1));
				array.put(data);
			}
			rs.close();
			custList = new String[array.length()];
			vec.copyInto(custList);
		}
		else {
			custList = CUSTOMER.split(",");
		}
		data = new JsonObject();
		data.put("date_from",sDateFrom);
		data.put("date_to",sDateTo);

		if (doExport) {
			data.put("file_url",s_file_url);
			data.put("file_name",FILENAME);
		}
		array.put(data);

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
				data = new JsonObject();
				sCustName = rs.getString(1);
				sPartnerName = rs.getString(2);
				data.put("sCustName",sCustName);
				data.put("sPartnerName",sPartnerName);
			}
			rs.close();
			if (sPartnerName == null) {
				sPartnerName = "Direct";
				data.put("sPartnerName",sPartnerName);
				array.put(data);
			}
			
            sRequestXML = "";
			sRequestXML += "<Request>\r\n";
			sRequestXML += "  <customer>"+sCustId+"</customer>\r\n";
			sRequestXML += "  <dateFrom>"+sDateFrom+"</dateFrom>\r\n";
			sRequestXML += "  <dateTo>"+sDateTo+"</dateTo>\r\n";
			sRequestXML += "</Request>\r\n";

			Exception saved_ex = null;
			try {
				for (int i = 0; i < 5; i++) {
					if (sListXML == null || sListXML.length() == 0) {
						sListXML = Service.communicate(ServiceType.RRCP_BILLING_CAMP_REPORT, sCustId, sRequestXML);
					}
				}
			}
			catch(Exception ex) {
				saved_ex = ex;
			}
				
			// should we give up?
			if (sListXML == null || sListXML.length() == 0) {
                rows++;
				data = new JsonObject();
				data.put("rcp_timepot",saved_ex.getMessage());
				data.put("sub_total",subtotal);

				if (doExport) {
					fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"RCP Timeout"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+subtotal+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+printSubtotal+"\r\n");
					data.put("file_out",fileOut);
				}
				array.put(data);
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
				data = new JsonObject();
				data.put("rcp_timepot",saved_ex.getMessage());
				data.put("sub_total",subtotal);

				if (doExport) {
					fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"RCP Error"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+subtotal+DELIMITER+"--"+DELIMITER+"--"+DELIMITER+printSubtotal+"\r\n");
					data.put("file_out",fileOut);
				}
				array.put(data);
			    continue;																													 
			}

			sSent = XmlUtil.getChildTextValue(eRoot,"Sent");
			xelItems = XmlUtil.getChildrenByName(eRoot, "Item");
			clientSubtotal = 0;
			if (xelItems == null || xelItems.getLength() == 0) {
                rows++;
				data = new JsonObject();
				data.put("sub_total",subtotal);
				if (doExport) {
					fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"n/a"+DELIMITER+"n/a"+DELIMITER+"n/a"+DELIMITER+"0"+DELIMITER+"0"+DELIMITER+subtotal+DELIMITER+"0"+DELIMITER+"0"+DELIMITER+printSubtotal+"\r\n");
					data.put("file_out",fileOut);
				}
				array.put(data);
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

			String classAppend = "";

				classAppend = "_Alt";
				data = new JsonObject();
				data.put("cust_name",sCustName);
				data.put("camp_date",sCampDate);
				data.put("camp_name",sCampName);
				data.put("camp_type",sCampType);
				data.put("sent",sSent);
				data.put("client_subtotal",clientSubtotal);
				data.put("subtotal",subtotal);
				array.put(data);

		  }
        }
	out.println(array);
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
		if(rs!=null) rs.close();
		if(stmt!=null) stmt.close();
	    if(conn!=null) cp.free(conn);

    }
%>
