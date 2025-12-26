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
<%! static Logger logger = null;%>

<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

    if(!can.bRead)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }


    ConnectionPool	cp		= null;
    Connection		conn	= null;
    Statement		stmt	= null;
    ResultSet		rs		= null;


    JsonArray array= new JsonArray();
    JsonObject data = new JsonObject();

    try
    {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();




           String sSql =  "select * from ccps_schedule_advisor_week_report WHERE cust_id ="+838;

            rs = stmt.executeQuery(sSql);

            while( rs.next() )
            {
                data = new JsonObject();
                data.put("week",rs.getString(2));
                data.put("hour",rs.getString(3));
                data.put("open",rs.getString(4));
                array.put(data);
            }
    out.println(array);
            rs.close();




    }
    catch (Exception ex) { throw ex; }
    finally
    {
        try
        {
            if( stmt  != null ) stmt.close();
            if( conn  != null ) cp.free(conn);
        }
        catch (SQLException ex) { }
    }
%>










