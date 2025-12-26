<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="com.britemoon.*" %>
<%@ page import="com.britemoon.cps.*" %>
<%@ page import="com.britemoon.cps.imc.*" %>
<%@ page
        language="java"
        import="com.britemoon.*,
    com.britemoon.cps.*,
    java.sql.*,java.io.*,
    java.util.*,java.net.*,
    org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="org.json.JSONObject" %>
<%@ include file="header.jsp"%>
<%@ include file="../header.jsp" %>

<%!
  private static final Logger logger = Logger.getLogger("reset_password.jsp");
%>

<%
  try {
    String userEmail = request.getParameter("user_email");
    String sPassword = request.getParameter("password");

    String userId = null;
    User userSadm = null;
    JSONObject data1 = new JSONObject();
    Connection connection = null;


    try {
      ConnectionPool cp = ConnectionPool.getInstance();
      Connection conn = cp.getConnection(this);

      String sSql = "SELECT TOP 1 cu.user_id FROM ccps_user as cu" +
              " LEFT JOIN  ccps_customer  as cc on cc.cust_id = cu.cust_id" +
              " WHERE  cu.email = ? AND cu.status_id= 30 AND cc.status_id = 3  ORDER BY user_id DESC";
      PreparedStatement preStm = conn.prepareStatement(sSql);
      preStm.setString(1, userEmail);
      ResultSet rs = preStm.executeQuery();
      if (rs.next()) {
        userId = rs.getString(1);
      }
      rs.close();
      preStm.close();
      cp.free(conn);

      if(userId != null && !userId.isEmpty()) {
        //SADM veritabanı scps_user tablosunda da password güncellemesi yapılacak.
        try {
          InetAddress ip = InetAddress.getLocalHost();
          final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
          //final  String urdb = "jdbc:sqlserver://192.168.151.4:1433;databaseName=brite_sadm_500";
          final String dbUser = "revotasadm";
          final String dbPassword = "abs0lut";

          sSql = "SELECT TOP 1 user_id, user_name, password, cust_id, login_name, [position], " +
                  "phone, email, descrip, status_id, last_name, pass_exp_date, " +
                  "pass_notify_date, recip_owner, pv_login, pv_password FROM scps_user WHERE  email = ? ORDER BY user_id DESC";
          connection = DriverManager.getConnection(urdb, dbUser, dbPassword);
          PreparedStatement preparedStatement = connection.prepareStatement(sSql);
          preparedStatement.setString(1, userEmail);
          ResultSet resultSet = preparedStatement.executeQuery();
          if (resultSet.next()) {
            userSadm = new User();
            userSadm.s_user_id = resultSet.getString("user_id");
            userSadm.s_user_name = resultSet.getString("user_name");
            userSadm.s_password = resultSet.getString("password");
            userSadm.s_cust_id = resultSet.getString("cust_id");
            userSadm.s_login_name = resultSet.getString("login_name");
            userSadm.s_position = resultSet.getString("position");
            userSadm.s_phone = resultSet.getString("phone");
            userSadm.s_email = resultSet.getString("email");
            userSadm.s_descrip = resultSet.getString("descrip");
            userSadm.s_status_id = resultSet.getString("status_id");
            userSadm.s_last_name = resultSet.getString("last_name");
            userSadm.s_pass_exp_date = resultSet.getString("pass_exp_date");
            userSadm.s_pass_notify_date = resultSet.getString("pass_notify_date");
            userSadm.s_recip_owner = resultSet.getString("recip_owner");
            userSadm.s_pv_login = resultSet.getString("pv_login");
            userSadm.s_pv_password = resultSet.getString("pv_password");
          }
        } catch (Exception e) {
          data1.put("success", false);
          data1.put("message", "Server error: " + e.getMessage());
          response.setStatus(500);
          out.print(data1.toString());
          logger.error("Error in reset_password.jsp", e);
          throw e;
        }
      }


    } catch (Exception ex) {
      data1.put("success", false);
      data1.put("message", "Server error: " + ex.getMessage());
      response.setStatus(500);
      out.print(data1.toString());
      logger.error("Error in reset_password.jsp", ex);
      throw ex;
    }

    if (userId != null) {
      User user = new User(userId);
      user.s_password = sPassword;
      user.save();

      if(userSadm != null) {
        userSadm.s_password = sPassword;
        userSadm.m_sSaveSql =
                " EXECUTE usp_scps_user_save" +
                        "	@user_id=?," +
                        "	@user_name=?," +
                        "	@last_name=?," +
                        "	@password=?," +
                        "	@cust_id=?," +
                        "	@login_name=?," +
                        "	@position=?," +
                        "	@phone=?," +
                        "	@email=?," +
                        "	@descrip=?," +
                        "	@status_id=?," +
                        "	@pass_exp_date=?," +
                        "	@pass_notify_date=?," +
                        "	@recip_owner=?," +
                        "	@pv_login=?," +
                        "	@pv_password=?";
        userSadm.save(connection);
      }
      data1.put("success", true);
      data1.put("message", user.s_user_name + " password updated successfully.");
      out.print(data1.toString());
    } else {
      data1.put("success", false);
      data1.put("message", "User not found.");
      out.print(data1.toString());
      return;
    }

  } catch (Exception ex) {
    System.out.println();
    JSONObject data1 = new JSONObject();
    data1.put("success", false);
    data1.put("message", "Server error: " + ex.getMessage());
    response.setStatus(500);
    out.print(data1.toString());
    logger.error("Error in reset_password.jsp", ex);
  }


%>