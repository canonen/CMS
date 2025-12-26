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
		request.getRequestDispatcher("index.jsp").forward(request, response);
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="styles/style.css"/>
<title>Social Media Campaigns</title>
</head>
<body>
		<div id="wrapper">
			
				<%@ include file="inc/header.jsp" %>
				
						<div id="container">
						
						<div id="new-camp-sec" class="m10" style="margin-bottom:10px;">	
																<a href="newcampaign.jsp?type=facebook"><span>New Facebook Campaign</span></a>
																<a href="newcampaign.jsp?type=twitter"><span>New Twitter Campaign</span></a>
																<div style="clear:both;"></div>	
						</div>
						
					<%
						// first check session object for accounts
						if(scope.getAttribute("accounts") == null)
						{
							request.getRequestDispatcher("index.jsp").forward(request, response);
						}
	
						// get campaigns from database
						ArrayList<CampaignObject> camps =  Campaign.getCampaigns(custId, 0, 0, false);
						boolean noData = true;
						
						// there are no campaigns in database
						if(camps == null)
						{
							out.println("There is no campaign.");
							
						} else {
							
					%>
							<table cellpadding="5" cellspacing="0" width="100%" class="datatable">
								<tr>
									<td class="header"></td>
									<td class="header">Campaign Name</td>
									<td class="header">Create Date</td>
									<td class="header">Finish Date</td>
									<td class="header">Status</td>
									<td class="header">Reporting</td>
								</tr>
								<%
									for(int i = 0; i < camps.size(); i ++)
									{
										String campType = "facebook";
										String campStatus = "DRAFT";
										String campPublishDate = "Not sent yet";
										String bgcolor = "F6F6F6";
										
										if(camps.get(i).getCampaignType() == 2)
										{
											campType = "twitter";
										}
										
										if(camps.get(i).getCampaignStatus() == 1)
										{
											campStatus = "Published";
										} 
										else if(camps.get(i).getCampaignStatus() == 2)
										{
											campStatus = "Deleted";
										}
										
										if(camps.get(i).getPublishDate() != null)
										{
											campPublishDate = camps.get(i).getPublishDate();
										}
										
										if(i % 2 == 0) 
										{
											bgcolor = "FFFFFF";
										}
										
										out.println("<tr bgcolor='#"+bgcolor+"'>");
										out.println("<td width='20' align='center'><img src='images/"+campType+"_16.png'/></td>");
										out.println("<td><a href='newcampaign.jsp?type="+campType+"&camp_id="+camps.get(i).getId()+"'>"+camps.get(i).getCampaignName()+"</a></td>");
										out.println("<td>"+camps.get(i).getCreateDate()+"</td>");
										out.println("<td>"+campPublishDate+"</td>");
										out.println("<td>"+campStatus+"</td>");
										out.println("<td>");
										
										if(camps.get(i).getCampaignStatus() == 1)
										{
											out.println("<a class='loader' href='report_detail.jsp?camp_id="+camps.get(i).getId()+"'>View report</a></td>");
										}
										
										out.println("</tr>");
									}
								%>
							</table>
					<% } %>	
			</div>
			
		</div>
				
</body>
</html>