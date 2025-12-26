<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
		errorPage="../../error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	try {
		String sFromAddressId = request.getParameter("from_address_id");

		FromAddress fa = null;

		if (sFromAddressId == null) {
			fa = new FromAddress();
			fa.s_cust_id = cust.s_cust_id;
		}
		else fa = new FromAddress(sFromAddressId);

		fa.s_prefix = request.getParameter("prefix");
		fa.s_domain = request.getParameter("domain");


		fa.saveWithSync();
	}
	catch (Exception e){
		out.println(e);
	}
%>

