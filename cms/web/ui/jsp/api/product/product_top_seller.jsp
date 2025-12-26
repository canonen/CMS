<%@ page language="java"

         import="java.net.*,

                 com.britemoon.*,

                 com.britemoon.rcp.*,

                 com.britemoon.rcp.imc.*,

                 com.britemoon.rcp.que.*,

                 java.sql.*,

                 java.util.Calendar,

                 java.util.Date,

                 java.io.*,

                 java.math.BigDecimal,

                 java.text.NumberFormat,

                 java.util.Locale,

                 java.util.*,

                 java.io.*,

                 org.apache.log4j.Logger,

                 org.w3c.dom.*"

         contentType="text/html;charset=UTF-8"

%>

<%@ page import="com.restfb.json.JsonObject" %>

<%@ page import="com.restfb.json.JsonArray" %>

<%

    response.setHeader("Access-Control-Allow-Origin", "*");

    response.setHeader("Access-Control-Allow-Methods", "GET, POST, PATCH, PUT, DELETE, OPTIONS");

    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");

%>

<%

    String cust_id = request.getParameter("cust_id");
    String pageNo = request.getParameter("page_no");
    int pageNumber = 1;
	if (pageNo != null && !pageNo.isEmpty()) {
		pageNumber = Integer.parseInt(pageNo);
	}


    if (cust_id == null)

        return;

%>
<%

    Statement stmt  = null;
	ConnectionPool connectionPool = null;
	Connection connection = null;
    ResultSet resultSet = null;
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    JsonArray arrayValues = new JsonArray();


    try {
        connectionPool	= ConnectionPool.getInstance(cust_id);
		connection		= connectionPool.getConnection(this);
        stmt = connection.createStatement();
        JsonArray topSellerArray = new JsonArray();
        String query = "SELECT id,cust_id,product_id,cat_id,json_data FROM z_product_topseller";
        resultSet = stmt.executeQuery(query);
        
        int pageSize = 50; // Sayfa basina sonuç sayisi
        int startIndex = (pageNumber - 1) * pageSize; // Baslangiç indeksi
        int endIndex = startIndex + pageSize; // Bitis indeksi

       int count = 0; // Dolasilan kayit sayisi
    while (resultSet.next()) {
        if (count >= startIndex && count < endIndex) {
        // Sayfada gösterilecek verileri isleyin ve JSON nesnesine ekleyin
        JsonObject topSellerObject = new JsonObject();
        topSellerObject.put("id", resultSet.getString(1));
        topSellerObject.put("cust_id", resultSet.getString(2));
        topSellerObject.put("product_id", resultSet.getString(3));
        topSellerObject.put("cat_id", resultSet.getString(4));
        topSellerObject.put("json_data", resultSet.getString(5));
        topSellerArray.put(topSellerObject);
        }
       count++;

        if (count >= endIndex) {
        // Belirtilen sayfa sinirina ulasildiginda döngüyü sonlandirin
        break;
         }
    }
        jsonObject.put("top_seller",topSellerArray);
        jsonArray.put(jsonObject);
        out.println(jsonArray);
        resultSet.close();
        
        
    }
    catch(Exception e)
    {
        e.printStackTrace();
    }
    finally
    {
        if(connectionPool != null)
        {
            connectionPool.free(connection);
        }
    }
%>
