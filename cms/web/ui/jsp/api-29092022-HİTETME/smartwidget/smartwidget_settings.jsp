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
<%@ page import="com.restfb.json.JsonObject" %>


<%

    Statement		statement= null;
    ResultSet resultSet = null;
    ConnectionPool	cp= null;
    Connection		conn= null;

    String custId = request.getParameter("custId");
    JsonObject data = new JsonObject();

  try {


      String web_page = "";
      String register_page = "";
      String cart_page = "";
      String order_page = "";

      cp = ConnectionPool.getInstance();
      conn = cp.getConnection(this);

      statement = conn.createStatement();

      String sSql = "SELECT web_page, register_page, cart_page, order_page FROM c_smart_widget_settings WHERE cust_id =" + custId;

      ResultSet rs = statement.executeQuery(sSql);
      while(rs.next()){
          if (rs.getString(1) !=null )
          web_page = rs.getString(1);
          if (rs.getString(2) !=null )
          register_page = rs.getString(2);
          if (rs.getString(3) !=null )
          cart_page = rs.getString(3);
          if (rs.getString(4) !=null )
          order_page = rs.getString(4);
      }
      rs.close();

      data.put("webPage" ,web_page );
      data.put("registerPage" ,register_page );
      data.put("cartPage" ,cart_page );
      data.put("orderPage" ,order_page );




  }catch (Exception exception){
      System.out.println("custId" +custId + exception.getMessage() );


  }finally {
      if (conn != null) {
          conn.close();
      
      }
  }

    out.print(data.toString());
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");


%>