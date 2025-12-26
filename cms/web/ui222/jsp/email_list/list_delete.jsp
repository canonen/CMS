<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String listID = request.getParameter("listID");
String typeID = request.getParameter("typeID");

if (typeID.equals("1"))
{
		out.println("<H3>Cannot delete a global exclusion list.</H3>");
		return;
}

ConnectionPool		cp		= null;
Connection			conn	= null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("list_delete.jsp");
        conn.setAutoCommit(false);
	Statement stmt = null;
	try
	{
		stmt = conn.createStatement();
		String sSql = null;

		//if((!"2".equals(typeID)) && (!"5".equals(typeID)) && (!"7".equals(typeID))) //Not a test list
		//{
		//	//See if this list is being used in a campaign
		//	sSql = 
		//		" SELECT TOP 1 camp_id FROM cque_camp_list" +
		//		" WHERE exclusion_list_id = " + listID +
		//		" OR auto_respond_list_id = "+listID +
		//		" OR test_list_id = " + listID;
		//
		//	ResultSet rs = stmt.executeQuery(sSql);
		//
		//	if (rs.next())
		//	{
		//		//Cannot delete it, it is being used
		//		rs.close();
		//		out.println("<H3>List is being used by a campaign.  Cannot delete it.</H3>");
		//		return;
		//	}
		//	rs.close();
		//}
		
		//delete it
		sSql = 

			" UPDATE cque_email_list SET status_id = " + EmailListStatus.DELETED + " WHERE list_id = " + listID;

		stmt.execute(sSql);
                stmt.close();
                conn.commit();
	}
	catch(Exception ex)
	{ 
	 	if (stmt != null) {
                    conn.rollback();
                    throw ex;
                }
	}
	finally { if (stmt != null) stmt.close(); }
}
catch(Exception ex) { throw ex; }
finally { if (conn != null ) {
            conn.setAutoCommit(true);
            cp.free(conn); 
            }
}
%>

<HTML>

<HEAD>
	<BASE target="_self">
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>List:</b> Deleted</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><b>The list was deleted.</b></p>
						<p align="center"><a href="list_list.jsp?typeID=<%=((!typeID.equals("5")&&!typeID.equals("7"))?typeID:"2")%>">Back to List</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
