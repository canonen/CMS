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
ResultSet			rs			= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("socialinc.jsp");
	stmt = conn.createStatement();
	
} catch(Exception ex)
{ 
	throw new Exception(ex);
}
	
/* Social Media */

String link = request.getParameter("link");
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
rs.close();
	
if(isFbAccountSet)
{
	try 
	{	
		client 	= new Facebook(fbAccessToken);
		
	} catch(Exception ex) {
		isFacebookError = true;
	}
}			

if(isFbAccountSet)
{
	if(!isFacebookError) 
	{
		try 
		{	
			LegacyFacebookClient s = new DefaultLegacyFacebookClient(fbAccessToken);
			JsonObject jsonobj = s.execute("links.preview", JsonObject.class, Parameter.with("url", link));
			out.println(jsonobj.toString());
		} catch(Exception ex) {
			
			 String myString = new JsonObject().put("error", "1").toString();
			 out.println(myString);
		}	
	} else {
		out.print("<span style='color:#b53b3b;'>Unavailable</span> <a onclick='getSocialStuff()' style='text-decoration:underline;' href='javascript:void(0)'><img border='0' src='/cms/ui/images/arrow_refresh.png'/></a>");
	}
} else{
		out.print("<a style='text-decoration:underline;' href='/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp'>Enable</a>");
} 
%>

	