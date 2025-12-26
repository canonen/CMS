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
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
  if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);
   
     if(!can.bWrite)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    String customerId = cust.s_cust_id;
    Statement	statement = null;
    ResultSet	resultSet  = null;
    ConnectionPool 	connectionPool 	= null;
    Connection 	connection 	= null;
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    JsonArray globalArray = new JsonArray();
   
    try {
        
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        String campQuery =  "SELECT camp_id, camp_name FROM cque_campaign "+
                            "WHERE origin_camp_id IS NOT NULL AND cust_id = '"+customerId+"' "+
                            " ORDER BY camp_id";
        resultSet = statement.executeQuery(campQuery);
        while(resultSet.next()){
            JsonObject campObject = new JsonObject();
            campObject.put("camp_id", resultSet.getString("camp_id"));
            campObject.put("camp_name", resultSet.getString("camp_name"));
            jsonArray.put(campObject);
        }
        jsonObject.put("CampArray",jsonArray);
        resultSet.close();

        String filterQuery = "SELECT filter_id, filter_name FROM ctgt_filter "+
                             "WHERE filter_name IS NOT NULL AND origin_filter_id IS NULL "+
                             "AND type_id = '"+FilterType.MULTIPART +"' AND  status_id != '"+FilterStatus.DELETED+"' "+
                             "AND cust_id = '"+customerId+"' ORDER BY filter_name";

        resultSet = statement.executeQuery(filterQuery);

        jsonArray = new JsonArray();
        while(resultSet.next()){
            JsonObject filterObject = new JsonObject();
            filterObject.put("filter_id", resultSet.getString("filter_id"));
            filterObject.put("filter_name", resultSet.getString("filter_name"));
            jsonArray.put(filterObject);
        }
        jsonObject.put("FilterArray",jsonArray);
        resultSet.close();
        

        String batchQuery = "SELECT batch_id, batch_name FROM cupd_batch b "+
                            "WHERE ( (b.type_id = 1 AND b.batch_id IN (SELECT DISTINCT i.batch_id FROM cupd_import i, cupd_batch b "+
                            "WHERE i.status_id = '"+UpdateStatus.COMMIT_COMPLETE+"' AND i.batch_id = b.batch_id "+
                            "AND b.cust_id = '"+customerId+"')) OR (b.type_id > 1)) AND b.cust_id = '"+customerId+"' "+
                            "ORDER BY batch_name";

       resultSet = statement.executeQuery(batchQuery);

       jsonArray = new JsonArray();
         while(resultSet.next()){
              JsonObject batchObject = new JsonObject();
              batchObject.put("batch_id", resultSet.getString("batch_id"));
              batchObject.put("batch_name", resultSet.getString("batch_name"));
              jsonArray.put(batchObject);
        }
        jsonObject.put("BatchArray",jsonArray);
        resultSet.close();
        
        String linkQuery = "SELECT DISTINCT link_id, link_name FROM cjtk_link l, cque_campaign c "+
                           "WHERE l.cont_id = c.cont_id AND c.cust_id = '"+customerId+"'";

        resultSet = statement.executeQuery(linkQuery);

        jsonArray = new JsonArray();

        while(resultSet.next()){
            JsonObject linkObject = new JsonObject();
            linkObject.put("link_id", resultSet.getString("link_id"));
            linkObject.put("link_name", resultSet.getString("link_name"));
            jsonArray.put(linkObject);
        }
        jsonObject.put("LinkArray",jsonArray);
        resultSet.close();

        String retriveQuery = "SELECT  attr_id, display_name FROM ccps_cust_attr WHERE cust_id = '"+customerId+"'";
        resultSet = statement.executeQuery(retriveQuery);

        jsonArray = new JsonArray();

        while(resultSet.next()){
            JsonObject retriveObject = new JsonObject();
            retriveObject.put("attr_id", resultSet.getString("attr_id"));
            retriveObject.put("display_name", resultSet.getString("display_name"));
            jsonArray.put(retriveObject);
        }
        jsonObject.put("RetriveArray",jsonArray);
        resultSet.close();

        globalArray.put(jsonObject);
        out.print(globalArray);


    }
    catch(Exception exception) {
        exception.printStackTrace();
    }


%>
