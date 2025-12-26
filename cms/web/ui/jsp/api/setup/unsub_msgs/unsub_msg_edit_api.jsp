<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.adm.*"
	import="com.britemoon.cps.ctm.WebUtils"
	import="java.sql.*,java.io.*"
	import="javax.servlet.*"
	import="javax.servlet.http.*"
	import="org.xml.sax.*"
	import="javax.xml.transform.*"
	import="javax.xml.transform.stream.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%!
	static Logger logger = null;
%>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%@ include file="../../fixTurkishCharacters.jsp"%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}


	JsonArray jsonArray = new JsonArray();

	JsonObject dataUnsub = new JsonObject();
	JsonObject dataAttr = new JsonObject();

	String UnsubMsgID = request.getParameter("msg_id");
	if (UnsubMsgID == null){
		out.print("msg_id is required");
		return;
	}

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	String msgName="";
	String UnsubMsgHTML="";
	String UnsubMsgText="";
	String firstPers="";

	String htmlPersonals = "";
	String htmlCurPers = "";
	String jsPersonals = "";
	String jsSubmitPers = "";

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		boolean isDisable = false;
		boolean isInUse = false;

		if (UnsubMsgID!=null)
		{
			UnsubMsg unSubObj = new UnsubMsg(UnsubMsgID);
			JsonObject data = new JsonObject();

			msgName = unSubObj.s_msg_name;
			UnsubMsgHTML = unSubObj.s_html_msg;
			UnsubMsgText = unSubObj.s_text_msg;

			data.put("msg_id", unSubObj.s_msg_id);
			data.put("msg_name", fixTurkishCharacters2(msgName));
			data.put("html_msg", fixTurkishCharacters2(UnsubMsgHTML));
			data.put("text_msg", fixTurkishCharacters2(UnsubMsgText));
			dataUnsub.put("data_unsub", data);
			jsonArray.put(dataUnsub);

			if (UnsubMsgHTML == null) UnsubMsgHTML = "";
			if (UnsubMsgText == null) UnsubMsgText = "";

		} else {
			msgName = "New Message";
		}

		//Personalization
		String attrName,attrDisplayName,tmp,defaultValue = "",attrID;
		int i,j;
		rs = stmt.executeQuery(""+
			"SELECT c.attr_id, a.attr_name, c.display_name " +
			"FROM ccps_cust_attr c, ccps_attribute a " +
			"WHERE c.cust_id = "+cust.s_cust_id+" AND c.display_seq IS NOT NULL " +
			"AND c.attr_id = a.attr_id " +
			"ORDER BY display_seq");
		while (rs.next()) {
			JsonObject data = new JsonObject();
			attrID = rs.getString(1);
			attrName = rs.getString(2);
			attrDisplayName = new String(rs.getBytes(3),"UTF-8");
			if (firstPers.length() == 0) firstPers = attrName;
			htmlPersonals += "<option value="+attrName+">"+attrDisplayName+"</option>\n";

			//Scan the contents for Personalization
			String allConts = UnsubMsgText + UnsubMsgHTML;
			if (allConts != null && allConts.length() != 0) {
				i = allConts.indexOf("!*"+attrName+";");
				if (i != -1) {
					tmp = allConts.substring(i);
					j = tmp.indexOf("*!");
					if (j != -1) {
						defaultValue = tmp.substring(3+attrName.length(),j);
						htmlCurPers += "<tr><td>"+attrDisplayName+"</td>\n" +
									   "<td><input type=text name=curDefault"+attrID+" value=\""+defaultValue+"\">\n";
						jsPersonals += "if (attrID == "+attrID+") {\n" +
									   "	newDefault = FT.curDefault"+attrID+".value;\n" +
									   "	attrName = '"+attrName+"';\n}\n";
						jsSubmitPers += "scanContentForPers("+attrID+");\n";
					}
				}
			}
			data.put("attr_id", attrID);
			data.put("attr_name", fixTurkishCharacters(attrName));
			data.put("display_name", fixTurkishCharacters(attrDisplayName));
			data.put("defaultValue", defaultValue);
			data.put("htmlCurPers", jsPersonals);
			data.put("jsPersonals", jsPersonals);
			data.put("jsSubmitPers", jsSubmitPers);
			dataAttr.put("data_attr", data);
			jsonArray.put(dataAttr);

		}
		if (htmlCurPers.length() == 0) htmlCurPers = "<tr><td colspan=2>None</td></tr>\n";

		out.println(jsonArray);
		
	} catch(Exception ex)	{
		ErrLog.put(this,ex,"unsub_msg_new.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

%>