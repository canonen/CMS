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

String sHowMany = BriteRequest.getParameter(request, "how_many");
int nHowMany = Integer.parseInt(sHowMany);

// === === ===

String	sCloneCustAddr = request.getParameter("clone_cust_addr");
String	sCloneCustUiSettings = request.getParameter("clone_cust_ui_settings");
String	sCloneCustPartner = request.getParameter("clone_cust_partner");
String	sCloneCustModInst = request.getParameter("clone_cust_mod_inst");
String	sCloneVanityDomain = request.getParameter("clone_vanity_domain");
String	sCloneUniqueIds = request.getParameter("clone_unique_ids");
String	sCloneUser = request.getParameter("clone_user");
String	sCloneAccessMask = request.getParameter("clone_access_mask");
String	sCloneCustAttr = request.getParameter("clone_cust_attr");
String	sCloneUnsubMsg = request.getParameter("clone_unsub_msg");
String	sCloneFromAddress = request.getParameter("clone_from_address");
String	sCloneSendParam = request.getParameter("clone_send_param");
String	sCloneCustFeature = request.getParameter("clone_cust_feature");
String	sCloneAprvlCust = request.getParameter("clone_aprvl_cust");

// === === ===

boolean bCloneCustAddr = ( sCloneCustAddr != null );
boolean bCloneCustUiSettings = ( sCloneCustUiSettings != null );
boolean bCloneCustPartner = ( sCloneCustPartner != null );
boolean bCloneCustModInst = ( sCloneCustModInst != null );
boolean bCloneVanityDomain = ( sCloneVanityDomain != null );
boolean bCloneUniqueIds = ( sCloneUniqueIds != null );
boolean bCloneUser = ( sCloneUser != null );
boolean bCloneAccessMask = ( sCloneAccessMask != null );
boolean bCloneCustAttr = ( sCloneCustAttr != null );
boolean bCloneUnsubMsg = ( sCloneUnsubMsg != null );
boolean bCloneFromAddress = ( sCloneFromAddress != null );
boolean bCloneSendParam = ( sCloneSendParam != null );
boolean bCloneCustFeature = ( sCloneCustFeature != null );
boolean bCloneAprvlCust = ( sCloneAprvlCust != null );

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
			sOriginalCustId,
			bCloneCustAddr,
			bCloneCustUiSettings,
			bCloneCustPartner,
			bCloneCustModInst,
			bCloneVanityDomain,
			bCloneUniqueIds,
			bCloneUser,
			bCloneAccessMask,
			bCloneCustAttr,
			bCloneUnsubMsg,
			bCloneFromAddress,
			bCloneSendParam,
			bCloneCustFeature,
			bCloneAprvlCust);
	
	String sCustName = clone.s_cust_name;
	String sLoginName = clone.s_login_name;	
	String sSuffix = null;
		
	for(int i=0; i < nHowMany; i++)
	{
		sSuffix = "_clone_" + new java.util.Date().getTime();

		clone.s_cust_id = null;
		clone.s_cust_name = sCustName + sSuffix;
		clone.s_login_name = sLoginName + sSuffix;

		fixIds(clone);

		clone.save();
%>
<H5><A href="javascript:void(0);" onclick="go2cust(<%=clone.s_cust_id%>);">
	<%=(i+1)%>. <%=HtmlUtil.escape(clone.s_cust_name)%>
</A></H5>
<BR>
<%
		out.flush();
	}
%>

</BODY>
</HTML>

<%@ include file="cust_clone_functions.inc" %>