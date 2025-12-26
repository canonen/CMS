<%@ page
        language="java"
        import="com.britemoon.cps.imc.*,
		com.britemoon.cps.*,
		java.sql.*,
		org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%@ include file="../fixTurkishCharacters.jsp" %>

<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    // AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);
    // AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
    // if (!can.bRead) {
    //     response.sendRedirect("../access_denied.jsp");
    //     return;
    // }

    JsonArray swDataArray=new JsonArray();
    JsonArray recoDataArray=new JsonArray();
    JsonArray emailDataArray=new JsonArray();
    JsonArray userDataArray=new JsonArray();
    JsonArray contentDataArray=new JsonArray();

    Statement		stmt			= null;
    ResultSet		rs				= null;
    ConnectionPool	connectionPool	= null;
    Connection		srvConnection	= null;


    String	searchKeywords	= request.getParameter ("keywords").replaceAll("[^a-zA-Z0-9 ]", "");
    String	custId	= user.s_cust_id;

    try
    {
        connectionPool = ConnectionPool.getInstance();
        srvConnection = connectionPool.getConnection(this);

        // smart widget search
        String sql = "SELECT * FROM c_smart_widget_config AS swc " +
                " WHERE swc.cust_id = ? AND swc.popup_name LIKE ? AND swc.status != 90";

        rs = searchRequest(srvConnection, sql, custId, searchKeywords);;
        while ( rs.next() ){
            JsonObject swData=new JsonObject();
            swData.put("id", rs.getInt("id"));
            swData.put("popup_id", rs.getString("popup_id"));
            swData.put("popup_name", rs.getString("popup_name"));
            swData.put("order_number", rs.getString("order_number"));
            swData.put("status", rs.getString("status"));
            swData.put("config_param", rs.getString("config_param"));
            swData.put("create_date", rs.getString("create_date"));
            swData.put("modify_date", rs.getString("modify_date"));
            String configParam = rs.getString("config_param");
            JSONObject jsonParam = new JSONObject(configParam);
            String type = jsonParam.optString("type","null");
            swData.put("type", type);
            swDataArray.put(swData);
        }
        rs.close();

        // Recommendation search
        sql = "SELECT * FROM c_recommendation_config AS reco " +
                " WHERE reco.cust_id = ? AND reco.camp_name LIKE ?";

        rs = searchRequest(srvConnection, sql, custId, searchKeywords);
        while ( rs.next() ){
            JsonObject recoData=new JsonObject();
            recoData.put("camp_id", rs.getString("camp_id"));
            recoData.put("camp_name", fixTurkishCharacters2(rs.getString("camp_name")));
            recoData.put("camp_type", rs.getString("camp_type"));
            recoData.put("create_date", rs.getString("create_date"));
            recoData.put("modify_date", rs.getString("modify_date"));
            recoDataArray.put(recoData);
        }
        rs.close();

        // Email search //
        sql = "SELECT * " +
                " FROM cque_campaign AS cqcamp " +
                " LEFT JOIN ccnt_content AS cccont ON cccont.cont_id = cqcamp.cont_id " +
                " LEFT JOIN crpt_camp_summary AS ccsum ON ccsum.camp_id = cqcamp.camp_id " +
                " WHERE cqcamp.cust_id = ? AND cqcamp.camp_name LIKE ? " +
                " AND cqcamp.status_id IN (57,60) ";

        rs = searchRequest(srvConnection, sql, custId, searchKeywords);
        while ( rs.next() ){
            JsonObject emailData=new JsonObject();
            emailData.put("type_id", rs.getString("type_id")); // cqcamp.type_id
            emailData.put("camp_name", fixTurkishCharacters2(rs.getString("camp_name")));
            emailData.put("camp_id", rs.getString("camp_id"));
            emailData.put("status_id", rs.getString("status_id"));
            emailData.put("media_type_id", rs.getString("media_type_id"));
            emailData.put("approval_flag", rs.getString("approval_flag"));
            emailData.put("last_update_date", rs.getString("last_update_date"));
            emailData.put("bbacks", rs.getString("bbacks"));
            emailData.put("unsubs", rs.getString("unsubs"));

            emailData.put("tot_reads", rs.getString("tot_reads"));
            emailData.put("tot_clicks", rs.getString("tot_clicks"));
            emailData.put("update_job_id", rs.getString("update_job_id"));
            emailDataArray.put(emailData);
        }
        rs.close();

        // User search
        sql = "SELECT * " +
                " FROM ccps_user AS cu " +
                " WHERE cu.cust_id = ? AND cu.user_name LIKE ?";

        rs = searchRequest(srvConnection, sql, custId, searchKeywords);
        while ( rs.next() ){
            JsonObject userData=new JsonObject();
            userData.put("user_id", rs.getString("user_id"));
            userData.put("user_name", rs.getString("user_name"));
            userData.put("email", rs.getString("email"));
            userData.put("phone", rs.getString("phone"));
            userDataArray.put(userData);
        }
        rs.close();

        // Content search
        sql = "SELECT * " +
                " FROM ccnt_content AS cccont " +
                " WHERE cccont.cust_id = ? " +
                " AND cccont.cont_name LIKE ? " +
                " AND cccont.status_id = 20 ";

        rs = searchRequest(srvConnection, sql, custId, searchKeywords);
        while ( rs.next() ){
            JsonObject contentData=new JsonObject();
            contentData.put("content_id", rs.getInt("cont_id"));
            contentData.put("cont_name", fixTurkishCharacters2(rs.getString("cont_name")));
            contentData.put("status_id", rs.getInt("status_id"));
            contentData.put("origin_cont_id", rs.getInt("origin_cont_id"));
            contentData.put("type_id", rs.getInt("type_id"));
            contentData.put("reusable_flag", rs.getInt("reusable_flag"));
            contentData.put("cti_doc_id", rs.getString("cti_doc_id"));
            contentDataArray.put(contentData);
        }
        rs.close();

        JsonObject responseData = new JsonObject();
        responseData.put("SmartWidget",swDataArray);
        responseData.put("Recommendation",recoDataArray);
        responseData.put("Email",emailDataArray);
        responseData.put("User",userDataArray);
        responseData.put("Content",contentDataArray);
        out.print(responseData);
    }
    catch(Exception ex) {
        ErrLog.put(this,ex, String.valueOf(1));
    }
    finally {
        if ( rs != null ) rs.close();
        if ( stmt != null ) stmt.close();
        if ( srvConnection != null ) connectionPool.free(srvConnection);
    }

%>
<%!
    private static ResultSet searchRequest(Connection srvConnection, String sql, String custId, String searchKeywords) throws SQLException {
        PreparedStatement pstmt = srvConnection.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(custId));
        pstmt.setString(2, "%" + searchKeywords + "%");
        return pstmt.executeQuery();
    }
%>