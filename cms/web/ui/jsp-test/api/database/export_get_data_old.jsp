<%@ page
        language="java"
        import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.tgt.Filter,
		java.sql.*,java.util.*,
		java.io.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>

<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);
%>
<%

    if(!can.bWrite)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    Statement	stmt;
    ResultSet	rs;
    ConnectionPool 	connectionPool 	= null;
    Connection 	srvConnection 	= null;
    JsonObject dataObjectJson = new JsonObject();
    JsonArray arrayJson = new JsonArray();
    JsonObject data = new JsonObject();
    JsonObject data1 = new JsonObject();
    JsonObject data2 = new JsonObject();
    JsonObject data3 = new JsonObject();
    JsonObject data4 = new JsonObject();
    JsonArray globalArray = new JsonArray();
    JsonObject globalObject = new JsonObject();

            String sSQLCampDet = null;
    String		CUSTOMER_ID	= cust.s_cust_id;
    String campId=null;
    String campName=null;

    try {



        connectionPool = ConnectionPool.getInstance();
        srvConnection = connectionPool.getConnection("export_get_data.jsp");
        stmt  = srvConnection.createStatement();
    } catch(Exception ex) {
        connectionPool.free(srvConnection);
        return;
    }

    try {
        sSQLCampDet =
                "SELECT camp_id, camp_name" +
                        " FROM cque_campaign " +
                        " WHERE origin_camp_id IS NOT NULL" +
                        " AND cust_id = " + CUSTOMER_ID +
                        " ORDER BY camp_id";

        rs = stmt.executeQuery(sSQLCampDet);

        while (rs.next()) {
            dataObjectJson = new JsonObject();

            campId = rs.getString(1);
            campName = new String(rs.getBytes(2), "ISO-8859-1");

            dataObjectJson.put("campId", campId);
            dataObjectJson.put("campName", campName);

            arrayJson.put(dataObjectJson);
        }
        data.put("CampId",arrayJson);
        rs.close();


        String filtersSql =
                "SELECT filter_id, filter_name" +
                        " FROM ctgt_filter" +
                        " WHERE filter_name IS NOT NULL AND origin_filter_id IS NULL" +
                        " AND type_id = " + FilterType.MULTIPART +
                        " AND status_id != " + FilterStatus.DELETED +
                        " AND cust_id = " + CUSTOMER_ID +
                        " ORDER BY filter_name";


        rs = stmt.executeQuery(filtersSql);

        arrayJson = new JsonArray();
        while (rs.next()) {
            data1 = new JsonObject();

            String filterId = rs.getString(1);
            String filterName = new String(rs.getBytes(2), "ISO-8859-1");

            data1.put("FilterId", filterId);
            data1.put("FilterName", filterName);

            arrayJson.put(data1);
        }
        data.put("filterIDArray",arrayJson);

        rs.close();


        String batchsSql =
                " SELECT b.batch_id, b.batch_name" +
                        " FROM cupd_batch b" +
                        " WHERE ( (b.type_id = 1" +
                        " AND b.batch_id IN" +
                        " (SELECT DISTINCT i.batch_id" +
                        " FROM cupd_import i, cupd_batch b" +
                        " WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE +
                        " AND i.batch_id = b.batch_id" +
                        " AND b.cust_id = " + CUSTOMER_ID+ "))" +
                        " OR (b.type_id > 1) )" +
                        " AND b.cust_id = " + CUSTOMER_ID +
                        " ORDER BY batch_name";

        rs = stmt.executeQuery(batchsSql);

        arrayJson = new JsonArray();
        while (rs.next()) {
            data2 = new JsonObject();

            String batchId = rs.getString(1);
            String batchName = new String(rs.getBytes(2), "ISO-8859-1");

            data2.put("BatchId", batchId);
            data2.put("BatchName", batchName);

            arrayJson.put(data2);
        }
        data.put("BatchIDArray",arrayJson);

        rs.close();

        String linksSql =
                "SELECT DISTINCT link_id, link_name"
                        + " FROM cjtk_link l, cque_campaign c"
                        + " WHERE l.cont_id = c.cont_id AND c.cust_id = "+ CUSTOMER_ID;

        rs = stmt.executeQuery(linksSql);

        arrayJson = new JsonArray();
        while (rs.next()) {
            data3 = new JsonObject();

            String linkId = rs.getString(1);
            String linkName = new String(rs.getBytes(2), "ISO-8859-1");

            data3.put("LinkId2", linkId);
            data3.put("LinkName", linkName);

            arrayJson.put(data3);
        }
        data.put("linkIDArray",arrayJson);
        rs.close();


//         linksSql =
//                "SELECT  attr_id, attr_name"
//                        + " FROM ccps_attribute"
//                        + " WHERE cust_id = "+ CUSTOMER_ID;
//
//        rs = stmt.executeQuery(linksSql);
//
//        arrayJson = new JsonArray();
//        while (rs.next()) {
//            dataObjectJson = new JsonObject();
//
//
//            dataObjectJson.put("attrID", rs.getString(1));
//            dataObjectJson.put("attrName", rs.getString(2));
//
//            arrayJson.put(dataObjectJson);
//        }
//        rs.close();
//        out.println(arrayJson);

        linksSql =
                "SELECT  attr_id, display_name"
                        + " FROM ccps_cust_attr"
                        + " WHERE cust_id = "+ CUSTOMER_ID;

        rs = stmt.executeQuery(linksSql);

        arrayJson = new JsonArray();
        while (rs.next()) {
            data4 = new JsonObject();

            data4.put("retrieveID", rs.getString(1));
            data4.put("retrieveName", rs.getString(2));

            arrayJson.put(data4);
        }
        data.put("arrayRetrieve",arrayJson);

        rs.close();
        globalArray.put(data);
        out.println(globalArray);



    }catch (Exception e){
        System.out.println(e);
    }
    finally {
        if (stmt != null) stmt.close();
        if (srvConnection != null) connectionPool.free(srvConnection);
    }





%>
