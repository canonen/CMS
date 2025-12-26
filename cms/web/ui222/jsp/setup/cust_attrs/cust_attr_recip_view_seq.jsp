<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY id="aaa">
<FORM method="POST" action="cust_attr_recip_view_seq_save.jsp" target="_self" name="attr_seq">

<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="attr_seq_save();">Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
<table cellspacing="0" cellpadding="0" width="650">
	<tr>
		<td>
			<!--- Step 1 Header----->
			<table width="100%" class="main" cellspacing="0" cellpadding="0">
				<tr>
					<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Set Recipient Attribute View Sequence</td>
				</tr>
			</table>
			<br>
			<!---- Step 1 Info----->
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="100%" border="0">
				<tr>
					<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class="EditBlock" id="block1_Step1">
				<tr>
					<td class="fillTab" valign="top" align="center" width="100%">
						<table class="main" cellspacing="1" cellpadding="2" width="100%">
							<tr> 
								<td width="40% align="center">
									Visible:<BR>
									<SELECT name="target" size="30" style="width: 100%;" onDblClick="removeField()">
										<%=getVisibleAttrs(cust)%>
									</SELECT>
									<SELECT multiple name="vis" style="width: 0; height: 0;"></SELECT>
								</td>
								<td valign="middle" align="center">
									<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">Move Up</a></p>
									<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">Move Down</a></p>
									<br>
									<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><< Move Left</a></p>
									<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">Move Right >></a></p>
								</td>
								<td width="40% align="center">
									Invisible:<BR>
									<SELECT name="source" size="30" style="width: 100%;" onDblClick="addField()">
										<%=getAllAttrs(cust)%>
									</SELECT>
									<SELECT multiple name="invis" style="width: 0; height: 0;"></SELECT>								
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
			<br><br>
		</td>
	</tr>
</table>

</FORM>
					
<SCRIPT>

		function upField()
		{
			var id, name;

			var ops = attr_seq.target.options;
			var si = attr_seq.target.selectedIndex;
			
			if( si < 1 ) return false;

			id = ops[si-1].value;
			name = ops[si-1].text;
			
			ops[si-1].value = ops[si].value;
			ops[si-1].text  = ops[si].text;

			ops[si].value = id;
			ops[si].text  = name;

			attr_seq.target.selectedIndex--;
		}

		function downField()
		{
			var id, name;

			var ops = attr_seq.target.options;
			var si = attr_seq.target.selectedIndex;

			if( si == attr_seq.target.length - 1 ) return false;

			id = ops[si+1].value;
			name = ops[si+1].text;
			
			ops[si+1].value = ops[si].value;
			ops[si+1].text  = ops[si].text;

			ops[si].value = id;
			ops[si].text  = name;
			
			attr_seq.target.selectedIndex++;
		}

		function addField()
		{
			var ops = attr_seq.source.options;
			var si = attr_seq.source.selectedIndex;

			if( si == -1 ) return false;

			attr_seq.target.options[attr_seq.target.length] = new Option(ops[si].text, ops[si].value);
			ops[si] = null;
		}

		function removeField()
		{
			if( attr_seq.target.selectedIndex == -1 ) return false;

			attr_seq.target.options[attr_seq.target.selectedIndex] = null;
			attr_seq.source.selectedIndex = 0;

			for(var i=0; i < itemOpt.length; ++i) attr_seq.source.options[i] = itemOpt[i]; 

			removeTargetFromSource()			
		}

		function removeTargetFromSource()
		{
			for(var i=0; i < attr_seq.target.options.length; ++i)
			{
				for(var j=0; j < attr_seq.source.options.length; ++j)
				{
					if( attr_seq.target.options[i].value == attr_seq.source.options[j].value )
					{
						attr_seq.source.options[j] = null;
						--j;
					}
				}
			}
		}
		
		var itemOpt = new Array();
		function Init()
		{
			for(var i=0; i < attr_seq.source.options.length; ++i) itemOpt[i] = attr_seq.source.options[i];
			removeTargetFromSource();
		}

		Init();
	</SCRIPT>
	<SCRIPT>
		function attr_seq_save()
		{
			attr_seq.target.disabled = true;
			attr_seq.source.disabled = true;

			for(var i=0; i < attr_seq.target.options.length; ++i)
			{
				attr_seq.vis.options[i] = 
					new Option(attr_seq.target.options[i].text, attr_seq.target.options[i].value); 
				attr_seq.vis.options[i].selected = true;
			}

			for(var i=0; i < attr_seq.source.options.length; ++i)
			{
				attr_seq.invis.options[i] = 
					new Option(attr_seq.source.options[i].text, attr_seq.source.options[i].value); 
				attr_seq.invis.options[i].selected = true;
			}
		
			attr_seq.submit();
		}
	</SCRIPT>
</BODY>
</HTML>

<%!
private String getVisibleAttrs(Customer cust) throws Exception
{
	String sSql =
		" SELECT ca.attr_id, ca.display_name, dt.type_name" +
		" FROM ccps_attribute a, ccps_cust_attr ca, ccps_data_type dt" +
		" WHERE" +
		" ca.cust_id=? AND" +
		" a.attr_id = ca.attr_id AND" +
		" a.type_id = dt.type_id AND" +
		" ISNULL(ca.display_seq, 0) > 0 AND" +
		" ISNULL(ca.recip_view_seq, 0) > 0 AND" +
		" ISNULL(a.internal_flag,0) <= 0" +
		" ORDER BY ca.recip_view_seq, ca.display_name";

	return getAttrs(sSql, cust);
}

private String getAllAttrs(Customer cust) throws Exception
{
	String sSql =
		" SELECT ca.attr_id, ca.display_name, dt.type_name" +
		" FROM ccps_attribute a, ccps_cust_attr ca, ccps_data_type dt" +
		" WHERE" +
		" ca.cust_id=? AND" +
		" a.attr_id = ca.attr_id AND" +
		" a.type_id = dt.type_id AND" +
		" ISNULL(ca.display_seq, 0) > 0 AND" +
		" ISNULL(a.internal_flag,0) <= 0" +
		" ORDER BY ca.display_name";

	return getAttrs(sSql, cust);	
}

private String getAttrs(String sSql, Customer cust) throws Exception
{
	ConnectionPool cp = null;
	Connection conn = null;
	StringWriter sw = new StringWriter();
	try
	{
		cp = ConnectionPool.getInstance();			
		conn = cp.getConnection(this);
		
		PreparedStatement pstmt = null;
		try
		{
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1, cust.s_cust_id);
			ResultSet rs = pstmt.executeQuery();

			String sAttrId = null;
			String sDisplayName = null;
			String sTypeName = null;

			while (rs.next())
			{
				sAttrId = rs.getString(1);
				sDisplayName = new String(rs.getBytes(2), "UTF-8");
				sTypeName = rs.getString(3);
				sw.write("<OPTION value=\"" + sAttrId + "\">" + sDisplayName + " (" + sTypeName + ")</OPTION>\r\n");
			}
			rs.close();
		}
		catch(Exception ex)	{ throw ex;	}
		finally { if(pstmt != null) pstmt.close(); }
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn != null) cp.free(conn); }

	return sw.toString();
}
%>

