<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.io.*,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.sun.org.apache.xpath.internal.operations.Bool" %>
<%@ page import="org.apache.commons.lang.ObjectUtils" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="jdk.nashorn.internal.objects.annotations.Getter" %>
<%@ page import="jdk.nashorn.internal.objects.annotations.Setter" %>
<%@ page import="java.util.*" %>
<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>

<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String batchId = request.getParameter("batch_id");

    Integer attrId = 0;
    String attrName = null;
    Boolean valueQty = null;
    String displayName = null;
    Integer displaySeq = 0;
    String fingerprintSeq = null;
    String newsletterFlag = null;
    String typeName = null;
    JsonArray mainArray = new JsonArray();
    JsonObject mainObject = new JsonObject();
    JsonArray array = new JsonArray();
    JsonObject registeredObject = new JsonObject();
    JsonObject notRegisteredObject = new JsonObject();

    List<ImportCustAttrModel> importCustAttrList = new ArrayList<ImportCustAttrModel>();
    List<ImportCustAttrModel> importCustAttrList2 = new ArrayList<ImportCustAttrModel>();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
        String sSql = "SELECT a.attr_id, a.attr_name, a.value_qty, " +
                "ca.display_name, ca.display_seq, ca.fingerprint_seq, ca.newsletter_flag," +
                " t.type_name " +
                "FROM ccps_cust_attr ca, ccps_attribute a, ccps_data_type t WHERE ca.cust_id=" + cust.s_cust_id + " AND ca.attr_id = a.attr_id AND a.type_id = t.type_id AND ISNULL(ca.display_seq, 0) > 0 AND ISNULL(a.internal_flag,0) <= 0 ORDER BY display_seq, display_name";

        rs = stmt.executeQuery(sSql);

        while (rs.next()) {
            attrId = rs.getInt(1);
            attrName = rs.getString(2);
            valueQty = rs.getInt(3) == 1 ? true : false;
            displayName = rs.getString(4);
            displaySeq = rs.getInt(5);
            fingerprintSeq = rs.getString(6) == null ? "NULL" : rs.getString(6);
            newsletterFlag = rs.getString(7) == null ? "NULL" : rs.getString(7);
            typeName = rs.getString(8);

            ImportCustAttrModel importCustAttrModel = new ImportCustAttrModel();
            importCustAttrModel.setAttrId(attrId);
            importCustAttrModel.setAttrName(attrName);
            importCustAttrModel.setValueQty(valueQty);
            importCustAttrModel.setDisplayName(displayName);
            importCustAttrModel.setDisplaySeq(displaySeq);
            importCustAttrModel.setFingerprintSeq(fingerprintSeq);
            importCustAttrModel.setNewsletterFlag(newsletterFlag);
            importCustAttrModel.setTypeName(typeName);
            importCustAttrList.add(importCustAttrModel);

        }
            rs.close();
        if(batchId != null) {
            String sSql2 = "SELECT " +
                    "a.attr_name as attr_name, a.attr_id as attr_id , a.value_qty as value_qty, " +
                    "ca.display_name as display_name, ca.display_seq as display_seq , ca.fingerprint_seq as fingerprint_seq, ca.newsletter_flag as newsletter_flag," +
                    "ISNULL(ca.fingerprint_seq, 0) AS fingerprint_seq, " +
                    "f.attr_id AS mapped_attr_id " +
                    " FROM ccps_cust_attr ca " +
                    " INNER JOIN ccps_attribute a ON a.attr_id = ca.attr_id" +
                    " LEFT OUTER JOIN cupd_fields_mapping f ON a.attr_id = f.attr_id " +
                    " INNER JOIN cupd_import ci ON ci.import_id = f.import_id " +
                    " WHERE ca.cust_id = " + cust.s_cust_id +
                    " AND ca.display_seq IS NOT NULL " +
                    " AND ci.batch_id = " + batchId +
                    " AND f.import_id = (select TOP 1 import_id from cupd_import where batch_id= '"+batchId+"' and status_id=50 order by import_date desc)"+
                    " ORDER BY f.seq, ca.display_seq";

            rs = stmt.executeQuery(sSql2);
            Vector<String> dupVector = new Vector<String>();
            while (rs.next()) {
                ImportCustAttrModel importCustAttrModel = new ImportCustAttrModel();

                if (!dupVector.contains(rs.getString("attr_id"))) {
                importCustAttrModel.setAttrName(rs.getString("attr_name"));
                importCustAttrModel.setAttrId(rs.getInt("attr_id"));
                importCustAttrModel.setValueQty(rs.getInt("value_qty") == 1 ? true : false);
                importCustAttrModel.setDisplayName(rs.getString("display_name"));
                importCustAttrModel.setDisplaySeq(rs.getInt("display_seq"));
                importCustAttrModel.setFingerprintSeq(rs.getString("fingerprint_seq") == null ? "NULL" : rs.getString("fingerprint_seq"));
                importCustAttrModel.setNewsletterFlag(rs.getString("newsletter_flag") == null ? "NULL" : rs.getString("newsletter_flag"));
                importCustAttrList2.add(importCustAttrModel);
                dupVector.add(rs.getString("attr_id"));
                }

            }
                for (ImportCustAttrModel importCustAttrModel : importCustAttrList2) {
                    JsonObject object = new JsonObject();
                    object.put("attrId", importCustAttrModel.getAttrId());
                    object.put("attrName", importCustAttrModel.getAttrName());
                    object.put("valueQty", importCustAttrModel.getValueQty());
                    object.put("displayName", importCustAttrModel.getDisplayName());
                    object.put("displaySeq", importCustAttrModel.getDisplaySeq());
                    object.put("fingerprintSeq", importCustAttrModel.getFingerprintSeq());
                    object.put("newsletterFlag", importCustAttrModel.getNewsletterFlag());
                    object.put("selectType", true);
                    array.put(object);
                }

                for (ImportCustAttrModel importCustAttrModel : importCustAttrList) {
                    if (dupVector.contains(String.valueOf(importCustAttrModel.getAttrId()))) {
                        continue;
                    }
                    JsonObject object = new JsonObject();
                    object.put("attrId", importCustAttrModel.getAttrId());
                    object.put("attrName", importCustAttrModel.getAttrName());
                    object.put("valueQty", importCustAttrModel.getValueQty());
                    object.put("displayName", importCustAttrModel.getDisplayName());
                    object.put("displaySeq", importCustAttrModel.getDisplaySeq());
                    object.put("fingerprintSeq", importCustAttrModel.getFingerprintSeq());
                    object.put("newsletterFlag", importCustAttrModel.getNewsletterFlag());
                    object.put("typeName", importCustAttrModel.getTypeName());
                    if(attrName.equals("email_821")) {
                        object.put("selectType", true);
                    }
                    else {
                        object.put("selectType", false);
                    }
                    array.put(object);
                }

        }else{
            for (ImportCustAttrModel importCustAttrModel : importCustAttrList) {
                JsonObject object = new JsonObject();
                object.put("attrId", importCustAttrModel.getAttrId());
                object.put("attrName", importCustAttrModel.getAttrName());
                object.put("valueQty", importCustAttrModel.getValueQty());
                object.put("displayName", importCustAttrModel.getDisplayName());
                object.put("displaySeq", importCustAttrModel.getDisplaySeq());
                object.put("fingerprintSeq", importCustAttrModel.getFingerprintSeq());
                object.put("newsletterFlag", importCustAttrModel.getNewsletterFlag());
                object.put("typeName", importCustAttrModel.getTypeName());
                array.put(object);
            }

        }
        mainObject.put("customFields", array);
        mainArray.put(mainObject);
        out.print(mainArray);


        rs.close();

    } catch (Exception exception) {
        exception.printStackTrace();
    } finally {
        out.flush();
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }

%>
<%!
    public class ImportCustAttrModel {
        private Integer attrId;
        private String attrName;
        private Boolean valueQty;
        private String displayName;
        private Integer displaySeq;
        private String fingerprintSeq;
        private String newsletterFlag;
        private String typeName;

         public String getFingerprintSeq() {
             return fingerprintSeq;
         }

         public void setFingerprintSeq(String fingerprintSeq) {
             this.fingerprintSeq = fingerprintSeq;
         }

         public Integer getAttrId() {
             return attrId;
         }

         public void setAttrId(Integer attrId) {
             this.attrId = attrId;
         }

         public String getAttrName() {
             return attrName;
         }

        public void setAttrName(String attrName) {
            this.attrName = attrName;
        }

        public Boolean getValueQty() {
            return valueQty;
        }

        public void setValueQty(Boolean valueQty) {
            this.valueQty = valueQty;
        }

        public String getDisplayName() {
            return displayName;
        }

        public void setDisplayName(String displayName) {
            this.displayName = displayName;
        }

        public Integer getDisplaySeq() {
            return displaySeq;
        }

        public void setDisplaySeq(Integer displaySeq) {
            this.displaySeq = displaySeq;
        }

        public String getNewsletterFlag() {
            return newsletterFlag;
        }

        public void setNewsletterFlag(String newsletterFlag) {
            this.newsletterFlag = newsletterFlag;
        }

        public String getTypeName() {
            return typeName;
        }

        public void setTypeName(String typeName) {
            this.typeName = typeName;
        }
    }

%>
