<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
    ConnectionPool	cp		= null;
    Connection		conn	= null;
    Statement		stmt	= null;
    ResultSet		rs		= null;

    JsonObject data = new JsonObject();
    JsonArray dataArray = new JsonArray();


    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String listTypeID = request.getParameter("typeID");
        String custId =  request.getParameter("custId");
        if (listTypeID == null) listTypeID = "2";
        boolean canSpecTest = ui.getFeatureAccess(Feature.SPECIFIED_TEST);
        boolean canTestHelp = ui.getFeatureAccess(Feature.TESTING_HELP);

        String listType = "Testing List";
        if (listTypeID.equals("1"))
            listType = "Global Exclusion List";
        if (listTypeID.equals("3"))
            listType = "Exclusion List";
        if (listTypeID.equals("4"))
            listType = "Auto-Respond Notification List";
        if (listTypeID.equals("5"))
            listType = "Specified Test Recipient List";

        String id, name, typeName;

        String sSql =
                " SELECT list_id, list_name, type_name" +
                        " FROM cque_email_list l, cque_list_type t " +
                        " WHERE" +
                        " (l.type_id = " + listTypeID + (listTypeID.equals("4") ? " OR l.type_id = 6" : "") + ((listTypeID.equals("2") && canSpecTest) ? " OR l.type_id = 5 OR l.type_id = 7" : "") + ") " +
                        " AND cust_id = " + custId +
                        " AND l.type_id = t.type_id " +
                        " AND list_name not like 'ApprovalRequest(%)' " +
                        " AND l.status_id = '" + EmailListStatus.ACTIVE + "'" +
                        " ORDER BY list_name ASC";

        rs = stmt.executeQuery(sSql);
        while (rs.next()){
            id = rs.getString(1);
            name = rs.getString(2);
            typeName = rs.getString(3);

            data.put("id",id);
            data.put("name",name);
            data.put("typeName",typeName);

            dataArray.put(data);
        }
        rs.close();


    }catch (Exception exception){

        System.out.println(exception.getMessage());
    }finally {
        if (stmt != null) stmt.close();
        if (conn  != null) cp.free(conn);
    }
%>
