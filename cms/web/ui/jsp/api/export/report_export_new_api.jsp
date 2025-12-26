<%@ page
		language="java"
		import="com.britemoon.*,
		com.britemoon.cps.*,
		java.sql.*,java.util.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	Statement	stmt;
	ResultSet	rs;
	ConnectionPool 	connectionPool 	= null;
	Connection 	srvConnection 	= null;
	int		nStep		= 1;
	try {
		connectionPool = ConnectionPool.getInstance();
		srvConnection = connectionPool.getConnection("report_export_new.jsp");
		stmt  = srvConnection.createStatement();
	} catch(Exception ex) {
		connectionPool.free(srvConnection);
		out.println("<BR>Connection error ... !<BR><BR>");
		return;
	}


	String sSql  =
			" SELECT c.category_id, c.category_name" +
					" FROM ccps_category c" +
					" WHERE c.cust_id="+cust.s_cust_id;
	rs = stmt.executeQuery(sSql);

	String sCategoryId = null;
	String sCategoryName = null;


	JsonArray categoryArray = new JsonArray();
	try {
		while (rs.next()) {
			JsonObject categoryObject = new JsonObject();
			sCategoryId = rs.getString(1);
			categoryObject.put("categoryId"  , sCategoryId);
			sCategoryName = rs.getString(2);
			categoryObject.put("categoryName" , fixTurkishCharacters(sCategoryName));
			boolean bSelected = (sSelectedCategoryId != null) && (sSelectedCategoryId.equals(sCategoryId));
			categoryObject.put("selected", bSelected);
			categoryArray.put(categoryObject);
		}
	} catch (Exception e) {
		throw new RuntimeException(e);
	}



	String sAction		= request.getParameter("Action").trim();
	String CampId 		= request.getParameter("Q");
	String LinkId		= request.getParameter("H");
	String ContentType	= request.getParameter("T");
	String FormId		= request.getParameter("F");
	String BBackCatId	= request.getParameter("B");
	String UnsubLevelId	= request.getParameter("S");
	String Domain		= request.getParameter("D");
	String NewsletterId	= request.getParameter("N");
	String Cache		= request.getParameter("Z");
	String CacheID		= request.getParameter("C");
	Cache = ("1".equals(Cache))?Cache:"0";
	CacheID = (CacheID==null||"".equals(CacheID))?"0":CacheID;

	try {

		String ExpDescrip = "Export of ";

		rs = stmt.executeQuery("SELECT camp_name FROM cque_campaign WHERE camp_id = "+CampId+" AND cust_id = "+cust.s_cust_id);
		if (rs.next())
			ExpDescrip += "'"+fixTurkishCharacters(rs.getString(1))+"' Campaign ";
		else
			throw new Exception("Campaign not found.");
		rs.close();

		if (sAction.equals("RptCampSent")) {
			ExpDescrip += "Sent ";
		} else if (sAction.equals("RptCampRcvd")) {
			ExpDescrip += "Reaching ";
		} else if (sAction.equals("RptCampBBack")) {
			ExpDescrip += "Bouncebacks ";
		} else if (sAction.equals("RptCampRead")) {
			ExpDescrip += "Open HTML Email ";
		} else if (sAction.equals("RptCampUnsub")) {
			ExpDescrip += "Unsubscribes ";
		} else if (sAction.equals("RptCampClick")) {
			ExpDescrip += "Clickthroughs ";
		} else if (sAction.equals("RptCampMultiRead")) {
			ExpDescrip += "Open HTML Email more than once ";
		} else if (sAction.equals("RptCampMultiClick")) {
			ExpDescrip += "Clicks on one link multiple times ";
		} else if (sAction.equals("RptCampMultiLink")) {
			ExpDescrip += "Clicks on more than one link ";
		} else if (sAction.equals("RptCampFormView")) {
			ExpDescrip += "Form Views ";
		} else if (sAction.equals("RptCampFormSubmit")) {
			ExpDescrip += "Form Submits ";
		} else if (sAction.equals("RptCampFormMultiSubmit")) {
			ExpDescrip += "Form Multiple Submits ";
		} else if (sAction.equals("RptCampDomainSent")) {
			ExpDescrip += "were Sent the campaign at "+Domain+" ";
		} else if (sAction.equals("RptCampDomainBBack")) {
			ExpDescrip += "Bounced Back from "+Domain+" ";
		} else if (sAction.equals("RptCampOptout")) {
			ExpDescrip += "Opted out of a Newsletter ";
		} else if (sAction.equals("RptCampDomainUnsub")) {
			ExpDescrip += "Unsubscribes from "+Domain+" ";
		} else if (sAction.equals("RptCampDomainSpam")) {
			ExpDescrip += "Unsubscribes spam complaints from "+Domain+" ";
		} else if (sAction.equals("RptCampSpamLevel")) {
			ExpDescrip += "SpamLevel";
		}

		if ((LinkId != null) && (LinkId.length() > 0)){
			rs = stmt.executeQuery("SELECT link_name FROM cjtk_link WHERE link_id = "+LinkId+" AND cust_id = "+cust.s_cust_id);
			if (rs.next())
				ExpDescrip += " of '"+rs.getString(1)+"' Link ";
			else
				throw new Exception("Link not found");
			rs.close();
		}

		if (ContentType != null) {
			if (ContentType.equals("H"))
				ExpDescrip += "in HTML Email ";
			if (ContentType.equals("T"))
				ExpDescrip += "in Text Email ";
			if (ContentType.equals("A"))
				ExpDescrip += "in AOL Email ";
		}

		if ((FormId != null) && (FormId.length() > 0)){
			rs = stmt.executeQuery("SELECT form_name FROM csbs_form WHERE form_id = "+FormId+" AND cust_id = "+cust.s_cust_id);
			if (rs.next())
				ExpDescrip += " of '"+rs.getString(1)+"' Form ";
			else
				throw new Exception("Form not found");
			rs.close();
		}

		if ((BBackCatId != null) && (BBackCatId.length() > 0)){
			rs = stmt.executeQuery("SELECT category_name FROM crpt_bback_category WHERE category_id = "+BBackCatId);
			if (rs.next())
				ExpDescrip += " in '"+rs.getString(1)+"' Category ";
			rs.close();
		}
		if ((UnsubLevelId != null) && (UnsubLevelId.length() > 0)){
			rs = stmt.executeQuery("SELECT level_name FROM crpt_unsub_level WHERE level_id = "+UnsubLevelId);
			if (rs.next())
				ExpDescrip += " in '"+rs.getString(1)+"' Level ";
			rs.close();
		}
		if ((NewsletterId != null) && (NewsletterId.length() > 0)){
			rs = stmt.executeQuery("SELECT display_name FROM ccps_cust_attr WHERE attr_id = "+NewsletterId+" AND cust_id = "+cust.s_cust_id);
			if (rs.next())
				ExpDescrip += "specifically the Newsletter: '"+rs.getString(1)+"'";
			else
				throw new Exception("Newsletter Attribute not found");
			rs.close();
		}
		JsonObject jsonObject = new JsonObject();
		jsonObject.put("exportDescription", ExpDescrip);




		JsonArray attrArray = new JsonArray();
        rs = stmt.executeQuery(
            "SELECT c.attr_id, c.display_name + '(' + t.type_name + ')', a.type_id " +
            "FROM ccps_attribute a, ccps_data_type t, ccps_cust_attr c " +
            "WHERE c.cust_id = "+cust.s_cust_id+" " +
            "AND a.attr_id = c.attr_id " +
            "AND a.type_id = t.type_id " +
            "AND c.display_seq IS NOT NULL " +
            "ORDER BY display_seq");

        while (rs.next())	{
			JsonObject attrObject = new JsonObject();
            String attrId = rs.getString (1);
			String attrName = rs.getString(2);
			String attrType = rs.getString(3);
			attrObject.put("attrId", attrId);
			attrObject.put("attrName", fixTurkishCharacters(attrName));
			attrObject.put("attrType", attrType);
			attrArray.put(attrObject);
        }
        rs.close();

		JsonObject resultObject = new JsonObject();
		resultObject.put("exportDescription", ExpDescrip);
		resultObject.put("categories", categoryArray);
		resultObject.put("attributes", attrArray);

		out.print(resultObject.toString());

	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_new.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (srvConnection != null) connectionPool.free(srvConnection);
	}
%>


<%!

	public  String fixTurkishCharacters(String input) {
		if (input == null) {
			return null;
		}

		String s = input;


		s = s.replace("Ã„Â±", "ı");
		s = s.replace("Ã„Â°", "İ");
		s = s.replace("Ã„ÂŸ", "ğ");
		s = s.replace("Ã„Âž", "Ğ");
		s = s.replace("Ã…ÅŸ", "ş");
		s = s.replace("Ã…Åž", "Ş");
		s = s.replace("ÃƒÂ¼", "ü");
		s = s.replace("ÃƒÂ–", "Ö");
		s = s.replace("ÃƒÂœ", "Ü");
		s = s.replace("ÃƒÂ§", "ç");
		s = s.replace("Ãƒâ€¹", "Ç");
		s = s.replace("ÃƒÂ¶", "ö");

		s = s.replace("Ä±", "ı");
		s = s.replace("Ä°", "İ");
		s = s.replace("ÄŸ", "ğ");
		s = s.replace("Äž", "Ğ");
		s = s.replace("ÅŸ", "ş");
		s = s.replace("Åž", "Ş");
		s = s.replace("Ã¼", "ü");
		s = s.replace("Ã", "Ü");
		s = s.replace("Ã§", "ç");
		s = s.replace("Ã‡", "Ç");
		s = s.replace("Ã¶", "ö");
		s = s.replace("Ã", "Ö");


		// Ç bozulmaları
		s = s.replace("Ã§", "ç");
		s = s.replace("Ã‡", "Ç");
		// Ğ/ğ bozulmaları
		s = s.replace("Ã„ÂŸ", "ğ");
		s = s.replace("Ã„Âž", "Ğ");
		// Ş/ş
		s = s.replace("Ã…ÅŸ", "ş");
		s = s.replace("Ã…Åž", "Ş");
		// Ü/ü
		s = s.replace("ÃƒÂ¼", "ü");
		s = s.replace("ÃƒÂœ", "Ü");
		// Ö/ö
		s = s.replace("ÃƒÂ¶", "ö");
		s = s.replace("ÃƒÂ–", "Ö");
		// ı/İ
		s = s.replace("Ã„Â±", "ı");
		s = s.replace("Ã„Â°", "İ");
		// Bozuk yer tutucu karakter (replacement char)
		s = s.replace("�", "ö")  ; // ! Dikkat: hangi harfe denk geldiğine göre ayarlayın
		// Diğer sık gözüken ikili bozulmalar
		s = s.replace("Â±", "ı");
		s = s.replace("Â§", "Ş");
		s = s.replace("Âş", "ş");

		return s;
	}

%>

