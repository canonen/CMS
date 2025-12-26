<%
	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");


    String requestUrl = "http://"+request.getRemoteAddr() + ":" + request.getRemotePort();
    String origin = request.getRequestURI();
    System.out.println(origin + " url2");
    response.setHeader("Access-Control-Allow-Origin", "http://dev.revotas.com:3001");
    response.setHeader("Access-Control-Allow-Credentials", "true");

    /*
    String tempUrl = new StringBuffer(request.getRequestURL()).toString();

    System.out.println(tempUrl+" mucahit");
    if(tempUrl.contains("dev.revotas.com")){
     System.out.println("mucahit1");
        response.setHeader("Access-Control-Allow-Origin", "http://dev.revotas.com:3001");
    }else if(tempUrl.contains("localhost:3001")){
     System.out.println("mucahit2");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3001");
    }else{
     System.out.println("mucahit3");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3001/");
    }
    response.setHeader("Access-Control-Allow-Credentials", "true");
    */

%>
