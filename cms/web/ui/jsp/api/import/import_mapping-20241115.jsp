<%@ page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.cps.*,
        		com.britemoon.cps.upd.*,
        		java.io.*,
        		java.util.*,
        		java.sql.*,
        		java.net.*,
        		org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%

    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);


    JsonArray arr = new JsonArray();
    JsonObject obj = new JsonObject();
    JsonArray arr1 = new JsonArray();
    JsonObject obj1 = new JsonObject();
    JsonArray arr2 = new JsonArray();
    JsonObject obj2 = new JsonObject();
    ServletInputStream in = request.getInputStream();
    HashMap aImportParameters = ImportUtil.downloadImport(in, cust.s_cust_id);

    String sImportName = request.getParameter("import_name").toString().trim();

    String sBatchId = request.getParameter("batch_id").toString().trim();
    if ("null".equals(sBatchId)) sBatchId = null;

    String sFieldSeparator = request.getParameter("delimiter").toString().trim();
    Map<String, String> seperator = new HashMap<String, String>() {{
        put("tab", "\t");
        put("pipe", "|");
        put("semicolon", ";");
        put("comma", ",");
    }};

    String newSeperator = seperator.get(sFieldSeparator).toString();
    if (newSeperator == "pipe") {
        sFieldSeparator = "\\|";
    }
    if (newSeperator == "tab") {
        sFieldSeparator = "\\t";
    }


    System.out.println(newSeperator + " param delimiter");


    String sFirstRow = request.getParameter("row").toString().trim();
    String sImportFile = aImportParameters.get("server_file_name").toString().trim();
    String sUpdRuleId = request.getParameter("upd_rule_id").toString().trim();
    String sFullNameFlag = request.getParameter("full_name_flag").toString().trim();
    String sEmailTypeFlag = request.getParameter("email_type_flag").toString().trim();
    String sUpdHierarchyId = request.getParameter("upd_hierarchy_id").toString().trim();
    String sMultiValueFieldSeparator = request.getParameter("multi_value_delimiter").toString().trim();
    if ("null".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;
    if ("".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;


    String sBatchName = request.getParameter("batch_name").toString().trim();
    String sBatchTypeId = request.getParameter("batch_type").toString().trim();


    String sNewsletters = request.getParameter("newsletters").toString();
    sNewsletters = (((sNewsletters != null) && !sNewsletters.equals("null")) ? sNewsletters.trim() : "");


    String sCategories = request.getParameter("category_temp").toString().trim();
    String sSelectedCategoryId = null;

    try {
        sSelectedCategoryId = request.getParameter("categories").toString().trim();
        if ("null".equals(sSelectedCategoryId)) sSelectedCategoryId = null;
    } catch (Exception ex) {
    }

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sDataDir = Registry.getKey("import_data_dir");

        BufferedReader inb =
                new BufferedReader(
                        new InputStreamReader(
                                new FileInputStream(sDataDir + sImportFile), "UTF-8"));

        int nRowsMap = 26;
        int numRecips = 0;
        stmt.execute("CREATE TABLE #tr (row_id int, col_id int, attr_value varchar(255))");
        while (inb.ready()) {
            numRecips++;
            if (numRecips > nRowsMap) break;

            String oneRow = inb.readLine();
            String[] sElement = oneRow.split(sFieldSeparator.equals("|") ? "\\|" : sFieldSeparator);
            System.out.println("element1 " + sElement.toString());
            PreparedStatement pstmt = null;
            for (int i = 0; i < sElement.length; i++) {
                try {
                    pstmt = conn.prepareStatement("INSERT #tr (row_id, col_id, attr_value) VALUES (?,?,?)");
                    pstmt.setInt(1, numRecips);
                    pstmt.setInt(2, i + 1);
                    pstmt.setBytes(3, sElement[i].getBytes("UTF-8"));
                    pstmt.executeUpdate();
                } catch (Exception ex) {
                    throw ex;
                } finally {
                    if (pstmt != null) pstmt.close();
                }
            }
        }
        inb.close();

        int nCols = 0;
        rs = stmt.executeQuery("SELECT max(col_id) FROM #tr");
        if (rs.next()) nCols = rs.getInt(1);
        rs.close();

        if (sFirstRow.equals("2")) {
            stmt.executeUpdate("UPDATE #tr SET attr_value = a.attr_id FROM #tr, ccps_attribute a, ccps_cust_attr c"
                    + " WHERE #tr.row_id = 1 AND #tr.attr_value = a.attr_name"
                    + " AND c.attr_id = a.attr_id AND c.cust_id = " + cust.s_cust_id);
        }
        int rowID = 0, lastRow = 0;
        int colID = 0, lastCol = 0;
        String val = null;
        String x = "";
        rs = stmt.executeQuery("SELECT row_id, col_id, attr_value FROM #tr WHERE row_id >= " + sFirstRow + " ORDER BY row_id, col_id");

        while (rs.next()) {
            rowID = rs.getInt(1);
            colID = rs.getInt(2);

            val = new String(rs.getBytes(3), "UTF-8");

        }
        obj.put("file", sImportFile);
        obj1.put("value", val);
        arr1.put(obj1);
        arr.put(obj);
        obj2.put("data3", arr);
        obj2.put("data2", arr1);
        arr2.put(obj2);
        out.print(arr2);
        rs.close();

    } catch (Exception ex) {
        throw ex;
    }finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>
