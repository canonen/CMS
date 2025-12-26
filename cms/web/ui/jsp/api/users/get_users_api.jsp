<%@ page
        language="java"
        import="com.britemoon.*,
com.britemoon.cps.*,
com.britemoon.cps.adm.*,
com.britemoon.cps.wfl.*,
java.io.*,java.sql.*,
org.json.JSONException,
org.json.JSONObject,
org.json.XML,
org.json.JSONArray,
java.util.*,org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>




<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>





<%
  
    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;
  	JSONObject data = new JSONObject();	
	JSONArray array = new JSONArray();
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            sSql = "SELECT user_id as userId , user_name + ' ' + ISNull(last_name,'') name, phone, email";
			sSql += " FROM ccps_user WHERE cust_id=" + cust.s_cust_id;
			sSql += " AND status_id!= 40 ORDER BY user_name";
			 
                    
            pstmt = conn.prepareStatement(sSql);
            
			
            rs = pstmt.executeQuery();
            while (rs.next())
			{
				
				
				JSONObject line = new JSONObject();
				line.put("userId", rs.getInt(1));
				line.put("name", rs.getString(2));
				line.put("phone", rs.getString(3));
				line.put("email", rs.getString(4));
				array.put(line);
				
						
				
			}
			rs.close();
			
			
			
        } catch (Exception ex) {
            throw ex;
        } finally {
           
            if (pstmt != null) pstmt.close();
        }
    }

    catch(SQLException sqlex)
    {
    throw sqlex;
    }
    finally
    {
    if(conn != null) cp.free(conn);
    }
%>

<%
data.put("data",array);
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.setHeader("Access-Control-Allow-Origin", "*");
out.print(data);
%>