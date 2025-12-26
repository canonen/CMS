<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
//        String sCustId = cust.s_cust_id;
//        Campaign camp = new Campaign();
//        camp.s_cust_id = sCustId;

         String sCustId = request.getParameter("custId");

        // Get Connection
        Statement		stmt	= null;
        ResultSet		rs		= null;
        ConnectionPool	cp		= null;
        Connection		conn	= null;
        JsonObject  data = new JsonObject();
        JsonArray arrayData = new JsonArray();


        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);
            stmt = conn.createStatement();

            //Mobil ve Desktop goruntulenmelerini getirir
            rs = stmt.executeQuery("select total_reads,desktop_reads,mobil_reads from z_rrpt_mobile_summary with(nolock) where cust_id ="+sCustId);

            String sTotal_Reads =null;
            String sDesktop_Reads =null;
            String sMobil_Reads =null;

            while(rs.next()){
                data  = new JsonObject();
                sTotal_Reads 		= rs.getString(1);
                sDesktop_Reads 		= rs.getString(2);
                sMobil_Reads 		= rs.getString(3);
                data.put("totalRead",sTotal_Reads);
                data.put("totalDesktopRead",sDesktop_Reads);
                data.put("totalMobileRead",sMobil_Reads);

                arrayData.put(data);
            }
            rs.close();

            //Cihazlardan gelen raporlar
            rs = stmt.executeQuery("select mobile_client,mobile_count,mobile_pct from z_mobile_reporting with(nolock) where cust_id ="+sCustId);

            String sMobile_Client =null;
            String sMobile_Count =null;
            String sMobile_Pct =null;
            String xxx ="";
            String table_format ="";
            while(rs.next()){
                data = new JsonObject();

                sMobile_Client 		= rs.getString(1);
                sMobile_Count 		= rs.getString(2);
                sMobile_Pct 		= rs.getString(3);

                data.put("mobileClient",sMobile_Client);
                data.put("mobileCount",sMobile_Count);
                data.put("mobilePct",sMobile_Pct);

                xxx +="['"+ sMobile_Client +"',"+sMobile_Count+"],";

                data.put("xxx",xxx);

                arrayData.put(data);

            }
            rs.close();

        }catch (Exception exception){
            exception.getMessage();
        }finally {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        }

    out.print(arrayData.toString());


    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");

%>
