<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
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
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript" src="../../js/tab_script.js"></script>
</HEAD>
<BODY>
<script>

function doSave()
{
	if (FT.export_name.value == null || FT.export_name.value == "") {
		alert("Please enter export name");
		return;
	}
	FT.submit()
}

</script>
<%

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("custom_export_new.jsp");
	stmt = conn.createStatement();

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	// === Categories ===
	
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

	// === === ===

	String		sExpID		= request.getParameter("exp_id");
	String		sExpName	= "";
	boolean bIsFixedWidth = false;

	rs = stmt.executeQuery(
		" SELECT exp_name, ISNULL(fixed_width_flag,0)" +
		" FROM cexp_custom_export" +
		" WHERE cstm_exp_id = "+sExpID +
		" AND cust_id = "+cust.s_cust_id);

	if (!rs.next()) out.print("Export not found!");
	else
	{
		sExpName = new String(rs.getBytes(1), "UTF-8");
		bIsFixedWidth = (rs.getInt(2) != 0);

%>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="doSave();">Save Export</a>
		</td>
	</tr>
</table>
<br>
<INPUT TYPE="hidden" NAME="view" VALUE="">
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=3>
			<table class=main cellspacing=1 cellpadding=1 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<span style="font-size:16pt;"><%=sExpName%></span>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<FORM  METHOD="POST" NAME="FT" action="custom_export_save.jsp" TARGET="_self">
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
<INPUT type="hidden" name="exp_id" value="<%=sExpID%>">

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Set export parameters</td>
	</tr>
</table>
<br>

<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=3>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<TR>
					<TD width="150">Export name</TD>
					<TD width="475"><INPUT type="text" name="export_name"></TD>
				</TR>
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
					<td width="150">Categories</td>
					<td width="475">
						<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" width="100">
							<%= htmlCategories %>
						</SELECT>
						<%=(!canCat.bExecute && !(sSelectedCategoryId == null) && !(sSelectedCategoryId.equals("0")))
						?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
						:""%>
					</td>
				</tr>
<%
			rs = stmt.executeQuery(
				" SELECT ISNULL(display_name,param_name), param_name" +
				" FROM cexp_custom_exp_param" +
				" WHERE cstm_exp_id = " + sExpID +
				" ORDER BY param_id");
				
			while (rs.next())
			{
				String sDisplayName = new String(rs.getBytes(1), "UTF-8");
				String sParamName = rs.getString(2);
				boolean bIsHeader = sParamName.startsWith("_header_;");
%>
				<TR<%=bIsHeader?" style=\"display:'none'\"":""%>>
					<TD width="150"><%=sDisplayName%></TD>
					<TD width="475">
						<INPUT type="hidden" name="param_name" value="<%=sParamName%>">
						<INPUT type="text" name="param_value">
					</TD>
				</TR>
<% 
			}
			rs.close();
%>
				<TR<%=bIsFixedWidth?" style=\"display:'none'\"":""%>>
					<TD width="150">Delimiter</TD>
					<TD width="475">
						<INPUT TYPE="radio" NAME="delim" VALUE="TAB"<%=!bIsFixedWidth?" CHECKED":""%>>Tab
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
<br><br>
</FORM>
<%
	}
}
catch(Exception ex)
{
	ErrLog.put(this,ex,"custom_export_list.jsp",out,1);
	return;
}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>
</BODY>
</HTML>
