<%@ page
        language="java"
        import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		java.util.*,java.sql.*,
		java.io.*,javax.servlet.*,
		javax.servlet.http.*,org.xml.sax.*,
		javax.xml.transform.*,
		javax.xml.transform.stream.*,org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
        errorPage="../error_page.jsp"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
    JsonObject object = new JsonObject();
    JsonArray array = new JsonArray();

    ConnectionPool cp	= null;
    Connection conn		= null;
    Statement stmt		= null;
    ResultSet rs		= null;

    String sSql ="Exec dbo.usp_ccnt_list_get @type_id=20, @CustomerId="+cust.s_cust_id;

    String modify_date = null;

    try{

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sSql);

        while (rs.next()){
            object = new JsonObject();
            object.put("contID",rs.getString(1));
            object.put("contName",new String(rs.getBytes(2), "UTF-8"));
            object.put("WizardId",rs.getString(3));
            object.put("type_id",rs.getString(4));
            object.put("display_name",rs.getString(5));
            object.put("ModifyDate",dateFormatter(rs.getString(6)));
            object.put("StatusId",rs.getString(7));
            object.put("Status",rs.getString(8));
            object.put("Editor",rs.getString(9));

            Timestamp modify_dateTimestamp = rs.getTimestamp(10);
            if(modify_dateTimestamp != null) {
                modify_date =  modify_dateTimestamp.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            }
            object.put("modify_date",modify_date);


            array.put(object);
        }
        out.print(array);
        rs.close();
    }catch(Exception ex) {
        logger.error("Error in cont_listtest.jsp", ex);
        throw ex;
    } finally{
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.error("ResultSet close error", e);
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                logger.error("Statement close error", e);
            }
        }
        if (conn != null && cp != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                logger.error("Connection close error", e);
            } finally {
                cp.free(conn);
            }
        }
    }

%>

<%!
    private static final DateTimeFormatter IN =
            DateTimeFormatter.ofPattern("MMM d yyyy h:mma", Locale.ENGLISH);

    private static final DateTimeFormatter OUT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private String dateFormatter(String raw) {
        if (raw == null || raw.isEmpty() || raw.equals("---"))
            return null;

        try {

            String cleanedRaw = raw.trim().replaceAll("\\s{2,}", " ");
            return LocalDateTime.parse(cleanedRaw, IN).format(OUT);
        } catch (Exception ex) {
            // Hata durumunda mesaj döndür
            return "HATA: Tarih formatı dönüştürülemedi! (" + ex.getMessage() + ")";
        }
    }
%>
