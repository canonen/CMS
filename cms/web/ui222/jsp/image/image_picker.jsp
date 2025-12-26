<%@ page

	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
%>
<%!
    static Logger logger = null;
	private String createFolderHTML(String rootFolderID, String custID, String indent) throws Exception {

		String folderHTML = "";
		String folderID, folderName;

		Statement			stmt			= null;
		ResultSet			rs				= null; 
		ConnectionPool	connectionPool= null;
		Connection			conn = null;

		try	{
			connectionPool = ConnectionPool.getInstance();
			conn = connectionPool.getConnection("image_new.jsp "+rootFolderID);
			stmt = conn.createStatement();

			//Find all of the folders in this folder
		  	rs = stmt.executeQuery(	"SELECT image_id, display_name "
				+ " FROM ccnt_image"
				+ " WHERE type_id = 0 AND parent_id = "+rootFolderID+" AND cust_id = "+custID
				+ " ORDER BY display_name");
			while (rs.next()) {
				folderID = rs.getString(1);
				folderName = rs.getString(2);
				folderHTML += "<OPTION value="+folderID+">"+indent+folderName+"</OPTION>\n";
				folderHTML += createFolderHTML(folderID, custID, indent+"&nbsp;&nbsp;");
			}

			//Find all of the images in this folder
		  	rs = stmt.executeQuery(	"SELECT image_id, url_path, display_name "
				+ " FROM ccnt_image"
				+ " WHERE type_id = 1 AND parent_id = "+rootFolderID
				+ " ORDER BY display_name");
			while (rs.next()) {
				folderHTML += "<OPTION value="+rs.getString(1)+">"+indent+rs.getString(3)+"</OPTION>\n";
			}

		} catch(Exception ex) { 

			throw new Exception("Problem getting new image - createFolderHTML proc");

		} finally {
			if ( stmt != null ) stmt.close();
			if ( conn != null ) connectionPool.free(conn); 
		}

		return folderHTML;
	}
%>


<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;


try	{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("image_new.jsp");
	stmt = srvConnection.createStatement();

	String urlsjs = "";
	rs = stmt.executeQuery("SELECT image_id, url_path " +
		"FROM ccnt_image " +
		"WHERE type_id = 1 " +
		"AND cust_id = "+cust.s_cust_id+" "+
		"ORDER BY image_id");
	while (rs.next()) {
		urlsjs += "urls["+rs.getString(1)+"] = '"+rs.getString(2)+"';";
	}

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" TARGET="_self">


<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Images:</b> Find an Image URL</td>
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
					<td align="left" valign="middle" width="100">Choose Image: </td>
					<td align="left" valign="middle">
						<select NAME="id" SIZE="1" onchange="document.all.url.value=urls[this.value]">
							<%
							rs = stmt.executeQuery("SELECT image_id, display_name "
							+ " FROM ccnt_image"
							+ " WHERE type_id = 0 AND parent_id IS NULL AND cust_id = "+cust.s_cust_id
							+ " ORDER BY display_name");

							String folderHTML = "", folderName, folderID;
							while(rs.next())
							{
							folderID = rs.getString(1);
							folderName = rs.getString(2);

							folderHTML += "<option value="+folderID+">"+folderName+"</option>\n";
							folderHTML += createFolderHTML(folderID, cust.s_cust_id, "&nbsp;&nbsp;");
							}
							rs.close();
							%>
							<%= folderHTML %>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">URL: </td>
					<td align="left" valign="middle"><input type="text" size="100" disabled name=url maxlength="255" ></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<SCRIPT LANGUAGE="JavaScript">

var urls = new Array();
<%= urlsjs %>

</SCRIPT>

</BODY>
</HTML>
<%
} catch(Exception ex) { 

	ErrLog.put(this,ex, "Problem with Image Picker.",out,1);

} finally {
	if ( stmt != null ) stmt.close();
	if ( srvConnection  != null ) connectionPool.free(srvConnection); 
}
%>


























