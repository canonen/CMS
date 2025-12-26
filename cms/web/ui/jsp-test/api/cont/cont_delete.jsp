<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.xcs.cti.ContentClient,
			java.util.*,java.sql.*,java.net.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sSelectedCategoryId = request.getParameter("category_id");
String contID = request.getParameter("cont_id");
String sContName = null;
String sSql = null;
int iRows = 0;

Content cont = new Content();
cont.s_cont_id = contID;
if(cont.retrieve() < 1) throw new Exception("Cont ID = " + contID + " does not exist");

// Connection
Statement			stmt	= null;
ResultSet			rs		= null; 
ConnectionPool		cp 		= null;
Connection			conn 	= null;

JsonObject data = new JsonObject();
JsonArray array = new JsonArray();

try	{
	if (cont.s_type_id.equals(String.valueOf(ContType.PRINT))) {

		ContentClient cc = new ContentClient();
		cc.deleteContentDocument(cont.s_cont_id, cust.s_cust_id, user.s_user_id);

	} else {

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("cont_delete.jsp");

	     // set AutoCommit to false so we can rollback the update if necessary
	     conn.setAutoCommit(false);
		stmt = conn.createStatement();
		
		if (contID != null) {
			//Make sure this customer owns this content block
	          sSql = "SELECT ISNULL(cont_name,'') as cont_name " +
	                    " FROM ccnt_content " +
					" WHERE cust_id = "+ cust.s_cust_id +
	                    " AND cont_id = "+contID;
			rs = stmt.executeQuery(sSql);
	                                     
			if (rs.next()) {
	               sContName =  rs.getString("cont_name");
				   data.put("contName",sContName);
				try {

	                    sSql = "UPDATE ccnt_content " +
	                              " SET status_id = " + String.valueOf(ContStatus.DELETED) +
	                              " WHERE cont_id = " + contID;
	                              
	                    iRows = stmt.executeUpdate(sSql);
	                    if (iRows != 1) {  // trying to delete just 1 content record, if fewer or more records were updated something's wrong
	                         conn.rollback();
	                         String sErrorMsg = "Error attempting to change content status to deleted. " +
	                                                       "Incorrect number of rows effected (should be 1): " + 
	                                                       String.valueOf(iRows) + ".\\n" +
	                                                       "(content ID:" + contID + ")";
	                         throw new Exception(sErrorMsg);
	                    } else {
	                         conn.commit();
	                    }

				} catch (SQLException SQLe) {
	                    conn.rollback();
	                    throw SQLe;
				}
	          }
		}
	}
					if (sContName != null)
					{
						HtmlUtil.escape(sContName);

					}

} catch(Exception ex) {
	throw ex;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) {
          conn.setAutoCommit(true); 
          cp.free(conn);
     }
}


%>
