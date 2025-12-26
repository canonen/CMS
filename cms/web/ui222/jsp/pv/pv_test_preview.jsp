<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.que.*"
	import="com.britemoon.cps.cnt.*"
	import="com.britemoon.cps.adm.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.io.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if (logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	boolean HYATTUSER = (ui.n_ui_type_id == UIType.HYATT_USER);

	if (!can.bRead && !HYATTUSER)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
	String pv_test_type_id = request.getParameter("pv_test_type_id");
	String pv_test_format_id = request.getParameter("pv_test_format_id");
	String pv_test_list_ids = request.getParameter("pv_test_list_ids");
	System.out.println("[preview] pv_test_list_ids = " + pv_test_list_ids);
	String originCampID = request.getParameter("origin_camp_id");
	String contID = request.getParameter("cont_id");
	String subj = HtmlUtil.escape(request.getParameter("subj"));
	String from = HtmlUtil.escape(request.getParameter("from"));
	
	String button_label = "Send Delivery Track test"; 
	if (pv_test_type_id == null) {
		pv_test_type_id = "1";
	}
	if (pv_test_type_id.equals("2")) {
		button_label = "Send eContent Scorer test";
	}
	if (pv_test_type_id.equals("3")) {
		button_label = "Send eDesign Optimizer test";
	}

	if (pv_test_format_id == null) {
		pv_test_format_id = "3";
	}
	Content cont = new Content();
	cont.s_cont_id = contID;
	if(cont.retrieve() < 1) {
		throw new Exception("Invalid content. Content does not exist.");	
	}
	ContBody cont_body = new ContBody(contID);
	String textPart = cont_body.s_text_part;
	String htmlPart = cont_body.s_html_part;
	if (textPart == null) {
		textPart = " ";
	}
	if (htmlPart == null) {
		htmlPart = " ";
	}
	ContSendParam cont_send_param = new ContSendParam(contID);
	int unsubPos = 0;
	if (cont_send_param.s_unsub_msg_position != null) {
		unsubPos = Integer.parseInt(cont_send_param.s_unsub_msg_position);
	}
	UnsubMsg unsub_msg = new UnsubMsg (cont_send_param.s_unsub_msg_id);
	String unsubTextPart = unsub_msg.s_text_msg;
	String unsubHtmlPart = unsub_msg.s_html_msg;
	if(unsubTextPart == null) {
		unsubTextPart = "";
	}
	if(unsubHtmlPart == null) {
		unsubHtmlPart = "";
	}

	String previewHtml = "";
	String previewText = "";

	//Unsub at -1 = top and bottom OR 0 = top
	if (unsubPos <= 0) {
		previewHtml = unsubHtmlPart;
		previewText = unsubTextPart;
	}

    if (from == null) {
    	from = ""; 
    }
    if (subj == null) {
    	subj = ""; 
    }
    subj = subj.replaceAll("\u00c3\u0082\u00c2\u00ae","\u00ae"); // allow registed trademark
    subj = subj.replaceAll("\u00c3\u0082\u00c2\u00a2","\u00a2"); // allow cent
    subj = subj.replaceAll("\u00c3\u0082\u00c2\u00a3","\u00a3"); // allow pound

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;

	try	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
		
		//Grab the customer's attributes
		Hashtable hPers = new Hashtable();
		String attrID, attrName;
		
		String sSql = "SELECT c.attr_id, a.attr_name" +
			   		  "  FROM ccps_attribute a, ccps_cust_attr c" +
			          " WHERE a.attr_id = c.attr_id" +
			          "   AND c.cust_id = " + cust.s_cust_id;
		ResultSet rs = stmt.executeQuery(sSql);

		while (rs.next()) {
			//Make sure this attribute is in the content
			attrID = rs.getString(1);
			attrName = rs.getString(2);
			if (attrName.equals("recip_id")) attrName = "RecipID";
			if (request.getParameter("a"+attrID) != null) hPers.put(attrID,attrName);
		}
		rs.close();
		
		// === === ===
		
		htmlPart = ContUtil.replacePers(htmlPart,hPers,request);
		textPart = ContUtil.replacePers(textPart,hPers,request);
	
		// === === ===
		
		htmlPart = ContUtil.replaceScrapeBlockIds(htmlPart);
		textPart = ContUtil.replaceScrapeBlockIds(textPart);
		
		// === === ===

		//Go through each part at the same time, looking for "!lb*name;id*lb!" tags
		//Vector will hold the Strings for each new paragraph and the id if it is a logic block
		Vector vHtmlPara = ContUtil.parseParagraph(htmlPart);
		Vector vTextPara = ContUtil.parseParagraph(textPart);

		int numHtml = vHtmlPara.size();
		int numText = vTextPara.size();
		
		//System.out.println("numHtml = "+numHtml+" numText = "+numText);

		String [] aHtml = new String[numHtml];
		String [] aText = new String[numText];
		
		vHtmlPara.toArray(aHtml);
		vTextPara.toArray(aText);

		String logicID, filterValue;
		String tmpFilterID,tmpContID,tmpContHtml,tmpContText;

		int j1,j2;
		int posHtml=0,posText=0;
		boolean htmlDone = false, textDone = false;
		boolean isLogic = false;
		while (!htmlDone || !textDone )	{
			//Start on html, then text
			if (!htmlDone) {
				htmlPart = aHtml[posHtml];
				if (textDone) textPart = " ";
				else textPart = aText[posText];

				j1 = htmlPart.indexOf("!lb*");
				j2 = textPart.indexOf("!lb*");

				//Increment html position
				++posHtml;
				isLogic = (j1 != -1);
				if (isLogic) {
					//html is a logic block, see if others are same logic block
					if (j2 != -1) {
						if (htmlPart.equals(textPart)) {							
							++posText;	
						}
						else {
							//Different logic block
							textPart = " ";
							j2 = -1;
						}
					} 
					else {
						//Normal text
						textPart = " ";
					}
				} 
				else {
					//html is normal paragraph, see if others are normal paragraphs
					if (j2 != -1) {
						textPart = " ";
					}
					else {
						++posText;
					}
				}
			}
			else {
				//html is done, go through text sections
				htmlPart = " ";
				textPart = aText[posText];
				
				j1 = -1;
				j2 = textPart.indexOf("!lb*");
				++posText;
				
				isLogic = (j2 != -1);
			} 

			if (!isLogic) {
				//Add paragraph
				//System.out.println("Normal Paragraph");
				if (j1 == -1 && !htmlPart.equals(" ")) previewHtml += htmlPart;
				if (j2 == -1 && !textPart.equals(" ")) previewText += textPart;
			
			}
			else {
				//Parse out the logic block, adding each content block and its formula
				//System.out.println("Logic Block");
				
				//Grab the logicID embedded in the merge symbol
				if (!htmlDone)
					logicID = htmlPart.substring(htmlPart.indexOf(";")+1,htmlPart.indexOf("*lb!"));
				else
					logicID = textPart.substring(textPart.indexOf(";")+1,textPart.indexOf("*lb!"));
				
				//Make sure the logicID is valid
				try { Integer.parseInt(logicID); }
				catch (NumberFormatException ex)
				{
					throw new Exception("Invalid Content!  One of the logic block merge symbols is invalid. Logic block ID = "+logicID);
				}
				
				//Lookup this logicID and check to see if filter is true
				byte[] b = null;				
				sSql =
					" SELECT b.cont_id, p.filter_id, b.html_part, b.text_part " +
					   "FROM ccnt_cont_part p, ccnt_cont_body b " +
					   "WHERE p.parent_cont_id = "+logicID+" " +
					   "AND b.cont_id = p.child_cont_id " +
					   "ORDER BY p.seq";
				rs = stmt.executeQuery(sSql);

				boolean bUseDefault = true;
				String tmpContHtmlDef = "";
				String tmpContTextDef = "";
				while (rs.next())
				{
					tmpContID = rs.getString(1);
					tmpFilterID = rs.getString(2);
					
					if (tmpFilterID == null) {
						b = rs.getBytes(3);
						tmpContHtmlDef = (b==null)?"":new String(b,"UTF-8");
						b = rs.getBytes(4);
						tmpContTextDef = (b==null)?"":new String(b,"UTF-8");
					} else {
						b = rs.getBytes(3);
						tmpContHtml = (b==null)?"":new String(b,"UTF-8");
						b = rs.getBytes(4);
						tmpContText = (b==null)?"":new String(b,"UTF-8");

						filterValue = request.getParameter("a"+tmpFilterID);
						if (filterValue != null) {
							bUseDefault = false;

							if (j1 != -1) previewHtml += ContUtil.replacePers(tmpContHtml,hPers,request);
							if (j2 != -1) previewText += ContUtil.replacePers(tmpContText,hPers,request);
						}
					}		
				}
				rs.close();

				if (bUseDefault) {
					if (j1 != -1) previewHtml += ContUtil.replacePers(tmpContHtmlDef,hPers,request);
					if (j2 != -1) previewText += ContUtil.replacePers(tmpContTextDef,hPers,request);
				}
			}
			
			//System.out.println("isLogic? = "+isLogic+" posHtml = "+posHtml+" posText = "+posText);
			//See which parts are done
			if (posHtml >= numHtml) htmlDone = true;
			if (posText >= numText) textDone = true;
		}
		if (unsubPos != 0)
		{
				previewHtml += unsubHtmlPart;
				previewText += unsubTextPart;
		}
	}
	catch (Exception ex) {
		throw ex; 
	}
	finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

	boolean show_text = true;
	boolean show_html = true;
	if (pv_test_format_id.equals("1")) show_html = false;
	if (pv_test_format_id.equals("2")) show_text = false;
	
	String tab_width = "350";
	String tab_colspan = " colspan=\"3\"";
	String tab_display = "";
	if (!show_html)
	{
		tab_width = "500";
		tab_colspan = " colspan=\"2\"";
	}
	if (show_text && show_html)
	{
		tab_display = "style=\"display:none;\"";
	}
	String textBody = previewText;
	String htmlBody = previewHtml;
%>

<html>
<head>
	<title>Deliverability Test Preview</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript" src="../../js/tab_script.js" type="text/javascript"></script>
</head>
<script language="javascript">
	function SubmitPrepare(){
		if (!confirm("Are you sure?")) return;
		document.FT.submit();
	}
	function SubmitBack()
	{
		document.FT.action = "pv_test_config.jsp";
		document.FT.submit();
	}
</script>
<body>
	<form name="FT" method="post" target="_self" action="pv_test_send.jsp">
		<input type=hidden name="pv_test_type_id" value="<%= pv_test_type_id %>">
		<input type=hidden name="pv_test_format_id" value="<%= pv_test_format_id %>">
		<input type=hidden name="pv_test_list_ids" value="<%= pv_test_list_ids %>">
		<input type=hidden name="origin_camp_id" value="<%= originCampID %>">
		<input type=hidden name="cont_id" value="<%= contID %>">
		<input type=hidden name="from" value="<%= from %>">
		<input type=hidden name="subj" value="<%= subj %>">
		<input type=hidden name="textBody" value="<%= HtmlUtil.escape(textBody) %>">
		<input type=hidden name="htmlBody" value="<%= HtmlUtil.escape(htmlBody) %>">
		<table id="main" cellspacing="0" cellpadding="0" width="650" border="0">
			<tr>
				<% if (show_text) { %>
				<td class="EditTabOn"  id="show_text" width="150" onclick="switchSteps('main', 'show_text', 'text_body');" valign="center" nowrap align="middle">Text</td>
				<% } %>
				<% if (show_html && !show_text) { %>
				<td class="EditTabOn" id="show_html" width="150" onclick="switchSteps('main', 'show_html', 'html_body');" valign="center" nowrap align="middle">HTML</td>
				<% } %>
				<% if (show_html && show_text) { %>
				<td class="EditTabOff" id="show_html" width="150" onclick="switchSteps('main', 'show_html', 'html_body');" valign="center" nowrap align="middle">HTML</td>
				<% } %>
				<td class="EmptyTab" valign="center" nowrap align="middle" width="<%= tab_width %>">&nbsp;</td>
			</tr>
			<tr>
				<td class="fillTabbuffer" valign="top" align="left" <%= tab_colspan %> width="650"><img height="2" src="../../images/blank.gif" width="1"></td>
			</tr>
			<% if (show_text) { %>
			<tbody class="EditBlock" id="text_body">
			<tr>
				<td class="fillTab" valign="top" align="center" <%= tab_colspan %> width="650">
					<table class=main width=100% cellspacing=1 cellpadding=3 border=0><tr><td>
        			<textarea cols=120 rows=35 wrap=hard><%= "From: " + from + "\nSubject: " + subj + "\n\n" + textBody %></textarea>
        			</td></tr></table>
				</td>
			</tr>
			</tbody>
			<% } %>
			<% if (show_html) { %>
			<tbody class="EditBlock" id="html_body" <%= tab_display %>>
			<tr>
				<td class="fillTab" valign="top" align="center" width="650" <%= tab_colspan %> >
					<table class=main width=100% cellspacing=1 cellpadding=3 border=0><tr><td>
				    <b>From</b>: <%= from %><br>
				    <b>Subject</b>: <%= subj %>
				    <object width=100%><p><%= htmlBody %></object>
				    </td></tr></table>
				</td>
			</tr>
			</tbody>
			<% } %>
		</table>
		<br><br>
		<center>
			<a class="subactionbutton" href="javascript:SubmitBack();"> Back</a> 
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a class="actionbutton" href="javascript:SubmitPrepare();"> <%= button_label %></a>
		</center>
	</form>
</body>
</html>