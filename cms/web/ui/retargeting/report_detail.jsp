<%@  page language="java"
	import="java.net.*,
	        java.util.ArrayList,
	   	    java.util.Date,java.io.*,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*,
			com.facebook.ads.sdk.*,
			java.net.URL,
			java.security.MessageDigest,
			java.nio.charset.StandardCharsets,
			com.google.gson.JsonArray,
			com.google.gson.JsonObject,
            com.google.gson.JsonPrimitive"
	contentType="text/html;charset=UTF-8"%>
<%
	response.setHeader("Access-Control-Allow-Origin", "*");
	response.setHeader("Access-Control-Allow-Methods",
			" GET, POST, PATCH, PUT, DELETE, OPTIONS");
	response.setHeader("Access-Control-Allow-Headers",
			"Origin, Content-Type, X-Auth-Token");
%>
<%

String account_id = request.getParameter("account_id");
String ads_id     = request.getParameter("ads_id");
String start_date = request.getParameter("start_date");
String end_date   = request.getParameter("end_date");
String refresh_token = request.getParameter("refresh_token");


if(account_id==null || ads_id==null)
	return;

if(start_date!=null)
	start_date=start_date.replace("/", "-");
if(end_date!=null)
	end_date=end_date.replace("/", "-");

  final String ACCESS_TOKEN = refresh_token;
  final String ACCOUNT_ID = account_id;
  final String APP_SECRET = "80fd5855769179cf568452958cc28e8e";
  final String INSIGHTS_ID = ads_id;
  final APIContext context = new APIContext(ACCESS_TOKEN,APP_SECRET).enableDebug(true);
  
  try {
	   
		ArrayList<String> fields = new ArrayList<String>();
	
		fields.add("actions");  
		fields.add("action_values");
		fields.add("impressions");
		fields.add("clicks");
		fields.add("spend");  
		fields.add("cpc");  
		fields.add("cpm"); 
		fields.add("conversions");  
		fields.add("conversion_values");
		fields.add("cost_per_conversion");
String result=	new AdSet(INSIGHTS_ID, context).getInsights()
	      .setParam("breakdown", "publisher_platform")
	      .requestFields(fields)
	      .setTimeRange("{\"since\":\""+start_date+"\",\"until\":\""+end_date+"\"}")
	      .setTimeIncrement("1")
	      .execute().toString();
out.println(result);
} catch (APIException e) {
	System.out.println("Ads ID :"+ads_id);
	System.out.println("Get Insights Error :"+e);
	out.println("error");
}


%>