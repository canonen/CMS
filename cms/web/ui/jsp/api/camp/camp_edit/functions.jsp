<%!
private static String buildCategoriesHtml(Statement stmt, String CUST_ID, String CAMP_ID, String sSelectedCategoryId)
	throws Exception
{	
	String htmlCategories = "";
	String sSql =
		" SELECT c.category_id, c.category_name, oc.object_id" +
		" FROM ccps_category c" +
			" LEFT OUTER JOIN ccps_object_category oc" +
			" ON (c.category_id = oc.category_id" +
				" AND c.cust_id = oc.cust_id" +
				" AND oc.object_id="+CAMP_ID+
				" AND oc.type_id="+ObjectType.CAMPAIGN+")" +
		" WHERE c.cust_id="+CUST_ID;
		
	ResultSet rs = stmt.executeQuery(sSql);

	String sCategoryId = null;
	String sCategoryName = null;
	String sObjectId = null;
	boolean isSelected = false;
			
	while (rs.next())
	{
		sCategoryId = rs.getString(1);
		sCategoryName = new String(rs.getBytes(2), "UTF-8");
		sObjectId = rs.getString(3);

		isSelected =
			(sObjectId!=null)||((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)));
		
		htmlCategories +=
			"<OPTION value=\""+sCategoryId+"\""+((isSelected)?" selected":"")+">" +
				HtmlUtil.escape(sCategoryName) +
			"</OPTION>";
	}
	rs.close();
	
	return htmlCategories;
}

private static String getContOptionsHtml(Statement stmt, String sCustId, String sSelectedContId, String sSelectedCategoryId, boolean isPrintContent)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = null;

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
	{
		String sTypeCond = " AND type_id = 20 AND origin_cont_id IS NULL";
		if (isPrintContent) {
			sTypeCond = " AND type_id = 40 AND origin_cont_id IS NULL AND cti_doc_id IS NOT NULL";
		}
		sSql = 
			" SELECT cont_id, cont_name" +
			" FROM ccnt_content" +
			" WHERE cust_id = " + sCustId  +
			" AND status_id = 20" +
			sTypeCond +
			((sSelectedContId!=null)?" OR cont_id = " + sSelectedContId:"") +
			" ORDER BY cont_id DESC";	
	}
	else {
		String sTypeCond = " AND c.type_id = 20 AND c.origin_cont_id IS NULL";
		if (isPrintContent) {
			sTypeCond = " AND c.type_id = 40 AND c.origin_cont_id IS NULL AND c.cti_doc_id IS NOT NULL";
		}
		sSql = 	
			" SELECT DISTINCT c.cont_id, c.cont_name" +
			" FROM ccnt_content c, ccps_object_category oc" +
			" WHERE (c.cust_id = " + sCustId +
			" AND c.status_id = 20" +
			sTypeCond +
			" AND c.cont_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CONTENT +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sSelectedCategoryId + ")" +
			((sSelectedContId!=null)?" OR c.cont_id = " + sSelectedContId:"") +
			" ORDER BY c.cont_id DESC";
	}

	String sContId = null;

	ResultSet rs = stmt.executeQuery(sSql);
	while(rs.next())
	{ 
		sContId = rs.getString(1);
		sw.write("<option value=" + sContId + ((sContId.equals(sSelectedContId))?" selected":"") + ">");
		sw.write(HtmlUtil.escape(new String(rs.getBytes(2),"UTF-8")));
		sw.write("</option>\r\n");
	}
	rs.close();
	
	return sw.toString();
}

private static String getFromAddressOptionsHtml(Statement stmt, String sCustId, String sSelectedFromAddressId)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = 
		" SELECT from_address_id, prefix+'@'+[domain]" +
		" FROM ccps_from_address" +
		" WHERE cust_id = " + sCustId +
		" ORDER BY from_address_id DESC";

	String sFromAddressId = null;
	ResultSet rs = stmt.executeQuery(sSql);
	while( rs.next() )
	{
		sFromAddressId = rs.getString(1);
		sw.write("<option value=" + sFromAddressId + ((sFromAddressId.equals(sSelectedFromAddressId))?" selected":"") + ">");
		sw.write(HtmlUtil.escape(rs.getString(2)));
		sw.write("</option>");
	}
	rs.close();
	return sw.toString();
}

private static String getFilterOptionsHtml(Statement stmt, String sCustId, String sSelectedFilterId, String sSelectedCategoryId)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = null;

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
	{
		sSql =
			" SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
			" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
			" FROM ctgt_filter" +
			" WHERE cust_id = " + sCustId +
			" AND origin_filter_id IS NULL" +
			" AND filter_name IS NOT NULL" +
			" AND type_id=" + FilterType.MULTIPART +
			" AND usage_type_id=" + FilterUsageType.REGULAR +
			" AND status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
               " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
			((sSelectedFilterId!=null)?" OR filter_id = " + sSelectedFilterId:"") +
			" ORDER BY 1 DESC";
	}
	else
	{
		sSql =
			" SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
			" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
			" FROM ctgt_filter f, ccps_object_category oc" +
			" WHERE (f.cust_id = " + sCustId +
			" AND f.origin_filter_id IS NULL" +
			" AND f.filter_name IS NOT NULL" +
			" AND f.type_id=" + FilterType.MULTIPART +
			" AND f.filter_id = oc.object_id" +
			" AND f.usage_type_id=" + FilterUsageType.REGULAR +
			" AND f.status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
               " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sSelectedCategoryId + ")" +
			((sSelectedFilterId!=null)?" OR f.filter_id = " + sSelectedFilterId:"") +
			" ORDER BY 1 DESC";	
	}

	String sFilterId = "";
	String sFilterName = "";
	String sDeleted = "0";
	ResultSet rs = stmt.executeQuery(sSql);		
	while( rs.next() )
	{
		sFilterId = rs.getString(1);
		sFilterName = new String(rs.getBytes(2),"UTF-8");
		sDeleted = rs.getString(3);
		sw.write("<OPTION value=\"" + ((sDeleted.equals("1"))?"":sFilterId) + "\"" + ((sFilterId.equals(sSelectedFilterId))?" selected":"") + ">");
		sw.write(HtmlUtil.escape(sFilterName));
		sw.write("</OPTION>\r\n");
	}
	rs.close();
	return sw.toString();
}


private static String getLogicBlockOptionsHtml(Statement stmt, String sCustId, String sSelectedFilterId, String sSelectedCategoryId)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = null;

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
	{
		sSql =
			" SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
			" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
			" FROM ctgt_filter" +
			" WHERE cust_id = " + sCustId +
			" AND origin_filter_id IS NULL" +
			" AND filter_name IS NOT NULL" +
			" AND type_id=" + FilterType.MULTIPART +
			" AND usage_type_id=" + FilterUsageType.CONTENT +
			" AND status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
               " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
			((sSelectedFilterId!=null)?" OR filter_id = " + sSelectedFilterId:"") +
			" ORDER BY 1 DESC";
	}
	else
	{
		sSql =
			" SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
			" CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
			" FROM ctgt_filter f, ccps_object_category oc" +
			" WHERE (f.cust_id = " + sCustId +
			" AND f.origin_filter_id IS NULL" +
			" AND f.filter_name IS NOT NULL" +
			" AND f.type_id=" + FilterType.MULTIPART +
			" AND f.filter_id = oc.object_id" +
			" AND f.usage_type_id=" + FilterUsageType.CONTENT +
			" AND f.status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
               " AND ISNULL(aprvl_status_flag,1) <> 0" + // Don't display Filters that are unapproved
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sSelectedCategoryId + ")" +
			((sSelectedFilterId!=null)?" OR f.filter_id = " + sSelectedFilterId:"") +
			" ORDER BY 1 DESC";	
	}

	String sFilterId = "";
	String sFilterName = "";
	String sDeleted = "0";
	ResultSet rs = stmt.executeQuery(sSql);		
	while( rs.next() )
	{
		sFilterId = rs.getString(1);
		sFilterName = new String(rs.getBytes(2),"UTF-8");
		sDeleted = rs.getString(3);
		sw.write("<OPTION value=\"" + ((sDeleted.equals("1"))?"":sFilterId) + "\"" + ((sFilterId.equals(sSelectedFilterId))?" selected":"") + ">");
		sw.write(HtmlUtil.escape(sFilterName));
		sw.write("</OPTION>\r\n");
	}
	rs.close();
	return sw.toString();
}

private static int getTestListCount(Statement stmt, String sCustId, String sInTypes)
	throws Exception
{
	int count = 0;
	String sSql = 
		"SELECT count(*) " +
		"  FROM cque_email_list l, cque_list_type t " +
		" WHERE l.type_id = t.type_id AND l.type_id in (" + sInTypes + ") " +
		"   AND l.cust_id = '" + sCustId + "'"  + 
		"   AND l.list_name not like 'ApprovalRequest(%)' " +
		"   AND l.status_id = '" + EmailListStatus.ACTIVE + "'";
	ResultSet rs = stmt.executeQuery(sSql);
	rs.next();
	count = rs.getInt(1);
	rs.close();
	return count;
}

private static String getTestListOptionsHtml(Statement stmt, String sCustId, String sSelectedListId, String sInTypes)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = 
		"SELECT l.list_id, CASE l.status_id WHEN " + EmailListStatus.DELETED + " THEN '*Deleted* ' + l.list_name ELSE l.list_name END, " + 
		" t.type_name, l.status_id" +
		"  FROM cque_email_list l, cque_list_type t " +
		" WHERE l.type_id = t.type_id AND l.type_id in (" + sInTypes + ") " +
		"   AND l.cust_id = '" + sCustId + "'"  + 
		"   AND l.list_name not like 'ApprovalRequest(%)' " +
		"   AND l.status_id = '" + EmailListStatus.ACTIVE + "'" +
		" ORDER BY l.list_id DESC";	

	String sTestListId = null;
	String sTestListName = null;
	String sTypeName = null;
	String sStatusID = null;
	int iStatusID = 0;
	
	ResultSet rs = stmt.executeQuery(sSql);
	while( rs.next() )
	{
		sTestListId = rs.getString(1);
		sTestListName = new String(rs.getBytes(2),"UTF-8");
		sTypeName = new String(rs.getBytes(3),"UTF-8");
		sStatusID = rs.getString(4);
		
		iStatusID = Integer.parseInt(sStatusID);
		
		sw.write("<option");
		if (sTestListId.equals(sSelectedListId))
		{
			sw.write(" selected");
		}
		sw.write(" value=" + ((iStatusID == EmailListStatus.DELETED)?"":sTestListId));
		sw.write(">");
		sw.write(HtmlUtil.escape(sTestListName));
		sw.write(" ( " + HtmlUtil.escape(sTypeName) + " ) " );
		sw.write("</option>\r\n");

	}
	rs.close();
	return sw.toString();
}

private static String getExclusionListOptionsHtml(Statement stmt, String sCustId, String sSelectedListId)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = 
		" SELECT list_id, CASE status_id WHEN " + EmailListStatus.DELETED + " THEN '*Deleted* ' + list_name ELSE list_name END, status_id" +
		" FROM cque_email_list " +
		" WHERE type_id = 3 AND cust_id =" + sCustId +
		" AND (status_id = '" + EmailListStatus.ACTIVE + "'" +
		((sSelectedListId!=null)?" OR list_id = " + sSelectedListId:"") +
		") ORDER BY list_id DESC";

	String sExclusionListId = null;
	String sExclusionListName = null;
	String sStatusID = null;
	int iStatusID = 0;
	
	ResultSet rs = stmt.executeQuery(sSql);
	while( rs.next() )
	{
		sExclusionListId = rs.getString(1);
		sExclusionListName = new String(rs.getBytes(2),"UTF-8");
		sStatusID = rs.getString(3);
		
		iStatusID = Integer.parseInt(sStatusID);

		sw.write("<option");
		if (sExclusionListId.equals(sSelectedListId))
		{
			sw.write(" selected");
		}
		sw.write(" value=" + ((iStatusID == EmailListStatus.DELETED)?"":sExclusionListId));
		sw.write(">");
		sw.write(HtmlUtil.escape(sExclusionListName));
		sw.write("</option>\r\n");

	}
	rs.close();
	return sw.toString();
}

private static String getLinkedCampOptionsHtml
	(Statement stmt, String sCustId, String sSelectedCampId, String sSelectedCategoryId, String sLinkedcampTypes)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = null;				
	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
	{
		sSql =		
			" SELECT DISTINCT origin_camp_id, camp_name" +
			" FROM cque_campaign" +
			" WHERE type_id in (" + sLinkedcampTypes + ")" +
			" AND cust_id = " + sCustId +
			" AND status_id > 0 " +
			" AND ( origin_camp_id IS NOT NULL" +
			((sSelectedCampId!=null)?" OR origin_camp_id = "+sSelectedCampId:"") + 
			" ) ORDER BY origin_camp_id DESC";
	}
	else
	{
		sSql =
			" SELECT DISTINCT c.origin_camp_id, c.camp_name" +
			" FROM cque_campaign c, ccps_object_category oc" +
			" WHERE c.type_id in ("+ sLinkedcampTypes +")" +
			" AND c.cust_id = " + sCustId +
			" AND c.status_id > 0 " +
			" AND ( origin_camp_id IS NOT NULL" +
			" AND ((c.origin_camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sSelectedCategoryId + ")" +
			((sSelectedCampId!=null)?" OR c.origin_camp_id = "+sSelectedCampId:"") + ")" +
			" ) ORDER BY c.origin_camp_id DESC";
	}
	String sLinkedCampId = null;
	ResultSet rs = stmt.executeQuery(sSql);
	while( rs.next() )
	{ 
		sLinkedCampId = rs.getString(1);

		sw.write("<option value=" + sLinkedCampId + ((sLinkedCampId.equals(sSelectedCampId))?" selected":"") + ">");
		sw.write(HtmlUtil.escape(new String(rs.getBytes(2),"UTF-8")));
		sw.write("</option>\r\n");
	}
	rs.close();
	return sw.toString();
}
%>

