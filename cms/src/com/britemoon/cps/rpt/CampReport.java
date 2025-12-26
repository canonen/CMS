package com.britemoon.cps.rpt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampReport
{
	private Element m_eCampReport = null;
	private static Logger logger = Logger.getLogger(CampReport.class.getName());
	
	public CampReport(Element eCampReport)
	{
		m_eCampReport = eCampReport;
	}
	
	public void save() throws Exception
	{
		ConnectionPool	cp = null;
		Connection conn = null;
		Statement stmt = null;
	
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
                        conn.setAutoCommit(false);
			stmt = conn.createStatement();				
			save(m_eCampReport, conn, stmt);
		}
		catch(Exception ex)
		{
			stmt.execute("IF @@TranCount > 0 ROLLBACK TRANSACTION T1");		
			throw ex;
		}
		finally
		{
			if(stmt != null) stmt.close();		
			if(conn != null) {
                            conn.setAutoCommit(true);
                            cp.free(conn);
                        }
		}
	}

	private void save(Element e, Connection conn, Statement stmt) throws Exception
	{
		String sCampID = XmlUtil.getChildTextValue(e, "camp_id");
		String sCustID = XmlUtil.getChildTextValue(e, "cust_id");

		if ((sCampID == null) || (sCustID == null)) throw new Exception("Campaign not specified.");
	
		saveCampReport(e, conn, sCustID, sCampID);
		saveCampLinks(e, conn, stmt, sCampID);
		saveCampForms(e, conn, stmt, sCampID);
		saveCampBbacks(e, conn, stmt, sCampID);
		saveCampUnsubs(e, conn, stmt, sCampID);
		saveCampDomains(e, conn, stmt, sCampID);
		saveCampOptouts(e, conn, stmt, sCampID);
		saveCampDays(e, conn, stmt, sCampID);
		saveCampHours(e, conn, stmt, sCampID);
		saveCampPosLinks(e, conn, stmt, sCampID);
		saveMbsRevenueReports(e, conn);
	}

	private void saveMbsRevenueReports(Element e, Connection conn) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "mbs_revenue_reports");
		if (e2 == null) return;
		MbsRevenueReports mbrs = new MbsRevenueReports(e2);
		mbrs.save(conn);
                conn.commit();
	}

	private void saveCampReport(Element e, Connection conn, String sCustID, String sCampID) throws Exception
	{
		String sSQL =
			"EXEC usp_crpt_camp_report_update"
			+ " @camp_id=?,"
			+ " @cust_id=?,"
			+ " @camp_name=?,"
			+ " @start_date=?,"
			+ " @sent=?,"
			+ " @bbacks=?,"
			+ " @reaching=?,"
			+ " @dist_reads=?,"
			+ " @tot_reads=?,"
			+ " @dist_clicks=?,"
			+ " @unsubs=?,"
			+ " @tot_clicks=?,"
			+ " @tot_text_clicks=?,"
			+ " @tot_html_clicks=?,"
			+ " @tot_aol_clicks=?,"
			+ " @tot_links=?,"
			+ " @dist_text_clicks=?,"
			+ " @dist_html_clicks=?,"
			+ " @dist_aol_clicks=?,"
			+ " @multi_readers=?,"
			+ " @link_multi_clickers=?,"
			+ " @multi_link_clickers=?,"
			+ " @last_update_date=?,"
			+ " @status_id=?";

		PreparedStatement pstmt = null;
		
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
			pstmt.setString(24,XmlUtil.getChildTextValue(e, "status_id"));

			logger.info("Updating camp report summary " + sCampID);

			pstmt.executeUpdate();
                        conn.commit();
		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }
	}

	private void saveCampLinks(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_links");
		if (e2 == null) return;

		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_link");
		
		logger.info("Updating camp report links " + sCampID);
		
		if (xel.getLength() <= 0) return;
		

		stmt.executeUpdate("DELETE crpt_camp_link WHERE camp_id = "+sCampID);

		PreparedStatement pstmt = null;
		
		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_link"
				+ " (camp_id,"
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
				+ " VALUES ("+sCampID+",?,?,?,?,?,?,?,?,?,?,?)";
				
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
				pstmt.close();
		}
		conn.commit();
	}
	
	private void saveCampForms(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_forms");

		if (e2 == null) return;

		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_form");
			
		logger.info("Updating camp report forms " + sCampID);
		
		if (xel.getLength() <= 0) return;
		
		// === === ===

		stmt.executeUpdate("DELETE crpt_camp_form WHERE camp_id = "+sCampID);

		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_form"
				+ " (camp_id,"
				+ " first_form_id,"
				+ " last_form_id,"
				+ " first_form_name,"
				+ " last_form_name,"
				+ " tot_first_views,"
				+ " tot_complete_submits,"
				+ " dist_first_views,"
				+ " dist_complete_submits,"
				+ " multi_submitters)"
				+ " VALUES ("+sCampID+",?,?,?,?,?,?,?,?,?)";
				
				PreparedStatement pstmt = conn.prepareStatement(sSQL);

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
				pstmt.close();
		}
		conn.commit();
	}
	
	private void saveCampBbacks(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_bbacks");
		if (e2 == null) return;

		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_bback");
			
		logger.info("Updating camp report bbacks " + sCampID);

		if (xel.getLength() <= 0) return;

		// === === ===

		stmt.executeUpdate("DELETE crpt_camp_bback WHERE camp_id = "+sCampID);

		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_bback"
				+ " (camp_id,"
				+ " category_id,"
				+ " bbacks)"
				+ " VALUES ("+sCampID+",?,?)";
				
			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildTextValue(e3, "category_id"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e3, "bbacks"));

			pstmt.executeUpdate();
			pstmt.close();
		}
		conn.commit();
	}

	//Release 6.1: Spam Compliants
	private void saveCampUnsubs(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_unsubs");
		if (e2 == null) return;

		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_unsub");
			
		logger.info("Updating camp report unsubscribes " + sCampID);

		if (xel.getLength() <= 0) return;

		// === === ===

		stmt.executeUpdate("DELETE crpt_camp_unsub WHERE camp_id = "+sCampID);

		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_unsub"
				+ " (camp_id,"
				+ " level_id,"
				+ " unsubs)"
				+ " VALUES ("+sCampID+",?,?)";
				
			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildTextValue(e3, "level_id"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e3, "unsubs"));

			pstmt.executeUpdate();
			pstmt.close();
		}
		conn.commit();
	}	
	
	private void saveCampDomains(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_domains");
		if (e2 == null) return;
		
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_domain");

		logger.info("Updating camp report domains " + sCampID);
		
		if (xel.getLength() <= 0) return;

		// === === ===

		stmt.executeUpdate("DELETE crpt_camp_domain WHERE camp_id = "+sCampID);
		//added for release 5.9 , Domain Deliverability changes 
		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_domain"
				+ " (camp_id,"
				+ " domain,"
				+ " sent,"
				+ " bbacks,"
				+ " reads,"
				+ " clicks,"
				+ " unsubs," 
				+ " spam_complaints)" 
				+ " VALUES ("+sCampID+",?,?,?,?,?,?,?)";
				
			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildCDataValue(e3, "domain"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e3, "sent"));
			pstmt.setString(3,XmlUtil.getChildTextValue(e3, "bbacks"));
			pstmt.setString(4,XmlUtil.getChildTextValue(e3, "reads"));
			pstmt.setString(5,XmlUtil.getChildTextValue(e3, "clicks"));
			pstmt.setString(6,XmlUtil.getChildTextValue(e3, "unsubs"));
			pstmt.setString(7,XmlUtil.getChildTextValue(e3, "spam_complaints"));

			pstmt.executeUpdate();
			pstmt.close();
		}
		conn.commit();
	}

	private void saveCampOptouts(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_optouts");
		if (e2 == null) return;
		
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_optout");
		
		logger.info("Updating camp report optouts " + sCampID);

		if (xel.getLength() <= 0) return;

		// === === ===

		stmt.executeUpdate("DELETE crpt_camp_optout WHERE camp_id = "+sCampID);

		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_optout"
				+ " (camp_id,"
				+ " attr_id,"
				+ " optouts)"
				+ " VALUES ("+sCampID+",?,?)";
				
			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildTextValue(e3, "attr_id"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e3, "optouts"));

			pstmt.executeUpdate();
			pstmt.close();
		}
		conn.commit();
	}

	private void saveCampDays(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_days");
		if (e2 == null) return;

		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_day");
		
		logger.info("Updating camp report days " + sCampID);

		if (xel.getLength() <= 0) return;
		
		// === === ===

		stmt.executeUpdate("DELETE crpt_camp_day WHERE camp_id = "+sCampID);

		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_day"
				+ " (camp_id,"
				+ " day_id,"
				+ " day_date,"
				+ " sent,"
				+ " reads,"
				+ " read_pct,"
				+ " clicks,"
				+ " click_pct,"
				+ " unsubs,"
				+ " unsub_pct)"
				+ " VALUES ("+sCampID+",?,?,?,?,?,?,?,?,?)";
				
			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildTextValue(e3, "day_id"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e3, "day_date"));
			pstmt.setString(3,XmlUtil.getChildTextValue(e3, "sent"));
			pstmt.setString(4,XmlUtil.getChildTextValue(e3, "reads"));
			pstmt.setString(5,XmlUtil.getChildTextValue(e3, "read_pct"));
			pstmt.setString(6,XmlUtil.getChildTextValue(e3, "clicks"));
			pstmt.setString(7,XmlUtil.getChildTextValue(e3, "click_pct"));
			pstmt.setString(8,XmlUtil.getChildTextValue(e3, "unsubs"));
			pstmt.setString(9,XmlUtil.getChildTextValue(e3, "unsub_pct"));

			pstmt.executeUpdate();
			pstmt.close();
		}
		conn.commit();
	}

	private void saveCampHours(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_hours");
		if (e2 == null) return;
		
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_hour");
		
		logger.info("Updating camp report hours "+sCampID);
		
		if (xel.getLength() <= 0) return;
		
		// === === ===

		stmt.executeUpdate("DELETE crpt_camp_hour WHERE camp_id = "+sCampID);

		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"INSERT crpt_camp_hour"
				+ " (camp_id,"
				+ " hour_id,"
				+ " hour_date,"
				+ " sent,"
				+ " reads,"
				+ " read_pct,"
				+ " clicks,"
				+ " click_pct,"
				+ " unsubs,"
				+ " unsub_pct)"
				+ " VALUES ("+sCampID+",?,?,?,?,?,?,?,?,?)";
				
			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildTextValue(e3, "hour_id"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e3, "hour_date"));
			pstmt.setString(3,XmlUtil.getChildTextValue(e3, "sent"));
			pstmt.setString(4,XmlUtil.getChildTextValue(e3, "reads"));
			pstmt.setString(5,XmlUtil.getChildTextValue(e3, "read_pct"));
			pstmt.setString(6,XmlUtil.getChildTextValue(e3, "clicks"));
			pstmt.setString(7,XmlUtil.getChildTextValue(e3, "click_pct"));
			pstmt.setString(8,XmlUtil.getChildTextValue(e3, "unsubs"));
			pstmt.setString(9,XmlUtil.getChildTextValue(e3, "unsub_pct"));

			pstmt.executeUpdate();
			pstmt.close();
		}
		conn.commit();
	}

	private void saveCampPosLinks(Element e, Connection conn, Statement stmt, String sCampID) throws Exception
	{
		Element e2 = XmlUtil.getChildByName(e, "camp_pos_links");
		if (e2 == null) return;
		
		XmlElementList xel = XmlUtil.getChildrenByName(e2, "camp_pos_link");
		
		logger.info("Updating camp report POS links " + sCampID);

		// === === ===

		for (int j=0; j < xel.getLength(); j++)
		{
			Element e3 = (Element)xel.item(j);

			String sSQL =
				"EXEC usp_crpt_camp_pos_insert "
				+ " @pos_link_id=?,"
				+ " @camp_id=?,"
				+ " @href=?,"
				+ " @tot_clicks=?,"
				+ " @dist_clicks=?";
				
			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildTextValue(e3, "pos_link_id"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e3, "camp_id"));
			pstmt.setString(3,XmlUtil.getChildCDataValue(e3, "href"));
			pstmt.setString(4,XmlUtil.getChildTextValue(e3, "tot_clicks"));
			pstmt.setString(5,XmlUtil.getChildTextValue(e3, "dist_clicks"));

			pstmt.executeUpdate();
			pstmt.close();
		}
		
		saveCampPosConnects(e2, conn, sCampID);
                conn.commit();
	}

	private void saveCampPosConnects(Element e2, Connection conn, String sCampID) throws Exception
	{
		Element e3 = XmlUtil.getChildByName(e2, "camp_pos_connects");
		if (e3 == null) return;
		
		XmlElementList xel2 = XmlUtil.getChildrenByName(e3, "camp_pos_connect");
		
		logger.info("Updating camp report POS connects " + sCampID);

		// === === ===
		
		for (int j=0; j < xel2.getLength(); j++)
		{
			Element e4 = (Element)xel2.item(j);

			String sSQL =
				"EXEC usp_crpt_camp_pos_connect_insert "
				+ " @origin_link_id=?,"
				+ " @resulting_link_id=?,"
				+ " @camp_id=?,"
				+ " @steps=?,"
				+ " @tot_clicks=?,"
				+ " @dist_clicks=?";

			PreparedStatement pstmt = conn.prepareStatement(sSQL);

			pstmt.setString(1,XmlUtil.getChildTextValue(e4, "origin_link_id"));
			pstmt.setString(2,XmlUtil.getChildTextValue(e4, "resulting_link_id"));
			pstmt.setString(3,XmlUtil.getChildTextValue(e4, "camp_id"));
			pstmt.setString(4,XmlUtil.getChildTextValue(e4, "steps"));
			pstmt.setString(5,XmlUtil.getChildTextValue(e4, "tot_clicks"));
			pstmt.setString(6,XmlUtil.getChildTextValue(e4, "dist_clicks"));

			pstmt.executeUpdate();
			pstmt.close();
                        
		}
                conn.commit();
	}
}
