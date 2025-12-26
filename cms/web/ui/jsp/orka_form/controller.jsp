<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.britemoon.*" %>
<%@ page import="com.britemoon.cps.*" %>
<%@ page import="com.britemoon.cps.imc.*" %>
<%@ page import="com.britemoon.cps.que.*" %>
<%@ page import="com.britemoon.cps.ctl.*" %>
<%@ page import="java.util.*,java.sql.*" %>
<%@ page import="java.net.*,java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
	String firstName = request.getParameter("firstname");
	String lastName  = request.getParameter("lastname");
	String fullName = firstName + " " + lastName; 
	
	String gsmccode = request.getParameter("gsmccode");
	String gsmext = request.getParameter("gsmext");
	String gsmno = request.getParameter("gsmno");
	String gsmNumber = gsmccode + " " + gsmext + " " + gsmno;
	
	String dobd = request.getParameter("dobd");
	String dobm = request.getParameter("dobm");
	String doby = request.getParameter("doby");
	String dateOfBirth = doby + "-" + dobm + "-" + dobd;
	
	String email = request.getParameter("email");
	String cityName = request.getParameter("cityName");
	String town = request.getParameter("town");
	String occupation = request.getParameter("occupation");
	String sShop = request.getParameter("sShop");
	String gender = request.getParameter("gender");
	
	URL u = new URL("http://orkagroup.rvs0.net/frm/sv/XMLSubmitForm");
	
	String xml = "<subscription_data>";
	xml += "<version>415</version>";
	xml += "<form_id>1149025</form_id>";
	xml += "<customer_id>228</customer_id>";
	xml += "<subscriber>";
	xml += "<attribute>";
	xml += "<attr_name>revo_campaign_type</attr_name>";
	xml += "<attr_value><![CDATA[new_member]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>revo_active_flag</attr_name>";
	xml += "<attr_value><![CDATA[1]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>emailgeneric</attr_name>";
	xml += "<attr_value><![CDATA["+email+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>pnmfull</attr_name>";
	xml += "<attr_value><![CDATA["+fullName+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>gender</attr_name>";
	xml += "<attr_value><![CDATA["+gender+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>gsm_no</attr_name>";
	xml += "<attr_value><![CDATA["+gsmNumber+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>iL</attr_name>";
	xml += "<attr_value><![CDATA["+cityName+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>ilce</attr_name>";
	xml += "<attr_value><![CDATA["+town+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>date_of_birth</attr_name>";
	xml += "<attr_value><![CDATA["+dateOfBirth+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>shop_name</attr_name>";
	xml += "<attr_value><![CDATA["+sShop+"]]></attr_value>";
	xml += "</attribute>";
	xml += "<attribute>";
	xml += "<attr_name>occupation</attr_name>";
	xml += "<attr_value><![CDATA["+occupation+"]]></attr_value>";
	xml += "</attribute>";
	
	ConnectionPool		cp				= null;
	Connection			conn 			= null;
	Statement			stmt			= null;
	ResultSet			rs				= null;
	
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("controller.jsp");
		stmt = conn.createStatement();

		rs = stmt.executeQuery("select top 1 * from czx_shopping_codes where status = 0");
		
		int id = 0;
		String code = "";
		
		while (rs.next())
		{
			id   = rs.getInt("id");
			code = rs.getString("code");
		}
		
		xml += "<attribute>";
		xml += "<attr_name>discount_code</attr_name>";
		xml += "<attr_value><![CDATA["+code+"]]></attr_value>";
		xml += "</attribute>";
		xml += "</subscriber>";
		xml += "</subscription_data>";
		
		try
		{
			HttpURLConnection uc = (HttpURLConnection)u.openConnection();
			uc.setRequestMethod("POST");
			uc.setDoOutput(true);
			uc.setDoInput(true);
			uc.setRequestProperty("Content-Type", "text/xml; charset=\"utf-8\"");
			uc.setAllowUserInteraction(false);
			
			DataOutputStream dstream = new DataOutputStream(uc.getOutputStream());
			dstream.writeBytes(xml);
			dstream.close();			
			
			InputStream in = uc.getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(in));
			StringBuffer buf = new StringBuffer();
			String line;
			while ((line = r.readLine())!=null) {
			buf.append(line);
			}
			in.close();
			
			String updateStatement = "UPDATE czx_shopping_codes SET status = 1, fullname = ?, email = ?, shop = ?, dateModified = ?  WHERE id = " +id;
			
			PreparedStatement pstmt 	= conn.prepareStatement(updateStatement);
			
			pstmt.setString(1, fullName);
			pstmt.setString(2, email);
			pstmt.setString(3, sShop);
			pstmt.setTimestamp(4, new java.sql.Timestamp(new java.util.Date().getTime()));
			
			pstmt.executeUpdate();
			
			try { if (stmt != null) stmt.close(); if (pstmt != null) pstmt.close(); }
			catch(Exception e) {}
			if (conn != null) cp.free(conn);
			
			response.sendRedirect("form.jsp?send=true");
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
			
		}		
	} 
	catch(Exception ex)
	{ 
		throw new Exception(ex);
	}
%>