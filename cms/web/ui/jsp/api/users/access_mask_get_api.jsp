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
<%! static Logger logger = null;%>




<%
    String sUserId = request.getParameter("user_id");
    User u = new User(sUserId);



// === === ===



    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sSql = null;
    System.out.println("burada");
	JSONObject data = new JSONObject();
	// JSONArray jsonArray = new JSONArray();
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        try {
            sSql = "SELECT ot.type_id, ot.type_name, mask=ISNULL(am.mask, 0) ";
			 sSql +="FROM ccps_object_type ot ";
			 sSql +="LEFT OUTER JOIN ccps_access_mask am ";
			 sSql +="ON ( ot.type_id = am.type_id ) ";
			 sSql +="AND ( am.user_id = ? ) ";
			 sSql +="WHERE ( 1 = 1 ) ";
                    
            pstmt = conn.prepareStatement(sSql);
            pstmt.setString(1, u.s_user_id);
			
            rs = pstmt.executeQuery();
            while (rs.next())
			{
				
				
				JSONObject access = new JSONObject();
				access.put("read",(AccessRight.READ & rs.getInt(3)) == AccessRight.READ);
				access.put("write",(AccessRight.WRITE & rs.getInt(3)) == AccessRight.WRITE);
				access.put("execute",(AccessRight.EXECUTE & rs.getInt(3)) == AccessRight.EXECUTE);
				access.put("erase",(AccessRight.DELETE & rs.getInt(3)) == AccessRight.DELETE);
				access.put("approve",(AccessRight.APPROVE & rs.getInt(3)) == AccessRight.APPROVE);
				data.put(String.valueOf(rs.getInt(1)),access);
				
				
				System.out.println((AccessRight.READ & rs.getInt(3)) == AccessRight.READ);
					    
						
				
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