<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>
<%
String sOriginalCustId = BriteRequest.getParameter(request, "original_cust_id");

Customer original = new Customer();
original.s_cust_id = sOriginalCustId;

if(original.retrieve() < 1)
{
	out.println("Invalid original customer id");
	return;
}

String sHayattSettings = BriteRequest.getParameter(request, "hayatt_settings");
if(sHayattSettings == null)
{
	out.println("No customers specified");
	return;
}
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">	
	<SCRIPT>
		function go2cust(nCustId)
		{
			var sUrl = "../cust_edit_frame.jsp?cust_id=" + nCustId;
			parent.location.href = sUrl;
		}
	</SCRIPT>
</HEAD>
<BODY>
New customers:<BR>
<%
	Customer clone =
		CustRetrieveUtil.retrieve4clone(
			sOriginalCustId,true,true,true,true,true,true,true,true,true,true,true,true,true,true);
	
	String sCustName = clone.s_cust_name;
	String sLoginName = clone.s_login_name;	
	String sSuffix = null;
	
	int n = 0;
	BufferedReader br = new BufferedReader(new StringReader(sHayattSettings));
			
	for(String sLine = br.readLine(); sLine != null; sLine = br.readLine())
	{
		if(sLine.trim().equals("")) continue;
		n++;		

		sSuffix = "_clone_" + new java.util.Date().getTime();

		clone.s_cust_id = null;
		clone.s_cust_name = sCustName + sSuffix;
		clone.s_login_name = sLoginName + sSuffix;
		
		fixIds(clone);
				
		clone.save();
		
		// === === ===
		
		String[] sSettings = sLine.split("\t");
		for(int i = 0; i < sSettings.length; i++)
		{
			if(sSettings[i]==null) continue;
			if(sSettings[i].trim().equals("")) sSettings[i] = null;
		}
		
		// === === ===
				
		String sSpiritCode = sSettings[0].toLowerCase();
		createAttributes(clone.s_cust_id, sSpiritCode);

		doCustSpecificSettings(clone, sSettings);
%>
<H5><A href="javascript:void(0);" onclick="go2cust(<%=clone.s_cust_id%>);">
	<%=n%>. <%=HtmlUtil.escape(sSettings[1])%>
</A></H5>
<BR>
<%
		out.flush();
	}
%>

</BODY>
</HTML>

<%@ include file="cust_clone_functions.inc" %>

<%!
	private static void doCustSpecificSettings(Customer clone, String[] sSettings) throws Exception
	{
		Customer cust = new Customer(clone.s_cust_id);
		cust.s_cust_name = sSettings[1];
		cust.s_login_name = sSettings[2];		
		cust.save();

		// === === ===
		
		CustAddr ca = new CustAddr();

		ca.s_cust_id = clone.s_cust_id;
		ca.s_address1 = sSettings[3];
		ca.s_address2 = sSettings[4];
		ca.s_city = sSettings[5];
		ca.s_state = sSettings[6];
		ca.s_zip = sSettings[7];
		ca.s_country = sSettings[8];
		ca.s_phone = null;
		ca.s_fax = null;
		
		ca.save();
			
		// === === ===
		
		if(clone.m_Users == null) return;
		
		User u1 = null;
		User u2 = null;		
		
		Enumeration e = clone.m_Users.elements();
		if(e.hasMoreElements()) u1 = (User)e.nextElement();
		if(e.hasMoreElements()) u2 = (User)e.nextElement();			

		// === === ===
		
		if(u1 == null) return;

		User u = new User();

		u.s_user_id = u1.s_user_id;
		u.s_cust_id = u1.s_cust_id;
		u.s_status_id = u1.s_status_id;
					
		u.s_user_name = sSettings[9];
		u.s_last_name = null;		
		
		u.s_phone = sSettings[10];
		u.s_email = sSettings[11];
		
		u.s_login_name = sSettings[12];
		u.s_password = sSettings[13];
		u.s_position = "unknown";
		u.s_descrip = null;

		fixUserName(u);
		
		u.save();
		
		// === === ===

		if(u2 == null) return;
	
		try
		{
			u = new User();

			u.s_user_id = u2.s_user_id;
			u.s_cust_id = u2.s_cust_id;
			u.s_status_id = u2.s_status_id;
						
			u.s_user_name = sSettings[14];
			u.s_last_name = null;
			u.s_phone = sSettings[15];
			u.s_email = sSettings[16];
			
			u.s_login_name = sSettings[17];
			u.s_password = sSettings[18];
			u.s_position = "unknown";
			u.s_descrip = null;
			
			fixUserName(u);
					
			u.save();
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ", ex);
		}
	}

	private static void fixUserName(User u)
	{
		if(u.s_user_name == null) return;

		int n = u.s_user_name.indexOf(" ");
		if(n < 0) return;

		u.s_last_name = u.s_user_name.substring(n).trim();
		u.s_user_name = u.s_user_name.substring(0,n).trim();		
	}
	
	private static void createAttributes(String sCustId, String sSpiritCode) throws Exception
	{
	// Hotel file attributes will be saved to each property so that the attribute name is prefixed with the hotel_id.
		Attributes attrs = new Attributes();
		
		attrs.add(createAttribute(sCustId, sSpiritCode, "_email_optin", DataType.INTEGER));
		
		attrs.add(createAttribute(sCustId, sSpiritCode, "_email_optin_type", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_hotel_id", DataType.VARCHAR_255));

		attrs.add(createAttribute(sCustId, sSpiritCode, "_cstm_pref_1", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_cstm_pref_2", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_cstm_ind", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_sub_src", DataType.VARCHAR_255));
		
		attrs.add(createAttribute(sCustId, sSpiritCode, "_alt_db", DataType.INTEGER));
		
		// reservation file attributes will be saved to each property so that the attribute name is prefixed with the hotel_id.
		attrs.add(createAttribute(sCustId, sSpiritCode, "_reservation_number", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_departure_date", DataType.DATETIME));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_cancel_reservation", DataType.INTEGER));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_num_adults", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_num_children", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_reservation_type", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_reservation_activity_date", DataType.DATETIME));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_reservation_brand", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_reservation_hotel_id", DataType.VARCHAR_255));
		attrs.add(createAttribute(sCustId, sSpiritCode, "_reservation_hotel_name", DataType.VARCHAR_255));	
			
		attrs.save();
	}

	private static Attribute createAttribute(String sCustId, String sSpiritCode, String sSuffix, int nDatatype)
	{
		Attribute attr = new Attribute();

		attr.s_attr_id = null;

		attr.s_cust_id = sCustId;
		attr.s_attr_name = sSpiritCode + sSuffix;
		attr.s_type_id = String.valueOf(nDatatype);
		attr.s_scope_id = String.valueOf(AttrScope.PUBLIC);

		attr.s_descrip = null;
		attr.s_value_qty = null;
		attr.s_internal_flag = null;

		// === === ===

		CustAttr ca = new CustAttr();
		
		ca.s_attr_id = null;
		ca.s_cust_id = attr.s_cust_id;
		
		ca.s_display_name = attr.s_attr_name;
		
		ca.s_display_seq = "1000";
		ca.s_fingerprint_seq = null;
		ca.s_sync_flag = null;
		ca.s_hist_flag = null;
		ca.s_newsletter_flag = null;
		
		// === === ===

		CustAttrs cas = new CustAttrs();
		cas.add(ca);
		attr.m_CustAttrs = cas;

		// === === ===

		return attr;
	}
%>
