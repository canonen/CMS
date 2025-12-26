<%
	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin","http://dev.revotas.com:3001");
	response.setHeader("Access-Control-Allow-Credentials", "true");
%>
<%@  page language="java"
          import="java.net.*,
            com.britemoon.*,
            com.britemoon.cps.*,
			java.sql.*,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
          contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../utilities/validator.jsp" %>
<%@ include file="../header.jsp" %>

<%
	
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    String sCustId = cust.s_cust_id;

    System.out.println(sCustId);
    String registerPage ="";
    String orderPage ="";
    String cartPage ="";
    String webPage ="";

    String webPageNullCheck = request.getParameter("webPage");
    if (webPageNullCheck != null ) {
        webPage = webPageNullCheck;
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


%>
<%


    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement	pstmt = null;
    ResultSet	rs = null;

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

        pstmt.setLong(x++,Long.parseLong(sCustId));
        pstmt.setLong(x++,Long.parseLong(sCustId));
        pstmt.setString(x++,webPage);
        pstmt.setString(x++,registerPage);
        pstmt.setString(x++,cartPage);
        pstmt.setString(x++,orderPage);
        pstmt.setString(x++,webPage);
        pstmt.setString(x++,registerPage);
        pstmt.setString(x++,cartPage);
        pstmt.setString(x++,orderPage);
        pstmt.setLong(x++,Long.parseLong(sCustId));



        pstmt.executeUpdate();
        out.println("200");

    }
    catch(Exception e){
        System.out.println("CustID :"+sCustId+"->User İnfo save error :"+e);
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
