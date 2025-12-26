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
<%@ include file="../../utilities/validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

AccessPermission can2 = user.getAccessPermission(ObjectType.RECIPIENT);

JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();
//CY 08042013
//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

boolean bCanRead = can.bRead && can2.bRead;

if(!bCanRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canExp = user.getAccessPermission(ObjectType.EXPORT);
AccessPermission canTG = user.getAccessPermission(ObjectType.FILTER);


// Connection
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;

String sRequestXML = "";
String sListXML = "";

String Mode	= request.getParameter("Action").trim();
if (Mode == null){
	Mode = "all";
}
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

if ( (Cache == null) || (Cache.equals("")) ){
	Cache = "0";
} 

String CacheID	= request.getParameter("C");

if ((CacheID == null) || (CacheID.equals(""))){
	CacheID = "0";
} 

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
		JsonObject jsonCamp = new JsonObject();
	    JsonArray jsonCampArray = new JsonArray();
		sSql = 
			" SELECT count(c.camp_id), MAX(c.type_id)" +
			" FROM cque_campaign c" +
			" WHERE c.cust_id = " + cust.s_cust_id +
			" AND c.camp_id = " + CampId;
		rs = stmt.executeQuery(sSql);
				
		while(rs.next())
		{
			jsonCamp = new JsonObject();
			numRecs = rs.getInt(1);
			CampType = rs.getInt(2);
			jsonCamp.put("numRecs", numRecs);
			jsonCamp.put("CampType", CampType);
			jsonCampArray.put(jsonCamp);
		}
		jsonObject.put("CampType", jsonCampArray);
	}

	rs.close();

	if ((CampId == null) || (CampId == "") || (numRecs < 1))
	{
        jsonObject.put("message", "No Campaign for that ID");			
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
		JsonObject jsonCampSummary = new JsonObject();
		JsonArray jsonCampSummaryArray = new JsonArray();
		
		if ("1".equals(Cache)) {
			
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
                jsonCampSummary = new JsonObject();
				jsonCampSummary.put("sCacheStartDate", sCacheStartDate);
				jsonCampSummary.put("sCacheEndDate", sCacheEndDate);
				jsonCampSummary.put("sCacheAttrID", sCacheAttrID);
				jsonCampSummary.put("sCacheAttrValue1", sCacheAttrValue1);
				jsonCampSummary.put("sCacheAttrValue2", sCacheAttrValue2);
				jsonCampSummary.put("sCacheAttrOperator", sCacheAttrOperator);
				jsonCampSummary.put("sCacheUserID", sCacheUserID);
				jsonCampSummary.put("sCacheFilterID", sCacheFilterID);
				jsonCampSummaryArray.put(jsonCampSummary);
			}
			jsonObject.put("CampSummary", jsonCampSummaryArray);
		}
		else if ("2".equals(Cache))
		{
			sCacheUserID = user.s_user_id;
			jsonCampSummary.put("sCacheUserID", sCacheUserID);
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
		JsonObject jsonAttr = new JsonObject();
		JsonArray jsonAttrArray = new JsonArray();
		
		while (rs.next()) {   
			jsonAttr = new JsonObject();
			sAttrIDList += ((sAttrIDList.length()>0)?",":"")+rs.getString(1);
			sAttrNameList += ((sAttrNameList.length()>0)?",":"")+rs.getString(2);
			sAttrDisplayList += ((sAttrDisplayList.length()>0)?",":"")+rs.getString(3);
			jsonAttr.put("attr_id",sAttrIDList);
			jsonAttr.put("attr_name",sAttrNameList);
			jsonAttr.put("display_name",sAttrDisplayList);
			jsonAttrArray.put(jsonAttr);
		}
		jsonObject.put("AttrValues", jsonAttrArray);

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
		Element eRecipList = XmlUtil.getRootElement(sListXML);
		int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
		int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));

		if ( nTotReturned < nTotRecips )
		{
			jsonObject.put("total_recips", nTotRecips);
		}

        if (!bStandardUI) {
		if(canExp.bWrite)
		{

		}
		
		if (canTG.bWrite)
		{

		}
        }
        XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");

		String tempStr = "";
		int iLen = 0;
		JsonObject jsonRecipient = new JsonObject();
		JsonArray  jsonArrRecipient = new JsonArray();
		tempStr = sAttrDisplayList.trim();
		String[] sInSplit = tempStr.split(",");
		int x = 0;
		
		for (x=0; x < sInSplit.length; x++)
		{
			jsonRecipient = new JsonObject();
			tempStr = "";
			tempStr = sInSplit[x].trim();
			iLen = tempStr.length();
			
			if ((iLen >= 1) && ("'".equals(tempStr.substring(0,1))))
			{
				tempStr = tempStr.substring(1, iLen - 1);
			}

        jsonRecipient.put("tempStr", tempStr);
		jsonArrRecipient.put(jsonRecipient);
		}
        jsonObject.put("jsonArrRecipient", jsonArrRecipient);

		Element eRecip = null;
		String 	sRecipID = "";
		String tempDisplay = "";
		JsonObject jsonClass = new JsonObject();
		JsonArray  jsonArrClass = new JsonArray();
		JsonObject jsonTemp = new JsonObject();
		JsonArray  jsonArrTemp = new JsonArray();
		int iCount = 0;

		String sClassAppend = "_other";

	 for (int j=0; j < xelRecips.getLength() ; j++) {
	  if (iCount % 2 != 0) sClassAppend = "_other";
	  else sClassAppend = "";
	
	  iCount++;
	
	   eRecip = (Element)xelRecips.item(j);
	   sRecipID = XmlUtil.getChildCDataValue(eRecip,"recip_id");


		jsonClass = new JsonObject();
		jsonClass.put("sRecipID", sRecipID);
		jsonClass.put("sClassAppend", sClassAppend);

		tempStr = "";
		iLen = 0;
		
		tempStr = sAttrNameList.trim();
		sInSplit = tempStr.split(",");
		x = 0;
		
		for (x=0; x < sInSplit.length; x++)
		{   
			jsonTemp = new JsonObject();
			tempStr = "";
			tempStr = sInSplit[x].trim();
			iLen = tempStr.length();
			
			if ((iLen >= 1) && ("'".equals(tempStr.substring(0,1))))
			{
				tempStr = tempStr.substring(1, iLen - 1);
			}
			
			tempDisplay = XmlUtil.getChildCDataValue(eRecip,tempStr);
			if (tempDisplay == null) tempDisplay = "";
           // jsonTemp.put("tempDisplay", tempDisplay);
		   //jsonArrTemp.put(jsonTemp);
		}
		//System.out.print(tempDisplay);
        jsonClass.put("tempDisplay", tempDisplay);
		//jsonClass.put("jsonArrTemp", jsonArrTemp);

		jsonArrClass.put(jsonClass);
        if (!bStandardUI) {		
		}
	  jsonObject.put("jsonArrClass", jsonArrClass);
      jsonObject.put("CamptypeMsg",(CampType == 3)?"*NOTE: &quot;Friend&quot; recipients are not shown.":"");
	 
    }
}
      jsonArray.put(jsonObject);
	  out.print(jsonArray);
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



