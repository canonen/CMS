<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<html>
<head>
	<title>Generate a Form URL</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>


<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

Statement	stmt	= null;
ResultSet	rs	= null; 
ConnectionPool	cp	= null;
Connection	conn	= null;

try
{
	cp= ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();


String CUSTOMER_ID = cust.s_cust_id;
String unSub_msg = request.getParameter("unsubmsgID");
boolean showFrmUnSub = false;
if (unSub_msg != null)
	showFrmUnSub = true;
%>
<body onLoad="makeURL();">
<form  name="FT" TARGET="_self">

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
			<table class="main" cellspacing="1" cellpadding="3" border="0" width="100%">
				<tr>
					<td align="right" valign="top" width="50%">
						<b>Form</b><br>
						The URL generated will point to the selected form
					</td>
					<td align="left" valign="top" width="50%">
						<select name="form_info" size="1" onChange="makeURL();">
							<option VALUE="">&nbsp;</option>
							<%
							String sSql =
							" select form_url + CASE WHEN (type_id = 3 OR type_id = 4) thEN '&I=' ELSE '&C=' END, form_name " +
							" FROM csbs_form WHERE cust_id = " + CUSTOMER_ID+
							" ORDER BY form_id DESC";
							
							if (showFrmUnSub){
							sSql = " select form_url, form_name " +
							" FROM csbs_form WHERE cust_id = " + CUSTOMER_ID +
							" and type_id in (1, 2) "+ 
							" ORDER BY form_id DESC";
							}
														
							rs = stmt.executeQuery(sSql);
							while( rs.next() )
							{
								%>			
								<option VALUE="<%=rs.getString(1)%>"> <%=new String(rs.getBytes(2),"UTF-8")%> </option>
								<%
							}
							%>
						</select>
					</td>
				</tr>
				<%
					if (!showFrmUnSub){
				%>
				<tr>
					<td align="right" valign="top" width="50%">
						<b>Campaign</b><br>
						Select "Standard Campaign" to create a URL that can be used in many campaigns
						<!-- <br>Select "Linked S2F or Auto-Respond" to associate a form submission with a S2F or AR campaign specified by a Standard campaign under Advanced Settings//-->
					</td>
					<td align="left" valign="top" width="50%">
						<select name="queue_id" size="1" onChange="makeURL();">
							<option VALUE="">&nbsp;</option>
							<option VALUE="!*linked_camp_id*!">--- Linked S2F or Auto-Respond Campaign ---</option>
							<option VALUE="!*CampaignID;*!">--- Standard Campaign ---</option>
							<%
							sSql =
							" select c.camp_id + 1, c.camp_name " +
							" FROM cque_campaign c, cque_camp_edit_info cei " +  
							" WHERE	c.origin_camp_id IS NULL AND" +
							" cei.camp_id = c.camp_id AND" +
							" c.cust_id = " + CUSTOMER_ID +
							" ORDER BY cei.modify_date DESC";

							rs = stmt.executeQuery(sSql);

							while( rs.next() )
							{
								%>
								<option VALUE="<%=rs.getString(1)%>"> <%=new String(rs.getBytes(2),"UTF-8")%></option>
								<%
							}
							rs.close();
							%>
						</select>
					</td>
				</tr>
				<%
					}
				%>
			</table>
			<br>
			<table class="main" cellspacing="1" cellpadding="3" border="0" width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:5px;">
						<a class="resourcebutton" href="javascript:copyURL();">Copy URL</a><br>
						<br><INPUT TYPE="text" name="addr" VALUE="" style="width:100%;">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<input type="hidden" name="showUnSubFrm" value="false">
</form>
<script language="JavaScript">
function makeURL()
{
    FT.showUnSubFrm.value = "<%=showFrmUnSub%>";
    if (FT.showUnSubFrm.value == "true")
    {
    	makeUnSubURL();
    }
    else
    {
	    f_index = FT.form_info.selectedIndex;
	    q_index = FT.queue_id.selectedIndex;			
		
		form_part = FT.form_info[f_index].value;
		
		if (FT.queue_id[q_index].value.length == 0) 
			form_part = form_part.substring(0, form_part.length - 3);
		if (FT.queue_id[q_index].value == '!*linked_camp_id*!') 
			form_part = form_part.substring(0, form_part.length - 3) + '&I=';
	
		FT.addr.value =  form_part + FT.queue_id[q_index].value;
	}
}

function makeUnSubURL(){
    f_index = FT.form_info.selectedIndex;		
	form_part = FT.form_info[f_index].value;
	if (f_index != 0)
		form_part = form_part + '&C=!*CampaignID;*!';
	FT.addr.value =  form_part;
}


function copyURL()
{
	var theURL;
	var theSelect;
	var theRange;
		
	FT.addr.focus();
	FT.addr.select();

	theSelect = document.selection;
	theRange = theSelect.createRange();
	if (theRange.text.length > 0)
	{
		theRange.execCommand("Copy");
		document.selection.empty();
		alert("The url has been copied.  Paste the form url in the appropriate section of your HTML.");
	}
}
</script>
</body>
</html>
<%
}
catch(Exception ex) { throw ex;}
finally
{
	if (conn != null) conn.close();
	if (cp!= null) cp.free(conn);
}

%>






