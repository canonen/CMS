<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,org.w3c.dom.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

AccessPermission can2 = user.getAccessPermission(ObjectType.RECIPIENT);

boolean bCanRead = can.bRead && can2.bRead;

if(!bCanRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canExp = user.getAccessPermission(ObjectType.EXPORT);
AccessPermission canTG = user.getAccessPermission(ObjectType.FILTER);

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<title>Report Details</title>
</HEAD>
<body>
<%

// Connection
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;

String sRequestXML = "";
String sListXML = "";

String Mode	= request.getParameter("Action").trim();
if (Mode == null) Mode = "all";

String CampId 		= request.getParameter("Q");
String LinkId		= request.getParameter("H");
String ContentType	= request.getParameter("T");
String FormId		= request.getParameter("F");
String sMax		= request.getParameter("Max");
if (sMax == null) sMax = ui.s_recip_view_count;

String BBackCatId	= request.getParameter("B");
String Domain		= request.getParameter("D");
String NewsletterId	= request.getParameter("N");
String UnsubLevelId	= request.getParameter("S");

String Cache		= request.getParameter("Z");
if ( (Cache == null) || (Cache.equals("")) ) Cache = "0";

String CacheID		= request.getParameter("C");
if ( (CacheID == null) || (CacheID.equals("")) ) CacheID = "0";

String sAction = null;

int	CampType		= 0;
int numRecs = 0;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_detail.jsp");
	stmt = conn.createStatement();

	String sSql = null;

	if ((CampId != null) && (CampId != ""))
	{
		sSql = 
			" SELECT count(c.camp_id), MAX(c.type_id)" +
			" FROM cque_campaign c" +
			" WHERE c.cust_id = " + cust.s_cust_id +
			" AND c.camp_id = " + CampId;
		rs = stmt.executeQuery(sSql);
				
		while(rs.next())
		{
			numRecs = rs.getInt(1);
			CampType = rs.getInt(2);
		}
	}

	rs.close();

	if ((CampId == null) || (CampId == "") || (numRecs < 1))
	{
%>
		<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
			<tr>
				<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tr>
				<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tbody class=EditBlock id=block1_Step1>
			<tr>
				<td class=fillTab valign=top align=center width=650>
					<table class=main cellspacing=1 cellpadding=2 width="100%">
						<tr>
							<td align="center" valign="middle" style="padding:10px;">
								<b>No Campaign for that ID</b>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			</tbody>
		</table>
		<br><br>
		<%	
	}
	else
	{
		String sCacheStartDate = null;
		String sCacheEndDate = null;
		String sCacheAttrID = null;
		String sCacheAttrValue1 = null;
		String sCacheAttrValue2 = null;
		String sCacheAttrOperator = null;
		String sCacheUserID = "0";
		String sCacheFilterID = null;
		
		if ("1".equals(Cache))
		{
			sSql = 
				" SELECT cache_start_date, cache_end_date, attr_id," +
				" attr_value1, attr_value2, attr_operator, user_id, filter_id" +
				" FROM crpt_camp_summary_cache" +
				" WHERE camp_id = " + CampId +
				" AND cache_id = " +CacheID;
				
			rs = stmt.executeQuery(sSql);
						
			if (rs.next())
			{
				sCacheStartDate = rs.getString(1);
				sCacheEndDate = rs.getString(2);
				sCacheAttrID = rs.getString(3);
				
				byte [] bval = rs.getBytes(4);
				sCacheAttrValue1 = (bval!=null?(new String(bval, "UTF-8")).trim():null);
				
				bval = rs.getBytes(5);
				sCacheAttrValue2 = (bval!=null?(new String(bval, "UTF-8")).trim():null);
				
				sCacheAttrOperator = rs.getString(6);
				sCacheUserID = rs.getString(7);
				
				if ( (sCacheUserID == null) || (sCacheUserID.equals("")) )
					sCacheUserID = "0";
				sCacheFilterID = rs.getString(8);
			}
		}
		else if ("2".equals(Cache))
		{
			sCacheUserID = user.s_user_id;
		}

		String sFields = " recip_id, email_821, pnmgiven, pnmfamily";
		sSql =
			" SELECT ca.attr_id, a.attr_name, ca.display_name" +
			" FROM ccps_attribute a, ccps_cust_attr ca" +
			" WHERE" +
			" ca.cust_id="+cust.s_cust_id+" AND" +
			" a.attr_id = ca.attr_id AND" +
			" ((ISNULL(ca.recip_view_seq, 0) > 0 AND" +
			" ISNULL(a.internal_flag,0) <= 0) OR a.attr_name IN ('recip_id'))" +
			" ORDER BY ca.recip_view_seq, ca.display_name";

		rs = stmt.executeQuery(sSql);
					
		String sAttrIDList = "";
		String sAttrDisplayList = "";
		String sAttrNameList = "";
		
		while (rs.next())
		{
			sAttrIDList += ((sAttrIDList.length()>0)?",":"")+rs.getString(1);
			sAttrNameList += ((sAttrNameList.length()>0)?",":"")+rs.getString(2);
			sAttrDisplayList += ((sAttrDisplayList.length()>0)?",":"")+rs.getString(3);
		}

		if (Mode.equals("all"))
			sAction = "RptCampSent";
		else if (Mode.equals("rcvd"))
			sAction = "RptCampRcvd";
		else if (Mode.equals("bbk"))
			sAction = "RptCampBBack";
		else if (Mode.equals("read"))
			sAction = "RptCampRead";
		else if (Mode.equals("unsub"))
			sAction = "RptCampUnsub";
		else if (Mode.equals("click"))
			sAction = "RptCampClick";
		else if (Mode.equals("multiread"))
			sAction = "RptCampMultiRead";
		else if (Mode.equals("multiclick"))
			sAction = "RptCampMultiClick";
		else if (Mode.equals("multilink")) 
			sAction = "RptCampMultiLink";
		else if (Mode.equals("view"))
			sAction = "RptCampFormView";
		else if (Mode.equals("submit"))
			sAction = "RptCampFormSubmit";
		else if (Mode.equals("multisubmit"))
			sAction = "RptCampFormMultiSubmit";
		else if (Mode.equals("domainsent"))
			sAction = "RptCampDomainSent";
		else if (Mode.equals("domainbbk"))
			sAction = "RptCampDomainBBack";
		else if (Mode.equals("domainread"))
			sAction = "RptCampDomainRead";
		else if (Mode.equals("domainclick"))
			sAction = "RptCampDomainClick";	
	    else if (Mode.equals("domainunsub"))
			sAction = "RptCampDomainUnsub";											
		else if (Mode.equals("domainspam"))
			sAction = "RptCampDomainSpam";	
		else if (Mode.equals("unsublevel"))
			sAction = "RptCampSpamLevel";							        				
		else if (Mode.equals("optout"))
			sAction = "RptCampOptout";
			
		sRequestXML += "<RecipRequest>";
		sRequestXML += "<action>"+sAction+"</action>";
		sRequestXML += "<cust_id>"+cust.s_cust_id+"</cust_id>";
		sRequestXML += "<camp_id>"+CampId+"</camp_id>";
		if ((LinkId != null) && !(LinkId.equals("")))
			sRequestXML += "<link_id>"+LinkId+"</link_id>";
		if ((ContentType != null) && !(ContentType.equals("")))
			sRequestXML += "<content_type>"+ContentType+"</content_type>";
		if ((FormId != null) && !(FormId.equals("")))
			sRequestXML += "<form_id>"+FormId+"</form_id>";
		if ((Domain != null) && !(Domain.equals("")))
			sRequestXML += "<domain><![CDATA["+Domain+"]]></domain>";
		if ((NewsletterId != null) && !(NewsletterId.equals("")))
			sRequestXML += "<newsletter_id>"+NewsletterId+"</newsletter_id>";
		if ((BBackCatId != null) && !(BBackCatId.equals("")))
			sRequestXML += "<bback_category>"+BBackCatId+"</bback_category>";	       	
        if ((UnsubLevelId != null) && !(UnsubLevelId.equals("")))
			sRequestXML += "<unsub_level>"+UnsubLevelId+"</unsub_level>";	        	   			   		
		if (CacheID != null)
			sRequestXML += "<cache_id>"+CacheID+"</cache_id>";
		if (sCacheStartDate != null)
			sRequestXML += "<cache_start_date><![CDATA["+sCacheStartDate+"]]></cache_start_date>";
		if (sCacheEndDate != null)
			sRequestXML += "<cache_end_date><![CDATA["+sCacheEndDate+"]]></cache_end_date>";
		if (sCacheAttrID != null)
			sRequestXML += "<cache_attr_id>"+sCacheAttrID+"</cache_attr_id>";
		if (sCacheAttrValue1 != null)
			sRequestXML += "<cache_attr_value1><![CDATA["+sCacheAttrValue1+"]]></cache_attr_value1>";
		if (sCacheAttrValue2 != null)
			sRequestXML += "<cache_attr_value2><![CDATA["+sCacheAttrValue2+"]]></cache_attr_value2>";
		if (sCacheAttrOperator != null)
			sRequestXML += "<cache_attr_operator>"+sCacheAttrOperator+"</cache_attr_operator>";
		if (sCacheUserID != null)
			sRequestXML += "<cache_user_id>"+sCacheUserID+"</cache_user_id>";
		if (sCacheFilterID != null)
			sRequestXML += "<cache_filter_id>"+sCacheFilterID+"</cache_filter_id>";
		if(sMax != null) sRequestXML += "<num_recips>"+sMax+"</num_recips>";
		
		sRequestXML += "<attr_list>"+sAttrIDList+"</attr_list>";
		sRequestXML += "</RecipRequest>";	
			
		logger.info(sRequestXML);
		sListXML = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXML);		
%>
<BODY>
<FORM  METHOD="POST" NAME="FT" ACTION="../export/report_export_new.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="Action" VALUE=<%=(sAction == null)?"\"\"":"\""+sAction+"\""%>>
<INPUT TYPE="hidden" NAME="Q" VALUE=<%=(CampId == null)?"\"\"":"\""+CampId+"\""%>>
<INPUT TYPE="hidden" NAME="H" VALUE=<%=(LinkId == null)?"\"\"":"\""+LinkId+"\""%>>
<INPUT TYPE="hidden" NAME="T" VALUE=<%=(ContentType == null)?"\"\"":"\""+ContentType+"\""%>>
<INPUT TYPE="hidden" NAME="F" VALUE=<%=(FormId == null)?"\"\"":"\""+FormId+"\""%>>
<INPUT TYPE="hidden" NAME="B" VALUE=<%=(BBackCatId == null)?"\"\"":"\""+BBackCatId+"\""%>>
<INPUT TYPE="hidden" NAME="S" VALUE=<%=(UnsubLevelId == null)?"\"\"":"\""+UnsubLevelId+"\""%>>
<INPUT TYPE="hidden" NAME="D" VALUE=<%=(Domain == null)?"\"\"":"\""+Domain+"\""%>>
<INPUT TYPE="hidden" NAME="N" VALUE=<%=(NewsletterId == null)?"\"\"":"\""+NewsletterId+"\""%>>
<INPUT TYPE="hidden" NAME="C" VALUE=<%=(CacheID == null)?"\"0\"":"\""+CacheID+"\""%>>
<INPUT TYPE="hidden" NAME="Z" VALUE=<%="\""+Cache+"\""%>>
<%
		Element eRecipList = XmlUtil.getRootElement(sListXML);
		int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
		int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));
%>
<table cellspacing="0" cellpadding="4" border=0 width="100%">
	<tr>
		<td align="left">Records: <%=nTotReturned%>
<%
		if ( nTotReturned < nTotRecips )
		{
%>
			(out of <%=nTotRecips%> total Recipients)
<%
		}

		if(canExp.bWrite)
		{
%>
		</td>
		<td align="right"><a class="resourcebutton" href="#" onClick="trySubmit(1)">Export Full List</a></td>
<%
		}
		
		if (canTG.bWrite)
		{
%>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</TD>
		<td align="right"><a class="resourcebutton" href="#" onClick="trySubmit(2)">Create Target Group</a>
<%
		}
%>
		</td>
	</tr>
</table>
<br>
<%
XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");
%>
<table class="listTable" border="0" cellspacing="0" cellpadding="2" width="100%">
	<tr>
		<th>&nbsp;</th>
	<%
		String tempStr = "";
		int iLen = 0;
		
		tempStr = sAttrDisplayList.trim();
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
		<th><%= tempStr %></th>
<%
		}
%>
		<th>&nbsp;</th>
	</tr>  
<%

Element eRecip = null;
String 	sRecipID = "";
String tempDisplay = "";

int iCount = 0;

String sClassAppend = "_Alt";

for (int j=0; j < xelRecips.getLength() ; j++)
{
	if (iCount % 2 != 0) sClassAppend = "_Alt";
	else sClassAppend = "";
	
	iCount++;
	
	eRecip = (Element)xelRecips.item(j);
	sRecipID = XmlUtil.getChildCDataValue(eRecip,"recip_id");
%>
	<tr>
		<!-- recip_id = <%=sRecipID%>-->
		<td class="listItem_Title<%= sClassAppend %>"><%= (j+1) %>&nbsp;</td>
		<%
		tempStr = "";
		iLen = 0;
		
		tempStr = sAttrNameList.trim();
		sInSplit = tempStr.split(",");
		x = 0;
		
		for (x=0; x < sInSplit.length; x++)
		{
			tempStr = "";
			tempStr = sInSplit[x].trim();
			iLen = tempStr.length();
			
			if ((iLen >= 1) && ("'".equals(tempStr.substring(0,1))))
			{
				tempStr = tempStr.substring(1, iLen - 1);
			}
			
			tempDisplay = XmlUtil.getChildCDataValue(eRecip,tempStr);
			if (tempDisplay == null) tempDisplay = "";
%>
		<td class="listItem_Data<%= sClassAppend %>"><%= tempDisplay %>&nbsp;</td>
<%
		}
%>
		<td class="listItem_Data<%= sClassAppend %>"><a class="resourcebutton" href="recip_camp_history.jsp?recip_id=<%= sRecipID %>&from=report">Edit/View</a>&nbsp;</td>
	</tr>
<%
}
%>
</table>
<br>
<%=(CampType == 3)?"*NOTE: &quot;Friend&quot; recipients are not shown.":""%>
	<%
}
%>
</FORM>
</body>
<SCRIPT>
function trySubmit (i)
{
	if (i == 2) FT.action = 'filter_new.jsp';
	FT.submit();
}
</SCRIPT>
</html>
<%
}
catch (Exception ex)
{
		ErrLog.put(this,ex,"export_new.jsp",out,1);
}
finally
{
	try { if( stmt  != null ) stmt.close(); }
	catch (Exception ex2) { } 
	if( conn  != null ) cp.free(conn); 
}

%>



