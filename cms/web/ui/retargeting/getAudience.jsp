<%@  page language="java" 
              import="java.net.*,
              		 com.facebook.ads.sdk.*,
              		 com.facebook.ads.sdk.CustomAudience.EnumSubtype,
             		 java.nio.charset.StandardCharsets,
              		 java.security.MessageDigest,
              		 java.util.ArrayList,
              		 com.google.gson.JsonArray,
              		 com.google.gson.JsonObject,
              		 com.google.gson.JsonPrimitive"
	contentType="text/html;charset=UTF-8"
%>

 <%
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "*");
 %>

<%
  String ACCOUNT_ID = request.getParameter("accountID"); 
  String refresh_token = request.getParameter("refresh_token");

  //String ACCOUNT_ID = "1084999661512561";
  String ACCESS_TOKEN = refresh_token;
  String APP_SECRET = "80fd5855769179cf568452958cc28e8e";
  APIContext context = new APIContext(ACCESS_TOKEN,APP_SECRET).enableDebug(true);


%>


<%
try {
	ArrayList<String> fields = new ArrayList<String>();
	fields.add("name");
	fields.add("approximate_count");
	fields.add("delivery_status");

	APINodeList<CustomAudience> customAudiences = new AdAccount("act_"+ACCOUNT_ID, context).getCustomAudiences()
			.requestFields(fields).execute();
	
	String outValue="";
	
	
	boolean check=false;
	
	if(customAudiences.size()>0)
	{
	  for(int i=0;i<customAudiences.size();i++)
	   {
	   String aud_name=	customAudiences.get(i).getFieldName().replace(" ", ",");
       outValue+=customAudiences.get(i).getFieldId()+"--"+customAudiences.get(i).getFieldName()+"--"+aud_name+"*";
	   }
	  check=true;
	}
	
	if(check)
	{	
	out.println(outValue);
	}
	else
	{
	 out.println("error");	
	}

} catch (APIException e) {
	System.out.println("Get Audience List Error :" + e);
	out.println("error");
}

%>