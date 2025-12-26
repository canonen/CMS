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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
  if (logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
  }

  AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
  AccessPermission can2 = user.getAccessPermission(ObjectType.RECIPIENT);
  JsonObject jsonObject = new JsonObject();
  JsonArray jsonArray = new JsonArray();
  JsonArray arr = new JsonArray();
  JsonArray recipientArray = new JsonArray();
  boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);
  boolean bCanRead = can.bRead && can2.bRead;

  if (!bCanRead) {
    jsonObject.put("error", "Access denied");
    out.print(jsonObject);
    return;
  }

  AccessPermission canExp = user.getAccessPermission(ObjectType.EXPORT);
  AccessPermission canTG = user.getAccessPermission(ObjectType.FILTER);

  Statement stmt = null;
  ResultSet rs = null;
  ConnectionPool cp = null;
  Connection conn = null;
  String sRequestXML = "";
  String sListXML = "";
  String Mode = request.getParameter("Action");
  if (Mode == null) Mode = "all";

  String CampId = request.getParameter("Q");
  String LinkId = request.getParameter("H");
  String ContentType = request.getParameter("T");
  String FormId = request.getParameter("F");
  String sMax = request.getParameter("Max");
  if (sMax == null) sMax = ui.s_recip_view_count;

  String BBackCatId = request.getParameter("B");
  String Domain = request.getParameter("D");
  String NewsletterId = request.getParameter("N");
  String UnsubLevelId = request.getParameter("S");

  String Cache = request.getParameter("Z");
  if (Cache == null || Cache.equals("")) Cache = "0";

  String CacheID = request.getParameter("C");
  if (CacheID == null || CacheID.equals("")) CacheID = "0";

  String sAction = null;

  int CampType = 0;
  int numRecs = 0;

  try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection("report_detail.jsp");
    stmt = conn.createStatement();

    String sSql = null;

    if (CampId != null && !CampId.equals("")) {
      sSql = " SELECT count(c.camp_id), MAX(c.type_id)" +
              " FROM cque_campaign c" +
              " WHERE c.cust_id = " + cust.s_cust_id +
              " AND c.camp_id = " + CampId;
      rs = stmt.executeQuery(sSql);

      if (rs.next()) {
        numRecs = rs.getInt(1);
        CampType = rs.getInt(2);
      }
    }
    jsonObject.put("numRecs", numRecs);
    jsonObject.put("CampType", CampType);
    rs.close();

    if (CampId == null || CampId.equals("") || numRecs < 1) {
      jsonObject.put("message", "No Campaign for that ID");
    } else {
      String sCacheStartDate = null;
      String sCacheEndDate = null;
      String sCacheAttrID = null;
      String sCacheAttrValue1 = null;
      String sCacheAttrValue2 = null;
      String sCacheAttrOperator = null;
      String sCacheUserID = "0";
      String sCacheFilterID = null;

      if ("1".equals(Cache)) {
        sSql = " SELECT cache_start_date, cache_end_date, attr_id," +
                " attr_value1, attr_value2, attr_operator, user_id, filter_id" +
                " FROM crpt_camp_summary_cache" +
                " WHERE camp_id = " + CampId +
                " AND cache_id = " + CacheID;

        rs = stmt.executeQuery(sSql);

        if (rs.next()) {
          sCacheStartDate = rs.getString(1);
          sCacheEndDate = rs.getString(2);
          sCacheAttrID = rs.getString(3);

          byte[] bval = rs.getBytes(4);
          sCacheAttrValue1 = (bval != null ? (new String(bval, "UTF-8")).trim() : null);

          bval = rs.getBytes(5);
          sCacheAttrValue2 = (bval != null ? (new String(bval, "UTF-8")).trim() : null);

          sCacheAttrOperator = rs.getString(6);
          sCacheUserID = rs.getString(7);

          if (sCacheUserID == null || sCacheUserID.equals(""))
            sCacheUserID = "0";
          sCacheFilterID = rs.getString(8);
        }
      } else if ("2".equals(Cache)) {
        sCacheUserID = user.s_user_id;
      }

      String sFields = " recip_id, email_821, pnmgiven, pnmfamily";
      sSql = " SELECT ca.attr_id, a.attr_name, ca.display_name" +
              " FROM ccps_attribute a, ccps_cust_attr ca" +
              " WHERE" +
              " ca.cust_id=" + cust.s_cust_id + " AND" +
              " a.attr_id = ca.attr_id AND" +
              " ((ISNULL(ca.recip_view_seq, 0) > 0 AND" +
              " ISNULL(a.internal_flag,0) <= 0) OR a.attr_name IN ('recip_id'))" +
              " ORDER BY ca.recip_view_seq, ca.display_name";

      rs = stmt.executeQuery(sSql);

      String sAttrIDList = "";
      String sAttrDisplayList = "";
      String sAttrNameList = "";
      JsonArray attr_arr = new JsonArray();
      while (rs.next()) {
        JsonObject attr = new JsonObject();
        sAttrIDList += ((sAttrIDList.length() > 0) ? "," : "") + rs.getString(1);
        sAttrNameList += ((sAttrNameList.length() > 0) ? "," : "") + rs.getString(2);
        sAttrDisplayList += ((sAttrDisplayList.length() > 0) ? "," : "") + rs.getString(3);
        attr.put("attr_id", rs.getString(1));
        attr.put("attr_name", rs.getString(2));
        attr.put("display_name", rs.getString(3));


        attr_arr.put(attr);
      }
      jsonObject.put("sAttrDisplayList", attr_arr);

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

      JsonObject requestJson = new JsonObject();
      sRequestXML += "<RecipRequest>";
      sRequestXML += "<action>"+sAction+"</action>";
      sRequestXML += "<cust_id>"+cust.s_cust_id+"</cust_id>";
      sRequestXML += "<camp_id>"+CampId+"</camp_id>";

      requestJson.put("action", sAction);
      requestJson.put("cust_id", cust.s_cust_id);
      requestJson.put("camp_id", CampId);
      if (LinkId != null && !LinkId.equals(""))
        sRequestXML += "<link_id>"+LinkId+"</link_id>";

      if (ContentType != null && !ContentType.equals(""))
        sRequestXML += "<content_type>"+ContentType+"</content_type>";

      if (FormId != null && !FormId.equals(""))
        sRequestXML += "<form_id>"+FormId+"</form_id>";

      if (Domain != null && !Domain.equals(""))
      {
        sRequestXML += "<domain><![CDATA["+Domain+"]]></domain>";

      }
      if (NewsletterId != null && !NewsletterId.equals("")) {
        sRequestXML += "<newsletter_id>"+NewsletterId+"</newsletter_id>";

      }
      if (BBackCatId != null && !BBackCatId.equals("")) {
        sRequestXML += "<bback_category>"+BBackCatId+"</bback_category>";

      }
      if (UnsubLevelId != null && !UnsubLevelId.equals("")) {
        sRequestXML += "<unsub_level>"+UnsubLevelId+"</unsub_level>";

      }
      if (CacheID != null) {
        sRequestXML += "<cache_id>"+CacheID+"</cache_id>";

      }
      if (sCacheStartDate != null) {
        sRequestXML += "<cache_start_date><![CDATA["+sCacheStartDate+"]]></cache_start_date>";

      }
      if (sCacheEndDate != null) {
        sRequestXML += "<cache_end_date><![CDATA["+sCacheEndDate+"]]></cache_end_date>";

      }
      if (sCacheAttrID != null) {
        sRequestXML += "<cache_attr_id>"+sCacheAttrID+"</cache_attr_id>";

      }
      if (sCacheAttrValue1 != null) {
        sRequestXML += "<cache_attr_value1><![CDATA["+sCacheAttrValue1+"]]></cache_attr_value1>";

      }
      if (sCacheAttrValue2 != null) {
        sRequestXML += "<cache_attr_value2><![CDATA["+sCacheAttrValue2+"]]></cache_attr_value2>";

      }
      if (sCacheAttrOperator != null) {
        sRequestXML += "<cache_attr_operator>"+sCacheAttrOperator+"</cache_attr_operator>";

      }
      if (sCacheUserID != null) {
        sRequestXML += "<cache_user_id>"+sCacheUserID+"</cache_user_id>";

      }
      if (sCacheFilterID != null) {
        sRequestXML += "<cache_filter_id>"+sCacheFilterID+"</cache_filter_id>";

      }
      if (sMax != null) {
        sRequestXML += "<num_recips>"+sMax+"</num_recips>";

      }


      sRequestXML += "<attr_list>"+sAttrIDList+"</attr_list>";
      sRequestXML += "</RecipRequest>";
      logger.info(sRequestXML);

      sListXML = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXML);

      Element eRecipList = XmlUtil.getRootElement(sListXML);
      int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
      int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));

      jsonObject.put("total_records", nTotReturned);
      if (nTotReturned < nTotRecips) {
        jsonObject.put("total_recips", nTotRecips);
      }

      XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");


      for (int j = 0; j < xelRecips.getLength(); j++) {
        Element eRecip = (Element) xelRecips.item(j);

        recipientArray = new JsonArray();


        String sRecipID = XmlUtil.getChildCDataValue(eRecip, "recip_id");
        JsonObject recipientIdJson = new JsonObject();
        recipientIdJson.put("displayName", "recip_id");
        recipientIdJson.put("value", sRecipID != null ? sRecipID : "");
        recipientArray.put(recipientIdJson);


        String tempStr = sAttrNameList.trim();
        String[] sInSplit = tempStr.split(",");

        for (String attrName : sInSplit) {
          attrName = attrName.trim();
          if (attrName.startsWith("'") && attrName.endsWith("'")) {
            attrName = attrName.substring(1, attrName.length() - 1);
          }


          if (attrName.equals("recip_id")) {
            continue;
          }

          String tempDisplay = XmlUtil.getChildCDataValue(eRecip, attrName);
          JsonObject attrJson = new JsonObject();
          attrJson.put("displayName", attrName);
          attrJson.put("value", tempDisplay != null ? tempDisplay : "");

          recipientArray.put(attrJson);
        }


        jsonArray.put(recipientArray);
      }
      JsonObject finalObject = new JsonObject();
      finalObject.put("recipients", jsonArray);
      finalObject.put("camp_type", (CampType == 3) ? "*NOTE: 'Friend' recipients are not shown." : "");
      arr.put(finalObject);
      arr.put(jsonObject);
      out.print(arr.toString());
    }
  } catch (Exception ex) {
    jsonObject.put("error", "An error occurred: " + ex.getMessage());
    out.print(jsonObject.toString());
    logger.error("Error in report_detail.jsp", ex);
  } finally {
    try {
      if (stmt != null) stmt.close();
    } catch (Exception ex2) {
      logger.error("Error closing Statement", ex2);
    }
    if (conn != null) cp.free(conn);
  }
%>
