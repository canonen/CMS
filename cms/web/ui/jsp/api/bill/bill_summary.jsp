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

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>



<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    String custId = cust.s_cust_id;
    JsonObject data=new JsonObject();
    JsonArray array=new JsonArray();
    String YEAR1	= request.getParameter("year1");
    String MONTH1	= request.getParameter("month1");
    String DAY1	    = request.getParameter("day1");
    String YEAR2	= request.getParameter("year2");
    String MONTH2	= request.getParameter("month2");
    String DAY2	    = request.getParameter("day2");
    String CUSTOMER = custId;
    String PARTNER  = request.getParameter("partner");
    String EXPORT   = request.getParameter("export");
    String FILENAME = request.getParameter("filename");
    String DELIMITER= request.getParameter("delim");



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
            // sExportDir = "D:\\Revotas\\adm\\web\\export\\";
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
		
		//burası ben değiştirmeden önce böyleydi
        s_file_url = sExportUrl + hashId + "/"  + FILENAME;
		
		//s_file_url = "http://dev.revotas.com/cms/data/" + hashId + "/"  + FILENAME;

        String cust_file_dir = sExportDir + hashId;

        File theDir = new File(cust_file_dir);

        if (!theDir.exists()) {
            theDir.mkdirs();
        }

        fileOut = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(s_file_name,false),"ISO-8859-1"));
        fileOut.write("Partner Name"+DELIMITER+"Client Name"+DELIMITER+"Emails Sent"+DELIMITER+"Prints Sent"+"\r\n");

        //out.println(fileOut);
        //System.out.println(fileOut);
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
                data = new JsonObject();
                vec.add(rs.getString(1));
                data.put("vector", vec);

            }
            rs.close();
            out.println(data);
            if (vec.size() == 0) {
//                out.println("<h3> That partner has no customers assigned to it!</h3>");
//                out.println("Please add customers to that partner and try again.");
                return;
            }
            custList = new String[vec.size()];
            vec.copyInto(custList);
        }
        else if ( CUSTOMER.equals("0") ) {
            sql =
                    "SELECT DISTINCT cust_id, cust_name " +
                            "  FROM ccps_customer " +
                            " WHERE status_id = 3 " +
                            " ORDER BY cust_name ASC";
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                data=new JsonObject();
                vec.add(rs.getString(1));
                data.put("vector",vec);
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
            data= new JsonObject();
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
                data.put("s_cust_name",sCustName);
                data.put("s_partner_name",sPartnerName);
            }
            rs.close();
            if (sPartnerName == null) {
                sPartnerName = "Direct";
                data.put("s_partner_name",sPartnerName);
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
               // data.put("sListXml", sListXML);
                 //out.println(data);
            }
            catch(Exception ex) {
                saved_ex = ex;
            }

            // should we give up?
            if (sListXML == null || sListXML.length() == 0) {
                // data.put("custName",sCustName);
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
                // data.put("custName",sCustName);
                if (doExport) {
                    fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+"RCP Error"+DELIMITER+"--"+"\r\n");
                }
                continue;
            }

            sCustId = XmlUtil.getChildTextValue(eRoot,"CustId");
            sSent = XmlUtil.getChildTextValue(eRoot,"Sent");
            sPrintSent = XmlUtil.getChildTextValue(eRoot,"PrintSent");
            data.put("sent",sSent);
            data.put("sPrintSent",sPrintSent);
			data.put("fileName",s_file_name);
			data.put("fileUrl",s_file_url);
			array.put(data);
            out.println(array);
            if (doExport) {
                fileOut.write(sPartnerName+DELIMITER+sCustName+DELIMITER+sSent+DELIMITER+sPrintSent+"\r\n");
              
            }
        }
    rs.close();
    conn.close();
    }

    catch(Exception ex) {
        ex.printStackTrace(response.getWriter());
        logger.error("Exception: ",ex);
    }
    finally {
        if (fileOut!=null) {
            fileOut.flush();
            fileOut.close();
        }
        if(rs!=null) rs.close();
        if(stmt!=null) stmt.close();
        if(conn!=null) cp.free(conn);
    }
%>
