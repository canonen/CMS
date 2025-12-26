<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
<script language="javascript">
function redireccionar() {
	setTimeout("location.href='campaigns.jsp'", 5000);
}
</script>
</head>
<body onload="redireccionar()">
	
<%
String appendText 	= "";
String campid  		= "";

if(request.getParameter("campid") != null)
{
	campid = request.getParameter("campid");
}

if(request.getParameter("type") != null)
{
	String type = request.getParameter("type");

	if(type.equals("facebook"))
	{
		if(request.getParameter("rs") != null)
		{
			String rs = request.getParameter("rs");

			if(rs.equals("database_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign has been published but we could not save it to database.</div>";
			}
			else if(rs.equals("publish_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign has NOT been published but it was saved to database.</div>";
				appendText += "<div>Click <a href='newcampaign.jsp?type="+type+"&camp_id="+campid+"'>here</a> to edit.</div>";
			}
			else if(rs.equals("publish_database_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign has NOT been published and we could not save it to database.</div>";
			}
			else if(rs.equals("saved"))
			{
				appendText += "<div>Your <b>"+type+"</b> campaign was saved.</div>";
			}
			else if(rs.equals("published_saved"))
			{
				appendText += "<div>Your <b>"+type+"</b> campaign was saved and published.</div>";
				appendText += "<div>Click <a href='newcampaign.jsp?type="+type+"&camp_id="+campid+"'>here</a> to edit.</div>";
			} 
			else if(rs.equals("delete_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign could not be deleted.</div>";
			} 
			else if(rs.equals("delete_done"))
			{
				appendText += "<div>Your <b>"+type+"</b> campaign was deleted.</div>";
			} 
			else {
				appendText += "<div>An unknown error occurred.</div>";
			}
		} 
		else
		{
			appendText += "<div>Could not categorize this error.</div>";
		}		
	}
	else if(type.equals("twitter"))
	{
		if(request.getParameter("rs") != null)
		{
			String rs = request.getParameter("rs");

			if(rs.equals("database_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign has been published but we could not save it to database.</div>";
			}
			else if(rs.equals("publish_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign has NOT been published but it was saved to database.</div>";
				appendText += "<div>Click <a href='newcampaign.jsp?type="+type+"&camp_id="+campid+"'>here</a> to edit.</div>";
			}
			else if(rs.equals("publish_database_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign has NOT been published and we could not save it to database.</div>";
			}
			else if(rs.equals("saved"))
			{
				appendText += "<div>Your <b>"+type+"</b> campaign was saved.</div>";
			}
			else if(rs.equals("published_saved"))
			{
				appendText += "<div>Your <b>"+type+"</b> campaign was saved and published.</div>";
				appendText += "<div>Click <a href='newcampaign.jsp?type="+type+"&camp_id="+campid+"'>here</a> to edit.</div>";
			} 
			else if(rs.equals("delete_error"))
			{
				appendText += "<div>Error occurred. Your <b>"+type+"</b> campaign could not be deleted.</div>";
			} 
			else if(rs.equals("delete_done"))
			{
				appendText += "<div>Your <b>"+type+"</b> campaign was deleted.</div>";
			} 
			else {
				appendText += "<div>An unknown error occurred.</div>";
			}
		} 
		else
		{
			appendText += "<div>Could not categorize this error.</div>";
		}	
	}
	else {
		appendText += "<div>Could not categorize this error.</div>";
	}
}
%>
<div style="text-align:center;font-size:12px;font-family:Arial;line-height:20px;padding:15px;">
	<div><%=appendText%></div>
	<div>You will be redirected automatically to Campaign list in 5 seconds.</div>
	<div>If redirection takes too long or you do not want to wait please click <a href="campaigns.jsp">here</a></div>
</div>
</body>
</html>