<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.cnt.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.io.*"
	import="javax.servlet.*"
	import="javax.servlet.http.*"
	import="org.xml.sax.*"
	import="javax.xml.transform.*"
	import="javax.xml.transform.stream.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if (logger == null) {
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	boolean HYATTUSER = (ui.n_ui_type_id == UIType.HYATT_USER);
	if (!can.bRead && !HYATTUSER){
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	String contID = request.getParameter("cont_id");
	if (contID == null) {
		response.sendRedirect("../camp/camp_list.jsp");
		return;
	}
	String pv_test_type_id = HtmlUtil.escape(request.getParameter("pv_test_type_id"));
	if (pv_test_type_id == null) {
		pv_test_type_id = "1";
	}

	String button_label = "Preview Delivery Track test"; 
	String deliverability_list_type = "10,11,12,13,14";
	if (pv_test_type_id.equals("2")) {
		button_label = "Preview eContent Scorer test";
		deliverability_list_type = "8";
	}
	else if (pv_test_type_id.equals("3")) {
		button_label = "Preview eDesign Optimizer test";
		deliverability_list_type = "9";
	}
	String originCampID = request.getParameter("origin_camp_id");
	String from = HtmlUtil.escape(request.getParameter("from"));
	String subj = HtmlUtil.escape(request.getParameter("subj"));
	
	Content cont = new Content();
	cont.s_cont_id = contID;
	if (cont.retrieve() < 1) {
		throw new Exception("Invalid content. Content does not exist.");	
	}
	ContBody cont_body = new ContBody(contID);
	String contName = cont.s_cont_name;
	String textPart = cont_body.s_text_part;
	String htmlPart = cont_body.s_html_part;

	if (textPart == null) textPart = "";
	if (htmlPart == null) htmlPart = "";
	
	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	
	String htmlFormulas = "";
	String htmlValues = "";
	String step3Label = "";
	String step3Html = "";
	String step4Label = "";
	String step4Html = "";
	String filterIDs = "";
	boolean oneInternalField = false;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
		
		Hashtable hPers = new Hashtable();
		String persAttrName;
		String [] sArray;
		
		String sSql =
			"SELECT attr_name, c.attr_id, display_name " +
			"  FROM ccps_attribute a, ccps_cust_attr c " +
			" WHERE a.attr_id = c.attr_id AND c.cust_id = "+cust.s_cust_id;
			
		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			persAttrName = rs.getString(1);
			if (persAttrName.equals("recip_id")) persAttrName = "RecipID";

			sArray = new String[2];
			sArray[0] = rs.getString(2);
			sArray[1] = new String(rs.getBytes(3),"UTF-8");
			
			hPers.put(persAttrName,sArray);
		}
		rs.close();

		Vector vPers = ContUtil.scanForPers(htmlPart+textPart,hPers);
		Enumeration ePers = vPers.elements();

		String attrIDs = "";
		String oneAttrName, aster;
		for (int i=0;i<vPers.size();++i)
		{
			oneAttrName = (String)ePers.nextElement();
			sArray = (String[])hPers.get(oneAttrName);

			aster = "";
			if (oneAttrName.equals("RecipID") || oneAttrName.equals("recip_key")) {
				oneInternalField = true;
				aster = "*";	
			}
			
			htmlValues += "<tr><td>"+aster+sArray[1]+"</td>\n" +
						"<td><input type=text size=30 name=a"+sArray[0]+"></td></tr>\n";

			attrIDs += ","+sArray[0]+",";			
		}
		
		//Find out which formulas are used in this content
		//First find logic blocks
		String tmpContID="",tmpContName="",tmpFilterID="",tmpFilterName="",tmpLogicID="",tmpLogicName="";
		String oldLogicID = "";
		
		// === === ===
		
		String sText = textPart + htmlPart;
		sText = ContUtil.replaceScrapeBlockIds(sText);
		Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
		String sLogicBlockId = null;

		// System.out.println(vLogicBlockIds);

		for (Enumeration eLogicBlockIds = vLogicBlockIds.elements() ; eLogicBlockIds.hasMoreElements() ;) {
			sLogicBlockId = (String) eLogicBlockIds.nextElement();
			
			//System.out.println("sLogicBlockId = " + sLogicBlockId);

			sSql = "SELECT l.cont_id, l.cont_name, cnt.cont_id, cnt.cont_name, p2.filter_id," +
					" ISNULL(pa.html_part,' '), ISNULL(pa.text_part,' '), f.filter_name" +
				" FROM ccnt_content l" +
					" INNER JOIN (ccnt_cont_part p2" +
							" LEFT OUTER JOIN ctgt_filter f ON p2.filter_id = f.filter_id" +
							" INNER JOIN (ccnt_content cnt" +
									" INNER JOIN ccnt_cont_body pa ON cnt.cont_id = pa.cont_id)" +
								" ON  p2.child_cont_id = cnt.cont_id)" +
						" ON l.cont_id = p2.parent_cont_id" +
				" WHERE l.cont_id = " + sLogicBlockId +
				" ORDER BY p2.seq";

			rs = stmt.executeQuery(sSql);
			while (rs.next())
			{
				tmpLogicID = rs.getString(1);
				tmpLogicName = new String(rs.getBytes(2),"UTF-8");
				tmpContID = rs.getString(3);
				tmpContName = new String(rs.getBytes(4),"UTF-8");
				tmpFilterID = rs.getString(5);
				htmlPart = new String(rs.getBytes(6),"UTF-8");
				textPart = new String(rs.getBytes(7),"UTF-8");

				//System.out.println("tmpFilterID = " + tmpFilterID);

				if (tmpFilterID == null) continue;

				tmpFilterName = new String(rs.getBytes(8),"UTF-8");
				
				// === === ===			

				if (!oldLogicID.equals(tmpLogicID)) {
					if (oldLogicID.length() != 0)
						htmlFormulas += "</table><br/><br/>\n<table width=650 class=\"main\" cellpadding=\"1\" cellspacing=\"1\">\n";

					htmlFormulas += "<tr><th colspan=2>Logic Block: "+tmpLogicName+"</th></tr>\n" +
									"<tr><td>Content</td><td>Target Group</td></tr>\n";
					oldLogicID = tmpLogicID;
				}
				
				htmlFormulas += "<tr>\n" +
					"  <td>"+tmpContName+"</td><td>"+tmpFilterName+"</td>\n" +
					"</tr>\n";
				
				if (filterIDs.indexOf(","+tmpFilterID+",") == -1) {
					htmlValues += "<tr><td>"+tmpFilterName+"</td>\n" +
					"  <td><input type=checkbox name=a"+tmpFilterID+"></td></tr>\n";
					filterIDs += ","+tmpFilterID+",";
				}

				
				//Personalization
				vPers = ContUtil.scanForPers(htmlPart+textPart,hPers);
				ePers = vPers.elements();

				for (int i=0;i<vPers.size();++i) {
					oneAttrName = (String)ePers.nextElement();
					sArray = (String[])hPers.get(oneAttrName);

					aster = "";
					if (oneAttrName.equals("RecipID") || oneAttrName.equals("recip_key")) {
						oneInternalField = true;
						aster = "*";	
					}
					
					if (attrIDs.indexOf(","+sArray[0]+",") == -1) {
						htmlValues += "<tr><td>"+aster+sArray[1]+"</td>\n" +
									"<td><input type=text size=30 name=a"+sArray[0]+"></td></tr>\n";
						attrIDs += ","+sArray[0]+",";			
					}
				}
			}
			rs.close();
		}
		//System.out.println("attrIDs = "+attrIDs);

		if (htmlFormulas.length() == 0) htmlFormulas = "<tr><td>None</td></tr>\n";
		else filterIDs = filterIDs.substring(1);

		if (htmlValues.length() == 0) htmlValues = "<tr><td>None</td></tr>\n";
	
		// get deliverability lists
		int count = 0;
		sSql = 
			"SELECT count(*) " +
			"  FROM cque_email_list l, cque_list_type t " +
			" WHERE l.type_id = t.type_id AND l.type_id in (" + deliverability_list_type + ") " +
			"   AND l.cust_id = '" + cust.s_cust_id + "'"  + 
			"   AND l.list_name not like 'ApprovalRequest(%)' " +
			"   AND l.status_id = '" + EmailListStatus.ACTIVE + "'";
		rs = stmt.executeQuery(sSql);
		rs.next();
		count = rs.getInt(1);
		rs.close();	
		String OptionsHtml = "";
		sSql = 
			"SELECT l.list_id, CASE l.status_id WHEN " + EmailListStatus.DELETED + " THEN '*Deleted* ' + l.list_name ELSE l.list_name END, " + 
			" t.type_name, l.status_id" +
			"  FROM cque_email_list l, cque_list_type t " +
			" WHERE l.type_id = t.type_id AND l.type_id in (" + deliverability_list_type + ") " +
			"   AND l.cust_id = '" + cust.s_cust_id + "'"  + 
			"   AND l.list_name not like 'ApprovalRequest(%)' " +
			"   AND l.status_id = '" + EmailListStatus.ACTIVE + "'" +
			" ORDER BY l.list_id DESC";	

		String sTestListId = null;
		String sTestListName = null;
		String sTypeName = null;
		String sStatusID = null;
		int iStatusID = 0;
		rs = stmt.executeQuery(sSql);
		while( rs.next() )
		{
			sTestListId = rs.getString(1);
			sTestListName = new String(rs.getBytes(2),"UTF-8");
			sTypeName = new String(rs.getBytes(3),"UTF-8");
			sStatusID = rs.getString(4);
			iStatusID = Integer.parseInt(sStatusID);
			OptionsHtml += "<option";
			OptionsHtml += " value=" + ((iStatusID == EmailListStatus.DELETED)?"":sTestListId);
			if (!pv_test_type_id.equals("1")) {
				OptionsHtml += " selected ";  
			}
			OptionsHtml += ">";
			OptionsHtml += HtmlUtil.escape(sTestListName);
			OptionsHtml += " ( " + HtmlUtil.escape(sTypeName) + " ) ";
			OptionsHtml += "</option>\r\n";
		}
		rs.close();

		step3Label = "Choose Deliverability List";
		
		step3Html += "<tr>";
		step3Html += "  <td>Deliverability list</td>";
		step3Html += "  <td>";
		step3Html += "    <select name=\"list_ids\" multiple size="+ count;
		if (!pv_test_type_id.equals("1")) {
			step3Html += " disabled";
		}
		step3Html += ">";
		step3Html += OptionsHtml;
		step3Html += "    </select>";
		step3Html += "  </td>";
		step3Html += "</tr>";
	
		step4Label = "Choose Delivery Format";
		
		step4Html += "<tr>";
		step4Html += "  <td>Delivery format</td>";
		step4Html += "  <td>";
		step4Html += "    <select name=\"format_id\" size=1>";
		step4Html += "      <option value=3 selected>multipart</option>";
		step4Html += "      <option value=2>html</option>";
		step4Html += "      <option value=1>text</option>";
		step4Html += "    </select>";
		step4Html += "  </td>";
		step4Html += "</tr>";
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>

<html>
	<head>
		<title>Deliverability Test</title>
		<%@ include file="../header.html" %>
		<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	</head>
	<script language="javascript">
		function SubmitPrepare(){
		    var count = 0;
			for (var i=0; i < document.FT.list_ids.options.length; i++) {
				if (document.FT.list_ids.options[i].selected == true) {
				    count++;
					if (document.FT.pv_test_list_ids.value == "") {
						document.FT.pv_test_list_ids.value = document.FT.list_ids.options[i].value;
					}
					else {
						document.FT.pv_test_list_ids.value += "," + document.FT.list_ids.options[i].value;
					}
				}
			}
			if (count == 0) {
				alert("Please select at least one deliverability list");
				return;
			}
			document.FT.pv_test_format_id.value = document.FT.format_id[document.FT.format_id.selectedIndex].value;
			document.FT.submit();
		}
	</script>
	<body>
		<form name="FT" method="post" target="_self" action="pv_test_preview.jsp">
			<input type=hidden name="pv_test_type_id" value="<%= pv_test_type_id %>">
			<input type=hidden name="pv_test_format_id" value="1">
			<input type=hidden name="pv_test_list_ids" value="">
			<input type=hidden name="origin_camp_id" value="<%= originCampID %>">
			<input type=hidden name="cont_id" value="<%= contID %>">
			<input type=hidden name="from" value="<%= from %>">
			<input type=hidden name="subj" value="<%= subj %>">
			<input type=hidden name="filter_ids" value="<%= filterIDs %>">
			<!-- Step 1 -->
			<table width="100%" class="main" cellspacing="0" cellpadding="0">
				<tr>
					<td class="sectionheader">&#x20;<b class="sectionheader">Step 1:</b> Formulas For <%= contName %></td>
				</tr>
			</table>
			<br><br>
			<table width=100% class="main" cellpadding="1" cellspacing="1">
				<%= htmlFormulas %>
			</table>
			<br><br>
			<!-- Step 2 -->
			<table width="100%" class="main" cellspacing="0" cellpadding="0">
				<tr>
					<td class="sectionheader">&#x20;<b class="sectionheader">Step 2:</b> Enter Values</td>
				</tr>
			</table>
			<br><br>
			<table width=100% class="main" cellpadding="1" cellspacing="1">
				<%= htmlValues %>
			</table>
			<%= (oneInternalField?"<br/>* Revotas internal field(s)<br/>":"") %>
			<br><br>
			<!-- Step 3 -->
			<table width="100%" class="main" cellspacing="0" cellpadding="0">
				<tr>
					<td class="sectionheader">&#x20;<b class="sectionheader">Step 3:</b> <%= step3Label %></td>
				</tr>
			</table>
			<br><br>
			<table width=100% class="main" cellpadding="1" cellspacing="1">
				<%= step3Html %>
			</table>
			<br><br>
			<!-- Step 4 -->
			<table width="100%" class="main" cellspacing="0" cellpadding="0">
				<tr>
					<td class="sectionheader">&#x20;<b class="sectionheader">Step 4:</b> <%= step4Label %></td>
				</tr>
			</table>
			<br><br>
			<table width=100% class="main" cellpadding="1" cellspacing="1">
				<%= step4Html %>
			</table>
			<br><br>
			<!-- Step 5 -->
			<center>
				<a class="actionbutton" href="javascript:SubmitPrepare();"> <%= button_label %></a>
			</center>
		</form>
	</body>
</html>