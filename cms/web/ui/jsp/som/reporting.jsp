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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="styles/style.css"/>
<title>Insert title here</title>
</head>
<body>
<%
	// get session object do not create new one
	HttpSession scope = request.getSession(false);
	int custId = 0;
	
	// get customer id if not set redirect to error page
	if(scope.getAttribute("custId") != null)
	{
	System.out.println("cust id not null");
		custId = Integer.parseInt((String)scope.getAttribute("custId"));	
	} else {
	System.out.println("custid is null");
		request.getRequestDispatcher("index.jsp").forward(request, response);
	}
	
	// first check session object for accounts
	if(scope.getAttribute("accounts") == null)
	{
	System.out.println("accounts is null");
		request.getRequestDispatcher("index.jsp").forward(request, response);
	}
	
	System.out.println("accounts is not null");
	
	// get all campaigns from database
	ArrayList<CampaignObject> camps =  Campaign.getCampaigns(custId, 1, 0, false);
	boolean noData = true;	
	
	System.out.println("hereeeeeeeeeeee");
	
	// there are no campaigns in database
	if(camps == null)
	{
		out.println("There is no campaign.");
	} else {
		
%>
	<div id="wrapper">
			
				<%@ include file="inc/header.jsp" %>
				
					<div id="container">
						

					
		<table cellpadding="5" cellspacing="0" width="100%" class="datatable">
			<tr>
				<td class="header"></td>
				<td class="header">Campaign Name</td>
				<td class="header">Create Date</td>
				<td class="header">Finish Date</td>
				<td class="header">Total Likes</td>
				<td class="header">Total Comments</td>
				<td class="header">Retweets</td>
			</tr>
			<%
			
				for(int i = 0; i < camps.size(); i ++)
				{
					String campType = "facebook";
					String bgcolor = "F6F6F6";
					
					if(camps.get(i).getCampaignType() == 2)
					{
						campType = "twitter";
					}
					
					if(i % 2 == 0) 
					{
						bgcolor = "FFFFFF";
					}

					out.println("<tr bgcolor='#"+bgcolor+"'>");
					out.println("<td width='20' align='center'><img src='images/"+campType+"_16.png'/></td>");
					out.println("<td><a class='loader' href='report_detail.jsp?camp_id="+camps.get(i).getId()+"'>"+camps.get(i).getCampaignName()+"</a></td>");
					out.println("<td>"+camps.get(i).getCreateDate()+"</td>");
					out.println("<td>"+camps.get(i).getPublishDate()+"</td>");
					
					Facebook fbclient = null;
					Twitter twclient = null;
					
					if(camps.get(i).getCampaignType() == 1)
					{						
						fbclient = (Facebook)scope.getAttribute("fbclient");	
						
						String[] tokens = camps.get(i).getPublishId().split(",");
						int totalLikes = 0;
						
						for(int t = 0; t < tokens.length; t++)
						{							
							Long likeCount = fbclient.getLikeCount(tokens[t]);
							
							if(likeCount != null)
							{
								totalLikes += (int)((long)likeCount);
								
							} else {
								totalLikes += 0;
							}
						}
						
						String[] tokensCom = camps.get(i).getPublishId().split(",");
						int totalComments = 0;
						
						for(int m = 0; m < tokensCom.length; m++)
						{							
							Long comCount = fbclient.getCommentCount(tokens[m]);
							
							if(comCount != null)
							{
								totalComments += (int)((long)comCount);
								
							} else {
								totalComments += 0;
							}
						}
						
						out.println("<td>"+totalLikes+"</td>");
						out.println("<td>"+totalComments+"</td>");
						out.println("<td>Not available</td>");
					}
					
					if(camps.get(i).getCampaignType() == 2)
					{
						out.println("<td>Not available</td>");
						out.println("<td>Not available</td>");
						
						twclient = (Twitter)scope.getAttribute("twclient");
						System.out.println("hereeeeeeeeetttttttttttttteee");
						int tweetCount = twclient.getTweetCount(Long.parseLong(camps.get(i).getPublishId()));
						
						out.println("<td>"+tweetCount+"</td>");
					}

					out.println("</tr>");
				}
			%>
		</table>
		</div>
					<div style="clear:both"></div>
				</div>
<% } %>	
</body>
</html>