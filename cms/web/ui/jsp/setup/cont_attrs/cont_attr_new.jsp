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
            </td>
        </tr>
    </table>
    <br>
<%
}
%>
    <FORM method="POST" action="" target="_self" name="contattr">
        <!--- Step 1 Header----->
        <table width="650" class="listTable" cellspacing="0" cellpadding="0">
            <tr>
                <th class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Name your content field</th>
            </tr>
            <tbody class="EditBlock" id="block1_Step1">
            <tr>
                <td class="" valign="top" align="center" width="650">
                    <table class="" cellspacing="1" cellpadding="2" width="100%">
                        <tr>
                            <td align="left" valign="middle" width="100">Name</td>
                            <td align="left" valign="middle"><INPUT type="text" name="attr_name" size="60" value=""></td>
                        </tr>
                    </table>
                </td>
            </tr>
            </tbody>
        </table>
        <br>
        <!--- Step 2 Header----->
        <table width="650" class="listTable" cellspacing="0" cellpadding="0">
            <tr>
                <th class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Value for your content field</th>
            </tr>
            <tbody class="EditBlock" id="block2_Step1">
                <tr>
                    <td class="" valign="top" align="center" width="650">
                        <table class="" cellspacing="1" cellpadding="2" width="100%">
                            <tr>
                                <td align="left" valign="middle" width="100">Value</td>
                                <td align="left" valign="middle"><INPUT type="text" name="attr_value" size="80" value=""></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
        <br>
        <!--- Step 3 Header----->
        <table width="650" class="listTable" cellspacing="0" cellpadding="0">
            <tr>
                <th class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Propagation to child customers</th>
            </tr>
            <tbody class="EditBlock" id="block2_Step1">
                <tr>
                    <td class="" valign="top" align="center" width="650">
                        <table class="" cellspacing="1" cellpadding="2" width="100%">
                            <tr>
                                <td align="left" valign="middle" width="100">Propagate?</td>
								<td align="left" valign="middle">
                                    <select name="propagate_flag" size=1><option value=0>No<option value=1>Yes</select>
                                </td> 
                            </tr>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
        <br><br>
    </FORM>
</BODY>
</HTML>
