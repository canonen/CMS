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
AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

Statement	stmt	= null;
ResultSet	rs	=null; 
ConnectionPool 	cp 	= null;
Connection 	conn 	= null;
int		nStep		= 1;
try
{
	cp = cp.getInstance();
	conn = cp.getConnection("report_export_new.jsp");
	stmt  = conn.createStatement();

	//Categories
	String sSql  =
			" SELECT c.category_id, c.category_name" +
			" FROM ccps_category c" +
			" WHERE c.cust_id="+cust.s_cust_id;
	rs = stmt.executeQuery(sSql);
	
	String sCategoryId = null;
	String sCategoryName = null;
	String htmlCategories = "";
	
	while (rs.next())
	{
		sCategoryId = rs.getString(1);
		sCategoryName = new String(rs.getBytes(2), "UTF-8");
	
		htmlCategories +=
			"<OPTION value=\""+sCategoryId+"\""+(((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)))?" SELECTED":"")+">" +
				sCategoryName+
			"</OPTION>";
	}
	rs.close();
	
	String sAction		= request.getParameter("Action").trim();
	String CampId 		= request.getParameter("Q");
	String LinkId		= request.getParameter("H");
	String ContentType	= request.getParameter("T");
	String FormId		= request.getParameter("F");
	String BBackCatId	= request.getParameter("B");
	String Domain		= request.getParameter("D");
	String NewsletterId	= request.getParameter("N");
	String Cache		= request.getParameter("Z");
	String CacheID		= request.getParameter("C");
	Cache = ("1".equals(Cache))?Cache:"0";
	CacheID = (CacheID==null||"".equals(CacheID))?"0":CacheID;
	
	// === === ===
	
	String sCacheStartDate = null;
	String sCacheEndDate = null;
	String sCacheAttrID = null;
	String sCacheAttrValue1 = null;
	String sCacheAttrValue2 = null;
	String sCacheAttrOperator = null;
	String sCacheUserID = "0";
	
	byte [] bval = null;
	
	if ("1".equals(Cache))
	{
		rs = stmt.executeQuery(
				" SELECT cache_start_date, cache_end_date, attr_id," +
				" attr_value1, attr_value2, attr_operator, user_id" +
				" FROM crpt_camp_summary_cache" +
				" WHERE camp_id = "+CampId+" AND cache_id = "+CacheID);
		
		if (rs.next())
		{
			sCacheStartDate = rs.getString(1);
			sCacheEndDate = rs.getString(2);
			sCacheAttrID = rs.getString(3);
			bval = rs.getBytes(4);
			sCacheAttrValue1 = (bval!=null?(new String(bval, "UTF-8")).trim():null);
			bval = rs.getBytes(5);
			sCacheAttrValue2 = (bval!=null?(new String(bval, "UTF-8")).trim():null);
			sCacheAttrOperator = rs.getString(6);
			sCacheUserID = rs.getString(7);
				
			if ( (sCacheUserID == null) || (sCacheUserID.equals("")) )
				sCacheUserID = "0";
		}
		rs.close();
	}

	String ExpDescrip = "<table cellspacing=0 cellpadding=3 border=0><tr><td align=center valign=middle colspan=2>This Target Group will be based on</td></tr>";

	rs = stmt.executeQuery("SELECT camp_name FROM cque_campaign WHERE camp_id = "+CampId+" AND cust_id = "+cust.s_cust_id);
	if (rs.next()) 
		ExpDescrip += "<td align=right valign=top>the Campaign:&nbsp;&nbsp;&nbsp;</td><td align=left valign=top><b>'"+rs.getString(1)+"'</b></td></tr><tr><td align=right valign=top>all recipients who:&nbsp;&nbsp;&nbsp;</td><td align=left valign=top>";
	else
		throw new Exception("Campaign not found.");
	rs.close();

	if (sAction.equals("RptCampSent")) ExpDescrip += "were Sent the campaign ";
	else if (sAction.equals("RptCampRcvd")) ExpDescrip += "the campaign Reached (did not bounceback) ";
	else if (sAction.equals("RptCampBBack")) ExpDescrip += "Bounced Back ";
	else if (sAction.equals("RptCampRead")) ExpDescrip += "Opened the HTML Email ";
	else if (sAction.equals("RptCampUnsub")) ExpDescrip += "Unsubscribed ";
	else if (sAction.equals("RptCampClick")) ExpDescrip += "Clicked a Link ";
	else if (sAction.equals("RptCampMultiRead")) ExpDescrip += "Opened the HTML Email more than once ";
	else if (sAction.equals("RptCampMultiClick")) ExpDescrip += "Clicked on one link multiple times ";
	else if (sAction.equals("RptCampMultiLink")) ExpDescrip += "Clicked on more than one link ";
	else if (sAction.equals("RptCampFormView")) ExpDescrip += "Viewed a Form ";
	else if (sAction.equals("RptCampFormSubmit")) ExpDescrip += "Submitted a Form ";
	else if (sAction.equals("RptCampFormMultiSubmit")) ExpDescrip += "Submitted a Form multiple times ";
	else if (sAction.equals("RptCampDomainSent")) ExpDescrip += "were Sent the campaign at "+Domain+" ";
	else if (sAction.equals("RptCampDomainBBack")) ExpDescrip += "Bounced Back from "+Domain+" ";
	else if (sAction.equals("RptCampOptout")) ExpDescrip += "Opted out of a Newsletter ";

	if ((LinkId != null) && (LinkId.length() > 0))
	{
		rs = stmt.executeQuery(
				" SELECT link_name FROM cjtk_link" +
				" WHERE link_id = "+LinkId+" AND cust_id = "+cust.s_cust_id);
		
		if (rs.next())
		{
			ExpDescrip += "<br>specifically the link: '"+rs.getString(1)+"'";
			rs.close();			
		}
		else
		{
			rs.close();
			throw new Exception("Link not found");
		}
	}

	if (ContentType != null) {
		if (ContentType.equals("H"))
			ExpDescrip += "<br>from the HTML Email ";
		if (ContentType.equals("T"))
			ExpDescrip += "<br>from the Text Email ";
		if (ContentType.equals("A"))
			ExpDescrip += "<br>from the AOL Email ";		
	}

	if ((FormId != null) && (FormId.length() > 0)){
		rs = stmt.executeQuery("SELECT form_name FROM csbs_form WHERE form_id = "+FormId+" AND cust_id = "+cust.s_cust_id);
		if (rs.next()) 
			ExpDescrip += "<br>specifically the Form: '"+rs.getString(1)+"'";
		else
			throw new Exception("Form not found");
		rs.close();
	}

	if ((BBackCatId != null) && (BBackCatId.length() > 0)){
		rs = stmt.executeQuery("SELECT category_name FROM crpt_bback_category WHERE category_id = "+BBackCatId);
		if (rs.next()) 
			ExpDescrip += "<br>specifically in the Category: '"+rs.getString(1)+"'";
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

	ExpDescrip += "</td></tr></table>";
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<title>Create Target Group</title>
</HEAD>
<SCRIPT>

function a()		{ return confirm("Are you sure?"); }

</SCRIPT>

<FORM  METHOD="POST" NAME="FT" ACTION="filter_create.jsp" TARGET="_self">
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
<INPUT TYPE="hidden" NAME="action" VALUE=<%=(sAction == null)?"\"\"":"\""+sAction+"\""%>>
<INPUT TYPE="hidden" NAME="camp_id" VALUE=<%=(CampId == null)?"\"\"":"\""+CampId+"\""%>>
<INPUT TYPE="hidden" NAME="link_id" VALUE=<%=(LinkId == null)?"\"\"":"\""+LinkId+"\""%>>
<INPUT TYPE="hidden" NAME="content_type" VALUE=<%=(ContentType == null)?"\"\"":"\""+ContentType+"\""%>>
<INPUT TYPE="hidden" NAME="form_id" VALUE=<%=(FormId == null)?"\"\"":"\""+FormId+"\""%>>
<INPUT TYPE="hidden" NAME="bback_category" VALUE=<%=(BBackCatId == null)?"\"\"":"\""+BBackCatId+"\""%>>
<INPUT TYPE="hidden" NAME="domain" VALUE=<%=(Domain == null)?"\"\"":"\""+Domain+"\""%>>
<INPUT TYPE="hidden" NAME="newsletter_id" VALUE=<%=(NewsletterId == null)?"\"\"":"\""+NewsletterId+"\""%>>
<INPUT TYPE="hidden" NAME="cache_id" VALUE=<%=(CacheID == null)?"\"0\"":"\""+CacheID+"\""%>>
<INPUT TYPE="hidden" NAME="start_date" VALUE=<%=(sCacheStartDate == null)?"\"\"":"\""+sCacheStartDate+"\""%>>
<INPUT TYPE="hidden" NAME="end_date" VALUE=<%=(sCacheEndDate == null)?"\"\"":"\""+sCacheEndDate+"\""%>>
<INPUT TYPE="hidden" NAME="attr_id" VALUE=<%=(sCacheAttrID == null)?"\"\"":"\""+sCacheAttrID+"\""%>>
<INPUT TYPE="hidden" NAME="attr_value1" VALUE=<%=(sCacheAttrValue1 == null)?"\"\"":"\""+sCacheAttrValue1+"\""%>>
<INPUT TYPE="hidden" NAME="attr_value2" VALUE=<%=(sCacheAttrValue2 == null)?"\"\"":"\""+sCacheAttrValue2+"\""%>>
<INPUT TYPE="hidden" NAME="attr_operator" VALUE=<%=(sCacheAttrOperator == null)?"\"\"":"\""+sCacheAttrOperator+"\""%>>
<INPUT TYPE="hidden" NAME="user_id" VALUE=<%=(sCacheUserID == null)?"\"0\"":"\""+sCacheUserID+"\""%>>

<INPUT TYPE="hidden" NAME="attr_list" VALUE="">


<table border="0" cellspacing=0 cellpadding=4>
	<tr>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onclick="Try_Submit();">Save</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader align=left>&nbsp;<b class=sectionheader>Step <%=(nStep++)%>:</b> Target Group Definition</td>
	</tr>
</table>
<br>

<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<TR>
					<TD nowrap>Enter target group name: </TD>
					<TD><INPUT TYPE="text" NAME="filter_name" SIZE="40" MAXLENGTH="50" value=""></TD>
					<td width="100%" rowspan="2" align="center" valign="middle" style="padding:10px;">
						<%= ExpDescrip %>
					</td> 
				</TR>
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
					<td>Categories: </td>
					<td nowrap>
						<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" width="100">
							<%= htmlCategories %>
						</SELECT>
					<%=(!canCat.bExecute && !(sSelectedCategoryId == null) && !(sSelectedCategoryId.equals("0")))
						?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
						:""%>
					</td>
				</tr>
			</TABLE>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!---- Step 2 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader align=left>&nbsp;<b class=sectionheader>Step <%=(nStep++)%>:</b> Add fields to view</td>
	</tr>
</table>
<br>

<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<TR> 
					<TD WIDTH="203" VALIGN="MIDDLE" ALIGN="RIGHT"><SELECT NAME="target" SIZE="15" STYLE="width: 202; height: 285" onDblClick="removeField()"></SELECT></TD> 
					<TD WIDTH="111" VALIGN="MIDDLE" ALIGN="CENTER" nowrap>
						<p><a class="subactionbutton" href="#" onclick="upField();">Move Up</a></p>
						<p><a class="subactionbutton" href="#" onclick="downField();">Move Down</a></p>
						<p><a class="subactionbutton" href="#" onclick="addField();"><< Move Left</a></p>
						<p><a class="subactionbutton" href="#" onclick="removeField();">Move Right >></a></p>
					</TD> 
					<TD WIDTH="203" VALIGN="MIDDLE" ALIGN="LEFT"><SELECT NAME="source" SIZE="15" STYLE="width: 200; height: 285" onDblClick="addField()"></SELECT></TD> 
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
 if (FT.filter_name.value.length == 0)
 {   alert ("Error - No target group name");  return 0;   }
 FT.attr_list.value = ""; 
 for (var j=0; j < FT.target.options.length; ++j) 
 {
	if (j > 0)
		FT.attr_list.value += ","; 
	FT.attr_list.value += attrName [ FT.target.options[j].value ]; 
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

	while (rs.next())
	{
		rs1 = rs.getString (1);
		rs2 = new String(rs.getBytes(2),"UTF-8");
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

function upField()
{
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

function downField()
{
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


function Init()
{
 var k = 0; 
 for( var j=3; j < attrParm.length; j +=3) 
	FT.source.options[k++] = new Option(attrParm[j+1], attrParm[j]);
 for(var i=0; i < FT.source.options.length; ++i) 
	itemOpt[i] = FT.source.options[i];
}

Init();

</SCRIPT>
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
