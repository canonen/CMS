<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

<%@ include file="../validator.jsp"%>

<%@page import="com.britemoon.cps.som.camp.*"%>
<%@page import="com.britemoon.cps.som.com.*"%>
<%@page import="com.britemoon.cps.som.fb.*"%>
<%@page import="com.britemoon.cps.som.servlets.*"%>
<%@page import="com.britemoon.cps.som.tw.*"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-9"
    pageEncoding="ISO-8859-1"%>
<%@ 
page import="java.util.ArrayList,java.util.List,com.restfb.Connection,com.restfb.types.Post,com.restfb.types.FacebookType,javax.servlet.http.HttpSession" 
%>
<%
	// get session object do not create new one
	HttpSession scope = request.getSession(false);
	int custId = 0;
	
	// get customer id if not set redirect to error page
	if(scope.getAttribute("custId") != null)
	{
		System.out.println("Customer id is set. from: home.jsp");
		custId = Integer.parseInt((String)scope.getAttribute("custId"));	
	} else {
		System.out.println("Customer id is NOT set. from: home.jsp");
		request.getRequestDispatcher("error.jsp?type=CUST_ID_NOT_SET_HOMEJSP").forward(request, response);
	}
	
	// first check session object for accounts
	if(scope.getAttribute("accounts") != null)
	{
			System.out.println("Account object is set in session object. from: home.jsp");
			ArrayList<Account> accounts = (ArrayList<Account>)scope.getAttribute("accounts");
			
			for(int i = 0; i < accounts.size(); i++)
			{
				System.out.println("There is at least one account. from: home.jsp");
				if(accounts.get(i).getAccountType() == 1) {
					
					System.out.println("Accounts from session is Facebook. from: home.jsp");
					String token = accounts.get(i).getAccessToken();
					
					// create new facebook client
					Facebook client = new Facebook(token);
					
					System.out.println("Facebook object created. from: home.jsp");
					
					// set this facebook client in session
					scope.setAttribute("fbclient", client);
					
					System.out.println("Facebook client is set in session. from: home.jsp");
					
				} else {
					
					// THIS PART IS MISSING CREATE A TWITTER OBJECT!!!!!!!!!
					System.out.println("Accounts from session is Twitter. from: home.jsp");
					String token = accounts.get(i).getAccessToken();
					
					// create new twitter object
					Twitter twitterObj = new Twitter(token);
					
					System.out.println("Twitter object created. from: home.jsp");
					
					// set this facebook client in session
					scope.setAttribute("twclient", twitterObj);
					
					System.out.println("Twitter client is set in session. from: home.jsp");
					
				}
			}
	} else {
		
		System.out.println("There is no accounts in session checking from database. from: home.jsp");
		
		try{
			
			// Pull accounts from database lets see if any account set in it
			ArrayList<Account> accounts = AccountVerifier.getAccounts(custId);
			
			if(accounts.size() < 1)
			{
				System.out.println("No accounts set in database. something should be wrong. Redirecting to error page from: home.jsp");
				request.getRequestDispatcher("index.jsp").forward(request, response);
				
			} else {
				
				System.out.println("Ok there is an account set in database. setting this accounts in session. from: home.jsp");
				scope.setAttribute("accounts", accounts);
				
				for(int i = 0; i < accounts.size(); i++)
				{
					System.out.println("There is at least one account. from: home.jsp");
					if(accounts.get(i).getAccountType() == 1) {
						
						System.out.println("Accounts from session is Facebook. from: home.jsp");
						String token = accounts.get(i).getAccessToken();
						
						// create new facebook client
						Facebook client = new Facebook(token);
						
						System.out.println("Facebook object created. from: home.jsp");
						
						// set this facebook client in session
						scope.setAttribute("fbclient", client);
						
						System.out.println("Facebook client is set in session. from: home.jsp");
						
					} else {
						
						System.out.println("Accounts from session is Twitter. from: home.jsp");
						String token = accounts.get(i).getAccessToken();
						
						// create new twitter object
						Twitter twitterObj = new Twitter(token);
						
						System.out.println("Twitter object created. from: home.jsp");
						
						// set this facebook client in session
						scope.setAttribute("twclient", twitterObj);
						
						System.out.println("Twitter client is set in session. from: home.jsp");
						
					}
				}
			}
			
		} catch(Exception e)
		{
			System.out.println("Problem!!! from: home.jsp");
		}
		
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Home</title>
<link rel="stylesheet" href="styles/style.css"/>
</head>
<body>


		<div id="wrapper">
			
				<%@ include file="inc/header.jsp" %>
				 
				<table cellpadding="5" cellspacing="0" width="700">
				<tr>
					<td>
						<div style="border:1px solid #DDDDDD;width:385px"><img src="http://www.revotas.com/autolink.gif"/></div>
					</td>
					<td style="padding-left: 20px;">
						<h3 style="font-size:13px;margin:0;color:#3B5998">Social Media Management</h3>
						<p style="color:#666;line-height: 17px;margin: 5px 0;">
							
							Revotas Social Media feature allows you to spread your messages on the fastest growing market: Social Media.
							By integrating Facebook and Twitter; it is easy to publish directly to your Facebook Fan Pages or Twitter account.
							You will be able to track the popularity of your Facebook feeds and Twitter tweets.
							
						</p>
						<h3 style="font-size:12px;">Getting Started</h3>
							<a href="newcampaign.jsp?type=facebook" style="background-color: #3B5998;color: #FFFFFF;display: block;font-size: 11px;font-weight: bold;margin-bottom: 10px;margin-top: 10px;padding: 10px;text-align: center;text-decoration: none;width: 150px;">New Facebook Campaign</a>
							<a href="newcampaign.jsp?type=twitter" style="background-color: #0099B9;color: #FFFFFF;display: block;font-size: 11px;font-weight: bold;margin-bottom: 10px;margin-top: 10px;padding: 10px;text-align: center;text-decoration: none;width: 150px;">New Twitter Campaign</a>
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-left:10px;">
						<h3 style="font-size:12px;margin:3px 0">Post Directly</h3>
						<p style="padding-bottom:10px;border-bottom:1px solid #DDDDDD;color:#666;line-height: 17px;margin: 5px 0;">
							Spread your message through world by Facebook and Twitter.
							You will be able to publish your email content, post your messages, pictures and links
							to Facebook and Twitter. Allows you to publish your content to all of your pages simultaneously.
						</p>
						
						<h3 style="margin:3px 0;font-size:12px;">View Recent Feeds</h3>
						<p style="padding-bottom:10px;border-bottom:1px solid #DDDDDD;color:#666;line-height: 17px;margin: 5px 0;">No matter how many Facebook Fan pages you have. You can switch one of your fan pages and get the recent
						Facebook feeds and view Twitter Timeline.</p>
						
						<h3 style="margin:3px 0;font-size:12px;">Track Your Posts</h3>
						<p style="color:#666;line-height: 17px;margin: 5px 0;">Track your Facebook and Twitter posts. See how many people likes, comments,
						retweets and mentions about your posts.</p>
					</td>
				</tr>
			</table>
				
		</div>

</body>
</html>