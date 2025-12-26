<%@ page

	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
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

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String sErrors = BriteRequest.getParameter(request,"errors");
String sFolderId = BriteRequest.getParameter(request,"folder_id");

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

// Connection
Image image = null;

JsonObject data= new JsonObject();
JsonArray array= new JsonArray();


String sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
//String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId,0,sFolderId,cust.s_cust_id)
String sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
//sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId,0,sFolderId,cust.s_cust_id);

Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool		cp = null;
Connection			conn = null;

int nChildCount = -1;   
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("image_new.jsp");
	stmt = conn.createStatement();

	rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
	while (rs.next()) {
		//only interested in last customer on chain
		data= new JsonObject();
		data.put("cust_id",rs.getString(1));
		data.put("parent_cust_id",rs.getString(2));
		data.put("cust_name",rs.getString(3));
		data.put("level_id",rs.getString(4));
		nChildCount++;
	}
	array.put(data);
	out.print(array);
	rs.close();

           // if (nChildCount > 0) {
            //        <%= ImageHostUtil.getFolderCustAccessHTML(cust.s_cust_id, sFolderId) %>
            //}
        } catch(Exception ex) { 

            throw ex;
            ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);


        } finally {
            if ( stmt != null ) stmt.close();
            if ( conn  != null ) cp.free(conn); 
        }


%>
