<%
    response.setHeader("Expires", "0");
    response.setHeader("Pragma", "no-cache"); 
    response.setHeader("Cache-Control", "no-store, no-cache");
    response.setHeader("Access-Control-Allow-Origin", "http://cms.revotas.com:3001");
    response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    response.setHeader("Access-Control-Allow-Credentials", "true");
%>
