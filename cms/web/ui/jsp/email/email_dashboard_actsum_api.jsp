<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>


<%@ include file="../validator_api.jsp" %>
<%

    String sCustId = "420";


    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sql = "";
    Integer custId = null;
    Integer cust_id = null;
    Integer total = null;
    Integer active = null;
    Integer bback = null;
    Integer unsub = null;
    Integer exclude_ = null;
    List rowValues = new ArrayList();
    ArrayList<Integer> custIdArray = new ArrayList();
    JsonObject jsonObject = new JsonObject();
    try {
        // TODO ARRAY İÇİNDEN TEK TEK JSON A ATILICAK !!!!!!
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();
        String getSqlCustId;
        sql = " SELECT cust_id FROM  crpt_cust_email_summary with(nolock) where cust_id= "+ sCustId+ "";
        resultSet = statement.executeQuery(sql);

        while (resultSet.next()) {
            custId = resultSet.getInt(1);



        }
        String getCustIdByDataSql = " SELECT cust_id,total,active,unsub,exclude_,bback " +
                                     "FROM crpt_cust_email_summary with (nolock) " +
                                     "where cust_id = "+  custId+ "";
        resultSet = statement.executeQuery(getCustIdByDataSql);
            while (resultSet.next()) {
                cust_id = resultSet.getInt(1);
                total = resultSet.getInt(2);
                active = resultSet.getInt(3);
                unsub = resultSet.getInt(4);
                exclude_ = resultSet.getInt(5);
				bback=resultSet.getInt(6);
                jsonObject.put("custId",cust_id);
                jsonObject.put("total",total);
                jsonObject.put("active",active);
                jsonObject.put("unsub",unsub);
                jsonObject.put("exclude",exclude_);
				jsonObject.put("bback",bback);

            }



    } catch (Exception exception) {

        exception.printStackTrace();
        System.out.println(exception.getMessage());

    }
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");


    out.print(jsonObject);


%>