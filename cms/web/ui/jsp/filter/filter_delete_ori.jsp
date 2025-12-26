<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
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
%>


<%
String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String sFilterId = request.getParameter("filter_id");
String sUsageTypeId = request.getParameter("usage_type_id");
String sSql = null;
String sFilterName = null;
int iRows = 0;

//KU: Added for content logic ui
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

%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<%@ include file="../header.html" %>
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Target Group:</b> Deleted</th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td  valign=top align=center width=650>
			<table  cellspacing=0 cellpadding=20 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b>The <%= sTargetGroupDisplay %><br>
					<%
					if (sFilterName != null)
					{
						%>
						'<%=HtmlUtil.escape(sFilterName)%>'
						<br>
						<%
					}
					%>
						has been deleted.</b>
						<br>
						<% if (bIsTargetGroup) { %>
						<a href="filter_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to list</a>
						<% } else { %>
						<a href="../cont/filter_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to list</a>
						<% } %>
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
<%

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
