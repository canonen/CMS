<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
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

String sectionID = request.getParameter("id");
if (sectionID == null) sectionID = "1";
int secID = Integer.parseInt(sectionID);

String sectionName = "";

switch (secID)
{
	case 1:
		sectionName = "Offer Masthead";
		break;
		
	case 2:
		sectionName = "Offer Image";
		break;
		
	case 3:
		sectionName = "Intro Text";
		break;
		
	case 4:
		sectionName = "Salutation";
		break;
		
	case 5:
		sectionName = "Offer Body";
		break;
		
	case 6:
		sectionName = "Body of PostCard";
		break;
		
	case 7:
		sectionName = "Address Info";
		break;
}

ConnectionPool cp	= null;
Connection conn		= null;
Statement stmt		= null;
ResultSet rs		= null;

String htmlPersonals="", firstPers="";


try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	//Personalization
	String attrID="", attrName="", attrDisplayName="";

	rs = stmt.executeQuery(""+
		"SELECT c.attr_id, a.attr_name, c.display_name " +
		"FROM ccps_cust_attr c, ccps_attribute a " +
		"WHERE c.cust_id = "+cust.s_cust_id+" AND c.display_seq IS NOT NULL " +
		"AND c.attr_id = a.attr_id " +
		"ORDER BY display_seq");
	while (rs.next()) {
		attrID = rs.getString(1);
		attrName = rs.getString(2);
		attrDisplayName = new String(rs.getBytes(3),"UTF-8");
		if (firstPers.length() == 0) firstPers = attrName;
		htmlPersonals += "<option value="+attrName+">"+attrDisplayName+"</option>\n";
	}
	
} catch(Exception ex)	{
	ErrLog.put(this,ex,"doc_step_3_edit.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
<html>
<head>
<title>Edit Section</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
<script language="javascript">
	
	function LibraryURL(imgurl)
	{
		LibraryWin = window.open(imgurl, 'ImageLibrary','scrollbars=yes,resizable=yes,toolbar=no,width=650,height=500');
	}
	
	function EditLogic(logicID)
	{
		LogicWin = window.open("logic.jsp?id=" + logicID, 'EditLogic','scrollbars=yes,resizable=yes,toolbar=no,width=775,height=550');
	}
	
	function EditCont(contURL)
	{
		ContWin = window.open(contURL, 'EditLogic','scrollbars=yes,resizable=yes,toolbar=no,width=650,height=350');
	}
	
	function switchOp(sec, typ)
	{
		var imgArea = document.getElementById("image_" + sec);
		var txtArea = document.getElementById("text_" + sec);
		
		imgArea.style.display = "none";
		txtArea.style.display = "none";
		
		if (typ == "image") imgArea.style.display = "";
		else txtArea.style.display = "";
	}
	
	function highlightRow(obj)
	{
		var oTD = obj;
		while (oTD.tagName != "TD")
		{
			oTD = oTD.parentElement;
		}
		
		var oTR = oTD;
		while (oTR.tagName != "TR")
		{
			oTR = oTR.parentElement;
		}
		
		if (obj.value != obj.defaultValue)
		{
			oTR.runtimeStyle.backgroundColor = "#DEDEDE";
		}
	}
	
	function saveOrder(obj)
	{
		var oTable = document.getElementById(obj);
		var i = 0;
		
		for (i=0; i < oTable.rows.length; i++)
		{
			oTable.rows[i].runtimeStyle.backgroundColor = "";
			if (oTable.rows[i].cells[0].children.length >= 1)
			{
				oTable.rows[i].cells[0].children[0].value = oTable.rows[i].cells[0].children[0].defaultValue;
			}
		}
		
		alert("Order saved!");
	}
	
	function AddNew(obj)
	{
		var tTable = document.getElementById(obj);
		var oRow, oCell;
		
		var trElem = tTable.rows[tTable.rows.length - 1];
		var oLast = trElem.cells[0].children[0];
		var curLastVal = oLast.value;
		
		tTable.deleteRow(trElem.rowIndex);
		
		oRow = tTable.insertRow();
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		oCell.innerHTML = "<input type=\"text\" name=\"order\" value=\"" + curLastVal + "\" style=\"width:100%;\" onchange=\"highlightRow(this);\">";
		
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		oCell.innerHTML = "<a href=\"javascript:EditLogic('../filter/filter_edit.jsp?usage_type_id=700&filter_id=');\">New Logic Element</a>";
		
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		
		if (obj == "sec3_order")
		{
			oCell.innerHTML = "<a href=\"javascript:EditCont('doc_step_3_edit.jsp?id=100');\">New Content Element</a>";
		}
		else
		{
			oCell.innerHTML = "<a href=\"javascript:EditCont('doc_step_3_edit.jsp?id=101');\">New Content Element</a>";
		}
		
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		oCell.innerHTML = "<a href=\"#\" onclick=\"DeleteRow('" + obj + "');\" class=\"deletebutton\">X</a>"
		
		var iNum = new Number(curLastVal);
		AddDefault(obj, iNum+1);
	}
	
	function AddDefault(obj, val)
	{
		var tTable = document.getElementById(obj);
		var oRow, oCell;
		
		oRow = tTable.insertRow();
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		oCell.innerHTML = "<input type=\"text\" name=\"order\" value=\"" + val + "\" style=\"width:100%;\" disabled>";
		
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		oCell.innerHTML = "* DEFAULT *";
		
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		
		if (obj == "sec3_order")
		{
			oCell.innerHTML = "<a href=\"javascript:EditCont('doc_step_3_edit.jsp?id=14');\">National Offer</a>";
		}
		else
		{
			oCell.innerHTML = "<a href=\"javascript:EditCont('doc_step_3_edit.jsp?id=23');\">Non-Partner Logo</a>";
		}
		
		oCell = oRow.insertCell();
		oCell.className = "listItem_Data";
		oCell.innerHTML = "&nbsp;";
	}
	
	function DeleteRow(obj)
	{
		var srcElem = window.event.srcElement;
		var trElem = srcElem;
		var tTable = document.getElementById(obj);
		
		while (trElem.tagName != "TR")
		{
			trElem = trElem.parentElement;
		}
		
		tTable.deleteRow(trElem.rowIndex);
		
		resetOrder(obj);
	}
	
	function resetOrder(obj)
	{
		var tTable = document.getElementById(obj);
		var oRow, oCell, oInput;
		var i = 0;
		var x = 1;
		
		for (i=0; i < tTable.rows.length; i++)
		{
			oRow = tTable.rows[i];
			oCell = oRow.cells[0];
			if (oCell.children.length >= 1)
			{
				oInput = oCell.children[0];
				oInput.value = x;
				oInput.defaultValue = x;
				x++;
			}
		}
	}
	
</script>
<script language="Javascript1.2"><!-- // load htmlarea
    _editor_url = "/cms/ui/js/editor/"; // URL to htmlarea files
    var win_ie_ver = parseFloat(navigator.appVersion.split("MSIE")[1]);
    if (navigator.userAgent.indexOf('Mac')        >= 0) { win_ie_ver = 0; }
    if (navigator.userAgent.indexOf('Windows CE') >= 0) { win_ie_ver = 0; }
    if (navigator.userAgent.indexOf('Opera')      >= 0) { win_ie_ver = 0; }
    if (win_ie_ver >= 5.5) {
        document.write('<script src="' +_editor_url+ 'editor.js"');
        document.write(' language="Javascript1.2"></script>');  
    } 
    else { 
        document.write('<script>function editor_generate() { return false; }</script>'); 
    }// -->
</script>
<script language="javascript" src="../../js/tab_script.js"></script>
</head>
<body style="padding:0px;">
<table cellspacing="0" cellpadding="0" border="0"<%= ((secID == 100)||(secID == 101))?"":" style=\"display:none;\"" %>>
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="javascript:self.close();">Save</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 100)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">New Content Element</th>
				</tr>
				<tr>
					<td width="150">Name: </td>
					<td><input type="text" style="width:100%;" name="cont_name" value="New Content Element"></td>
				</tr>
				<tr>
					<td width="150">Enter Text:<br><br><li>3 line(s) maximum</li><li>Text limit of approximately 25 character(s) per line</li></td>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('free_text_0');</script>
						<textarea rows="3" cols="50" name="free_text_0">Enter new content here</textarea>
					</td>
				</tr>
			</table>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 101)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">New Content Element</th>
				</tr>
				<tr>
					<td width="150">Name: </td>
					<td><input type="text" style="width:100%;" name="cont_name" value="New Content Element"></td>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG style="WIDTH: 185px; HEIGHT: 80px" src="https://www.clicktactics.com/demo/Content/Private/B72F9777-38E2-11D5-876A-00508BD8862C/Images/www_gs/F4296F44-4557-11D5-8A50-00508B660430_www_gs.png" border=0></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;<%= (secID == 1)?"":" display:none;" %>">
	<col>
	<tr height="30">
		<td style="padding:0px;" valign="top">
			<a href="javascript:AddNew('sec1_order');" class="subactionbutton">Add New</a>
		</td>
	</tr>
	<tr>
		<td style="padding:0px;" valign="top">
			<table cellspacing="0" cellpadding="2" border="0" id="sec1_order" class="listTable layout" style="width:100%;">
				<col width="45">
				<col>
				<col>
				<col width="60">
				<tr>
					<th>Order</th>
					<th>Logic Element</th>
					<th>Content Element</th>
					<th>&nbsp;</th>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="1" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560108');">Last Purchase Date is 60 Days Ago</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=10');">Win Back : 60 Days Masthead</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec1_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="2" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560111');">Last Purchase Date is 90 Days Ago</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=11');">Win Back : 90 Day Masthead</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec1_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="3" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560113');">Last Purchase Date is 120 Days Ago</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=12');">Win Back : 120 Day Masthead</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec1_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="4" disabled style="width:100%;"></td>
					<td class="listItem_Data">* DEFAULT *</td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=13');">Win Back : Masthead</a></td>
					<td class="listItem_Data">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;<%= (secID == 2)?"":" display:none;" %>">
	<col>
	<tr height="30">
		<td style="padding:0px;" valign="top">
			<a href="javascript:AddNew('sec2_order');" class="subactionbutton">Add New</a>
		</td>
	</tr>
	<tr>
		<td style="padding:0px;" valign="top">
			<table cellspacing="0" cellpadding="2" border="0" id="sec2_order" class="listTable layout" style="width:100%;">
				<col width="45">
				<col>
				<col>
				<col width="60">
				<tr>
					<th>Order</th>
					<th>Logic Element</th>
					<th>Content Element</th>
					<th>&nbsp;</th>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="1" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560105');">Last Purchase Dept: Jewelry</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=20');">Win Back : Last Purchased : Jewelry</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec2_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="2" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560101');">Last Purchase Dept: Kitchen</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=21');">Win Back : Last Purchased : Kitchen</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec2_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="3" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560103');">Last Purchase Dept: Electronics</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=22');">Win Back : Last Purchased Electronics</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec2_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="4" disabled style="width:100%;"></td>
					<td class="listItem_Data">* DEFAULT *</td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=23');">Win Back : All Products</a></td>
					<td class="listItem_Data">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" style="width:100%;"<%= (secID == 3)?"":" style=\"display:none;\"" %>>
	<tr>
		<td>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%">
				<tr>
					<th colspan="2">Intro Text:</th>
				</tr>
				<tr>
					<td width="150">Enter Text:<br><br><li>1 line(s) maximum</li><li>Text limit of approximately 40 character(s) per line</li></td>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('free_text_3');</script>
						<textarea rows="2" cols="50" name="free_text_3">Take advantage of extra-special savings!</textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" style="width:100%;"<%= (secID == 4)?"":" style=\"display:none;\"" %>>
	<tr>
		<td>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%">
				<tr>
					<th colspan="2">Salutation:</th>
				</tr>
				<tr>
					<td width="150">Enter Text:<br><br><li>1 line(s) maximum</li><li>Text limit of approximately 40 character(s) per line</li></td>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('free_text_4');</script>
						<textarea rows="2" cols="50" name="free_text_4">Dear !*pnmfull;Valued Customer*!, </textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;<%= (secID == 5)?"":" display:none;" %>">
	<col>
	<tr height="30">
		<td style="padding:0px;" valign="top">
			<a href="javascript:AddNew('sec5_order');" class="subactionbutton">Add New</a>
		</td>
	</tr>
	<tr>
		<td style="padding:0px;" valign="top">
			<table cellspacing="0" cellpadding="2" border="0" id="sec5_order" class="listTable layout" style="width:100%;">
				<col width="45">
				<col>
				<col>
				<col width="60">
				<tr>
					<th>Order</th>
					<th>Logic Element</th>
					<th>Content Element</th>
					<th>&nbsp;</th>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="1" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560108');">Last Purchase Date is 60 Days Ago</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=50');">Win Back : 60 Days Offer Body</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec5_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="2" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560111');">Last Purchase Date is 90 Days Ago</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=51');">Win Back : 90 Day Offer Body</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec5_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="3" style="width:100%;" onchange="highlightRow(this);"></td>
					<td class="listItem_Data"><a href="javascript:EditLogic('100560113');">Last Purchase Date is 120 Days Ago</a></td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=52');">Win Back : 120 Day Offer Body</a></td>
					<td class="listItem_Data"><a href="#" onclick="DeleteRow('sec5_order');" class="deletebutton">X</a></td>
				</tr>
				<tr>
					<td class="listItem_Data"><input type="text" name="order" value="4" disabled style="width:100%;"></td>
					<td class="listItem_Data">* DEFAULT *</td>
					<td class="listItem_Data"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=53');">Win Back : Offer Body</a></td>
					<td class="listItem_Data">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" style="width:100%;"<%= (secID == 6)?"":" style=\"display:none;\"" %>>
	<tr>
		<td>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%">
				<tr>
					<th colspan="2">Body (Part 1 of 3):</th>
				</tr>
				<tr>
					<td width="150">Enter Text:<br><br><li>3 line(s) maximum</li><li>Text limit of approximately 35 character(s) per line</li></td>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('free_text_6_1');</script>
						<textarea rows="3" cols="50" name="free_text_6_1">Simply go to BargainBasement.com and when<br>you check out enter the code: <b>!*promo_code;*!</b><br>to get your rebate.</textarea>
					</td>
				</tr>
				<tr>
					<th colspan="2">Closing (Part 2 of 3):</th>
				</tr>
				<tr>
					<td width="150">Enter Text:<br><br><li>1 line(s) maximum</li><li>Text limit of approximately 35 character(s) per line</li></td>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('free_text_6_2');</script>
						<textarea rows="2" cols=50 name="free_text_6_2">We look forward to serving you!</textarea>
					</td>
				</tr>
				<tr>
					<th colspan="2">Signature (Part 3 of 3):</th>
				</tr>
				<tr>
					<td width="150">Enter Text:<br><br><li>1 line(s) maximum</li><li>Text limit of approximately 35 character(s) per line</li></td>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('free_text_6_3');</script>
						<textarea rows="2" cols=50 name="free_text_6_3">The BargainBasement Team</textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" style="width:100%;"<%= (secID == 7)?"":" style=\"display:none;\"" %>>
	<tr>
		<td>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%">
				<tr>
					<th colspan="2">Address Info:</th>
				</tr>
				<tr>
					<td width="150">Enter Text:<br><br><li>4 line(s) maximum</li><li>Text limit of approximately 40 character(s) per line</li></td>
					<td>
						<script language="JavaScript1.2" defer>editor_generate('free_text_7');</script>
						<textarea rows="4" cols="40" name="free_text_7">!*pnmfull;Current Resident*!<br>!*bsaddr;*!<br>!*bscity;*!, !*bsst;*!  !*bspostcde;*!</textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;<%= ((secID == 10)||(secID == 11)||(secID == 12)||(secID == 13))?"":" display:none;" %>">
	<col>
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="javascript:self.close();">Save</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td style="padding:0px;" valign="top">
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 10)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : 60 Days Masthead</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/spot-hdr2a.gif" border=0></</td>
				</tr>
			</table>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 11)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : 90 Days Masthead</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/spot-hdr2b.gif" border=0></</td>
				</tr>
			</table>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 12)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : 120 Days Masthead</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/spot-hdr2c.gif" border=0></</td>
				</tr>
			</table>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 13)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : Masthead</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/spot-hdr2.gif" border=0></</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;<%= ((secID == 20)||(secID == 21)||(secID == 22)||(secID == 23))?"":" display:none;" %>">
	<col>
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="javascript:self.close();">Save</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td style="padding:0px;" valign="top">
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 20)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : Last Purchased : Jewelry</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/prod1.jpg" border=0></</td>
				</tr>
			</table>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 21)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : Last Purchased : Kitchen</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/pots.gif" border=0></</td>
				</tr>
			</table>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 22)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : Last Purchased : Electronics</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/camera.gif" border=0></</td>
				</tr>
			</table>
			<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 23)?"":" style=\"display:none;\"" %>>
				<tr>
					<th colspan="2">Win Back : Last Purchased : Products</th>
				</tr>
				<tr>
					<td width="150">Choose an image from the library: </td>
					<td><a class="resourcebutton" href="javascript:LibraryURL('../image/folder_details_url.jsp')">Image Library</a></td>
				</tr>
				<tr>
					<td width="150">Preview Image: </td>
					<td><IMG src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/watch.gif" border=0></</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;<%= ((secID == 50)||(secID == 51)||(secID == 52)||(secID == 53))?"":" display:none;" %>">
	<col>
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="javascript:self.close();">Save</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td style="padding:0px;" valign="top">
			<table id="Tabs_Table2" cellspacing=0 cellpadding=0 border=0 style="width:590px; height:250px;">
				<tr height="22">
					<td class=EditTabOn id=tab2_Step1 width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Edit Content</td>
					<td class=EditTabOff id=tab2_Step2 width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Personalization Options</td>
					<td class=EmptyTab valign=center nowrap align=middle width="290"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr height="2">
					<td class=fillTabbuffer valign=top align=left width=590 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block2_Step1>
				<tr>
					<td class=fillTab valign=top align=center width=590 colspan=3>
						<table cellspacing="1" cellpadding="2" border="0" class="main" width="590"<%= (secID == 50)?"":" style=\"display:none;\"" %>>
							<tr>
								<th colspan="2">Win Back : 60 Days Offer Body:</th>
							</tr>
							<tr>
								<td width="150">Enter Text:<br><br><li>4 line(s) maximum</li><li>Text limit of approximately 25 character(s) per line</li></td>
								<td>
									<script language="JavaScript1.2" defer>editor_generate('free_text_50');</script>
									<textarea rows=4 cols=50 name="free_text_50">We'd like to thank you for being such a<br>valued customer by giving you <b>$10 off any<br>purchase of $100 or more</b>. This offer is valid<br>in ALL stores!</textarea>
								</td>
							</tr>
						</table>
						<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 51)?"":" style=\"display:none;\"" %>>
							<tr>
								<th colspan="2">Win Back : 90 Days Offer Body:</th>
							</tr>
							<tr>
								<td width="150">Enter Text:<br><br><li>4 line(s) maximum</li><li>Text limit of approximately 25 character(s) per line</li></td>
								<td>
									<script language="JavaScript1.2" defer>editor_generate('free_text_51');</script>
									<textarea rows=4 cols=50 name="free_text_51">We'd like to thank you for being such a<br>valued customer by giving you <b>$15 off any<br>purchase of $100 or more</b>. This offer is valid<br>in ALL stores!</textarea>
								</td>
							</tr>
						</table>
						<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 52)?"":" style=\"display:none;\"" %>>
							<tr>
								<th colspan="2">Win Back : 120 Days Offer Body:</th>
							</tr>
							<tr>
								<td width="150">Enter Text:<br><br><li>4 line(s) maximum</li><li>Text limit of approximately 25 character(s) per line</li></td>
								<td>
									<script language="JavaScript1.2" defer>editor_generate('free_text_52');</script>
									<textarea rows=4 cols=50 name="free_text_52">We'd like to thank you for being such a<br>valued customer by giving you <b>20% off any<br>purchase of $100 or more</b>. This offer is valid<br>in ALL stores!</textarea>
								</td>
							</tr>
						</table>
						<table cellspacing="1" cellpadding="2" border="0" class="main" width="100%"<%= (secID == 53)?"":" style=\"display:none;\"" %>>
							<tr>
								<th colspan="2">Win Back : Offer Body:</th>
							</tr>
							<tr>
								<td width="150">Enter Text:<br><br><li>4 line(s) maximum</li><li>Text limit of approximately 25 character(s) per line</li></td>
								<td>
									<script language="JavaScript1.2" defer>editor_generate('free_text_53');</script>
									<textarea rows=4 cols=50 name="free_text_53">We'd like to thank you for being such a<br>valued customer by inviting you to come to<br>ANY store and check out the great deals!</textarea>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block2_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width=590 colspan=3>
						<form name="FT10">
						<table class="main" cellpadding="2" cellspacing="1" width="590">
							<tr>
								<td align="left" valign="middle">
									Personalization Field:<br>
									<select name=PerzFields size=1 onchange="FT10.MergeSymbol.value='!*'+this.value+';'+FT10.DefaultValue.value+'*!';">
										<%= htmlPersonals %>		
									</select>
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle">
									Default Value:<br>
									<!-- Default value -->
									<input type=text name="DefaultValue" size=22 onkeyup="FT10.MergeSymbol.value='!*'+FT10.PerzFields.options[FT10.PerzFields.selectedIndex].value+';'+this.value+'*!';">
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle">
									Merge Symbol:<br>
									<!-- PickUp value -->
									<input type=text name=MergeSymbol size=34 disabled value="!*<%= firstPers %>;*!"><br>
									(copy and paste this into your content)
								</td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
