<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.sql.*,
                        java.io.*,javax.servlet.*,
			javax.servlet.http.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
			contentType="text/html;charset=UTF-8"
		
%>
<%@ include file="validator.jsp"%>
<%@ include file="header.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%
	response.setContentType("*/*");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin","http://localhost:3002");
	response.setHeader("Access-Control-Allow-Credentials", "true");
	response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>

<%

	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	boolean bPasswordExpiring = user.isPassExpiring();

	String seenPop = null;
	if (seenPop == null) seenPop = ui.getSessionProperty("pass_exp_pop");
	if ((seenPop == null)||("".equals(seenPop))) seenPop = "0";

	//String sCustId = request.getParameter("cust_id");
	Customer cSuper = ui.getSuperiorCustomer();
	Customer cActive = ui.getActiveCustomer();
	JsonObject data = new JsonObject();
	JsonArray dataArray = new JsonArray();

	
	
	
	//data.put("cActive.s_cust_name ",cActive.s_cust_name );
	data.put("cActive",cActive);
	data.put("userId",user.s_user_id);
	data.put("bPasswordExpiring",bPasswordExpiring);
	//data.put("custId",cust.s_cust_id);
	data.put("custName",cust.s_cust_name);
	data.put("userName",user.s_user_name);
	dataArray.put(data);
	out.println(dataArray.toString());

	boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	boolean hasChildren = false;
	if(cSuper.m_Customers != null) hasChildren = true;

	boolean bDoRefresh = false;
	//if(sCustId != null)
	//{
	//	cActive = ui.setActiveCustomer(session, sCustId);
	//	bDoRefresh = true;
        //}
%>