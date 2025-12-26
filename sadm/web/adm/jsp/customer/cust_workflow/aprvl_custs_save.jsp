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

AprvlCusts acs = new AprvlCusts();
AprvlCust ac = null;


for (Enumeration eTypeIds = BriteRequest.getParameterNames(request); eTypeIds.hasMoreElements();)
{
	ac = new AprvlCust();
	ac.s_cust_id = sCustId;
	ac.s_object_type = (String) eTypeIds.nextElement();

	logger.info(ac.s_object_type);

	if("cust_id".equals(ac.s_object_type)) continue;

	String[] sValues = BriteRequest.getParameterValues(request, ac.s_object_type);
	int l = ( sValues == null )?0:sValues.length;

	int nValue = 0;
	for (int i = 0; i < l; i++)
	{
		nValue += Integer.parseInt(sValues[i]);
		logger.info("i=" + i);
		logger.info("nValue=" + nValue);		
	}

	ac.s_aprvl_workflow_flag = String.valueOf(nValue);
	acs.add(ac);
}

logger.info(acs.toXmlNice());
acs.save();

// === === ===

String sSql =
	" DELETE scps_aprvl_cust" +
	" WHERE aprvl_workflow_flag=0" +
	" AND cust_id=" + sCustId;
	
BriteUpdate.executeUpdate(sSql);

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "aprvl_custs.jsp?cust_id=<%=sCustId%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
