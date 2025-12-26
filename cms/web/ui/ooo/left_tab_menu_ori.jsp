<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

<%@ include file="../jsp/validator.jsp"%>

<HTML>
<HEAD>
<META HTTP-EQUIV="Expires" CONTENT="0">
<META HTTP-EQUIV="Caching" CONTENT="">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-store, no-cache">
<META HTTP-EQUIV="Content-Type" CONTENT="text/html;charset=UTF-8">
<TITLE>LEFT</TITLE>
<link rel="stylesheet" href="style.css" TYPE="text/css">
<script language="JavaScript" src="script.js"></script>
</HEAD>
<body>
<table border="0" width="150" cellspacing="0" cellpadding="0">

	<tr>
		<td align="left">
		<img valign="bottom" width="150" src="images/tab_left_line.gif" border="0">
		</td>
	</tr>
	<tr>
		<td align="left" valign="top">
		<a class="tab_button" target="detail" href="/cms/ui/jsp/home/welcome.jsp" ><img align="absmiddle" src="images/icon_home_18_18.png" border="0"> Home</a>

		<div style="cursor:hand" onclick="ShowHide(document.all.Id1);"><a class="tab_button" href="#"><img align="absmiddle" src="images/icon_msg_18_18.png" border="0"> Campaigns</a></div>
		<div id="Id1" align="center" style="display:none">
			<img src="images/37_37_rss.png"><br/><a href="cms/ui/jsp/camp/camp_list_rss.jsp" target="detail">RSS</a><br/><br/>
			<img src="images/37_37_sms.png"><br/><a href="/cms/ui/jsp/camp/camp_list_sms.jsp" target="detail">SMS</a><br/><br/>
			<img src="images/37_37_email.png"><br/><a href="/cms/ui/jsp/camp/camp_list.jsp" target="detail">Email</a><br/>
			<img src="images/37_37_dmaill.png"><br/><a href="/cms/ui/jsp/camp/camp_list_dmail.jsp" target="detail">Direct Mail</a>
		</div>
		
		<div style="cursor:hand" onclick="ShowHide(document.all.Id2);"><a class="tab_button" href="#"><img align="absmiddle" src="images/icon_db_18_18.png" border="0"> Database</a></div>
		<div id="Id2" align="center" style="display:none">
			<img src="images/37_37_em_db_tl.png"><br/><a href="/cms/ui/jsp/email_list/list_list.jsp?typeID=2" target="detail">Testing Lists</a><br/><br/>
			<img src="images/37_37_em_db_tl.png"><br/><a href="/cms/ui/jsp/email_list/list_list.jsp?typeID=3" target="detail">Exclusion Lists</a><br/><br/>
			<img src="images/37_37_em_db.png"><br/><a href="/cms/ui/jsp/import/import_list.jsp?amount=1000" target="detail">Import Lists</a><br/><br/>
			<img src="images/37_37_tg.png"><br/><a href="/cms/ui/jsp/filter/filter_list.jsp" target="detail">Segmentation</a><br/><br/>
			<img src="images/37_37_export.png"><br/><a href="/cms/ui/jsp/export/export_list.jsp" target="detail">Data Export</a><br/>
			<img src="images/37_37_search.png"><br/><a href="/cms/ui/jsp/edit/recip_search.jsp" target="detail">Contact Search</a>
		</div>
		
		<div style="cursor:hand" onclick="ShowHide(document.all.Id3);"><a class="tab_button" href="#"><img align="absmiddle" src="images/content.gif" border="0"> Contents</a></div>
		<div id="Id3" align="center" style="display:none">
			<img src="images/37_37_cnt.png"><br/><a href="/cms/ui/jsp/cont/cont_list.jsp" target="detail">Content</a><br/><br/>
			<img src="images/37_37_dyn_cnt.png"><br/><a href="/cms/ui/jsp/cont/logic_block_list.jsp" target="detail">Dynamic</a><br/>
			<img src="images/37_37_tmp_cnt.png"><br/><a href="/cms/ui/jsp/ctm/index.jsp" target="detail">Templates</a><br/>
			<img src="images/37_37_aln_cnt.png"><br/><a href="/cms/ui/jsp/cont/link_renaming_list.jsp" target="detail">Auto Link Names</a><br/>
			<img src="images/37_37_img_cnt.png"><br/><a href="/cms/ui/jsp/image/image_list.jsp" target="detail">Image Library</a><br/>
		</div>
		
		<div style="cursor:hand" onclick="ShowHide(document.all.Id4);"><a class="tab_button" href="#"><img align="absmiddle" src="images/reports.gif" border="0"> Reports</a></div>
		<div id="Id4" align="center" style="display:none">
			<img src="images/37_37_myreport.png"><br/><a href="/cms/ui/jsp/report/report_list.jsp" target="detail">My Reports</a><br/><br/>
			<img src="images/37_37_sreport.png"><br/><a href="/cms/ui/jsp/report/super_camp_report_list.jsp" target="detail">Super Reports</a><br/>
			<img src="images/37_37_creport.png"><br/><a href="/cms/ui/jsp/report/report_settings_edit.jsp" target="detail">Customize Reports</a><br/>
			<img src="images/37_37_report_fltr.png"><br/><a href="/cms/ui/jsp/report/filter_list.jsp" target="detail">Report Filters</a><br/><br/>
			<img src="images/37_37_tg.png"><br/><a href="/cms/ui/jsp/report/cust_report_list_frame.jsp" target="detail">Global Reports</a><br/><br/>
		</div>
		
		<div style="cursor:hand" onclick="ShowHide(document.all.Id5);"><a class="tab_button" href="#"><img align="absmiddle" src="images/icon_settings_18_18.png" border="0"> Settings</a></div>
		<div id="Id5" align="center" style="display:none">
			<img src="images/37_37_fromadr.png"><br/><a href="/cms/ui/jsp/setup/from_addresses/from_address_list.jsp" target="detail">From Address</a><br/>
			<img src="images/37_37_content.png"><br/><a href="/cms/ui/jsp/form/form_list.jsp" target="detail" target="detail">Subscription Form</a><br/><br/>
			<img src="images/37_37_custom_field.png"><br/><a href="/cms/ui/jsp/setup/cust_attrs/cust_attr_list.jsp" target="detail">Custom Fields</a><br/>
			<img src="images/37_37_cat.png"><br/><a href="/cms/ui/jsp/setup/categories/category_list.jsp" target="detail">Categories</a><br/>
			<img src="images/37_37_cat.png"><br/><a href="/cms/ui/jsp/setup/bbacks/bback_settings_edit.jsp" target="detail">Bounceback Settings</a><br/>
			<img src="images/37_37_cat.png"><br/><a href="/cms/ui/jsp/setup/cont_attrs/cont_attr_list.jsp" target="detail">Content Settings</a><br/>
		</div>
		
		<div style="cursor:hand" onclick="ShowHide(document.all.Id6);"><a class="tab_button" href="#"><img align="absmiddle" src="images/icon_user_18_18.png" border="0"> Users & Help</a></div>
		<div id="Id6" align="center" style="display:none">
			<img src="images/37_37_user.png"><br/><a href="/cms/ui/jsp/setup/users/user_list.jsp" target="detail">Users</a><br/><br/>
		</div>

		<%
		if(cust.s_cust_id.equals("181"))
		{
		%>
			<div style="cursor:hand" onclick="ShowHide(document.all.Id51);"><a class="tab_button" href="#"><img align="absmiddle" src="images/icon_settings_18_18.png" border="0"> Social Media</a></div>
			<div id="Id51" align="center" style="display:none">
				<img src="images/37_37_fromadr.png"><br/><a href="/cms/ui/jsp/som/dofilter?redirect_url=index.jsp" target="detail">Home</a><br/>
				<img src="images/37_37_content.png"><br/><a href="/cms/ui/jsp/som/dofilter?redirect_url=campaigns.jsp" target="detail" target="detail">Campaigns</a><br/><br/>
				<img src="images/37_37_custom_field.png"><br/><a href="/cms/ui/jsp/som/dofilter?redirect_url=reporting.jsp" target="detail">Reporting</a><br/>
				<img src="images/37_37_cat.png"><br/><a href="/cms/ui/jsp/som/dofilter?redirect_url=accounts.jsp" target="detail">Accounts</a><br/>
			</div>
		<%
		}
		%>
		
		</td>
	</tr>
</table>
<script language="javascript">
	curTab = document.getElementById("nav1");
</script>
</BODY>