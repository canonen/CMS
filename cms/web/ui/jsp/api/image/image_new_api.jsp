<%@ page
		language="java"
		import="com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
		errorPage="../error_page.jsp"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>

<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<% response.setContentType("application/json;charset=UTF-8"); %>

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

	String sFolderId = BriteRequest.getParameter(request,"folder_id");
	String sImageId = BriteRequest.getParameter(request,"image_id");
	String sErrors = BriteRequest.getParameter(request,"errors");

	boolean bCanExecute = can.bExecute;
	boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
	boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

// Connection
	Image image = null;
	ImgFolder folder = null;

	try	{

		if (sImageId != null && sImageId.length() != 0)
		{
			//Load image info
			image = new Image(sImageId);
			if (sFolderId == null)
				sFolderId = image.s_folder_id;

			folder = new ImgFolder(sFolderId);
		}
	// Connection
	Statement			stmt			= null;
	Statement			stmt2			= null;
	Statement			stmt3			= null;
	ResultSet			rs				= null;
	ResultSet			rs2				= null;
	ResultSet			rs3				= null;
	ConnectionPool		cp			    = null;
	Connection			conn 			= null;
	Connection			conn2 			= null;
	/* *** */

	int nChildCount = -1;
	try	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("image_new_api.jsp");
		conn2 = cp.getConnection("image_new_api.jsp");
		stmt = conn.createStatement();
		stmt2 = conn2.createStatement();
		stmt3 = conn.createStatement();

		String sCustId ;
		String sParentCustId ;
		String sLevelId ;
		JsonObject custInfo = new JsonObject();
		JsonArray custArr = new JsonArray();
		JsonObject custObj = new JsonObject();

		rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
		while (rs.next()) {

			//only interested in last customer on chain
			int custId = rs.getInt("cust_id");
			int parentCustId = rs.getInt("parent_cust_id");
			int levelId = rs.getInt("level_id");

			sCustId = Integer.toString(custId);
			sParentCustId = Integer.toString(parentCustId);
			sLevelId = Integer.toString(levelId);

			custObj.put("sCustId", sCustId);
			custObj.put("sParentCustId", sParentCustId);
			custObj.put("sLevelId", sLevelId);

			System.out.println("sCustId" +sCustId);
			System.out.println("sParentCustId" +sParentCustId);
			System.out.println("sLevelId" +sLevelId);
			nChildCount++;
		}
		custArr.put(custObj);
		custInfo.put("custInfo", custArr);
		//out.println(custInfo);
		rs.close();


		/*String sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
		String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId,0,sFolderId,cust.s_cust_id);
		String sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
		sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId,0,sFolderId,cust.s_cust_id);
*/

		JsonArray folderArr = new JsonArray();
		JsonObject folderObj = new JsonObject();

		String sqlFolder = " SELECT" +
				" folder_name, " +
				" folder_id, " +
				" type_id" +
				" FROM ccnt_img_folder " +
				" WHERE" +
				"	cust_id= " + cust.s_cust_id +
				" ORDER BY folder_id";

		rs2= stmt2.executeQuery(sqlFolder);
		while(rs2.next()){
			 folderObj = new JsonObject();

			String s_FolderId = rs2.getString("folder_id");
			String s_FolderName = rs2.getString("folder_name");
			String s_TypeId = rs2.getString("type_id");

			folderObj.put("s_FolderId",s_FolderId);
			folderObj.put("s_FolderName",s_FolderName);
			folderObj.put("s_TypeId",s_TypeId);

			folderArr.put(folderObj);
		}

		rs2.close();
		
		String imageSql = "Select  image_id, folder_id, url_path, image_name from ccnt_image where cust_id = "
				+cust.s_cust_id + " and image_id= "+ sImageId + " ";

		JsonObject imageObj = new JsonObject();
		JsonArray imageArr = new JsonArray();

		rs3 = stmt3.executeQuery(imageSql);
		while (rs3.next()){
			String s_FolderId = rs3.getString("folder_id");
			String s_ImageId = rs3.getString("image_id");
			String s_UrlPath = rs3.getString("url_path");
			String s_ImageName = rs3.getString("image_name");

			imageObj.put("s_FolderId",s_FolderId);
			imageObj.put("s_ImageId",s_ImageId);
			imageObj.put("s_UrlPath",s_UrlPath);
			imageObj.put("s_ImageName",s_ImageName);
		}
		imageArr.put(imageObj);

		JsonArray totalData = new JsonArray();
		totalData.put(folderArr);
		totalData.put(imageArr);
		out.println(totalData);

		String sAccessHtml = "";
		if (sImageId!=null&&sImageId.length()!=0) {
		sAccessHtml = ImageHostUtil.getImageCustAccessHTML(cust.s_cust_id, sImageId);
		} else {
		sAccessHtml = ImageHostUtil.getFolderCustAccessHTML(cust.s_cust_id, sFolderId);
		}
			} catch(Exception ex) {

				throw ex;

			} finally {
				if ( stmt != null ) stmt.close();
				if ( stmt2 != null ) stmt2.close();
				if ( stmt3 != null ) stmt3.close();
				if ( conn  != null ) cp.free(conn);
			}
	} catch(Exception ex) {
			ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);
		}
%>
