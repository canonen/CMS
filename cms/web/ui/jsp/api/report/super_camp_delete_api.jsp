<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    String superCampID = request.getParameter("super_camp_id");

// Connection
    Statement stmt_cque_super_camp_camp = null;
    Statement stmt_crpt_super_link = null;
    Statement stmt_cque_super_camp = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("super_camp_delete_api.jsp");
        stmt_cque_super_camp_camp = conn.createStatement();
        stmt_crpt_super_link = conn.createStatement();
        stmt_cque_super_camp = conn.createStatement();
    } catch (Exception ex) {
        cp.free(conn);
        out.println("<BR>Connection error ... !<BR><BR>");
        return;
    }

    try {
        if (superCampID != null) {

            String query1 = "DELETE FROM cque_super_camp_camp " +
                        "WHERE super_camp_id = " + superCampID;
            stmt_cque_super_camp_camp.executeUpdate(query1);

            String query2 = "DELETE FROM crpt_super_link " +
                    "WHERE  super_camp_id = " + superCampID;
            stmt_crpt_super_link.executeUpdate(query2);

            String query3 = "DELETE FROM cque_super_camp " +
                    "WHERE cust_id = " + cust.s_cust_id + " AND super_camp_id = " + superCampID;
            stmt_cque_super_camp.executeUpdate(query3);

            out.print("Deleted super_camp_id : " + superCampID);
        }
    } catch (Exception ex) {
        ErrLog.put(this, ex, "super_camp_delete_api.jsp", out, 1);
        return;
    } finally {
        if (stmt_cque_super_camp_camp != null) stmt_cque_super_camp_camp.close();
        if (stmt_crpt_super_link != null) stmt_crpt_super_link.close();
        if (stmt_cque_super_camp != null) stmt_cque_super_camp.close();
        if (conn != null) cp.free(conn);
    }

%>