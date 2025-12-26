<%@ page
        language="java"
        import="com.britemoon.cps.imc.*,
		com.britemoon.cps.*,
		java.sql.*,
		org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    Statement		stmt			= null;
    ResultSet		rs				= null;
    ConnectionPool	connectionPool	= null;
    Connection		srvConnection	= null;
    JsonObject responseData = new JsonObject();

    String  finishDate  = request.getParameter("finishDate");
    String  custId  = user.s_cust_id;

    LocalDateTime finishLocalDate = LocalDateTime.parse(finishDate);
    Timestamp tsFinishDate = Timestamp.valueOf(finishLocalDate);

    try
    {
        connectionPool = ConnectionPool.getInstance();
        srvConnection = connectionPool.getConnection(this);

        String sql = "UPDATE ccps_attribute_xml_summary " +
                " SET status = 'N/A' WHERE cust_id = ?  AND finish_date = ?";

        PreparedStatement pstmt = srvConnection.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(custId));
        pstmt.setTimestamp(2, tsFinishDate);
        int success= pstmt.executeUpdate();

        if ( success==1 ){
            responseData.put("Update","Success");
        }else responseData.put("Update","Fail");
        out.print(responseData);
    }
    catch(Exception ex) {
        ErrLog.put(this,ex, String.valueOf(1));
    }
    finally {
        if ( rs != null ) rs.close();
        if ( stmt != null ) stmt.close();
        if ( srvConnection != null ) connectionPool.free(srvConnection);
    }

%>