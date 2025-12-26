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

String sUserId = BriteRequest.getParameter(request, "user_id");
User user = new User(sUserId);

AccessMasks ams = new AccessMasks();
AccessMask am = null;
int iMask = 0;

for (Enumeration eTypeIds = BriteRequest.getParameterNames(request); eTypeIds.hasMoreElements();)
{
	am = new AccessMask();
	am.s_user_id = user.s_user_id;
	am.s_type_id = (String) eTypeIds.nextElement();

	if(!"user_id".equals(am.s_type_id))
	{
		String[] sValues = BriteRequest.getParameterValues(request, am.s_type_id);
		int l = ( sValues == null )?0:sValues.length;

		iMask = 0;
		for (int i = 0; i < l; i++)
		{
			iMask = iMask | Integer.parseInt(sValues[i]);
		}

		am.s_mask = String.valueOf(iMask);
		ams.add(am);
	}
}

ams.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "access_masks.jsp?user_id=<%=user.s_user_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
