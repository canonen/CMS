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

<%@ include file="../../utilities/header.jsp"%>
<%@ include file="../../utilities/validator.jsp" %>
<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    String sCustId = user.s_cust_id;


    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sql = "";
    Integer custId = null;
    Integer iCustId = null;
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
        String getCustIdByDataSql = " SELECT total,active,unsub,exclude_,bback " +
                                     "FROM crpt_cust_email_summary with (nolock) " +
                                     "where cust_id = "+  custId+ "";
        resultSet = statement.executeQuery(getCustIdByDataSql);
            while (resultSet.next()) {
                total = resultSet.getInt(1);
                active = resultSet.getInt(2);
                unsub = resultSet.getInt(3);
                exclude_ = resultSet.getInt(4);
				bback=resultSet.getInt(4);
				System.out.println(total);
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


    out.print(jsonObject);


%>