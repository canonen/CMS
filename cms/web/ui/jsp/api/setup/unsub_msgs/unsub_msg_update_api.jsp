<%@ page
        language="java"
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.adm.*"
        import="com.britemoon.cps.ctm.WebUtils"
        import="java.sql.*,java.io.*"
        import="javax.servlet.*"
        import="javax.servlet.http.*"
        import="org.xml.sax.*"
        import="javax.xml.transform.*"
        import="javax.xml.transform.stream.*"
        import="org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%!
    static Logger logger = null;
%>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%@ include file="../../fixTurkishCharacters.jsp"%>

<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    JsonObject unSubDataSaved = new JsonObject();

    String UnsubMsgID = request.getParameter("msg_id");
    String MessageName = request.getParameter("MessageName");
    String UnSubMessageText = request.getParameter("UnSubMessageText");
    String UnSubMessageHTML = request.getParameter("UnSubMessageHTML");
    if (UnsubMsgID == null){
        response.setStatus(400);
        out.print("msg_id is required");
        return;
    }else {
        try {
            UnsubMsg unSubObj = new UnsubMsg(UnsubMsgID);

            unSubObj.s_msg_name = MessageName;
            unSubObj.s_text_msg = UnSubMessageText;
            unSubObj.s_html_msg = UnSubMessageHTML;
            unSubObj.s_cust_id = user.s_cust_id;
            unSubObj.save();

            unSubDataSaved.put("msg_id", unSubObj.s_msg_id);
            unSubDataSaved.put("msg_name", fixTurkishCharacters(unSubObj.s_msg_name));
            unSubDataSaved.put("html_msg", unSubObj.s_html_msg);
            unSubDataSaved.put("text_msg", fixTurkishCharacters(unSubObj.s_text_msg));

            out.println(unSubDataSaved);

        } catch (Exception ex) {
            ErrLog.put(this, ex, "", out, 1);
            return;
        }
    }
%>


