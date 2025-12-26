<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

<%@ include file="../validator.jsp"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ 
page import="java.io.BufferedReader,java.io.DataInputStream,java.io.FileInputStream,java.io.IOException,java.io.InputStreamReader,java.net.MalformedURLException,java.net.URL,java.util.ArrayList,java.util.List" 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css">
<script type="text/javascript" src="http://code.jquery.com/jquery-1.7.1.min.js"></script>
<script type="text/javascript" src="http://autobahn.tablesorter.com/jquery.tablesorter.min.js"></script>
<title>Sender Score</title>
<style>
	body {
		margin:10px;
	}
	.score {
		font-weight:bold;
		color:green;
	}
	
</style>
<script>
		$(document).ready(function() 
	    { 
	        $("#myTable").tablesorter(); 
	    } 
	); 
</script>
</head>
<body>
<table class="zebra-striped" id="myTable">
<thead>
<tr>
<th class="header">#</th>
<th class="yellow header">IP</th>
<th class="blue header">Customers</th>
<th class="green header headerSortUp">Reputation</th>
</tr>
</thead>
<tbody> 

<%
String url 	= "https://www.senderscore.org/lookup.php?lookup=";
URL blurl 	= null;
BufferedReader in = null;
String inputLine;
List<String> found = new ArrayList<String>();
List<String> params = new ArrayList<String>();
List<String> customers = new ArrayList<String>();

String lines;
FileInputStream fis =null;
DataInputStream dis =null;
BufferedReader breader =null;

try
{
	String linex;
	fis 	= new FileInputStream("C:/Revotas/cms/web/ui/jsp/score/wordlist.txt");
	dis 	= new DataInputStream(fis);
	breader = new BufferedReader(new InputStreamReader(dis));
	
	while ((linex = breader.readLine()) != null)
	{			 
		String[] lineContainer = linex.split("\t");
		
		params.add(lineContainer[1]);
		customers.add(lineContainer[0]);
	}
}
catch (Exception e) {
	System.out.println("---- Hata ---- wordlist.txt dosyasi bulunamadi.");
	e.printStackTrace();
} finally {
	fis.close();
	breader.close();
	dis.close();
}

int i = 0;
for (String str : params) {
	
	try 
	{
		blurl = new URL(url+str);
		
	} catch (MalformedURLException e) {
		
		System.out.println("URL is not valid!");
		out.println("URL is not valid.");
	}
	 
	try 
	{
		in = new BufferedReader(new InputStreamReader(blurl.openStream()));
		
		while ((inputLine = in.readLine()) != null)
		{
			
			if(inputLine.indexOf("senderscore_number") != -1)
			{						
				String subs = inputLine.substring(171, 174);
				
				if(subs.indexOf("<") != -1)
				{
					subs = subs.substring(0 , 2);
				}
			
				out.println("<tr>");
				out.println("<td>"+(i+1)+"</td>");
				out.println("<td>"+str+"</td>");
				out.println("<td>"+customers.get(i).toString()+"</td>");
				out.println("<td><button class='btn success'>"+subs+"</button></td>");
				out.println("</tr>");
				break;
			}
		}				
		
	} catch (IOException e) {

		System.out.println("Could not read from URL "+url);
	}
	finally {
		in.close();
	}
	
	i++;
}
%>
</tbody>
</table>
</body>
</html>