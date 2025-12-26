<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			org.apache.log4j.*"
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

boolean HYATTADMIN = (ui.n_ui_type_id == UIType.HYATT_ADMIN);

if(!can.bWrite && !HYATTADMIN)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sAttrId = BriteRequest.getParameter(request,"attr_id");
String sCustId = BriteRequest.getParameter(request,"cust_id");

AttrCalcProps acp = new AttrCalcProps(sCustId, sAttrId);
if("2".equals(acp.s_calc_values_flag))
{
	acp.s_distinct_values_qty = BriteRequest.getParameter(request,"num_values");
	acp.save();	
}

ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	sSQL =
		" DELETE" +
		" FROM ccps_attr_value" +
		" WHERE cust_id = '" + sCustId + "'" +
		" AND attr_id = '" + sAttrId + "'";

	stmt.executeUpdate(sSQL);
	
	int numVals = Integer.parseInt(request.getParameter("num_values"));
	String attr_val = "";

	int count = 0;
	for (int i = 1; i <= numVals; i++)
	{
		attr_val = BriteRequest.getParameter(request, "attr_value"+i);
		if (attr_val != null)
		{
			count++;
			sSQL =
				" INSERT INTO ccps_attr_value" +
				" (cust_id, attr_id, attr_value, value_qty)" +
				" VALUES ('" + sCustId + "', '" + sAttrId + "', '" + attr_val + "', '1')";
			stmt.executeUpdate(sSQL);
		}
	}
}
catch(Exception ex) { throw ex; }
finally { if(conn!=null) cp.free(conn); }
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=100% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Custom Field Values:</b> Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
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
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p><b>The custom field values were saved.</b></p>
						<p><A href="javascript:self.close();">Close</A></p>
						<p><A href= "values_edit.jsp?attr_id=<%= sAttrId %>">Back to Edit</A></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>