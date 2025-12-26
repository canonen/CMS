<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 2.01.2025
  Time: 10:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.imc.*"
        import="java.io.*"
        import="java.security.MessageDigest"
        import="java.security.NoSuchAlgorithmException"
        import="java.sql.*"
        import="java.util.*"
        import="org.apache.log4j.*"
        import="org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.britemoon.cps.adm.CustAddr" %>
<%@ page import="java.net.InetAddress" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    String custId = cust.s_cust_id;
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }


    String state = request.getParameter("state");
    String address1 = request.getParameter("address1");
    String address2 = request.getParameter("address2");
    String city = request.getParameter("city");
    String country = request.getParameter("country");
    String zip = request.getParameter("zip");
    String phone = request.getParameter("phone");
    String fax = request.getParameter("fax");

    try {



        CustAddr custAddr = new CustAddr(custId);
        int retrieve = custAddr.retrieve();
        if(retrieve != 0) {
            if (state == null) {
                state = custAddr.s_state;
            }
            if (address1 == null) {
                address1 = custAddr.s_address1;
            }
            if (address2 == null) {
                address2 = custAddr.s_address2;
            }
            if (city == null) {
                city = custAddr.s_city;
            }
            if (country == null) {
                country = custAddr.s_country;
            }
            if (zip == null) {
                zip = custAddr.s_zip;
            }
            if (phone == null) {
                phone = custAddr.s_phone;
            }
            if (fax == null) {
                fax = custAddr.s_fax;
            }
        }
        custAddr.s_cust_id = custId;
        custAddr.s_state = state;
        custAddr.s_address1 = address1;
        custAddr.s_address2 = address2;
        custAddr.s_city = city;
        custAddr.s_country = country;
        custAddr.s_zip = zip;
        custAddr.s_phone = phone;
        custAddr.s_fax = fax;

        try {
            custAddr.save();
        }catch (Exception e) {
            out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }

        Connection connection       =null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String saveOrUpdateSql = null;
        String selectSql = null;


        try {

            final  String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
            InetAddress ip = InetAddress.getLocalHost();
		    final  String urdb = "jdbc:sqlserver://"+ip.getHostAddress()+":1433;databaseName=brite_sadm_500";
            // final  String urdb = "jdbc:sqlserver://192.168.151.4:1433;databaseName=brite_sadm_500";
            final  String dbUser = "revotasadm";
            final  String dbPassword = "abs0lut";

            selectSql = "SELECT * FROM sadm_cust_addr WHERE cust_id = " + custId;
            connection = DriverManager.getConnection(urdb,dbUser,dbPassword);
            ps = connection.prepareStatement(selectSql);
            rs = ps.executeQuery();

            if(rs.next()) {
                saveOrUpdateSql = "UPDATE sadm_cust_addr SET state = ?, address1 = ?, address2 = ?, city = ?, country = ?, zip = ?, phone = ?, fax = ? WHERE cust_id = ?";
                ps = connection.prepareStatement(saveOrUpdateSql);
                ps.setString(1, custAddr.s_state);
                ps.setString(2, custAddr.s_address1);
                ps.setString(3, custAddr.s_address2);
                ps.setString(4, custAddr.s_city);
                ps.setString(5, custAddr.s_country);
                ps.setString(6, custAddr.s_zip);
                ps.setString(7, custAddr.s_phone);
                ps.setString(8, custAddr.s_fax);
                ps.setInt(9, Integer.parseInt(custAddr.s_cust_id));
            } else {
                saveOrUpdateSql = "INSERT INTO sadm_cust_addr (cust_id,state,address1,address2,city,country,zip,phone,fax) VALUES (?,?,?,?,?,?,?,?,?)";
                ps = connection.prepareStatement(saveOrUpdateSql);
                ps.setInt(1, Integer.parseInt(custAddr.s_cust_id));
                ps.setString(2, custAddr.s_state);
                ps.setString(3, custAddr.s_address1);
                ps.setString(4, custAddr.s_address2);
                ps.setString(5, custAddr.s_city);
                ps.setString(6, custAddr.s_country);
                ps.setString(7, custAddr.s_zip);
                ps.setString(8, custAddr.s_phone);
                ps.setString(9, custAddr.s_fax);
            }
            ps.executeUpdate();
            out.println("Success");

        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (connection != null) {
                connection.close();
            }
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    }

%>
