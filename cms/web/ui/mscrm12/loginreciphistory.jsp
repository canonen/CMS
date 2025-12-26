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
	
	String recipID = request.getParameter("recip_id");
	
	Customer cust = new Customer(null, sCustLogin);
	boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)))?true:false;

	User user = new User(null, sUserLogin, cust.s_cust_id);
	boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id)))?true:false;
	boolean bIsPasswordValid = ((user.s_password != null) && (user.s_password.equals(sPassword)))?true:false;

	if ( bIsCustActive && bIsUserActive && bIsPasswordValid)
	{
		session = request.getSession(true);
		UIEnvironment ui = new UIEnvironment(session, user, cust);
		
		AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);

		if(!can.bRead)
		{
			response.sendRedirect("../access_denied.jsp");
			return;
		}
		
		/*
		// Connection
		Statement			stmt			= null;
		ResultSet			rs				= null; 
		ConnectionPool		connectionPool	= null;
		Connection			srvConnection	= null;

		String sRequestXML = "";
		String sListXML = "";

		try
		{
			connectionPool = ConnectionPool.getInstance();
			srvConnection = connectionPool.getConnection("loginreciphistory.jsp");
			stmt = srvConnection.createStatement();

			sRequestXML += "<RecipRequest>\r\n";
			sRequestXML += "<action>EdtList</action>\r\n";
			sRequestXML += "<cust_id>" + cust.s_cust_id + "</cust_id>\r\n";
			sRequestXML += "<email_821><![CDATA[" + sEmail + "]]></email_821>\r\n";
			sRequestXML += "<num_recips>10</num_recips>\r\n";
			sRequestXML += "<attr_list>1,6</attr_list>\r\n";
			sRequestXML += "</RecipRequest>\r\n";

			Service service = null;
			Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);

			service = (Service) services.get(0);
			service.connect();

			service.send(sRequestXML);
			sListXML = service.receive();

			service.disconnect();
			
			Element eRecipList = XmlUtil.getRootElement(sListXML);
			
			XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");
			
			Element eRecip = null;
			String 	sRecipID = "";
			
			//out.write("xml: " + String.valueOf(sRequestXML) + "<br>");
			
			//out.write("# match: " + String.valueOf(xelRecips.getLength()) + "<br>");
			
			for (int j=0; j < xelRecips.getLength() ; j++)
			{
				eRecip = (Element)xelRecips.item(j);
				sRecipID = XmlUtil.getChildCDataValue(eRecip,"recip_id");
			}
			
			//out.write("recipID: " + String.valueOf(sRecipID) + "<br>");
			
			recipID = sRecipID;
		}
		catch(Exception ex)
		{
			ErrLog.put(this,ex,"Problem finding Recipients.\r\n Request XML: "+sRequestXML+"\r\n List XML: "+sListXML,out,1);
		}
		finally
		{
			if ( stmt != null ) stmt.close();
			if ( srvConnection != null ) connectionPool.free(srvConnection); 
		}
		*/
		//out.write("recipID: " + String.valueOf(recipID) + "<br>");

		response.sendRedirect("/cms/ui/jsp/report/recip_camp_history.jsp?recip_id=" + recipID);

		SessionMonitor.update(session, request.getRequestURI());
	}
	else
	{
		SessionMonitor.update(session, request.getRequestURI());
		session.invalidate();
%>

<HTML>

<HEAD>
	<TITLE>Login</TITLE>
	<BASE target="_self">

	<SCRIPT>

	function putFocus()
	{
		if (login_form.company.value=='')login_form.company.focus();
		else if (login_form.login.value=='')login_form.login.focus();
		else if (login_form.password.value=='')login_form.password.focus();
	}

	</SCRIPT>
</HEAD>

<BODY bgcolor=#dddddd onLoad="putFocus(0,1);">

<FORM method="POST" action="loginreciphistory.jsp" name="login_form">

<font face=arial size=1>
<center><br><br><br><br><br><br><table bgcolor=#aaaaaa width=250 cellpadding=1 cellspacing=1>
<tr>
<td bgcolor=#ffffff width=250>
  <TABLE style="font-family:arial;color:#555555;font-size:10px;" border="0" align="left" cellpadding=3 cellspacing=1>
    
<tr>
<td style="font-family:arial;color:#990000;font-size:10px;" colspan=2 align=center>Your login information is incorrect.  Please try again or contact support for assistance.</td>
</tr>
<TR>
	<TD></TD>
    <TD align="left" valign=bottom>&nbsp;<IMG border="0" src="../images/logologin.gif"></TD>
      
    </TR>
			<TR>
			<TD align="right">Company:</TD>
			<TD><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="company" size="32" value="<%=(sCustLogin==null)?"":sCustLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Login:</TD>
			<TD><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="text" name="login" size="32" value="<%=(sUserLogin==null)?"":sUserLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Password:</TD>
			<TD><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="password" name="password" size="32" value=""></TD>
		</TR>
		<TR>
			<TD align="center" colspan="2"><INPUT style="font-family:arial;color:#555555;font-size:10px;" type="submit" value="Submit"></TD>
		</TR>
	</TABLE>
</FORM>
</BODY>

</HTML>

<%
	}
}
catch(Exception ex)
{
	ErrLog.put(this, ex, "Error in login.jsp", out, 1);
}
finally
{
}
%>
