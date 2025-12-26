<%@ page
	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
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
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String sFolderId = BriteRequest.getParameter(request,"folder_id");
	String sImageId = BriteRequest.getParameter(request,"image_id");
	String sErrors = BriteRequest.getParameter(request,"errors");

	boolean bCanExecute = can.bExecute;
	boolean bCanWrite = (can.bWrite || bCanExecute);

	boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

	Image image = null;
	ImgFolder folder = null;

	String tabWidth = "650";
	if (sImageId!=null&&sImageId.length()!=0) tabWidth = "100%";

try	{

	if (sImageId != null && sImageId.length() != 0)
	{
		//Load image info
		image = new Image(sImageId);
		if (sFolderId == null)
			sFolderId = image.s_folder_id;
		
		folder = new ImgFolder(sFolderId);
	}

	Statement			stmt			= null;
	ResultSet			rs				= null; 
	ConnectionPool		cp = null;
	Connection			conn = null;

	int nChildCount = -1;
	try	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("image_new.jsp");
		stmt = conn.createStatement();

		rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
		while (rs.next()) {
			//only interested in last customer on chain
			data = new JsonObject();
			nChildCount++;
			data.put("nChildCount",nChildCount);
		}
		rs.close();


		String sAccessHtml = "";
		if (sImageId!=null&&sImageId.length()!=0) { 
			sAccessHtml = ImageHostUtil.getImageCustAccessHTML(cust.s_cust_id, sImageId);
			data.put("sImageId",sAccessHtml);
		} else {
			sAccessHtml = ImageHostUtil.getFolderCustAccessHTML(cust.s_cust_id, sFolderId);
			data.put("sFolderId",sAccessHtml);
		}
		array.put(data);

	}
	} catch(Exception ex) { 
		throw ex;
	} finally {
		if ( stmt != null ) stmt.close();
		if ( conn  != null ) cp.free(conn);
		out.print(array); 
	}
	} catch(Exception ex) { 
		ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);
	}
%>