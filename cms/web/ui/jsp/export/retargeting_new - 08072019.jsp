<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.*,
		java.sql.*,java.util.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%! 
   	static Logger logger = null;
    public class qParm 
    { 
    	String  offset;
        String	id; 
        String	name; 
        
        public qParm(String a, String b) { id = a; name = b; offset = b; } 
    }
%>
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

String sfile_id = request.getParameter("file_id");

//*************For Retargeting

String fbUser     = request.getParameter("fbUser");
String fbStatus   = request.getParameter("fbStatus");
if(fbUser==null || fbStatus==null)
	return;

//*************For Retargeting
String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;


Statement	stmt;
ResultSet	rs; 
ConnectionPool 	connectionPool 	= null;
Connection 	srvConnection 	= null;
Connection 	srvConnection2 	= null;
Statement	stmt2;
ResultSet	rs_2; 

Connection  rtrgConnection  = null;
Statement   stmtRTRG;
ResultSet   rtrg_rs;

int		nStep		= 1;
try {
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("retargeting_new.jsp");
	stmt  = srvConnection.createStatement();
	srvConnection2 = connectionPool.getConnection("retargeting_new.jsp 2");
	stmt2  = srvConnection2.createStatement();
	
	rtrgConnection = connectionPool.getConnection("retargeting_new.jsp 2");
	stmtRTRG = rtrgConnection.createStatement();
	
} catch(Exception ex) {
	connectionPool.free(srvConnection);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

String sSql  = null;
String		CUSTOMER_ID	= cust.s_cust_id;
String		QUERY_NAME	= "";
String[]	tmp		= new String[8];
Enumeration	e;
qParm		sqlE;
Vector		parm		= new Vector();
int		FLAG = 0;

boolean 	isDisable = false;
boolean 	isInUse = false;

try {

	tmp[0] = "null";
	tmp[1] = "New target group"; 
	tmp[2] = ""; 
	tmp[3] = ""; 
	tmp[4] = ""; 
	tmp[5] = ""; 
	tmp[6] = ""; 

	int		kCamp		= -1;
	int		kTarg		= -1;
	int		kBat		= -1;
	int		kClick		= -1;
	String		kCamp0 = "0", kClick0 = "0", kTarg0 = "0", kBat0 = "0";
	String		id		= "";
	String		id2		= "";

	boolean		isChangeable 	= true;
	String		isChecked;
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
<SCRIPT>
ns4 = (document.layers)? true:false
ie4 = (document.all)   ? true:true

function brow (obj)		{ if (ns4) return (document.obj); if (ie4) return (obj.style); }
function doNotShow (type)	{ var va = brow (type); if( ie4 ) va.display = 'none'; }

function setClicker(AreaName)
{
	if (AreaName == "FR1")
	{
		clicker(FR1, FRR1, FT.id1.value, FT.addStr1.value, 1);
	}
	if (AreaName == "FR1b")
	{
		clicker(FR1b, null, FT.id1b.value, '', '1b');
	}
	if (AreaName == "FR2")
	{
		clicker(FR2, null, FT.id2.value, '', 2);
	}
	if (AreaName == "FR3")
	{
		clicker(FR3, null, FT.id3.value, '', 3);
	}
	if (AreaName == "FR4")
	{
		clicker(FR4, null, 0, '', 4);
	}
	if (AreaName == "FR5")
	{
		clicker(FR5, null, 0, '', 5);
	}
}

function clicker ( type1, type2, id, addParam, id_type )
{ 
 if (type1 != null)
 {
	doNotShow (FR1);	doNotShow (FRR1);
	doNotShow (FR1b);
	doNotShow (FR2);
	doNotShow (FR3);
	doNotShow (FR4);
	doNotShow (FR5);
	var va; 
	va = brow (type1); if( ie4 ) va.display = (va.display == 'none') ? '' : 'none'; 
	if (type2 != null)
	{
		va = brow (type2); if( ie4 ) va.display = (va.display == 'none') ? '' : 'none'; 
	}

 }

 FT.GroupSelected.value = id_type;
 FT.IdSelected.value    = id;  
 FT.AdditString.value   = addParam;
}	

function a()		{ return confirm("Are you sure?"); }

</SCRIPT>
<script language="javascript" src="../../js/tab_script.js"></script>
</HEAD>
<body>

<div class="modal fade" id="modal" name="modal">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Create New Audience</h5>
        <button style="width:50px !important" type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
       
       <form>
         <div class="form-group row">
            <label for="staticEmail" class="col-sm-3 col-form-label">Name *</label>
          <div class="col-sm-9">
           <input type="text"  class="form-control" id="aud_name"  name="aud_name" placeholder="Audience Name" >
           </div>
       </div>
     <div class="form-group row">
         <label for="inputPassword" class="col-sm-3 col-form-label">Description</label>
          <div class="col-sm-9">
           <input type="text" class="form-control" id="aud_description" name="aud_description" placeholder="Description">
       </div>
      </div>
    </form>
       
      </div>
      <div class="modal-footer">
        <button style="width:50px !important" type="button" class="savebutton" onclick="new_audience()">Create</button>
        <button style="width:50px !important" type="button" class="newbutton" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>




<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="Try_Submit();">Save Export</a>
		</td>
	</tr>
</table>
<br>
<!-- Changed for Retargeting -->
<FORM  METHOD="POST" NAME="FT" ACTION="retargeting_save.jsp?fbUser=<%=fbUser%>&fbStatus=<%=fbStatus%>" TARGET="_self">
<!-- Changed for Retargeting -->
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

<!--- Step  Header----->
<table width=750 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Choose export name and delimiter</th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td  valign=top align=center width=750 height="165" colspan=3>
			<table cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<td width="150">Enter export name</td>
					<td width="475"><INPUT TYPE="text" NAME="export_name" width="100%" SIZE="20" MAXLENGTH="50" value=""></td> 
				</tr>
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
					<td width="150">Categories</td>
					<td width="475">
						<SELECT multiple name="categories" size="5" width="100">
							<%=CategortiesControl.toHtmlOptions(cust.s_cust_id, sSelectedCategoryId)%>
						</SELECT>
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

<!--- Header----->

<!-- Retargeting Header Start -->

<%
String accounts="";

String rtgSql="select cust_id,user_id,ad_accounts,ad_accounts_name from z_retargeting_user_info with(nolock)"+
                  " where user_id='"+fbUser+"'";

rtrg_rs=stmtRTRG.executeQuery(rtgSql);

while(rtrg_rs.next())
{
	
accounts+="<option value='"+rtrg_rs.getString(3)+":"+rtrg_rs.getString(4)+"'>"+rtrg_rs.getString(4)+"</option>";

}

%>

<table width=750 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b>Select Retargeting</th>
	</tr>
	<tbody class=EditBlock id=retargeting_Step1>
			<!--Start: Select Facebook or Google Retargeting / created by Ramazan Isik  -->
			<tr>
			   <td width="150">Retargeting Group</td>
				<td>
				 <select id="retargeting" name="retargeting" onchange="display_audience()">
				   <option value="-1">--</option>
				   <option value="40">Facebook Retargeting</option>
				   <option value="50">Google Retargeting</option>
			   	</select>
				</td>
			</tr>
			
			<!-- This Fields Then will load -->
			<tr id="action_rtrg"></tr>
			<tr id="ad_accounts"></tr>
			<tr id="retargeting_audience"></tr>
			<tr id="time_period"></tr>
	     	<tr id="retargeting_schedule"></tr>
	</tbody>
</table>
<br>

<!-- Finished Targeting  -->

<table width=750 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Step 3:</b> Select recipients by group</th>
	</tr>

<tbody class=EditBlock id=block2_Step1>
<tr>
	<td valign=top align=center width=750 colspan=3>
	<INPUT TYPE="hidden" NAME="view" VALUE="">
		<table cellspacing=0 cellpadding=2 width="100%">
			<tr>
				<td align="left" valign="middle" width="50">
					<select name="chooseArea" id="chooseArea" onChange="setClicker(this[this.selectedIndex].value);">
						<option value="FR1">Campaigns</option>
						<option value="FR1b">Link Clicks</option>
						<option value="FR2">Target Groups</option>
						<option value="FR3">Batches</option>
						<option value="FR4">Bounce Backs</option>
						<option value="FR5">Unsubscribes</option>
					</select>
				</td>
				<td align="left" valign="middle" width="575">
				<INPUT TYPE="hidden" NAME="id1" VALUE="0">
				<INPUT TYPE="hidden" NAME="addStr1" VALUE="">
				<DIV id="FR1">
				<TABLE width=100% cellspacing=5 cellpadding=1>
				<TR>
					<TD>
					<SELECT NAME="R1" onChange="FT.id1.value=this[this.selectedIndex].value;clicker (null, null, FT.id1.value, FT.addStr1.value, 1);">
<% 

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql  =
			"SELECT c.camp_id, c.camp_name, t.type_name" +
			" FROM cque_campaign c, cque_camp_type t" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != " + CampaignType.TEST+
			" AND (c.status_id = " + CampaignStatus.DONE +
			" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
			" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
			" AND c.cust_id = " + cust.s_cust_id +
			" AND c.type_id = t.type_id" +
			" ORDER BY c.camp_id";
	} else {
		sSql  =
			"SELECT c.camp_id, c.camp_name, t.type_name" +
			" FROM cque_campaign c, cque_camp_type t, ccps_object_category oc" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != " + CampaignType.TEST+
			" AND (c.status_id = " + CampaignStatus.DONE +
			" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
			" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
			" AND c.cust_id = " + cust.s_cust_id +
			" AND c.type_id = t.type_id" +
			" AND c.origin_camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY c.camp_id";
	}

	rs = stmt.executeQuery(sSql);
	while(rs.next()) { 
		id = rs.getString(1); 
		kCamp ++; 
		isChecked = (kCamp == 0)? "SELECTED" : "";
		if (kCamp == 0)		kCamp0 = id;
%>
						<OPTION VALUE="<%=id%>" <%=isChecked%>><%=new String(rs.getBytes(2),"ISO-8859-1")%> (<%=rs.getString(3)%>)</OPTION>
<% 
	}  
	rs.close();
%>
					</SELECT>
					</TD>
					<TD>
					<DIV id="FRR1">
					<SELECT NAME="which1" onChange="FT.addStr1.value=this[this.selectedIndex].value;clicker (null, null, FT.id1.value, FT.addStr1.value, 1);">
						<OPTION value="1" SELECTED>All Recipients for this campaign</OPTION>
						<OPTION value="2">All Open HTML Reads for this campaign</OPTION>
						<OPTION value="3">All Bounce Backs for this campaign</OPTION>
						<OPTION value="4">All Unsubscribes for this campaign</OPTION>
						<OPTION value="5">All Click-Thrus for this campaign</OPTION>
					</SELECT>
					</DIV>
					</TD>
				</TR>
				</TABLE>
				</DIV>
				<INPUT TYPE="hidden" NAME="id1b" VALUE="0">
				<DIV id="FR1b" style="display:none">
				<TABLE width=100% cellspacing=5 cellpadding=1>
				<TR>
					<TD>
					<SELECT NAME="R1b" onChange="FT.id1b.value=this[this.selectedIndex].value;clicker (null, null, FT.id1b.value, '', '1b');">
<%

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql  =
			"SELECT c.camp_id, c.camp_name" +
			" FROM cque_campaign c" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != 1" +
			" AND c.status_id = " + CampaignStatus.DONE +
			" AND c.cust_id = " + cust.s_cust_id +
			" ORDER BY c.camp_id";
	} else {
		sSql  =
			"SELECT c.camp_id, c.camp_name" +
			" FROM cque_campaign c, ccps_object_category oc" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != 1" +
			" AND c.status_id = " + CampaignStatus.DONE +
			" AND c.cust_id = " + cust.s_cust_id +
			" AND c.origin_camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY c.camp_id";
	}

	rs = stmt.executeQuery(sSql);
	String	sName = null;
	while (rs.next()) { 
		id = rs.getString(1);
		sName = new String(rs.getBytes(2),"ISO-8859-1");
		rs_2 = stmt2.executeQuery("SELECT DISTINCT link_id, link_name"
			+ " FROM cjtk_link l, cque_campaign c"
			+ " WHERE l.cont_id = c.cont_id AND c.camp_id = " + id);
		while(rs_2.next()) {
			id2 = id + ":" + rs_2.getString(1);
			++kClick; 
			isChecked = (kClick == 0)? "SELECTED" : "";
			if (kClick == 0)		kClick0 = id2;
%>
						<OPTION VALUE="<%=id2%>" <%=isChecked%>>[<%=sName%>] <%=new String(rs_2.getBytes(2),"ISO-8859-1")%></LI>
<%
		}
		rs_2.close();
	}
	rs.close();
%>
					</SELECT>
					</TD>
				</TR>
				</TABLE>
				</DIV>
				<INPUT TYPE="hidden" NAME="id2" VALUE="0">
				<DIV id="FR2" style="display:none">
				<TABLE width=100% cellspacing=5 cellpadding=1>
				<TR>
					<TD>
					<SELECT NAME="R2" onChange="FT.id2.value=this[this.selectedIndex].value;clicker (null, null, FT.id2.value, '', 2);">
<%

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql  =
			"SELECT filter_id, filter_name" +
			" FROM ctgt_filter" +
			" WHERE filter_name IS NOT NULL AND origin_filter_id IS NULL" +
			" AND type_id = " + FilterType.MULTIPART +
			" AND status_id != " + FilterStatus.DELETED +
			" AND cust_id = " + cust.s_cust_id +
			" ORDER BY filter_name";
	} else {
		sSql  =
			"SELECT f.filter_id, f.filter_name" +
			" FROM ctgt_filter f, ccps_object_category oc" +
			" WHERE f.filter_name IS NOT NULL AND f.origin_filter_id IS NULL" +
			" AND f.type_id = " + FilterType.MULTIPART +
			" AND f.status_id != " + FilterStatus.DELETED +
			" AND f.cust_id = " + cust.s_cust_id +
			" AND f.filter_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY f.filter_name";
	}

	rs = stmt.executeQuery(sSql);
	while(rs.next()) { 
		id = rs.getString(1);
		++kTarg;
		isChecked = (kTarg == 0)? "SELECTED" : "";
		if (kTarg == 0)		kTarg0 = id;
%>
						<OPTION VALUE="<%=id%>" <%=isChecked%>><%=new String(rs.getBytes(2),"ISO-8859-1")%></OPTION>
<%
	} 
	rs.close();
%>
					</SELECT>
					</TD>
				</TR>
				</TABLE>
				</DIV>
				<INPUT TYPE="hidden" NAME="id3" VALUE="0">
				<DIV id="FR3" style="display:none">
				<TABLE width=100% cellspacing=5 cellpadding=1>
				<TR>
					<TD>
					<SELECT NAME="R3" onChange="FT.id3.value=this[this.selectedIndex].value;clicker (null, null, FT.id3.value, '', 3);"> 
<% 

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i, cupd_batch b" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + cust.s_cust_id + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + cust.s_cust_id +
			" ORDER BY type_id, batch_name";
	} else {
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + cust.s_cust_id + 
				" AND oc.object_id = i.import_id" +
				" AND oc.type_id = " + ObjectType.IMPORT +
				" AND oc.cust_id = " + cust.s_cust_id +
				" AND oc.category_id = " + sSelectedCategoryId + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + cust.s_cust_id +
			" ORDER BY type_id, batch_name";
	}

	rs = stmt.executeQuery(sSql);
	while(rs.next()) { 
		id = rs.getString(1);
		++kBat;
		isChecked = (kBat == 0)? "SELECTED" : "";
		if (kBat == 0)		kBat0 = id;
%>
						<OPTION VALUE="<%=id%>" <%=isChecked%>><%= new String(rs.getBytes(2),"ISO-8859-1") %></OPTION>
<%
	}
	rs.close();
%>
					</SELECT>
					</TD>
				</TR>
				</TABLE>
				</DIV>
				<DIV id="FR4" style="display:none">
				<TABLE width=100% cellspacing=5 cellpadding=1>
				<TR>
					<TD>
					<SELECT NAME="R4"> 
						<OPTION SELECTED>All Bounce Backs</OPTION>
					</SELECT>
					</TD>
				</TR>
				</TABLE>
				</DIV>
				<DIV id="FR5" style="display:none">
				<TABLE width=100% cellspacing=5 cellpadding=1>
					<TR>
						<TD>
					<SELECT NAME="R5"> 
						<OPTION SELECTED>All Unsubscribes</OPTION>
					</SELECTED>
					</td>
				</tr>
				</table>
				</DIV>
				</td>
			</tr>
		</table>
	</td>
</tr>
</tbody>
</table>
<br>

<!--- Header----->
<table width=750 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Step 4:</b> Add Fields to Export</th>
	</tr>

	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td valign=top align=center width=750 height="165" colspan=3>
			<table cellspacing=1 cellpadding=2 width="100%">
				<TR> 
					<TD WIDTH="203" VALIGN="MIDDLE" ALIGN="RIGHT" ROWSPAN="7">
						<SELECT NAME="target" SIZE="15" STYLE="width: 202; height: 285" onDblClick="removeField()"></SELECT>
					</TD> 
					<TD WIDTH="111" VALIGN="MIDDLE" ALIGN="CENTER" ROWSPAN="7">
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
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<INPUT TYPE="hidden" NAME="GroupSelected" 	VALUE="1" >
<INPUT TYPE="hidden" NAME="IdSelected" 		VALUE="-1">
<INPUT TYPE="hidden" NAME="AdditString"		VALUE=""  >
</FORM>

<SCRIPT>

function Try_Submit ()
{
 if (FT.export_name.value.length == 0)
 {   alert ("Error - No export name");  return 0;   }
 if (FT.target.options.length == 0)
 {   alert ("Error - No fields selected");  return 0;   }
 if ( FT.GroupSelected.value == null || FT.GroupSelected.value < 1 || FT.GroupSelected.value > 5 )	
 {   alert ("Error - No one group is selected: " + FT.GroupSelected.value);  return 0;   }
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
		"FROM ccps_attribute a, ccps_cust_attr c, ccps_data_type t " +
		"WHERE c.cust_id = "+CUSTOMER_ID+" " +
		"AND c.attr_id = a.attr_id " +
		"AND a.type_id = t.type_id " +
		"AND c.display_seq IS NOT NULL " +
		"ORDER BY c.display_seq");

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

	FT.id1.value = "<%=kCamp0%>";
	FT.id1b.value = "<%=kClick0%>";
	FT.id2.value = "<%=kTarg0%>";
	FT.id3.value = "<%=kBat0%>";
	setClicker("FR1");
}

Init();

/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

     // Start Retargeting Functions
     
function display_audience()
	{
	
var aud_html="<td width=\"150\">Audience</td>"+
                  "<td>"+
                     "<select id=\"select_audience\" name=\"select_audience\">"+
                     
                     "</select>"+
                  "</td>"+
                  "<a class=\"subactionbutton\" href=\"#\" id=\"showmodal\" >New Audience</a>";
 
var time_checkbox="<td width=\"150\">Time Period</td>"+
	               "<td><input type=\"checkbox\" id=\"time_pr\" onclick=\"getTimePeriod(this)\"></td>";	


var action_rtrg="<td width=\"150\">Action</td>"+
                  "<td>"+
                   "<INPUT TYPE=\"radio\" NAME=\"action_rb\" VALUE=\"act_add\"CHECKED>Add Audience &nbsp;"+
              	   "<INPUT TYPE=\"radio\" NAME=\"action_rb\" VALUE=\"act_remove\">Remove Audience"+
              	   "</td>";
                     
var option_account="<%=accounts%>";
	               
var ad_account="<td width=\"150\">Ad Accounts</td>"+
                "<td>"+
                  "<select id=\"select_adaccounts\" name=\"select_adaccounts\" onchange=\"change_account()\">"+
                  "<option value=1>default</option>"+ option_account+
                   "</select>"+
                  "</td>";

               
var val=document.getElementById('retargeting').value;
	
	if(val=="40")
		{
	     document.getElementById('retargeting_audience').innerHTML=aud_html;
	     document.getElementById('time_period').innerHTML=time_checkbox;
	     document.getElementById('ad_accounts').innerHTML=ad_account;
	     document.getElementById('action_rtrg').innerHTML=action_rtrg;
	   
		}
	else
		{
		document.getElementById('retargeting_audience').innerHTML="";
		document.getElementById('time_period').innerHTML="";
		document.getElementById('ad_accounts').innerHTML="";
		document.getElementById('retargeting_schedule').innerHTML="";
		document.getElementById('action_rtrg').innerHTML="";
		}
				
     }
    
    
    
function change_account()
{
	
var accountID=document.getElementById('select_adaccounts').value;
var acs=accountID.split(":");


 accountID=acs[0].trim();


  
		var http = new XMLHttpRequest();
		var url = "https://dev.revotas.com/cms/ui/retargeting/getAudience.jsp"; 
		var params = "accountID="+ accountID;
		
           
		http.open("POST", url, true);
		http.setRequestHeader("Content-type",
		"application/x-www-form-urlencoded; charset=UTF-8");

		http.onreadystatechange = function() {
			if (http.readyState == 4 && http.status == 200) {
		         var serverResponse = http.responseText;
		         
      
              // var serverResponse="6114972145144--Test Audience of Ramazan*6105258287344--full_list*6061251983144--LuluCandle Visitors*6060607440544--madame_coco_tum_data*6060607255944--evidea*6058837156144--Revotas DB*6058429870344--Revotas WebSite V*";
                   serverResponse= serverResponse.substring(0,serverResponse.length-1);
               var option="";
		         if(serverResponse!="error")
		        	 {
		        	  var audiences=serverResponse;
		        	    
		        	  var aud=audiences.split("*");
		        	  
		        	  for(var i=0;i<aud.length;i++)
		        		  {
		        		  var au=aud[i].split("--");
		        		   	   
		        		   option+="<option value="+au[0]+":"+au[2]+">"+au[1]+"</option>";
		        		    
		        		  }
		        	 
		        	 document.getElementById('select_audience').innerHTML=option;  
		        	
		        }
		         
   
	            }
       }
	http.send(params);
	

}
     
function getTimePeriod(obj)
     {
	
  var time_html="<td width=\"150\">Period Type</td>"+
    "<td>"+
    	"<INPUT TYPE=\"radio\" NAME=\"time_period\" VALUE=\"hourly\"CHECKED>Hourly  "+
   	    "<INPUT TYPE=\"radio\" NAME=\"time_period\" VALUE=\"daily\">Daily &nbsp;"+
    	"<INPUT TYPE=\"radio\" NAME=\"time_period\" VALUE=\"weekly\">Weekly &nbsp;"+
	    "<INPUT TYPE=\"radio\" NAME=\"time_period\" VALUE=\"monthly\">Monthly &nbsp;"+
    "</td>";
    	 
    	if(obj.checked)
    		{
    		document.getElementById('retargeting_schedule').innerHTML=time_html;
    		}
    	else
    		{
    		document.getElementById('retargeting_schedule').innerHTML="";
    		}
    	 
      }
      
      function new_audience()
      {
    	  var ads= document.getElementById('select_adaccounts').value;
    	 	  
    	  var ad=ads.split(":");
    	  
    	  
    	  	var name        = $('#aud_name').val();
    	  	var description = "";
    	  	    description = $('aud_description').val(); 
    	  	if(name!="")
    	  		{
    	  		
    		    
    			var http = new XMLHttpRequest();
    	        var url = "https://dev.revotas.com/cms/ui/retargeting/create_audience.jsp"; 
    			var params = "account_id="+ ad[0]
    					   + "&name="+name
    					   + "&description="+description;
    	                   
    			http.open("POST", url, true);
    			http.setRequestHeader("Content-type",
    					"application/x-www-form-urlencoded; charset=UTF-8");

    			http.onreadystatechange = function() {
    				if (http.readyState == 4 && http.status == 200) {
    					var serverResponse = http.responseText;
                            if(serverResponse.trim()=="ok")
                            	{
                            	change_account();
                            	$('#modal').modal('hide');
                            	}
                            else
                            	alert("Create Audience Error");
    				}
    			}
    	     	http.send(params);
    	  		
    	  		}
    	  	else
    	  		alert("Audience Name is empty");
   
    	  
      }

   $(document).on("click","#showmodal", function(e) {
    	  	e.preventDefault();
    	   	var ads2= document.getElementById('select_adaccounts').value;
      	    if(ads2!="1")
            	{	    
    	  	 
    	  	$('#modal').modal('show');
    	  	
      	       }
      	  else
    		  alert("Select Ad Account");

    	  }); 
    	  
    	  
    	  
    	  
     
      
      
      // End Retargeting Functions


</SCRIPT>
</body>
</HTML>
<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"retargeting_new.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (stmt2 != null) stmt2.close();
		if (stmtRTRG != null) stmtRTRG.close();
		if (srvConnection != null) connectionPool.free(srvConnection);
		if (srvConnection2 != null) connectionPool.free(srvConnection2);
		if (rtrgConnection != null) connectionPool.free(rtrgConnection);
	}
%>
