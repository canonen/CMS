<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.rpt.*,
			java.sql.*,java.net.*,java.io.*,
			java.util.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }


    ConnectionPool	cp		= null;
    Connection		conn	= null;
    Statement		stmt	= null;
    ResultSet		rs		= null;


    JsonArray array= new JsonArray();
    JsonArray allData= new JsonArray();
    JsonObject data = new JsonObject();
    ArrayList dizi = new ArrayList();

    int count = 0;


    try
    {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();


        String sSql =  "select week from ccps_schedule_advisor_week_report WHERE cust_id ="+ cust.s_cust_id+" group by week" ;

        rs = stmt.executeQuery(sSql);



        while( rs.next() ) {
           dizi.add(rs.getString(1));
        }
        rs.close();
        for(int i=0; i< dizi.size(); i++){
            data = new JsonObject();
            String week = dizi.get(i).toString();
            sSql = "select distinct [open],[hour] from ccps_schedule_advisor_week_report where cust_id="+ cust.s_cust_id+"and week ="+dizi.get(i);
            rs = stmt.executeQuery(sSql);
            array = new JsonArray();
            while (rs.next()){
                String open = rs.getString(1);
                String hour = rs.getString(2);
                JsonObject jsonObject = new JsonObject();
                jsonObject.put("hour", hour);
                jsonObject.put("open", open);
                array.put(jsonObject);
            }
            data.put("data", array);
            data.put("week", week);
            allData.put(data);
        }

        rs.close();
        out.println(allData);

    }
    catch (Exception ex) { throw ex; }
    finally
    {
        try
        {   if (   rs    != null ) rs.close();
            if( stmt  != null ) stmt.close();
            if( conn  != null ) cp.free(conn);
        }
        catch (SQLException ex) { 
            ex.printStackTrace();
        }
    }
%>










