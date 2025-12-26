<%@ page
	language="java"
	import="javax.servlet.http.*,
			javax.servlet.*,
			com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctm.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.cnt.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.io.*,
			java.text.DateFormat, 
			java.text.SimpleDateFormat,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../../wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission canCat = user.getAccessPermission(ObjectType.OFFER);

// if input_name is not null, we will assume this page was opened from ccps/ui/jsp/ctm/sectionedit.jsp.
// we will switch to the 'selector mode', which will update the input field from sectionedit.jsp
// after a section has been made

String sInputName = BriteRequest.getParameter(request,"input_name");
String sSelectedOfferId = BriteRequest.getParameter(request,"selected_offer_id");
String sOfferSize = BriteRequest.getParameter(request,"offer_size");
String sSelectedCategoryId = request.getParameter("category_id");

if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
if (sSelectedCategoryId == null) sSelectedCategoryId = "0";

if (sOfferSize == null || sOfferSize.length() == 0) {
	sOfferSize = "1";
}



ConnectionPool cp	= null;
Connection conn		= null;
Statement stmt		= null;
ResultSet rs		= null;
String sql          = null;
try
{
	
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String availableOffersHtml = "";
	String headlineHtml = "";
	String detailHtml = "";
	String imageUrl = "";
	String firstOfferId = "";
	boolean foundSelectedOffer = false;
	// get offer list as html
	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
	sql =
		" SELECT t.offer_id, t.name, t.last_send_date " +
		"  FROM ctm_offer t " + 
		" WHERE t.size_id = " + sOfferSize +
		"   AND t.last_send_date > getDate() " +
		"   AND t.cust_id = " +  cust.s_cust_id ;
	} else {
	sql = 
		" SELECT t.offer_id, t.name, t.last_send_date " +
		"  FROM ctm_offer t " + 
		" INNER JOIN ccps_object_category oc WITH(NOLOCK) ON ((t.offer_id = oc.object_id) " +
		"       AND (t.cust_id = oc.cust_id)) " + 
		" WHERE t.size_id = " + sOfferSize +
		"   AND t.last_send_date > getDate() " +
		"   AND t.cust_id = " +  cust.s_cust_id + 
		"   AND oc.type_id = " +  ObjectType.OFFER + 
		"   AND oc.category_id in (" + sSelectedCategoryId + ")";
	}
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
	SimpleDateFormat sdf = new SimpleDateFormat("yyy-MM-dd");
	StringWriter sw = new StringWriter();
	rs = stmt.executeQuery(sql);
	while (rs.next()) {
		String offer_id = rs.getString(1);
		String offer_name = rs.getString(2);
		String offer_date = rs.getString(3);
		java.util.Date dSendDate = df.parse(offer_date);
		sdf.applyPattern("MMMM d yyyy ");
		String sSendDate = sdf.format(dSendDate);
		sw.write("<option value=" + offer_id + ((offer_id.equals(sSelectedOfferId))?" selected":"") + ">");
		sw.write(HtmlUtil.escape(offer_name));
		sw.write("  " + HtmlUtil.escape(sSendDate));
		sw.write("</option>");
		if (firstOfferId == null || firstOfferId.length() == 0) {
			firstOfferId = offer_id;
		}
		if (sSelectedOfferId != null && sSelectedOfferId.equals(offer_id)) {
			foundSelectedOffer = true;
		}
	}
	availableOffersHtml = sw.toString();
	rs.close();

	String inputVal = "";
	String hiddenVal = "";

	if (!foundSelectedOffer && firstOfferId != null) {
		sSelectedOfferId = firstOfferId;
	}
	logger.info("selected offer id = " + sSelectedOfferId);
	if (sSelectedOfferId != null && sSelectedOfferId.length() > 0) {
		// get selected offer
		sql = 
			"SELECT headline_html, detail_html, image_url" +
			"  FROM ctm_offer " +
			" WHERE offer_id = " + sSelectedOfferId +
			"   AND cust_id = " + cust.s_cust_id; 
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			byte[] b = null;	
			b = rs.getBytes(1);
			try { headlineHtml = ((b == null)? null : new String(b,"UTF-8")); } catch (Exception ex) {}		
			b = rs.getBytes(2);
			try	{ detailHtml = ((b == null)? null : new String(b,"UTF-8")); } catch (Exception ex) {}
			b = rs.getBytes(3);
			try { imageUrl = ((b == null)? null : new String(b,"UTF-8")); } catch (Exception ex) {}
		}
		rs.close();
	
		inputVal = BNetPageBean.generateOfferHtml(headlineHtml, detailHtml, imageUrl);
		hiddenVal = WebUtils.convertToByteSymbolSequence(inputVal);
		 
	}
%>
<HTML>
<HEAD>
<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT src="../../../js/scripts.js"></SCRIPT>
<script src="../../../js/tab_script.js"></script>
<title>Offer Library</title>
<script language="javascript">
	
	function selectOffer()
	{
		if (opener.document.getElementById('<%=sInputName%>') == null) {
			alert('oops, there is no offer id found in parent page');
		}
		else {
			opener.document.getElementById('offer<%=sInputName%>').innerHTML = '<%=inputVal%>';
			opener.document.getElementById('<%=sInputName%>').value = '<%=hiddenVal%>';
		}
		self.close();
		return false;
	}
	
	function refresh(offerId)
	{
		if (offerId != null) {
			FT.selected_offer_id.value = offerId;
		}
		FT.submit();
	}
	
	function window.onload()
	{
		self.focus();
	}
	
	function GO(parm)
	{
		FT.submit();
	}
	
	function innerFramOnLoad()
	{
		var catName = FT.category_id[FT.category_id.selectedIndex].text;
		document.getElementById("cat_1").innerHTML = catName;
	}
	
</script>
</HEAD>
<BODY topmargin="0" leftmargin="0" style="padding:0px;" onLoad="innerFramOnLoad();">
	<form name="FT" ACTION="offer_chooser.jsp" TARGET="_self">
	<input type=hidden name=offer_size value=<%=sOfferSize%> >
	<input type=hidden name=input_name value=<%=sInputName%> >
	<input type=hidden name=selected_offer_id value=<%=sSelectedOfferId%> >
	<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
		<col>
		<tr height="50">
			<td align="left" valign="top" style="padding:0px;">
				<table cellspacing="0" cellpadding="3" border="0" class="layout" style="width:100%; height:100%;">
					<col width="100">
					<col>
					<col width="200">
					<tr>
						<td class="MenuBar" align="right" valign="middle">
							<b>Available Offers:</b>
						</td>
						<td class="MenuBar" align="left" valign="middle">
							<select name="offer_id" onchange="javascript:refresh(this[this.selectedIndex].value);" size="1">
								<%= availableOffersHtml %>
							</select>
						</td>
						<td class="MenuBar" align="left"  valign="middle">
							<table class="filterList" cellspacing="1" cellpadding="0" border="0">
								<tr>
									<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
									<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;&nbsp;&nbsp;</td>
								</tr>
							</table>
							<br>
							<div id="filterBox" style="display:none;">							
							<table class="listTable" cellspacing="0" cellpadding="2" border="0">
								<tr>
									<th valign="middle" align="left" colspan="2">Filter offers</th>
									<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
								</tr>
								<tr<%=(!canCat.bRead)?" style=\"display:none\"":""%>>
									<td valign="middle" align="right">Category:&nbsp;</td>
									<td valign="middle" align="left"><%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId, "") %></td>
									<td valign="middle" align="right">&nbsp;</td>
								</tr>
								<tr>
									<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);">Filter</a></td>
									<td valign="middle" align="right">&nbsp;</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td align="left" valign="top" style="padding:0px;">
				<table cellspacing="0" cellpadding="3" border="0" class="layout" style="width:100%; height:100%;">
					<col width="100">
					<col>
					<col width="100">
					<tr height=50 colspan=2>
						<td>&nbsp;</td>
						<td align="middle" valign=bottom>
							<a class="resourcebutton" href="javascript:selectOffer();">&nbsp;select this offer&nbsp;</a>
						</td>
					</tr>
					<tr valign=top>
						<td>&nbsp;</td>
						<td colspan=2>
							<table cellspacing="0" cellpadding="0" border="1">
								<tr><td><div id=offerPreview><%=inputVal %></div></td></tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	</form>
</BODY>
</HTML>
<%
}
catch (Exception ex) { throw ex; }
finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>
