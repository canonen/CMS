package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.io.*;
import java.sql.*;
import java.util.*; 
import org.apache.log4j.*;

public class CampApproveDAO
{
	private static Logger logger = Logger.getLogger(CampApproveDAO.class.getName());
	public CampApproveDAO ()
	{
	}

	public int doDbUpdate (String sCampId, String sAction) throws SQLException
	{
		int iResult = 0;

		String sApprovalVal = "0";
		if ( (sAction.equals("approve")) || (sAction.equals("restart")) ) sApprovalVal = "1";

		String sSql =
			"UPDATE cque_campaign SET approval_flag = " + sApprovalVal + 
			" WHERE camp_id = " + sCampId;

		try { iResult = BriteUpdate.executeUpdate(sSql); }
		catch(SQLException sqlex) {
               logger.error("Exception: ", sqlex);
               throw sqlex;
        }

		return iResult;
	}
     
	public int doDbUpdateSamples (String sCampId, String sAction) throws SQLException
	{
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
          ResultSet rs = null;
		int iResult = 0;

		String sSql = "SELECT camp_id " +
                                   " FROM cque_campaign " +
                                   " WHERE sample_id IS NOT NULL AND " +
                                   " origin_camp_id = ? AND " +
                                   " type_id <> 1";
          
		try { 
               cp = ConnectionPool.getInstance();
               conn = cp.getConnection(this  + ".doDbUpdateSamples()");

               pstmt = conn.prepareStatement(sSql);
               pstmt.setString(1,sCampId);

               rs = pstmt.executeQuery();

               while (rs.next()) {
                    iResult = doDbUpdate(rs.getString(1), sAction);
                    if (iResult != 1) break;
               }
          }
		catch(SQLException sqlex) {
               logger.error("Exception: ", sqlex);
               throw sqlex;
          } finally {
			try	{ if (pstmt!=null) pstmt.close(); }
			catch (Exception ex) {  }
			if (conn!=null) cp.free(conn);
          }

		return iResult;
	}

	// method changed as a part of release 6.0, 'Set Done' button added which will perform same action as Cancel
	public int doCancelCamp (String sCustId, String sCampId, String sAction) 
	{
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
          //ResultSet rs = null;
         int iResult = 0;
          
 		try
		{
               cp = ConnectionPool.getInstance();
               conn = cp.getConnection(this  + ".doCancelCamp()");

			//first, just suspend the campaign
               iResult = this.doDbUpdate(sCampId,"suspend");
               int campaignStatus = 0;
               
               if (iResult == 1) {
                    //next, cancel the campaign on the RCP side
                    Service service = null;
                    String sRCPXml = null;
                    String sCPSXml = null;
                    
                    if(sAction.equalsIgnoreCase("cancel"))
                    {
                    	campaignStatus = CampaignStatus.CANCELLED; 	
                    }
                    else
                    {
                    	campaignStatus = CampaignStatus.DONE; 	
                    }

                    sRCPXml = "<CampCancel>\r\n" +
                    "<action>CampCancel</action>\r\n" +
                    "<cust_id>" + sCustId + "</cust_id>\r\n" +
                    "<camp_id>" + sCampId + "</camp_id>\r\n" +
                    "<status_id>" + campaignStatus + "</status_id>\r\n" +
					"</CampCancel>\r\n";                 	

                    //System.out.println("in CampApproveDAO, sending XML to RCP...");
                    //System.out.println(sRCPXml);

                    Vector services = Services.getByCust(ServiceType.RQUE_CAMP_CANCEL, sCustId);
                    service = (Service) services.get(0);
                    // use this for local testing ONLY!! service.s_host = "localhost";
                    service.connect();
                    service.send(sRCPXml);
                    sCPSXml = service.receive();
                    service.disconnect();
                    //System.out.println("Returned from RCP...");
                    //System.out.println(sCPSXml);

                    if (sCPSXml == null || sCPSXml.indexOf("<OK>OK</OK>") == -1) {
                         String sErrMsg = "Error returned from RCP";
                         logger.error(sErrMsg + "->RQUE_CAMP_CANCEL.  Returned XML follows:\n" + sCPSXml);
                         iResult = -1;
                    } else {
                         //now Cancel the campaign on the CPS side.
                         String sSql = "update cque_campaign " + 
                                   "SET status_id = " + campaignStatus + " " +
                                   "WHERE camp_id = ? " +
                                   "AND cust_id = ?";
                    
                         pstmt = conn.prepareStatement(sSql);
                         pstmt.setString(1,sCampId);
                         pstmt.setString(2,sCustId);
                         iResult = pstmt.executeUpdate();
                    }
               }
               
		}
		catch (SQLException sqle)
		{
			String sErrMsg = "SQL Error during Campaign DAO.doCancelCamp().";
			logger.error("Exception: " + sErrMsg , sqle);
               return -1;
		}
		catch (IOException ioe)
		{
			String sErrMsg = "I/O Error during Campaign DAO.doCancelCamp().";
			logger.error("Exception: " + sErrMsg,ioe);
               return -1;
		}
		catch (Exception e)
		{
			String sErrMsg = "Error during Campaign DAO.doCancelCamp().";
			logger.error("Exception: " + sErrMsg , e);
               return -1;
		}
		finally
		{
			try	{ if (pstmt!=null) pstmt.close(); }
			catch (Exception ex) {  }
			if (conn!=null) cp.free(conn);
		}

          return iResult;  // return value should be 1 if the Cancel SP was successful; 0 if an error occurred
	}

	public boolean getApprovedStatus (String sCampId) 
	{
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		boolean bApproved = false;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this  + ".getSampleApprovedStatus()");
			
			String sSql =
				" SELECT " +
				" ISNULL(approval_flag,0) FROM cque_campaign " +
				" WHERE camp_id = ? AND " +
				//" origin_camp_id is not null and " +
				" type_id <> 1";

			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,sCampId);

			rs = pstmt.executeQuery();
			if (rs.next()) bApproved = (rs.getInt(1) == 1);
			rs.close();
		}
		catch (SQLException sqle)
		{
			logger.info("SQL Error during CampaignDAO.getSampleApprovedStatus().");
			logger.info(sqle.getMessage());
			logger.error("Exception: ", sqle);
		}
		finally
		{
			try { if (pstmt!=null) pstmt.close(); }
			catch (Exception ex) {  }
			if (conn!=null) cp.free(conn);
		}

		return bApproved;
	}

	public boolean getSentStatus (String sCampId) 
	{
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		boolean bSent = false;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this  + ".getSampleSentStatus()");
			
			String sSql =
				" SELECT " +
				" status_id FROM cque_campaign " +
				" WHERE camp_id = ? AND " +
				//" origin_camp_id is not null AND " +
				" type_id <> 1";
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,sCampId);

			rs = pstmt.executeQuery();
			if (rs.next()) bSent = (rs.getInt(1) < CampaignStatus.DONE);
			rs.close();
		}
		catch (SQLException sqle)
		{
			logger.info("SQL Error during CampaignDAO.getSampleSentStatus().");
			logger.info(sqle.getMessage());
			logger.error("Exception: ", sqle);
		}
		finally
		{
			try { if (pstmt!=null) pstmt.close(); }
			catch (Exception ex) {  }
			if (conn!=null) cp.free(conn);
		}

		return bSent;
	}

	public String getActiveCamp (String sOriginCampId, String sSampleId) 
	{
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		String sActiveCampId = null;

 		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this  + ".getActiveCamp()");
			stmt = conn.createStatement();
			
			StringBuffer sbSql = new StringBuffer("Select camp_id from cque_campaign " +
				" where origin_camp_id = " + sOriginCampId + 
				" AND type_id <> " + Integer.toString(CampaignType.TEST));

			if (sSampleId == null)
				sbSql.append(" AND sample_id is null");
			else
				sbSql.append(" AND sample_id = " + sSampleId);
				
			rs = stmt.executeQuery(sbSql.toString());
			if (rs.next()) sActiveCampId = rs.getString("camp_id");
			rs.close();
		}
		catch (SQLException sqle)
		{
			logger.info("SQL Error during Campaign DAO.getActiveCamp().");
			logger.info(sqle.getMessage());
			logger.error("Exception: ", sqle);
		}
		finally
		{
			try	{ if (stmt!=null) stmt.close(); }
			catch (Exception ex) {  }
			if (conn!=null) cp.free(conn);
		}

		return sActiveCampId;
	}
}
