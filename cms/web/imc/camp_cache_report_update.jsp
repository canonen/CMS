<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.imc.*"
	import="java.io.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="header.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

Element e = XmlUtil.getRootElement(request);

if(e == null) throw new Exception("Malformed Campaign Report xml.");

String sCampID = XmlUtil.getChildTextValue(e, "camp_id");
String sCustID = XmlUtil.getChildTextValue(e, "cust_id");
String sCacheID = XmlUtil.getChildTextValue(e, "cache_id");
String sTempCacheID = XmlUtil.getChildTextValue(e, "temp_cache_id");

if ((sCampID == null) || (sCustID == null)) throw new Exception("Campaign not specified.");

System.out.println("Received camp cache report update for camp_id = " + sCampID + ", cache_id = " + sCacheID + ", temp_cache_id = " + sTempCacheID);
// === === ===

// Connection
Statement		stmt	= null;
PreparedStatement pstmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;
String 			sSQL 	= null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("camp_cache_report_update.jsp");
	conn.setAutoCommit(false);

	try
	{ 	
		stmt = conn.createStatement();
		String sDeleteCacheID = sCacheID;
		if (sTempCacheID != null && sTempCacheID.startsWith("-")) {
			sDeleteCacheID = sTempCacheID;
		}
		System.out.println("deleting cache id  = " + sDeleteCacheID);

		stmt.executeUpdate("DELETE crpt_camp_pos_connect_cache WHERE cache_id = " + sDeleteCacheID + " AND camp_id = "+sCampID);
		stmt.executeUpdate("DELETE crpt_camp_pos_cache WHERE cache_id = " + sDeleteCacheID + " AND camp_id = "+sCampID);
		stmt.executeUpdate("DELETE crpt_camp_form_cache WHERE cache_id = " + sDeleteCacheID + " AND camp_id = "+sCampID);
		stmt.executeUpdate("DELETE crpt_camp_bback_cache WHERE cache_id = " + sDeleteCacheID + " AND camp_id = "+sCampID);
		stmt.executeUpdate("DELETE crpt_camp_domain_cache WHERE cache_id = " + sDeleteCacheID + " AND camp_id = "+sCampID);
		stmt.executeUpdate("DELETE crpt_camp_link_cache WHERE cache_id = " + sDeleteCacheID + " AND camp_id = "+sCampID);
		stmt.executeUpdate("DELETE crpt_camp_summary_cache WHERE cache_id = " + sDeleteCacheID + " AND camp_id = "+sCampID);
	}
	catch (Exception ex) { throw ex; }
	finally { if( stmt != null ) stmt.close(); }

	sSQL = "INSERT crpt_camp_summary_cache"
		+ " (camp_id,"
		+ " cust_id,"
		+ " camp_name,"
		+ " start_date,"
		+ " sent,"
		+ " bbacks,"
		+ " reaching,"
		+ " dist_reads,"
		+ " tot_reads,"
		+ " dist_clicks,"
		+ " unsubs,"
		+ " tot_clicks,"
		+ " tot_text_clicks,"
		+ " tot_html_clicks,"
		+ " tot_aol_clicks,"
		+ " tot_links,"
		+ " dist_text_clicks,"
		+ " dist_html_clicks,"
		+ " dist_aol_clicks,"
		+ " multi_readers,"
		+ " link_multi_clickers,"
		+ " multi_link_clickers,"
		+ " last_update_date,"
		+ " cache_id,"
		+ " cache_start_date,"
		+ " cache_end_date,"
		+ " attr_id,"
		+ " attr_value1,"
		+ " attr_value2,"
		+ " attr_operator,"
		+ " user_id,"
		+ " filter_id)"
		+ " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";


	try
	{ 	
		pstmt = conn.prepareStatement(sSQL);

		pstmt.setString(1,sCampID);
		pstmt.setString(2,sCustID);
		pstmt.setString(3,XmlUtil.getChildCDataValue(e, "camp_name"));
		pstmt.setString(4,XmlUtil.getChildCDataValue(e, "start_date"));
		pstmt.setString(5,XmlUtil.getChildTextValue(e, "sent"));
		pstmt.setString(6,XmlUtil.getChildTextValue(e, "bbacks"));
		pstmt.setString(7,XmlUtil.getChildTextValue(e, "reaching"));
		pstmt.setString(8,XmlUtil.getChildTextValue(e, "dist_reads"));
		pstmt.setString(9,XmlUtil.getChildTextValue(e, "tot_reads"));
		pstmt.setString(10,XmlUtil.getChildTextValue(e, "dist_clicks"));
		pstmt.setString(11,XmlUtil.getChildTextValue(e, "unsubs"));
		pstmt.setString(12,XmlUtil.getChildTextValue(e, "tot_clicks"));
		pstmt.setString(13,XmlUtil.getChildTextValue(e, "tot_text_clicks"));
		pstmt.setString(14,XmlUtil.getChildTextValue(e, "tot_html_clicks"));
		pstmt.setString(15,XmlUtil.getChildTextValue(e, "tot_aol_clicks"));
		pstmt.setString(16,XmlUtil.getChildTextValue(e, "tot_links"));
		pstmt.setString(17,XmlUtil.getChildTextValue(e, "dist_text_clicks"));
		pstmt.setString(18,XmlUtil.getChildTextValue(e, "dist_html_clicks"));
		pstmt.setString(19,XmlUtil.getChildTextValue(e, "dist_aol_clicks"));
		pstmt.setString(20,XmlUtil.getChildTextValue(e, "multi_readers"));
		pstmt.setString(21,XmlUtil.getChildTextValue(e, "link_multi_clickers"));
		pstmt.setString(22,XmlUtil.getChildTextValue(e, "multi_link_clickers"));
		pstmt.setString(23,XmlUtil.getChildCDataValue(e, "last_update_date"));
		pstmt.setString(24,XmlUtil.getChildTextValue(e, "cache_id"));
		pstmt.setString(25,XmlUtil.getChildCDataValue(e, "cache_start_date"));
		pstmt.setString(26,XmlUtil.getChildCDataValue(e, "cache_end_date"));
		pstmt.setString(27,XmlUtil.getChildTextValue(e, "attr_id"));
		pstmt.setString(28,XmlUtil.getChildCDataValue(e, "attr_value1"));
		pstmt.setString(29,XmlUtil.getChildCDataValue(e, "attr_value2"));
		pstmt.setString(30,XmlUtil.getChildTextValue(e, "attr_operator"));
		pstmt.setString(31,XmlUtil.getChildTextValue(e, "user_id"));
		pstmt.setString(32,XmlUtil.getChildTextValue(e, "filter_id"));
		pstmt.executeUpdate();
	}
	catch (Exception ex) { throw ex; }
	finally { if( pstmt != null ) pstmt.close(); }

	Element e2 = XmlUtil.getChildByName(e, "camp_links");
	if (e2 != null)
	{
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_link");

		if (xel.getLength() > 0)
		{
			for (int j=0; j < xel.getLength(); j++)
			{
				Element e3 = (Element)xel.item(j);

				sSQL = "INSERT crpt_camp_link_cache"
					+ " (cache_id,"
					+ " camp_id,"
					+ " link_id,"
					+ " link_name,"
					+ " tot_clicks,"
					+ " tot_text_clicks,"
					+ " tot_html_clicks,"
					+ " tot_aol_clicks,"
					+ " dist_clicks,"
					+ " dist_text_clicks,"
					+ " dist_html_clicks,"
					+ " dist_aol_clicks,"
					+ " multi_clickers)"
					+ " VALUES ("+sCacheID+","+sCampID+",?,?,?,?,?,?,?,?,?,?,?)";
					
				try
				{
					pstmt = conn.prepareStatement(sSQL);

					pstmt.setString(1,XmlUtil.getChildTextValue(e3, "link_id"));
					pstmt.setString(2,XmlUtil.getChildCDataValue(e3, "link_name"));
					pstmt.setString(3,XmlUtil.getChildTextValue(e3, "tot_clicks"));
					pstmt.setString(4,XmlUtil.getChildTextValue(e3, "tot_text_clicks"));
					pstmt.setString(5,XmlUtil.getChildTextValue(e3, "tot_html_clicks"));
					pstmt.setString(6,XmlUtil.getChildTextValue(e3, "tot_aol_clicks"));
					pstmt.setString(7,XmlUtil.getChildTextValue(e3, "dist_clicks"));
					pstmt.setString(8,XmlUtil.getChildTextValue(e3, "dist_text_clicks"));
					pstmt.setString(9,XmlUtil.getChildTextValue(e3, "dist_html_clicks"));
					pstmt.setString(10,XmlUtil.getChildTextValue(e3, "dist_aol_clicks"));
					pstmt.setString(11,XmlUtil.getChildTextValue(e3, "multi_clickers"));

					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
			}
		}
	}

	e2 = XmlUtil.getChildByName(e, "camp_forms");
	if (e2 != null)
	{
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_form");

		if (xel.getLength() > 0)
		{
			for (int j=0; j < xel.getLength(); j++)
			{
				Element e3 = (Element)xel.item(j);

				sSQL = "INSERT crpt_camp_form_cache"
					+ " (cache_id,"
					+ " camp_id,"
					+ " first_form_id,"
					+ " last_form_id,"
					+ " first_form_name,"
					+ " last_form_name,"
					+ " tot_first_views,"
					+ " tot_complete_submits,"
					+ " dist_first_views,"
					+ " dist_complete_submits,"
					+ " multi_submitters)"
					+ " VALUES ("+sCacheID+","+sCampID+",?,?,?,?,?,?,?,?,?)";
					
				try
				{					
					pstmt = conn.prepareStatement(sSQL);

					pstmt.setString(1,XmlUtil.getChildTextValue(e3, "first_form_id"));
					pstmt.setString(2,XmlUtil.getChildTextValue(e3, "last_form_id"));
					pstmt.setString(3,XmlUtil.getChildCDataValue(e3, "first_form_name"));
					pstmt.setString(4,XmlUtil.getChildCDataValue(e3, "last_form_name"));
					pstmt.setString(5,XmlUtil.getChildTextValue(e3, "tot_first_views"));
					pstmt.setString(6,XmlUtil.getChildTextValue(e3, "tot_complete_submits"));
					pstmt.setString(7,XmlUtil.getChildTextValue(e3, "dist_first_views"));
					pstmt.setString(8,XmlUtil.getChildTextValue(e3, "dist_complete_submits"));
					pstmt.setString(9,XmlUtil.getChildTextValue(e3, "multi_submitters"));

					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
			}
		}
	}

	e2 = XmlUtil.getChildByName(e, "camp_bbacks");
	if (e2 != null)
	{
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_bback");
		
		if (xel.getLength() > 0)
		{
			for (int j=0; j < xel.getLength(); j++)
			{
				Element e3 = (Element)xel.item(j);

				sSQL = "INSERT crpt_camp_bback_cache"
					+ " (cache_id,"
					+ " camp_id,"
					+ " category_id,"
					+ " bbacks)"
					+ " VALUES ("+sCacheID+","+sCampID+",?,?)";
					
				try
				{					
					pstmt = conn.prepareStatement(sSQL);

					pstmt.setString(1,XmlUtil.getChildTextValue(e3, "category_id"));
					pstmt.setString(2,XmlUtil.getChildTextValue(e3, "bbacks"));

					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
			}
		}
	}

	e2 = XmlUtil.getChildByName(e, "camp_domains");
	if (e2 != null)
	{
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_domain");

		if (xel.getLength() > 0)
		{
			try
			{ 	
				stmt = conn.createStatement();
				stmt.executeUpdate("DELETE crpt_camp_domain_cache WHERE camp_id = "+sCampID);
			}
			catch (Exception ex) { throw ex; }
			finally { if( stmt != null ) stmt.close(); }

			for (int j=0; j < xel.getLength(); j++)
			{
				Element e3 = (Element)xel.item(j);

				sSQL = "INSERT crpt_camp_domain_cache"
					+ " (cache_id,"
					+ " camp_id,"
					+ " domain,"
					+ " sent,"
					+ " bbacks,"
					+ " reads,"
					+ " clicks,"
					+ " unsubs,"
					+ " spam_complaints)" 
					+ " VALUES ("+sCacheID+","+sCampID+",?,?,?,?,?,?,?)";
				
				try
				{					
					pstmt = conn.prepareStatement(sSQL);

					pstmt.setString(1,XmlUtil.getChildCDataValue(e3, "domain"));
					pstmt.setString(2,XmlUtil.getChildTextValue(e3, "sent"));
					pstmt.setString(3,XmlUtil.getChildTextValue(e3, "bbacks"));
					pstmt.setString(4,XmlUtil.getChildTextValue(e3, "reads"));
					pstmt.setString(5,XmlUtil.getChildTextValue(e3, "clicks"));
					pstmt.setString(6,XmlUtil.getChildTextValue(e3, "unsubs"));
					pstmt.setString(7,XmlUtil.getChildTextValue(e3, "spam_complaints"));

					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
			}
		}
	}

	e2 = XmlUtil.getChildByName(e, "camp_pos_links");
	if (e2 != null)
	{
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_pos_link");

		if (xel.getLength() > 0)
		{
			for (int j=0; j < xel.getLength(); j++)
			{
				Element e3 = (Element)xel.item(j);

				sSQL = "INSERT crpt_camp_pos_cache "
					+ " (cache_id,"
					+ " pos_link_id,"
					+ " camp_id,"
					+ " href,"
					+ " tot_clicks,"
					+ " dist_clicks)"
					+ " VALUES ("+sCacheID+",?,?,?,?,?)";
					
				try
				{
					pstmt = conn.prepareStatement(sSQL);
									
					pstmt.setString(1,XmlUtil.getChildTextValue(e3, "pos_link_id"));
					pstmt.setString(2,XmlUtil.getChildTextValue(e3, "camp_id"));
					pstmt.setString(3,XmlUtil.getChildCDataValue(e3, "href"));
					pstmt.setString(4,XmlUtil.getChildTextValue(e3, "tot_clicks"));
					pstmt.setString(5,XmlUtil.getChildTextValue(e3, "dist_clicks"));

					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
			}
		}

		Element e3 = XmlUtil.getChildByName(e2, "camp_pos_connects");
		if (e3 != null)
		{
			XmlElementList xel2 = XmlUtil.getChildrenByName(e3, "camp_pos_connect");

			if (xel2.getLength() > 0)
			{
				for (int j=0; j < xel2.getLength(); j++)
				{
					Element e4 = (Element)xel2.item(j);

					sSQL = "INSERT crpt_camp_pos_connect_cache "
						+ " (cache_id,"
						+ " origin_link_id,"
						+ " resulting_link_id,"
						+ " camp_id,"
						+ " steps,"
						+ " tot_clicks,"
						+ " dist_clicks)"
						+ " VALUES ("+sCacheID+",?,?,?,?,?,?)";

					try
					{
						pstmt = conn.prepareStatement(sSQL);

						pstmt.setString(1,XmlUtil.getChildTextValue(e4, "origin_link_id"));
						pstmt.setString(2,XmlUtil.getChildTextValue(e4, "resulting_link_id"));
						pstmt.setString(3,XmlUtil.getChildTextValue(e4, "camp_id"));
						pstmt.setString(4,XmlUtil.getChildTextValue(e4, "steps"));
						pstmt.setString(5,XmlUtil.getChildTextValue(e4, "tot_clicks"));
						pstmt.setString(6,XmlUtil.getChildTextValue(e4, "dist_clicks"));

						pstmt.executeUpdate();
					}
					catch (Exception ex) { throw ex; }
					finally { if( pstmt != null ) pstmt.close(); }

				}
			}
		}
	}
	out.println("<xml>ok</xml>");
	conn.commit();
}
catch(Exception ex)
{ 
	conn.rollback();
	ErrLog.put(this, ex, "Campaign Update Error.",out,1);
}
finally
{
	if( conn != null )
	{
		try { conn.setAutoCommit(true);	}
		catch(Exception eee) {logger.error("Exception: ",eee); }
		cp.free(conn); 
	}
}
%>
