<%!
private static String getContOptionsHtml(Statement stmt, String sCustId, String sSelectedContId, String sSelectedCategoryId, boolean isPrintContent)
	throws Exception
{
	StringWriter sw = new StringWriter();

	String sSql = null;

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
	{
		String sTypeCond = " AND type_id = 20 AND origin_cont_id IS NULL";
		if (isPrintContent) {
			sTypeCond = " AND type_id = 40 AND cti_doc_id IS NOT NULL AND origin_cont_id IS NOT NULL";
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
			sTypeCond = " AND c.type_id = 40 AND c.cti_doc_id IS NOT NULL AND c.origin_cont_id IS NOT NULL";
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
		if(!ContUtil.isContSimple(sContId)) continue;

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
%>

