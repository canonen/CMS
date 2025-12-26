<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.util.List,
			java.net.*,java.text.DateFormat,
			java.text.SimpleDateFormat,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@page import="com.britemoon.cps.som.camp.*"%>
<%@page import="com.britemoon.cps.som.com.*"%>
<%@page import="com.britemoon.cps.som.fb.*"%>
<%@page import="com.britemoon.cps.som.servlets.*"%>
<%@page import="com.britemoon.cps.som.tw.*"%>
<%@page import="com.restfb.LegacyFacebookClient, com.restfb.DefaultFacebookClient,com.restfb.DefaultLegacyFacebookClient,com.restfb.Parameter, com.restfb.DefaultJsonMapper, com.restfb.json.JsonObject, com.restfb.types.Post, com.restfb.JsonMapper, com.restfb.types.Url, com.restfb.types.Page,twitter4j.ResponseList,twitter4j.Status,twitter4j.TwitterException,twitter4j.ProfileImage"%>


<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

String switchPage = request.getParameter("switchPage");
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy k:m, E");

Facebook client 		= null;
Twitter twitterClient 	= null;

String likeCount 	= null;
Page pagefb 		= null;
String idx 			= null;

com.restfb.Connection<Post> feeds 	= null;
ResponseList<Status> statuses 		= null;
ResponseList<Status> mentions 		= null;
int twitterFollowerCount			= 0;

boolean isFbAccountSet 	= false;
boolean isTwAccountSet 	= false;
String fbAccessToken 	= null;
String twAccessToken 	= null;
boolean isFacebookError = false;
boolean isTwitterError  = false;
ArrayList<FBAccount> pageAccounts = null;
	
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("socialinc.jsp");
	stmt = conn.createStatement();

	rs = stmt.executeQuery("select * from cque_camp_social_media_accounts where status = 1 and custId = " + cust.s_cust_id);

	while (rs.next())
	{
		int accountType    = rs.getInt("accountType");
		String accessToken = rs.getString("accessToken");
		
		if(accountType == 1) {
			isFbAccountSet = true;
			fbAccessToken  = accessToken;
		} else {
			isTwAccountSet = true;
			twAccessToken  = accessToken;
		}
	}
} 
catch(Exception ex)
{ 
	throw new Exception(ex);
}
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception e) {}
	if (conn != null) cp.free(conn);
}
	
if(isFbAccountSet)
{
	try 
	{	
		client 			= new Facebook(fbAccessToken);
		pageAccounts 	= client.getAccounts();
		idx 			= pageAccounts.get(0).getId();
		
		if(switchPage != null)
		{
			idx = switchPage;
		}
		
		feeds 		 	= client.getFbclient().fetchConnection(idx+"/feed", Post.class, Parameter.with("limit", 4));
		pagefb 		 	= client.getFbclient().fetchObject(idx, Page.class);	
		likeCount 	 	= Long.toString(pagefb.getLikes());
		
	} catch(Exception ex) {
		isFacebookError = true;
	}
}			
if(isTwAccountSet)
{
	try 
	{
		twitterClient 			= new Twitter(twAccessToken);
		statuses 				= twitterClient.getTwitter().getUserTimeline();	
		mentions 				= twitterClient.getTwitter().getMentions();
		twitterFollowerCount 	= twitterClient.getTwitter().getFollowersIDs(-1).getIDs().length;
	} catch(Exception ex) {
		isTwitterError = true;
	}
}
%>
	
<div id="facebookRs">
	<%
	if(isFbAccountSet)
	{
		if(!isFacebookError) 
		{				
	%>
		<span style="font-size:16px;font-family:Arial;font-weight:bold;color:#3B5998"><%=likeCount%></span>
		<span style="font-size:12px;font-family:Arial;color:#666666;">Likes</span>
	<%
		} else {
			out.print("<span style='color:#b53b3b;'>Unavailable</span> <a onclick='getSocialStuff()' style='text-decoration:underline;' href='javascript:void(0)'><img border='0' src='/cms/ui/images/arrow_refresh.png'/></a>");
		}
	} else{
			out.print("<a style='text-decoration:underline;' href='/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp&referer=home'>Enable</a>");
	} 
	%>
</div>
	
<div id="twitterRs">
	<%
	if(isTwAccountSet) 
	{
		if(!isTwitterError) 
		{
	%>
		<span style="font-size:16px;font-family:Arial;font-weight:bold;color:#19BAEE"><%=twitterFollowerCount%></span>
		<span style="font-size:12px;font-family:Arial;color:#666666;">Followers 
		<span style="font-size:16px;font-family:Arial;font-weight:bold;color:#19BAEE"><%=mentions.size()%></span> Mentions</span>
	<%
		} else {
			out.print("<span style='color:#b53b3b;'>Unavailable</span> <a onclick='getSocialStuff()' style='text-decoration:underline;' href='javascript:void(0)'><img border='0' src='/cms/ui/images/arrow_refresh.png'/></a>");
		}
	} else{
		out.print("<a style='text-decoration:underline;' href='/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp&referer=home'>Enable</a>");
		
	}
	%>
</div>
	
<div id="socialRs">
	<div id="block5_Step1">			
	<%
	if(isFbAccountSet) {
		if(!isFacebookError) {
	%>
		<div style="text-align:right;">
		<select id="pages" onchange='pageSwitcher(options[selectedIndex].value)'>			
	<%
		for(int i = 0; i < pageAccounts.size(); i++)
		{
			out.print("<option value='"+pageAccounts.get(i).getId()+"'>"+pageAccounts.get(i).getName()+"</option>");
		}
	%>
		</select>
		</div>
	<%
		int feedSize = feeds.getData().size();
		
		if(feedSize > 0) 
		{
		%>
			<table cellpadding="5" cellspacing="0" width="360">
		<%
			for(int i = 0; i < 4; i++)
			{		
				String fromId = "";
				
				try 
				{
					fromId = feeds.getData().get(i).getFrom().getId().toString();
					
					if(fromId == "") 
					{
						continue;
					}
				} catch(Exception e) {
					continue;
				}
	%>
				<tr>
					<td style="vertical-align:top;padding-top:10px;">
						<a style="color:#FFFFFF;text-decoration:none;" href='http://www.facebook.com/profile.php?id=<%=feeds.getData().get(i).getFrom().getId().toString()%>'>
							<img border="0" src="http://graph.facebook.com/<%=fromId%>/picture"/>
						</a>
					</td>
					<td style="vertical-align:top;padding-top:10px;">
						<div style="margin-bottom:2px;color:#3B5998;font-weight:bold;">
							<a style="color:#3B5998;text-decoration:none;" href='http://www.facebook.com/profile.php?id=<%=fromId%>'>
								<%=feeds.getData().get(i).getFrom().getName().toString()%>
							</a>
						</div>
						<div style="margin-bottom:2px;color:gray;">
							<%
								try 
								{
									String fb_message = feeds.getData().get(i).getMessage().toString();
									
									if(fb_message != null)
									{
										out.println(fb_message);
									}
								} catch(Exception e) {
									
								}
							%>
						</div>
						<div style="margin-bottom:2px;color:gray;">
							<%
								try 
								{
									String fb_desc = feeds.getData().get(i).getDescription().toString();
									
									if(fb_desc != null)
									{
										out.println(fb_desc);
									}
								} catch(Exception e) {
									
								}
							%>
							</div>
						<div style="margin-bottom:2px;color:#AAAAAA;font-size:10px;"><%=sdf.format(feeds.getData().get(i).getCreatedTime())%></div>
					</td>
				</tr>
				<tr>
					<td colspan="2" style="border-bottom:1px solid #DDDDDD">
						<div style="text-align:right;">
						<%
							Long comCount 	= client.getCommentCount(feeds.getData().get(i).getId());										
							Long likeCountx = client.getLikeCount(feeds.getData().get(i).getId());

							if(likeCountx != null) {
								out.println("<img src='/cms/ui/images/fblike.png'/> <span style='color:#3B5998'>"+likeCountx+"</span>");
							} else {
								out.println("<img src='/cms/ui/images/fblike.png'/> <span style='color:#3B5998'>0</span>");
							}

							if(comCount != null) {
								out.println("<img src='/cms/ui/images/fbcom.png'/> <span style='color:#3B5998'>"+comCount+"</span>");
							} else {
								out.println("<img src='/cms/ui/images/fbcom.png'/> <span style='color:#3B5998'>0</span>");
							}
						%>
						</div>
					</td>
				</tr>
		<%
			}
		%>	
			</table>
		<%	
		} else {
			out.println("Currently, there is no feed.");
		}	
	} else {
		out.println("<span style='font-size:12px;'>Facebook News Feed is <span style='color:#b53b3b;'>Unavailable</span> right now!</span>");
	}
	} else {
	out.print("<div style='font-size: 12px;line-height: 20px;'>You must have verified your Facebook account in order to view News Feed. <a style='text-decoration:underline;' href='/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp&referer=home'>Click here to verify</a></div>");
	}
	%>
	</div>

	<div id="block5_Step2" style="display:none;">
	<%
	if(isTwAccountSet)
	{
		if(!isTwitterError)
		{
	%>
			<div style="color: #444444;">
				<div style="float:left;margin-right:7px;"><a href='https://twitter.com/#!/<%=twitterClient.getTwitter().getScreenName()%>'><img border="0" src='<%=twitterClient.getTwitter().getProfileImage(twitterClient.getTwitter().getScreenName(),ProfileImage.NORMAL).getURL()%>'></a></div>
				<div style="float:left;">
					<div style="line-height:48px;font-size:14px;font-weight: bold;margin-bottom: 5px;margin-left:10px;"><a style="color:#444444;text-decoration:none;" href='https://twitter.com/#!/<%=twitterClient.getTwitter().getScreenName()%>'><%=twitterClient.getTwitter().getScreenName()%></a></div>
				</div>
				<div style="clear:both;"></div>
			</div>
	<%
				if(statuses.size() > 0)	
				{
					for(int i = 0; i < 5; i++)
					{							
					%>
						<div style="margin-bottom:10px;padding-bottom:5px;border-bottom:1px solid #CCCCCC;">
							<div style="margin-bottom:2px;font-size:12px;color:#437EA1;font-weight:bold;"><%=statuses.get(i).getUser().getName()%></div>
							<div style="color:gray;margin-bottom:2px;"><%=statuses.get(i).getText()%></div>
							<div style="color:gray;margin-bottom:2px;color:#AAAAAA;font-size:10px;"><%=sdf.format(statuses.get(i).getCreatedAt())%></div>
							<div style="">
								<a style="font-size:10px;color:#007DC6" target="_blank" href="http://twitter.com/intent/tweet?in_reply_to=<%=statuses.get(i).getId()%>">reply</a>&nbsp;
								<a style="font-size:10px;color:#007DC6" target="_blank" href="http://twitter.com/intent/retweet?tweet_id=<%=statuses.get(i).getId()%>">retweet</a>&nbsp;
								<a style="font-size:10px;color:#007DC6" target="_blank" href="http://twitter.com/intent/favorite?tweet_id=<%=statuses.get(i).getId()%>">favorite</a>
							</div>
						</div>
					<%					
					}
				} else {
					out.println("Currently, there is no status updates.");
				}
		} else {
			out.println("<span>Twitter Timeline is <span style='color:#b53b3b;'>Unavailable</span> right now!</span>");
		}
	} else {
		out.print("<div style='font-size: 12px;line-height: 20px;'>You must have verified your Twitter account in order to view Timeline. <a style='text-decoration:underline;' href='/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp&referer=home'>Click here to verify</a></div>");
	}
	%>
	</div>
</div>