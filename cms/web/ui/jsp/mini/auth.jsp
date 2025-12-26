<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,java.sql.*,
			java.io.*,javax.servlet.*,
			javax.servlet.http.*,java.util.*,
			java.security.MessageDigest,
			java.security.NoSuchAlgorithmException,
			java.net.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String error = "";

try	
{	
	// Here we go
	
	String userid = "";
	String username = "";
	String password = "";
	String custid = "";
	String token = "rvs1";
	String uniqueIdentifier = "";
		
	if(request.getParameter("auth") != null)
	{
		String loginCredentials = request.getParameter("auth");
		
		if(!loginCredentials.trim().equals(""))
		{
			String loginCredentialPartials[] = loginCredentials.split("-");
			
			if(loginCredentialPartials.length == 3)
			{
				userid = loginCredentialPartials[0];
				uniqueIdentifier = loginCredentialPartials[1];
				custid = loginCredentialPartials[2];
				
				Customer c = new Customer(custid);
				
				if(c != null && c.s_cust_name != null && !c.s_cust_name.trim().equals(""))
				{
					boolean isActiveCustomer = ((c.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(c.s_status_id)))?true:false;
					
					if(isActiveCustomer)
					{					
						User u = new User(userid, null, c.s_cust_id);
						
						boolean isActiveUser = ((u.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(u.s_status_id)))?true:false;
						
						if(isActiveUser)
						{
							password = u.s_password;
							username = u.s_login_name;
							
							String concatAuthCredentials = userid + username + password + custid + token;
							
							byte[] defaultBytes = concatAuthCredentials.getBytes();
							String hashAuthCredentials = "";
		
							try
							{
								MessageDigest algorithm = MessageDigest.getInstance("MD5");
								algorithm.reset();
								algorithm.update(defaultBytes);
								byte messageDigest[] = algorithm.digest();
										
								StringBuffer hexString = new StringBuffer();
								for (int i=0;i<messageDigest.length;i++) {
									hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
								}
								
								hashAuthCredentials = hexString.toString();
								
								if(hashAuthCredentials.equals(uniqueIdentifier))
								{
									response.addHeader("P3P","CP=\"IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\"");
									session = request.getSession(true);
									UIEnvironment ui = new UIEnvironment(session, u, c);
									
									String sRedirect = "../mini/home.jsp";
									
									SessionMonitor.update(session, request.getRequestURI());
									response.sendRedirect(sRedirect);
									
								}
								else 
								{
									error = "Login credentials are incorrect.";
								}
								
							}
							catch(NoSuchAlgorithmException nsae){
								error = "Internal error occurred.";
							}
					
						}
						else
						{
							error = "User is not active.";
						}
					
					}
					else
					{
						error = "Customer is not active.";
					}
					
					
				}
				else
				{
					error = "No such customer.";
				}
				
			}
			else
			{
				error = "Parameters are not set correctly.";
			}
			
			
		}
		else
		{
			error = "Parameters are not set correctly.";
		}
		
	}
	else
	{
		error = "Parameters are not set correctly.";
	}
}
catch(Exception ex)
{
	error = "Unknown error occurred.";	
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="tr" lang="tr">

<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
</head>
<body>
	<div style="text-align:center;font-size:13px;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;width:400px;margin:0 auto;padding:10px;color:#B94A48;background-color:#F2DEDE;border:1px solid #EED3D7;border-radius:4px;">
		<div style="font-weight:bold;margin-bottom:3px;">Error</div>
		<% if(!error.equals("")) out.println(error); %>
	</div>
</body>
</html>