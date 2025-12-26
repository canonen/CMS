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
            com.google.gson.JsonPrimitive,
            java.text.DateFormat"
	contentType="text/html;charset=UTF-8"%>
<%
	response.setHeader("Access-Control-Allow-Origin", "*");
	response.setHeader("Access-Control-Allow-Methods",
			" GET, POST, PATCH, PUT, DELETE, OPTIONS");
	response.setHeader("Access-Control-Allow-Headers",
			"Origin, Content-Type, X-Auth-Token");
%>

<%
       
	String cust_id = request.getParameter("cust_id");
	String file_url = request.getParameter("file_url");
	String action_type = request.getParameter("action_type");
	String audience_id = request.getParameter("audience_id");
	String export_id = request.getParameter("export_id");
	String account_id = request.getParameter("account_id");
	String refresh_token = request.getParameter("refresh_token");
      
 
	 /*
	System.out.println("cust_id     :"+cust_id);
	System.out.println("file_url    :"+file_url);
	System.out.println("action_type :"+action_type);
	System.out.println("audience_id :"+audience_id);
	System.out.println("export_id   :"+export_id);
	System.out.println("account_id  :"+account_id);
	
	*/
	if(file_url==null || action_type==null || audience_id==null || export_id==null || account_id==null)
	{
	return;
	}
	 

	final String ACCESS_TOKEN = refresh_token;
	final String APP_SECRET = "80fd5855769179cf568452958cc28e8e";
	final String ACCOUNT_ID = account_id;
	final APIContext context = new APIContext(ACCESS_TOKEN, APP_SECRET).enableDebug(true);
	
	String error="";
	boolean errorCheck=false;
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
		error=e.toString();
		errorCheck=true;
	}
	
	String inputLine;
	try {
		int lineCount = 0;
		String dt="";
		while ((inputLine = in.readLine()) != null) {
			
			if (lineCount > 2) {

				String email = inputLine;
				dt+="[\""+sha256(email.trim())+"\"],";
				}
			lineCount += 1;
		}
			
		boolean checkRes=false;
		if (lineCount > 2)
		{
			checkRes=true;
			if(!dt.equals(""))
			{	
			dt=dt.substring(0,dt.length()-1);
			
			if(action_type.equals("act_add"))
			{
			try {
				CustomAudience user = new CustomAudience(audience_id, context).createUser()
						  .setPayload("{\"schema\":[\"EMAIL_SHA256\"],\"data\":["+dt+"]}")
						  .execute();
			} catch (APIException e) {
				System.out.println("Add Audience Error :"+e);
				checkRes=false;
				error=e.toString();
				errorCheck=true;
				}
			}
			else
			{
				
				try {
					 new CustomAudience(audience_id, context).deleteUsers()
					.setPayload("{\"schema\":\"EMAIL_SHA256\",\"data\":["+dt+"]}")
					
					.execute();
					 
				} catch (APIException be) {
					System.out.println("Delete Audience Error :"+be);
					checkRes=false;/*e.printStackTrace();*/
					error=be.toString();
					errorCheck=true;
				}	
				
			}	
		}	
		}
		if(checkRes)
			out.println(lineCount-2);
		else
		    out.println("error");
	} catch (IOException e) {
		//System.out.println("custID :"+cust_id);
        //System.out.println("file_url    :"+file_url);
		System.out.println("File Read Error :" + e);
		error=e.toString();
		errorCheck=true;
		}
	try {
		in.close();
	} catch (IOException e) {
		System.out.println("InputStream Closed Error :" + e);
		error=e.toString();
		errorCheck=true;
	}
	
	if(errorCheck)
	{
		
        File file =new File("C:\\Winapps\\retargeting_log.txt");
        if(!file.exists())
        {
       	 try {
				file.createNewFile();
			} catch (IOException e) {
			   System.out.println("File write error! "+e);
			}
        }
        try {
       	DateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
       	Date date = new Date();
			BufferedWriter wr=new BufferedWriter(new FileWriter(file,true));
			wr.append(dateFormat.format(date)+" custID:"+cust_id+" AudienceID:"+audience_id+" ExportID:"+export_id);
			wr.append(System.getProperty("line.separator"));
			wr.append("Error :"+error);
			wr.append(System.getProperty("line.separator"));
			wr.append(System.getProperty("line.separator"));
			wr.close();
		} catch (FileNotFoundException e) {e.printStackTrace();}  
         catch (IOException e) {e.printStackTrace();}
	}
%>

<%!
public static String sha256(String message) {
	try {
		MessageDigest digest = MessageDigest.getInstance("SHA-256");
		byte[] hash = digest.digest(message.getBytes(StandardCharsets.UTF_8));
		return toHex(hash);
	} catch (Exception e) {
		return null;
	}
}

public static String toHex(byte[] bytes) {
	StringBuilder sb = new StringBuilder();
	for (byte b : bytes) {
		sb.append(String.format("%1$02x", b));
	}
	return sb.toString();
}



%>
