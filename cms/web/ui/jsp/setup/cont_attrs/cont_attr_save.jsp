<%@ page
    language="java"
    import="com.britemoon.*,
    		com.britemoon.cps.*,
    		com.britemoon.cps.adm.*,
    		java.io.*,java.sql.*,
    		java.util.*,org.apache.log4j.*"
    errorPage="../../error_page.jsp"
    contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
if (!can.bWrite)
{
    response.sendRedirect("../../access_denied.jsp");
    return;
}
%>
<HTML>
<HEAD>
    <%@ include file="../../header.html" %>
    <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">   
</HEAD>
<BODY>
<%
String sAttrId = BriteRequest.getParameter(request,"attr_id");
String sAttrName = BriteRequest.getParameter(request,"attr_name");
String sAttrValue = BriteRequest.getParameter(request,"attr_value");
String sPropagateFlag = BriteRequest.getParameter(request,"propagate_flag");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sql = null;
boolean error = false;
String msg = null;
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);

	if (sAttrName != null)
	{

		// when insert/update, make sure this name is not used by other attr of this current customer
		sql =
			"SELECT attr_id FROM ccps_cont_attr " +
			" WHERE LOWER(attr_name) = LOWER('" + sAttrName + "') " +
			"   AND cust_id = " + cust.s_cust_id;
		if (sAttrId != null) {
			sql += " AND attr_id != " + sAttrId;
		}
		pstmt = conn.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if (rs.next()) {
			msg = "Content Field Name already exists, please choose a different one";
			error = true;
		}
		rs.close();

		// make sure this name is not used by parent customer
		if (!error && cust.s_parent_cust_id != null) {
			sql =
				"SELECT attr_id FROM ccps_cont_attr " +
				" WHERE LOWER(attr_name) = LOWER('" + sAttrName + "') " +
				"   AND cust_id = " + cust.s_parent_cust_id;
			if (sAttrId != null) {
				sql += " AND attr_id != " + sAttrId;
			}
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				msg = "Content Field Name already exists in parent, please choose a different one";
				error = true;
			}
			rs.close();
		}

		// make sure this name is not used by children
		if (!error && cust.m_Customers != null) {
			String children = null;
			Customers custs = cust.m_Customers;
			Enumeration e = custs.elements();
			while (e.hasMoreElements()) {
				if (children == null) {
					children = ((Customer) e.nextElement()).s_cust_id;
				}
				else {
					children += "," + ((Customer) e.nextElement()).s_cust_id;
				}
			}
			if (children != null && children.length() > 0) {
				sql =
					"SELECT attr_id FROM ccps_cont_attr " +
					" WHERE LOWER(attr_name) = LOWER('" + sAttrName + "') " +
					"   AND cust_id in (" + children + ")";
				pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				if (rs.next()) {
					msg = "Content Field Name already exists in child customer, please choose a different one";
					error = true;
				}
				rs.close();

				// if updating propagate_flag to 0, make sure no children is using it
				if (!error && sAttrId != null && sPropagateFlag != null && sPropagateFlag.equals("0")) {
					sql =
						"SELECT attr_id FROM ccps_cont_attr_value " +
						" WHERE attr_id = " + sAttrId +
						"   AND cust_id in (" + children + ")";
					pstmt = conn.prepareStatement(sql);
					rs = pstmt.executeQuery();
					if (rs.next()) {
						msg = "Content Field already used by child customers, can't change propagate to 'No'";
						error = true;
					}
					rs.close();
				}
				
			}
		}

		if (!error) {
			sql = "EXEC usp_ccps_cont_attr_save @cust_id=?,@attr_id=?,@attr_name=?,@attr_value=?,@propagate_flag=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, cust.s_cust_id);
			pstmt.setString(2, sAttrId);
			pstmt.setString(3, sAttrName);
			pstmt.setString(4, sAttrValue);
			//pstmt.setBytes(4, sAttrValue.getBytes("UTF-8"));
			pstmt.setString(5, sPropagateFlag);
			logger.info(sAttrId + "," + sAttrName + "," + sAttrValue + "," + sPropagateFlag);
			rs = pstmt.executeQuery();
			rs.next();
			sAttrId = rs.getString(1);
			rs.close();
			msg = "Content Field saved";
			logger.info("new => " + sAttrId);
		}
	}
	else {
		msg = "Content Field name is required";
	}
%>
    <!--- Step 1 Header----->
    <table width=650 class=listTable cellspacing=0 cellpadding=0>
        <tr>
		 <th class=sectionheader>&nbsp;<b class=sectionheader>Content Field Save</th>
        </tr>
        <tbody class=EditBlock id=block1_Step1>
            <tr>
                <td valign=top align=center width=650>
                    <table cellspacing=0 cellpadding=0 width="100%">
                        <tr>
                            <td align="center" valign="middle" style="padding:10px;">
								<b>&nbsp;<%=msg%></b><BR><BR>
                                <A href="cont_attr_list.jsp">Back to list</A>
                                <BR><BR>
<% if (sAttrId != null) { %>
                                <A href="cont_attr_edit.jsp?attr_id=<%=sAttrId%>">Back to edit</A>
<% } else { %>
                                <A href="cont_attr_new.jsp">Back to new</A>
<% } %>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </tbody>
    </table>
    <br><br>
<%
}
catch(Exception ex)
{
    throw ex;
}
finally
{
    if (pstmt != null) pstmt.close();
    if(conn != null) cp.free(conn);
}
%>
</BODY>
</HTML>
