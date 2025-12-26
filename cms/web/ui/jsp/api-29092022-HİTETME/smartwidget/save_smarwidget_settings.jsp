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


    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement	pstmt = null;
    ResultSet	rs = null;
    String web_page= "";
    String cust_id ="";
    String register_page = "" ;
    String order_page = "";
    String cart_page = "";
    String web_pageNullCheck = request.getParameter("webPage");
    if (web_pageNullCheck != null ) {
        web_page = web_pageNullCheck;
    }

    String cust_idNullCheck = request.getParameter("custId");
    if (cust_idNullCheck !=null){
         cust_id = cust_idNullCheck;
    }


    String register_pageNullCheck = request.getParameter("registerPage");
    if (register_pageNullCheck !=null){
         register_page=register_pageNullCheck;

    }

    String order_pageNullCheck = request.getParameter("orderPage");
    if (order_pageNullCheck !=null){
        order_page = order_pageNullCheck;
    }

    String cart_pageNullCheck = request.getParameter("cartPage");
    if (cart_pageNullCheck != null){
        cart_page =  cart_pageNullCheck ;

    }

    try{

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        String sql = "IF (NOT EXISTS(SELECT id FROM c_smart_widget_settings WHERE cust_id = ?)) " +
                "BEGIN " +
                "INSERT INTO c_smart_widget_settings (cust_id,web_page,register_page,cart_page,order_page,create_date,modify_date) VALUES (?,?,?,?,?,getdate(),getdate()) " +
                "END " +
                "ELSE " +
                "BEGIN " +
                "UPDATE c_smart_widget_settings SET web_page = ?, register_page = ?, cart_page = ?, order_page = ?, modify_date = getdate() WHERE cust_id = ? " +
                "END ";

        pstmt = conn.prepareStatement(sql);
        int x=1;
        pstmt.setLong(x++,Long.parseLong(cust_id));
        pstmt.setLong(x++,Long.parseLong(cust_id));
        pstmt.setString(x++,web_page);
        pstmt.setString(x++,register_page);
        pstmt.setString(x++,cart_page);
        pstmt.setString(x++,order_page);
        pstmt.setString(x++,web_page);
        pstmt.setString(x++,register_page);
        pstmt.setString(x++,cart_page);
        pstmt.setString(x++,order_page);
        pstmt.setLong(x++,Long.parseLong(cust_id));


        pstmt.executeUpdate();
        out.println("200");

    }
    catch(Exception e){
        System.out.println("CustID :"+cust_id+"->User İnfo save error :"+e);
        out.print(e);
    }
    finally{

        try { if ( pstmt != null ) pstmt.close(); }
        catch (Exception ignore) { }

        if ( conn != null ) {
            cp.free(conn);
        }

    }

%>