<%@  page language="java"
	import="java.net.*,
	   		java.util.ArrayList,
	   		java.text.SimpleDateFormat,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
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
	String cust_id = "723";
	String file_url = "http://rcp3.revotas.com/rrcp/export/exp_723_2019-05-28_11-47-33_369.txt";
	String action_type = "act_add";
	String audience_id = "6121817505944";
	String export_id = "237";
	String account_id = "1084999661512561";

	/*
	System.out.println("cust_id     :"+cust_id);
	System.out.println("file_url    :"+file_url);
	System.out.println("action_type :"+action_type);
	System.out.println("audience_id :"+audience_id);
	System.out.println("export_id   :"+export_id);
	System.out.println("account_id  :"+account_id);
	*/
	

	 
	final String ACCESS_TOKEN = "EAAD9PBkDKZAsBAKzUbIj5flXpWqV8K6xZCW19nyJ0uNyflWLcTIuxqptgmHwg6WWUEDZAEYjm0EyF9z1yCf9OyO3yvX3yD9oZBHZCQzczzisauZBSpUncYSYWZAU4dZB4huUr6Wg5lOpsrGOOIIjNrhv9RLiYhpHnGG2og1G31hKCAZDZD";
	final String APP_SECRET = "80fd5855769179cf568452958cc28e8e";
	final String ACCOUNT_ID = account_id;
	final APIContext context = new APIContext(ACCESS_TOKEN, APP_SECRET).enableDebug(true);
%>

<%

JsonArray schema = new JsonArray();
schema.add(new JsonPrimitive("EMAIL_SHA256"));

JsonArray data = new JsonArray();

JsonObject payload = new JsonObject();


%>

<%
	URL url = null;
	try {
		url = new URL(file_url);
	} catch (MalformedURLException e) {
		System.out.println("File Url Connection Error :" + e);
	}
	BufferedReader in = null;
	try {
		in = new BufferedReader(new InputStreamReader(url.openStream()));
	} catch (IOException e) {
		System.out.println("InputStream Error :" + e);
	}

	String inputLine;
	try {
		int lineCount = 0;
		String dt="";
		while ((inputLine = in.readLine()) != null) {
			if (lineCount > 2) {

				String email = inputLine;
			   out.println(email+"<br>");
				}
			lineCount += 1;
		}
		
		
	
		

	} catch (IOException e) {
		System.out.println("File Read Error :" + e);
	}
	try {
		in.close();
	} catch (IOException e) {
		System.out.println("InputStream Closed Error :" + e);
	}
%>


