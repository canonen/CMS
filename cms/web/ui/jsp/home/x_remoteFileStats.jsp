<%@page import="com.britemoon.cps.imc.Service"%>
<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

<%@ include file="../validator.jsp"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-9"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.net.*, java.io.*"%>

<%


	String nextLine;
	URL url = null;
	URLConnection urlConn = null;
	InputStreamReader  inStream = null;
	BufferedReader buff = null;
	
	String opt = request.getParameter("opt");	
	String cid = request.getParameter("custid");
    
	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, 227);
	service = (Service) services.get(0); 
	
	try{
	
	url= "http://" + service.getURL().getHost() + "/rrcp/imc/home/stats.jsp" + "?opt=" + opt + "&custid=" + cid;


          urlConn = url.openConnection();
          inStream = new InputStreamReader( 
          urlConn.getInputStream());
          buff= new BufferedReader(inStream);
        
			while (true) {
				nextLine =buff.readLine(); 
				
				if (nextLine !=null){
					out.print(nextLine);
				}
				else{
				   break;
				} 
			}
			
	} catch(MalformedURLException e){
		System.out.println("Please check the URL:" + e.toString() );
	} catch(IOException  e1){
			System.out.println("Can't read  from the Internet: "+ e1.toString() ); 
	}
%>