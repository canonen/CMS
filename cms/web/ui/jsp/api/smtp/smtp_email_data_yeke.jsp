<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 19.12.2024
  Time: 10:41
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java"
         import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp"%>
<%! static Logger logger = null;%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.net.InetAddress" %>


<%
    if(logger == null){
        logger = Logger.getLogger(this.getClass().getName());
    }

    boolean isClicked = false;
    boolean isOpened = false;


    Connection connection       =null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String sql = null;

    String transactionId	= request.getParameter("transaction_id");
    String toEmail = request.getParameter("recipient_to");
    String domain = request.getParameter("recipient_domain");
    String subject = request.getParameter("subject");

    String whereCondition = "";
    if(transactionId != null && !transactionId.isEmpty()){
        whereCondition += " AND transactionID = '"+transactionId+"'";
    }
    if(toEmail != null && !toEmail.isEmpty()){
        whereCondition += " AND emailTo = '"+toEmail+"'";
    }
    if(domain != null && !domain.isEmpty()){
        whereCondition += " AND emailTo LIKE '%"+domain+"'";
    }
    if(subject != null && !subject.isEmpty()){
        whereCondition += " AND subject LIKE '%"+subject+"%'";
    }
    try {

        final String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        final String urdb = "jdbc:sqlserver://192.168.151.6:1433;databaseName=brite_ainb_500";
        final String dbUser = "revotasadm";
        final String dbPassword = "l3br0nj4m3s";

        sql = "SELECT"
                + " account_id as account_id , reportType as reportType , custId as custId ,   transactionID as transactionID ,"
                + " createdDate as createdDate , lastmodifiedDate as lastmodifiedDate , timeDelivered as timeDelivered ,"
                + " timeQueued as timeQueued , emailTo as emailTo , emailToOriginal as emailToOriginal ,"
                + " emailFrom as emailFrom ,  subject as subject ,timeBounced as timeBounced ,"
                + " dsnAction as dsnAction , dsnStatus as dsnStatus , dsnRemoteMta as dsnRemoteMta , dsnDiagnostics as dsnDiagnostics , status as status  , alc.type_id as type_id"
                + " FROM brite_ainb_500.dbo.mail_pmta_acct as mpa"
                + " LEFT JOIN brite_ainb_500.dbo.ainb_link_activity as alc on alc.transaction_id = mpa.transactionID "
                + " where transactionID IS NOT NULL  "
                +   whereCondition
                + " AND custId = '"+cust.s_cust_id+"'";
        connection = DriverManager.getConnection(urdb, dbUser, dbPassword);
        ps = connection.prepareStatement(sql);
        rs = ps.executeQuery();
        HashMap<String ,EmailRowModel> rowMap = new HashMap<String ,EmailRowModel>();
        JsonArray arr = new JsonArray();
        int clickCount = 0;
        int openCount = 0;
        while (rs.next()){

            if(rs.getString("transactionID").equals("ec3049ad-2dbc-4d76-9012-37fe4d6bebcf")){
                System.out.println("transactionID : "+rs.getString("transactionID"));
            }

            EmailRowModel emailRowModel = new EmailRowModel();
            emailRowModel.setAccountId(rs.getString("account_id"));
            emailRowModel.setReportType(rs.getString("reportType"));
            emailRowModel.setCustomerId(rs.getString("custId"));
            emailRowModel.setTransactionID(rs.getString("transactionID"));
            emailRowModel.setCreatedDate(rs.getString("createdDate"));
            emailRowModel.setLastmodifiedDate(rs.getString("lastmodifiedDate"));
            emailRowModel.setTimeDelivered(rs.getString("timeDelivered"));
            emailRowModel.setTimeQueued(rs.getString("timeQueued"));
            emailRowModel.setEmailTo(rs.getString("emailTo"));
            emailRowModel.setEmailToOriginal(rs.getString("emailToOriginal"));
            emailRowModel.setEmailFrom(rs.getString("emailFrom"));
            emailRowModel.setSubject(rs.getString("subject"));
            emailRowModel.setTimeBounced(rs.getString("timeBounced"));
            emailRowModel.setDsnAction(rs.getString("dsnAction"));
            emailRowModel.setDsnStatus(rs.getString("dsnStatus"));
            emailRowModel.setDsnRemoteMta(rs.getString("dsnRemoteMta"));
            emailRowModel.setDsnDiagnostics(rs.getString("dsnDiagnostics"));
            emailRowModel.setStatus(rs.getString("status"));

            String typeId1 = rs.getString("type_id") == null ? "0" : rs.getString("type_id");

            if(!rowMap.containsKey(emailRowModel.getTransactionID())) {
                rowMap.put(emailRowModel.getTransactionID(),emailRowModel);
                clickCount = 0;
                openCount = 0;

                if (typeId1.equals("2")) {
                    clickCount++;
                    isClicked = true;
                } else if (typeId1.equals("1")) {
                    openCount++;
                    isOpened = true;
                }


            }else{
                if (typeId1 != null && !typeId1.isEmpty()) {
                    if (typeId1.equals("2")) {
                        isClicked = true;
                        clickCount++;
                    } else if (typeId1.equals("1")) {
                        isOpened = true;
                        openCount++;
                    }
                }
            }
            rowMap.get(emailRowModel.getTransactionID()).setClicked(isClicked);
            rowMap.get(emailRowModel.getTransactionID()).setClickCount(clickCount);
            rowMap.get(emailRowModel.getTransactionID()).setOpened(isOpened);
            rowMap.get(emailRowModel.getTransactionID()).setOpenCount(openCount);

        }


        for (Map.Entry<String, EmailRowModel> entry : rowMap.entrySet()) {
            JsonObject obj = new JsonObject();
            //Front tarafında obje ismi değişikliği olmaması için her veri için ayrı obje oluşturuldu.
            EmailRowModel value = entry.getValue();
            obj.put("account_id", value.getAccountId());
            obj.put("reportType", value.getReportType());
            obj.put("custId", value.getCustomerId());
            obj.put("transactionID", value.getTransactionID());
            obj.put("createdDate", value.getCreatedDate());
            obj.put("lastmodifiedDate", value.getLastmodifiedDate());
            obj.put("timeDelivered", value.getTimeDelivered());
            obj.put("timeQueued", value.getTimeQueued());
            obj.put("emailTo", value.getEmailTo());
            obj.put("emailToOriginal", value.getEmailToOriginal());
            obj.put("emailFrom", value.getEmailFrom());
            obj.put("subject", value.getSubject());
            obj.put("timeBounced", value.getTimeBounced());
            obj.put("dsnAction", value.getDsnAction());
            obj.put("dsnStatus", value.getDsnStatus());
            obj.put("dsnRemoteMta", value.getDsnRemoteMta());
            obj.put("dsnDiagnostics", value.getDsnDiagnostics());
            obj.put("status", value.getStatus());
            obj.put("isClicked", value.isClicked());
            obj.put("isOpened", value.isOpened());
            obj.put("clickCount", value.getClickCount());
            obj.put("openCount", value.getOpenCount());
            arr.put(obj);
        }
        out.println(arr.toString());
    }catch (Exception e){
        logger.error("Error in smtp_data.jsp",e);
        out.println("Error : "+e);
    }finally {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (connection != null) {
                connection.close();
            }
        } catch (Exception ex) {
            logger.error("Error closing resources in smtp_data.jsp",ex);
        }
    }

%>

<%!
    public class EmailRowModel implements Serializable{
        public String accountId;
        public String reportType;
        public String customerId;
        public String transactionID;
        public String createdDate;
        public String lastmodifiedDate;
        public String timeDelivered;
        public String timeQueued;
        public String emailTo;
        public String emailToOriginal;
        public String emailFrom;
        public String subject;
        public String timeBounced;
        public String dsnAction;
        public String dsnStatus;
        public String dsnRemoteMta;
        public String dsnDiagnostics;
        public String status;
        public boolean isClicked;
        public boolean isOpened;
        public int clickCount;

        public int getClickCount() {
            return clickCount;
        }

        public void setClickCount(int clickCount) {
            this.clickCount = clickCount;
        }

        public int getOpenCount() {
            return openCount;
        }

        public void setOpenCount(int openCount) {
            this.openCount = openCount;
        }

        public int openCount;

        public String getAccountId() {
            return accountId;
        }

        public void setAccountId(String accountId) {
            this.accountId = accountId;
        }

        public String getReportType() {
            return reportType;
        }

        public void setReportType(String reportType) {
            this.reportType = reportType;
        }

        public String getCustomerId() {
            return customerId;
        }

        public void setCustomerId(String customerId) {
            this.customerId = customerId;
        }

        public String getTransactionID() {
            return transactionID;
        }

        public void setTransactionID(String transactionID) {
            this.transactionID = transactionID;
        }

        public String getCreatedDate() {
            return createdDate;
        }

        public void setCreatedDate(String createdDate) {
            this.createdDate = createdDate;
        }

        public String getLastmodifiedDate() {
            return lastmodifiedDate;
        }

        public void setLastmodifiedDate(String lastmodifiedDate) {
            this.lastmodifiedDate = lastmodifiedDate;
        }

        public String getTimeDelivered() {
            return timeDelivered;
        }

        public void setTimeDelivered(String timeDelivered) {
            this.timeDelivered = timeDelivered;
        }

        public String getTimeQueued() {
            return timeQueued;
        }

        public void setTimeQueued(String timeQueued) {
            this.timeQueued = timeQueued;
        }

        public String getEmailTo() {
            return emailTo;
        }

        public void setEmailTo(String emailTo) {
            this.emailTo = emailTo;
        }

        public String getEmailToOriginal() {
            return emailToOriginal;
        }

        public void setEmailToOriginal(String emailToOriginal) {
            this.emailToOriginal = emailToOriginal;
        }

        public String getEmailFrom() {
            return emailFrom;
        }

        public void setEmailFrom(String emailFrom) {
            this.emailFrom = emailFrom;
        }

        public String getSubject() {
            return subject;
        }

        public void setSubject(String subject) {
            this.subject = subject;
        }

        public String getTimeBounced() {
            return timeBounced;
        }

        public void setTimeBounced(String timeBounced) {
            this.timeBounced = timeBounced;
        }

        public String getDsnAction() {
            return dsnAction;
        }

        public void setDsnAction(String dsnAction) {
            this.dsnAction = dsnAction;
        }

        public String getDsnStatus() {
            return dsnStatus;
        }

        public void setDsnStatus(String dsnStatus) {
            this.dsnStatus = dsnStatus;
        }

        public String getDsnRemoteMta() {
            return dsnRemoteMta;
        }

        public void setDsnRemoteMta(String dsnRemoteMta) {
            this.dsnRemoteMta = dsnRemoteMta;
        }

        public String getDsnDiagnostics() {
            return dsnDiagnostics;
        }

        public void setDsnDiagnostics(String dsnDiagnostics) {
            this.dsnDiagnostics = dsnDiagnostics;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public boolean isClicked() {
            return isClicked;
        }

        public void setClicked(boolean clicked) {
            isClicked = clicked;
        }

        public boolean isOpened() {
            return isOpened;
        }

        public void setOpened(boolean opened) {
            isOpened = opened;
        }
    }

%>
