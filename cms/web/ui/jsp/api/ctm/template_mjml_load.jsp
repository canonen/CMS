<%@ page
        language="java"
        import="com.britemoon.*,
            com.britemoon.cps.*,
            com.britemoon.cps.ctm.*,
            com.britemoon.cps.adm.CustFeature,
            java.util.*,
            java.sql.*,
            java.io.*,
            java.net.*,
            org.w3c.dom.*,
            java.text.NumberFormat,
            javax.servlet.http.Part,
            org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp" %>

<%
    /*out.println("testteyizz  3");
    ConnectionPool cp       = null;
    Connection conn         = null;
    Statement stmt          = null;
    ResultSet rs            = null;

    String s_cust_id = cust.s_cust_id;
    int templateID = 0;
    int custID = Integer.parseInt(s_cust_id);
    String templateName ="";
    String sSql = "";

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("template_mjml_load.jsp");
        stmt = conn.createStatement();

        sSql ="select isnull(max(template_id), 0) + 1 from ctm_templates WITH(NOLOCK)";
        rs = stmt.executeQuery(sSql);
        rs.next();
        templateID = rs.getInt(1);

        out.println("templateId: " + templateID);

    } catch (Exception e) {
        out.print("Hata1: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }*/
%>

<form action="template_mjml_load.jsp" method="post" enctype="multipart/form-data">
 

    <label for="templateName">Template Name:</label>
    <input type="text" name="templateName" id="templateName" required>

    <label for="templateMJML">Template MJML:</label>
    <input type="file" name="templateMJML" id="templateMJML" accept=".mjml" required>

    <label for="smallImage">Small Image:</label>
    <input type="file" name="smallImage" id="smallImage" accept="image/*" required>

    <label for="largeImage">Large Image:</label>
    <input type="file" name="largeImage" id="largeImage" accept="image/*" required>

    <button type="submit">Upload and Save</button>
</form>

