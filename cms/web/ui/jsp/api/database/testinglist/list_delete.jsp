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
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

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
	conn = cp.getConnection(this);
        conn.setAutoCommit(false);
	Statement stmt = null;
	try
	{
		stmt = conn.createStatement();
		String sSql = null;

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
