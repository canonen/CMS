<%!

private static String getPV_ClientId(String cust_id, Statement stmt) throws Exception
{
	String pv_clientid = null;
	String sqlQuery = "select pv_cust_id from ccps_cust_pv_info " +  
					   "where cust_id = '" + cust_id + "'";
					   
	ResultSet rs = stmt.executeQuery(sqlQuery); 
	while (rs.next())
	{
		pv_clientid = rs.getString(1);
	}
	return pv_clientid;
}

private static String getSeedListOptionsHtml(Statement stmt, String sCustId, String sCampId) throws Exception
{
	StringWriter sw = new StringWriter();
	String listId = null;
	
	String sSql = "SELECT  l.list_id, l.list_name, ccl.camp_id, cc.origin_camp_id " +
		 "FROM cque_email_list l, cque_list_type t, cque_camp_list ccl, " +
		 "cque_campaign cc " + 
		 "WHERE l.cust_id = '" + sCustId +"' " +
		 "AND l.type_id = t.type_id AND l.type_id in (10,11,12,13,14) " +
		 "AND l.list_id = ccl.test_list_id " + 
		 "AND ccl.camp_id = cc.camp_id " +
		 "AND ccl.camp_id <> '" + sCampId +"' "+
		 "AND cc.origin_camp_id = (select origin_camp_id from cque_campaign where camp_id = '" + sCampId +"') " +
		 "AND cc.mode_id = 40";	


		ResultSet rs = stmt.executeQuery(sSql);
		while(rs.next())
		{
			listId = rs.getString(1);
			sw.write("<option value=" + listId + ">");
			sw.write(HtmlUtil.escape(new String(rs.getBytes(2),"UTF-8")));
			sw.write("</option>\r\n");
		}
		rs.close();
	
	return sw.toString();
}

private static int getSeedListCount(Statement stmt, String sCustId, String sCampId) throws Exception
{
	int nCount = 0;
	
	String sSql = "SELECT  count(*) " +
				  "FROM cque_email_list l, cque_list_type t, cque_camp_list ccl, " +
	  			  "cque_campaign cc " + 
				  "WHERE l.cust_id = '" + sCustId +"' " +
				  "AND l.type_id = t.type_id AND l.type_id in (10,11,12,13,14) " +
				  "AND l.list_id = ccl.test_list_id " + 
		 		  "AND ccl.camp_id = cc.camp_id " +
				  "AND ccl.camp_id <> '" + sCampId +"' "+
		 		  "AND cc.origin_camp_id = (select origin_camp_id from cque_campaign where camp_id = '" + sCampId +"') " +
				  "AND cc.mode_id = 40";	

	ResultSet rs = stmt.executeQuery(sSql);
	if (rs.next())nCount = rs.getInt(1);
	rs.close();

	return nCount;
}

private static String getPVId(Statement stmt, String sCustId, String sCampId,String sListId) throws Exception
{
		String xpviqID = null;
		String sSql = 
		" SELECT camp.camp_id AS test_id, pv.pv_iq AS pviq_id, campList.test_list_id " + 
		" FROM   cque_camp_list campList, cque_campaign AS camp INNER JOIN cque_camp_pv_hist AS pv ON camp.camp_id = pv.camp_id " +
		" WHERE 	camp.origin_camp_id = (select origin_camp_id from cque_campaign where camp_id = '" + sCampId + "') " +
		" AND campList.test_list_id= '" + sListId + "' "  + 
		" AND pv.origin_camp_id = camp.origin_camp_id " + 
		" AND pv.pv_test_type_id = '1' " + 
		" AND campList.camp_id = camp.camp_id AND camp.mode_id = '40'";	
	
		ResultSet rs = stmt.executeQuery(sSql);
		while(rs.next())
		{
			xpviqID = rs.getString(2);
		}
		rs.close();
		return xpviqID;
}

private static boolean checkPVRecord(Statement stmt, String sCampId,String sTestId) throws Exception
{
		boolean ifRecordExist = false;
		String sSql ="select count(*) cnt from crpt_camp_pv_summary " + 
		" where camp_id = '" + sCampId + "' and test_id = '" + sTestId + "' ";
		ResultSet rs = stmt.executeQuery(sSql);
		while(rs.next())
		{
			if(rs.getInt(1) > 0) 
			{
				ifRecordExist = true;
			}
		}
		rs.close();
		return ifRecordExist;
}
%>