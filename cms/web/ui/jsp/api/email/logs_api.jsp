<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.wfl.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.net.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%
    boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    CampEditInfo camp_edit_info = null;
    User creator = null;
    User modifier = null;

    String sSql = "";

    JsonObject jsonObject = new JsonObject();
    JsonArray arrayData = new JsonArray();

    JsonObject obj = new JsonObject();
    JsonArray arr = new JsonArray();

    JsonObject newObj = new JsonObject();
    JsonArray newArr = new JsonArray();

    String campId = request.getParameter("camp_id");

    try {
            ResultSet rs = null;
            connectionPool = ConnectionPool.getInstance();
            connection = connectionPool.getConnection(this);
            statement = connection.createStatement();
            sSql = "SELECT"+
        				 " isnull(e.create_date,''),"+
        				 " isnull(s.start_date,''),"+
        				 " isnull(s.finish_date,''),"+
        				 " t.display_name,"+
        				 " a.display_name,"+
        				 " s.recip_queued_qty,"+
        				 " s.recip_sent_qty,"+
        				 " c.camp_id,"+
        				 " c.approval_flag, "+
        				 " t.type_id"+
        			 " FROM cque_campaign c WITH(NOLOCK)"+
        				 " LEFT OUTER JOIN cque_camp_statistic s WITH(NOLOCK)"+
        					 " ON c.camp_id = s.camp_id"+
        				 " LEFT OUTER JOIN cque_camp_edit_info e WITH(NOLOCK)"+
        					 " ON c.camp_id = e.camp_id"+
        				 " INNER JOIN cque_camp_type t WITH(NOLOCK)"+
        					 " ON c.type_id = t.type_id"+
        				 " INNER JOIN cque_camp_status a WITH(NOLOCK)"+
        					 " ON c.status_id = a.status_id"+
        			 " WHERE c.cust_id = "+cust.s_cust_id+" "+
        				 " AND (c.type_id = 2)"+
        	             " AND ISNULL(c.mode_id,0) not in (20,30,40)"+
        				 " AND c.camp_id = "+campId+" "+
        			 " ORDER BY modify_date DESC";

            rs = statement.executeQuery(sSql);
            camp_edit_info = new CampEditInfo(campId);
            creator = new User(camp_edit_info.s_creator_id);
            modifier = new User(camp_edit_info.s_modifier_id);
            while (rs.next()){
                jsonObject = new JsonObject();
                System.out.println(rs.getDate(1));
                jsonObject.put("createDate",rs.getDate(1));
                jsonObject.put("startDate",rs.getDate(2));
                jsonObject.put("finishDate",rs.getDate(3));
                jsonObject.put("displayName",rs.getString(4));
                jsonObject.put("status",rs.getString(5));
                jsonObject.put("queued",rs.getString(6));
                jsonObject.put("sent",rs.getString(7));
                jsonObject.put("campId",rs.getString(8));
                jsonObject.put("approveId",rs.getString(9));
                jsonObject.put("typeId",rs.getString(10));
                arrayData.put(jsonObject);

            }


            rs.close();

            sSql = "select * from cque_camp_edit_info where camp_id="+ campId;

            rs = statement.executeQuery(sSql);

            while(rs.next()) {

                obj = new JsonObject();
                obj.put("creator",creator.s_user_name + " " + creator.s_last_name);
                obj.put("modifier",modifier.s_user_name + " " + modifier.s_last_name);
                obj.put("createDate",rs.getDate(3));
                obj.put("modifiedDate",rs.getDate(5));
                arr.put(obj);

            }

            rs.close();

            newObj = new JsonObject();
            newObj.put("logs",arrayData);
            newObj.put("history",arr);

            newArr.put(newObj);
            out.print(newArr);

    }catch (Exception exception){
            System.out.println(exception.getMessage());
            exception.printStackTrace();
        }
        finally {
            if (statement != null) {
                try {
                    statement.close();
                } catch (SQLException e) {
                    logger.error(e.getMessage(), e);
                }
            }
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    logger.error(e.getMessage(), e);
                }
            }
            if (connectionPool != null) {
                connectionPool.releaseConnection(this);
            }
        }

%>
