<%@ page
    language="java"
    import="com.britemoon.*,
    		com.britemoon.cps.*,
    		com.britemoon.cps.adm.*,
    		com.britemoon.cps.tgt.*,
    		java.io.*,java.sql.*,
    		java.util.*,java.util.*,
    		java.sql.*,org.apache.log4j.*"
    errorPage="../../error_page.jsp"
    contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp" %>
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
<HTML>
<HEAD>
    <TITLE></TITLE>
    <%@ include file="../../header.html" %>
    <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">   
    <SCRIPT src="../../../js/disable_forms.js"></SCRIPT>
</HEAD>
<BODY <%=(!can.bWrite)?"onload='disable_forms();'":""%>>
<%
if (can.bWrite) {
%>
    <table cellspacing="0" cellpadding="4" border="0">
        <tr>
            <td align="left" valign="middle">
                <a class="savebutton" href="#" onClick="contattr.action='cont_attr_save.jsp'; contattr.submit();;">Save</a>
                <a class="savebutton" href="#" onClick="contattr.action='cont_attr_delete.jsp'; contattr.submit();;">Delete</a>
            </td>
        </tr>
    </table>
    <br>
<%
}
String sAttrId = request.getParameter("attr_id");
String sAttrName = null;
String sAttrValue = null;   
String sPropagateFlag = "0";
String sAttrCustId = null;

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sql = null;
try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);  
	sql  =
		" SELECT a.attr_name, ISNULL(v.attr_value,''), ISNULL(a.propagate_flag, '0'), a.cust_id" +
        "   FROM ccps_cont_attr a" +
        "   LEFT JOIN ccps_cont_attr_value v ON v.attr_id = a.attr_id AND v.cust_id = ?" +
		"  WHERE a.attr_id = ?";    
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, cust.s_cust_id);
	pstmt.setString(2, sAttrId);
	rs = pstmt.executeQuery();
	if (rs.next()) {
		sAttrName = rs.getString(1);
		sAttrValue = new String(rs.getBytes(2), "UTF-8");
		sPropagateFlag = rs.getString(3);
		sAttrCustId = rs.getString(4);
	}
	if (sPropagateFlag == null) {
		sPropagateFlag = "0";
	}
	if (sAttrCustId == null || !sAttrCustId.equals(cust.s_cust_id)) {
		sPropagateFlag = "0";
	}
%>
    <FORM method="POST" action="" target="_self" name="contattr">
        <INPUT type="hidden" name="attr_id" value="<%=sAttrId%>">
        <!--- Step 1 Header----->
        <table width="650" class="main" cellspacing="0" cellpadding="0">
            <tr>
                <td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Name your content field</td>
            </tr>
        </table>
        <br>
        <!---- Step 1 Info----->
        <table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
            <tr>
                <td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
            </tr>
            <tr>
                <td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
            </tr>
            <tbody class="EditBlock" id="block1_Step1">
            <tr>
                <td class="fillTab" valign="top" align="center" width="650">
                    <table class="main" cellspacing="1" cellpadding="2" width="100%">
                        <tr>
                            <td align="left" valign="middle" width="100">Name</td>
                            <td align="left" valign="middle">
<% 	if (sAttrCustId == null || !sAttrCustId.equals(cust.s_cust_id)) { %>
                                <input type="hidden" name="attr_name" value="<%=(sAttrName==null)?"":sAttrName%>"><%=(sAttrName==null)?"":sAttrName%>
<% } else { %>
                                <INPUT type="text" name="attr_name" size="60" value="<%=(sAttrName==null)?"":sAttrName%>">
<% } %>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            </tbody>
        </table>
        <br><br>
        <!--- Step 2 Header----->
        <table width="650" class="main" cellspacing="0" cellpadding="0">
            <tr>
                <td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Value for your content field</td>
            </tr>
        </table>
        <br>
        <!---- Step 2 Info----->
        <table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
            <tr>
                <td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
            </tr>
            <tr>
                <td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
            </tr>
            <tbody class="EditBlock" id="block2_Step1">
                <tr>
                    <td class="fillTab" valign="top" align="center" width="650">
                        <table class="main" cellspacing="1" cellpadding="2" width="100%">
                            <tr>
                                <td align="left" valign="middle" width="100">Value</td>
                                <td align="left" valign="middle"><INPUT type="text" name="attr_value" size="80" value="<%=(sAttrValue==null)?"":sAttrValue%>"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
        <br><br>
        <!--- Step 3 Header----->
        <table width="650" class="main" cellspacing="0" cellpadding="0">
            <tr>
                <td class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Propagation to child customers</td>
            </tr>
        </table>
        <br><HTML>

        <!---- Step 3 Info----->
        <table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
            <tr>
                <td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
            </tr>
            <tr>
                <td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
            </tr>
            <tbody class="EditBlock" id="block2_Step1">
                <tr>
                    <td class="fillTab" valign="top" align="center" width="650">
                        <table class="main" cellspacing="1" cellpadding="2" width="100%">
                            <tr>
                                <td align="left" valign="middle" width="100">Propagate?</td>
								<td align="left" valign="middle">
<% if (cust.m_Customers == null) { %>
                                    <input type="hidden" name="propagate_flag" value="0">No
<% } else { %>
                                    <select name="propagate_flag" size=1><option value=0 <%=(sPropagateFlag.equals("0")?"selected":"")%>>No<option value=1 <%=(sPropagateFlag.equals("1")?"selected":"")%>>Yes</select>
<% } %>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
        <br><br>
    </FORM>
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
</HTML>
