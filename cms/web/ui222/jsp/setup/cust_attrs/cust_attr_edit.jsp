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

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

boolean HYATTADMIN = (ui.n_ui_type_id == UIType.HYATT_ADMIN);

String sAttrId = request.getParameter("attr_id");
String showValues = request.getParameter("show");
boolean bVals = true;
if (showValues == null) bVals = false;
if ("".equals(showValues)) bVals = false;

Attribute a = null;
CustAttr ca = null;
AttrCalcProps acp = null;

if( sAttrId == null)
{
	a = new Attribute();
	ca = new CustAttr();
	acp = new AttrCalcProps();
}
else
{
	a = new Attribute(sAttrId);
	ca = new CustAttr(cust.s_cust_id, sAttrId);
	if(ca.s_display_name == null)
	{
		ca = new CustAttr(a.s_cust_id,a.s_attr_id);
		ca.s_display_seq = "1";
		ca.s_sync_flag = null;
	}
	acp = new AttrCalcProps(cust.s_cust_id, sAttrId);	
}

if(a.s_type_id==null) a.s_type_id = String.valueOf(DataType.VARCHAR_255);
if(a.s_scope_id==null) a.s_scope_id = String.valueOf(AttrScope.PUBLIC);

%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
	<SCRIPT src="../../../js/scripts.js"></SCRIPT>
	<script language="javascript" src="../../../js/tab_script.js"></script>
	<SCRIPT>
		function values_show()
		{
			URL = 'values_show.jsp?attr_id=<%=ca.s_attr_id%>';
			windowName = '';
			windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=500, width=400';
	       	window.open(URL, windowName, windowFeatures);
		}
		
		function values_edit()
		{
			URL = 'values_edit.jsp?attr_id=<%=ca.s_attr_id%>';
			windowName = '';
			windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=500, width=400';
	       	window.open(URL, windowName, windowFeatures);
		}

		function values_update()
		{
			URL = 'values_update.jsp?attr_id=<%=ca.s_attr_id%>';
			windowName = '';
			windowFeatures = 'dependent=yes, scrollbars=no, resizable=yes, toolbar=no, height=200, width=670';
			window.open(URL, windowName, windowFeatures);
		}
		
		function check_1()
		{
			FT.ns1.checked = true;
			FT.ns2.checked = false;
			FT.newsletter_flag.value = "1";
		}
		
		function check_Y()
		{
			FT.ns2.checked = true;
			FT.ns1.checked = false;
			FT.newsletter_flag.value = "Y";
		}
		
		function check_none()
		{
			FT.ns2.checked = false;
			FT.ns1.checked = false;
			FT.newsletter_flag.value = "1";
		}
		
		function refresh_screen()
		{
			location.href = "cust_attr_edit.jsp?show=values&attr_id=<%= ca.s_attr_id %>";
		}
		
		function switchVals(obj)
		{
			FT.show.value = "values";
			checkAttr();
			
			//document.getElementById("vals_1_1").style.display = "none";
			//document.getElementById("vals_1_2").style.display = "none";
			//document.getElementById("vals_2_1").style.display = "none";
			
			//if (obj[obj.selectedIndex].value == "1")
			//{
			//	document.getElementById("vals_1_1").style.display = "";
			//	document.getElementById("vals_1_2").style.display = "";
			//}
			//if (obj[obj.selectedIndex].value == "2")
			//{
			//	document.getElementById("vals_2_1").style.display = "";
			//}
		}
		
		function checkNewsLetter(is_submit)
		{
			var obj = FT.newsletter_flag;
			var nlS = document.getElementById("nl_symbol");
			var nl_1 = document.getElementById("nl_symbol_1");
			var nl_Y = document.getElementById("nl_symbol_Y");
			var selType = FT.type_id[FT.type_id.selectedIndex].value;
			
			if ((selType == "10") || (selType == "20"))
			{
				if (is_submit == false)
				{
					if (obj.checked == true)
					{
						nlS.style.display = "";
						
						if (selType == "10")
						{
							nl_Y.style.display = "none";
							nl_1.style.display = "";
							check_1();
						}
						else if (selType == "20")
						{
							nl_Y.style.display = "";
							nl_1.style.display = "";
							check_Y();
						}
					}
					else
					{
						nlS.style.display = "none";
						check_none();
					}
				}
				return true;
			}
			else
			{
				if (obj.checked == true)
				{
					obj.checked = false;
					nlS.style.display = "none";
					check_none();
					alert("For a custom field to be a Newsletter field, it must either be an INTEGER or VARCHAR field.");
					return false;
				}
				else
				{
					return true;
				}
			}
		}
		
	</SCRIPT>
</HEAD>

<BODY>

<FORM method="POST" action="cust_attr_save.jsp" name="FT">
<input type="hidden" name="show" value="">
<% if(a.s_attr_id != null) { %>
	<INPUT type="hidden" name="attr_id" size="50" readonly value="<%=a.s_attr_id%>">
<% } %>
<%
if(can.bWrite || HYATTADMIN)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="checkAttr();">Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td width="620" class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> <%= ((a.s_attr_id != null))?"Edit":"Create"%> Custom Field</td>
		<td width="30" align="right"><a href="javascript:loadHelp('vl1125-ch1133', '1129');" class="resourcebutton" title="Help on this Section">[?]</a>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EditTabOn id=tab1_Step1 width=150 onclick="switchSteps('Tabs_Table1', 'tab1_Step1', 'block1_Step1');" valign=center nowrap align=middle>Details</td>
		<td class=EditTabOff id=tab1_Step2 width=150 onclick="switchSteps('Tabs_Table1', 'tab1_Step2', 'block1_Step2');" valign=center nowrap align=middle>Advanced Settings</td>
		<td class=EditTabOff id=tab1_Step3 width=150 onclick="switchSteps('Tabs_Table1', 'tab1_Step3', 'block1_Step3');" valign=center nowrap align=middle>Values</td>
		<td class=EmptyTab valign=center nowrap align=middle width=200><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=4><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4>
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Field Name</td>
					<td align="left" valign="middle"><INPUT type="text" name="attr_name" size="50" <%=(a.s_attr_id == null)?"":"disabled"%> value="<%=(a.s_attr_name==null)?"":a.s_attr_name%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Display Name</td>
					<td align="left" valign="middle"><INPUT type="text" name="display_name" size="50" value="<%=HtmlUtil.escape(ca.s_display_name)%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Type</td>
					<td align="left" valign="middle">
						<SELECT size="1" name="type_id" <%=(a.s_attr_id == null)?"":"disabled"%> onchange="checkNewsLetter(false);">
							<%=DataType.toHtmlOptions(a.s_type_id)%>
 						</SELECT>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Description</td>
					<td align="left" valign="middle"><TEXTAREA rows="5" name="descrip" cols="40" <%=((a.s_cust_id==null)||(cust.s_cust_id.equals(a.s_cust_id))?"":" disabled")%>><%=(a.s_descrip==null)?"":a.s_descrip%></TEXTAREA></td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block1_Step2 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4>
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
			<% if(cust.m_Customers != null) { %>
				<tr>
					<td align="left" valign="middle" width="100">Scope</td>
					<td align="left" valign="middle">
						<SELECT size="1" name="scope_id" <%=(a.s_attr_id == null)?"":"disabled"%>>
							<%=AttrScope.toHtmlOptions(a.s_scope_id)%>
 						</SELECT>
					</td>
				</tr>
			<% } %>
				<tr>
					<td align="left" valign="middle" width="100">Multivalue</td>
					<td align="left" valign="middle"><INPUT type="checkbox" name="value_qty" <%=(a.s_value_qty==null)?"":"checked"%> <%=(a.s_attr_id == null)?"":"disabled"%>></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Fingerprint</td>
					<td align="left" valign="middle"><INPUT type="checkbox" name="fingerprint_seq" disabled <%=(ca.s_fingerprint_seq==null)?"":"checked"%>></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Newsletter</td>
					<td align="left" valign="middle"><INPUT type="checkbox" onclick="checkNewsLetter(false);" name="newsletter_flag" value="<%=(ca.s_newsletter_flag!=null)?ca.s_newsletter_flag:"1"%>" <%=(ca.s_newsletter_flag==null)?"":"checked"%>></td>
				</tr>
				<tr id="nl_symbol"<%=(ca.s_newsletter_flag==null)?" style=\"display:none;\"":""%>>
					<td align="left" valign="middle" width="100">Newsletter Symbol</td>
					<td align="left" valign="middle">
						<span id="nl_symbol_1" onClick="check_1();"><INPUT type="radio" name="ns1" id="ns1" <%=(ca.s_newsletter_flag==null || "1".equals(ca.s_newsletter_flag))?"checked":""%>><label for="ns1">&nbsp;1/0</label></span>&nbsp;
						<span id="nl_symbol_Y" onClick="check_Y();"><INPUT type="radio" name="ns2" id="ns2" <%=(ca.s_newsletter_flag!=null && "Y".equals(ca.s_newsletter_flag))?"checked":""%>><label for="ns2">&nbsp;Y/N</label></span>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Synchronize</td>
					<td align="left" valign="middle"><INPUT type="checkbox" name="sync_flag" value="1" <%=(ca.s_sync_flag==null || ca.s_sync_flag.equals("0"))?"":"checked"%>></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Keep update history</td>
					<td align="left" valign="middle"><INPUT type="checkbox" name="hist_flag" value="1" <%=(ca.s_hist_flag==null || ca.s_hist_flag.equals("0"))?"":"checked"%>></td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Values in Target Group</td>
					<td align="left" valign="middle">
						<select size="1" name="filter_usage">
							<option value="0"<%=("0".equals(acp.s_filter_usage))?" selected":""%>>No</option>
							<option value="1"<%=("1".equals(acp.s_filter_usage))?" selected":""%>>Yes - Only Values List</option>
							<option value="2"<%=("2".equals(acp.s_filter_usage))?" selected":""%>>Yes - Values List &amp; Open Input</option>
 						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block1_Step3 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4 height=200>
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Create Values List</td>
					<td align="left" valign="middle" nowrap>
					<% if("-1".equals(acp.s_calc_values_flag)) { %>
						<SELECT size="1" name="calc_values_flag" disabled>
							<OPTION value="-1" selected>Never</OPTION>			
						</SELECT>
					<% } else { %>
						<SELECT size="1" name="calc_values_flag" onchange="switchVals(this)">
							<OPTION value="0" <%=("0".equals(acp.s_calc_values_flag))?"selected":""%>>No</OPTION>			
							<OPTION value="1" <%=("1".equals(acp.s_calc_values_flag))?"selected":""%>>Yes - Calculate</OPTION>
							<OPTION value="2" <%=("2".equals(acp.s_calc_values_flag))?"selected":""%>>Yes - Manually Define</OPTION>
						</SELECT>
					<% } %>
					</td>
				</tr>
				<tr id="vals_1_1"<%= ("1".equals(acp.s_calc_values_flag))?"":" style=\"display:none;\"" %>>
					<td align="left" valign="middle" width="100">Distinct values count</td>
					<td align="left" valign="middle">
						<%=(acp.s_distinct_values_qty==null)?"---":acp.s_distinct_values_qty%>
						&nbsp;
						<a class="resourcebutton" href="#" onclick="values_show();">Show Values</a>
						&nbsp;
						(5000 limit)
					</td>
				</tr>
				<tr id="vals_1_2"<%= ("1".equals(acp.s_calc_values_flag))?"":" style=\"display:none;\"" %>>
					<td align="left" valign="middle" width="100">Last calculation date</td>
					<td align="left" valign="middle">
						<%=(acp.s_last_calc_date==null)?"---":acp.s_last_calc_date%>
						&nbsp;
						<a class="resourcebutton" href="#" onclick="values_update();">Update</a>
						<br><br>
						<a class="resourcebutton" href="#" onclick="refresh_screen();">Refresh</a>
					</td>
				</tr>
				<tr id="vals_2_1"<%= ("2".equals(acp.s_calc_values_flag))?"":" style=\"display:none;\"" %>>
					<td align="left" valign="middle" width="100">Values</td>
					<td align="left" valign="middle">
						<a class="resourcebutton" href="#" onclick="values_edit();">Edit Values</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</FORM>

<SCRIPT>
function checkAttr()
{

	FT.attr_name.value = FT.attr_name.value.replace(/(^\s*)|(\s*$)/g, '');
	FT.display_name.value = FT.display_name.value.replace(/(^\s*)|(\s*$)/g, '');

	if (FT.attr_name.value.length == 0)
	{
		alert("You must include a Field Name");
		return false;
	}
	if (FT.display_name.value.length == 0)
	{
		alert("You must include a Display Name");
		return false;
	}
	if (!FT.attr_name.value.substring(0,1).match("[a-z]|[A-Z]"))
	{
		alert("Field Name should start with letter (a-z).");
		return false;
	}
	if (FT.attr_name.value.match(/\W/))
	{
		alert("Field Name can only contain alphanumeric characters (a-z, 0-9) and underscores (_) with no spaces.");
		return false;
	}
	
	if (!checkNewsLetter(true))
	{
		return false;
	}
	
	FT.submit();
}

<% if (bVals) { %>
	switchSteps('Tabs_Table1', 'tab1_Step3', 'block1_Step3');
<% } %>

</SCRIPT>
</BODY>
</HTML>
