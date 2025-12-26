<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>


<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	JsonArray array= new JsonArray();


	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	String contID = request.getParameter("cont_id");
	String sNumLinks = request.getParameter("numLinks");
	int numLinks = Integer.parseInt(sNumLinks);

	// === === ===

	String sSql = "DELETE cjtk_link WHERE cont_id = " + contID;
	BriteUpdate.executeUpdate(sSql);
	
	ConnectionPool cp	= null;
	Connection conn		= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("link_scan_save.jsp");

		String check = null;
		String linkName="";
		String hrefName="";
		String sNewLinkID="";
		int newLinkID = 0;
		
		sSql = "Exec usp_ccnt_link_insert_bytes " + contID + ",?,?," + cust.s_cust_id;
		
		for (int i=1;i<=numLinks;++i)
		{
			JsonObject data= new JsonObject();
			check = request.getParameter("check"+i);
			if (check == null) continue;

			linkName = request.getParameter("lname"+i);
			hrefName = request.getParameter("lhref"+i);
			
			linkName = linkName.replaceAll("(?:\\n|\\r)", "");
			System.out.println("---------------"+linkName+"---------------");

			PreparedStatement pstmt	= null;
			
			try
			{
				pstmt = conn.prepareStatement(sSql);
				pstmt.setBytes(1,linkName.getBytes("ISO-8859-1"));
				pstmt.setString(2,hrefName);
				data.put("numLinks",numLinks);
				data.put("check",check)
                data.put("linkName",linkName);
				data.put("hrefName",hrefName);
				data.put("cont_id",contID);
				data.put("cont_id",contID);
                array.put(data);
				pstmt.execute();
			}
         

			catch(Exception ex){ throw ex; }
			finally { if (pstmt != null) pstmt.close(); }
		}
	}
	catch(Exception ex) { throw ex; }
	finally { 
		if (conn != null) cp.free(conn); }

	// === === ===

	String sRedirectURL = null;
	
	if (request.getParameter("type").equals("standard"))
		sRedirectURL = "cont_edit_standard.jsp?cont_id="+contID;
     // CY 8/24/16
     // added the following to change the flow for auto content load
     else if (request.getParameter("type").equals("load"))
          sRedirectURL = "cont_list.jsp";
	else
		sRedirectURL = "cont_edit.jsp?cont_id="+contID;
		
	response.sendRedirect(sRedirectURL);
%>
