<%@page import="java.text.SimpleDateFormat"%>
<%@ page
		language="java"
		import="com.britemoon.aps.jtk.*,
			java.io.*,java.sql.*,java.util.*"

		contentType="text/html;charset=UTF-8"
%>
<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONString"%>

<%
	response.setHeader("Access-Control-Allow-Origin", "*");
	// response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
	// response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>

<%
	String url_activite= request.getParameter("url_activite");
	if(url_activite.length()>255)
		url_activite=url_activite.substring(0,254);

	String page_type = null;
	String pageType = request.getParameter("page_type");
	if(pageType!=null && !pageType.isEmpty()){
		page_type = pageType;
	}
	String product				= request.getParameter("act_product");
	//System.out.println("prod= " +product);
	JSONObject jsonObj;
	if(product == null ||product.equals("null")){
		jsonObj 		= new JSONObject();
	}
	else {
		jsonObj 		= new JSONObject(product);
	}

	Boolean isTsoft=false;

	//System.out.println("-----act_id------ = " + jsonObj.get("act_id"));
	//System.out.println("-----act_currency------------ = " + jsonObj.get("act_currency"));

	if(jsonObj.has("act_image"))
		isTsoft=true;
	//System.out.println("-----url------ = " + jsonObj.get("act_available"));
	String cookie= request.getParameter("cookie_id");

	String token = request.getParameter("token_id");

	if(token == null || token.equalsIgnoreCase("undefined") || token.equalsIgnoreCase(""))
		token = null;
	//System.out.println("-----token------ = " + token);
	String useragent= request.getParameter("useragent");
	if(useragent.length()>255)
		useragent=useragent.substring(0,254);


	String uip= request.getParameter("uip");


	String sehir= request.getParameter("sehir");


	String bolge= request.getParameter("bolge");


	String custkey= request.getParameter("custkey");

	String custid= request.getParameter("custid");

	String campid= request.getParameter("campid");


	String recipid= request.getParameter("recipid");

	String mailrecipid= request.getParameter("mailrecipid");

	String device = request.getParameter("device");
	String deviceStr = "";
	if(device.equals("1")){
		deviceStr = "MOBILE";
	}else if(device.equals("2")) {
		deviceStr = "DESKTOP";
	}


	SimpleDateFormat time_format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	String current_time = time_format.format(System.currentTimeMillis());


	int mail_recip_id=-1;
	if(!mailrecipid.equals("null"))
		mail_recip_id=Integer.parseInt(mailrecipid);
	String cst="";
	String queryString="";
	boolean kontrol=false;

	ConnectionPool connectionPool = null;
	Connection connection = null;
	Statement statement = null;
	ResultSet resultSet = null;
	String sSQL = null;

	int rpid=-1;
	int cpid=-1;
	if(!campid.equals("null"))
		cpid=Integer.parseInt(campid);
	if(!recipid.equals("null"))
		rpid=Integer.parseInt(recipid);
	try {
		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);
		statement = connection.createStatement();

		int cust_id=0;

		if(!custid.equals("null"))
		{
			cust_id=Integer.parseInt(custid);
			kontrol=true;
		}
		else
		{
			String q="select cust_id from ajtk_push_customer WITH(NOLOCK) where private_key='"+custkey+"'";
			ResultSet sr= statement.executeQuery(q);
			if(sr.next())
			{
				cst=sr.getString(1);
				kontrol=true;
				System.out.println(kontrol);
			}
			cust_id=Integer.parseInt(cst);
		}



		if(kontrol)
		{

			// get data from PRODUCT_DATA for Tsoft
			if(isTsoft){
				int isAvaliable = 0;


				if(jsonObj.getBoolean("act_available")== true){
					isAvaliable = 1;
				}
				System.out.println("geldi");
				System.out.println(jsonObj);
				queryString = "INSERT INTO ajtk_web_link_activity (type_id,remote_ip,referer,user_agent,cookie_val,cust_id,push_recip_id,"+
						"push_camp_id,email_recip_id, token_id,img,ctgry_name,ctgry_id,brand, product_code, title,product_id,currency,price_sell,total_sale_price,is_avaliable, page_type, user_id_long, product_id_long , device_tpye) VALUES('1','"
						+uip+"','"+url_activite+"','"+useragent+"','"+cookie+"','"+cust_id+"','"+rpid+"','"+cpid+"','"+mail_recip_id+"','"+token
						+"','"+(String) jsonObj.get("act_image")+"','"+(String) jsonObj.get("act_category")+"','"+ (String) jsonObj.get("act_category_id") +"','"+(String) jsonObj.get("act_brand")  +"','"+ (String) jsonObj.get("act_product_code")
						+"','"+  (String) jsonObj.get("act_title") +"','"+  (String) jsonObj.get("act_id")  +"','"+ (String) jsonObj.get("act_currency") +"','"+ jsonObj.getDouble("act_price")  +"','"+  jsonObj.getDouble("act_total_sale_price") +"','"+isAvaliable+"','"+page_type
						+"','"+cookie.hashCode() + "','"+ ((String)jsonObj.get("act_id")).hashCode() + "' , '"+deviceStr+"')";
			
			}else{
			

				queryString = "INSERT INTO ajtk_web_link_activity (type_id,remote_ip,referer,user_agent,cookie_val,cust_id,push_recip_id,push_camp_id,email_recip_id, token_id, page_type, user_id_long , device_tpye) VALUES('1','"+uip+"','"+url_activite+"','"+useragent+"','"+cookie+"','"+cust_id+"','"+rpid+"','"+cpid+"','"+mail_recip_id+"','"+token+"','"+page_type+"','"+cookie.hashCode()+"' , '"+deviceStr+"')";
			
			}

			int sonuc = statement.executeUpdate(queryString);
			

		}


	} catch (Exception e) {

		System.out.println(queryString);
		e.printStackTrace();

	}
	finally
	{
		try {

			if (resultSet != null)
				resultSet.close();

			if (statement != null)
				statement.close();
			if (connection != null) {

				connection.close();

			}
		}catch (SQLException e) { /* ignored */}
	}


%> 