<%@ page
    language="java"
    import="com.britemoon.*,
    		com.britemoon.cps.*,
    		com.britemoon.cps.imc.*,
    		java.io.*,java.sql.*,
    		java.util.*,java.util.*,
    		java.sql.*,org.w3c.dom.*,
    		org.apache.log4j.*"
    errorPage="../../error_page.jsp"
    contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
if (!can.bRead) {
    response.sendRedirect("../../access_denied.jsp");
    return;
}
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">

<HEAD>
    <TITLE></TITLE>
    <%@ include file="../../header.html" %>
    <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
    <SCRIPT src="../../../js/disable_forms.js"></SCRIPT>
</HEAD>
<BODY>
<div class="page_header"><fmt:message key="header_content_settings"/></div>
<div class="page_desc"><fmt:message key="header_content_settings_desc"/></div>

<%
if (can.bWrite) {
%>
    <table cellspacing="0" cellpadding="3" border="0" width="650">
        <tr>
            <td align="left" valign="middle">
                <a class="newbutton" href="cont_attr_new.jsp"><fmt:message key="button_content_settings"/></a>&nbsp;&nbsp;&nbsp;
            </td>
        </tr>
    </table>
    <br>
<%
}
%>
    <table cellspacing="0" cellpadding="0" width="650" border="0">
        <tr>
            <td class="listHeading" valign="center" nowrap align="left">Content Fields&nbsp;<br><br>
                <table class="listTable" width="100%" cellpadding="2" cellspacing="0">
                    <tr>
                        <th><fmt:message key="content_settings_column_name"/></th>
                        <th><fmt:message key="content_settings_column_value"/></th>
                        <th><fmt:message key="content_settings_column_origin"/></th>
                        <th>Propagate?</th>
                    </tr>
<%
ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sql = null;
String sContAttrId = null;
String sContAttrName = null;
String sContAttrValue = null;   
String sContAttrOrigin = null;   
String sContAttrPropagate = null;   
String sClassAppend = "";
try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);  
    sql =
        " SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'self', 'yes' " +    // self defined attr
        "   FROM ccps_cont_attr a" +
        "   LEFT JOIN ccps_cont_attr_value v ON v.attr_id = a.attr_id AND v.cust_id = a.cust_id" +
        "  WHERE a.cust_id = ?" +
        "    AND a.propagate_flag = 1" +
        " UNION" +    
        " SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'self', 'no'" +      // self defined attr no propagation
        "   FROM ccps_cont_attr a" +
        "   LEFT JOIN ccps_cont_attr_value v ON v.attr_id = a.attr_id AND v.cust_id = a.cust_id" +
        "  WHERE a.cust_id = ?" +
        "    AND a.propagate_flag != 1" +
        " UNION" +    
        " SELECT a.attr_id, a.attr_name, ISNULL(v.attr_value,'--'), 'parent', '--'" +   // inherited from parent
        "   FROM ccps_customer c" +
        "   LEFT JOIN ccps_cont_attr a ON c.parent_cust_id = a.cust_id AND a.propagate_flag = 1" + 
        "   LEFT OUTER JOIN ccps_cont_attr_value v ON c.cust_id = v.cust_id AND a.attr_id = v.attr_id" +
        "  WHERE c.cust_id = ?" +
        "  ORDER BY 2";    
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, cust.s_cust_id);
    pstmt.setString(2, cust.s_cust_id);
    pstmt.setString(3, cust.s_cust_id);
    rs = pstmt.executeQuery();  
    int i = 0;  
    while (rs.next()) {
        if (i % 2 != 0) {
            sClassAppend = "_Alt";
        }
        else {
            sClassAppend = "";
        }
        i++;        
        sContAttrId = rs.getString(1);
        if (sContAttrId == null) continue;
        sContAttrName = rs.getString(2);
        sContAttrValue = new String(rs.getBytes(3), "UTF-8");
        sContAttrOrigin = rs.getString(4);
        sContAttrPropagate = rs.getString(5);
%>
                    <tr>
                        <td class="listItem_Title<%= sClassAppend %>">
                            <a href="cont_attr_edit.jsp?attr_id=<%=sContAttrId%>" target="_self"><%=sContAttrName%></a>
                        </td>
                        <td class="listItem_Title<%= sClassAppend %>">
                            <%=sContAttrValue%>
                        </td>
                        <td class="listItem_Title<%= sClassAppend %>">
                            <%=sContAttrOrigin%>
                        </td>
                        <td class="listItem_Title<%= sClassAppend %>">
                            <%=sContAttrPropagate%>
                        </td>
                    </tr>
<%
    }
    rs.close();                     
    if (i == 0) {
%>
                    <tr>
                        <td class="listItem_Title" colspan="3">There are currently no Content Fields</td>
                    </tr>
<%
    }
%>
                </table>
            </td>
        </tr>
    </table>
    <br>
<%
}
catch(Exception ex) {
    throw ex;
}
finally {
    if (pstmt != null) pstmt.close();
    if(conn != null) cp.free(conn);
}
%>
</BODY>
</fmt:bundle>
</HTML>