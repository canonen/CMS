<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.tgt.Filter,
		java.sql.*,java.util.*,
		java.io.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%! 
   	String sSql = null;
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

boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);

String sfile_id = request.getParameter("file_id");

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String expName = null;
String expDelimiter = null;
String sAttribList = null;
String sParamId = null;
String sLinkId = "";
String sSelectedLinkId = null;
String sAction = null;
String sRecipOption = null;
String sParams = null;
String sExpParamId = "";
String sFileUrl = null;
int iStatusId = 0;
String sTotalRecip = null;
String ExpDescrip = "";

boolean isCamp = false;
boolean isClick = false;
boolean isTgt = false;
boolean isBatch = false;
boolean isBounce = false;
boolean isUnsub = false;

if(sfile_id != null)
{
	Export exp = new Export(sfile_id);
	expName = exp.s_export_name;
	expDelimiter = exp.s_delimiter;
	sAttribList = exp.s_attr_list;
	sAction = exp.s_action;
	sParams = exp.s_params;
	sFileUrl = exp.s_file_url;
	iStatusId = Integer.parseInt(exp.s_status_id);

	ExportParam eps = new ExportParam(sfile_id);
	sRecipOption = eps.s_param_name;
	sParamId = eps.s_param_value;
	if ( (sRecipOption != null) && (sRecipOption.equals("camp_id")))
	{
		if (sParams.indexOf("link_id") > 0)
			sExpParamId = "2";
		else
			sExpParamId = "1";
	}
	else if ( (sAction != null) && (sAction.startsWith("Tgt")))
	{
		sExpParamId = "3";
		Filter filter = null;
		if(sParamId != null)
		{
			filter = new Filter(sParamId);
			ExpDescrip = "Export of " + filter.s_filter_name;
		}
	}
	else if ( (sAction != null) && ( (sAction.equals("ExpBBack")) || (sAction.equals("ExpUnsub"))  ) )
	{
		if(sParamId == null)
			sParamId = "";
	}
	if (sAction == null)
	{
		String []arr = sParams.split(";");
		for (int k =0; k< arr.length; k++)
		{
			if (arr[k].startsWith("Exp"))
				sAction = arr[k];
			else if (arr[k].indexOf("delimiter=") > 0)
				expDelimiter = arr[k].substring(arr[k].indexOf("=")+2, arr[k].length() -1);
			else if (arr[k].indexOf("attr_list=") > 0)
				sAttribList = arr[k].substring(arr[k].indexOf("=")+1, arr[k].length());
			else if (arr[k].indexOf("camp_id=") > 0)
			{
				sRecipOption = "camp_id";
				sParamId = arr[k].substring(arr[k].indexOf("=")+1, arr[k].length());
			}
		}
	}
	else if (sAction.equalsIgnoreCase("ExpCampLinkClick"))
	{
		int linkIdIndex = sParams.indexOf("link_id=");
		if(linkIdIndex > -1)
		{
			sLinkId = sParams.substring(linkIdIndex+8, sParams.indexOf(";",linkIdIndex));		
		}
	}
	if (sFileUrl != null)
	{
		try 
		{
			InputStream is = null; 
			DataInputStream dis; 
			String str; 
			
			URL url = new URL(sFileUrl);
			is = url.openStream();                           
			dis = new DataInputStream(new BufferedInputStream(is)); 
			while ((str = dis.readLine()) != null) 
			{ 
            	if (str.indexOf("Total Recipients") != -1) 
            	{
                	sTotalRecip = str.substring(str.indexOf(":")+1, str.length());
                   	break;
                }
			} 
            is.close(); 
		}
        catch (IOException ex) 
        {
			logger.error("Exception in export_edit.jsp : ", ex);
        }
	}
}

Statement	stmt;
ResultSet	rs; 
ConnectionPool 	connectionPool 	= null;
Connection 	srvConnection 	= null;
Connection 	srvConnection2 	= null;
Statement	stmt2;
ResultSet	rs_2; 
int		nStep		= 1;
try {
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("export_edit.jsp");
	stmt  = srvConnection.createStatement();
	srvConnection2 = connectionPool.getConnection("export_edit.jsp 2");
	stmt2  = srvConnection2.createStatement();
} catch(Exception ex) {
	connectionPool.free(srvConnection);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

String		CUSTOMER_ID	= cust.s_cust_id;
String		QUERY_NAME	= "";
String[]	tmp		= new String[8];
Enumeration	e;
qParm		sqlE;
Vector		parm		= new Vector();
int			FLAG = 0;

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

	String campDet[] = new String[3];
	String	sSQLCampDet = null;
	if ((sExpParamId != null) && (sExpParamId.equals("1")))
	{
		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) 
		{
			sSQLCampDet =
				"SELECT c.camp_id, c.camp_name, t.type_name" +
				" FROM cque_campaign c, cque_camp_type t" +
				" WHERE c.origin_camp_id IS NOT NULL" +
				" AND c.type_id != " + CampaignType.TEST+
				" AND (c.status_id = " + CampaignStatus.DONE +
				" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
				" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
				" AND c.cust_id = " + cust.s_cust_id +
				" AND c.camp_id = " + sParamId +
				" AND c.type_id = t.type_id" +
				" ORDER BY c.camp_id";
		} 
		else 
		{
			sSQLCampDet = "SELECT c.camp_id, c.camp_name, t.type_name" +
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
						" AND c.camp_id = " + sParamId +
						" AND oc.category_id = " + sSelectedCategoryId +
						" ORDER BY c.camp_id";
		}
		rs = stmt.executeQuery(sSQLCampDet);
		while(rs.next()) { 
			campDet[0] = rs.getString(1);
			campDet[1] = new String(rs.getBytes(2),"ISO-8859-1");
			campDet[2] = rs.getString(3);
		}
	}
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT>
ns4 = (document.layers)? true:false
ie4 = (document.all)   ? true:false

function brow (obj)		{ if (ns4) return (document.obj); if (ie4) return (obj.style); }
function doNotShow (type)	{ var va = brow (type); if( ie4 ) va.display = 'none'; }

function setClicker(AreaName)
{
	FT.is_link_click.value = "false";
	if (AreaName == "FR1")
	{
		clicker(FR1, FRR1, FT.id1.value, FT.addStr1.value, 1);
	}
	if (AreaName == "FR1b")
	{
		FT.is_link_click.value = "true";
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

function ExportWin(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,menubar=yes,toolbar=yes,location=no,status=yes,height=600,width=500';
	SmallWin = window.open(freshurl,'ExportWin',window_features);
}
</SCRIPT>
<script language="javascript" src="../../js/tab_script.js"></script>
</HEAD>
<body>

<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="Try_Submit();">Update & Save</a>
		</td>
	</tr>
</table>
<br>
<%if ((sExpParamId != null) && (sExpParamId.equals("3")) ) { %>
<FORM  METHOD="POST" NAME="FT" ACTION="filter_stat_export_save.jsp" TARGET="_self">
<%=(sParamId!=null)?"<INPUT type=\"hidden\" name=\"filter_id\" value=\""+sParamId+"\">":""%>
<INPUT type="hidden" name="Action" value="<%=sAction%>">
<%} else { %>
<FORM  METHOD="POST" NAME="FT" ACTION="export_save.jsp" TARGET="_self">
<%} %>
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
<INPUT type="hidden" name="action_type" value="<%=sAction%>">
<INPUT type="hidden" name="is_link_click" value="false">

<%=(sfile_id!=null)?"<INPUT type=\"hidden\" name=\"file_id\" value=\""+sfile_id+"\">":""%>
<!--- Step  Header----->
<table width=800 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Choose export name and delimiter</td>
	</tr>
</table>
<br>

<!---- Step  Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=800 border=0>
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="275"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td valign="center" nowrap align="middle" width="15"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="360"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="275"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td valign="top" align="left" width="15"><img height="2" src="../../images/blank.gif" width="1"></td>
		<td class="fillTabbuffer" valign="top" align="left" width="360"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>

	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class="fillTab" valign="top" align="center" width=400>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="150">Enter export name</td>
					<td width="475"><INPUT TYPE="text" NAME="export_name" width="100%" SIZE="40" MAXLENGTH="50" value="<%=(expName==null)?"New Export Name":expName%>"></td> 
				</tr>
				<% if (!sExpParamId.equals("3")){ %>
				<tr<%=!canCat.bRead?" style=\"display:none\"":""%>>
					<td width="150">Categories</td>
					<td width="475">
						<select multiple name="categories" size="5">
							<%=CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.EXPORT, sfile_id, sSelectedCategoryId)%>
						</select>
					</td>
				</tr>
				<%}%>
				<TR>
					<TD width="150">Delimiter</TD>
					<%if (expDelimiter != null) { %>
					<TD width="475">
						<input type="radio" name="delim" value="<%="\\t"%>"<%=(expDelimiter.equals("\\t"))?" CHECKED":""%>>Tab
						<INPUT TYPE="radio" NAME="delim" VALUE="<%=";"%>"<%=(expDelimiter.equals(";"))?" CHECKED":""%>>Semicolon (;)
						<INPUT TYPE="radio" NAME="delim" VALUE="<%=","%>"<%=(expDelimiter.equals(","))?" CHECKED":""%>>Comma (,)
						<INPUT TYPE="radio" NAME="delim" VALUE="<%="|"%>"<%=(expDelimiter.equals("|"))?" CHECKED":""%>>Pipe (|)
					</TD>
					<%} %>
				</tr>
			</table>
		</td>
		<td valign="top" align="center" width="15">&nbsp;&nbsp;&nbsp;</td>
		<td class="fillTab" valign="top" align="center" width="360">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<th align="center" valign="middle"><%=expName%>:&nbsp;<%= ExportStatus.getDisplayName(iStatusId) %></th>
				</tr>
				<tr>
					<td valign="top" align="center" style="padding:10px;" width="100%">
					<% if ( iStatusId == ExportStatus.QUEUED || iStatusId == ExportStatus.PROCESSING ) { %>
						The Export is currently processing. You cannot make changes to it until after processing is completed.
					<% } else if ( iStatusId == ExportStatus.COMPLETE ) { %>
						When last updated, the Export included 
						<b><%=sTotalRecip%></b> 
						records.<br><br>
						Click the Save &amp; Update button to recalculate the record count.
						<br><br>
						<%= (iStatusId == ExportStatus.COMPLETE)?"<a class=\"resourcebutton\" href=\""+sFileUrl+"\" onClick=\"ExportWin('"+sFileUrl+"');return false;\">View/Save</a>":"&nbsp;" %>
					<% } else if ( iStatusId == ExportStatus.ERROR ) { %>
						There was an error while processing the Target Group. 
						<% if (canSupReq) { %>
						Please contact <a href="../index.jsp?tab=Help&sec=4" target="_parent">Technical Support</a> 
						with any questions.
						<% } %>
					<% } %>
					</td>
				</tr>
			</table>
		</td>
		
	</tr>
	</tbody>
</table>
<br><br>
<%if (sExpParamId.equals("3")) { %>
<!--- Header----->
<table width=800 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Recipients by target group</td>
	</tr>
</table>
<br>
<!---- Info----->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=800 border=0>
<tr>
	<td class=EmptyTab valign=center nowrap align=middle width=800><img height=2 src="../../images/blank.gif" width=1></td>
</tr>
<tr>
	<td class=fillTabbuffer valign=top align=left width=800><img height=2 src="../../images/blank.gif" width=1></td>
</tr>
<tbody class=EditBlock id=block2_Step1>
<tr>
	<td class=fillTab valign=top align=center width=800 colspan=2>
		<INPUT TYPE="hidden" NAME="view" VALUE="">
		<table class=main cellspacing=1 cellpadding=2 width="100%">
			<tr>
				<td class=fillTab valign=top align=center width=800>
				<table class=main cellspacing=1 cellpadding=2 width="100%">
					<tr>
						<td align="center" valign="middle" style="padding:10px;">
							<b><%= ExpDescrip %></b>
						</td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
	</td>
</tr>
</tbody>
</table>
<br><br>				
<%} else { %>
<!--- Header----->
<table width=800 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Select recipients by group</td>
	</tr>
</table>
<br>

<!---- Info----->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=800 border=0>
<tr>
	<td class=EmptyTab valign=center nowrap align=middle width=800><img height=2 src="../../images/blank.gif" width=1></td>
</tr>
<tr>
	<td class=fillTabbuffer valign=top align=left width=800><img height=2 src="../../images/blank.gif" width=1></td>
</tr>
<tbody class=EditBlock id=block2_Step1>
<tr>
	<td class=fillTab valign=top align=center width=800 colspan=3>
	<INPUT TYPE="hidden" NAME="view" VALUE="">
		<table class=main cellspacing=1 cellpadding=2 width="100%">
			<tr>
				<td align="left" valign="middle" width="50">
					<select name="chooseArea" id="chooseArea" onChange="setClicker(this[this.selectedIndex].value);">
					<% if ((sRecipOption != null) && sRecipOption.equals("camp_id")){ 
							isCamp = true;
					%>
						<option value="FR1" selected >Campaigns</option>
					<%}else {%>
						<option value="FR1">Campaigns</option>
					<%}%>
					<% if ((sExpParamId != null) &&	sExpParamId.equals("2") ){
							isClick = true;
					%>	
						<option value="FR1b" selected >Link Clicks</option>
					<%}else {%>
						<option value="FR1b">Link Clicks</option>
					<%}%>
					<% if ((sAction != null) && sAction.equals("ExpTgt")){	
							isTgt = true;
					%>
						<option value="FR2" selected >Target Groups</option>
					<%}else {%>
						<option value="FR2">Target Groups</option>
					<%}%>
					<% if ((sAction != null) && sAction.equals("ExpBatch")){
							isBatch = true;
					%>
						<option value="FR3" selected >Batches</option>
					<%}else {%>
						<option value="FR3">Batches</option>
					<%}%>
					<% if ((sAction != null) && sAction.equals("ExpBBack")){
							isBounce = true;
					%>
						<option value="FR4" selected >Bounce Backs</option>
					<%}else {%>
						<option value="FR4">Bounce Backs</option>
					<%}%>
					<% if ((sAction != null) && sAction.equals("ExpUnsub")){ 
							isUnsub = true;
					%>
						<option value="FR5" selected >Unsubscribes</option>
					<%}else {%>						
						<option value="FR5">Unsubscribes</option>
					<%}%>
					</select>
				</td>
				<td align="left" valign="middle" width="575">
				<INPUT TYPE="hidden" NAME="id1" VALUE="0">				
				<INPUT TYPE="hidden" NAME="addStr1" VALUE="">
				<DIV id="FR1">
				<TABLE width=100% cellspacing=5 cellpadding=1>
				<TR>
					<TD>
					<SELECT id="R1" NAME="R1" onChange="FT.id1.value=this[this.selectedIndex].value;clicker (null, null, FT.id1.value, FT.addStr1.value, 1);">
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
		isChecked = "";
		if (kCamp == 0) {
			if (isCamp) {
				if (sParamId != null) kCamp0 = sParamId;
			} else {
				isChecked ="SELECTED";
				kCamp0 = id;
			}
		}
%>
						<%if (id.equals(campDet[0])) { %>
						<OPTION VALUE="<%=campDet[0]%>" <%=isChecked%> selected ><%=campDet[1]%> (<%=campDet[2]%>)</OPTION>
						<%} else { %>
						<OPTION VALUE="<%=id%>" <%=isChecked%>><%=new String(rs.getBytes(2),"ISO-8859-1")%> (<%=rs.getString(3)%>)</OPTION>						
						<%}%>
<% 
	}  
	rs.close();
%>
					</SELECT>
					</TD>
					<TD>
					<DIV id="FRR1">					
					<SELECT NAME="which1" onChange="FT.addStr1.value=this[this.selectedIndex].value;clicker (null, null, FT.id1.value, FT.addStr1.value, 1);">
						<% if ((sAction != null) && sAction.equals("ExpCampSent")){ %>
						<OPTION value="1" SELECTED>All Recipients for this campaign</OPTION>
						<%} else {%>
						<OPTION value="1">All Recipients for this campaign</OPTION>
						<%}%>
						
						<% if ((sAction != null) && sAction.equals("ExpCampRead")){ %>
						<OPTION value="2" selected >All Open HTML Reads for this campaign</OPTION>
						<%} else {%>
						<OPTION value="2">All Open HTML Reads for this campaign</OPTION>
						<%}%>
						
						<% if ((sAction != null) && sAction.equals("ExpCampBBack")){ %>
						<OPTION value="3" selected >All Bounce Backs for this campaign</OPTION>
						<%} else {%>
						<OPTION value="3">All Bounce Backs for this campaign</OPTION>
						<%}%>

						<% if ((sAction != null) && sAction.equals("ExpCampUnsub")){ %>
						<OPTION value="4" selected >All Unsubscribes for this campaign</OPTION>
						<%} else {%>
						<OPTION value="4">All Unsubscribes for this campaign</OPTION>
						<%}%>

						<% if ((sAction != null) && sAction.equals("ExpCampClick")){ %>						
						<OPTION value="5" selected >All Click-Thrus for this campaign</OPTION>
						<%} else {%>						
						<OPTION value="5">All Click-Thrus for this campaign</OPTION>
						<%}%>						
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
					<SELECT id="R1b" NAME="R1b" onChange="FT.id1b.value=this[this.selectedIndex].value;clicker (null, null, FT.id1b.value, '', '1b');">
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
	sSelectedLinkId = sParamId.trim()+":"+sLinkId.trim();
	while (rs.next()) { 
		id = rs.getString(1);
		
		sName = new String(rs.getBytes(2),"ISO-8859-1");
		rs_2 = stmt2.executeQuery("SELECT DISTINCT link_id, link_name"
			+ " FROM cjtk_link l, cque_campaign c"
			+ " WHERE l.cont_id = c.cont_id AND c.camp_id = " + id);
		while(rs_2.next()) {
			id2 = id + ":" + rs_2.getString(1);
			
			++kClick; 
			isChecked = "";
			if (kClick == 0) {
				if (isClick) {
					if (sSelectedLinkId != null) kClick0 =  sSelectedLinkId;
				} else {
					isChecked ="SELECTED";
					kClick0 = id2;
				}
			}
%>
						<%if (id2.equals(sSelectedLinkId)) {%>
						<OPTION VALUE="<%=id2%>" selected <%=isChecked%>>[<%=sName%>] <%=new String(rs_2.getBytes(2),"ISO-8859-1")%></LI>
						<%} else {%>						
						<OPTION VALUE="<%=id2%>" <%=isChecked%>>[<%=sName%>] <%=new String(rs_2.getBytes(2),"ISO-8859-1")%></LI>
						<%}%>
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
		isChecked = "";
		if (kTarg == 0) {
			if (isTgt) {
				if (sParamId != null) kTarg0 =  sParamId;
			} else {
				isChecked ="SELECTED";
				kTarg0 = id;
			}
		}
%>
						<%  if (id.equals(sParamId)) { %>
						<OPTION VALUE="<%=id%>" selected <%=isChecked%> ><%=new String(rs.getBytes(2),"ISO-8859-1")%></OPTION>
						<% } else {%>
						<OPTION VALUE="<%=id%>" <%=isChecked%>><%=new String(rs.getBytes(2),"ISO-8859-1")%></OPTION>
						<% } %>
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
		isChecked = "";
		if (kBat == 0) {
			if (isBatch) {
				if (sParamId != null) kBat0 = sParamId;
			} else {
				isChecked ="SELECTED";
				kBat0 = id;
			}
		}
%>
						<% if (id.equals(sParamId)) { %>
						<OPTION VALUE="<%=id%>" selected <%=isChecked%>><%= new String(rs.getBytes(2),"ISO-8859-1") %></OPTION>
						<% } else {%>
						<OPTION VALUE="<%=id%>" <%=isChecked%>><%= new String(rs.getBytes(2),"ISO-8859-1") %></OPTION>
						<%}%>
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
<br><br>
<%} %>

<!--- Header----->
<table width=800 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 3:</b> Add Fields to Export</td>
	</tr>
</table>
<br>

<!---- Info----->
<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=800 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=1 src="../../images/blank.gif" width=650></td>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="left" valign="middle">
						<%@ include file="export_preview_attrs.inc"%>
					</td>
				</tr>
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
	FT.view.value += FT.target.options[j].value ; 
 }
 <%if(sExpParamId != null && !sExpParamId.equals("3")){%>
 if(FT.is_link_click.value != "false")
 {
 FT.IdSelected.value = FT.R1b.options[FT.R1b.options.selectedIndex].value;
 }
 <%}%>
 FT.submit();
}


/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

function Initialise() {
	FT.id1.value = "<%=kCamp0%>";
	FT.id1b.value = "<%=kClick0%>";
	FT.id2.value = "<%=kTarg0%>";
	FT.id3.value = "<%=kBat0%>";

	var val = FT.action_type.value;
	if (val != null){
	if (val == "ExpBBack")
		setClicker("FR4");
	else if (val == "ExpUnsub")
		setClicker("FR5");
	else if (val == "ExpBatch")
		setClicker("FR3");
	else if (val == "ExpTgt")
		setClicker("FR2");
	else if (val == "ExpCampLinkClick")
		setClicker("FR1b");
	else
		setClicker("FR1");
	}
}
<% if (!sExpParamId.equals("3")){ %>
Initialise();
<%} %>
Init();

/**********************************************************************/
/**********************************************************************/
/**********************************************************************/


</SCRIPT>
</body>
</HTML>
<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_edit.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (stmt2 != null) stmt2.close();
		if (srvConnection != null) connectionPool.free(srvConnection);
		if (srvConnection2 != null) connectionPool.free(srvConnection2);
	}
%>
