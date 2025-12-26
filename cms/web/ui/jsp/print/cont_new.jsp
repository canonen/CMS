<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.xcs.cti.*,
			java.sql.*,java.io.*,
			java.util.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);
boolean isPrintDemo = ui.getFeatureAccess(Feature.PRINT_DEMO);

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
	
String contID = null;

String contName="New Content",contStatus="",sendType="",contHTML="",contText="",contAOL="";
String creator="",creationDate="",editor="",modifyDate="",firstPers="",firstBlock="";
String unsubID="",unsubPosition="",textFlag="",htmlFlag="",aolFlag="";

int contTypeID = ContType.PRINT;
boolean isPrint = false;

String htmlTracking = "";
String htmlPersonals = "";
String htmlStatuses = "";
String htmlCharsets = "";
String htmlCurPers = "";
String jsPersonals = "";
String jsSubmitPers = "";
String htmlLogicBlocks = "";
String htmlUnsubs = "";
String htmlCategories = "";
String htmlUnsubContent = "";
String textUnsubContent = "";
String aolUnsubContent = "";
String jsUnsubs = "";

// === === ===

ConnectionPool cp	= null;
Connection conn		= null;
Statement stmt		= null;
ResultSet rs		= null;

String sSql = null;
byte[] b = null;
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	//Unsubscribes
	if (unsubID == null) unsubID = "-1";
	if (unsubPosition == null) unsubPosition = "-1";
	String tmpUnsubID = "";
	
	sSql = 
		" SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
		" FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
						   
	rs = stmt.executeQuery(sSql);
	while (rs.next())
	{
		tmpUnsubID = rs.getString(1);
		if (unsubID.equals(tmpUnsubID))
		{
			htmlUnsubs += "<option selected value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
		}
		else
		{
			htmlUnsubs += "<option value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
		}
		
		htmlUnsubContent +=
			"<textarea style=display:none name=UnsubContentHTML"+tmpUnsubID+">"+
			new String(rs.getBytes(3),"UTF-8")+"</textarea>\n";
			
		textUnsubContent +=
			"<textarea style=display:none name=UnsubContentText"+tmpUnsubID+">"+
			new String(rs.getBytes(4),"UTF-8")+"</textarea>\n";
			
		aolUnsubContent +=
			"<textarea style=display:none name=UnsubContentAOL"+tmpUnsubID+">"+
			new String(rs.getBytes(5),"UTF-8")+"</textarea>\n";

		jsUnsubs += "if (document.all.unsubID.value == "+tmpUnsubID+") {\n" +
					"	if (act=='1') unTxt = FT.UnsubContentText"+tmpUnsubID+".value;\n" +
					"	if (act=='2') unTxt = FT.UnsubContentHTML"+tmpUnsubID+".value;\n" +
					"	if (act=='3') unTxt = FT.UnsubContentAOL"+tmpUnsubID+".value;\n" +
					"}\n";
	}
	rs.close();

	//Statuses
	String tmpStatusID = "";
	sSql =
		" SELECT status_id, status_name" +
		" FROM ccnt_cont_status" +
		" WHERE UPPER(status_name) <> 'DELETED' " +
           " AND UPPER(status_name) NOT LIKE '%PENDING%' ";
	rs = stmt.executeQuery(sSql);
	while (rs.next())
	{
		tmpStatusID = rs.getString(1);
		if (contStatus.equals(tmpStatusID))
			htmlStatuses += "<option selected value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";
		else
			htmlStatuses += "<option value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";
	}
	rs.close();
	
	//Charsets
	String tmpCharsetID = "";
	rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
	while (rs.next())
	{
		tmpCharsetID = rs.getString(1);			
		if (sendType.equals(tmpCharsetID))
			htmlCharsets += "<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
		else
			htmlCharsets += "<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";			
	}
	rs.close();

	htmlCategories =
		CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.CONTENT, contID, sSelectedCategoryId);

%>

<html>
<head>
<title>Content</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body>
<form name="FT" method="post" action="../cont/cont_save.jsp" style="display:inline;">
<table cellpadding="0" cellspacing="0" border="0" width="650">
	<col>
	<tr height="30">
		<td valign="middle">
			<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
			<input type=hidden name=contentID value="<%=((contID!=null)?contID:"")%>">
			<input type=hidden name=destLogicID value="">
			<input type="hidden" name="disposition_id" value="0"/>
			<input type="hidden" name="object_type" value="<%=String.valueOf(ObjectType.CONTENT)%>"/>
			<input type="hidden" name="object_id" value="<%=(contID != null)?contID:"0"%>"/>
			<INPUT TYPE="hidden" NAME="aprvl_request_id" value="">
			<input type="hidden" name="contTypeID" value="<%= String.valueOf(contTypeID) %>"/>
			<%= htmlUnsubContent %>
			<%= textUnsubContent %>
			<%= aolUnsubContent %>
			<!-- Unsubscription Text default 
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">UnsubContentText</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentText"/></xsl:attribute>
			        </xsl:element>

			<!-- Unsubscription HTML default 
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">UnsubContentHTML</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentHTML"/></xsl:attribute>
			        </xsl:element>

			<!-- Unsubscription AOL default 
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">UnsubContentAOL</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentAOL"/></xsl:attribute>
			        </xsl:element>
			-->

			<!-- Subscribe URL default
			        <xsl:element name="input">
			        <xsl:attribute name="type">hidden</xsl:attribute>
			        <xsl:attribute name="name">SubscribeURL</xsl:attribute>
			        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/SubscribeURL"/></xsl:attribute>
			        </xsl:element>
			-->
			<input type="hidden" name="ActionSave" value="2"/>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="FT.submit();">Save</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="30">
		<td valign="middle">
			<!--- Step 1 Header----->
			<table width="100%" class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Name Your Content</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<!---- Step 1 Info----->
			<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td class=EmptyTab valign=top align=left width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTabbuffer valign=top align=left width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block1_Step1>
				<tr>
					<td class=fillTab valign=top align=center width="100%">
						<table class=main cellspacing=1 cellpadding=2 width="100%">
							<tr>
								<td width="120">Status</td>
								<td width="50%">
									<!-- Status list -->
									<select name=Statuses size=1 disabled>
										<%= htmlStatuses %>
									</select>
								</td>
								<td<%=!canCat.bRead?" style=\"display:'none'\"":""%> rowspan="2" width="80">Categories</td>
								<td<%=!canCat.bRead?" style=\"display:'none'\"":""%> rowspan="2" width="50%">
									<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" style="width:100%;">
										<%= htmlCategories %>
									</SELECT>
									<%=(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
									?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
									:""%>
								</td>
							</tr>
							<tr>
								<td width="120" nowrap>Content Name</td>
								<td width="50%">
									<input type="text"  name="ContentName"  Value="<%= contName %>" size="20" style="width:100%;" maxlength="50">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block1_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width="100%">
						<table class=main cellspacing=1 cellpadding=2 width="100%">
							<tr>
								<td width="150">Send Type</td>
								<td width="475">
									<!-- Send type list-->
									<select name=SendTypes size=1>
										<%= htmlCharsets %>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Unsubscribe Message</td>
								<td width="475">
									<select name=unsubID size=1>
										<%= htmlUnsubs %>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Position of Unsubscribe Message</td>
								<td width="475">
									<select name=unsubPos size=1>
										<option <%= (unsubPosition.equals("1")?"selected":"") %> value=1>Bottom</option>
										<option <%= (unsubPosition.equals("0")?"selected":"") %> value=0>Top</option>
										<option <%= (unsubPosition.equals("-1")?"selected":"") %> value=-1>Top and Bottom</option>
									</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr height="30">
		<td valign="middle">
			<textarea style="display:none;" name="ContentText">Print Content</textarea>
			<input type="hidden" name="ContentHTML" value="Print Content">
			<input type="hidden" name="ContentAOL" value="Print Content">
			<select name="TrackURLs" style="display:none;" multiple="MULTIPLE"></select>
			<table id="LinkTable" style="display:none;">
				<tr>
					<td class="subsectionheader"></td>
				</tr>
			</table>
			<!--- Step 1 Header----->
			<table width="100%" class=main cellspacing=0 cellpadding=0>
				<tr>
					<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Select a Print Template</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width="100%" border=0>
				<tr>
					<td class=EmptyTab valign=top align=left width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTabbuffer valign=top align=left width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTab valign=top align=center width="100%">
						<table class=main cellspacing=1 cellpadding=2 width="100%">
							<tr>
								<td>
									<table width="100%" cellspacing="0" cellpadding="2">
										<tr>
						<%
						String tmpDocID = "", tmpContName = "";
						sSql =
							" SELECT cti_doc_id, cont_name" +
							" FROM ccnt_content" +
							" WHERE type_id = '" + ContType.PRINT_TEMPLATE + "'" + 
							" AND cust_id = '" + cust.s_cust_id + "'";
							
						rs = stmt.executeQuery(sSql);

						int rowCount = 0, count = 0;
						boolean hasOneRow = false;

						int iCount = 0;
						
						while (rs.next())
						{
							tmpDocID = rs.getString(1);
							tmpContName = rs.getString(2);
							
							hasOneRow = true;
							++rowCount;
							++count;
							if (rowCount == 4)
							{
								rowCount = 1;
								%>
										</tr>
										<tr>
								<%
								
								++iCount;
							}
							%>
											<td width="33%" valign="top" align="center">
												<img border="0" src="../../images/templates/<%= tmpDocID %>_small.jpg"><br>
												<%= tmpContName %><br>
												<input type="radio" name="ctiDocID" value="<%= tmpDocID %>"><br>
												<a class="resourcebutton" target="_blank" href="../../images/templates/<%= tmpDocID %>_large.jpg">Preview</a>
											</td>
							<%
						}
						rs.close();

						if (!hasOneRow)
						{
							%><td colspan="3">There are currently no print templates to choose from.</td><%
						}
						else
						{
							for (int x=rowCount+1;x<4;++x) {
								%><td width="33%"></td><%
							}
						}
						%>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
<%
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>