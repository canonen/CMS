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

Statement	stmt;
ResultSet	rs; 
ConnectionPool 	cp 	= null;
Connection 	conn 	= null;
int	nStep = 1;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_camp_edit.jsp");
	stmt  = conn.createStatement();
} catch(Exception ex) {
	cp.free(conn);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

String superCampID = request.getParameter("super_camp_id");
String superCampName = "New Super Campaign";
String curCampIDsParam="", curCampIDsName ="";
String jsInit = "";

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

try {

	if (superCampID != null) {
		String sSql = "SELECT super_camp_name FROM cque_super_camp " +
					  "WHERE cust_id = "+cust.s_cust_id+" AND super_camp_id = "+superCampID;
		rs = stmt.executeQuery(sSql);	
		if (!rs.next()) throw new Exception("Invalid super campaign - Doesn't exist or you are not allowed to see it");
		superCampName = new String(rs.getBytes(1),"UTF-8");
		
		//Grab all of this super campaign's campaigns.
		sSql = "SELECT c.camp_id, c.camp_name + ' (' + type_name + ')' " +
			   "FROM cque_super_camp_camp cc, cque_campaign c, cque_camp_type t " +
			   "WHERE cc.super_camp_id = "+superCampID+ " " +
			   "AND c.camp_id = cc.camp_id " +
			   "AND c.type_id = t.type_id";
		rs = stmt.executeQuery(sSql);
		String rs1,rs2;
		while (rs.next()) {

			rs1 = rs.getString (1);
			rs2 = new String (rs.getBytes(2), "UTF-8");
			curCampIDsParam += ",\r\n \"" + rs1 + "\",\"" + rs2 + "\",\""+ rs1 +"\""; 
			curCampIDsName += "attrName [" + rs1 + "] = \""+rs1+"\";\r\n";

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
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="Try_Submit();">Save</a>
		</td>
	<%
	if (superCampID != null)
	{
		%>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='super_camp_delete.jsp?super_camp_id=<%= superCampID %>';">Delete</a>
		</td>
		<%
	}
	%>
	</tr>
</table>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="super_camp_save.jsp" TARGET="_self">
<input type=hidden name=super_camp_id value=<%= superCampID %>>
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

<table cellspacing="0" cellpadding="0" border="0">
<tr>
<td>
<table width=100% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step <%=(nStep++)%>:</b> Choose super campaign name</td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<TR>
					<TD width="150" align="left" valign="middle">
						Enter super campaign name: 
					</td>
					<TD align="left" valign="middle">
						<INPUT TYPE="text" NAME="super_camp_name" SIZE="30" MAXLENGTH="50" value="<%= superCampName %>">
					</TD>
				</TR>
			</TABLE>
		</td>
	</tr>
	</tbody>
</table>
<BR><BR>

<INPUT TYPE="hidden" NAME="super_camps" VALUE="">

<table width=100% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step <%=(nStep++)%>:</b> Select campaigns for super campaign</td>
	</tr>
</table>
<br>
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=center>
			<table class=main cellspacing=1 cellpadding=2>
				<TR> 
					<TD WIDTH="285" VALIGN="MIDDLE" ALIGN="RIGHT"><SELECT NAME="target" SIZE="15" STYLE="width: 285; height: 315" onDblClick="removeField()"></SELECT></TD> 
					<TD WIDTH="90" VALIGN="MIDDLE" ALIGN="CENTER" nowrap>
						<p><a class="subactionbutton" href="javascript:upField();">Move Up</a></p>
						<p><a class="subactionbutton" href="javascript:downField();">Move Down</a></p>
						<br>
						<p><a class="subactionbutton" href="javascript:addField();"><< Move Left</a></p>
						<p><a class="subactionbutton" href="javascript:removeField();">Move Right >></a></p>
					</TD> 
					<TD WIDTH="285" VALIGN="MIDDLE" ALIGN="LEFT">
						<SELECT NAME="source" SIZE="15" STYLE="width: 285; height: 315" onDblClick="addField()"></SELECT>
					</TD> 
				</TR> 
			</TABLE>
		</td>
	</tr>
	</tbody>
</table>
</td>
</tr>
</table>
<br><br>
</FORM>
<SCRIPT>

function Try_Submit ()
{
 if (FT.super_camp_name.value.length == 0)
 {   alert ("Error - No super campaign name entered.");  return 0;   }
 if (FT.target.options.length == 0)
 {   alert ("Error - No campaigns selected.");  return 0;   }
 FT.super_camps.value = ""; 
 for (var j=0; j < FT.target.options.length; ++j) 
 {
	if (j > 0)
		FT.super_camps.value += ","; 
	FT.super_camps.value += attrName [ FT.target.options[j].value ]; 
 }
 FT.submit();
}


/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

<%
	String	attrParm = "var attrParm = new Array ('null','', '0'";
	String	attrName = "var attrName = new Array ();";
	String rs1, rs2;

	String extraConstraint = " AND c.camp_id NOT IN" +
							" (SELECT camp_id FROM cque_super_camp_camp WHERE super_camp_id = "+superCampID+")";
	String sSql = null;
	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql = "SELECT c.camp_id, c.camp_name + ' (' + t.type_name + ')'" +
			" FROM cque_campaign c, cque_camp_type t" +
			" WHERE c.cust_id = "+cust.s_cust_id+
			" AND c.origin_camp_id IS NULL" +
			(superCampID != null?extraConstraint:"") +
			" AND c.type_id = t.type_id" +
			" ORDER BY c.type_id, c.camp_name";
	} else {
		sSql = "SELECT c.camp_id, c.camp_name + ' (' + t.type_name + ')'" +
			" FROM cque_campaign c, cque_camp_type t, ccps_object_category oc" +
			" WHERE c.cust_id = "+cust.s_cust_id+
			" AND c.origin_camp_id IS NULL" +
			(superCampID != null?extraConstraint:"") +
			" AND c.type_id = t.type_id" +
			" AND c.camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY c.type_id, c.camp_name";
	}
	rs = stmt.executeQuery(sSql);

	while (rs.next())	{
		rs1 = rs.getString (1);
		rs2 = new String (rs.getBytes(2), "UTF-8");
		attrParm += ",\r\n \"" + rs1 + "\",\"" + rs2 + "\",\""+ rs1 +"\""; 
		attrName += "attrName [" + rs1 + "] = \""+rs1+"\";\r\n";
	}
	rs.close();
	attrParm += curCampIDsParam+");";
	attrName += curCampIDsName;
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
 var i = 0;
 for( var j=3; j < attrParm.length; j +=3) 
	FT.source.options[k++] = new Option(attrParm[j+1], attrParm[j]);
 for(i=0; i < FT.source.options.length; ++i) 
	itemOpt[i] = FT.source.options[i];

<%= jsInit %>
}

Init();

</SCRIPT>
</HTML>
<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"super_camp_edit.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
