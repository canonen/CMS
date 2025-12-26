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
<%@ page import="com.restfb.json.JsonArray" %>

<%
    Statement 		statement	= null;
    ResultSet 		resultSet		= null;
    ConnectionPool 	connectionPool		= null;
    Connection 		conn	= null;

    connectionPool = connectionPool.getInstance();
    conn = connectionPool.getConnection(this);
    statement = conn.createStatement();


    boolean isDisable = false;

    JsonObject data = new JsonObject();
    JsonArray dataArray = new JsonArray();

    String	CUSTOMER_ID	=request.getParameter("custId");
    String sSelectedCategoryId = request.getParameter("category_id");

    String	sFilename	= "";
    String	sFileUrl	= "";
    String	sFileId		= "";
    String	sStatus		= "";
    int nStatusID = 0;
    int nTypeID = 0;




    try {

        if (sSelectedCategoryId == null || sSelectedCategoryId.equals("0"))
        {
            resultSet= statement.executeQuery(

                    "SELECT f.file_url, f.export_name, f.file_id, ISNULL(s.display_name, s.status_name),"+
                            " ISNULL(f.status_id, "+ExportStatus.COMPLETE+"), f.type_id " +
                            "FROM cexp_export_file f, cexp_export_status s " +
                            "WHERE cust_id = "+CUSTOMER_ID+
                            " AND ISNULL(f.status_id, "+ExportStatus.COMPLETE+") = s.status_id " +
                            " AND f.type_id<>40 "+
                            "ORDER BY file_id DESC");
        }
        else
        {
            resultSet = statement.executeQuery(
                    "SELECT f.file_url, f.export_name, f.file_id, ISNULL(s.display_name, s.status_name),\n" +
                            "ISNULL(f.status_id, "+ ExportStatus.COMPLETE +"), f.type_id  \n" +
                            "FROM cexp_export_file f, cexp_export_status s, ccps_object_category c  \n" +
                            "WHERE f.cust_id = CUSTOMER_ID\n" +
                            "AND ISNULL(f.status_id,"+ ExportStatus.COMPLETE +") = s.status_id  \n" +
                            "AND c.cust_id = CUSTOMER_ID AND c.type_id ="+ ObjectType.EXPORT  +" \n" +
                            "AND c.category_id = sSelectedCategoryId AND c.object_id = f.file_id  \n" +
                            "ORDER BY file_id DESC");
        }


        while (resultSet.next()){
            data = new JsonObject();

            sFilename = resultSet.getString(1);
            sFileUrl = resultSet.getString(2);
            sFileId = resultSet.getString(3);
            sStatus = resultSet.getString(4);
            nStatusID = resultSet.getInt(5);
            nTypeID = resultSet.getInt(6);

            data.put("sFilename",sFilename);
            data.put("sFileUrl",sFileUrl);
            data.put("sFileId",sFileId);
            data.put("sStatus",sStatus);
            data.put("nStatusID",nStatusID);
            data.put("nTypeID",nTypeID);

            dataArray.put(data);

        }
        resultSet.close();




    }catch (Exception exception){
        System.out.println("custId : " +CUSTOMER_ID  + exception.getMessage()  );
    }




    finally {
        if (statement != null) statement.close();
        if (conn != null) connectionPool.free(conn);
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
    
    out.print(dataArray.toString());

%>
