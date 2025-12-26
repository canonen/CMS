<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.util.*,
			java.net.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<% 
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

Statement	stmt	= null;
ResultSet	rs	= null;
ConnectionPool 	cp	= null;
Connection 	conn 	= null;
int	nStep = 1;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_link_edit.jsp");
	stmt  = conn.createStatement();
	
	String superCampID = request.getParameter("super_camp_id");
	String superLinkID = request.getParameter("super_link_id");
	String superLinkName = "New Super Campaign Link";
	String curLinkIDsParam="", curLinkIDsName ="";
	String jsInit = "";
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	if (superCampID == null) 
		throw new Exception ("No Super Campaign specified!");

	if (superLinkID != null) {
		String sSql = "SELECT super_link_name FROM crpt_super_link"
				+ " WHERE super_camp_id = "+superCampID
				+ " AND super_link_id = "+superLinkID;
		rs = stmt.executeQuery(sSql);	
		if (!rs.next()) throw new Exception("Invalid super campaign link - Doesn't exist or you are not allowed to see it");
		superLinkName = new String(rs.getBytes(1),"UTF-8");
		
		//Grab all of this super link's campaign links.
		sSql = "SELECT s.link_id, l.link_name + ':' + l.href +' (' + c.camp_name + ')'"
			+ " FROM crpt_super_link_link s, cjtk_link l, cque_campaign c"
			+ " WHERE s.link_id = l.link_id"
			+ " AND l.cont_id = c.cont_id"
			+ " AND s.super_link_id = "+superLinkID
			+ " AND s.super_camp_id = "+superCampID
			+ " ORDER BY c.camp_id, l.link_id";

		rs = stmt.executeQuery(sSql);
		String rs1,rs2;
		while (rs.next()) {

			rs1 = rs.getString (1);
			rs2 = new String (rs.getBytes(2), "UTF-8");
			curLinkIDsParam += ",\r\n \"" + rs1 + "\",\"" + rs2 + "\",\""+ rs1 +"\""; 
			curLinkIDsName += "attrName [" + rs1 + "] = \""+rs1+"\";\r\n";

			jsInit += "FT.source.selectedIndex = FT.source.length-1;\n" +
					 "addField();\n";
		}
	}
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="Try_Submit();">Save</a>&nbsp;&nbsp;&nbsp;
		</td>
	<%
	if (superLinkID != null)
	{
		%>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='super_link_delete.jsp?super_camp_id=<%= superCampID %>&super_link_id=<%= superLinkID %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>'">Delete</a>&nbsp;&nbsp;&nbsp;
		</td>
		<%
	}
	%>
		<td vAlign="middle" align="left">
			&nbsp;&nbsp;&nbsp;<a class="subactionbutton" href="super_camp_object.jsp?super_camp_id=<%= superCampID %>">Cancel &amp; Go Back</a>
		</td>
	</tr>
</table>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="super_link_save.jsp" TARGET="_self">
<input type=hidden name=super_camp_id value=<%= superCampID %>>
<input type=hidden name=super_link_id value=<%= superLinkID %>>
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

<table cellspacing="0" cellpadding="0" border="0">
<tr>
<td>
<table width="100%" class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Step <%=(nStep++)%>:</b> Choose super campaign link name</th>
	</tr>

	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width="100%">
			<br>
			<table cellspacing=0 cellpadding=0 width="100%">
				<TR>
					<TD width="150">Enter super campaign link name: </td>
					<TD><INPUT TYPE="text" NAME="super_link_name" SIZE="30" MAXLENGTH="50" value="<%= superLinkName %>"></TD>
				</TR>
			</TABLE>
			<br>
		</td>
	</tr>
	</tbody>
</table>
<BR>

<INPUT TYPE="hidden" NAME="super_links" VALUE="">

<table class=listTable cellspacing=0 cellpadding=0 width="100%">
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Step <%=(nStep++)%>:</b> Select links for super campaign link</th>
	</tr>

	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class= valign=top align=center>
			
			<table  cellspacing=0 cellpadding=0>
				<TR> 
					<TD WIDTH="435" VALIGN="MIDDLE" ALIGN="RIGHT" >
						<SELECT NAME="target" SIZE="15" STYLE="width: 435; height: 315" onDblClick="removeField()"></SELECT></TD> 
					<TD WIDTH="90" VALIGN="MIDDLE" ALIGN="CENTER" nowrap>
						<p><a class="subactionbutton" href="#" onclick="upField();">Move Up</a></p>
						<p><a class="subactionbutton" href="#" onclick="downField();">Move Down</a></p>
						<br>
						<p><a class="subactionbutton" href="#" onclick="addField();">Move Left</a></p>
						<p><a class="subactionbutton" href="#" onclick="removeField();">Move Right</a></p>
					</TD> 
					<TD WIDTH="435" VALIGN="MIDDLE" ALIGN="LEFT">
						<SELECT NAME="source" SIZE="15" STYLE="width: 435; height: 315" onDblClick="addField()"></SELECT>
					</TD> 
				</TR> 
			</TABLE>
			<br>
		</td>
	</tr>
	</tbody>
</table>
</td>
</tr>
</table>
<br>
<%----
<INPUT TYPE="button" VALUE="Preview" onClick="alert (FT.GroupSelected.value + ' // ' +
   FT.IdSelected.value + ' // ' +  FT.AdditString.value );" >
!--%>
</FORM>

<SCRIPT>

function Try_Submit ()
{
 if (FT.super_link_name.value.length == 0)
 {   alert ("Error - No super campaign link name entered.");  return 0;   }
 if (FT.target.options.length == 0)
 {   alert ("Error - No links selected.");  return 0;   }
 FT.super_links.value = ""; 
 for (var j=0; j < FT.target.options.length; ++j) 
 {
	if (j > 0)
		FT.super_links.value += ","; 
	FT.super_links.value += attrName [ FT.target.options[j].value ]; 
 }
 FT.submit();
}

<%
	String	attrParm = "var attrParm = new Array ('null','', '0'";
	String	attrName = "var attrName = new Array ();";
	String rs1, rs2;

	String extraConstraint = " AND l.link_id NOT IN" +
							" (SELECT link_id FROM crpt_super_link_link WHERE super_camp_id = "+superCampID
							+" AND super_link_id = "+superLinkID+")";
	String sSql = null;
	
	// Get list of sent campaigns from super camp's campaigns
	String sCampList = "";
	sSql = "SELECT c.camp_id FROM cque_campaign c, cque_super_camp_camp s"
		+ " WHERE c.origin_camp_id = s.camp_id"
		+ " AND c.type_id > "+CampaignType.TEST
		+ " AND s.super_camp_id = "+superCampID;
	rs = stmt.executeQuery(sSql);
	while (rs.next()) {
		sCampList += ((sCampList.length() > 0)?",":"")+rs.getString(1);
	}
out.print("<!-- "+sCampList+" -->");

	boolean bAllCampsSent = false;
	if (sCampList.length() > 0) {

		sSql = "SELECT count(s.camp_id) FROM cque_super_camp_camp s"
			+ " WHERE s.super_camp_id = "+superCampID
			+ " AND s.camp_id NOT IN (SELECT c.origin_camp_id FROM cque_campaign c"
					+" WHERE c.camp_id IN ("+ sCampList +"))";

		int nCampsNotSent = 0;
		rs = stmt.executeQuery(sSql);
		if (rs.next())
			nCampsNotSent = rs.getInt(1);

		bAllCampsSent = (nCampsNotSent == 0);

		sSql = "SELECT l.link_id, l.link_name + ':' + l.href +' (' + c.camp_name + ')'" +
				" FROM cque_campaign c, cjtk_link l" +
				" WHERE c.camp_id IN (" + sCampList + ") " +
				(superLinkID != null?extraConstraint:"") +
				" AND l.cont_id = c.cont_id" +
				" AND l.href IS NOT NULL" +
				" ORDER BY c.camp_id, l.link_name";
		rs = stmt.executeQuery(sSql);

		while (rs.next())	{
			rs1 = rs.getString (1);
			rs2 = new String (rs.getBytes(2), "UTF-8");
			attrParm += ",\r\n \"" + rs1 + "\",\"" + rs2 + "\",\""+ rs1 +"\""; 
			attrName += "attrName [" + rs1 + "] = \""+rs1+"\";\r\n";
		}
		rs.close();
	}
	attrParm += curLinkIDsParam+");";
	attrName += curLinkIDsName;
%>
var itemOpt = new Array();
<%=attrParm%>
<%=attrName%>

function addField()
{
	if( FT.source.selectedIndex == -1 ) return false;

	FT.target.options[FT.target.length] = new 
		Option (FT.source.options[FT.source.selectedIndex].text, FT.source.options[FT.source.selectedIndex].value);
	FT.source.options[FT.source.selectedIndex] = null;
}

function removeField()
{
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
 var i = 0;
 for( var j=3; j < attrParm.length; j +=3) 
	FT.source.options[k++] = new Option(attrParm[j+1], attrParm[j]);
 for(i=0; i < FT.source.options.length; ++i) 
	itemOpt[i] = FT.source.options[i];

<%= jsInit %>
}

Init();

</SCRIPT>

<%=(!bAllCampsSent?"*** Links can only be selected for campaigns that have been sent ***":"")%>

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