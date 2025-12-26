<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}


CustCredit cc = new CustCredit();
cc.s_cust_id = "165";
cc.s_allocated_credit = "10000";
cc.s_used_credit = "7000";
cc.s_remaining_credit = "3000";

cc.saveWithSync();
%>
