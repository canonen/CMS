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

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
 
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
 
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
/*
if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
*/
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

try	{
	 

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
	 
%>
<HTML>

<HEAD>
<title>Content: Delete</title>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Content:</b> Deleted</td>
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
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b>The content <br>
					<%
					if (sContName != null)
					{
						%>
						'<%=HtmlUtil.escape(sContName)%>'
						<br>
						<%
					}
					%>
						has been deleted.</b>
					<%--
					StringBuffer sbCampNames = null;
					
					sSql = "SELECT camp_name " +
							" FROM cque_campaign " +
							" WHERE cont_id = " + contID + 
							" AND status_id IN (" +
					
					String.valueOf(CampaignStatus.BEING_PROCESSED) + "," +
					String.valueOf(CampaignStatus.DRAFT) + "," +
					String.valueOf(CampaignStatus.READY_TO_SEND) + ")" ;
					
					rs = stmt.executeQuery(sSql);
					
					while (rs.next())
					{
						sbCampNames.append(rs.getString("camp_name") + "<br>");
					}
					
					if (sbCampNames != null)
					{
						%>
						<br>
						These Campaigns may have been effected by the Content deletion:
						<br>
						<%= HtmlUtil.escape(sbCampNames.toString()) %>
						<%
					}
					--%>
						<P align="center"><a href="cont_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a></P>
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
