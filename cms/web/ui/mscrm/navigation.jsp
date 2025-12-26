<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.net.*, 
			java.io.*, 
			java.sql.*, 
			java.util.*, 
			java.util.*, 
			java.sql.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../jsp/error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../jsp/header.jsp" %>
<%@ include file="../jsp/validator.jsp"%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	//grab query strings
		String sNavTab = request.getParameter("tab");
		String sNavSection = request.getParameter("sec");
	
	//set default values for querystrings
		if ((null == sNavTab) || ("" == sNavTab))
		{
			sNavTab = "Home";
		}
		
		if ((null == sNavSection) || ("" == sNavSection))
		{
			sNavSection = "1";
		}
	
	//set default values for selected Tab
		int iHome = 0;
		int iCamp = 0;
		int iData = 0;
		int iCont = 0;
		int iRept = 0;
		int iAdmn = 0;
		int iHelp = 0;
	
	//set default values to show or hide tabs
		int showHome = 1;
		int showCamp = 1;
		int showData = 1;
		int showCont = 1;
		int showRept = 1;
		int showAdmn = 1;
		int showHelp = 1;
	
	//set default values to show or hide sections
		int showCamp1 = 1;
		int showCamp2 = 1;
		int showCamp3 = 1;
		int showCamp4 = 1;
		int showCamp5 = 1;
		
		int showData1 = 1;
		int showData2 = 1;
		int showData3 = 1;
		int showData4 = 1;
		
		int showCont1 = 1;
		int showCont2 = 1;
		int showCont3 = 1;
		
		int showAdmn1 = 1;
		int showAdmn2 = 1;
		int showAdmn3 = 1;
		int showAdmn4 = 1;
		int showAdmn5 = 1;
		int showAdmn6 = 1;
	
	//set default values for the nav styles
		String sNavHome1 = "navsuboff";
		
		String sNavCamp1 = "navsuboff";
		String sNavCamp2 = "navsuboff";
		String sNavCamp3 = "navsuboff";
		String sNavCamp4 = "navsuboff";
		String sNavCamp5 = "navsuboff";
		
		String sNavData1 = "navsuboff";
		String sNavData2 = "navsuboff";
		String sNavData3 = "navsuboff";
		String sNavData4 = "navsuboff";
		
		String sNavCont1 = "navsuboff";
		String sNavCont2 = "navsuboff";
		String sNavCont3 = "navsuboff";
		
		String sNavRept1 = "navsuboff";
		String sNavRept2 = "navsuboff";
		String sNavRept3 = "navsuboff";
		
		String sNavAdmn1 = "navsuboff";
		String sNavAdmn2 = "navsuboff";
		String sNavAdmn3 = "navsuboff";
		String sNavAdmn4 = "navsuboff";
		String sNavAdmn5 = "navsuboff";
		String sNavAdmn6 = "navsuboff";
		
		String sNavHelp1 = "navsuboff";
		String sNavHelp2 = "navsuboff";
		String sNavHelp3 = "navsuboff";
		String sNavHelp4 = "navsuboff";
		
	//Standard UI Check
		boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
		if (STANDARD_UI)
		{
			showCamp3 = 0;
			showCamp4 = 0;
			showCont2 = 0;
		}
		
	//check access levels per section
		AccessPermission can;
	
	//Campaigns -- check access levels
		can = user.getAccessPermission(ObjectType.CAMPAIGN);
		
		if(!can.bRead)
		{
			showCamp = 0;
		}
		
	//Database -- check access levels
		can = user.getAccessPermission(ObjectType.IMPORT);
		
		if(!can.bRead)
		{
			showData1 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.FILTER);
		
		if(!can.bRead)
		{
			showData2 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.EXPORT);
		
		if(!can.bRead)
		{
			showData3 = 0;
		}
		
		if (showData1 == 0 && showData2 == 0 && showData3 == 0)
		{
			showData = 0;
		}
			
	//Content -- check access levels
		can = user.getAccessPermission(ObjectType.CONTENT);
		
		if(!can.bRead)
		{
			showCont1 = 0;
			showCont2 = 0;
		}
		
		if(!can.bWrite)
		{
			showCont3 = 0;
		}
		
		if (showCont1 == 0 && showCont3 == 0)
		{
			showCont = 0;
		}
		
	//Reporting -- check access levels
		can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
		
		if(!can.bRead)
		{
			showRept = 0;
		}
	
	//Administration -- check access levels
		can = user.getAccessPermission(ObjectType.USER);
		
		if(!can.bRead)
		{
			showAdmn1 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
		
		if(!can.bRead)
		{
			showAdmn4 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.CATEGORY);
		
		if(!can.bRead)
		{
			showAdmn5 = 0;
		}
		
		can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
		
		if(!can.bRead)
		{
			showAdmn6 = 0;
		}
		
	//check tab and set variables
		if (sNavTab.equals("Home"))
		{
			//set variables
				//iHome = 1;
				iCamp = 1;
				if (sNavSection.equals("1")) sNavHome1 = "navsubon";
		}
		else if (sNavTab.equals("Camp"))
		{
			//set variables
				iCamp = 1;
				if (sNavSection.equals("1")) sNavCamp1 = "navsubon";
				if (sNavSection.equals("2")) sNavCamp2 = "navsubon";
				if (sNavSection.equals("3")) sNavCamp3 = "navsubon";
				if (sNavSection.equals("4")) sNavCamp4 = "navsubon";
				if (sNavSection.equals("5")) sNavCamp5 = "navsubon";
		}
		else if (sNavTab.equals("Data"))
		{
			//set variables
				iData = 1;
				if (sNavSection.equals("1")) sNavData1 = "navsubon";
				if (sNavSection.equals("2")) sNavData2 = "navsubon";
				if (sNavSection.equals("3")) sNavData3 = "navsubon";
				if (sNavSection.equals("4")) sNavData4 = "navsubon";
		}
		else if (sNavTab.equals("Cont"))
		{
			//set variables
				iCont = 1;
				if (sNavSection.equals("1")) sNavCont1 = "navsubon";
				if (sNavSection.equals("2")) sNavCont2 = "navsubon";
				if (sNavSection.equals("3")) sNavCont3 = "navsubon";
		}
		else if (sNavTab.equals("Rept"))
		{
			//set variables
				//iRept = 1;
				iCamp = 1;
				if (sNavSection.equals("1")) sNavRept1 = "navsubon";
				if (sNavSection.equals("2")) sNavRept2 = "navsubon";
				if (sNavSection.equals("3")) sNavRept3 = "navsubon";
		}
		else if (sNavTab.equals("Admn"))
		{
			//set variables
				iAdmn = 1;
				if (sNavSection.equals("1")) sNavAdmn1 = "navsubon";
				if (sNavSection.equals("2")) sNavAdmn2 = "navsubon";
				if (sNavSection.equals("3")) sNavAdmn3 = "navsubon";
				if (sNavSection.equals("4")) sNavAdmn4 = "navsubon";
				if (sNavSection.equals("5")) sNavAdmn5 = "navsubon";
				if (sNavSection.equals("6")) sNavAdmn6 = "navsubon";
		}
		else if (sNavTab.equals("Help"))
		{
			//set variables
				iHelp = 1;
				if (sNavSection.equals("1")) sNavHelp1 = "navsubon";
				if (sNavSection.equals("2")) sNavHelp2 = "navsubon";
				if (sNavSection.equals("3")) sNavHelp3 = "navsubon";
		}
		else
		{
			//set variables
				//iHome = 1;
				iCamp = 1;
				if (sNavSection.equals("1")) sNavHome1 = "navsubon";
		}
%>
<HTML>
<HEAD>
<TITLE></TITLE>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<style>

td
{
	padding:0px;
}

</style>
<script language="javascript">
<!--

function ShowHide(val)
{
	if (val.style.display == 'none')
	{
		val.style.display = '';
	}
	else
	{
		val.style.display='none';
	}
}

//-->
</script>
</HEAD>
<BODY leftmargin="0" topmargin="0" class="navBody">
<table width="150" cellspacing="0" cellpadding="0" align="right">
	<tr>
		<td align="left" valign="top">&nbsp;</td>
	</tr>
	<tr>
		<td align="right" valign="top" width="150">
		<!----- ----->
			<table border=0 cellpadding=0 cellspacing=0 width="141"<%= (showCamp == 0)?" style=\"display:none;\"":"" %>>
				<tr style="cursor:hand" onclick="ShowHide(document.all.sec_Camp);">
					<td class="navmainon" align="left" valign="middle" nowrap>:: Campaigns</td>
				</tr>
				<tbody id="sec_Camp"<%= (iCamp == 1)?"":" style=\"display:none\"" %>>
				<tr>
					<td<%= (showHome == 0)?" style=\"display:none;\"":"" %> class="<%= sNavHome1 %>" nowrap><a class="<%= sNavHome1 %>" href="../jsp/index.jsp?tab=Home&sec=1"  target="_parent">&nbsp;Welcome</td>
				</tr>
				<tr>
					<td<%= (showCamp5 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCamp5 %>" nowrap><a class="<%= sNavCamp5 %>" href="../jsp/index.jsp?tab=Camp&sec=5"  target="_parent"><img src="images/mscrmquickcampaign.gif" border=0 align="absmiddle">&nbsp;Quick Campaign</td>
				</tr>
				<tr>
					<td<%= (showCamp1 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCamp1 %>" nowrap><a class="<%= sNavCamp1 %>" href="../jsp/index.jsp?tab=Camp&sec=1"  target="_parent"><img src="images/mscrmsendout.gif" border=0 align="absmiddle">&nbsp;My Campaigns</td>
				</tr>
				<tr>
					<td<%= (showCamp2 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCamp2 %>" nowrap><a class="<%= sNavCamp2 %>" href="../jsp/index.jsp?tab=Camp&sec=2"  target="_parent"><img src="images/mscrmtest.gif" border=0 align="absmiddle">&nbsp;Test Lists</a></td>
				</tr>
				<tr>
					<td<%= (showCamp3 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCamp3 %>" nowrap><a class="<%= sNavCamp3 %>" href="../jsp/index.jsp?tab=Camp&sec=3"  target="_parent"><img src="images/mscrmexclusion.gif" border=0 align="absmiddle">&nbsp;Exclusion Lists</a></td>
				</tr>
				<tr>
					<td<%= (showCamp4 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCamp4 %>" nowrap><a class="<%= sNavCamp4 %>" href="../jsp/index.jsp?tab=Camp&sec=4"  target="_parent"><img src="images/mscrmnotification.gif" border=0 align="absmiddle">&nbsp;Notification Lists</a></td>
				</tr>
				<tr>
					<td<%= (showRept == 0)?" style=\"display:none;\"":"" %> class="<%= sNavRept1 %>" nowrap><a class="<%= sNavRept1 %>" href="../jsp/index.jsp?tab=Rept&sec=1"  target="_parent"><img src="images/mscrmreports.gif" border=0 align="absmiddle">&nbsp;My Reports</a></td>
				</tr>
				<tr>
					<td<%= (showRept == 0)?" style=\"display:none;\"":"" %> class="<%= sNavRept2 %>" nowrap><a class="<%= sNavRept2 %>" href="../jsp/index.jsp?tab=Rept&sec=2"  target="_parent"><img src="images/mscrmsupercamp.gif" border=0 align="absmiddle">&nbsp;Super Reports</a></td>
				</tr>
				</tbody>
			</table>
			<br>
			<table border=0 cellpadding=0 cellspacing=0 width="141"<%= (showData == 0)?" style=\"display:none;\"":"" %>>
				<tr style="cursor:hand" onclick="ShowHide(document.all.sec_Data);">
					<td class="navmainon" align="left" valign="middle" nowrap>:: Data Management</td>
				</tr>
				<tbody id="sec_Data"<%= (iData == 1)?"":" style=\"display:none\"" %>>
				<tr>
					<td<%= (showData1 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavData1 %>" nowrap><a class="<%= sNavData1 %>" href="../jsp/index.jsp?tab=Data&sec=1"  target="_parent"><img src="images/mscrmimport.gif" border=0 align="absmiddle">&nbsp;Imports</a></td>
				</tr>
				<tr>
					<td<%= (showData2 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavData2 %>" nowrap><a class="<%= sNavData2 %>" href="../jsp/index.jsp?tab=Data&sec=2"  target="_parent"><img src="images/mscrmtarget.gif" border=0 align="absmiddle">&nbsp;Target Groups</a></td>
				</tr>
				<tr>
					<td<%= (showData3 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavData3 %>" nowrap><a class="<%= sNavData3 %>" href="../jsp/index.jsp?tab=Data&sec=3"  target="_parent"><img src="images/mscrmexport.gif" border=0 align="absmiddle">&nbsp;Exports</a></td>
				</tr>
				<tr>
					<td<%= (showData4 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavData4 %>" nowrap><a class="<%= sNavData4 %>" href="../jsp/index.jsp?tab=Data&sec=4"  target="_parent"><img src="images/mscrmsearch.gif" border=0 align="absmiddle">&nbsp;Contact Search</a></td>
				</tr>
				</tbody>
			</table>
			<br>
			<table border=0 cellpadding=0 cellspacing=0 width="141"<%= (showCont == 0)?" style=\"display:none;\"":"" %>>
				<tr style="cursor:hand" onclick="ShowHide(document.all.sec_Cont);">
					<td class="navmainon" align="left" valign="middle" nowrap>:: Content Creation</td>
				</tr>
				<tbody id="sec_Cont"<%= (iCont == 1)?"":" style=\"display:none\"" %>>
				<tr>
					<td<%= (showCont1 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCont1 %>" nowrap><a class="<%= sNavCont1 %>" href="../jsp/index.jsp?tab=Cont&sec=1"  target="_parent"><img src="images/mscrmcontent.gif" border=0 align="absmiddle">&nbsp;My Content</a></td>
				</tr>
				<tr>
					<td<%= (showCont3 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCont3 %>" nowrap><a class="<%= sNavCont3 %>" href="../jsp/index.jsp?tab=Cont&sec=3"  target="_parent"><img src="images/mscrmtemplate.gif" border=0 align="absmiddle">&nbsp;Templates</a></td>
				</tr>
				<tr>
					<td<%= (showCont2 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavCont2 %>" nowrap><a class="<%= sNavCont2 %>" href="../jsp/index.jsp?tab=Cont&sec=2"  target="_parent"><img src="images/mscrmblocks.gif" border=0 align="absmiddle">&nbsp;Dynamic Elements</a></td>
				</tr>
				</tbody>
			</table>
			<br>
			<table border=0 cellpadding=0 cellspacing=0 width="141"<%= (showAdmn == 0)?" style=\"display:none;\"":"" %>>
				<tr style="cursor:hand" onclick="ShowHide(document.all.sec_Admn);">
					<td class="navmainon" align="left" valign="middle" nowrap>:: Administration</td>
				</tr>
				<tbody id="sec_Admn"<%= (iAdmn == 1)?"":" style=\"display:none\"" %>>
				<tr>
					<td<%= (showAdmn2 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavAdmn2 %>" nowrap><a class="<%= sNavAdmn2 %>" href="../jsp/index.jsp?tab=Admn&sec=2"  target="_parent"><img src="images/mscrmcategories.gif" border=0 align="absmiddle">&nbsp;From Address</a></td>
				</tr>
				<tr>
					<td<%= (showAdmn3 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavAdmn3 %>" nowrap><a class="<%= sNavAdmn3 %>" href="../jsp/index.jsp?tab=Admn&sec=3"  target="_parent"><img src="images/mscrmcategories.gif" border=0 align="absmiddle">&nbsp;Subscription Form</a></td>
				</tr>
				<tr>
					<td<%= (showAdmn5 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavAdmn5 %>" nowrap><a class="<%= sNavAdmn5 %>" href="../jsp/index.jsp?tab=Admn&sec=5"  target="_parent"><img src="images/mscrmcategories.gif" border=0 align="absmiddle">&nbsp;Categories</a></td>
				</tr>
				<tr>
					<td<%= (showAdmn6 == 0)?" style=\"display:none;\"":"" %> class="<%= sNavAdmn6 %>" nowrap><a class="<%= sNavAdmn6 %>" href="../jsp/index.jsp?tab=Admn&sec=6"  target="_parent"><img src="images/mscrmreports.gif" border=0 align="absmiddle">&nbsp;Customize Reports</a></td>
				</tr>
				</tbody>
			</table>
			<br>
			<table border=0 cellpadding=0 cellspacing=0 width="141"<%= (showHelp == 0)?" style=\"display:none;\"":"" %>>
				<tr style="cursor:hand" onclick="ShowHide(document.all.sec_Help);">
					<td class="navmainon" align="left" valign="middle" nowrap>:: Support</td>
				</tr>
				<tbody id="sec_Help"<%= (iHelp == 1)?"":" style=\"display:none\"" %>>
				<tr>
					<td<%= (showHelp == 0)?" style=\"display:none;\"":"" %> class="<%= sNavHelp2 %>" nowrap><a class="<%= sNavHelp2 %>" href="../jsp/index.jsp?tab=Help&sec=2"  target="_parent"><img src="images/mscrmhelp.gif" border=0 align="absmiddle">&nbsp;Help Document</a></td>
				</tr>
				<tr>
					<td<%= (showHelp == 0)?" style=\"display:none;\"":"" %> class="<%= sNavHelp3 %>" nowrap><a class="<%= sNavHelp3 %>" href="../jsp/index.jsp?tab=Help&sec=3"  target="_parent"><img src="images/mscrmhelp.gif" border=0 align="absmiddle">&nbsp;FAQs</a></td>
				</tr>
				<tr>
					<td<%= (showHelp == 0)?" style=\"display:none;\"":"" %> class="<%= sNavHelp4 %>" nowrap><a class="<%= sNavHelp4 %>" href="../jsp/index.jsp?tab=Help&sec=4"  target="_parent"><img src="images/mscrmhelp.gif" border=0 align="absmiddle">&nbsp;Contact Support</a></td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>