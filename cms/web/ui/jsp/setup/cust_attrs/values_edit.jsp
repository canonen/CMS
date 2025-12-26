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

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sAttrId = request.getParameter("attr_id");
if( sAttrId == null) return;

Attribute a = new Attribute(sAttrId);
CustAttr ca = new CustAttr(cust.s_cust_id, sAttrId);

%>
<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<title>Custom Field Values List</title>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">

	var tabIndex = 2;
	
	function addValue()
	{
		var tTable = document.getElementById("valuesTable");
		var oRow, oCell;
		
		oRow = tTable.insertRow();
		
		tabIndex++;
		
		oCell = oRow.insertCell();
		oCell.align = "left";
		oCell.vAlign = "middle";
		oCell.Width = "100%";
		oCell.className = "listItem_Title";
		oCell.innerHTML = "<input type=\"text\" name=\"attr_value\" id=\"attr_value\" tabindex=\"" + tabIndex + "\" size=\"30\" value=\"\" style=\"width:100%;\">";
		oCell.children[0].focus();
		
		tabIndex++;
		
		oCell = oRow.insertCell();
		oCell.align = "left";
		oCell.vAlign = "middle";
		oCell.className = "listItem_Data";
		oCell.innerHTML = "<a href=\"#\" onclick=\"removeValue();\" class=\"subactionbutton\">X</a>";
	}
	
	function removeValue()
	{
		var srcElem = window.event.srcElement;
		var trElem = srcElem;
		var tTable = document.getElementById("valuesTable");
		
		while (trElem.tagName != "TR")
		{
			trElem = trElem.parentElement;
		}
		
		tTable.deleteRow(trElem.rowIndex);
	}
		
		function saveValues()
		{
			var tTable = document.getElementById("valuesTable");
			var hDiv = document.getElementById("hiddenInputs");
			
			var sValues = "";
			var sAttrValue = "";
			
			var y = 1;
			
			for (i=1; i < tTable.rows.length; i++)
			{
				sAttrValue = "";
				sAttrValue = tTable.rows[i].cells[0].children[0].value;
				
				if ((sAttrValue != ""))
				{
					sValues += "<input type=hidden name=attr_value" + y + " value=\"" + sAttrValue + "\">";
					y++;
				}
				else
				{
					alert("You have added a value with out entering the required information.\n\nPlease enter a value or delete the row by clicking the 'X' button.");
					return;
				}
			}
			
			hDiv.innerHTML = sValues;
			FT.num_values.value = (y - 1);
			
			var dt = new Date();
			
			FT.update_date.value = dt.toString();
			FT.submit();
		}

</script>
</HEAD>
<BODY>
<form name="FT" action="values_save.jsp">
<input type="hidden" name="attr_id" value="<%= sAttrId %>">
<input type="hidden" name="cust_id" value="<%= cust.s_cust_id %>">
<input type="hidden" name="num_values" value="1">
<input type="hidden" name="update_date" value="">
<div style="display:none;" id="hiddenInputs">
</div>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onClick="saveValues();">Save</a>
		</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<%= ca.s_display_name %> (<%= a.s_attr_name %>)&nbsp;
			<br><br>
			<table class="listTable" cellpadding="2" cellspacing="0" id="valuesTable" width="100%">
				<tr>
					<th colspan="2" align="center">Value</th>
				</tr>
			<%
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
					" SELECT attr_value, value_qty" +
					" FROM ccps_attr_value" +
					" WHERE cust_id = '" + ca.s_cust_id + "'" +
					" AND attr_id = '" + ca.s_attr_id + "'" +
					" ORDER BY attr_value";

 				rs = stmt.executeQuery(sSQL);

				String sAttrValue = null;

				byte[] b = null;
							
				String sClassAppend = "";
				
				int i = 0;
				
				for(i = 0; rs.next(); i++)
				{
					if (i % 2 != 0) sClassAppend = "_Alt";
					else sClassAppend = "";
					
					b = rs.getBytes(1);
					sAttrValue = (b==null)?null:new String(b, "UTF-8");
					
					if (i == 0)
					{
					%>
				<tr>
					<td class="listItem_Title" width="100%"><input type="text" name"attr_value" size="30" style="width:100%;" value="<%= HtmlUtil.escape(sAttrValue) %>"></td>
					<td class="listItem_Data" nowrap><a href="javascript:addValue();" class="subactionbutton">Additional Value</a>&nbsp;&nbsp;</td>
				</tr>
					<%
					}
					else
					{
					%>
				<tr>
					<td class="listItem_Title"><input type="text" name="attr_value" value="<%= HtmlUtil.escape(sAttrValue) %>" size="30" style="width:100%;"></td>
					<td class="listItem_Data"><a href="#" onclick="removeValue();" class="subactionbutton">X</a></td>
				</tr>
					<%
					}
				}
				rs.close();
				
				if (i == 0)
				{
				%>
				<tr>
					<td class="listItem_Title" width="100%"><input type="text" name"attr_value" size="30" style="width:100%;" value="<%= HtmlUtil.escape(sAttrValue) %>"></td>
					<td class="listItem_Data" nowrap><a href="javascript:addValue();" class="subactionbutton">Additional Value</a>&nbsp;&nbsp;</td>
				</tr>
				<%
				}
			}
			catch(Exception ex) { throw ex; }
			finally { if(conn!=null) cp.free(conn); }
			%>
			</table>
		</td>
	</tr>
</table>
</form>
</BODY>
</HTML>