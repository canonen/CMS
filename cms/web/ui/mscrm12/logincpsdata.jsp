<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.imc.*, 
			java.sql.*, 
			java.io.*, 
			java.util.*, 
			java.net.*, 
			org.w3c.dom.*, 
			javax.servlet.*, 
			javax.servlet.http.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../jsp/header.jsp"%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try	
{
	String sCustLogin = request.getParameter("company");
	String sUserLogin = request.getParameter("login");
	String sPassword = request.getParameter("password");
	
	String sAction = request.getParameter("a");
	String sParams = request.getParameter("p");
	
	Customer cust = new Customer(null, sCustLogin);
	boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)))?true:false;

	User user = new User(null, sUserLogin, cust.s_cust_id);
	boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id)))?true:false;
	boolean bIsPasswordValid = ((user.s_password != null) && (user.s_password.equals(sPassword)))?true:false;

	if ( bIsCustActive && bIsUserActive && bIsPasswordValid)
	{
		session = request.getSession(true);
		UIEnvironment ui = new UIEnvironment(session, user, cust);

		SessionMonitor.update(session, request.getRequestURI());
		
		if ("cont_view".equals(sAction))
		{
			String sContentID 		= sParams;
			String sOriginContID 	= "";
			String contHTML 		= "No Content";
			String contText 		= "No Content";
			
			byte[] b = null;

			if ((sContentID != null) && !("null".equals(sContentID)))
			{
				Statement			stmt = null;
				ResultSet			rs = null; 
				ConnectionPool		cp = null;
				Connection			conn = null;
				
				try
				{
					cp = ConnectionPool.getInstance();
					conn = cp.getConnection(this);
					stmt = conn.createStatement();
				
					rs = stmt.executeQuery("select origin_cont_id from ccnt_content with(nolock) where cont_id = '" + sContentID + "'");
					if (rs.next())
					{
						sOriginContID = rs.getString(1);
					}
					rs.close();
					
					rs = stmt.executeQuery("Exec dbo.usp_ccnt_info_get " + sOriginContID);
					if (rs.next())
					{
						contHTML = "No Content";
						contText = "No Content";
						
						b = rs.getBytes("HTML");				
						contHTML = (b==null)?"No Content":new String(b,"UTF-8");
						b = rs.getBytes("Text");
						contText = (b==null)?"No Content":new String(b,"UTF-8");
					}
					rs.close();
				}
				catch (Exception ex)
				{
					ErrLog.put(this, ex, "Error in " + this.getClass().getName() +"\r\n", out, 1);
				}
				finally
				{
					try
					{
						if( stmt  != null ) stmt.close();
					}
					catch (Exception ex2) { } 
					
					if( conn  != null ) cp.free(conn); 
				}
				
				if (!("".equals(contHTML)))
				{
					%>
					<%= contHTML %>
					<%
				}
				else if (!("".equals(contText)))
				{
					%>
					<%= contText %>
					<%
				}
				else
				{
					%>
					<font face=Verdana size=2>No Content Selected</font>
					<%
				}
			}
		}
	}
	else
	{
		SessionMonitor.update(session, request.getRequestURI());
		session.invalidate();
		%>
<html>
<head>
<title>LogIn</title>
</head>
<body>
</body>
</html>
		<%
	}
}
catch(Exception ex)
{
	ErrLog.put(this, ex, "Error in login.jsp", out, 1);
}
finally { }
%>
