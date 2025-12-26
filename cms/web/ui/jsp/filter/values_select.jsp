<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

boolean HYATTADMIN = (ui.n_ui_type_id == UIType.HYATT_ADMIN);

String sAttrId = request.getParameter("attr_id");
String sOpID = request.getParameter("operation_id");

String sVal1 = request.getParameter("val1");
String sVal2 = request.getParameter("val2");

if (sVal1 == null) sVal1 = "";
if (sVal2 == null) sVal2 = "";

if( sAttrId == null) return;

Attribute a = new Attribute(sAttrId);
CustAttr ca = new CustAttr(cust.s_cust_id, sAttrId);
AttrCalcProps acp = new AttrCalcProps(cust.s_cust_id, sAttrId);

boolean disableValues = false;

String sFilterUse = acp.s_filter_usage;
String sCalcValsFlag = acp.s_calc_values_flag;

if (("1".equals(sFilterUse)) && ("1".equals(sCalcValsFlag) || "2".equals(sCalcValsFlag)))
{
	disableValues = true;
}

int i_operation_id = Integer.parseInt(sOpID);
int showOption = 0;

switch (i_operation_id)
{
	case CompareOperation.EQUAL:
		showOption = 0;
		break;
	case CompareOperation.MORE:
		showOption = 0;
		break;
	case CompareOperation.MORE_OR_EQUAL:
		showOption = 0;
		break;
	case CompareOperation.LESS:
		showOption = 0;
		break;
	case CompareOperation.LESS_OR_EQUAL:
		showOption = 0;
		break;
	case CompareOperation.LIKE:
		showOption = 0;
		break;
	case CompareOperation.BETWEEN:
		showOption = 1;
		break;
	case CompareOperation.IN:
		showOption = 2;
		break;
}

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<title>Select Values</title>
<script language="javascript">
	
	function selectValues()
	{
<%
switch (showOption)
{
	case 0: // Select single value
		%>
		var parWin, formula, val1;
		
		var destText = document.getElementById("select_val");
		
		parWin = window.opener;
		formula = parWin.curFormula;
		val1 = parWin.getChildByXmlTag(formula, 'value1');
		val1.value = "'" + destText.value + "'";
		<%
		if (disableValues)
		{
			%>
		val1.style.display = "";
		val1.disabled = true;
			<%
		}
		break;
	
	case 1: // Select two values for BETWEEN
		%>
		var parWin, formula, val1, val2;
		
		var destText1 = document.getElementById("select_val_1");
		var destText2 = document.getElementById("select_val_2");
		
		parWin = window.opener;
		formula = parWin.curFormula;
		
		val1 = parWin.getChildByXmlTag(formula, 'value1');
		val1.value = "'" + destText1.value + "'";
		
		val2 = parWin.getChildByXmlTag(formula, 'value2');
		val2.value = "'" + destText2.value + "'";
		<%
		if (disableValues)
		{
			%>
		val1.style.display = "";
		val1.disabled = true;
		val2.style.display = "";
		val2.disabled = true;
			<%
		}
		break;
	
	case 2: // Select multiple values for IN
		%>
		var parWin, formula, val1, val2;
		
		parWin = window.opener;
		formula = parWin.curFormula;
		
		val1 = parWin.getChildByXmlTag(formula, 'value1');
		
		var sInText = "";
		var i = 0;
		var selVals = document.getElementsByName("select_val");
		
		for (i=0; i < selVals.length; i++)
		{
			if (selVals[i].value != "")
			{
				sInText = sInText + ", '" + selVals[i].value + "'";
			}
		}
		
		sInText = sInText.substr(2);
		
		val1.value = sInText;
		<%
		if (disableValues)
		{
			%>
		val1.style.display = "";
		val1.disabled = true;
			<%
		}
		break;
}
%>
		self.close();
	}
	
	function selectVal()
	{
<%
switch (showOption)
{
	case 0: // Select single value
		%>
		var srcElem = event.srcElement;
		var oRow, oParent;
		oParent = srcElem;
		
		while(oParent.tagName != "TR")
		{
			oParent = oParent.parentElement;
		}
		
		var destText = document.getElementById("select_val");
		destText.value = oParent.cells[0].innerText;
		<%
		break;
	
	case 2: // Select multiple values for IN
		%>
		var srcElem = event.srcElement;
		var oParent = srcElem;
		
		while(oParent.tagName != "TR")
		{
			oParent = oParent.parentElement;
		}
		
		var tTable = document.getElementById("valuesTable");
		var oRow, oCell;
		
		oRow = tTable.insertRow();
		
		oCell = oRow.insertCell();
		oCell.align = "left";
		oCell.vAlign = "middle";
		oCell.Width = "100%";
		oCell.className = "listItem_Title";
		oCell.innerHTML = "<input type=\"text\" name=\"select_val\" id=\"select_val\" size=\"30\" value=\"\" style=\"width:100%;\">";
		oCell.children[0].value = oParent.cells[0].innerText;
		<% if (disableValues) { %>
		oCell.children[0].disabled = true;
		<% } %>
		
		
		oCell = oRow.insertCell();
		oCell.align = "left";
		oCell.vAlign = "middle";
		oCell.className = "listItem_Data";
		oCell.innerHTML = "<a href=\"#\" onclick=\"removeValue();\" class=\"subactionbutton\">X</a>";
		<%
		break;
}
%>
	}
	
	function selectVal1()
	{
		var srcElem = event.srcElement;
		var oRow, oParent;
		oParent = srcElem;
		
		while(oParent.tagName != "TR")
		{
			oParent = oParent.parentElement;
		}
		
		var destText1 = document.getElementById("select_val_1");
		destText1.value = oParent.cells[0].innerText;
	}
	
	function selectVal2()
	{
		var srcElem = event.srcElement;
		var oRow, oParent;
		oParent = srcElem;
		
		while(oParent.tagName != "TR")
		{
			oParent = oParent.parentElement;
		}
		
		var destText2 = document.getElementById("select_val_2");
		destText2.value = oParent.cells[0].innerText;
	}
	
	function clearVal(id)
	{
		if (id == 1)
		{
			var destText1 = document.getElementById("select_val_1");
			destText1.value = "";
		}
		else
		{
			var destText2 = document.getElementById("select_val_2");
			destText2.value = "";
		}
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
	
	function values_update()
	{
		URL = '../setup/cust_attrs/values_update.jsp?attr_id=<%= sAttrId %>';
		windowName = '';
		windowFeatures = 'dependent=yes, scrollbars=no, resizable=yes, toolbar=no, height=200, width=670';
		window.open(URL, windowName, windowFeatures);
	}
	
	function refresh_screen()
	{
		location.href = "values_select.jsp?attr_id=<%= sAttrId %>&operation_id=<%= sOpID %>&val1=<%= sVal1 %>&val2=<%= sVal2 %>";
	}
	
	function values_edit()
	{
		URL = '../setup/cust_attrs/values_edit.jsp?attr_id=<%= sAttrId %>';
		windowName = '';
		windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=500, width=400';
       	window.open(URL, windowName, windowFeatures);
	}
	
</script>
</HEAD>
<BODY>
<form name="FT" action="values_select.jsp">
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col width="275">
	<col width="15">
	<col>
	<tr height="25">
		<td colspan="3">
			<table cellspacing="0" cellpadding="4" border="0">
				<tr>
					<td align="left" valign="middle">
						<a class="savebutton" href="#" onClick="selectValues();">Select Values</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="100">
		<td valign="top" colspan="3">
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
								<b><%= ca.s_display_name %> (<%= a.s_attr_name %>) Values&nbsp;</b><br>
								Select the values on the left to build the criteria to use in the 
								target group on the right.
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table class="listTable layout" style="width:100%; height:100%;" cellpadding="0" cellspacing="0">
				<col>
				<col width="150">
				<tr height="22">
					<th align="left">Value</th>
					<th align="right">
						&nbsp;
						<% if ("1".equals(acp.s_calc_values_flag)) { %>
							<a class="resourcebutton" href="#" onclick="values_update();">Update Values</a>
						<% } else { %>
							<% if (HYATTADMIN) { %>
							<a class="resourcebutton" href="#" onclick="values_edit();">Edit Values</a>
							<% } %>
						<% } %>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="resourcebutton" href="#" onclick="refresh_screen();">Refresh</a>
				</th>
				</tr>
				<tr>
					<td style="padding:0px;" colspan="2">
						<div style="width:100%; height:100%; overflow:auto;">
						<table class="layout" style="width:100%;" cellpadding="2" cellspacing="0">
							<col>
							<% if (showOption == 1) { %>
							<col width="35">
							<col width="35">
							<% } else { %>
							<col width="50">
							<% } %>
						<%
						ConnectionPool cp = null;
						Connection conn = null;
						Statement	stmt = null;
						ResultSet	rs = null; 
						String sSQL = null;
						
						int i = 0;

						try
						{
							cp = ConnectionPool.getInstance();
							conn = cp.getConnection(this);
							stmt = conn.createStatement();

							sSQL =
								" SELECT attr_value" +
								" FROM ccps_attr_value" +
								" WHERE cust_id=" + ca.s_cust_id +
								" AND attr_id=" + ca.s_attr_id + 
								" ORDER BY attr_value";

			 				rs = stmt.executeQuery(sSQL);

							String sAttrValue = null;

							byte[] b = null;

							String sClassAppend = "";
							
							for(i = 0; rs.next(); i++)
							{
								if (i % 2 != 0) sClassAppend = "_Alt";
								else sClassAppend = "";
								
								b = rs.getBytes(1);
								sAttrValue = (b==null)?null:new String(b, "UTF-8");
								%>
							<tr>
								<td class="listItem_Data<%= sClassAppend %>" nowrap><%= HtmlUtil.escape(sAttrValue) %></td>
								<% if (showOption == 1) { %>
								<td class="listItem_Data<%= sClassAppend %>" nowrap><a class="subactionbutton" href="#" onclick="selectVal1();">Sel1</a></td>
								<td class="listItem_Data<%= sClassAppend %>" nowrap><a class="subactionbutton" href="#" onclick="selectVal2();">Sel2</a></td>
								<% } else { %>
								<td class="listItem_Data<%= sClassAppend %>" nowrap><a class="subactionbutton" href="#" onclick="selectVal();">Select</a></td>
								<% } %>
								
							</tr>
								<%
							}
							rs.close();
						}
						catch(Exception ex) { throw ex; }
						finally { if(conn!=null) cp.free(conn); }
						
						if (i == 0)
						{
							%>
							<tr>
								<td style="padding:6px;" colspan="<%= (showOption == 1)?"3":"2" %>">
									There are currently no values defined or calculated for this field.<br><br>
								</td>
							</tr>
							<%
						}
						%>
						</table>
						</div>
					</td>
				</tr>
			</table>
		</td>
		<td></td>
		<td valign="top">
			<table class="listTable" cellpadding="2" cellspacing="0" width="100%" id="valuesTable">
		<%
		String tempStr = "";
		int iLen = 0;
		
		switch (showOption)
		{
			case 0: // Select single value
				tempStr = "";
				tempStr = sVal1.trim();
				iLen = tempStr.length();
				
				if ((iLen >= 1) && ("'".equals(tempStr.substring(0,1))))
				{
					tempStr = tempStr.substring(1, iLen - 1);
				}
				%>
				<tr>
					<th align="left" colspan="2">Selected Value</th>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Single Value Selected:</td>
					<td align="left" valign="middle" width="100%"><input type="text" name="select_val" id="select_val" size="30" style="width:100%;" value="<%= tempStr %>"<%= (disableValues)?" disabled":"" %>></td>
				</tr>
				<%
				break;
			
			case 1: // Select two values for BETWEEN
				tempStr = "";
				tempStr = sVal1.trim();
				iLen = tempStr.length();
				
				if ((iLen >= 1) && ("'".equals(tempStr.substring(0,1))))
				{
					tempStr = tempStr.substring(1, iLen - 1);
				}
				%>
				<tr>
					<th align="left" colspan="2">Selected Values</th>
				</tr>
				<tr>
					<td align="left" valign="middle" colspan="2" nowrap>Value 1 Selected:</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100%"><input type="text" name="select_val_1" id="select_val_1" size="30" style="width:100%;" value="<%= tempStr %>"<%= (disableValues)?" disabled":"" %>></td>
					<td nowrap>&nbsp;<a class="subactionbutton" href="#" onclick="clearVal(1);">Clear</a>&nbsp;&nbsp;</td>
				</tr>
				<tr>
					<td align="left" valign="middle" colspan="2" nowrap>Value 2 Selected:</td>
				</tr>
				<%
				tempStr = "";
				tempStr = sVal2.trim();
				iLen = tempStr.length();
				
				if ((iLen >= 1) && ("'".equals(tempStr.substring(0,1))))
				{
					tempStr = tempStr.substring(1, iLen - 1);
				}
				%>
				<tr>
					<td align="left" valign="middle" width="100%"><input type="text" name="select_val_2" id="select_val_2" size="30" style="width:100%;" value="<%= tempStr %>"<%= (disableValues)?" disabled":"" %>></td>
					<td nowrap>&nbsp;<a class="subactionbutton" href="#" onclick="clearVal(2);">Clear</a>&nbsp;&nbsp;</td>
				</tr>
				<%
				break;
			
			case 2: // Select multiple values for IN
				%>
				<tr>
					<th align="left" colspan="2">Selected Value(s)</th>
				</tr>
				<%
				tempStr = "";
				tempStr = sVal1.trim();
				String[] sInSplit = tempStr.split(",");
				int x = 0;
				
				for (x=0; x < sInSplit.length; x++)
				{
					tempStr = "";
					tempStr = sInSplit[x].trim();
					iLen = tempStr.length();
					
					if ((iLen >= 1) && ("'".equals(tempStr.substring(0,1))))
					{
						tempStr = tempStr.substring(1, iLen - 1);
					}
					%>
					<tr>
						<td align="left" valign="middle" width="100%" class="listItem_Title">
							<input type="text" name="select_val" id="select_val" size="30" value="<%= tempStr %>" style="width:100%;"<%= (disableValues)?" disabled":"" %>>
						</td>
						<td align="left" valign="middle" class="listItem_Data"><a href="#" onclick="removeValue();" class="subactionbutton">X</a></td>
					</tr>
					<%
				}
				break;
		}
		%>
			</table>
		</td>
	</tr>
</table>
</form>
</BODY>
</HTML>
