<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.io.*, 
			java.text.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	String sTaskId = BriteRequest.getParameter(request,"task_id");

	ConnectionPool cp = null;
	Connection conn = null;
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		
		String[] sTaskIdList = sTaskId.split(",");
		for (int n=0; n < sTaskIdList.length; n++) 
		{
			String sql = " EXEC usp_cftp_ftp_task_host_monitor_reset_task @task_id=" + sTaskIdList[n];
			BriteUpdate.executeUpdate(sql, conn);
		}
	}
	catch (Exception ex)
	{
		logger.error("Exception: ", ex);
		out.println("<PRE>");
		ex.printStackTrace(new PrintWriter(out));
		out.println("</PRE>");
	}
	finally
	{
		if (conn!=null) cp.free(conn);			
	}
	
	if (true)
	{
		response.sendRedirect("ftp_import_hm.jsp");
		return;
	}
%>
