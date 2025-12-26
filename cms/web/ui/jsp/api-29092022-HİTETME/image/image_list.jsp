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
<%@ page import="org.jcp.xml.dsig.internal.dom.DOMSubTreeData" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
    String sCustId = request.getParameter("custId");
    String sUserId = request.getParameter("userId");
try	{

    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();
     // get the ID for the Root Folder.  If this customer has no root folder, create it.
     String sRootFolderId = null;
     sRootFolderId = ImageHostUtil.getRoot(sCustId);
     if ((sRootFolderId == null) ) {
          sRootFolderId = ImageHostUtil.createRoot(sCustId, sUserId);
     }
        data.put("RootFolderId",sRootFolderId);
     String sGlobalFolderId = null;
     sGlobalFolderId = ImageHostUtil.getGlobalRoot(sCustId);
     if (sGlobalFolderId == null) {
          sGlobalFolderId = ImageHostUtil.createGlobalRoot(sCustId, sUserId);
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
