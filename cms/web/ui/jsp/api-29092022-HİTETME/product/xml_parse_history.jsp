<%@ page language="java"
         import="java.net.*,
	   		java.util.ArrayList,
	   		java.text.SimpleDateFormat,
	   		com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
            com.britemoon.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
         contentType="text/html;charset=UTF-8"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%

    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();
        String custid=request.getParameter("custId");

        if(custid==null)
            return;

// Get Connection
        Statement		stmt	= null;
        ResultSet		rs	= null;

        ConnectionPool  cp	= null;
        Connection		connm	= null;

        String taskName ="";
        String startDate ="";
        String recordCount ="";
        String finishDate ="";
        String status ="";

        try {
            cp = ConnectionPool.getInstance();
            connm = cp.getConnection(this);
            stmt = connm.createStatement();

            String query="SELECT task_name, start_date, finish_date, record_count, status FROM ccps_attribute_xml_summary where cust_id = "+ custid +" order by finish_date desc";

            rs=stmt.executeQuery(query);

            while (rs.next()){
                data = new JsonObject();

                taskName = rs.getString(1);
                startDate = rs.getString(2);
                finishDate = rs.getString(3);
                recordCount = rs.getString(4);
                status = rs.getString(5);

                data.put("taskName",taskName);
                data.put("startDate",startDate);
                data.put("finishDate",finishDate);
                data.put("recordCount",recordCount);

                data.put("status",status);

                arrayData.put(data);

            }
            rs.close();

        }catch (Exception exception){
            System.out.println("CUSTID: " + custid + exception.getMessage());
            throw  exception;
        }
        finally {
            try {
                if (stmt!=null) stmt.close();
                if (connm!=null) cp.free(connm);
            }catch (SQLException e){
                System.out.println(e);
            }
        }



%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
    out.print(arrayData.toString());
%>