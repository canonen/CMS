<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
			org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
%>

<%
	JsonArray jsonArray = new JsonArray();
	String sAction = BriteRequest.getParameter(request, "a");
	if(sAction == null) sAction = "queue";

	String sFilterId = BriteRequest.getParameter(request, "filter_id");
	if(sFilterId == null) return;

	FilterStatDetails csds = new FilterStatDetails();
	csds.s_filter_id = sFilterId;
	csds.retrieve();

	String sRecipType = "";
	String stepDesc = "";

	if ("queue".equals(sAction))
	{
		stepDesc = "Queued Count Details";
	}
	else
	{
		stepDesc = "Calculated Recipient Statistics";
	}

	if(csds.size() == 0) {
		JsonObject json = new JsonObject();
		json.put("error", "A detailed break down of the number of queued recipients is unavailable.");
		out.print(json.toString());
		return;
	}else {
		String sClassAppend = "";
		int iCount = 0;

		String sName = "";
		String sValue = "";

		String oldName = "";
		String oldValue = "";
		String appExp = "Export";
		boolean showExp = false;

		FilterStatDetail csd = null;
		for (Enumeration e = csds.elements() ; e.hasMoreElements() ;)
		{
			JsonObject json = new JsonObject();
			csd = (FilterStatDetail)e.nextElement();

			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";

			iCount++;

			oldName = sName;
			oldValue = sValue;

			sName = csd.s_detail_name;
			sValue = csd.s_integer_value;

			if(sName.contains("print")){
				sName="Non-Sms recipients";
			}
			if(sName.contains("Print")){
				sName="Total Sms Recipients in Target Group";
			}

			if ( (sName.equals("Unsubscribe Exclusions")) || (sName.equals("Ineligible Recipients")) || (sName.equals("Bounceback Exclusions"))  )
			{
				if (sName.equals("Bounceback Exclusions"))
					sRecipType = "TgtBBack";
				if (sName.equals("Unsubscribe Exclusions"))
					sRecipType = "TgtUnsub";
				if (sName.equals("Ineligible Recipients"))
					sRecipType = "TgtIneligible";
			}else {
				sRecipType = "";
			}
			json.put("name", sName);
			json.put("value", sValue);
			json.put("classAppend", sClassAppend);
			json.put("recipType", sRecipType);
			json.put("stepDesc", stepDesc);
			jsonArray.put(json);
		}

	}

	out.print(jsonArray.toString());
%>

