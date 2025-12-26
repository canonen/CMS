<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                java.io.*,
                java.sql.*,
                java.util.*,
                java.sql.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt" %>
<%! static Logger logger = null;%>


<%

    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    boolean bPasswordExpiring = user.isPassExpiring();
    boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    boolean hasChildren = false;

    String sCustId = request.getParameter("cust_id");

    Customer cSuper = ui.getSuperiorCustomer();
    Customer cActive = ui.getActiveCustomer();

    if (sCustId != null) {
        cActive = ui.setActiveCustomer(session, sCustId);
    }

    String seenPop = null;
    if (seenPop == null) seenPop = ui.getSessionProperty("pass_exp_pop");
    if ((seenPop == null) || ("".equals(seenPop))) seenPop = "0";

    if (cSuper.m_Customers != null) hasChildren = true;

    JsonObject data = new JsonObject();
    JsonObject superiorCustomer = new JsonObject();
    JsonObject activeCustomer = new JsonObject();
    JsonArray dataArray = new JsonArray();

    ConnectionPool connPool = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet resultSet_cSuper = null;
    ResultSet resultSet_cActive = null;

    data.put("hasChildren", hasChildren);
    data.put("customer_name", cSuper.s_cust_name);
    data.put("cust_id", cSuper.s_cust_id);
    data.put("login_name", cSuper.s_login_name);
    data.put("password_expiring", bPasswordExpiring);
    data.put("s_level_id", cSuper.s_level_id);
    data.put("s_css_filename", ui.s_css_filename);

    try {
        connPool = ConnectionPool.getInstance();
        conn = connPool.getConnection(this);
        pstmt = conn.prepareStatement(cSuper.getRetrieveSql());

        pstmt.setString(1, sCustId);
        pstmt.setString(2, cSuper.s_login_name);

        resultSet_cSuper = pstmt.executeQuery();

        while (resultSet_cSuper.next()) {
            superiorCustomer.put("s_login_name", resultSet_cSuper.getString(3));
            superiorCustomer.put("s_status_id", resultSet_cSuper.getString(4));
            superiorCustomer.put("s_level_id", resultSet_cSuper.getString(5));
            superiorCustomer.put("s_parent_cust_id", resultSet_cSuper.getString(6));
            superiorCustomer.put("s_max_bbacks", resultSet_cSuper.getString(7));
            superiorCustomer.put("s_descrip", resultSet_cSuper.getString(8));
            superiorCustomer.put("s_upd_rule_id", resultSet_cSuper.getString(9));
            superiorCustomer.put("s_upd_hierarchy_id", resultSet_cSuper.getString(10));
            superiorCustomer.put("s_unsub_hierarchy_id", resultSet_cSuper.getString(11));
            superiorCustomer.put("s_max_bback_days", resultSet_cSuper.getString(12));
            superiorCustomer.put("s_pass_expire_interval", resultSet_cSuper.getString(13));
            superiorCustomer.put("s_pass_notify_days", resultSet_cSuper.getString(14));
            superiorCustomer.put("s_cti_group_id", resultSet_cSuper.getString(15));
            superiorCustomer.put("s_max_consec_bbacks", resultSet_cSuper.getString(16));
            superiorCustomer.put("s_max_consec_bback_days", resultSet_cSuper.getString(17));
            superiorCustomer.put("s_max_domains_on_report", resultSet_cSuper.getString(18));
        }

        data.put("superiorCustomer", superiorCustomer);

        if (hasChildren && cSuper != cActive) {
            data.put("children", cActive.s_cust_name);
        }
        resultSet_cSuper.close();


        pstmt = conn.prepareStatement(cActive.getRetrieveSql());

        pstmt.setString(1, sCustId);
        pstmt.setString(2, cActive.s_login_name);
        resultSet_cActive = pstmt.executeQuery();


        while (resultSet_cActive.next()) {
            activeCustomer.put("s_login_name", resultSet_cActive.getString(3));
            activeCustomer.put("s_status_id", resultSet_cActive.getString(4));
            activeCustomer.put("s_level_id", resultSet_cActive.getString(5));
            activeCustomer.put("s_parent_cust_id", resultSet_cActive.getString(6));
            activeCustomer.put("s_max_bbacks", resultSet_cActive.getString(7));
            activeCustomer.put("s_descrip", resultSet_cActive.getString(8));
            activeCustomer.put("s_upd_rule_id", resultSet_cActive.getString(9));
            activeCustomer.put("s_upd_hierarchy_id", resultSet_cActive.getString(10));
            activeCustomer.put("s_unsub_hierarchy_id", resultSet_cActive.getString(11));
            activeCustomer.put("s_max_bback_days", resultSet_cActive.getString(12));
            activeCustomer.put("s_pass_expire_interval", resultSet_cActive.getString(13));
            activeCustomer.put("s_pass_notify_days", resultSet_cActive.getString(14));
            activeCustomer.put("s_cti_group_id", resultSet_cActive.getString(15));
            activeCustomer.put("s_max_consec_bbacks", resultSet_cActive.getString(16));
            activeCustomer.put("s_max_consec_bback_days", resultSet_cActive.getString(17));
            activeCustomer.put("s_max_domains_on_report", resultSet_cActive.getString(18));
        }

        data.put("activeCustomer", activeCustomer);

        dataArray.put(data);

        out.print(dataArray.toString());
        resultSet_cActive.close();
    } catch (Exception ex) {
        throw ex;
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) connPool.free(conn);
    }

%>