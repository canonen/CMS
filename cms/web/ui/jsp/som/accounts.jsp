<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

<%@ include file="../validator.jsp"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ 
page import="twitter4j.*,twitter4j.auth.*,javax.servlet.http.HttpSession" 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="com.britemoon.cps.som.camp.*"%>
<%@page import="com.britemoon.cps.som.com.*"%>
<%@page import="com.britemoon.cps.som.fb.*"%>
<%@page import="com.britemoon.cps.som.servlets.*"%>
<%@page import="com.britemoon.cps.som.tw.*"%>
<%@page import="java.util.ArrayList"%>

<%@page import="twitter4j.Twitter"%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="styles/style.css"/>
<title>Revotas Social Media Module</title>
</head>
<body>
	<%		
		// get session object do not create new one
		HttpSession scope = request.getSession(false);
		int custId = 0;
		boolean disableFacebook = false;
		boolean disableTwitter = false;
		String oauthURL = "";
		ArrayList<Account> accounts = null;

		// get customer id if not set redirect to error page
		if(scope.getAttribute("custId") == null)
		{
			request.getRequestDispatcher("index.jsp").forward(request, response);
			
		} else {
			custId = Integer.parseInt((String)scope.getAttribute("custId"));
		
			// first check session object for accounts
			if(scope.getAttribute("accounts") == null)
			{
				request.getRequestDispatcher("index.jsp").forward(request, response);
				
			} else {

				// Pull accounts from session lets see if any account set in it
				accounts = (ArrayList<Account>)scope.getAttribute("accounts");
				
				if(accounts.size() > 0)
				{
					for(int i = 0; i < accounts.size(); i++)
					{
						if(accounts.get(i).getAccountType() == 1)
						{
							disableFacebook = true;
							
						} else if(accounts.get(i).getAccountType() == 2){
							
							disableTwitter = true;
						}
					}
					
				} else {
					request.getRequestDispatcher("index.jsp").forward(request, response);
				}
				
				// things we need to create twitter authentication url
				Twitter twitter = new TwitterFactory().getInstance();
				twitter.setOAuthConsumer("MpaPZ9Zt4UuiFxZDqPCw", "L40D0VleAB1pasnTMcHY709H3BpeVP5NraYntYVBmw");
				oauthURL = twitter.getOAuthRequestToken().getAuthorizationURL();
				scope.setAttribute("twitterobject", twitter);
			}
		}
	%>
		<div id="wrapper">
			
				<%@ include file="inc/header.jsp" %>
				
					<div id="container">
					
						
					<div id="account-selection">
						<h2>Add Social Accounts</h2>
						<p>
							Please select at least one account to use social media campaigns which will enable you to post content and view activities.
							By clicking on the social properties below; you will be asked to login with your account and authenticate the Revotas application. 
							You will be able to add non-authorized social properties from the Accounts section.
						</p>
						
						<div id="acc-btn-cnt">
							<%
								if(disableFacebook == false)
								{
							%>
									<a target="_blank" style="margin-right:10px;cursor:pointer" class="fb" onclick="window.open('https://www.facebook.com/dialog/oauth?client_id=132994310113715&redirect_uri=http://login.revotas.com/cms/ui/jsp/som/fbhandler.jsp&scope=offline_access,read_stream,publish_stream,user_groups,manage_pages&response_type=token','Facebook','height=500,width=500');"></a>
							<%
								} else {
							%>		
									<a href="ManageAccounts?do=deauthorize&accountType=1" style="margin-right:10px;cursor:pointer" class="fbde">
							<%		
									for(int i = 0; i < accounts.size(); i++)
									{
										if(accounts.get(i).getAccountType() == 1)
										{
											Facebook client = new Facebook(accounts.get(i).getAccessToken());
											com.restfb.types.User userx = client.getFbclient().fetchObject("me", com.restfb.types.User.class);
											String fullName = userx.getName();
											out.println("<span style='color: #666666;font-size: 11px;font-weight: bold;text-decoration: none;'>Logged in as " + fullName + "</span>");
										}
									}
								}
								%>
								</a>
								<%
								if(disableTwitter == false)
								{
							%>
									<a  style="cursor:pointer" class="tw" onclick="window.open('<%=oauthURL%>','Twitter','height=300,width=450');"></a>
							<%											
								} else {
							%>		
									<a href="ManageAccounts?do=deauthorize&accountType=2" style="cursor:pointer" class="twde">
							<%		
									for(int i = 0; i < accounts.size(); i++)
									{
										if(accounts.get(i).getAccountType() == 2)
										{
											com.britemoon.cps.som.tw.Twitter twitterClient = new com.britemoon.cps.som.tw.Twitter(accounts.get(i).getAccessToken());
											String fullName = twitterClient.getTwitter().getScreenName();
											out.println("<span style='color: #666666;font-size: 11px;font-weight: bold;text-decoration: none;'>Logged in as " + fullName + "</span>");
										}
									}
							%>
									</a>
							<%
								}
							%>

							<div style="clear:both;"></div>
						</div>
						
						<p class="info">
							* Facebook requires that you authenticated Pages through your personal Facebook account. 
							Revotas Social Media does not access your personal Facebook profile. It only pulls data from and publishes content to pages that you give authentication.
						</p>
					</div>

				</div>
	
			</div>
</body>
</html>