<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.imc.*,
			java.util.*,java.util.Date,
			java.text.DateFormat,
			java.sql.*,java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	// === === ===

	EmailListItems elis = new EmailListItems();
	String sEmail = null;
	
	for( int k = 0; k < 9999; ++k )
	{
		sEmail = request.getParameter("f" + k);
		if( sEmail == null ) break;		
		sEmail = sEmail.trim();
		if(sEmail.equals("")) continue;
		sEmail = new String(sEmail.getBytes("ISO-8859-1"), "UTF-8");
		EmailListItem eli = new EmailListItem();		
		eli.s_email = sEmail;
		eli.s_email_type_id = request.getParameter("t" + k);
		elis.add(eli);
	}

	// === === ===

	EmailList el = new EmailList();

	String isCloned = BriteRequest.getParameter(request,"clone");
	if (isCloned == null) isCloned = "false";
	if ("false".equals(isCloned))
	{
		el.s_list_id = BriteRequest.getParameter(request,"listID");
	}
	
	el.s_cust_id = cust.s_cust_id;
	el.s_list_name = BriteRequest.getParameter(request,"name");
	el.s_type_id = BriteRequest.getParameter(request,"type");
	el.s_status_id = BriteRequest.getParameter(request,"status_id");
	el.m_EmailListItems = elis;
	el.save();
	

	// === === ===

	boolean bRcpSyncErr = false;

	try
	{
		String sRequest = el.toXml();
		String sResponse = Service.communicate(ServiceType.RQUE_LIST_SETUP, cust.s_cust_id, sRequest);
		XmlUtil.getRootElement(sResponse);
		out.print(sResponse);
	}
	catch(Exception ex)
	{
		bRcpSyncErr = true;
	}

	// === === ===

	String listID = el.s_list_id;
	String listType = el.s_type_id;
	if (listType.equals("6")) listType = "4";
%>
