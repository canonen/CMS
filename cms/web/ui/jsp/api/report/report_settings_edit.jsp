<%@ page
        language="java"
        import="com.britemoon.cps.imc.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                java.util.*,
                java.sql.*,
                java.util.Date,
                java.io.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    if (!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%

    // Connection
    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;

    try {
        JsonObject reportSettingEdit = new JsonObject();
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("report_settings_edit.jsp");
        stmt = conn.createStatement();

        int nTotalsSecFlag = 1;
        int nGeneralSecFlag = 1;
        int nBBackSecFlag = 1;
        int nActionSecFlag = 1;
        int nDistClickSecFlag = 1;
        int nTotClickSecFlag = 0;
        int nFormSecFlag = 1;
        int nTotReadFlag = 0;
        int nMultiReadFlag = 1;
        int nTotClickFlag = 1;
        int nMultiLinkClickFlag = 1;
        int nLinkMultiClickFlag = 1;
        int nDomainFlag = 1;
        int nOptoutFlag = 0;

        rs = stmt.executeQuery("EXEC usp_crpt_report_settings_get @cust_id = " + cust.s_cust_id);
        if (rs.next()) {
            nTotalsSecFlag = rs.getInt(1);
            nGeneralSecFlag = rs.getInt(2);
            nBBackSecFlag = rs.getInt(3);
            nActionSecFlag = rs.getInt(4);
            nDistClickSecFlag = rs.getInt(5);
            nTotClickSecFlag = rs.getInt(6);
            nFormSecFlag = rs.getInt(7);
            nTotReadFlag = rs.getInt(8);
            nMultiReadFlag = rs.getInt(9);
            nTotClickFlag = rs.getInt(10);
            nMultiLinkClickFlag = rs.getInt(11);
            nLinkMultiClickFlag = rs.getInt(12);
            nDomainFlag = rs.getInt(13);
            nOptoutFlag = rs.getInt(14);

            reportSettingEdit.put("nTotalsSecFlag", nTotalsSecFlag);
            reportSettingEdit.put("nGeneralSecFlag", nGeneralSecFlag);
            reportSettingEdit.put("nBBackSecFlag", nBBackSecFlag);
            reportSettingEdit.put("nActionSecFlag", nActionSecFlag);
            reportSettingEdit.put("nDistClickSecFlag", nDistClickSecFlag);
            reportSettingEdit.put("nTotClickSecFlag", nTotClickSecFlag);
            reportSettingEdit.put("nFormSecFlag", nFormSecFlag);
            reportSettingEdit.put("nTotReadFlag", nTotReadFlag);
            reportSettingEdit.put("nMultiReadFlag", nMultiReadFlag);
            reportSettingEdit.put("nTotClickFlag", nTotClickFlag);
            reportSettingEdit.put("nMultiLinkClickFlag", nMultiLinkClickFlag);
            reportSettingEdit.put("nLinkMultiClickFlag", nLinkMultiClickFlag);
            reportSettingEdit.put("nDomainFlag", nDomainFlag);
            reportSettingEdit.put("nOptoutFlag", nOptoutFlag);
        }
        out.print(reportSettingEdit.toString());
%>


<%
    } catch (Exception ex) {
        ErrLog.put(this, ex, "Report Error.", out, 1);
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>
</body>
</fmt:bundle>


</HTML>
