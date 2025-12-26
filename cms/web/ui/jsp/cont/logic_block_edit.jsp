<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.sql.*"
	import="java.io.*"
	import="javax.xml.transform.*"
	import="javax.xml.transform.stream.*"
	import="org.xml.sax.*"		
	import="org.apache.log4j.*"
    import="com.restfb.json.JsonObject"
    import="com.restfb.json.JsonArray"
	contentType="application/json;charset=UTF-8"
%>


<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%!
    static Logger logger = Logger.getLogger("LogicBlockEditLogger");
%>
<%
    response.setContentType("application/json");

    if(logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    JsonObject resultJson = new JsonObject();
    JsonArray contentArray = new JsonArray();


    JsonArray logicArray = new JsonArray();



    ConnectionPool cp = null;
    Connection conn = null;

    PreparedStatement psContent = null;
    ResultSet rsContent = null;
    PreparedStatement psLogic = null;
    ResultSet rsLogic = null;

    try {
        String sSql = null;
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        sSql =
			" SELECT cont_id, cont_name FROM ccnt_content" +
			" WHERE cust_id = " + cust.s_cust_id +
				" AND type_id = 30 AND status_id = 20" +
				" AND origin_cont_id IS NULL" +
			" ORDER BY cont_name";
        rsContent = psContent.executeQuery(sSql);

        while(rsContent.next()){
            resultJson = new JsonObject();
            resultJson.put("contId",rsContent.getString(1));
            resultJson.put("contName",new String(rsContent.getBytes(2),"UTF-8"));

        contentArray.put(resultJson);
        }
        rsContent.close();
        psContent.close();

        String sql2 = " SELECT filter_id, filter_name " +
            " FROM ctgt_filter" +
            " WHERE cust_id = " + cust.s_cust_id +
                " AND origin_filter_id IS NULL " +
                " AND filter_name IS NOT NULL " +
                " AND type_id = 0 " +
                " AND status_id < " + FilterStatus.DELETED +
                " AND usage_type_id = " + FilterUsageType.CONTENT +
            " ORDER BY filter_name";

        rsLogic = psLogic.executeQuery(sql2);

        while(rsLogic.next()){
            resultJson = new JsonObject();
            resultJson.put("filterId",rsLogic.getString(1));
            resultJson.put("filterName",new String(rsLogic.getBytes(2),"UTF-8"));

        logicArray.put(resultJson);
        }
        rsLogic.close();
        psLogic.close();

        JsonObject resultObject = new JsonObject();
        resultObject.put("content",contentArray);
        resultObject.put("logic",logicArray);

     out.print(resultObject);
    } catch (Exception e) {
        out.print(e.getMessage());
        return;
    }finally {
        // out.print(resultObject);
        if(conn != null) cp.free(conn);
    }

%>