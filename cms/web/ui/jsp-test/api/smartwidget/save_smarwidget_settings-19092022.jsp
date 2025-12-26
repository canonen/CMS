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
			org.json.JSONObject,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%


    ConnectionPool connectionPool = null;
    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;
    String webPage = "";
    String custId ="";
    String registerPage = "" ;
    String orderPage = "";
    String cartPage = "";
    String webPageNullCheck = request.getParameter("webPage");
    if (webPageNullCheck != null ) {
        webPage = webPageNullCheck;
    }

    String custIdNullCheck = request.getParameter("custId");
    if (custIdNullCheck !=null){
         custId = custIdNullCheck;
    }


    String registerPageNullCheck = request.getParameter("registerPage");
    if (registerPageNullCheck !=null){
         registerPage = registerPageNullCheck;

    }

    String orderPageNullCheck = request.getParameter("orderPage");
    if (orderPageNullCheck !=null){
        orderPage = orderPageNullCheck;
    }

    String cartPageNullCheck = request.getParameter("cartPage");
    if (cartPageNullCheck != null){
        cartPage = cartPageNullCheck;

    }

    try{

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);

        String sql = "IF (NOT EXISTS(SELECT id FROM c_smart_widget_settings WHERE cust_id = ?)) " +
                "BEGIN " +
                "INSERT INTO c_smart_widget_settings (cust_id,web_page,register_page,cart_page,order_page,create_date,modify_date) VALUES (?,?,?,?,?,getdate(),getdate()) " +
                "END " +
                "ELSE " +
                "BEGIN " +
                "UPDATE c_smart_widget_settings SET web_page = ?, register_page = ?, cart_page = ?, order_page = ?, modify_date = getdate() WHERE cust_id = ? " +
                "END ";

        preparedStatement = connection.prepareStatement(sql);
        int x=1;
        preparedStatement.setLong(x++,Long.parseLong(custId));
        preparedStatement.setLong(x++,Long.parseLong(custId));
        preparedStatement.setString(x++, webPage);
        preparedStatement.setString(x++, registerPage);
        preparedStatement.setString(x++, cartPage);
        preparedStatement.setString(x++, orderPage);
        preparedStatement.setString(x++, webPage);
        preparedStatement.setString(x++, registerPage);
        preparedStatement.setString(x++, cartPage);
        preparedStatement.setString(x++, orderPage);
        preparedStatement.setLong(x++,Long.parseLong(custId));


        preparedStatement.executeUpdate();
        out.println("200");

    }
    catch(Exception e){
        System.out.println("CustID :"+ custId +"->User İnfo save error :"+e);
        out.print(e);
    }
    finally{

        try { if ( preparedStatement != null ) preparedStatement.close(); }
        catch (Exception ignore) { }

        if ( connection != null ) {
            connectionPool.free(connection);
        }

    }
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");

%>