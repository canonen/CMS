<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
ConnectionPool		cp 		= null;
Connection			conn 	= null;
JsonObject data = new JsonObject();
JsonArray array= new JsonArray();

try	{

	String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
	String imageId = request.getParameter("image_id");

	if (imageId == null)
           {
	      //throw new Exception("NO Image ID for Image Delete.");
	      data.put("Message:","NO Image ID for Image Delete.");
	   }		
	Image img = new Image(imageId);

	img.hide(cust.s_cust_id);
	img.deleteImage(conn);

        if(imageId != null)
	{
	    data.put("Message:","Image deleted succesfully");
	}
        array.put(data);

} catch(Exception ex) {
	ErrLog.put(this,ex,"image_delete.jsp",out,1);
	return;
} 
finally {
	if (conn != null) cp.free(conn);
	out.print(array);
}

%>
