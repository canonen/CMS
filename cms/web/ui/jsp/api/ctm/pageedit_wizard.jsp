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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp" %>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application"/>
<%
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    int custID = Integer.parseInt(cust.s_cust_id);

    String isHyatt = (String) session.getAttribute("isHyatt");
    if (isHyatt == null || isHyatt.length() == 0) {
        isHyatt = "0";
    }
    PageBean pbean = (PageBean) session.getAttribute("pbean");
    TemplateBean tbean = null;

    String sTemplateID = request.getParameter("templateID");
    String contentID = request.getParameter("contentID");
    contentID = ((contentID != null) && (contentID.length() > 0)) ? contentID : null;

    ConnectionPool connPool = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String status = null;
    try {
        connPool = ConnectionPool.getInstance();
        conn = connPool.getConnection(this);
        stmt = conn.createStatement();

        if (contentID != null && !contentID.equals("null")) {
            rs = stmt.executeQuery("select template_id " +
                    "  from ctm_pages " +
                    " where content_id = '" + contentID + "' " +
                    "   and status <> 'deleted'");

            while (rs.next()) {
                sTemplateID = rs.getString(1);
                jsonObject.put("template_id", sTemplateID);
            }
        }
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
        throw e;
    } finally {
        stmt.close();
        if (conn != null) connPool.free(conn);
    }

    if (sTemplateID == null || !tbeans.containsKey(new Integer(sTemplateID))) {
        jsonObject.put("Message", "templateID is null");
        return;
    }
    int templateID = Integer.parseInt(sTemplateID);
    boolean refreshed = false;
    if (pbean == null || (pbean.getTemplateBean()).getTemplateID() != templateID ||
            (contentID != null && !contentID.equals(String.valueOf(pbean.getContentID())))) {

        tbean = (TemplateBean) tbeans.get(new Integer(templateID));
        boolean ok = false;
        if (isHyatt.equals("1")) {
            ok = tbean.isGlobal();
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

    if (contentID == null) {
        try {
            contentID = String.valueOf(pbean.getContentID());
            contentID = "&contentID=" + contentID;
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        if (contentID == null) {
            contentID = "";
			jsonObject.put("contentID", contentID);
        }
    } else {
        contentID = "&contentID=" + contentID;
		jsonObject.put("contentID", contentID);
    }

    boolean isEdit;
    String sIsEdit = request.getParameter("isEdit");
    if ((sIsEdit != null && sIsEdit.equals("false")) || "locked".equals(status)) {
        isEdit = false;
		jsonObject.put("isEdit", isEdit);
    } else {
        isEdit = true;
		jsonObject.put("isEdit", isEdit);
	}
    String previewType = request.getParameter("previewType");
    if (previewType == null){
		previewType = "html";
		jsonObject.put("previewType", previewType);
	}

%>

 

