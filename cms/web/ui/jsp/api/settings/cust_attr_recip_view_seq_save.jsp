<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>

<%
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Headers", "x-requested-with, content-type");
	response.setContentType("application/x-www-form-urlencoded;charset=UTF-8");
	response.setHeader("Access-Control-Allow-Origin","https://cms.revotas.com:3001");
	response.setHeader("Access-Control-Allow-Credentials", "true");
	response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<%
String[] sVisibleAttrs = request.getParameterValues("vis");
	String[] sInvisibleAttrs = request.getParameterValues("invis");

// 1. Girdi Verilerini Logla
	if (sVisibleAttrs == null) {
		out.println("No visible attributes provided (sVisibleAttrs is null).");
	} else {
		out.println("Visible attributes: " + Arrays.toString(sVisibleAttrs));
	}

	if (sInvisibleAttrs == null) {
		out.println("No invisible attributes provided (sInvisibleAttrs is null).");
	} else {
		out.println("Invisible attributes: " + Arrays.toString(sInvisibleAttrs));
	}

	CustAttr ca = null;
	JsonArray fullAttr = new JsonArray();

// 2. Visible Attributes İşlemleri
	int l = (sVisibleAttrs == null) ? 0 : sVisibleAttrs.length;
	JsonArray visAttr = new JsonArray();
	for (int i = 0; i < l; i++) {
		try {
			JsonObject data = new JsonObject();
			out.println("Processing visible attribute: " + sVisibleAttrs[i]);

			
			ca = new CustAttr(cust.s_cust_id, sVisibleAttrs[i]);
			

			
			ca.s_recip_view_seq = String.valueOf(10 * (i + 1));
			ca.saveWithSync(); // Veri tabanı veya başka işlemler burada gerçekleşir
			

			// JSON güncellemesi
			data.put("Vis Display Name", ca.s_display_name);
			visAttr.put(data);
		} catch (Exception e) {
			out.println("ERROR: Exception while processing visible attribute: " + sVisibleAttrs[i]);
		}
	}

	fullAttr.put(visAttr);

// 3. Invisible Attributes İşlemleri
	l = (sInvisibleAttrs == null) ? 0 : sInvisibleAttrs.length;
	JsonArray invisAttr = new JsonArray();
	for (int i = 0; i < l; i++) {
		try {
			JsonObject data = new JsonObject();
			out.println("Processing invisible attribute: " + sInvisibleAttrs[i]);

			
			ca = new CustAttr(cust.s_cust_id, sInvisibleAttrs[i]);
			

			
			ca.s_recip_view_seq = null;
			ca.saveWithSync(); // Veri tabanı veya başka işlemler burada gerçekleşir
			

			// JSON güncellemesi
			data.put("Invis Display Name", ca.s_display_name);
			invisAttr.put(data);
		} catch (Exception e) {
			out.println("ERROR: Exception while processing invisible attribute: " + sInvisibleAttrs[i]);
		}
	}

	fullAttr.put(invisAttr);

// 4. Son JSON Çıktısını Logla
	out.println("Final JSON: " + fullAttr.toString());
	out.print(fullAttr.toString());


%>
