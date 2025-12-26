<%@ page
        language="java"
        import="com.britemoon.*,
            com.britemoon.cps.*,
            java.util.*,java.sql.*,
            java.net.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;
    JsonObject obj = new JsonObject();
    JsonObject responseJson = new JsonObject();
    JsonArray summaryArray = new JsonArray();


    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sCustId = cust.s_cust_id;
        String camp_id = request.getParameter("camp_id");


        String sSql = "select * from cque_campaign where cust_id= "+sCustId+" AND  camp_id= "+camp_id+"";

        rs=stmt.executeQuery(sSql);
        while (rs.next()){

            obj.put("camp_id",rs.getString(1));
            obj.put("type_id",rs.getString(2));
            obj.put("status_id",rs.getString(3));
            obj.put("camp_name",new String(rs.getBytes(4), "UTF-8"));
            obj.put("cust_id",rs.getString(5));
            obj.put("cont_id",rs.getString(6));
            obj.put("filter_id",rs.getString(7));
            obj.put("seed_list_id",rs.getString(8));
            obj.put("origin_camp_id",rs.getString(9));
            obj.put("approval_flag",rs.getString(10));
            obj.put("sample_id",rs.getString(11));
            obj.put("mode_id",rs.getString(12));
            obj.put("media_type_id",rs.getString(13));
            obj.put("pv_iq",rs.getString(14));
            obj.put("sample_filter_id",rs.getString(15));
            obj.put("sample_priority",rs.getString(16));
            obj.put("camp_code",rs.getString(17));
            obj.put("program_type_id",rs.getString(18));

            summaryArray.put(obj);


        }

        out.println(summaryArray.toString());


    } catch (Exception ex) {
        responseJson.put("error", ex.getMessage());
        out.print(responseJson.toString());
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>