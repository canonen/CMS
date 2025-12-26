<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>


<%
    String sCustId = request.getParameter("custId");
    String sSelectedCategoryId = request.getParameter("categoryId");

    ConnectionPool cp = null;
    Connection conn = null;

    PreparedStatement pstmt = null;
    ResultSet rs;
    String sSql;
    String date = "date";

    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();

    String sFilterId;
    String sFilterName;
    String sModifyDate;



    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        out.println(getStatistics(Integer.valueOf(sCustId)));

        try {


            sSql = "execute usp_ctgt_filter_list_get_report "+ sCustId + ", " + sSelectedCategoryId + ", @start_record=?, @page_size=?, @orderby=?";
            pstmt = conn.prepareStatement(sSql);
            
            pstmt.setInt(1, 1);
            pstmt.setInt(2, 1);
            pstmt.setString(3, date);


            rs = pstmt.executeQuery();


            while (rs.next()) {
                data = new JsonObject();
                sFilterId = rs.getString(1);
                sFilterName = new String(rs.getBytes(2), "UTF-8");
                sModifyDate = rs.getString(3);
                data.put("filterID", sFilterId);
                data.put("categoryID", sFilterName);
                data.put("modifyDate", sModifyDate);

                arrayData.put(data);

            }
            rs.close();
            out.print(arrayData.toString());

        } catch (SQLException sqlex) {
            throw sqlex;
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) cp.free(conn);
        }

    }catch(Exception ex)
    {
    throw ex;
    }finally
    {
    if(conn != null) cp.free(conn);
    }
%>

<%!
    private String getStatistics(Integer sCustId) throws Exception {
        String sFilterId;
        PreparedStatement pstmt = null;
        ResultSet rs;
        String sSql;
        ConnectionPool cp = ConnectionPool.getInstance();
        Connection conn = cp.getConnection(this);
        JsonArray arrayDataStat;
        try {
            sSql =
                    " SELECT f.filter_id" +
                            " FROM ctgt_filter f WITH(NOLOCK)" +
                            " WHERE f.origin_filter_id IS NULL" +
                            " AND f.type_id = " + FilterType.MULTIPART +
                            " AND f.cust_id = " + String.valueOf(sCustId) +
                                       " AND f.status_id IN (" + 
            //                FilterStatus.READY + ")";
                            FilterStatus.QUEUED_FOR_PROCESSING + ", " +
                            FilterStatus.PROCESSING + ")";




            pstmt = conn.prepareStatement(sSql);
            rs = pstmt.executeQuery();
            arrayDataStat = new JsonArray();

            while (rs.next()) {
                JsonObject dataStat = new JsonObject();
                sFilterId = rs.getString(1);
                dataStat.put("filterID", sFilterId);

                arrayDataStat.put(dataStat);

            }
            rs.close();


        } catch (SQLException sqlex) {
            throw sqlex;
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) cp.free(conn);
        }
        return arrayDataStat.toString();
    }
%>