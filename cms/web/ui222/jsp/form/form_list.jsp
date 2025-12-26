<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<HTML>
<HEAD>
	<TITLE>Subscription Forms</TITLE>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">

<script language="javascript">
function PreviewForm(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,height=500,width=650';
	SmallWin = window.open(freshurl,'Filter',window_features);
}
function PreviewURL(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,height=250,width=650';
	SmallWin = window.open(freshurl,'Filter',window_features);
}
</script>	
	
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="3" border="0" width="85%">
	<tr>
	<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	String admin = request.getParameter("admin");
	if (admin != null && admin.equals("1"))
	{
		%>
		<td align="left" valign="middle" nowrap>
			<a class="newbutton" href="form_edit.jsp">New Form</a>&nbsp;&nbsp;&nbsp;
		</td>
		<%
	}
	%>
		<td align="right" valign="middle" width="100%">
			&nbsp;&nbsp;&nbsp;<a class="resourcebutton" href="javascript:PreviewURL('form_list_url.jsp')">Generate Form URL</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="85%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Subscription Forms&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th nowrap>Form Name</th>
					<th nowrap>ID</th>
					<th nowrap>Form URL / Preview</th>
					<th nowrap>Modify Date</th>
					<th nowrap><span ondblclick="location.href = 'form_list.jsp?admin=1';">Create Date</span></th>
				</tr>
		<%
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt =null;
			
		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection(this);
			
			stmt = conn.createStatement();

			String sSql =
				" SELECT" +
				"	f.form_id," +
				"	f.form_name," +
				"	f.form_url," +
				"	fei.modify_date," +
				"	fei.create_date" +
				" FROM csbs_form f, csbs_form_edit_info fei" +
				" WHERE" +
				"	f.cust_id=" + cust.s_cust_id + " AND" +
				"	fei.form_id = f.form_id" +
				" ORDER BY fei.modify_date desc";
				
			ResultSet rs = stmt.executeQuery(sSql);

			int i;
			boolean oneForm = false;	
			String formName, cpsFormID, formURL, formURLStripped = "";
			
			String sClassAppend = "";
			int formCount = 0;
			
			byte[] b = null;
			while (rs.next())
			{
				if (formCount % 2 != 0)
				{
					sClassAppend = "_Alt";
				}
				else
				{
					sClassAppend = "";
				}
				formCount++;
				
				oneForm = true;
				cpsFormID = rs.getString(1);
				b = rs.getBytes(2);
				formName = (b==null)?null:new String(b, "UTF-8");
				b = rs.getBytes(3);			
				formURL = (b==null)?null:new String(b, "UTF-8");
				if (formURL == null)
				{
					formURLStripped = "";
					formURL = "";
				}
				else
				{
					i = formURL.indexOf('&');
					if (i != -1)
						formURLStripped = formURL.substring(0,i);
					else
						formURLStripped = formURL;
				}
				%>
				<tr>
					<% if (admin != null && admin.equals("1")) { %>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><A HREF="form_edit.jsp?form_id=<%= cpsFormID %>"><%= formName %></A></td>
					<% } else { %>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= formName %></td>
					<% } %>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%=cpsFormID%></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><a href="javascript:PreviewForm('<%= formURLStripped %>')"><%= formURL %></a></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(4)) %></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(5)) %></td>
				</tr>
				<%
			}
			if (!oneForm)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="5">There are currently no Forms</td>
				</tr>
				<%
			}
			rs.close();
		}
		catch(Exception ex)
		{
			throw ex;
		}
		finally
		{
			if (stmt!=null) stmt.close();
			if (conn!=null) cp.free(conn);
		}
		%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>
