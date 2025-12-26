<%@ page
        import="com.britemoon.*"
        import="com.britemoon.sas.*"
        import="com.britemoon.sas.imc.*"
        import="java.net.*"
        import="java.sql.*"
        import="java.util.*"
        import="org.w3c.dom.*"
        import="org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%! static Logger logger = null; %>
<%
    response.setHeader("Expires", "0");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Cache-Control", "no-store, no-cache, max-age=0");
    response.setContentType("text/html;charset=UTF-8");
%>

<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>


<%


    JsonObject data = new JsonObject();
    try
    {

        String sUserLogin = request.getParameter("login");
        String sPassword = request.getParameter("password");

        PreparedStatement	pstmt = null;
        ResultSet			rs;
        ConnectionPool cp = null;
        Connection 			conn  = null;

        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);
        } catch(Exception ex) {
            data.put("Connection Error", ex);
            throw new Exception("Connection Error");
        }
        String sql = "SELECT " +
                " syu.system_user_id as id ," +
                " syu.partner_id as partner_id ," +
                " first_name as firstName ," +
                " last_name as lastName ," +
                " email_address as email ," +
                " status_id as status " +
                " FROM sadm_system_user as syu " +
                " LEFT OUTER JOIN  sadm_system_access_mask as syam on syam.system_user_id = syu.system_user_id " +
                " LEFT JOIN  sadm_system_object_type as syot on syot.type_id = syam.type_id " +
                " LEFT JOIN  scps_access_mask as sam on sam.type_id = syot.type_id " +
                " WHERE syot.type_id = 510 AND username = ? AND password = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, sUserLogin);
        pstmt.setString(2, sPassword);
        rs = pstmt.executeQuery();
        if(rs.next()) {
            Partner partner = new Partner(rs.getString("partner_id"));
            SystemUser user = new SystemUser(rs.getString("id") , sUserLogin , partner.s_partner_id);
            UIEnvironment ui = new UIEnvironment(session, user, partner);

            session = request.getSession(true);

            data.put("success",true);
            data.put("message", "Login Successful.");
            data.put("session",session.getId());
            data.put("firstName", rs.getString("firstName"));
            data.put("lastName", rs.getString("lastName"));
            data.put("email", rs.getString("email"));
            data.put("status", rs.getString("status"));
            data.put("partner", partner.s_partner_name);
        }else {
            data.put("error", "Invalid username or password");
            response.setStatus(403);
            session = request.getSession(false);
            throw new Exception("Invalid username or password");
        }
        out.println(data.toString());
    }
    catch(Exception ex)
    {
        session = request.getSession(false);
        response.setStatus(500);
        data.put("error", ex);
        logger.error("Exception: ", ex);
    }
%>