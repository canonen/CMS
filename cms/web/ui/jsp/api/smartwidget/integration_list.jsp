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
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../db_resource_util.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

    DBResourceUtil dbUtil = new DBResourceUtil();
    JsonObject object = new JsonObject();
    JsonArray array = new JsonArray();

    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";
    try {
		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);
		statement = connection.createStatement();

		sSql="SELECT f.form_id, f.form_name FROM csbs_form f, csbs_form_edit_info fei WHERE f.cust_id = "
                                                        + cust.s_cust_id
                                                        + " AND fei.form_id = f.form_id ORDER BY f.form_name ASC" ;
        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){
            object = new JsonObject();
            object.put("value",resultSet.getString(1));
            object.put("label",resultSet.getString(2));

            array.put(object);
        }
        resultSet.close();
        out.println(array);
	}catch (Exception exception){
     			System.out.println(exception.getMessage());
     			exception.printStackTrace();
    }finally {
        dbUtil.closeResources(resultSet, statement, connection, connectionPool);
    }
%>