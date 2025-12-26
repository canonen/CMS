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




<%@ include file="../../validator_api.jsp"%>





<%
    



// === === ===



    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;
  	JSONObject data = new JSONObject();	
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            sSql = "select * from ccps_ui_type";
			 
                    
            pstmt = conn.prepareStatement(sSql);
            
			
            rs = pstmt.executeQuery();
            while (rs.next())
			{
				
				
				
				data.put(String.valueOf(rs.getInt(1)),rs.getString(2));
				
						
				
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
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.setHeader("Access-Control-Allow-Origin", "*");
out.print(data);
%>