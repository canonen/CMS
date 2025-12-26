<%@ page
        language="java"
        import="org.apache.log4j.*"
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.ctm.*"
        import="java.util.*"
        import="java.sql.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.logging.Logger" %>
<%! static Logger logger = null; %>
<% if (logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "http://dev.revotas.com:3002");
    response.setHeader("Access-Control-Allow-Credentials", "true");
%>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application"/>
<%
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    String isWizard = (String) session.getAttribute("isWizard");
    if ("1".equals(isWizard)) {
        response.sendRedirect("pageedit_wizard.jsp?" + request.getQueryString());
        return;
    }

    int custID = Integer.parseInt(cust.s_cust_id);

    String isHyatt = (String) session.getAttribute("isHyatt");
    if (isHyatt == null || isHyatt.length() == 0) {
        isHyatt = "0";
    }

    PageBean pbean = null;
    TemplateBean tbean = null;

    pbean = (PageBean) session.getAttribute("pbean");
    String sTemplateID = request.getParameter("templateID");
    if (sTemplateID == null || !tbeans.containsKey(new Integer(sTemplateID))) {
        jsonObject.put("Message", "Cannot find template id");
        return;
    }

    int templateID = Integer.parseInt(sTemplateID);
    String contentID = request.getParameter("contentID");

    boolean refreshed = false;
    if (pbean == null || (pbean.getTemplateBean()).getTemplateID() != templateID ||
            (contentID != null && !contentID.equals(String.valueOf(pbean.getContentID())))) {

        tbean = (TemplateBean) tbeans.get(new Integer(templateID));
        boolean ok = false;
        if (isHyatt.equals("1")) {
            ok = tbean.isGlobal(); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
        } else {
            ok = (tbean.getCustID() == 0);
        }
        if (!ok && tbean.getCustID() != custID && !tbean.inChildCustList(custID + "")) {
            jsonObject.put("Message", "Bad CustID For TemplateID");
            return;
        }
        pbean = new PageBean(custID, tbean);
        if (contentID != null) {
            try {
                pbean.load(Integer.parseInt(contentID));
                if (pbean.getCustID() != custID) {
                    jsonObject.put("Message", "Really Bad ClientID For TemplateID");
                    return;
                }
            } catch (SQLException e) {
                throw e;
            }
        } else {
            pbean.setHiddenValues();
        }
        session.setAttribute("pbean", pbean);
        session.setAttribute("tbean", tbean);

        refreshed = true;
    } else {
        tbean = (TemplateBean) session.getAttribute("tbean");
    }
    if (request.getParameter("clone") != null) {
        pbean.setPageName("");
        int oldContentID = pbean.getContentID();
        pbean.setContentID(0);
        response.sendRedirect("pagesave.jsp?oldContentID=" + oldContentID);
        return;
    }
    if (pbean.getPageName().length() == 0) {
        response.sendRedirect("pagesave.jsp");
        return;
    }
    contentID = (contentID != null) ? contentID : String.valueOf(pbean.getContentID());

    ConnectionPool connPool = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    String status = null;
    try {
        connPool = ConnectionPool.getInstance();
        conn = connPool.getConnection(this);
        stmt = conn.createStatement();

        rs = stmt.executeQuery(
                "SELECT status" +
                        " FROM ctm_pages p" +
                        " WHERE p.template_id = " + sTemplateID +
                        " AND p.content_id = " + contentID +
                        " AND p.customer_id = " + custID);

        if (rs.next()) {
            status = rs.getString(1);
            jsonObject.put("status", status);
        }
        rs.close();
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        stmt.close();
        if (conn != null) connPool.free(conn);
    }

    if (contentID == null) {
        contentID = "";
        jsonObject.put("content_id", contentID);
    } else {
        contentID = "&contentID=" + contentID;
        jsonObject.put("content_id", contentID);
    }

    boolean isEdit;
    String sIsEdit = request.getParameter("isEdit");
    if ((sIsEdit != null && sIsEdit.equals("false")) || "locked".equals(status)) {
        isEdit = false;
        jsonObject.put("is_edit", isEdit);
    } else {
        isEdit = true;
        jsonObject.put("is_edit", isEdit);
    }
    String previewType = request.getParameter("previewType");
    if (previewType == null) {
        previewType = "html";
        jsonObject.put("preview_type", previewType);
    }
    jsonArray.put(jsonObject);
    out.print(jsonArray);
%>

