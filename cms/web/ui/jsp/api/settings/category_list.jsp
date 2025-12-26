<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
                java.io.*,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.json.JSONArray,
                org.json.JSONObject,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ include file="../fixTurkishCharacters.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CATEGORY);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    if (!can.bRead) {
        response.sendRedirect("../../access_denied.jsp");
        return;
    }

    String sDefaultCategoryID = ui.s_category_id;
    boolean bCanDefault = ((user.s_cust_id).equals(cust.s_cust_id) && can.bExecute);
    String sCustId = cust.s_cust_id;
%>
<%
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;
%>
<%
    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        Integer categoryId = 0;
        String categoryName = null;
        String categoryDescrip = "";

        String categorySqlQuery = "SELECT category_id, category_name, ISNULL(category_descrip,'') FROM ccps_category WHERE cust_id=" + sCustId + " ORDER BY category_name";

        resultSet = statement.executeQuery(categorySqlQuery);

        JSONArray array = new JSONArray();

        while (resultSet.next()) {
//            categoryId = resultSet.getInt(1);
//            categoryName = resultSet.getString(2);
//            categoryDescrip = resultSet.getString(3);

            JSONObject data = new JSONObject();
            data.put("categoryId", resultSet.getInt(1));
            data.put("categoryName",fixTurkishCharacters(new String(resultSet.getBytes(2), "UTF-8")));
            data.put("categoryDescrip",fixTurkishCharacters(new String(resultSet.getBytes(3), "UTF-8")));
            if((resultSet.getString(1)).equals(sDefaultCategoryID)){
                data.put("categorySet","Default");
            }else{
                data.put("categorySet","Set Default");
            }
            array.put(data);
        }

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("Category", array);

        resultSet.close();

        out.print(jsonObject);

    } catch (Exception exception) {
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (resultSet != null) resultSet.close();
        if (statement != null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }
%>
