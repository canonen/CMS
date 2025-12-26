<%@ page
	language="java"
	import="javax.servlet.http.*,
			javax.servlet.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.cnt.*,
 			com.britemoon.cps.ctm.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%@ page import="org.jcp.xml.dsig.internal.dom.DOMSubTreeData" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%! static Logger logger = null;%>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>

<%


    AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


    if(!can.bRead)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

    boolean bCanExecute = can.bExecute;
    boolean bCanWrite = can.bExecute;


    String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    String sErrors = BriteRequest.getParameter(request,"errors");
try	{

    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();
     // get the ID for the Root Folder.  If this customer has no root folder, create it.
     String sRootFolderId = null;
     sRootFolderId = ImageHostUtil.getRoot(user.s_cust_id);
     if ((sRootFolderId == null) ) {
          sRootFolderId = ImageHostUtil.createRoot(user.s_cust_id, user.s_cust_id);
     }
        data.put("RootFolderId",sRootFolderId);
     String sGlobalFolderId = null;
     sGlobalFolderId = ImageHostUtil.getGlobalRoot(user.s_cust_id);
     if (sGlobalFolderId == null) {
          sGlobalFolderId = ImageHostUtil.createGlobalRoot(user.s_cust_id, user.s_cust_id);
     }
    data.put("GlobalFolderId",sGlobalFolderId);

     arrayData.put(data);
     out.print(arrayData.toString());




} catch(Exception ex) { 

//	logger.error("Problem producing Image list",ex);
    System.out.println("Problem producing Image list");
    throw ex;
}
%>
