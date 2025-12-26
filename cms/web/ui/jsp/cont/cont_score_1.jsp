<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		java.util.*,java.sql.*,
		java.io.*,javax.servlet.*,
		javax.servlet.http.*,
		org.xml.sax.*,javax.xml.transform.*,
		javax.xml.transform.stream.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	boolean HYATTUSER = (ui.n_ui_type_id == UIType.HYATT_USER);

	if(!can.bRead && !HYATTUSER)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	String contID = request.getParameter("cont_id");
	if (contID == null)
	{
		response.sendRedirect("cont_list.jsp");
		return;
	}
	String from = HtmlUtil.escape(request.getParameter("from"));
	String subjText = HtmlUtil.escape(request.getParameter("subjText"));
	String subjHtml = HtmlUtil.escape(request.getParameter("subjHtml"));
	String subjAol = HtmlUtil.escape(request.getParameter("subjAol"));
	// === === ===
	
	Content cont = new Content();
	cont.s_cont_id = contID;
	if(cont.retrieve() < 1)
		throw new Exception("Invalid content. Content does not exist.");	

	ContBody cont_body = new ContBody(contID);
	
	// === === ===
	
	String contName = cont.s_cont_name;
	
	String textPart = cont_body.s_text_part;
	String htmlPart = cont_body.s_html_part;
	String aolPart = cont_body.s_aol_part;

	if(textPart == null) textPart = "";
	if(htmlPart == null) htmlPart = "";
	if(aolPart == null) aolPart = "";

	// === === ===
		
	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	
	String htmlFormulas = "";
	String htmlValues = "";
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
			" SELECT attr_name, c.attr_id, display_name " +
			" FROM ccps_attribute a, ccps_cust_attr c " +
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

		Vector vPers = scanForPers(htmlPart+textPart+aolPart,hPers);
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
		
		String sText = textPart + htmlPart + aolPart;
		sText = ContUtil.replaceScrapeBlockIds(sText);
		Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
		String sLogicBlockId = null;

// System.out.println(vLogicBlockIds);

		for (Enumeration eLogicBlockIds = vLogicBlockIds.elements() ; eLogicBlockIds.hasMoreElements() ;) {
			sLogicBlockId = (String) eLogicBlockIds.nextElement();
			
// System.out.println("sLogicBlockId = " + sLogicBlockId);

			sSql = 
				" SELECT l.cont_id, l.cont_name, cnt.cont_id, cnt.cont_name, p2.filter_id," +
					" ISNULL(pa.html_part,' '), ISNULL(pa.text_part,' '), ISNULL(pa.aol_part,' '), f.filter_name" +
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
				aolPart = " "; //new String(rs.getBytes(8),"UTF-8");

// System.out.println("tmpFilterID = " + tmpFilterID);

				if (tmpFilterID == null) continue;

				tmpFilterName = new String(rs.getBytes(9),"UTF-8");
				
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
				vPers = scanForPers(htmlPart+textPart+aolPart,hPers);
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
//		System.out.println("attrIDs = "+attrIDs);

		if (htmlFormulas.length() == 0) htmlFormulas = "<tr><td>None</td></tr>\n";
		else filterIDs = filterIDs.substring(1);

		if (htmlValues.length() == 0) htmlValues = "<tr><td>None</td></tr>\n";
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
<title>Content Score</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>

<script language="javascript">

function SubmitPrepare(contType){
	document.FT.contType.value = contType;
	document.FT.submit();
}
</script>

<body>
<form name="FT" method="post" target="score" action="cont_score_2.jsp">

<!-- Content ID -->
<input type=hidden name="cont_id" value="<%= contID %>">
<input type=hidden name="from" value="<%= from %>">
<input type=hidden name="subjText" value="<%= subjText %>">
<input type=hidden name="subjHtml" value="<%= subjHtml %>">
<input type=hidden name="subjAol" value="<%= subjAol %>">
<input type=hidden name="filter_ids" value="<%= filterIDs %>">
<input type=hidden name="contType" value="1">


<!-- Step 1 -->
<table width="100%" class="listTable" cellspacing="0" cellpadding="0">
<tr>
		<th class="sectionheader">&#x20;<b class="sectionheader">Step 1:</b> Formulas For <%= contName %></th>
</tr>

<%= htmlFormulas %>
</table>
<br/>

<!-- Step 2 -->
<table width="100%" class="listTable" cellspacing="0" cellpadding="0">
<tr>
		<th colspan=2 class="sectionheader">&#x20;<b class="sectionheader">Step 2:</b> Enter Values For Score</th>
</tr>

<%= htmlValues %>
</table>
<%= (oneInternalField?"<br/>* Revotas internal field(s)<br/>":"") %>
<Br/>

<table width="100%" class="listTable" cellspacing="0" cellpadding="0">
<tr>
<th class="sectionheader">&#x20;<b class="sectionheader">Step 3: Score Content</b></th>
</tr>
</table>
<br/>

<center>
<a class="subactionbutton" href="javascript:SubmitPrepare(1);">Score Text</a>

<a class="subactionbutton" href="javascript:SubmitPrepare(2);">Score HTML</a>
<!--

<a class="subactionbutton" href="javascript:SubmitPrepare(3);">Score AOL</a>
//-->
</center>
</form>
</body>
</html>


<%!
	//s contains the 3 content parts
	//h contains the list of attr_names for this customer
	protected Vector scanForPers (String s, Hashtable h) throws Exception {

		Vector v = new Vector();
		
		String attrName;
		int i,j,k;

		String tmp = s;
		while (true) {
			i = tmp.indexOf("!*");
			if (i == -1) break;

			tmp = tmp.substring(i);
			j = tmp.indexOf("*!");
			if (j == -1) {
				tmp = tmp.substring(2);
				continue;
			}
			
			//find the attr_name and make sure it is in h
			k = tmp.indexOf(";");
			if (k == -1) {
				tmp = tmp.substring(2);
				continue;
			}
			
			if (k > j) k = j;

			attrName = tmp.substring(2,k);
			logger.info("attrName = "+attrName);
			if (h.containsKey(attrName) && !v.contains(attrName)) {
				v.add(attrName);
			}
			tmp = tmp.substring(j);
		}
		return v;
	}

%>
