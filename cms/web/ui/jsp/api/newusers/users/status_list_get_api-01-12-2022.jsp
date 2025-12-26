<%@ page
        language="java"
        import="com.britemoon.*,
com.britemoon.cps.*,
com.britemoon.cps.adm.*,
com.britemoon.cps.wfl.*,
java.io.*,java.sql.*,
org.json.JSONException,
org.json.JSONObject,
org.json.XML,
org.json.JSONArray,
java.util.*,org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.USER);

    if(!can.bRead)
    {
        response.sendRedirect("../../access_denied.jsp");
        return;
    }
%>

<%

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;
    JSONObject data = new JSONObject();
    JSONObject dataObject= new JSONObject();


    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            sSql = "select * from ccps_user_status";


            pstmt = conn.prepareStatement(sSql);


            rs = pstmt.executeQuery();
            while (rs.next())
            {
                data= new JSONObject();

                String statusId=String.valueOf(rs.getInt(1));
                String statusName=rs.getString(2);
                data.put("statusName",statusName);
                dataObject.put(statusId,data);


            }
            out.println(dataObject);

            rs.close();


        } catch (Exception ex) {
            throw ex;
        } finally {

            if (pstmt != null) pstmt.close();
        }
    }

    catch(SQLException sqlex)
    {
        throw sqlex;
    }
    finally
    {
        if(conn != null) cp.free(conn);
    }
%>

