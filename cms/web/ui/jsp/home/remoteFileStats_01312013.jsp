<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

<%@ include file="../validator.jsp"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-9"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.net.*, java.io.*" %>
<%
	String nextLine;
    URL url = null;
    URLConnection urlConn = null;
    InputStreamReader  inStream = null;
    BufferedReader buff = null;
	
	String opt = request.getParameter("opt");	
	String cid = request.getParameter("custid");
    
	try{
          url  = new URL("http://rcp1.revotas.com/rrcp/imc/home/stats.jsp?opt="+opt+"&custid="+cid);
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