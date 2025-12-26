<%@ page
        language="java"
        import="com.britemoon.*,
com.britemoon.cps.*,
com.britemoon.cps.adm.*,
com.britemoon.cps.wfl.*,
java.io.*,java.sql.*,
org.json.JSONException,
org.json.XML,
org.json.JSONArray,
java.util.*,org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../../utilities/validator.jsp"%>
<%@ include file="../../header.jsp"%>
<%
    



// === === ===


    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();
    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            sSql = "select * from ccps_object_type";
			 
                    
            pstmt = conn.prepareStatement(sSql);
            
			
            rs = pstmt.executeQuery();
            while (rs.next())
			{
                data= new JsonObject();

                String name = rs.getString(2);
                String obje =(String.valueOf(rs.getInt(1)));


                data.put("read",false);
                data.put("write",false);
                data.put("execute",false);
                data.put("erase",false);
                data.put("approve",false);
                data.put("name",name);
				data.put("data",obje);

//				access.put("read",false);
//				access.put("write",false);
//				access.put("execute",false);
//				access.put("erase",false);
//				access.put("approve",false);
//				access.put("name",rs.getString(2));
//				data.put(String.valueOf(rs.getInt(1)),access);
				
						
				
			}
            array.put(data);
            out.println(array);
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

