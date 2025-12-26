<%@ page
	import="java.util.*,
				 java.io.File,
				java.util.Date,
				java.text.SimpleDateFormat,
				 java.lang.Exception"%>
<%@page contentType="application/json; charset=UTF-8"%>
<%@ page isThreadSafe="false"%>

<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONString"%>

<%
	response.setHeader("Access-Control-Allow-Origin", "*");
	// response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
	// response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>

<%!String getSizeString(float sizeInBytes) {
		if (sizeInBytes < 1024)
			return sizeInBytes + " Bytes";
		else if (sizeInBytes < 1024 * 1024) {
			return sizeInBytes / 1024 + " KB";
		} else {
			return sizeInBytes / 1024 * 1024 + " MB";
		}
	}%>
<%
	String name = null;
	String Cust_id = request.getParameter("cust_id");

	int MAXSIZE = 1024 * 1024 * 1;

	String message;
	JSONObject json = new JSONObject();
	JSONArray data = new JSONArray();
    json.put("templates", data);

    String[] pathnames;
    String DOMAIN_URL = "https://cms.revotas.com/cms/ui/smartwidgets/newui/templates";
	String path ="C:/Revotas/cms/web/ui/smartwidgets/newui/templates/";
    File f = new File(path);
    try {
        pathnames = f.list();
        for (String pathname : pathnames) {
            data.put(DOMAIN_URL + "/" + pathname);
        }
    } catch(Exception e) {
        System.out.println("Folder not found");
    }
    out.print(json.toString());
    out.flush();
%>

