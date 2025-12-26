<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.apache.log4j.Logger"
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

	AccessPermission can = user.getAccessPermission(ObjectType.CATEGORY);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
%>

<%

	String s_cust_id=cust.s_cust_id;
	String sCategoryId = request.getParameter("category_id");
	String sCategoryNamee = request.getParameter("category_name");
 //String sCategoryName = request.getParameter("category_name");
	String sCategoryDescripe = request.getParameter("category_description");

	out.println(sCategoryId);

	if(sCategoryNamee==null|| sCategoryNamee==""){
		sCategoryNamee="kazak";
	}

    Category category = new Category(s_cust_id , sCategoryId);

    category.s_cust_id = cust.s_cust_id;
    category.s_category_id = request.getParameter("category_id");
    category.s_category_name = request.getParameter("category_name");
    category.s_category_descrip = request.getParameter("category_description");
    category.save();

	//Category category = new Category(s_cust_id , sCategoryId);
	//String sCategoryName = category.s_category_name;
	//String sCategoryDescrip = category.s_category_descrip;
	//out.println(sCategoryNamee);
	//out.println(sCategoryDescripe);
	//out.println("custid="+s_cust_id );
	//if(sCategoryNamee!=null && sCategoryNamee!=""){
	//category.save();
		//response.sendRedirect("category_save.jsp");
	//}
%>