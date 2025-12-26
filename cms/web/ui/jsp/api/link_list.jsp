<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<% if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
%>

<%
    JsonObject object = new JsonObject();
    JsonArray array = new JsonArray();
    
    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";


	try{
		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);
		statement = connection.createStatement();
		sSql="SELECT link_id, '[' + c.camp_name + '] ' + link_name AS formatted_name" +
					" FROM cjtk_link l WITH(NOLOCK) JOIN cque_campaign c WITH(NOLOCK) ON l.cont_id = c.cont_id" +
					" WHERE" +
					//" (l.origin_link_id IS NULL) AND" +
					" l.href IS NOT NULL AND" +
					" l.cust_id = " + user.s_cust_id + " AND" +
					" l.cont_id = c.cont_id AND" +
					" c.origin_camp_id IS NOT NULL AND" +
					" c.type_id != 1" +
					" ORDER BY formatted_name";
                                                       
        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){
            object = new JsonObject();
            object.put("linkId",resultSet.getString(1));
            object.put("linkName",resultSet.getString(2));
            array.put(object);
        }

        resultSet.close();
		out.println(new String(array.toString().getBytes(), "UTF-8"));
	}catch (Exception exception){
     	System.out.println(exception.getMessage());
     	exception.printStackTrace();
    }
%>