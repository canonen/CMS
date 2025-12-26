<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		java.sql.*,java.util.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

Statement	stmt;
ResultSet	rs; 
ConnectionPool 	connectionPool 	= null;
Connection 	srvConnection 	= null;
int		nStep		= 1;
try {
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("report_export_new.jsp");
	stmt  = srvConnection.createStatement();
} catch(Exception ex) {
	connectionPool.free(srvConnection);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}


//Categories
String sSql  =
		" SELECT c.category_id, c.category_name" +
		" FROM ccps_category c" +
		" WHERE c.cust_id="+cust.s_cust_id;
rs = stmt.executeQuery(sSql);

String sCategoryId = null;
String sCategoryName = null;
String htmlCategories = "";

while (rs.next()) {
	sCategoryId = rs.getString(1);
	sCategoryName = new String(rs.getBytes(2), "UTF-8");

	htmlCategories += "<OPTION value=\""+sCategoryId+"\""+(((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)))?" SELECTED":"")+">" +
			sCategoryName+
		"</OPTION>";
}

String sAction		= request.getParameter("Action").trim();
String CampId 		= request.getParameter("Q");
String LinkId		= request.getParameter("H");
String ContentType	= request.getParameter("T");
String FormId		= request.getParameter("F");
String BBackCatId	= request.getParameter("B");
String UnsubLevelId	= request.getParameter("S");
String Domain		= request.getParameter("D");
String NewsletterId	= request.getParameter("N");
String Cache		= request.getParameter("Z");
String CacheID		= request.getParameter("C");
Cache = ("1".equals(Cache))?Cache:"0";
CacheID = (CacheID==null||"".equals(CacheID))?"0":CacheID;

try {

	String ExpDescrip = "Export of ";

	rs = stmt.executeQuery("SELECT camp_name FROM cque_campaign WHERE camp_id = "+CampId+" AND cust_id = "+cust.s_cust_id);
	if (rs.next()) 
		ExpDescrip += "'"+rs.getString(1)+"' Campaign ";
	else
		throw new Exception("Campaign not found.");
	rs.close();

	if (sAction.equals("RptCampSent")) {
		ExpDescrip += "Sent ";
	} else if (sAction.equals("RptCampRcvd")) {
		ExpDescrip += "Reaching ";
	} else if (sAction.equals("RptCampBBack")) {
		ExpDescrip += "Bouncebacks ";
	} else if (sAction.equals("RptCampRead")) {
		ExpDescrip += "Open HTML Email ";
	} else if (sAction.equals("RptCampUnsub")) {
		ExpDescrip += "Unsubscribes ";
	} else if (sAction.equals("RptCampClick")) {
		ExpDescrip += "Clickthroughs ";
	} else if (sAction.equals("RptCampMultiRead")) {
		ExpDescrip += "Open HTML Email more than once ";
	} else if (sAction.equals("RptCampMultiClick")) {
		ExpDescrip += "Clicks on one link multiple times ";
	} else if (sAction.equals("RptCampMultiLink")) {
		ExpDescrip += "Clicks on more than one link ";
	} else if (sAction.equals("RptCampFormView")) {
		ExpDescrip += "Form Views ";
	} else if (sAction.equals("RptCampFormSubmit")) {
		ExpDescrip += "Form Submits ";
	} else if (sAction.equals("RptCampFormMultiSubmit")) {
		ExpDescrip += "Form Multiple Submits ";
	} else if (sAction.equals("RptCampDomainSent")) {
		ExpDescrip += "were Sent the campaign at "+Domain+" ";
	} else if (sAction.equals("RptCampDomainBBack")) {
		ExpDescrip += "Bounced Back from "+Domain+" ";
	} else if (sAction.equals("RptCampOptout")) {
		ExpDescrip += "Opted out of a Newsletter ";
    } else if (sAction.equals("RptCampDomainUnsub")) {
		ExpDescrip += "Unsubscribes from "+Domain+" ";
	} else if (sAction.equals("RptCampDomainSpam")) {
		ExpDescrip += "Unsubscribes spam complaints from "+Domain+" ";
    } else if (sAction.equals("RptCampSpamLevel")) {
		ExpDescrip += "SpamLevel";	
	}



	if ((LinkId != null) && (LinkId.length() > 0)){
		rs = stmt.executeQuery("SELECT link_name FROM cjtk_link WHERE link_id = "+LinkId+" AND cust_id = "+cust.s_cust_id);
		if (rs.next()) 
			ExpDescrip += " of '"+rs.getString(1)+"' Link ";
		else
			throw new Exception("Link not found");
		rs.close();
	}

	if (ContentType != null) {
		if (ContentType.equals("H"))
			ExpDescrip += "in HTML Email ";
		if (ContentType.equals("T"))
			ExpDescrip += "in Text Email ";
		if (ContentType.equals("A"))
			ExpDescrip += "in AOL Email ";		
	}

	if ((FormId != null) && (FormId.length() > 0)){
		rs = stmt.executeQuery("SELECT form_name FROM csbs_form WHERE form_id = "+FormId+" AND cust_id = "+cust.s_cust_id);
		if (rs.next()) 
			ExpDescrip += " of '"+rs.getString(1)+"' Form ";
		else
			throw new Exception("Form not found");
		rs.close();
	}

	if ((BBackCatId != null) && (BBackCatId.length() > 0)){
		rs = stmt.executeQuery("SELECT category_name FROM crpt_bback_category WHERE category_id = "+BBackCatId);
		if (rs.next()) 
			ExpDescrip += " in '"+rs.getString(1)+"' Category ";
		rs.close();
	}
    if ((UnsubLevelId != null) && (UnsubLevelId.length() > 0)){
		rs = stmt.executeQuery("SELECT level_name FROM crpt_unsub_level WHERE level_id = "+UnsubLevelId);
		if (rs.next()) 
			ExpDescrip += " in '"+rs.getString(1)+"' Level ";
		rs.close();
	}
	if ((NewsletterId != null) && (NewsletterId.length() > 0)){
		rs = stmt.executeQuery("SELECT display_name FROM ccps_cust_attr WHERE attr_id = "+NewsletterId+" AND cust_id = "+cust.s_cust_id);
		if (rs.next()) 
			ExpDescrip += "<br>specifically the Newsletter: '"+rs.getString(1)+"'";
		else
			throw new Exception("Newsletter Attribute not found");
		rs.close();
	}

%>
<HTML>
<HEAD>
<title>Report Export</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT>
function a()		{ return confirm("Are you sure?"); }
</SCRIPT>
</HEAD>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="Try_Submit();">Save Export</a>
		</td>
	</tr>
</table>
<br>
<FORM  METHOD="POST" NAME="FT" ACTION="report_export_save.jsp" TARGET="_self">
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
<INPUT TYPE="hidden" NAME="Action" VALUE=<%=(sAction == null)?"\"\"":"\""+sAction+"\""%>>
<INPUT TYPE="hidden" NAME="Q" VALUE=<%=(CampId == null)?"\"\"":"\""+CampId+"\""%>>
<INPUT TYPE="hidden" NAME="H" VALUE=<%=(LinkId == null)?"\"\"":"\""+LinkId+"\""%>>
<INPUT TYPE="hidden" NAME="T" VALUE=<%=(ContentType == null)?"\"\"":"\""+ContentType+"\""%>>
<INPUT TYPE="hidden" NAME="F" VALUE=<%=(FormId == null)?"\"\"":"\""+FormId+"\""%>>
<INPUT TYPE="hidden" NAME="B" VALUE=<%=(BBackCatId == null)?"\"\"":"\""+BBackCatId+"\""%>>
<INPUT TYPE="hidden" NAME="S" VALUE=<%=(UnsubLevelId== null)?"\"\"":"\""+UnsubLevelId+"\""%>>
<INPUT TYPE="hidden" NAME="D" VALUE=<%=(Domain == null)?"\"\"":"\""+Domain+"\""%>>
<INPUT TYPE="hidden" NAME="N" VALUE=<%=(NewsletterId == null)?"\"\"":"\""+NewsletterId+"\""%>>
<INPUT TYPE="hidden" NAME="C" VALUE=<%=(CacheID == null)?"\"0\"":"\""+CacheID+"\""%>>
<INPUT TYPE="hidden" NAME="Z" VALUE=<%="\""+Cache+"\""%>>

<INPUT TYPE="hidden" NAME="view" VALUE="">

<!--- Header----->
<table width=650 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader><b class=sectionheader>Reporting:</b> New Export</th>
	</tr>
	<tr>
		<td  valign=top align=center width=650>
			<table cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b><%= ExpDescrip %></b>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>

<!--- Header----->
<table width=650 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader align=left><b class=sectionheader>Step 1:</b> Choose export name and delimiter</th>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td valign=top align=center width=650>
			<table WIDTH="100%" cellspacing=1 cellpadding=2 border=0> 
				<tr>
					<td>Enter export name</TD>
					<td><INPUT TYPE="text" NAME="export_name" SIZE="20" MAXLENGTH="50" value=""></TD> 
				</tr>
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
					<td>Categories</td>
					<td>
						<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" width="100">
							<%= htmlCategories %>
						</SELECT>
						<%=(!canCat.bExecute && !(sSelectedCategoryId == null) && !(sSelectedCategoryId.equals("0")))
							?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
							:""%>
					</td>
				</tr>
				<TR>
					<TD width="150">Delimiter</TD>
					<TD width="475">
						<INPUT TYPE="radio" NAME="delim" VALUE="TAB" CHECKED>Tab
						<INPUT TYPE="radio" NAME="delim" VALUE=";">Semicolon (;)
						<INPUT TYPE="radio" NAME="delim" VALUE=",">Comma (,)
						<INPUT TYPE="radio" NAME="delim" VALUE="|">Pipe (|)
					</TD>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>

<!---- Header----->
<table width=650 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader align=left><b class=sectionheader>Step 2:</b> Add fields to view</th>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td  valign=top align=center width=650>
			<TABLE WIDTH="100%" cellpadding=2 cellspacing=1> 
				<TR> 
					<TD WIDTH="203" VALIGN="MIDDLE" ALIGN="RIGHT" ROWSPAN="7">
						<SELECT NAME="target" SIZE="15" STYLE="width: 202; height: 285" onDblClick="removeField()"></SELECT>
					</TD> 
					<TD WIDTH="111" VALIGN="MIDDLE" ALIGN="CENTER" ROWSPAN="7" nowrap>
						<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">Move Up</a></p>
						<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">Move Down</a></p>
						<br>
						<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><< Move Left</a></p>
						<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">Move Right >></a></p>
					</TD> 
					<TD WIDTH="203" VALIGN="MIDDLE" ALIGN="LEFT" ROWSPAN="7">
						<SELECT NAME="source" SIZE="15" STYLE="width: 200; height: 285" onDblClick="addField()"></SELECT>
					</TD> 
				</TR> 
			</TABLE>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</FORM>

<SCRIPT>

function Try_Submit ()
{
 if (FT.export_name.value.length == 0)
 {   alert ("Error - No export name");  return 0;   }
 if (FT.target.options.length == 0)
 {   alert ("Error - No fields selected");  return 0;   }
 FT.view.value = ""; 
 for (var j=0; j < FT.target.options.length; ++j) 
 {
	if (j > 0)
		FT.view.value += ","; 
	FT.view.value += attrName [ FT.target.options[j].value ]; 
 }
 FT.submit();
}


/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

<%
	String	attrParm = "var attrParm = new Array ('null','', '0'";
	String	attrName = "var attrName = new Array ();";
	String rs1, rs2, rs3, rs4;
	int nType;

	rs = stmt.executeQuery(
		"SELECT c.attr_id, c.display_name + '(' + t.type_name + ')', a.type_id " +
		"FROM ccps_attribute a, ccps_data_type t, ccps_cust_attr c " +
		"WHERE c.cust_id = "+cust.s_cust_id+" " +
		"AND a.attr_id = c.attr_id " +
		"AND a.type_id = t.type_id " +
		"AND c.display_seq IS NOT NULL " +
		"ORDER BY display_seq");

	while (rs.next())	{
		rs1 = rs.getString (1);
		rs2 = new String(rs.getBytes(2),"ISO-8859-1");
		nType = rs.getInt(3);
		attrParm += ",\r\n \"" + rs1 + "\",\"" + rs2 + "\",\""+ rs1 +"\""; 
		attrName += "attrName [" + rs1 + "] = \""+rs1+"\";\r\n";
	}
	rs.close();
	attrParm += ");";
%>
var itemOpt = new Array();
<%=attrParm%>
<%=attrName%>

function addField() {

	if( FT.source.selectedIndex == -1 ) return false;

	FT.target.options[FT.target.length] = new 
		Option (FT.source.options[FT.source.selectedIndex].text, FT.source.options[FT.source.selectedIndex].value);
	FT.source.options[FT.source.selectedIndex] = null;
}

function removeField() {

	if( FT.target.selectedIndex == -1 ) return false;

	FT.target.options[FT.target.selectedIndex] = null;
	
	for(var i=0; i < itemOpt.length; ++i) FT.source.options[i] = itemOpt[i]; 
	for(var i=0; i < FT.target.options.length; ++i) 
		for(var j=0; j < FT.source.options.length; ++j) 
			if( FT.target.options[i].value == FT.source.options[j].value ) {
				FT.source.options[j] = null;
				--j;
			}
	FT.source.selectedIndex	= 0;
}

function upField() {

var id, name;

	if( FT.target.selectedIndex < 1 ) return false;

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

	if( FT.target.selectedIndex == FT.target.length - 1 ) return false;

	id = FT.target.options[FT.target.selectedIndex + 1].value;
	name = FT.target.options[FT.target.selectedIndex + 1].text;
	
	FT.target.options[FT.target.selectedIndex + 1].value = FT.target.options[FT.target.selectedIndex].value;
	FT.target.options[FT.target.selectedIndex + 1].text  = FT.target.options[FT.target.selectedIndex].text;

	FT.target.options[FT.target.selectedIndex].value = id;
	FT.target.options[FT.target.selectedIndex].text  = name;
	
	FT.target.selectedIndex++;
}


function Init() {
 var k = 0; 
 for( var j=3; j < attrParm.length; j +=3) 
	FT.source.options[k++] = new Option(attrParm[j+1], attrParm[j]);
 for(var i=0; i < FT.source.options.length; ++i) 
	itemOpt[i] = FT.source.options[i];
}

Init();

/**********************************************************************/
/**********************************************************************/
/**********************************************************************/


</SCRIPT>
</body>
</HTML>
<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_new.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (srvConnection != null) connectionPool.free(srvConnection);
	}
%>
