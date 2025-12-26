<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ 
page import="twitter4j.*,twitter4j.auth.*,javax.servlet.http.HttpSession" 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

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
<%@page import="java.util.ArrayList"%>
<%@page import="twitter4j.Twitter"%>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="styles/style.css"/>
<title>Revotas Social Media Module</title>
</head>
<body>
	
	<%		
		String referer = "";
			
		if(request.getParameter("referer") != null)
		{
			referer = request.getParameter("referer");
		}
		
		String oauthURL = "";
		
		// create a http session object, create new if no session available
		HttpSession scope = request.getSession(true);
	
		// put customer id in session object
		scope.setAttribute("custId", cust.s_cust_id);
		
		
		
		// Pull accounts from database lets see if any account set in it
		ArrayList<Account> accounts =  AccountVerifier.getAccounts(Integer.parseInt(cust.s_cust_id));
		
		if(accounts.size() > 0)
		{
			System.out.println("Facebook or Twitter account exists in database. Redirecting to home.jsp from: index.jsp");
			
			scope.setAttribute("accounts", accounts);
			
			// facebook or twitter account is set before
			request.getRequestDispatcher("home.jsp").forward(request, response);
			
		} else {
		
			// things we need to create twitter authentication url
			Twitter twitter = new TwitterFactory().getInstance();
			twitter.setOAuthConsumer("MpaPZ9Zt4UuiFxZDqPCw", "L40D0VleAB1pasnTMcHY709H3BpeVP5NraYntYVBmw");
			
			RequestToken requestToken = twitter.getOAuthRequestToken();
			AccessToken accessToken = null;
			oauthURL = requestToken.getAuthorizationURL();
			
			scope.setAttribute("twitterobject", twitter);
			
			System.out.println("Twitter authentication URL created. from: index.jsp");
			System.out.println(oauthURL);
		}
		
	%>

	<div id="wrapper">
		<div id="account-selection">
			<h2>Add Social Accounts</h2>
			<p>
				Please select at least one account to use social media campaigns which will enable you to post content and view activities.
				By clicking on the social properties below; you will be asked to login with your account and authenticate the Revotas application. 
				You will be able to add non-authorized social properties from the Accounts section.
			</p>
			
			<div id="acc-btn-cnt">
				<a  style="margin-right:10px;cursor:pointer" class="fb" onclick="window.open('https://www.facebook.com/dialog/oauth?client_id=132994310113715&redirect_uri=http://login.revotas.com/cms/ui/jsp/som/fbhandler.jsp?referer=<%=referer%>&scope=offline_access,read_stream,publish_stream,user_groups,manage_pages&response_type=token','Facebook');"></a>
				<a  style="cursor:pointer" class="tw" onclick="window.open('<%=oauthURL%>','Twitter');"></a>
				<div style="clear:both;"></div>
			</div>
			
			<p class="info">
				* Facebook requires that you authenticated Pages through your personal Facebook account. 
				Revotas Social Media does not access your personal Facebook profile. It only pulls data from and publishes content to pages that you give authentication.
			</p>
		</div>
	</div>
</body>
</html>