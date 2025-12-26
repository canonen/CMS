<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();
String sSelectedCategoryId = request.getParameter("category_id");

if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String sFilterId = request.getParameter("filter_id");
String sUsageTypeId = request.getParameter("usage_type_id");

String referer = request.getParameter("referer");


String sSql = null;
String sFilterName = null;
int iRows = 0;
boolean bIsTargetGroup = true;
String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
	bIsTargetGroup = false;
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
	bIsTargetGroup = false;
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}

// Connection
Statement			stmt	= null;
ResultSet			rs		= null; 
ConnectionPool		cp 		= null;
Connection			conn 	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("filter_delete.jsp");

     // set AutoCommit to false so we can rollback the update if necessary
     conn.setAutoCommit(false);
	stmt = conn.createStatement();
	
	if (sFilterId != null) {
		//Make sure this customer owns this Filter
          sSql = "SELECT ISNULL(filter_name,'') as filter_name " +
                    " FROM ctgt_filter " +
				" WHERE cust_id = "+ cust.s_cust_id +
                    " AND filter_id = " + sFilterId;
		rs = stmt.executeQuery(sSql);
                                     
		if (rs.next()) {
               //get Filter name for displaying purposes
               sFilterName =  rs.getString("filter_name");
			try {

                    sSql = "UPDATE ctgt_filter " +
                              " SET status_id = " + String.valueOf(FilterStatus.DELETED) +
                              " WHERE filter_id = " + sFilterId;
                              
                    iRows = stmt.executeUpdate(sSql);
                    if (iRows != 1) {  // trying to delete just 1 content record, if fewer or more records were updated something's wrong
                         conn.rollback();
                         String sErrorMsg = "Error attempting to change Filter status to deleted. " +
                                                       "Incorrect number of rows effected (should be 1): " + 
                                                       String.valueOf(iRows) + ". " +
                                                       "(Filter ID:" + sFilterId + ")";
                         throw new Exception(sErrorMsg);
                    } else {
                         conn.commit();
                    }

			} catch (SQLException SQLe) {
                    conn.rollback();
                    throw SQLe;
			}
          } else {  // SQL query retrieving Filter name based on Cust ID and Filter ID returned no rows
               String sErrorMsg = "Error attempting to change Filter status to deleted. " +
                                             " SQL query retrieving Filter based on Customer ID and Filter ID returned no values. " +
                                             "(Customer ID:" + cust.s_cust_id + "; Filter ID:" + sFilterId + ")";
               throw new Exception(sErrorMsg);
          }
	} else {  // sFilterID is NULL
          String sErrorMsg = "Error attempting to change Filter status to deleted. " +
                                        " Filter ID is NULL (from edit page to delete page).";
          throw new Exception(sErrorMsg);
     } 
	if (sFilterName != null)
	{
	   jsonObject.put("filter_name", sFilterName);
	}
	if (bIsTargetGroup) {
			if(referer!=null) {
				jsonObject.put("category_id",(sSelectedCategoryId!=null)?sSelectedCategoryId:"");	
			}
			else {	
				Service service = null;
				Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
				service = (Service) services.get(0); 
                jsonObject.put("cust_id", cust.s_cust_id);				
			}
        } 
		else { 
			   jsonObject.put("category_id",(sSelectedCategoryId!=null)?sSelectedCategoryId:"");
             } 
			 jsonObject.put("message","The Target Group has been deleted.");
			 jsonArray.put(jsonObject);
             rs.close();
			 out.print(jsonArray);
}
catch(Exception ex) {
	throw ex;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) {
          conn.setAutoCommit(true); 
          cp.free(conn);
     }
}
%>
