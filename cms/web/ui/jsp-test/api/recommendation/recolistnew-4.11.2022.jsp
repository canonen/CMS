<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			org.json.JSONObject,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>


<%
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt =null;
		JsonObject data = new JsonObject();
		JsonArray  array = new JsonArray();
		String campName="";
		String campId="";
		String modifyDate="";
		String createDate="";
		String status="";
		String filtered="";

			
		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection(this);
			
			stmt = conn.createStatement();

			String sSql =
				" SELECT" +
				"	camp_name," +
				"	camp_id," +
				"	modify_date," +
				"	create_date," +
				"	(case when status=1 then 'true' else 'false' end) as status," +
				"	(case when filter_id =1 then 'true' else 'false' end)as filtered" +
				" FROM c_recommendation_config" +
				" WHERE status <> 90 AND " +
				"	cust_id=" + cust.s_cust_id;
				
			ResultSet rs = stmt.executeQuery(sSql);
			
			boolean noConfig = true;
			int counter = 0;
			while (rs.next())
			{
				 campName=rs.getString(1);
				 campId=rs.getString(2);
				 modifyDate=rs.getString(3);
				 createDate=rs.getString(4);
				 status=rs.getString(5);
				 filtered=rs.getString(6);
				
				noConfig = false;

				data.put("campName",campName);
				data.put("campId",campId);
				data.put("modifyDate",modifyDate);
				data.put("createDate",createDate);
				data.put("status",status);
				data.put("filtered",filtered);



				array.put(data);
			}
			if (noConfig)
			{

			}
			rs.close();
			out.print(array.toString());
		}

		

		catch(Exception ex)
		{
			throw ex;
		}
		finally
		{
			if (stmt!=null) stmt.close();
			if (conn!=null) cp.free(conn);
		}

%>
