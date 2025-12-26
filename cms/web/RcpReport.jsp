<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>

<%@ page import="java.util.Date" %>
<%@ page import="net.sourceforge.jtds.jdbc.DateTime" %>

<%! static Logger logger = null;%>
<%@ include file="header.jsp" %>
<%!
    class RcpReportClass {

        private Element m_RcpReport = null;
        public String cust_id;
        public String total;
        public String active;
        public String bback;
        public String unsub;
        public String exclude_;
        public String update_date;

        public RcpReportClass(Element eRcpReportClass) {


            m_RcpReport = eRcpReportClass;
            cust_id = XmlUtil.getChildCDataValue(m_RcpReport, "cust_id");
            total = XmlUtil.getChildCDataValue(m_RcpReport, "total");
            active = XmlUtil.getChildCDataValue(m_RcpReport, "active");
            bback = XmlUtil.getChildCDataValue(m_RcpReport, "bback");
            unsub = XmlUtil.getChildCDataValue(m_RcpReport, "unsub");
            exclude_ = XmlUtil.getChildCDataValue(m_RcpReport, "exclude_");
            update_date = XmlUtil.getChildCDataValue(m_RcpReport, "update_date");


        }

        public void save() throws Exception {

            ConnectionPool cp = null;
            Connection conn = null;
            PreparedStatement pstmt = null;

            try {
                cp = ConnectionPool.getInstance();
                conn = cp.getConnection(this);

                String  sSql = " IF EXISTS( SELECT cust_id FROM crpt_cust_email_summary where cust_id = " + cust_id + ") "
                        + " BEGIN " +
                        " UPDATE crpt_cust_email_summary SET cust_id = " + cust_id + "," +
                        " total =" + total + "," +
                        " active =" + active + "," +
                        " bback =" + bback + "," +
                        " unsub =" + unsub + "," +
                        " exclude_ =" + exclude_ + "," +
                        " update_date=" +"'"+ new Timestamp(System.currentTimeMillis()) +"'"+
                        " where cust_id = " + cust_id + " END  ELSE  BEGIN" +
                        " INSERT INTO  crpt_cust_email_summary  (cust_id,total,active,bback,unsub,exclude_,update_date)values(?,?,?,?,?,?,?) END ";

             //   String sSql = "INSERT INTO crpt_cust_email_summary (cust_id,total,active,bback,unsub,exclude_,update_date) values(?,?,?,?,?,?,?)";

               int x =1;
                 pstmt = conn.prepareStatement(sSql);
                 pstmt.setInt(x++,Integer.parseInt(cust_id));
                 pstmt.setInt(x++,Integer.parseInt(total));
                 pstmt.setInt(x++,Integer.parseInt(active));
                 pstmt.setInt(x++,Integer.parseInt(bback));
                 pstmt.setInt(x++,Integer.parseInt(unsub));
                 pstmt.setInt(x++,Integer.parseInt(exclude_));
                 pstmt.setTimestamp(x++, new Timestamp(System.currentTimeMillis()));

                 pstmt.executeUpdate();
                pstmt.close();
               // System.out.println(pstmt.executeUpdate());




            } catch (Exception ex) {
                throw ex;
            } finally {
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    cp.free(conn);
                }
            }
        }
    }

%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    String sCampID = null;
    try
    {
        Element e = XmlUtil.getRootElement(request);
        if(e == null) throw new Exception(" Rcp Report xml.");

        RcpReportClass rcpReportClass = new RcpReportClass(e);
        rcpReportClass.save();
    }
    catch (Exception ex)
    {

        logger.error("Rcp Report Update Error!\r\n", ex);
    }

%>


