<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.CategortiesControl,
		java.sql.*,java.util.Vector,
		java.util.Enumeration,
		java.io.*,java.net.*,
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
boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);

String sfile_id = request.getParameter("file_id");

String sExpName = null;
String sParams = null;
String sFileUrl = null;
String sExpDelimiter = "";
int iStatusId = 0;
String sParamName = null;
String sParamValue = null;
ExportParams eps = null;
ExportParam ep = null;
Enumeration e = null;
String sTotalRecip = null;

if(sfile_id != null)
{
	Export exp = new Export(sfile_id);
	sExpName = exp.s_export_name;
	sExpDelimiter = exp.s_delimiter;
	sParams = exp.s_params;
	sFileUrl = exp.s_file_url;
		
	iStatusId = Integer.parseInt(exp.s_status_id);
	
	eps = new ExportParams();
	eps.s_file_id = exp.s_file_id;
	eps.s_cust_id = exp.s_cust_id;
	eps.retrieve();

	for (e = eps.elements(); e.hasMoreElements() ;)
		ep = (ExportParam)e.nextElement();
	
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
            if (sTotalRecip == null )
            	sTotalRecip = "0";
		}
        catch (IOException ex) 
        {
			logger.error("IO Exception in custom_export_edit.jsp: ", ex);
        }
	}
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
function ExportWin(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,menubar=yes,toolbar=yes,location=no,status=yes,height=600,width=500';
	SmallWin = window.open(freshurl,'ExportWin',window_features);
}

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
	conn = cp.getConnection("custom_export_edit.jsp");
	stmt = conn.createStatement();

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	int	sExpID	= 0;
	boolean bIsFixedWidth = false;

	rs = stmt.executeQuery(
		" SELECT cstm_exp_id, ISNULL(fixed_width_flag,0)" +
		" FROM cexp_custom_export" +
		" WHERE cust_id = " + cust.s_cust_id +" ");

	if (!rs.next()) out.print("Export not found!");
	else
	{
		sExpID = rs.getInt(1);
		bIsFixedWidth = (rs.getInt(2) != 0);
%>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="doSave();">Update & Save</a>
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
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<th align="center" valign="middle"><%=sExpName%>:&nbsp;<%= ExportStatus.getDisplayName(iStatusId) %></th>
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

<FORM  METHOD="POST" NAME="FT" action="custom_export_save.jsp" TARGET="_self">
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
<%=(sfile_id!=null)?"<INPUT type=\"hidden\" name=\"file_id\" value=\""+sfile_id+"\">":""%>
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
					<TD width="475"><INPUT type="text" name="export_name" value="<%=sExpName%>"></TD>
				</TR>
				
				<tr<%=!canCat.bRead?" style=\"display:none\"":""%>>
					<td width="150">Categories</td>
					<td width="475">
						<select multiple name="categories" size="5">
							<%=CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.EXPORT, sfile_id, sSelectedCategoryId)%>
						</select>
						<%=(!canCat.bExecute && !(sSelectedCategoryId == null) && !(sSelectedCategoryId.equals("0")))
						?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
						:""%>						
					</td>
				</tr>		
<%
			if (e != null){
			for (e = eps.elements(); e.hasMoreElements() ;)
			{				
				ep = (ExportParam)e.nextElement();
				sParamName = ep.s_param_name;
				sParamValue = ep.s_param_value;
				
				String cxzSql = " SELECT ISNULL(display_name,param_name)";
				cxzSql += " FROM cexp_custom_exp_param";
				cxzSql += " WHERE param_name = '" + sParamName + "'";
				cxzSql += " AND cstm_exp_id = " + sExpID;
				
				
				rs = stmt.executeQuery(cxzSql);
				
				
				while (rs.next())
				{
					String sDisplayName = new String(rs.getBytes(1), "UTF-8");
					boolean bIsHeader = sParamName.startsWith("_header_;");
%>
				<TR<%=bIsHeader?" style=\"display:'none'\"":""%>>
					<TD width="150"><%=sDisplayName%></TD>
					<TD width="475">
						<INPUT type="hidden" name="param_name" value="<%=sParamName%>">
						<INPUT type="text" name="param_value" value="<%=sParamValue%>">
					</TD>
				</TR>
<% 
				}//close while loop
				rs.close();
			}
			}//end if
%>
				<TR<%=bIsFixedWidth?" style=\"display:'none'\"":""%>>
					<TD width="150">Delimiter</TD>
					<%if (sExpDelimiter != null) { %>
					<TD width="475">
						<INPUT TYPE="radio" NAME="delim" value="<%="TAB"%>" <%=(sExpDelimiter.equals("\\t"))?" CHECKED":""%>>Tab
						<INPUT TYPE="radio" NAME="delim" VALUE="<%=";"%>" <%=(sExpDelimiter.equals(";"))?" CHECKED":""%>>Semicolon (;)
						<INPUT TYPE="radio" NAME="delim" VALUE="<%=","%>" <%=(sExpDelimiter.equals(","))?" CHECKED":""%>>Comma (,)
						<INPUT TYPE="radio" NAME="delim" VALUE="<%="|"%>" <%=(sExpDelimiter.equals("|"))?" CHECKED":""%>>Pipe (|)
					</TD>
					<%} %>
					
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
