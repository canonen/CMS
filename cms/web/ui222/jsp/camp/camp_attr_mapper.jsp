<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.adm.*,
		com.britemoon.cps.tgt.*,
		com.britemoon.cps.xcs.cti.*,
		com.britemoon.cps.imc.*,
		java.io.*,java.sql.*,
		java.util.*,org.w3c.dom.*,
		org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String sAttrIdList = request.getParameter("attr_id_list");
String sContIdList = request.getParameter("cont_id_list");
String sCampId = request.getParameter("camp_id");
String sPrintFlag = request.getParameter("print_flag");

boolean isPrintCampaign = false;
if (sPrintFlag != null && sPrintFlag.equals("1") ) {
	isPrintCampaign = true;
}

ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("camp_attr_mapper.jsp");
	stmt = conn.createStatement();
	String sSql = null;

	logger.info("camp_id = " + sCampId + ",cont_id_list=" + sContIdList);

	boolean canEditCamp = true;
	if (sCampId != null && !sCampId.equals("")) {
		int count = 0;
		rs = stmt.executeQuery("SELECT COUNT(*) " +
							   "  FROM cque_campaign" +
							   " WHERE origin_camp_id = " + sCampId +
							   "   AND status_id != " + CampaignStatus.DRAFT);
		if ( rs.next() ) { 
			count = rs.getInt(1);
		}
		rs.close();
		if (count > 0) {
			canEditCamp = false;
		}
	}
	logger.info("canEditCamp = " + canEditCamp);

	if (canEditCamp) {
		try {
			StringTokenizer contIdList = new StringTokenizer(sContIdList, ",");
			while (contIdList.hasMoreTokens()) {
				String contId = contIdList.nextToken();
				logger.info("calling web service to populate cxcs_cti_doc_attrs table for cont_id = " + contId);
				CTIDocAttributeWS docAttr = new CTIDocAttributeWS();
				docAttr.getDocAttributes(cust.s_cust_id, contId);
			}
		}
		catch (Exception ex) {}
	}
%>

<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<TITLE>Campaign Attributes Mapper</TITLE>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript" src="../../js/tab_script.js" type="text/javascript"></script>
</HEAD>
<BODY>
    <table cellspacing="0" cellpadding="4" border="0">
	    <tr>
	        <% if (canEditCamp) { %>
		    <td align="left" valign="middle"><a class="savebutton" href="#" onClick="save(true);" TARGET="_self">Save & Exit</a></td>
	        <% } else { %>
		    <td align="left" valign="middle"><a class="savebutton" href="#" onClick="save(false);" TARGET="_self">Exit</a></td>
	        <% } %>
		</tr>
    </table>
    <FORM METHOD="POST" NAME="FT" ACTION="camp_attr_mapper.jsp" TARGET="_self">
		<table id=mapper class=main width="100%" cellpadding=2 cellspacing=1> 
	        <tr> 
		        <td colspan=3 width="100%" valign="middle" align="middle">Please choose additional attributes</td>
	        </tr>
			<tr> 
				<td width="237" valign="middle" align="right" rowspan="7"><select name="target" size="15" style="width: 202; height: 285" onDblClick="removeField()"></select></td> 
				<td width="101" valign="middle" align="CENTER" rowspan="7" nowrap>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">Move Up</a></p>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">Move Down</a></p>
					<br>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><< Move Left</a></p>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">Move Right >></a></p>
				</td> 
				<td width="237" valign="middle" align="left" rowspan="7">
					<select name="source" size="15" style="width: 200; height: 285" onDblClick="addField()"></select>
				</td> 
			</tr> 
		</table>
    </FORM>

<SCRIPT LANGUAGE="JavaScript">

var itemOpt = new Array();
<%
	int i,j;
	String p1,p2,p3, pp;
	i = 0;
	j = 0;

    String selectedAttrList = new String(":");
	selectedAttrList = sAttrIdList;  // the selectedAttrList is obtained from parent
    logger.info("selectedAttrList = " + selectedAttrList);

	// the cti_doc_attrs are required attributes
    String defaultAttrList = new String(":");
	if (sContIdList != null && sContIdList.length() > 0) {
		rs = stmt.executeQuery("SELECT DISTINCT attr_id " +
							   "  FROM cxcs_cti_doc_attrs a" +
							   " WHERE a.cont_id in (" + sContIdList + ")");
		while( rs.next() ) { 
			defaultAttrList += rs.getString(1) + ":";
		}
		rs.close();
	}
    logger.info("defaultAttrList = " + defaultAttrList);

	// the fingerprint is not required for print campaigns
	String fingerprint = "isnull(c.fingerprint_seq,0)";
	if (isPrintCampaign) {
		logger.info("this is a print campaign");
		fingerprint = "0";
	}
	rs = stmt.executeQuery("SELECT c.display_name, c.attr_id, " + fingerprint +
						   "  FROM ccps_cust_attr c " +
						   " WHERE c.cust_id = " + cust.s_cust_id +
						   " ORDER BY ISNULL(c.display_seq,9999)");
	while( rs.next() ) { 
		p1 = new String(rs.getBytes(1), "ISO-8859-1");
		p2 = rs.getString(2);
		p3 = rs.getString(3);
        pp = new String(":" + p2 + ":");
		if ( defaultAttrList.indexOf(pp) >= 0 ) {
%>
FT.target.options[<%=j%>] = new Option("<%=p1%>", <%=p2%>);
FT.target.options[<%=j%>].type = 1;
<%
	        ++j;
		}
		else if ( p3.equals("0") && (selectedAttrList.indexOf(pp) < 0) ) {
%>
FT.source.options[<%=i%>] = new Option("<%=p1%>", <%=p2%>);
FT.source.options[<%=i%>].type = <%=p3%>;
<%
	        ++i;
		}
		else {
%>
FT.target.options[<%=j%>] = new Option("<%=p1%>", <%=p2%>);
FT.target.options[<%=j%>].type = <%=p3%>;
<%
		++j;
		}
	}
	rs.close();
%>

for (var i=0; i < FT.source.options.length; ++i) {
	itemOpt[i] = FT.source.options[i];
}

for (var j=i, k=0; j < FT.target.options.length; ++j, ++k) {
	itemOpt[j] = FT.target.options[k];
}

function addField() {

	if ( FT.source.selectedIndex == -1 ) {
		return false;
	}

	FT.target.options[FT.target.length] = new Option(FT.source.options[FT.source.selectedIndex].text, FT.source.options[FT.source.selectedIndex].value);
	FT.source.options[FT.source.selectedIndex] = null;
}

function removeField() {

	if ( FT.target.selectedIndex == -1 ) {
		return false;
	}
	
	if ( ( FT.target.options[FT.target.selectedIndex].type != null ) && ( FT.target.options[FT.target.selectedIndex].type != 0 ) ) {
		alert("You can not remove the required field"); 
		return false; 
	}
	
	
	FT.target.options[FT.target.selectedIndex]	= null;
	
	for (var i=0; i < itemOpt.length; ++i) {
		FT.source.options[i] = itemOpt[i]; 
	}
	
	for (var i=0; i < FT.target.options.length; ++i) {
		for (var j=0; j < FT.source.options.length; ++j) {
			if ( FT.target.options[i].value == FT.source.options[j].value ) {
				FT.source.options[j] = null;
				--j;
			}
		}
	}
	FT.source.selectedIndex	= 0;
}

function upField() {

    var id, name;

	if ( FT.target.selectedIndex < 1 ) {
		return false;
	}

	id = FT.target.options[FT.target.selectedIndex - 1].value;
	name = FT.target.options[FT.target.selectedIndex - 1].text;
	
	FT.target.options[FT.target.selectedIndex - 1].value = FT.target.options[FT.target.selectedIndex].value;
	FT.target.options[FT.target.selectedIndex - 1].text  = FT.target.options[FT.target.selectedIndex].text;

	FT.target.options[FT.target.selectedIndex].value = id;
	FT.target.options[FT.target.selectedIndex].text  = name;
	
	FT.target.selectedIndex--;
}

function downField() {

    var id, name;

	if ( FT.target.selectedIndex == FT.target.length - 1 ) {
		return false;
	}

	id = FT.target.options[FT.target.selectedIndex + 1].value;
	name = FT.target.options[FT.target.selectedIndex + 1].text;
	
	FT.target.options[FT.target.selectedIndex + 1].value = FT.target.options[FT.target.selectedIndex].value;
	FT.target.options[FT.target.selectedIndex + 1].text  = FT.target.options[FT.target.selectedIndex].text;

	FT.target.options[FT.target.selectedIndex].value = id;
	FT.target.options[FT.target.selectedIndex].text  = name;
	
	FT.target.selectedIndex++;
}

function save(doSave) {
	if (!doSave) {
		self.close();
		return false;		
	}
	var opener_target = opener.document.getElementById('target');
	opener_target.length = 0;
	for (var j=0; j < FT.target.options.length; j++) {
		var new_option = opener.document.createElement("OPTION");
		new_option.text = FT.target.options[j].text;
		new_option.value= FT.target.options[j].value;
		opener_target.add(new_option);
	}
	self.close();
	return false;
}

</SCRIPT>

</BODY>
</HTML>
<%	
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn); 
}
%>
