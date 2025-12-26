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

String sCustId = BriteRequest.getParameter(request, "cust_id");

Customer cust = new Customer(sCustId);

CustModInstServices cmiss = new CustModInstServices();
CustModInstService cmis = null;

String[] sIsNews = BriteRequest.getParameterValues(request, "is_new");
String[] sModInstIds = BriteRequest.getParameterValues(request, "mod_inst_id");
String[] sServiceTypeIds = BriteRequest.getParameterValues(request, "service_type_id");
String[] sProtocols = BriteRequest.getParameterValues(request, "protocol");
String[] sPorts = BriteRequest.getParameterValues(request, "port");
String[] sPaths = BriteRequest.getParameterValues(request, "path");

String sIsNew = null;
String sModInstId = null;
String sServiceTypeId = null;
String sProtocol = null;
String sPort = null;
String sPath = null;

int l = ( sModInstIds == null )?0:sModInstIds.length;

for (int i = 0; i < l; i++)
{
	sIsNew = sIsNews[i];
	sModInstId = sModInstIds[i];
	sServiceTypeId = sServiceTypeIds[i];
	sProtocol = sProtocols[i];
	sPort = sPorts[i];
	sPath = sPaths[i];

	sProtocol = ("".equals(sProtocol))?null:sProtocol;
	sPort = ("".equals(sPort))?null:sPort;
	sPath = ("".equals(sPath))?null:sPath;

	if(("no".equals(sIsNew)) && (sProtocol == null) && (sPort == null) || (sPath == null))
	{
		String sSql = 
			" DELETE sadm_cust_mod_inst_service" +
			" WHERE cust_id = " + sCustId  +
			" AND mod_inst_id = " + sModInstId +
			" AND service_type_id = " + sServiceTypeId;

		BriteUpdate.executeUpdate(sSql);
		continue;
	}

	if(("no".equals(sIsNew)) || (sProtocol != null) || (sPort != null) || (sPath != null))
	{
		cmis = new CustModInstService();
		cmis.s_cust_id = cust.s_cust_id;
		cmis.s_mod_inst_id = sModInstId;
		cmis.s_service_type_id = sServiceTypeId;
		cmis.s_protocol = sProtocol;
		cmis.s_port = sPort;
		cmis.s_path = sPath;
		cmiss.add(cmis);
	}
}

cmiss.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_mod_inst_services.jsp?cust_id=<%=cust.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
