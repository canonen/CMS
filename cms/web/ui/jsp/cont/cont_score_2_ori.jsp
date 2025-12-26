<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.adm.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
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
		//No values have been selected yet
		out.println("Enter formula values above and then select preview type.");
		return;
	}
	
	// === === ===

	Content cont = new Content();
	cont.s_cont_id = contID;
	if(cont.retrieve() < 1)
		throw new Exception("Invalid content. Content does not exist.");	

	// === === ===

	ContBody cont_body = new ContBody(contID);

	String textPart = cont_body.s_text_part;
	String htmlPart = cont_body.s_html_part;
	String aolPart = cont_body.s_aol_part;

	if(textPart == null) textPart = " ";
	if(htmlPart == null) htmlPart = " ";
	if(aolPart == null) aolPart = " ";
		
	// === === ===
		
	ContSendParam cont_send_param = new ContSendParam(contID);

	int unsubPos = 0;
	if(cont_send_param.s_unsub_msg_position != null)
		unsubPos = Integer.parseInt(cont_send_param.s_unsub_msg_position);

	// === === ===

	UnsubMsg unsub_msg = new UnsubMsg (cont_send_param.s_unsub_msg_id);

	String unsubTextPart = unsub_msg.s_text_msg;
	String unsubHtmlPart = unsub_msg.s_html_msg;
	String unsubAolPart = "";

	if(unsubTextPart == null) unsubTextPart = "";
	if(unsubHtmlPart == null) unsubHtmlPart = "";
	if(unsubAolPart == null) unsubAolPart = "";

	// === === ===

	String previewHtml="",previewAol="",previewText="";

	//Unsub at -1 = top and bottom OR 0 = top
	if (unsubPos <= 0)
	{
		previewHtml = unsubHtmlPart;
		previewAol = unsubAolPart;
		previewText = unsubTextPart;
	}
	
	// === === ===
	
	String filterIDs = request.getParameter("filter_ids");

	String from = request.getParameter("from");
    if (from == null) {
        from = ""; 
    }
    //System.out.println("from=" + from);
	String subj_text = request.getParameter("subjText");
    if (subj_text == null) {
        subj_text = ""; 
    }
    subj_text = subj_text.replaceAll("\u00c3\u0082\u00c2\u00ae","\u00ae"); // allow registed trademark
    subj_text = subj_text.replaceAll("\u00c3\u0082\u00c2\u00a2","\u00a2"); // allow cent
    subj_text = subj_text.replaceAll("\u00c3\u0082\u00c2\u00a3","\u00a3"); // allow pound
    //System.out.println("subjText=" + subj_text);

	String subj_html = request.getParameter("subjHtml");
    if (subj_html == null) {
        subj_html = ""; 
    }
    subj_html = subj_html.replaceAll("\u00c3\u0082\u00c2\u00ae","\u00ae"); // allow registed trademark
    subj_html = subj_html.replaceAll("\u00c3\u0082\u00c2\u00a2","\u00a2"); // allow cent
    subj_html = subj_html.replaceAll("\u00c3\u0082\u00c2\u00a3","\u00a3"); // allow pound
    //System.out.println("subjHtml=" + subj_html);

	String subj_aol = request.getParameter("subjAol");
    if (subj_aol == null) {
        subj_aol = ""; 
    }
    subj_aol = subj_aol.replaceAll("\u00c3\u0082\u00c2\u00ae","\u00ae"); // allow registed trademark
    subj_aol = subj_aol.replaceAll("\u00c3\u0082\u00c2\u00a2","\u00a2"); // allow cent
    subj_aol = subj_aol.replaceAll("\u00c3\u0082\u00c2\u00a3","\u00a3"); // allow pound
    //System.out.println("subjAol=" + subj_aol);

	// we should always use the html subject line
	subj_text = subj_html;

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
		
		//Grab the customer's attributes
		Hashtable hPers = new Hashtable();
		String attrID, attrName;
		
		String sSql =
			" SELECT c.attr_id, a.attr_name " +
			   "FROM ccps_attribute a, ccps_cust_attr c " +
			   "WHERE a.attr_id = c.attr_id AND c.cust_id = "+cust.s_cust_id;
		ResultSet rs = stmt.executeQuery(sSql);

		while (rs.next())
		{
			//Make sure this attribute is in the content
			attrID = rs.getString(1);
			attrName = rs.getString(2);
			if (attrName.equals("recip_id")) attrName = "RecipID";
			if (request.getParameter("a"+attrID) != null) hPers.put(attrID,attrName);
		}
		rs.close();
		
		// === === ===
		
		htmlPart = replacePers(htmlPart,hPers,request);
		textPart = replacePers(textPart,hPers,request);
		aolPart = replacePers(aolPart,hPers,request);
	
		// === === ===
		
		htmlPart = ContUtil.replaceScrapeBlockIds(htmlPart);
		textPart = ContUtil.replaceScrapeBlockIds(textPart);
		aolPart = ContUtil.replaceScrapeBlockIds(aolPart);
		
		// === === ===

		//Go through each part at the same time, looking for "!lb*name;id*lb!" tags
		//Vector will hold the Strings for each new paragraph and the id if it is a logic block
		Vector vHtmlPara = parseParagraph(htmlPart);
		Vector vTextPara = parseParagraph(textPart);
		Vector vAolPara = parseParagraph(aolPart);

		int numHtml = vHtmlPara.size();
		int numText = vTextPara.size();
		int numAol = vAolPara.size();
		
		//System.out.println("numHtml = "+numHtml+" numText = "+numText+" numAol = "+numAol);

		String [] aHtml = new String[numHtml];
		String [] aText = new String[numText];
		String [] aAol = new String[numAol];
		
		vHtmlPara.toArray(aHtml);
		vTextPara.toArray(aText);
		vAolPara.toArray(aAol);

		String logicID, filterValue;
		String tmpFilterID,tmpContID,tmpContHtml,tmpContAol,tmpContText;

		int j1,j2,j3;
		int posHtml=0,posText=0,posAol=0;
		boolean htmlDone = false, textDone = false, aolDone = false;
		boolean isLogic = false;
		while (!htmlDone || !textDone || !aolDone)
		{
			//Start on html, then text, then aol
			if (!htmlDone)
			{
				htmlPart = aHtml[posHtml];
				if (textDone) textPart = " ";
				else textPart = aText[posText];
				if (aolDone) aolPart = " ";
				else aolPart = aAol[posAol];

				j1 = htmlPart.indexOf("!lb*");
				j2 = textPart.indexOf("!lb*");
				j3 = aolPart.indexOf("!lb*");

				//Increment html position
				++posHtml;
				isLogic = (j1 != -1);
				if (isLogic) {
					//html is a logic block, see if others are same logic block
					if (j2 != -1) {
						if (htmlPart.equals(textPart)) {							
							++posText;	
						} else {
							//Different logic block
							textPart = " ";
							j2 = -1;
						}
					} else {
						//Normal text
						textPart = " ";
					}
					
					if (j3 != -1) {
						if (htmlPart.equals(aolPart)) {							
							++posAol;
						} else {
							//Different logic block
							aolPart = " ";
							j3 = -1;
						}
					} else {
						//Normal text
						aolPart = " ";
					}
				} else {
					//html is normal paragraph, see if others are normal paragraphs
					if (j2 != -1) {
						textPart = " ";
					} else {
						++posText;
					}

					if (j3 != -1) {
						aolPart = " ";
					} else {
						++posAol;
					}
				}
			}
			else if (!textDone)
			{
				//html is done, go through text sections
				htmlPart = " ";
				textPart = aText[posText];
				if (aolDone) aolPart = " ";
				else aolPart = aAol[posAol];
				
				j1 = -1;
				j2 = textPart.indexOf("!lb*");
				j3 = aolPart.indexOf("!lb*");

				++posText;
				
				isLogic = (j2 != -1);
				if (isLogic) {
					//Text is a logic block check aol
					if (j3 != -1) {
						if (textPart.equals(aolPart)) {							
							++posAol;
						} else {
							//Different logic block
							aolPart = " ";
							j3 = -1;
						}
					} else {
						//Normal text
						aolPart = " ";
					}
				} else {
					//Text is normal
					if (j3 != -1) {
						aolPart = " ";
					} else {
						++posAol;
					}
				}
			} else {
				//html and text are done, go through aol sections
				htmlPart = " ";
				textPart = " ";
				aolPart = aAol[posAol];
				
				j1 = -1;
				j2 = -1;
				j3 = aolPart.indexOf("!lb*");
				isLogic = (j3 != -1);
		
				++posAol;
			}

			if (!isLogic) {
				//Add paragraph
				//System.out.println("Normal Paragraph");
				if (j1 == -1 && !htmlPart.equals(" ")) previewHtml += htmlPart;
				if (j2 == -1 && !textPart.equals(" ")) previewText += textPart;
				if (j3 == -1 && !aolPart.equals(" ")) previewAol += aolPart;
			
			} else {
				//Parse out the logic block, adding each content block and its formula
				//System.out.println("Logic Block");
				
				//Grab the logicID embedded in the merge symbol
				if (!htmlDone)
					logicID = htmlPart.substring(htmlPart.indexOf(";")+1,htmlPart.indexOf("*lb!"));
				else if (!textDone)
					logicID = textPart.substring(textPart.indexOf(";")+1,textPart.indexOf("*lb!"));
				else
					logicID = aolPart.substring(aolPart.indexOf(";")+1,aolPart.indexOf("*lb!"));
				
				//Make sure the logicID is valid
				try { Integer.parseInt(logicID); }
				catch (NumberFormatException ex)
				{
					throw new Exception("Invalid Content!  One of the logic block merge symbols is invalid. Logic block ID = "+logicID);
				}
				
				//Lookup this logicID and check to see if filter is true
				byte[] b = null;				
				sSql =
					" SELECT b.cont_id, p.filter_id, b.html_part, b.aol_part, b.text_part " +
					   "FROM ccnt_cont_part p, ccnt_cont_body b " +
					   "WHERE p.parent_cont_id = "+logicID+" " +
					   "AND b.cont_id = p.child_cont_id " +
					   "ORDER BY p.seq";
				rs = stmt.executeQuery(sSql);

				boolean bUseDefault = true;
				String tmpContHtmlDef = "";
				String tmpContAolDef = "";
				String tmpContTextDef = "";
				while (rs.next())
				{
					tmpContID = rs.getString(1);
					tmpFilterID = rs.getString(2);
					
					if (tmpFilterID == null) {
						b = rs.getBytes(3);
						tmpContHtmlDef = (b==null)?"":new String(b,"UTF-8");
						b = rs.getBytes(4);
						tmpContAolDef = (b==null)?"":new String(b,"UTF-8");
						b = rs.getBytes(5);
						tmpContTextDef = (b==null)?"":new String(b,"UTF-8");
					} else {
						b = rs.getBytes(3);
						tmpContHtml = (b==null)?"":new String(b,"UTF-8");
						b = rs.getBytes(4);
						tmpContAol = (b==null)?"":new String(b,"UTF-8");
						b = rs.getBytes(5);
						tmpContText = (b==null)?"":new String(b,"UTF-8");

						filterValue = request.getParameter("a"+tmpFilterID);
						if (filterValue != null) {
							bUseDefault = false;

							if (j1 != -1) previewHtml += replacePers(tmpContHtml,hPers,request);
							if (j2 != -1) previewText += replacePers(tmpContText,hPers,request);
							if (j3 != -1) previewAol += replacePers(tmpContAol,hPers,request);
						}
					}		
				}
				rs.close();

				if (bUseDefault) {
					if (j1 != -1) previewHtml += replacePers(tmpContHtmlDef,hPers,request);
					if (j2 != -1) previewText += replacePers(tmpContTextDef,hPers,request);
					if (j3 != -1) previewAol += replacePers(tmpContAolDef,hPers,request);
				}
			}
			
			//System.out.println("isLogic? = "+isLogic+" posHtml = "+posHtml+" posText = "+posText+" posAol = "+posAol);
			//See which parts are done
			if (posHtml >= numHtml) htmlDone = true;
			if (posText >= numText) textDone = true;
			if (posAol >= numAol) aolDone = true;
		}
		if (unsubPos != 0)
		{
				previewHtml += unsubHtmlPart;
				previewAol += unsubAolPart;
				previewText += unsubTextPart;
		}
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

    String contType = request.getParameter("contType");
    //System.out.println("text = " + previewText);
    SpamFilter sf = new SpamFilter();
    StringBuffer email = new StringBuffer();
	if (contType.equals("1")) {
        sf.from(from);
        sf.to("you@revotas.com");
        sf.subject(subj_text);
        sf.body(previewText);
        sf.format("text");
        sf.checkForSpam();
        //System.out.println("errorcode = " + sf.errorCode());		  
        //System.out.println("status = " + sf.status());	
		//System.out.println("hits = " + sf.hits());		  
        //System.out.println("required = " + sf.required());		  
        //System.out.println("isSpam = " + sf.isSpam());	  
        //System.out.println("explanation = " + sf.explanation());
        String report = sf.getBriteReport();
%>
<html>
<head>
<title>Content Score</title>
<%@ include file="../header.html" %>
</head>
<body>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="color: #ffffff;font-family:arial;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Score Overview</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=1 cellpadding=0>
  <tr><td><table style="font-size: 11px;font-family:arial;background-color:#eeeeee;" cellspacing=1 cellpadding=2 border=0>
            <tr><td>Total Score: <b><%= sf.hits() %></b></td></tr>
            <tr><td>Minimal Spam Score: <b><%= sf.required() %></b></td></tr>
            <tr><td>Is This Considered Spam?: <b><%=(sf.isSpam())?"Yes":"No"%></b></td></tr>
			<tr><td><br><br><u>Disclaimer</u>: Revotas makes no representation concerning the accuracy of the scores or the implied recommendations provided herein. These are informational only and Revotas does not guarantee that your email will be delivered to its intended recipient.</td></tr>
          </table></td></tr>
  <tr><td>&nbsp;</td></tr>
</table>
<Br/>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="font-family:arial;font-size: 11px;color: #ffffff;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Score Detail</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=1 cellpadding=0>
  <tr><td><table style="font-size: 11px;font-family:arial;background-color:#eeeeee;" width=100% cellspacing=1 cellpadding=3 border=0>
            <%=(report.equals(""))?"<tr><td>Detail is not available</td></tr>":"<tr><td><b>Score</b></td><td><b>Rule</b></td><td><b>Description</b></td></tr>"+report%>
          </table></td></tr>
  <tr><td>&nbsp;</td></tr>
</table>
<Br/>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="font-family:arial;color: #ffffff;font-family:arial;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Message</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=1 cellpadding=0>
  <tr><td><table class=main width=100% cellspacing=0 cellpadding=3 border=0>
            <tr><td><textarea cols=150 rows=25 wrap=hard>From: <%= from + "\n"%>Subject: <%= subj_text + "\n\n" %><%= previewText %></textarea>
            </td></tr>
          </table></td></tr>
</table> 
<%
	}
    else if (contType.equals("2")) {
        //System.out.println("html = " + previewHtml);
        sf.from(from);
        sf.to("you@revotas.com");
        sf.subject(subj_html);
        sf.body(previewHtml);
        sf.format("html");
        sf.checkForSpam();
        //System.out.println("errorcode = " + sf.errorCode());		  
        //System.out.println("status = " + sf.status());		  
        //System.out.println("explanation = " + sf.explanation());		  
        //System.out.println("hits = " + sf.hits());		  
        //System.out.println("required = " + sf.required());		
        //System.out.println("isSpam = " + sf.isSpam());
        String report = sf.getBriteReport();
        // we need to do some surgery with the returned html 
        previewHtml = previewHtml.replaceFirst("<TABLE cellSpacing=1 cellPadding=10 width=500","<TABLE cellSpacing=0 cellPadding=0 width=100%");
%>
<html>
<head>
<title>Content Score</title>
<%@ include file="../header.html" %>
</head>
<body>

<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="font-family:arial;color: #ffffff;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Score Overview</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=1 cellpadding=0>
  <tr><td><table style="font-size: 11px;font-family:arial;background-color:#eeeeee;" cellspacing=1 cellpadding=2 border=0>
            <tr><td>Total Score: <b><%= sf.hits() %></b></td></tr>
            <tr><td>Minimal Spam Score: <b><%= sf.required() %></b></td></tr>
            <tr><td>Is This Considered Spam?: <b><%=(sf.isSpam())?"Yes":"No"%></b></td></tr>
			<tr><td><br><br><u>Disclaimer</u>: Revotas makes no representation concerning the accuracy of the scores or the implied recommendations provided herein. These are informational only and Revotas does not guarantee that your email will be delivered to its intended recipient.</td></tr>
          </table></td></tr>
  <tr><td>&nbsp;</td></tr>
</table>
<Br/>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="font-family:arial;color: #ffffff;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Score Detail</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=1 cellpadding=0>
  <tr><td><table style="font-size: 11px;font-family:arial;background-color:#eeeeee;" width=100% cellspacing=1 cellpadding=3 border=0>
            <%=(report.equals(""))?"<tr><td>Detail is not available</td></tr>":"<tr><td><b>Score</b></td><td><b>Rule</b></td><td><b>Description</b></td></tr>"+report%>
          </table></td></tr>
  <tr><td>&nbsp;</td></tr>
</table>
<Br/>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="font-family:arial;color: #ffffff;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Message</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=0 cellpadding=0>
  <tr><td><table class=main width=100% cellspacing=1 cellpadding=3 border=0>
            <tr><td><b>From</b>: <%= from %><br><b>Subject</b>: <%= subj_html %><object width=100%><p><%= previewHtml %></object></td></tr>
          </table></td></tr>
</table> 
<%
	}
    else {
	//System.out.println("aol = " + previewAol);
        sf.from(from);
        sf.to("you@revotas.com");
        sf.subject(subj_aol);
        sf.body(previewAol);
        sf.format("aol");
        sf.checkForSpam();
        //System.out.println("errorcode = " + sf.errorCode());		  
        //System.out.println("status = " + sf.status());		  
        //System.out.println("explanation = " + sf.explanation());		  
        //System.out.println("hits = " + sf.hits());		  
        //System.out.println("required = " + sf.required());		
        //System.out.println("isSpam = " + sf.isSpam());		    
        String report = sf.getBriteReport();
        // we need to do some surgery with the returned html 
        previewAol = previewAol.replaceFirst("<TABLE cellSpacing=1 cellPadding=10 width=500","<TABLE cellSpacing=0 cellPadding=0 width=100%");
%>
<html>
<head>
<title>Content Score</title>
<%@ include file="../header.html" %>
</head>
<body>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="font-family:arial;color: #ffffff;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Score Overview</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=0 cellpadding=0>
  <tr><td><table style="font-family:arial;background-color:#eeeeee;" cellspacing=1 cellpadding=2 border=0>
            <tr><td>Total Score: <b><%= sf.hits() %></b></td></tr>
            <tr><td>Minimal Spam Score: <b><%= sf.required() %></b></td></tr>
            <tr><td>Is This Considered Spam?: <b><%=(sf.isSpam())?"Yes":"No"%></b></td></tr>
          </table>
</td></tr>
</table>
<Br/>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="color: #ffffff;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Score Detail</b></td>
</tr>
</table>
<br/>
<table  width=100% cellspacing=1 cellpadding=0>
  <tr><td><table style="font-family:arial;background-color:#eeeeee;" width=100% cellspacing=1 cellpadding=3 border=0>
            <%=(report.equals(""))?"<tr><td>Detail is not available</td></tr>":"<tr><td><b>Score</b></td><td><b>Rule</b></td><td><b>Description</b></td></tr>"+report%>
          </table></td></tr>
  <tr><td>&nbsp;</td></tr>
</table>
<Br/>
<table width="100%" class="main" cellspacing="0" cellpadding="0">
<tr>
<td style="color: #ffffff;font-size: 12px;background-color: #555555;border-right: #000000 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid;border-bottom: #000000 1px solid;padding-top: 2px;padding-bottom: 2px;padding-left: 4px;padding-right: 2px;">&#x20;<b>Message</b></td>
</tr>
</table>
<br/>
<table width=100% cellspacing=1 cellpadding=0>
  <tr><td><table class=main width=100% cellspacing=1 cellpadding=3 border=0>
            <tr><td><b>From</b>: <%= from %><br><b>Subject</b>: <%= subj_aol %><object width=100%><p><%= previewAol %></object></td></tr>
          </table></td></tr>
</table> 
<%
	}
%>
</body>
</html>

<%!

//Parses a content paragraph returning it's paragraphs
//as a vector of Strings and logic blocks
protected Vector parseParagraph(String part) {
	Vector vPara = new Vector();
	String tmpPart = part;

	int i = tmpPart.indexOf("!lb*");
	int j = 0;
	while (i != -1) {
		vPara.add(tmpPart.substring(0,i));
		j = tmpPart.indexOf("*lb!") + 4;
		if (j != -1) {
			vPara.add(tmpPart.substring(i,j));
			tmpPart = tmpPart.substring(j);
			i = tmpPart.indexOf("!lb*");
		} else {
			i = -1;
		}
	}
	
	if (tmpPart.length() != 0)
		vPara.add(tmpPart);

	return vPara;
}

protected String replacePers (String vtext, Hashtable h, HttpServletRequest request) throws Exception {

	String tmp;
	int offset,j,i,l;

	String attrID, attrName, attrValue;
	Enumeration e = h.keys();
	for (int k=0;e.hasMoreElements();++k) {
		attrID = (String)e.nextElement();
		attrName = (String)h.get(attrID);
		
		attrValue = request.getParameter("a"+attrID);
		
		tmp = vtext;
		offset = 0;
		i = tmp.indexOf("!*"+attrName+";");
		while (i != -1) {
			tmp = tmp.substring(i);
			j = tmp.indexOf("*!");
			if (j != -1) {
				if (attrValue.length() == 0) {
					l = tmp.indexOf(";");
					if (l != -1 && l < j) {
						//Use this default since one was not provided
						attrValue = tmp.substring(l+1,j);
					}
				}
				vtext = vtext.substring(0,offset+i)+attrValue+tmp.substring(j+2);

				offset += attrValue.length()+i-2;
				tmp = tmp.substring(j);
				i = tmp.indexOf("!*"+attrName+";");
			} else {
				i = -1;
			}
		}
	}

	return vtext;
}

%>
