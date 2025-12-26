<%@  page language="java" 
              import="java.util.*,
			  com.britemoon.*,
			  com.britemoon.cps.imc.*"
	contentType="text/html;charset=UTF-8"
%>
 <%
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
 %>
 <%
	String cust_id = request.getParameter("cust_id");
	if(cust_id == null)
		return;
	Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust_id);
    service = (Service) services.get(0);
	out.print(service.getURL().getHost());

 %>