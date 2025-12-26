<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sOption = request.getParameter("opt");
if (sOption == null) sOption = "dyn";

boolean showLive = false;
if ("live".equals(sOption)) showLive = true;

%>
<html>
<head>
<title>Print Content</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
<script language="javascript" src="../../js/tab_script.js"></script>
<script language="javascript">

function showLiveData(ord)
{
	var sec1 = document.getElementById("live_1");
	var sec2 = document.getElementById("live_2");
	var sec3 = document.getElementById("live_3");
	var sec4 = document.getElementById("live_4");
	var sec5 = document.getElementById("live_5");
	
	switch(ord)
	{
		case 1:
			//HIDE
			sec2.style.display = "none";
			
			//SHOW
			sec1.style.display = "";
			
			//SET DATA
			FT.fname.value = "John";
			FT.lname.value = "Smith";
			FT.addr.value = "1234 Main St";
			FT.cityst.value = "Boston, MA 01801";
			
			FT.purch_date[0].checked = true;
			FT.purch_dept[0].checked = true;
			
			FT.submit();
			
			break;
		
		case 2:
			//HIDE
			sec1.style.display = "none";
			sec3.style.display = "none";
			
			//SHOW
			sec2.style.display = "";
			
			//SET DATA
			FT.fname.value = "Sally";
			FT.lname.value = "Buyer";
			FT.addr.value = "578 Department Rd Apt 3A";
			FT.cityst.value = "Newark, NJ 23567";
			
			FT.purch_date[1].checked = true;
			FT.purch_dept[2].checked = true;
			
			FT.submit();
			
			break;
		
		case 3:
			//HIDE
			sec2.style.display = "none";
			sec4.style.display = "none";
			
			//SHOW
			sec3.style.display = "";
			
			//SET DATA
			FT.fname.value = "Rick";
			FT.lname.value = "Miller";
			FT.addr.value = "1004 LakeView Ln";
			FT.cityst.value = "Chicago, IL 47812";
			
			FT.purch_date[2].checked = true;
			FT.purch_dept[3].checked = true;
			
			FT.submit();
			
			break;
		
		case 4:
			//HIDE
			sec3.style.display = "none";
			sec5.style.display = "none";
			
			//SHOW
			sec4.style.display = "";
			
			//SET DATA
			FT.fname.value = "";
			FT.lname.value = "";
			FT.addr.value = "49023 SE 45th Way";
			FT.cityst.value = "Redmond, WA 98052";
			
			FT.purch_date[3].checked = true;
			FT.purch_dept[2].checked = true;
			
			FT.submit();
			
			break;
		
		case 5:
			//HIDE
			sec4.style.display = "none";
			
			//SHOW
			sec5.style.display = "";
			
			//SET DATA
			FT.fname.value = "Marth";
			FT.lname.value = "Kent";
			FT.addr.value = "14 AppleTree Ct";
			FT.cityst.value = "Smallville, KS 74365";
			
			FT.purch_date[1].checked = true;
			FT.purch_dept[1].checked = true;
			
			FT.submit();
			
			break;
		
		default:
			
			break;
	}
}

</script>
</head>
<body>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
<% if (showLive) { %>
	<tr height="150">
		<td>
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
								<td align="center" valign="middle" style="padding:10px;">
									<b>Live Data Preview</b><br>
									Choose a Target Group from which to select preview data:<br><br>
									<select name="filter_id" id="filter_id">
										<option value="1">Newsletter Subscribers</option>
										<option value="1">WinBack: 90 Days</option>
										<option value="1">Payments Overdue</option>
									</select>
									<br><br>
									<a href="javascript:showLiveData(1);" class="subactionbutton">Generate Preview</a>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr height="30" id="live_1" style="display:none;">
		<td>
			<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%; height:100%;">
				<col width="80">
				<col>
				<col width="80">
				<tr>
					<th align="left">&nbsp;</th>
					<td align="center" class="listItem_Data"><b>John Smith</b> (1 of 5)</td>
					<th align="right" title="Preview Next Recipient" onclick="javascript:showLiveData(2);" style="cursor:hand;">Next >></a></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="30" id="live_2" style="display:none;">
		<td>
			<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%; height:100%;">
				<col width="80">
				<col>
				<col width="80">
				<tr>
					<th align="right" title="Preview Previous Recipient" onclick="javascript:showLiveData(1);" style="cursor:hand;"><< Previous</a></td>
					<td align="center" class="listItem_Data"><b>Sally Buyer</b> (2 of 5)</td>
					<th align="right" title="Preview Next Recipient" onclick="javascript:showLiveData(3);" style="cursor:hand;">Next >></a></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="30" id="live_3" style="display:none;">
		<td>
			<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%; height:100%;">
				<col width="80">
				<col>
				<col width="80">
				<tr>
					<th align="right" title="Preview Previous Recipient" onclick="javascript:showLiveData(2);" style="cursor:hand;"><< Previous</a></td>
					<td align="center" class="listItem_Data"><b>Rick Miller</b> (3 of 5)</td>
					<th align="right" title="Preview Next Recipient" onclick="javascript:showLiveData(4);" style="cursor:hand;">Next >></a></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="30" id="live_4" style="display:none;">
		<td>
			<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%; height:100%;">
				<col width="80">
				<col>
				<col width="80">
				<tr>
					<th align="right" title="Preview Previous Recipient" onclick="javascript:showLiveData(3);" style="cursor:hand;"><< Previous</a></td>
					<td align="center" class="listItem_Data"><b><< UNKNOWN NAME >></b> (4 of 5)</td>
					<th align="right" title="Preview Next Recipient" onclick="javascript:showLiveData(5);" style="cursor:hand;">Next >></a></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="30" id="live_5" style="display:none;">
		<td>
			<table cellspacing="0" cellpadding="2" border="0" class="listTable layout" style="width:100%; height:100%;">
				<col width="80">
				<col>
				<col width="80">
				<tr>
					<th align="right" title="Preview Previous Recipient" onclick="javascript:showLiveData(4);" style="cursor:hand;"><< Previous</a></td>
					<td align="center" class="listItem_Data"><b>Martha Kent</b> (5 of 5)</td>
					<th align="right">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
<% } %>
	<tr height="165">
		<td>
			<table id="Tabs_Table2" cellspacing=0 cellpadding=0 border=0 class="layout" style="width:100%; height:100%;">
				<col width="150">
				<col width="150">
				<col>
				<tr height="22">
					<td class=EditTabOn id=tab2_Step1 onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Preview</td>
					<td class=EditTabOff id=tab2_Step2 onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Details</td>
					<td class=EmptyTab valign=center nowrap align=middle ><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr height="2">
					<td class=fillTabbuffer valign=top align=left colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block2_Step1>
				<tr>
					<td class=fillTab valign=top align=center colspan=3>
						<div style="width:100%; height:100%; overflow-y:auto;">
						<form target="preview_frame" name="FT" style="display:inline;" action="demo/preview_postcard.jsp" method="get">
						<table width=100% class="main" cellpadding="1" cellspacing="1">
							<tr>
								<td width="50%">First Name</td>
								<td width="50%"><input type="text" size="30" name="fname"></td>
							</tr>
							<tr>
								<td width="50%">Last Name</td>
								<td width="50%"><input type="text" size="30" name="lname"></td>
							</tr>
							<tr>
								<td width="50%">Address</td>
								<td width="50%"><input type="text" size="30" name="addr"></td>
							</tr>
							<tr>
								<td width="50%">City, State, ZIP</td>
								<td width="50%"><input type="text" size="30" name="cityst"></td>
							</tr>
						</table>
						<br>
						<table width=100% class="main" cellpadding="1" cellspacing="1">
							<tr>
								<td width="50%">Last Purchase Date is 60 Days Ago</td>
								<td width="50%"><input type="radio" name="purch_date" value="hdr2a"></td>
							</tr>
							<tr>
								<td width="50%">Last Purchase Date is 90 Days Ago</td>
								<td width="50%"><input type="radio" name="purch_date" value="hdr2b"></td>
							</tr>
							<tr>
								<td width="50%">Last Purchase Date is 120 Days Ago</td>
								<td width="50%"><input type="radio" name="purch_date" value="hdr2c"></td>
							</tr>
							<tr>
								<td width="50%">Default</td>
								<td width="50%"><input type="radio" name="purch_date" value="hdr2"></td>
							</tr>
						</table>
						<br>
						<table width=100% class="main" cellpadding="1" cellspacing="1">
							<tr>
								<td width="50%">Last Purchase Dept: Jewelry</td>
								<td width="50%"><input type="radio" name="purch_dept" value="watch.gif"></td>
							</tr>
							<tr>
								<td width="50%">Last Purchase Dept: Kitchen</td>
								<td width="50%"><input type="radio" name="purch_dept" value="pots.gif"></td>
							</tr>
							<tr>
								<td width="50%">Last Purchase Dept: Electronics</td>
								<td width="50%"><input type="radio" name="purch_dept" value="camera.gif"></td>
							</tr>
							<tr>
								<td width="50%">Default</td>
								<td width="50%"><input type="radio" name="purch_dept" value="pots.gif"></td>
							</tr>
						</table>
						</form>
						</div>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block2_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width=100% colspan=3>
						<div style="width:100%; height:100%; overflow-y:auto;">
						<table width=100% class="main" cellpadding="1" cellspacing="1">
							<tr>
								<th colspan=2>Logic Block: Win Back: Masthead</th>
							</tr>
							<tr>
								<td width="50%" class="subsectionheader">Content Element</td>
								<td width="50%" class="subsectionheader">Logic Element</td>
							</tr>
							<tr>
								<td width="50%">Win Back : 60 Day Masthead</td>
								<td width="50%">Last Purchase Date is 60 Days Ago</td>
							</tr>
							<tr>
								<td width="50%">Win Back : 90 Day Masthead</td>
								<td width="50%">Last Purchase Date is 90 Days Ago</td>
							</tr>
							<tr>
								<td width="50%">Win Back : 120 Days Masthead</td>
								<td width="50%">Last Purchase Date is 120 Days Ago</td>
							</tr>
						</table>
						<br>
						<table width=100% class="main" cellpadding="1" cellspacing="1">
							<tr>
								<th colspan=2>Logic Block: Win Back: Body</th>
							</tr>
							<tr>
								<td width="50%" class="subsectionheader">Content Element</td>
								<td width="50%" class="subsectionheader">Logic Element</td>
							</tr>
							<tr>
								<td width="50%">Win Back : 60 Day Body</td>
								<td width="50%">Last Purchase Date is 60 Days Ago</td>
							</tr>
							<tr>
								<td width="50%">Win Back : 90 Day Body</td>
								<td width="50%">Last Purchase Date is 90 Days Ago</td>
							</tr>
							<tr>
								<td width="50%">Win Back : 120 Days Body</td>
								<td width="50%">Last Purchase Date is 120 Days Ago</td>
							</tr>
						</table>
						<br>
						<table width=100% class="main" cellpadding="1" cellspacing="1">
							<tr>
								<th colspan=2>Logic Block: Win Back: Department</th>
							</tr>
							<tr>
								<td width="50%" class="subsectionheader">Content Element</td>
								<td width="50%" class="subsectionheader">Logic Element</td>
							</tr>
							<tr>
								<td width="50%">Win Back : Last Purchased : Jewelry</td>
								<td width="50%">Last Purchase Dept: Jewelry</td>
							</tr>
							<tr>
								<td width="50%">Win Back : Last Purchased : Kitchen</td>
								<td width="50%">Last Purchase Dept: Kitchen</td>
							</tr>
							<tr>
								<td width="50%">Win Back : Last Purchased Electronics</td>
								<td width="50%">Last Purchase Dept: Electronics</td>
							</tr>
						</table>
						</div>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr height="30">
		<th>
			<center>
				<a class="resourcebutton" href="javascript:FT.submit();">Preview</a>
			</center>
		</th>
	</tr>
	<tr>
		<td>
			<iframe name="preview_frame" src="demo/preview_postcard.jsp" style="width:100%; height:100%;" frameborder="0" border="0" scrolling="auto"></iframe>
		</td>
	</tr>
</table>
</body>
</html>