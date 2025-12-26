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
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ 
page import="java.util.ArrayList,java.util.List,com.restfb.Connection,com.restfb.types.Post,com.restfb.types.FacebookType,javax.servlet.http.HttpSession" 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="styles/style.css"/>
<title>Social Media Management by Revotas</title>
<script language="javascript" src="/cms/ui/js/tabscript.js" type="text/javascript"></script>

</head>
<body>

<%
	// get session object do not create new one
	HttpSession scope = request.getSession(false);
	String obj_id = request.getParameter("camp_id");
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

	if(obj_id == null)
	{
		request.getRequestDispatcher("error.jsp?type=OBJECT_ID_NOT_SET_IN_REPORTDETAIL").forward(request, response);
	}

%>

	<div id="wrapper">
			
				<%@ include file="inc/header.jsp" %>
				
					<div id="container">
											
							<%
							
								ArrayList<CampaignObject> camps =  Campaign.getCampaigns(custId, 1, Integer.parseInt(obj_id), true);
								Facebook fbclient = null;
								Twitter twclient = null;
							
								for(int i = 0; i < camps.size(); i ++)
								{
									String[] temp;
									temp = camps.get(i).getPublishDate().split(" ");
									String onlyDate = temp[0];
									String onlyTime = temp[1];
									
									String[] onlyDateArr = onlyDate.split("-");
									String properDate = onlyDateArr[2] + "/" + onlyDateArr[1] + "/" + onlyDateArr[0];
									
									String[] onlyTimeArr = onlyTime.split(":");
									String properTime = onlyTimeArr[0] + ":" + onlyTimeArr[1]; 
									
									String concatDate = properDate + " at " + properTime;
									
									String campType = "facebook";
									
									if(camps.get(i).getCampaignType() == 2)
									{
										campType = "twitter";
									}
									
							%>
									<table cellpadding="0" cellspacing="0" class="form-tables" width="600">
									<tr>
										<td colspan="2" class="header">
											<img src="images/<%=campType%>_16.png"/>
											<h2><%=camps.get(i).getCampaignName()%></h2>
										</td>
									</tr>									
							<%

									if(camps.get(i).getCampaignType() == 1)
									{
										fbclient = (Facebook)scope.getAttribute("fbclient");
										
										String[] tokens = camps.get(i).getPublishId().split(",");
										int totalLikes = 0;
										String likersNames = "";
										
										for(int t = 0; t < tokens.length; t++)
										{
											likersNames = "";
											Long likeCount = fbclient.getLikeCount(tokens[t]);
											
											
											if(likeCount != null)
											{
												totalLikes += (int)((long)likeCount);
												
												try
												{
													ArrayList<String> likers = fbclient.getLikers(tokens[t]);
													
													for(int k = 0 ; k < likers.size(); k++)
													{
														likersNames += "<div style='padding:9px;border-bottom:1px solid #383838'>"+likers.get(k)+"</div>";
													}
												}
												catch(Exception e)
												{
													likersNames += "N/A";
												}
												
											} else {
												totalLikes += 0;
											}
											
										}
										
										String[] tokensCom = camps.get(i).getPublishId().split(",");
										int totalComments = 0;
										String commenterNames = "";
										
										for(int m = 0; m < tokensCom.length; m++)
										{							
											Long comCount = fbclient.getCommentCount(tokens[m]);
											ArrayList<String> commenters = fbclient.getCommenterNames(tokens[m]);
											
											if(comCount != null)
											{
												totalComments += (int)((long)comCount);
												
												for(int k = 0 ; k < commenters.size(); k++)
												{
													commenterNames += "<div style='padding-bottom:3px;border-bottom:1px solid #E6E6E6'>"+commenters.get(k)+"</div>";
												}
											} else {
												totalComments += 0;
											}
										}
										%>
											<tr>
												<td>
													<table cellpadding="0" cellspacing="0" width="100%">
														<tr>
															<td colspan="2"><a style="font-weight:bold;color:#333" href="<%=camps.get(i).getLink() %>"><%=camps.get(i).getMessage() %></a></td>
														</tr>
														<tr>
															<td><img width="70" height="60" src="<%=camps.get(i).getPicture() %>"/></td>
															<td>
																<div style="font-weight:bold;"><%=camps.get(i).getTitle() %></div>
																<div style="font-weight:bold;"><%=camps.get(i).getCaption() %></div>
																<div style="text-align:justify;"><%=camps.get(i).getDescription() %></div>
															</td>
														</tr>
														<tr>
															<td colspan="2"><span style="color:#999999">Published on <span style="font-style:italic;"><%=concatDate%></span></span></td>
														</tr>
													</table>
												</td>
												<td width="275">
													<div>
														<div style="border-radius:5px;border: 2px solid #7A983C;margin-left:5px;font-size:16px;font-weight:bold;color:#000000;text-align:center;float:right;width:80px;height:60px;background-color:#9bbb59;">
															<div style="margin:10px 0;font-weight:normal;font-size:12px;">Clicks</div>
															<div>N/A</div>
														</div>
														<div style="border-radius:5px;border: 2px solid #7A983C;margin-left:5px;font-size:16px;font-weight:bold;color:#000000;text-align:center;float:right;width:80px;height:60px;background-color:#9bbb59;">
															<div style="margin:10px 0;font-weight:normal;font-size:12px;">Likes</div>
															<div><%=totalLikes%></div>
														</div>
														<div style="border-radius:5px;border: 2px solid #7A983C;margin-left:5px;font-size:16px;font-weight:bold;color:#000000;text-align:center;float:right;width:80px;height:60px;background-color:#9bbb59;">
															<div style="margin:10px 0;font-weight:normal;font-size:12px;">Comments</div>
															<div><%=totalComments%></div>
														</div>
														
														<div style="clear:both"></div>
													</div>
												</td>
											</tr>
	
											<tr>
												<td colspan="2">
													<ul id="tabnav">
														<li><a id="tab6_Step1" class="noClassPassiveTab" onclick="toggleTabs('tab6_Step','block6_Step',1,2,'active','noClassPassiveTab');" href="javascript:void(0)">Likes</a></li>
														<li><a id="tab6_Step2" class="active" href="javascript:void(0)" onclick="toggleTabs('tab6_Step','block6_Step',2,2,'active','noClassPassiveTab');">Comments</a></li>
													</ul>
													<%
										out.println("<div class='stats'>");
										
										out.print("<div class='likers' id='block6_Step1' style='display:none'>");
										if(totalLikes != 0)
										{
											out.print(likersNames);
										} else {
											out.print("No likes yet.");
										}
										out.print("</div>");
									
										out.print("<div class='commenters' id='block6_Step2'>");
										if(totalComments != 0)
										{
											out.print(commenterNames);
										} else {
											out.print("No comments yet.");
										}
										out.print("</div>");
										
										out.println("<div style='clear:both;'></div>");
										out.println("</div>");
										%>
												</td>
											</tr>
										<%

										
									} else {
										
										twclient = (Twitter)scope.getAttribute("twclient");
										String retweeters = "";
										
										int tweetCount = twclient.getTweetCount(Long.parseLong(camps.get(i).getPublishId()));
										
										if(tweetCount > 0)
										{
											ArrayList<String> twitters = twclient.getRetweeters(Long.parseLong(camps.get(i).getPublishId()));
											
											for(int m = 0; m < twitters.size(); m++)
											{
												retweeters += "<div style='padding:9px;border-bottom:1px solid #E6E6E6'>"+twitters.get(m)+"</div>";
											}
										}
										%>
										<tr>
											<td>
												<div style="margin-bottom:5px;font-size:13px;"><%=camps.get(i).getMessage()%></div>
												<div><span style="color:#999999">Published on <span style="font-style:italic;"><%=concatDate%></span></span></div>
											</td>
											<td>
											<div>
												<div style="border-radius:5px;border: 2px solid #7A983C;margin-left:5px;font-size:16px;font-weight:bold;color:#000000;text-align:center;float:right;width:80px;height:60px;background-color:#9bbb59;">
													<div style="margin:10px 0;font-weight:normal;font-size:12px;">Retweets</div>
													<div><%=tweetCount%></div>
												</div>
											</div>
											</td>
										</tr>
										
										<%
										if(tweetCount > 0)
										{
											%>
											<tr>
												<td colspan="2">
													<ul id="tabnav">
														<li><a id="tab6_Step1" class="active" href="javascript:void(0)">Retweets</a></li>
													</ul>
											
											
											<%

										
											out.println("<div class='stats'>");
											
											out.print("<div class='likers'>");
											out.print(retweeters);
											out.print("</div>");
											
											out.println("</div>");
											out.println("</td>");
											out.println("</tr>");
										}
										
										
									}
									
									
									
									
								}
							
							%>
							<tr>
								<td colspan="2"><div style="background-color: #E0F0FA;border: 1px solid #B7E2FA;color: #7D7D7D;line-height: 16px;padding: 5px;">Sometimes it is not possible to see the information of person who likes, comments or retweets. 
								This happens because of the privacy settings of the user account. 
								For this condition, you may only see the number of comments, likes or retweets.</div></td>
							</tr>
						</table>
					</div>
				</div>
</body>
</html>