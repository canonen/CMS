<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		java.util.*,
		java.sql.*,java.io.*,
		org.apache.log4j.*"
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

	if(!can.bWrite)
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

	String sUseAnchorName = request.getParameter("use_anchor_name");
	String sUseLinkRenaming = request.getParameter("use_link_renaming");
	String sReplaceScannedLinks = request.getParameter("replace_scanned_links");
    boolean useAnchorName = false;
    boolean useLinkRenaming = false;
    boolean replaceScannedLinks = false;
    if (sUseAnchorName != null && sUseAnchorName.equals("1")) {
		logger.info("Using anchor name");
        useAnchorName = true;
    }
    if (sUseLinkRenaming != null && sUseLinkRenaming.equals("1")) {
		logger.info("Using link renaming");
        useLinkRenaming = true;
    }
    if (sReplaceScannedLinks != null && sReplaceScannedLinks.equals("1")) {
		logger.info("Replace scanned links");
        replaceScannedLinks = true;
    }

	String sLoadId = request.getParameter("loadId");
    boolean validateContentLoadImages = false;
    if (sLoadId != null) {
		validateContentLoadImages = true;
    }

	// === === ===
	
	Content cont = new Content();
	cont.s_cont_id = contID;
	if(cont.retrieve() < 1)
		throw new Exception("Invalid content. Content does not exist.");	

	ContBody cont_body = new ContBody(contID);
	
	// === === ===
	
	String contName = cont.s_cont_name;
	
	String tmpTextPart = cont_body.s_text_part;
	String tmpHtmlPart = cont_body.s_html_part;
	String tmpAolPart = cont_body.s_aol_part;

	if(tmpTextPart == null) tmpTextPart = "";
	if(tmpHtmlPart == null) tmpHtmlPart = "";
	if(tmpAolPart == null) tmpAolPart = "";

	// === === ===

	String htmlLinks = "", jsLinks = "";
	String missingImages = "";
	int linkCount = 0;

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		//Need to create a hashtable of all current links in order to prefill with names
		Hashtable hCurLinks = new Hashtable();
		String sSql =
			" SELECT href, link_name " +
			" FROM cjtk_link " +
			" WHERE cont_id = "+contID+
			" AND cust_id = "+cust.s_cust_id;
			
		ResultSet rs = stmt.executeQuery(sSql);
		while (rs.next()) hCurLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8"));
		rs.close();

		//Need to create a hashtable of all user defined exactly matched links
		Hashtable hExactLinks = new Hashtable();
		sSql =
			" SELECT lower(link_definition), link_name " +
			"   FROM ccnt_link_renaming " +
			"  WHERE link_type_id = 1"+
			"    AND cust_id = "+cust.s_cust_id;
			
		rs = stmt.executeQuery(sSql);
		while (rs.next()) hExactLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8"));
		rs.close();

		//Need to create a hashtable of all user defined partially matched links
		LinkedHashMap hPartialLinks = new LinkedHashMap();
		sSql =
			" SELECT lower(link_definition), link_name " +
			"   FROM ccnt_link_renaming " +
			"  WHERE link_type_id = 2"+
			"    AND cust_id = "+cust.s_cust_id+
			"  ORDER BY len(link_definition) DESC";
			
		rs = stmt.executeQuery(sSql);
		while (rs.next()) hPartialLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8"));
		rs.close();

		//Need to create a vector of all images loaded from content load		
		Vector vContentLoadImages = new Vector();
		if (validateContentLoadImages) {
			String fileUrl = null;
			String fileName = null;
			String rootDir = null;
			int idx = 0;

			// find rootdir from text file
			sSql = "SELECT DISTINCT f.file_url"
				+ " FROM ccnt_cont_load_file f"
				+ " WHERE f.type_id = " + FileType.CONT_TEXT
				+ " AND f.load_id = "+sLoadId;
			
			rs = stmt.executeQuery(sSql);
			if (rs.next()) {
				rootDir = rs.getString(1);
			}
			rs.close();
			idx = rootDir.lastIndexOf('/');
			if (idx > 0) {
				rootDir = rootDir.substring(0, idx+1);
			}
			else {
				rootDir = "/";
			}

			// get loaded images
			sSql =
				" SELECT file_url " +
				" FROM ccnt_cont_load_file " +
				" WHERE load_id = " + sLoadId+
				"   AND type_id = " + FileType.IMAGE;			
			rs = stmt.executeQuery(sSql);
			logger.info("rootDir = " + rootDir);
			while (rs.next()) {
				fileUrl = new String (rs.getBytes(1),"UTF-8");
				logger.info("found image = " + fileUrl);
				if (fileUrl.toLowerCase().startsWith(rootDir.toLowerCase())) {
					fileName = fileUrl.substring(rootDir.length());
				}
				else {
					fileName = fileUrl.substring(fileUrl.lastIndexOf("/")+1);
				}
				logger.info("add image = " + fileName);
				vContentLoadImages.add(fileName);
			}
			rs.close();
		}

		Vector vLinks;
        Vector vLinks2;
        Vector vLinks3;
		Vector vAllLinks = new Vector();
		
		vLinks = scanForHtmlAnchors(tmpHtmlPart+"\n"+tmpAolPart+"\n", hCurLinks, hExactLinks, hPartialLinks, useAnchorName, useLinkRenaming, replaceScannedLinks);
		vLinks2 = scanForTextLinks(tmpTextPart+"\n", hCurLinks, hExactLinks, hPartialLinks, useLinkRenaming, replaceScannedLinks);
		vLinks3 = scanForHtmlImgs(tmpHtmlPart+"\n"+tmpAolPart+"\n");

        vLinks.addAll(vLinks2);
        vLinks.addAll(vLinks3);
		
		if (validateContentLoadImages) {
			Vector vLeftOver = new Vector();
			String content = tmpHtmlPart.toLowerCase();
			for (int n=0; n < vContentLoadImages.size(); n++) {
				String oneImg = (String)vContentLoadImages.get(n);	
				if (content.indexOf(oneImg.toLowerCase()) < 0) {
					vLeftOver.add(oneImg);
				}				
			}
			vContentLoadImages.removeAllElements();
			vContentLoadImages.addAll(vLeftOver);				
		}

		// debug: see what is in the hCurLinks
		logger.info("debug: saved links");
		Enumeration eCurLinks = hCurLinks.keys();
		while (eCurLinks.hasMoreElements())
		{
			String key = (String)eCurLinks.nextElement();
			logger.info(key + " => " + hCurLinks.get(key));
		}
		logger.info("end debug: saved links");
		// end debug

		htmlLinks += "<tr><th colspan=3>Main Content</th></tr>\n" +
					 "<tr><td class=subsectionheader>Include</td><td class=subsectionheader>Link</td><td class=subsectionheader>Link Name</td></tr>\n";

		//Go through every link found and create the html for it
		Enumeration e = vLinks.elements();

		String oneLink = "", linkExt = "";
		boolean notImage = true;
		
		String sClassAppend = "";
		int iTabCount = 1;
		
		for (int i=0;i<vLinks.size();++i)
		{

			if (i % 2 != 0)
			{
				sClassAppend = "_Alt";
			}
			else
			{
				sClassAppend = "";
			}
			
			oneLink = (String)e.nextElement();
			//System.out.println("checking <"+oneLink+">");
			//See if link is already displayed, in vAllLinks
			if (vAllLinks.contains((String)oneLink)) {
				continue;
			}
			else {
				vAllLinks.add(oneLink);
			}

			linkExt = oneLink.substring(oneLink.length()-4);
			notImage = (!linkExt.equalsIgnoreCase(".gif") && !linkExt.equalsIgnoreCase(".jpeg") && !linkExt.equalsIgnoreCase(".jpg"));
			
			++linkCount;
			
			htmlLinks += "<tr>\n" +
				"  <td class=\"listItem_Data" + sClassAppend + "\"><input tabindex="+iTabCount+" type=checkbox name=check"+linkCount+" "+(notImage || hCurLinks.containsKey(oneLink)?"checked":"")+"></td>\n" +
				"  <td class=\"listItem_Data" + sClassAppend + "\">"+(notImage?"":"<font color=red>(image)</font>")+"<a target=\"new_window\" href=\""+HtmlUtil.escape(oneLink)+"\">"+HtmlUtil.escape(oneLink)+"</a></td>\n";
			
				iTabCount++;
				
			htmlLinks += "  <td class=\"listItem_Data" + sClassAppend + "\"><input tabindex="+iTabCount+" type=hidden name=lhref"+linkCount+" value=\""+HtmlUtil.escape(oneLink)+"\">\n" +
				"  <input type=text size=30 name=lname"+linkCount+" value=\""+(hCurLinks.containsKey(oneLink)?(String)hCurLinks.get(oneLink):"Link "+linkCount)+"\"></td>\n" +
				"</tr>\n";
				
				iTabCount++;
				
			jsLinks += "if (document.FT.check"+linkCount+".checked == true) {\n" +
					   "  document.FT.lname"+linkCount+".value = document.FT.lname"+linkCount+".value.replace(/(^\\s*)|(\\s*$)/g, '');\n" +
					   "  if (document.FT.lname"+linkCount+".value.length == 0) {\n" +
					   "    alert(\"You have to enter a name for all checked links.\");\n" +
					   "    return;\n  }\n}\n";
		
		}
		if (oneLink.length() == 0)
			htmlLinks += "<tr><td class=\"listItem_Title\" colspan=3>None</td></tr>\n";

		//Find out which paragraphs are used in this content
		String tmpContID="",tmpContName="",tmpLogicID="",tmpLogicName="";
		String oldLogicID = "";
		
// KO: new logic block stuff
		String sText = tmpTextPart + tmpHtmlPart + tmpAolPart;
		sText = ContUtil.replaceScrapeBlockIds(sText);
		Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
		String sLogicBlockId = null;

// System.out.println(vLogicBlockIds);

		for (Enumeration eLogicBlockIds = vLogicBlockIds.elements() ; eLogicBlockIds.hasMoreElements() ;)
		{
			sLogicBlockId = (String) eLogicBlockIds.nextElement();
			
// System.out.println("sLogicBlockId = " + sLogicBlockId);

			sSql =
				" SELECT l.cont_id, l.cont_name, cnt.cont_id, cnt.cont_name," +
				" ISNULL(pa.html_part,' '), ISNULL(pa.aol_part,' '), ISNULL(pa.text_part,' ')" +
				" FROM ccnt_content l, ccnt_cont_part p2, " +
				" ccnt_content cnt, ccnt_cont_body pa " +
				" WHERE l.cont_id = " + sLogicBlockId +
				" AND l.cont_id = p2.parent_cont_id " +
				" AND cnt.cont_id = p2.child_cont_id " +
				" AND cnt.cont_id = pa.cont_id " +
				" ORDER BY p2.seq";

			rs = stmt.executeQuery(sSql);
			while (rs.next())
			{
				tmpLogicID = rs.getString(1);
				tmpLogicName = new String(rs.getBytes(2),"UTF-8");
				tmpContID = rs.getString(3);
				tmpContName = new String(rs.getBytes(4),"UTF-8");
				tmpHtmlPart = new String(rs.getBytes(5),"UTF-8");
				tmpAolPart = new String(rs.getBytes(6),"UTF-8");
				tmpTextPart = new String(rs.getBytes(7),"UTF-8");

				if (!oldLogicID.equals(tmpLogicID)) {
					htmlLinks += "</table><br/>\n<table width=100% class=\"listTable\" cellpadding=\"2\" cellspacing=\"0\">\n" +
								 "<tr><th colspan=3>Logic Block: "+tmpLogicName+"</th></tr>\n" +
								 "<tr><td class=subsectionheader>Include</td><td class=subsectionheader>Link</td><td class=subsectionheader>Link Name</td></tr>\n";

					oldLogicID = tmpLogicID;
				}
				htmlLinks += "<tr><th colspan=3><b>Content Block: "+tmpContName+"</b></th></tr>\n";

				vLinks  = scanForHtmlAnchors(tmpHtmlPart+"\n"+tmpAolPart+"\n", hCurLinks, hExactLinks, hPartialLinks, useAnchorName, useLinkRenaming, replaceScannedLinks);				
				vLinks2 = scanForTextLinks(tmpTextPart+"\n", hCurLinks, hExactLinks, hPartialLinks, useLinkRenaming, replaceScannedLinks);
				vLinks3 = scanForHtmlImgs(tmpHtmlPart+"\n"+tmpAolPart+"\n");
				vLinks.addAll(vLinks2);
				vLinks.addAll(vLinks3);

				if (validateContentLoadImages) {
					Vector vLeftOver = new Vector();
					String content = tmpHtmlPart.toLowerCase();
					for (int n=0; n < vContentLoadImages.size(); n++) {
						String oneImg = (String)vContentLoadImages.get(n);	
						if (content.indexOf(oneImg.toLowerCase()) < 0) {
							vLeftOver.add(oneImg);
						}				
					}
					vContentLoadImages.removeAllElements();
					vContentLoadImages.addAll(vLeftOver);				
				}

				
				//Go through every link found and create the html for it

				oneLink = "";
				int nLinks = 0;
				for (int i=0;i<vLinks.size();++i)
				{
					oneLink = (String)vLinks.get(i);
					//See if link is already displayed, in vAllLinks
					if (vAllLinks.contains((String)oneLink))
					{
						continue;
					}
					else
					{
						vAllLinks.add(oneLink);
					}
					
					if (nLinks++ % 2 != 0)
					{
						sClassAppend = "_Alt";
					}
					else
					{
						sClassAppend = "";
					}

					linkExt = oneLink.substring(oneLink.length()-4);
					notImage = (!linkExt.equalsIgnoreCase(".gif") && !linkExt.equalsIgnoreCase(".jpeg") && !linkExt.equalsIgnoreCase(".jpg"));
					
					++linkCount;
					
					htmlLinks += "<tr>\n" +
						"  <td class=\"listItem_Data" + sClassAppend + "\"><input tabindex="+iTabCount+" type=checkbox name=check"+linkCount+" "+(notImage || hCurLinks.containsKey(oneLink)?"checked":"")+"></td>\n" +
						"  <td class=\"listItem_Data" + sClassAppend + "\">"+(notImage?"":"<font color=red>(image)</font>")+"<a target=\"new_window\" href=\""+oneLink+"\">"+oneLink+"</a></td>\n";
					
					iTabCount++;
					
					htmlLinks += "  <td class=\"listItem_Data" + sClassAppend + "\"><input tabindex="+iTabCount+" type=hidden name=lhref"+linkCount+" value=\""+oneLink+"\">\n" +
						"  <input type=text size=30 name=lname"+linkCount+" value=\""+(hCurLinks.containsKey(oneLink)?(String)hCurLinks.get(oneLink):"Link "+linkCount)+"\"></td>\n" +
						"</tr>\n";
					
					iTabCount++;
						
					jsLinks += "if (document.FT.check"+linkCount+".checked == true) {\n" +
							   "  document.FT.lname"+linkCount+".value = document.FT.lname"+linkCount+".value.replace(/(^\\s*)|(\\s*$)/g, '');\n" +
							   "  if (document.FT.lname"+linkCount+".value.length == 0) {\n" +
							   "    alert(\"You have to enter a name for all checked links.\");\n" +
							   "    return;\n  }\n}\n";
				}
				if (nLinks == 0)
					htmlLinks += "<tr><td class=\"listItem_Data\" colspan=3>None</td></tr>\n";
							  
			}
			rs.close();
		}
		if (htmlLinks.length() == 0) htmlLinks = "<tr><td class=\"listItem_Data\">None</td></tr>";

		// create html for unvalidated images
		if ( validateContentLoadImages && ( vContentLoadImages.size() > 0) ) {
			missingImages += "<table width=\"100%\" class=\"main\" cellspacing=\"1\" cellpadding=\"2\">";
			missingImages += "  <tr>";
			missingImages += "    <td valign=\"center\" align=\"left\" style=\"padding:10px;\">";
			missingImages += "      <center><font color=red>These images are loaded to the system but not referenced in the content</font></center>";
			missingImages += "      <br>";
			for (int n=0; n < vContentLoadImages.size(); ++n) {
				String oneImg = (String)vContentLoadImages.get(n);
				//System.out.println("image not found in content => " + oneImg);
				missingImages += oneImg + "<br>";
			}
			missingImages += "    </td>";
			missingImages += "  </tr>";
			missingImages += "</table>"; 
			missingImages += "<br>"; 
		}

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
<title>Link Scan</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>

<script language="javascript">
function SubmitPrepare()
{
	<%= jsLinks %>
	document.FT.submit();
}
</script>

<body>

<form name="FT" method="post" action="link_scan_save.jsp">
	<input type=hidden name="cont_id" value="<%= contID %>">
	<input type=hidden name="linkCount" value="<%= linkCount %>">
	<input type=hidden name="type" value="<%= request.getParameter("type") %>">

<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
		<% if (linkCount != 0) { %>
			<a class="savebutton" href="javascript:SubmitPrepare();"/>Save to Content</a>
		<% } else { %>
			<a class="savebutton" href="cont_edit.jsp?cont_id=<%= contID %>">Back to Edit</a>
			<br><br>
			<font color=red>No Links Found</font>
			<br>
		<% } %>
		</td>
	</tr>
</table>
<br>

<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Select and Name Links to Track For <%= contName %></td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=650>
			<table width="100%" class="main" cellspacing="1" cellpadding="2">
				<tr>
					<td valign="center" align="middle" style="padding:10px;">
						Select and Name links you wish to track.  Naming the links will allow for easier report viewing.  <br>
						Note:  If you choose to track images, the clickthrough rate will be inflated due to images acting as automatic clicks without recipient actions
					</td>
				</tr> 
			</table>
			<br>
			<%=(missingImages != null ? missingImages : "")%>
			<table width=100% class="listTable" cellpadding="2" cellspacing="0">
				<%= htmlLinks %>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</form>
</body>
</html>

<%!
    // for text format
	protected Vector scanForTextLinks (String s, Hashtable hCur, Hashtable hExact, LinkedHashMap hPartial, boolean useLink, boolean replaceScannedLinks) throws Exception
	{
		Vector v = new Vector();
		Vector vImages = new Vector();

		int i,j1,j2,j3,j4,j5,j6,min=0;
		String oneLink, linkExt;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("http");
			if (i == -1) break;
			partS = partS.substring(i);
			
			//If there is less that 8 characters left quit (cant get "httpxxxx", ie "https://)
			if (partS.length() < 8) break;
			i = partS.substring(0,8).indexOf("://");
			if (i == -1) {
				//does not have "://", skip it
				partS = partS.substring(5);
				continue;
			}
			//Search for a quote, space, >, or \n to denote end of link
			//Links cannot have quote, space, >, or \n in them
			j1 = partS.indexOf("\"");
			j2 = partS.indexOf(" ");
			j3 = partS.indexOf(">");
			j4 = partS.indexOf("\n");
			j5 = partS.indexOf("'");
			j6 = partS.indexOf("<");
			if (j1 != -1 || j2 != -1 || j3 != -1 || j4 != -1 || j5 != -1 || j6 != -1)
			{
				//Want to use the min j, that is not -1
				if (j1 == -1) j1 = Integer.MAX_VALUE;
				if (j2 == -1) j2 = Integer.MAX_VALUE;
				if (j3 == -1) j3 = Integer.MAX_VALUE;
				if (j4 == -1) j4 = Integer.MAX_VALUE;
				if (j5 == -1) j5 = Integer.MAX_VALUE;
				if (j6 == -1) j6 = Integer.MAX_VALUE;
			
				//Take the min of j1,j2,j3,j4,j5
				if (j1 < j2)
					if (j1 < j3)
						if (j1 < j4) min = j1;
						else min = j4;
					else if (j3 < j4) min = j3;
					else min = j4;
				else if (j2 < j3)
					if (j2 < j4) min = j2;
					else min = j4;
				else if (j3 < j4) min = j3;
				else min = j4;

				if (j5 < min) min = j5;
				if (j6 < min) min = j6;

				oneLink = partS.substring(0,min);
				if (!oneLink.equals("http://")  && !oneLink.equals("https://"))
				{
				    oneLink = oneLink.trim();
					linkExt = oneLink.substring(oneLink.length()-4);
					if (!linkExt.equalsIgnoreCase(".gif") &&
						!linkExt.equalsIgnoreCase(".jpeg") &&
						!linkExt.equalsIgnoreCase(".jpg"))
					{
			            //System.out.println("found <"+oneLink+">");
						if (!v.contains(oneLink)) v.add(oneLink);
						if (!hCur.containsKey(oneLink) || replaceScannedLinks) {
							if (useLink) {
								String name = null;
								if (hExact.containsKey(oneLink.toLowerCase())) {
									name = (String) hExact.get(oneLink.toLowerCase());
									hCur.put(oneLink, name);
								}
								else {
									// find longest match, since we ordered the list by length, the first match is the longest
									Iterator iter = hPartial.keySet().iterator();
									while (iter.hasNext()) {
										String key = (String) iter.next();
										if (oneLink.toLowerCase().indexOf(key) != -1) {
											name = (String) hPartial.get(key);
											hCur.put(oneLink, name);
											break;
										}
									}
								}
							}
						}
					}
					else
					{
						if (!vImages.contains(oneLink)) vImages.add(oneLink);
					}
				}
			}
			else
			{
				//Could not find '"' or ' ' or '>' after http, move it ahead of http, ignorning link
				 min = 4;
			}
			partS = partS.substring(min);
		}
		v.addAll(vImages);
		return v;
	}

    // for href link inside an anchor
	protected String scanForOneLink (String s) throws Exception
	{
		int i,j1,j2,j3,j4,j5,j6,min=0;
		String oneLink, linkExt;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("http");
			if (i == -1) break;
			partS = partS.substring(i);
			
			//If there is less that 8 characters left quit (cant get "httpxxxx", ie "https://)
			if (partS.length() < 8) break;
			i = partS.substring(0,8).indexOf("://");
			if (i == -1) {
				//does not have "://", skip it
				partS = partS.substring(5);
				continue;
			} 
			//Search for a quote, space, >, or \n to denote end of link
			//Links cannot have quote, space, >, or \n in them
			j1 = partS.indexOf("\"");
			j2 = partS.indexOf(" ");
			j3 = partS.indexOf(">");
			j4 = partS.indexOf("\n");
			j5 = partS.indexOf("'");
			j6 = partS.indexOf("<");
			if (j1 != -1 || j2 != -1 || j3 != -1 || j4 != -1 || j5 != -1 || j6 != -1)
			{
				//Want to use the min j, that is not -1
				if (j1 == -1) j1 = Integer.MAX_VALUE;
				if (j2 == -1) j2 = Integer.MAX_VALUE;
				if (j3 == -1) j3 = Integer.MAX_VALUE;
				if (j4 == -1) j4 = Integer.MAX_VALUE;
				if (j5 == -1) j5 = Integer.MAX_VALUE;
				if (j6 == -1) j6 = Integer.MAX_VALUE;
			
				//Take the min of j1,j2,j3,j4,j5
				if (j1 < j2)
					if (j1 < j3)
						if (j1 < j4) min = j1;
						else min = j4;
					else if (j3 < j4) min = j3;
					else min = j4;
				else if (j2 < j3)
					if (j2 < j4) min = j2;
					else min = j4;
				else if (j3 < j4) min = j3;
				else min = j4;

				if (j5 < min) min = j5;
				if (j6 < min) min = j6;

				oneLink = partS.substring(0,min);
				if (!oneLink.equals("http://")  && !oneLink.equals("https://"))
				{
					linkExt = oneLink.substring(oneLink.length()-4);
					if (!linkExt.equalsIgnoreCase(".gif") &&
						!linkExt.equalsIgnoreCase(".jpeg") &&
						!linkExt.equalsIgnoreCase(".jpg"))
					{
						return oneLink;
					}
					else
					{
						return null;
					}
				}
			}
			else
			{
				//Could not find '"' or ' ' or '>' after http, move it ahead of http, ignorning link
				 min = 4;
			}
			partS = partS.substring(min);
		}
		return null;
	}

    // scan for name inside an anchor
	protected String scanForOneName (String s) throws Exception
	{
		//System.out.println("looking for name in {" + s + "}");
		int i,j,k1,k2,k3,min=0;
		String partS = s;
		String name = null;
		
		// look for name
		i = partS.indexOf("name");
		if (i == -1) return null;
		partS = partS.substring(i+4);

		//System.out.println("looking for name in {" + partS + "}");
		
		// look for =
		j = partS.indexOf("=");
		if (j == -1) return null;
		partS = partS.substring(j+1);

		//System.out.println("looking for name in {" + partS + "}");
		
		partS = partS.trim();
		if (partS.length() <= 0) return null;
		
		//System.out.println("looking for name in {" + partS + "}");

		String q = partS.substring(0,1);
		if (q.equals("'") || q.equals("\"")) {
			//System.out.println("found starting quote");
			partS = partS.substring(1);
			// look for q
			min = partS.indexOf(q);
			if (min == -1) return null;
			//System.out.println("found ending quote");
		}
		else {
			//System.out.println("found other starting char");
			// look for " ", ">", "\n"
			k1 = partS.indexOf(" ");
			k2 = partS.indexOf(">");
			k3 = partS.indexOf("\n");
			//System.out.println("found other ending char (" + k1 + "," + k2 + "," + k3 + ")");
			if (k1 == -1 && k2 == -1 && k3 == -1) return null;
			if (k1 == -1) k1 = Integer.MAX_VALUE;
			if (k2 == -1) k2 = Integer.MAX_VALUE;
			if (k3 == -1) k3 = Integer.MAX_VALUE;
			min = k1;
			if (k2 <= k1 && k2 <= k3) min = k2;
			if (k3 <= k1 && k3 <= k2) min = k3;
		}
		name = partS.substring(0,min).trim();
		//System.out.println("found name = {" + name + "}");
		return name;
	}

    // for html and aol formats link e.g. <a href="http://www.revotas.com" name="Revotas">
    protected Vector scanForHtmlAnchors (String s, Hashtable hCur, Hashtable hExact, LinkedHashMap hPartial,  boolean useName, boolean useLink, boolean replaceScannedLinks) throws Exception
	{
		Vector v = new Vector();

		int i,j,min=0;
		String oneLink;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("<a");
			if (i == -1) break;
			partS = partS.substring(i);
			// can't be less than 4 characters left (i.e. '<a >' is minimally expected)
			if (partS.length() < 4) break;
			j = partS.indexOf(">");
			if (j != -1) {
				min = j+1;
				oneLink = partS.substring(0,min);
				if (!oneLink.equals("<a")) {
					String href = scanForOneLink(oneLink);
					if (href != null) {
	                    href = href.trim();
			            //System.out.println("found <"+href+">");
						if (!v.contains(href)) v.add(href);
						if (!hCur.containsKey(href) || replaceScannedLinks) {
							// get link name using the following order of preferences
							// 1. use href name if found
							// 2. use exact match if found
							// 3. use longest partial match if found
							String name = null;
                            if (useName) {
                                name = scanForOneName(oneLink);
                            }
							if (name != null) {
								hCur.put(href, name);
			                    //System.out.println("replaced by name: " + href + " => " + name);
							}
							else if (useLink) {
								if (hExact.containsKey(href.toLowerCase())) {
									name = (String) hExact.get(href.toLowerCase());
									hCur.put(href, name);
			                        //System.out.println("replaced by exact: " + href + " => " + name);
								}
								else {
									// find longest match, since we ordered the list by length, the first match is the longest
									Iterator iter = hPartial.keySet().iterator();
									while (iter.hasNext()) {
										String key = (String) iter.next();
										if (href.toLowerCase().indexOf(key) != -1) {
											name = (String) hPartial.get(key);
											hCur.put(href, name);
											//System.out.println("replaced by partial: " + href + " => " + name);
											break;
										}
										else {
											//name = (String) hPartial.get(key);
											//System.out.println("NOT replaced by partial: " + href + " => (" + name + ") " + key);
										}
									}
								}
							}
						}
					}
				}
			}
			else {
				//Could not find '>' after '<a', move it ahead of '<a', ignorning anchor
				min = 2;
			}
			partS = partS.substring(min);
		}
		return v;
	}
	protected Vector scanForHtmlImgs (String s) throws Exception
	{
		Vector vImages = new Vector();

		int i,j1,j2,j3,j4,j5,j6,min=0;
		String oneLink, linkExt;
		String partS = s;
		while (true) {
			i = partS.toLowerCase().indexOf("http");
			if (i == -1) break;
			partS = partS.substring(i);
			
			//If there is less that 8 characters left quit (cant get "httpxxxx", ie "https://)
			if (partS.length() < 8) break;
			i = partS.substring(0,8).indexOf("://");
			if (i == -1) {
				//does not have "://", skip it
				partS = partS.substring(5);
				continue;
			}
			//Search for a quote, space, >, or \n to denote end of link
			//Links cannot have quote, space, >, or \n in them
			j1 = partS.indexOf("\"");
			j2 = partS.indexOf(" ");
			j3 = partS.indexOf(">");
			j4 = partS.indexOf("\n");
			j5 = partS.indexOf("'");
			j6 = partS.indexOf("<");
			if (j1 != -1 || j2 != -1 || j3 != -1 || j4 != -1 || j5 != -1 || j6 != -1)
			{
				//Want to use the min j, that is not -1
				if (j1 == -1) j1 = Integer.MAX_VALUE;
				if (j2 == -1) j2 = Integer.MAX_VALUE;
				if (j3 == -1) j3 = Integer.MAX_VALUE;
				if (j4 == -1) j4 = Integer.MAX_VALUE;
				if (j5 == -1) j5 = Integer.MAX_VALUE;
				if (j6 == -1) j6 = Integer.MAX_VALUE;
			
				//Take the min of j1,j2,j3,j4,j5
				if (j1 < j2)
					if (j1 < j3)
						if (j1 < j4) min = j1;
						else min = j4;
					else if (j3 < j4) min = j3;
					else min = j4;
				else if (j2 < j3)
					if (j2 < j4) min = j2;
					else min = j4;
				else if (j3 < j4) min = j3;
				else min = j4;

				if (j5 < min) min = j5;
				if (j6 < min) min = j6;

				oneLink = partS.substring(0,min);
				if (!oneLink.equals("http://")  && !oneLink.equals("https://"))
				{
                    oneLink = oneLink.trim();
					linkExt = oneLink.substring(oneLink.length()-4);
					if (linkExt.equalsIgnoreCase(".gif") ||
						linkExt.equalsIgnoreCase(".jpeg") ||
						linkExt.equalsIgnoreCase(".jpg"))
					{
						if (!vImages.contains(oneLink)) vImages.add(oneLink);
					}
				}
			}
			else
			{
				//Could not find '"' or ' ' or '>' after http, move it ahead of http, ignorning link
				 min = 4;
			}
			partS = partS.substring(min);
		}
		return vImages;
	}
%>
