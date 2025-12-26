<%@ page
		language="java"
		import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>

<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	if(!can.bDelete)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	Statement 		stmt	= null;
	ResultSet 		rs		= null;
	ConnectionPool 	cp		= null;
	Connection 		conn	= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("export_delete.jsp");
		stmt = conn.createStatement();

		String sSelectedCategoryId = request.getParameter("category_id");
		if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
			sSelectedCategoryId = ui.s_category_id;

		String		CUSTOMER_ID	= cust.s_cust_id;
		//String []	FILES_LIST	= request.getParameterValues ("FILE");

		String []	FILES_LIST	= request.getParameterValues("check1");

		if (FILES_LIST == null) throw new Exception("No files were selected to be removed");

		Export exp = null;
		ExportParam eParam = null;

		for (int j=0 ; j < FILES_LIST.length ; j ++)
		{
			if (!FILES_LIST[j].equals("-9999"))
			{
				eParam = new ExportParam(FILES_LIST[j]);
				eParam.delete();
				exp = new Export(FILES_LIST[j]);
				exp.delete();
			}
		}

	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_delete.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

%>
