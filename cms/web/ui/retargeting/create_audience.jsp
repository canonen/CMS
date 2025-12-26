<%@  page language="java"
	import="java.net.*,
	   		java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*,
			com.facebook.ads.sdk.*,
			com.facebook.ads.sdk.CustomAudience.EnumSubtype,
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
      String account_id    = request.getParameter("account_id");
      String audience_name = request.getParameter("name");
      String description   = request.getParameter("description");
	  String refresh_token = request.getParameter("refresh_token");
      
      if(account_id==null || audience_name==null)
  	    {
  	     return;
  	    }

  	final String ACCESS_TOKEN = refresh_token;
  	final String APP_SECRET = "80fd5855769179cf568452958cc28e8e";
  	final String ACCOUNT_ID = account_id;
  	final APIContext context = new APIContext(ACCESS_TOKEN, APP_SECRET).enableDebug(true);

%>

<%

String descriptionA="";
if(description!=null)
	descriptionA = description;


AdAccount account = new AdAccount(ACCOUNT_ID, context);
boolean check=true;
try {
CustomAudience audience = account.createCustomAudience()
		.setName(audience_name)
		.setDescription(descriptionA)
		.setSubtype(EnumSubtype.VALUE_CUSTOM)
		.setCustomerFileSource(CustomAudience.EnumCustomerFileSource.VALUE_USER_PROVIDED_ONLY)
		.execute();
}
catch(APIException e){System.out.println("Create Audience API Error :" + e);check=false;}

if(check)
 out.println("ok");
else
	out.println("not ok");

%>



