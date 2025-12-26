package com.britemoon.cps.wfl;

import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.StringTokenizer;
import java.util.Vector;

import org.apache.log4j.Logger;

import com.britemoon.cps.AccessRight;
import com.britemoon.cps.ApprovalDisposition;
import com.britemoon.cps.CampaignMode;
import com.britemoon.cps.CampaignStatus;
import com.britemoon.cps.CampaignType;
import com.britemoon.cps.ContStatus;
import com.britemoon.cps.FilterStatus;
import com.britemoon.cps.FilterType;
import com.britemoon.cps.FilterUsageType;
import com.britemoon.cps.ImportStatus;
import com.britemoon.cps.ObjectType;
import com.britemoon.cps.ServiceType;
import com.britemoon.cps.UserStatus;
import com.britemoon.cps.BriteUpdate;
import com.britemoon.cps.ConnectionPool;
import com.britemoon.cps.User;
import com.britemoon.cps.cnt.ContEditInfo;
import com.britemoon.cps.cnt.ContRetrieveUtil;
import com.britemoon.cps.cnt.Content;
import com.britemoon.cps.imc.Services;
import com.britemoon.cps.jtk.Link;
import com.britemoon.cps.que.CampEditInfo;
import com.britemoon.cps.que.CampList;
import com.britemoon.cps.que.CampRetrieveUtil;
import com.britemoon.cps.que.CampSampleset;
import com.britemoon.cps.que.CampSendParam;
import com.britemoon.cps.que.CampSetupUtil;
import com.britemoon.cps.que.Campaign;
import com.britemoon.cps.que.EmailList;
import com.britemoon.cps.que.LinkedCamp;
import com.britemoon.cps.que.Schedule;
import com.britemoon.cps.tgt.Filter;
import com.britemoon.cps.tgt.FilterEditInfo;
import com.britemoon.cps.tgt.FilterParam;
import com.britemoon.cps.tgt.FilterParams;
import com.britemoon.cps.tgt.FilterPart;
import com.britemoon.cps.tgt.FilterParts;
import com.britemoon.cps.tgt.FilterRetrieveUtil;
import com.britemoon.cps.upd.Import;
import com.britemoon.cps.upd.ImportBean;
import com.britemoon.cps.upd.ImportUtil;

public class WorkflowUtil
{
	/* determines whether or not a customer is using workflow */
	private static Logger logger = Logger.getLogger(WorkflowUtil.class.getName());
	public static boolean getWorkflow(String sCustId, int iObjectType) throws Exception
	{
		boolean bWorkflow = false;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getWorkflow()");

			PreparedStatement pstmt = null;
			int iWorkflowFlag = -1;

			try
			{
				String sSql =
					" SELECT aprvl_workflow_flag FROM ccps_aprvl_cust" +
					" WHERE cust_id = ? AND object_type = ?";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1,sCustId);
				pstmt.setInt(2,iObjectType);

				ResultSet rs = pstmt.executeQuery();
				while (rs.next()) { iWorkflowFlag = rs.getInt(1); }
				rs.close();

				if (iWorkflowFlag <=0) bWorkflow = false;
				if (iWorkflowFlag == 1) bWorkflow = true;
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return bWorkflow;
	}

	public static Vector getCustChain(String sCustId) throws Exception {
		Vector vCustChain = new Vector();

		ConnectionPool cp = null;
		Connection conn = null;


		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getCustChain()");

			PreparedStatement pstmt = null;
			String sUserId = null;

			try
			{
				String sSql = "EXEC usp_ccps_cust_parent_chain_get @cust_id=?";
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1,sCustId);

				ResultSet rs = pstmt.executeQuery();
				while (rs.next()) vCustChain.add(rs.getString(1));
				rs.close();
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if (conn != null ) cp.free(conn); }

		if (vCustChain.size() == 0 ) { vCustChain = null; }
		return vCustChain;
	}

	public static Hashtable getApprovers(String sCustId, int iObjectType) throws Exception
	{
		Hashtable htApprovers = new Hashtable();

		ConnectionPool cp = null;
		Connection conn = null;

		Vector vCustChain = getCustChain(sCustId);

		//System.out.println("customer chain withing getApprovers:" + vCustChain.toString().substring(1,vCustChain.toString().length()-1));

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getApprovers()");

			PreparedStatement pstmt = null;

			String sUserId = null;
			String sUserName = null;
			int iAccessMask = 0;

			try
			{
				String sSql =
					" SELECT DISTINCT am.user_id, ISNULL(u.user_name,'') + ' ' + ISNULL(u.last_name,'') " +  //, am.mask " +
					" FROM  ccps_access_mask am INNER JOIN " +
					" ccps_user u ON am.user_id = u.user_id " +
					" WHERE u.cust_id in (" + vCustChain.toString().substring(1,vCustChain.toString().length()-1) + ") AND " +
					" u.status_id = " + UserStatus.ACTIVATED + " AND " +
					" am.mask >= ?";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setInt(1, AccessRight.APPROVE);

				ResultSet rs = pstmt.executeQuery();

				User user = null;

				while (rs.next())
				{
					sUserId = rs.getString(1);
					sUserName = rs.getString(2);
//					iAccessMask = rs.getInt(3);
					user = new User(sUserId);
					if (user.getAccessPermission(iObjectType).bApprove)
						htApprovers.put(sUserId,sUserName);
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close();}
		}
		catch (Exception ex) { throw ex; }
		finally { if (conn != null ) cp.free(conn); }

		if (htApprovers.size() == 0 ) htApprovers = null;
		return htApprovers;
	}

	public static ApprovalPath getCustApprovalPath (String sCustId) throws Exception
	{
		ApprovalPath apApprovalPath = null;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getCustApprovalPath()");

			PreparedStatement pstmt = null;

			try
			{
				ResultSet rs = null;

				String sSql =
					" SELECT approval_path_id " +
					" FROM  ccps_aprvl_path  " +
					" WHERE cust_id = ? ";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1,sCustId);

				rs = pstmt.executeQuery();

				if (rs.next())
				{
					apApprovalPath = new ApprovalPath(rs.getString(1));
					apApprovalPath.getCustPath();
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if (conn != null ) cp.free(conn); }

		return apApprovalPath;
	}

	public static ApprovalPath getGroupApprovalPath (String sCustId, String sGroupId) throws Exception
	{
		ApprovalPath apApprovalPath = null;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getGroupApprovalPath()");

			PreparedStatement pstmt = null;

			try
			{
				ResultSet rs = null;

				String sSql =
					" SELECT approval_path_id " +
					" FROM  ccps_aprvl_path  " +
					" WHERE cust_id = ? AND group_id = ? ";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1,sCustId);
				pstmt.setString(2,sGroupId);

				rs = pstmt.executeQuery();

				if (rs.next())
				{
					apApprovalPath = new ApprovalPath(rs.getString(1));
					apApprovalPath.getGroupPath();
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if (conn != null ) cp.free(conn); }

		return apApprovalPath;
	}

	public static void setRequestsInactive(String sApprovalId) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.setRequestsInactive()");

			PreparedStatement pstmt = null;

			try
			{
				String sSql = "UPDATE ccps_aprvl_request set active_flag = 0 WHERE aprvl_id = ?";
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1,sApprovalId);
				pstmt.executeUpdate();
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }
	}

	public static ApprovalTask getApprovalTask(String sCustId, String sObjectType, String sObjectId) throws Exception
	{
		return getApprovalTask(sCustId, sObjectType, sObjectId, null);
	}

	public static ApprovalTask getApprovalTask
	(String sCustId, String sObjectType, String sObjectId, String sCampSampleFlag)
	throws Exception
	{
		ApprovalTask atApprovalTask = null;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getApprovalTask()");

			PreparedStatement pstmt = null;
			ResultSet rs = null;

			try
			{
				String sSql =
					" SELECT approval_id FROM ccps_aprvl_task " +
					" WHERE cust_id = ? AND " +
					" object_type = ? AND " +
					" object_id = ? AND " +
					" active_flag = 1";
				if (sCampSampleFlag != null) sSql += " AND camp_sample_flag = ? ";
				else sSql += " AND camp_sample_flag is NULL ";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCustId);
				pstmt.setString(2, sObjectType);
				pstmt.setString(3, sObjectId);
				if (sCampSampleFlag != null) pstmt.setString(4, sCampSampleFlag);

				rs = pstmt.executeQuery();
				if (rs.next())
				{
					String sApprovalId = rs.getString(1);
					if (sApprovalId != null)
					{
						atApprovalTask = new ApprovalTask(sApprovalId);
					}
				}
				rs.close();

				if (atApprovalTask == null)
				{
					atApprovalTask = new ApprovalTask();
					atApprovalTask.s_cust_id = sCustId;
					atApprovalTask.s_object_type = sObjectType;
					atApprovalTask.s_object_id = sObjectId;
					if (sCampSampleFlag != null && !sCampSampleFlag.equals("null"))
						atApprovalTask.s_camp_sample_flag = sCampSampleFlag;
					atApprovalTask.s_active_flag = "1";
					atApprovalTask.save();
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return atApprovalTask;
	}

	public static ApprovalRequest getApprovalRequest(String sCustId, String sObjectType, String sObjectId) throws Exception {
		return getApprovalRequest(sCustId, sObjectType, sObjectId, null);
	}

	public static ApprovalRequest getApprovalRequest(String sCustId, String sObjectType, String sObjectId, String sCampSampleFlag) throws Exception {
		ApprovalRequest arRequest  = null;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getApprovalRequest()");

			PreparedStatement pstmt = null;
			ResultSet rs = null;

			try
			{
				String sSql =
					" SELECT ar.approval_request_id " +
					" FROM ccps_aprvl_request ar, ccps_aprvl_task at " +
					" WHERE at.cust_id = ? AND " +
					" at.object_type = ? AND " +
					" at.object_id = ? AND " +
					" ar.aprvl_id = at.approval_id AND " +
					" ar.active_flag = 1 AND " +
					" at.active_flag = 1";

				if (sCampSampleFlag != null) sSql += " AND at.camp_sample_flag = ? ";
				else sSql += " AND at.camp_sample_flag is NULL ";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCustId);
				pstmt.setString(2, sObjectType);
				pstmt.setString(3, sObjectId);
				if (sCampSampleFlag != null) pstmt.setString(4, sCampSampleFlag);

				rs = pstmt.executeQuery();
				if (rs.next())
				{
					String sAprvlRequestId = rs.getString(1);
					if (sAprvlRequestId != null)
					{
						arRequest = new ApprovalRequest(sAprvlRequestId);
					}
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return arRequest;
	}

	public static String getCampId(String sCustId, String sOriginCampId, String sSampleId) throws Exception
	{
		String sCampId = null;

		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getCampId()");
			PreparedStatement pstmt = null;
			ResultSet rs = null;

			try
			{
				String sSql =
					" SELECT camp_id FROM cque_campaign " +
					" WHERE origin_camp_id = ? AND " +
					" type_id <> 1 AND " +
					" status_id = " + CampaignStatus.PENDING_APPROVAL;

				if (sSampleId != null) sSql += " AND sample_id = ?";
				else sSql += " AND sample_id is null";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sOriginCampId);
				if (sSampleId != null) pstmt.setString(2,sSampleId);

				rs = pstmt.executeQuery();
				if (rs.next()) sCampId = rs.getString(1);
				rs.close();
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return sCampId;
	}

	public static String getPendingEditsCampId(String sCustId, String sOriginCampId, String sSampleId)
	throws Exception
	{
		String sCampId = null;

		ConnectionPool cp = null;
		Connection conn = null;
		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getPendingEditsCampId()");
			PreparedStatement pstmt = null;

			try
			{
				String sSql =
					" SELECT camp_id FROM cque_campaign " +
					" WHERE origin_camp_id = ? AND " +
					" type_id <> 1 AND " +
					" status_id = " + CampaignStatus.PENDING_EDITS;

				if (sSampleId == null) sSql += " AND sample_id is null";
				else if (sSampleId.equals("all_samples"))  sSql += " AND sample_id is not null";
				else sSql += " AND sample_id = ?";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sOriginCampId);
				if (sSampleId != null && !sSampleId.equals("all_samples"))
				{
					pstmt.setString(2,sSampleId);
				}

				ResultSet rs = pstmt.executeQuery();
				if (rs.next()) sCampId = rs.getString(1);
				rs.close();
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return sCampId;
	}

	public static void getCustApprovalTasks
	(String sCustId, ApprovalPath apApprovalPath, String sObjectType, String sObjectId)
	throws Exception
	{
		getCustApprovalTasks(sCustId, apApprovalPath, sObjectType, sObjectId, null);
	}

	public static void getCustApprovalTasks
	(String sCustId, ApprovalPath apApprovalPath, String sObjectType, String sObjectId, String sCampSampleFlag)
	throws Exception
	{
		// for every customer in apApprovalPath.vCusts, make sure an Approval Task exists.
		//If not, create an Approval Task with any links to next_tier_custs
		Iterator itCusts = apApprovalPath.m_vCusts.iterator();
		String sCurCustId = null;
		if (itCusts != null)
		{
			while (itCusts.hasNext())
			{
				sCurCustId = (String)itCusts.next();
				if (getApprovalTask(sCurCustId,sObjectType, sObjectId, sCampSampleFlag) == null)
				{
					throw new Exception("Error occurred checking for Approval Tasks for cust:" + sCurCustId + " and Approval Path:" + apApprovalPath.s_approval_path_id);
				}
			}
		}
	}

	public static void setPendingStatus(String sObjectType, String sObjectId)
	throws Exception
	{

		int iObjectType = Integer.parseInt(sObjectType);

		switch(iObjectType)
		{
		case ObjectType.CAMPAIGN:
		{
			Campaign camp = new Campaign(sObjectId);
			camp.s_status_id = String.valueOf(CampaignStatus.PENDING_APPROVAL);
			camp.save();
			break;
		}
		case ObjectType.CONTENT:
		{
			Content cont = new Content(sObjectId);
			cont.s_status_id = String.valueOf(ContStatus.PENDING_APPROVAL);
			cont.save();
			break;
		}
		case ObjectType.FILTER:
		{
			Filter filter = new Filter(sObjectId);
			filter.s_status_id = String.valueOf(FilterStatus.PENDING_APPROVAL);
			filter.save();
			break;
		}
		case ObjectType.IMPORT:
		{
			ConnectionPool cp = null;
			Connection conn = null;

			try
			{
				cp = ConnectionPool.getInstance();
				conn = cp.getConnection("WorkflowUtil.setPendingStatus()");

				PreparedStatement pstmt = null;

				try
				{
					String sSql = "UPDATE cupd_import set status_id = ? WHERE import_id = ?";
					pstmt = conn.prepareStatement(sSql);
					pstmt.setInt(1,ImportStatus.PENDING_APPROVAL);
					pstmt.setString(2,sObjectId);

					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if (pstmt!=null) pstmt.close(); }
			}
			catch (Exception e) { throw e; }
			finally { if (conn != null) cp.free(conn); }

			break;
		}
		case ObjectType.USER:
		{
			User user = new User(sObjectId);
			user.s_status_id = String.valueOf(UserStatus.PENDING_APPROVAL);
			user.save();
			break;
		}
		}
	}

	public static boolean setRejectedStatus (String sObjectType, String sObjectId, String sCustId)
	throws Exception
	{
		boolean bSuccess = false;
		int iObjectType = Integer.parseInt(sObjectType);

		switch(iObjectType)
		{
		case ObjectType.CONTENT:
			Content cont = new Content(sObjectId);
			cont.s_status_id = String.valueOf(ContStatus.DRAFT);
			cont.save();
			bSuccess = true;
			break;

		case ObjectType.FILTER:
			Filter filter = new Filter(sObjectId);
			filter.s_status_id = String.valueOf(FilterStatus.NEW);
			filter.save();
			bSuccess = true;
			break;

		case ObjectType.IMPORT:
			// rollback the import
			//rollbackImport(sObjectId, sCustId);
			Import imp = new Import(sObjectId);
			imp.s_status_id = String.valueOf(ImportStatus.IN_STAGING);
			imp.save();
			bSuccess = true;
			break;

		case ObjectType.USER:
			User user = new User(sObjectId);
			user.s_status_id = String.valueOf(UserStatus.DRAFT);
			user.save();
			bSuccess = true;
			break;
		}

		return bSuccess;

	}

	public static boolean setApprovedStatus(String sObjectType, String sObjectId, String sCustId)
	throws Exception
	{
		boolean bSuccess = false;
		int iObjectType = Integer.parseInt(sObjectType);

		switch(iObjectType)
		{
		case ObjectType.CONTENT:
			Content cont = new Content(sObjectId);
			cont.s_status_id = String.valueOf(ContStatus.READY);
			cont.save();
			bSuccess = true;
			break;

		case ObjectType.FILTER:
			Filter filter = new Filter(sObjectId);
			filter.s_status_id = String.valueOf(FilterStatus.READY);
			filter.s_aprvl_status_flag = "1";
			filter.save();
			bSuccess = true;
			break;

		case ObjectType.IMPORT:
			ConnectionPool cp = null;
			Connection conn = null;
			try {
				cp = ConnectionPool.getInstance();
				conn = cp.getConnection("WorkflowUtil.setPendingStatus()");
				PreparedStatement pstmt = null;

				try {
					String sSql = "UPDATE cupd_import set status_id = ? WHERE import_id = ?";
					pstmt = conn.prepareStatement(sSql);
					pstmt.setInt(1,ImportStatus.IN_STAGING);
					pstmt.setString(2,sObjectId);

					pstmt.executeUpdate();
				} catch (Exception ex) {
					throw ex;
				} finally {
					if (pstmt!=null) pstmt.close();
				}
			} catch (Exception e) {
				throw e;
			} finally {
				if (conn != null)
					cp.free(conn);
			}
			bSuccess = true;
			break;

		case ObjectType.USER:
			User user = new User(sObjectId);
			user.s_status_id = String.valueOf(UserStatus.ACTIVATED);
			user.save();
			bSuccess = true;
			break;

		}

		return bSuccess;

	}

	public static boolean setPendingEditsStatus(String sObjectType, String sObjectId, String sCustId) throws Exception {

		boolean bSuccess = false;
		int iObjectType = Integer.parseInt(sObjectType);

		switch(iObjectType) {

		case ObjectType.CAMPAIGN:
			Campaign camp = new Campaign(sObjectId);
			camp.s_status_id = String.valueOf(CampaignStatus.PENDING_EDITS);
			camp.save();
			bSuccess = true;
			break;

			/*			case ObjectType.CONTENT:
						Content cont = new Content(sObjectId);
						cont.s_status_id = String.valueOf(ContStatus.READY);
						cont.save();
						bSuccess = true;
						break;

			case ObjectType.FILTER:
						Filter filter = new Filter(sObjectId);
						filter.s_status_id = String.valueOf(FilterStatus.READY);
						filter.save();
						bSuccess = true;
						break;

			case ObjectType.IMPORT:
						ConnectionPool cp = null;
						Connection conn = null;
						try {
							cp = ConnectionPool.getInstance();
							conn = cp.getConnection("WorkflowUtil.setPendingStatus()");
							PreparedStatement pstmt = null;

							try {
								String sSql = "UPDATE cupd_import set status_id = ? WHERE import_id = ?";
								pstmt = conn.prepareStatement(sSql);
								pstmt.setInt(1,ImportStatus.IN_STAGING);
								pstmt.setString(2,sObjectId);

								pstmt.executeUpdate();
							} catch (Exception ex) {
								throw ex;
							} finally {
								if (pstmt!=null) pstmt.close();
							}
						} catch (Exception e) {
							throw e;
						} finally {
							if (conn != null)
								cp.free(conn);
						}
						bSuccess = true;
						break;

			case ObjectType.USER:
						User user = new User(sObjectId);
						user.s_status_id = String.valueOf(UserStatus.ACTIVATED);
						user.save();
						bSuccess = true;
						break;
			 */
		}

		return bSuccess;

	}

	public static void rollbackImport(String sImportId, String sCustId) throws Exception
	{
		ImportUtil.sendImportActionToRCP(sCustId, sImportId, "rollback");

		// === === ===

		ConnectionPool cp = null;
		Connection conn =  null;
		Statement stmt = null;
		ResultSet rs = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.rollbackImport()");
			conn.setAutoCommit(false);

			try
			{
				stmt = conn.createStatement();

				rs = stmt.executeQuery("SELECT i.batch_id FROM cupd_import i, cupd_batch b"
						+ " WHERE i.batch_id = b.batch_id AND i.import_id = "+sImportId+" AND b.cust_id = "+sCustId);
				int nBatchID = 0;
				if (rs.next())
					nBatchID = rs.getInt(1);
				rs.close();

				if (nBatchID > 0)
				{
					stmt.executeUpdate("DELETE cupd_fields_mapping WHERE import_id = "+sImportId);
					stmt.executeUpdate("DELETE cupd_import_statistics WHERE import_id = "+sImportId);
					stmt.executeUpdate("DELETE cupd_import_newsletter WHERE import_id = "+sImportId);
					stmt.executeUpdate("DELETE cupd_import WHERE import_id = "+sImportId);

					rs = stmt.executeQuery("SELECT count(*) FROM cupd_import WHERE batch_id = "+nBatchID);
					int nCount = 0;
					if (rs.next())
						nCount = rs.getInt(1);
					rs.close();
					if (nCount < 1)  // No imports for that batch - delete it
						stmt.executeUpdate("DELETE cupd_batch WHERE batch_id = "+nBatchID);
					conn.commit();
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { 
			if ( conn != null ) {
				conn.setAutoCommit(true);
				cp.free(conn); 
			}
		}
	}

	public static String getReturnPage(String sObjectType) throws Exception
	{
		int iObjectType = Integer.parseInt(sObjectType);
		String sReturnPage = null;

		switch(iObjectType)
		{
		case ObjectType.CAMPAIGN:
			sReturnPage = "../index.jsp?tab=Camp&sec=1";
			break;

		case ObjectType.CONTENT:
			sReturnPage = "../index.jsp?tab=Cont&sec=1";
			break;

		case ObjectType.FILTER:
			sReturnPage = "../index.jsp?tab=Data&sec=2";
			break;

		case ObjectType.IMPORT:
			sReturnPage = "../index.jsp?tab=Data&sec=1";
			break;

		case ObjectType.USER:
			sReturnPage = "../index.jsp?tab=Admn&sec=1";
			break;

		}
		return sReturnPage;
	}

	public static boolean deleteCamp(String sCustId, String sCampId) throws Exception
	{
		boolean bSuccess = false;

		Campaign camp = new Campaign(sCampId);

		if (camp != null)
		{
			if (sCustId.equals(camp.s_cust_id))
			{
				if (camp.s_sample_id == null || camp.s_sample_id.equals("null") || camp.s_sample_id.equals("0"))
				{
					// Single or Final campaign, just delete it
					bSuccess = deleteCampAndChildren(sCustId, sCampId);
				}
				else
				{
					bSuccess = false;
				}
			}
		}
		else
		{
			logger.info("no campaign for camp Id:" + sCampId);		
		}

		return bSuccess;
	}

	public static boolean deleteCampSamples(String sCustId, String sOriginCampId) throws Exception
	{
		boolean bSuccess = false;

		Campaign camp = new Campaign(sOriginCampId);
		if (camp.s_cust_id.equals(sCustId))
		{
			CampSampleset cSampleset = new CampSampleset(sOriginCampId);
			String sSampleCampId = null;
			for (int i = 1; i <= Integer.parseInt(cSampleset.s_camp_qty); i++)
			{
				sSampleCampId = getCampId(sCustId,sOriginCampId,String.valueOf(i));
				bSuccess = deleteCampAndChildren(sCustId, sSampleCampId);
			}
		}

		return bSuccess;
	}


	public static boolean deleteCampAndChildren(String sCustId, String sCampId) throws Exception
	{
		Campaign camp = new Campaign(sCampId);

		boolean bSuccess = deleteCampChildren(sCustId, sCampId);
		if (bSuccess)
		{
			CampRetrieveUtil.retrieve4Rcp(camp);

			ContRetrieveUtil.retriveContTree(camp.m_Content,true, true, true, true);
			ContRetrieveUtil.retriveContEditInfo(camp.m_Content);
//			ContRetrieveUtil.retriveContSendParam(camp.m_Content);

			FilterRetrieveUtil.retrieveFilterStatistic(camp.m_Filter);
			FilterRetrieveUtil.retrievePreviewAttrs(camp.m_Filter);
			FilterEditInfo fei = new FilterEditInfo(camp.m_Filter.s_filter_id);
			camp.m_Filter.m_FilterEditInfo = fei;
			camp.delete();
		}
		// do the same damn thing over on RCP
		String sRcpXml = "<CampDelete>\r\n" +
		"<action>CampDelete</action>\r\n" +
		"<cust_id>" + sCustId + "</cust_id>\r\n" +
		"<camp_id>" + sCampId + "</camp_id>\r\n" +
		"</CampDelete>\r\n";
		Vector vSvcs = Services.getByType(ServiceType.RQUE_CAMP_DELETE);
		com.britemoon.cps.imc.Service svc = (com.britemoon.cps.imc.Service) vSvcs.get(0);
//		svc.s_host = "localhost";
		String sResponse = svc.communicate(sRcpXml);
//		String sResponse = com.britemoon.cps.imc.Service.communicate(ServiceType.RQUE_CAMP_DELETE,sCustId, sRcpXml);
		if (sResponse == null || sResponse.indexOf("<OK>OK</OK>") == -1)
		{
			String sErrMsg = "Error returned from RCP";
			throw new Exception(sErrMsg + "->RQUE_CAMP_DELETE.  Returned XML follows:\n" + sResponse);
		}
		else
		{
			bSuccess = true;
		}

		return bSuccess;
	}


	public static boolean deleteCampChildren(String sCustId, String sCampId) throws Exception
	{
		boolean bSuccess = false;
		ConnectionPool cp = null;
		Connection conn = null;

		int iResult = 0;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.deleteCampChildren()");

			PreparedStatement pstmt = null;

			try
			{
				String sSql = "EXEC usp_cque_delete_camp_children @cust_id=?, @camp_id=?";
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1,sCustId);
				pstmt.setString(2,sCampId);

				iResult = pstmt.executeUpdate();
				bSuccess = true;

			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return bSuccess;
	}

	public static boolean doDisposition
	(String sObjectType, String sObjectId, ApprovalRequest arRequest)
	throws Exception
	{
		boolean bSuccess = false;
		int iObjectType = Integer.parseInt(sObjectType);
		int iDispositionId = Integer.parseInt(arRequest.s_disposition_id);
//		System.out.println("in doDisposition..." + ApprovalDisposition.getDisplayName(iDispositionId));


		if (arRequest.s_disposition_id == null) {
			throw new Exception("Cannot process disposition.  Disposition does not exist for ApprovalRequest:" + arRequest.s_approval_request_id);
		} else if (iDispositionId == ApprovalDisposition.REJECT) {
			if (iObjectType == ObjectType.CAMPAIGN) {
				// get campaign's sampleset info
				ApprovalTask at = new ApprovalTask(arRequest.s_aprvl_id);
				if (at.s_camp_sample_flag == null || at.s_camp_sample_flag.equals("0")) {
//					System.out.println("about to deleteCamp for regular or Sample final camp:" + sObjectId);
					String sCampId = getCampId(arRequest.s_cust_id, sObjectId, null);
//					System.out.println("about to deleteCamp for samples final camp:" + sCampId);
					bSuccess = deleteCamp(arRequest.s_cust_id, sCampId);
					unlockCampAssets (sObjectId);
				} else if (at.s_camp_sample_flag.equals("1")) {
//					System.out.println("about to deleteCampSamples with originCampID:" + sObjectId);
					bSuccess = deleteCampSamples(arRequest.s_cust_id, sObjectId);
				}

			} else {
				bSuccess = setRejectedStatus(sObjectType, sObjectId,arRequest.s_cust_id);
			}

		} else if (iDispositionId == ApprovalDisposition.APPROVE)  {
			// for non-campaign, set status to Ready/Active/etc.
			// for campaign, set status to SentToRcp, set approval_flag to 1, and send to RCP
			if (iObjectType == ObjectType.CAMPAIGN) {
				// get campaign's sampleset info
				ApprovalTask at = new ApprovalTask(arRequest.s_aprvl_id);
				if (at.s_camp_sample_flag == null || at.s_camp_sample_flag.equals("0")) {
					String sCampId = getCampId(arRequest.s_cust_id, sObjectId, null);
					bSuccess = launchCamp(arRequest.s_cust_id, sCampId);
					unlockCampAssets (sObjectId);
				} else if (at.s_camp_sample_flag.equals("1")) {
					bSuccess = launchCampSamples(arRequest.s_cust_id, sObjectId);
				}
			} else {
				bSuccess = setApprovedStatus(sObjectType, sObjectId,arRequest.s_cust_id);
			}

		} else if (iDispositionId == ApprovalDisposition.EDITING)  {

			String sCampId = getCampId(arRequest.s_cust_id, sObjectId, null);
			bSuccess = setPendingEditsStatus(sObjectType, sCampId,arRequest.s_cust_id);
			unlockCampAssets (sObjectId);
		}

		return bSuccess;
	}


	public static boolean sendEditedCamp (String sCustId, String sCampId, String sApprovalFlag) throws Exception
	{
		boolean bSuccess = false;
//		System.out.println("in sendEditedCamp");

		ApprovalRequest arOrigRequest = getApprovalRequest(sCustId, "190", sCampId);

//		first send the campaign

		String sPendingEditsCampId = getPendingEditsCampId(sCustId, sCampId, null);
		bSuccess = deleteCamp(arOrigRequest.s_cust_id, sPendingEditsCampId);

		sendCamp(sCampId, 0, "send_pending_edits", null, null, null, sCustId, arOrigRequest.s_approver_id, sApprovalFlag);

//		next create a new dummy approval request and set it to approved

		setRequestsInactive(arOrigRequest.s_aprvl_id);
		ApprovalRequest arDummyRequest = new ApprovalRequest();
		arDummyRequest.s_aprvl_id = arOrigRequest.s_aprvl_id;
		arDummyRequest.s_approver_id = arOrigRequest.s_approver_id;
		arDummyRequest.s_requestor_id = arOrigRequest.s_requestor_id;
		arDummyRequest.s_aprvl_comment = "Sending edited campaign.";
		java.util.Calendar cal = java.util.Calendar.getInstance();
		String sNow = "" + cal.get(Calendar.YEAR) + "-" + (cal.get(Calendar.MONTH)+1) + "-" + cal.get(Calendar.DAY_OF_MONTH) + " " + cal.get(Calendar.HOUR_OF_DAY) + ":" + cal.get(Calendar.MINUTE);
		arDummyRequest.s_request_date = sNow;
		arDummyRequest.s_active_flag = "1";
		arDummyRequest.s_cust_id = arOrigRequest.s_cust_id;
		arDummyRequest.s_disposition_id = String.valueOf(ApprovalDisposition.APPROVE);
		arDummyRequest.s_disposition_date = sNow;
		arDummyRequest.save();
		WorkflowEmailUtil.sendRequestorEmail(arDummyRequest);

		return bSuccess;
	}

	private static boolean launchCamp (String sCustId, String sCampId) throws Exception {
		boolean bSuccess = false;
//		System.out.println("in launchCamp");

		Campaign camp = new Campaign(sCampId);
		if (camp.s_sample_id == null || camp.s_sample_id.equals("null") || camp.s_sample_id.equals("0")) {		// Single or Final campaign, just delete it
			bSuccess = launchSingleCamp(sCampId);
		}
		return bSuccess;
	}

	private static boolean launchCampSamples (String sCustId, String sOriginCampId) throws Exception {
		boolean bSuccess = false;
//		System.out.println("in launchCamp");

		CampSampleset cSampleset = new CampSampleset(sOriginCampId);
		String sSampleCampId = null;
		for (int i = 1; i <= Integer.parseInt(cSampleset.s_camp_qty); i++) {
			sSampleCampId = getCampId(sCustId,sOriginCampId,String.valueOf(i));
			bSuccess = launchSingleCamp(sSampleCampId);
		}
		return bSuccess;
	}

	private static boolean launchSingleCamp(String sCampId) throws Exception {
		boolean bSuccess = false;

//		createReadLink(sCampId);
		try
		{
			String sSql =
				" UPDATE cque_campaign SET" +
				" status_id = " + CampaignStatus.SENT_TO_RCP +
				", approval_flag = 1" +
				" WHERE camp_id = " + sCampId;

			BriteUpdate.executeUpdate(sSql);
//			System.out.println("in launchSingleCamp after db Update...going to doRcpSetup");

			CampSetupUtil.doRcpSetup(sCampId);

			bSuccess = true;

		}
		catch(Exception ex)
		{
			throw ex;
		}
		return bSuccess;
	}

	public static String sendCamp
	(String sCampId, int nSampleId, String sMode, String sNewFilterId, String sNewTestListId, String sDynamicRecipQty,
			String sCustId, String sUserId, String sApprovalFlag)
	throws Exception
	{

		//		sendCamp(sCampId, 0, "send_pending_edits", null, null, null, sCustId, arOrigRequest.s_approver_id, sApprovalFlag);
		String sSql = null;
		String sNewCampId = null;
//		System.out.println("in sendCamp of approval_request_send.jsp...campID:" + sCampId+";mode:"+sMode);

		try
		{
			// Clone is done within CampSetupUtil.prepareCamp4Setup();
			boolean bUseReservedCampId = false;
			if (("set_pending".equals(sMode) || "send_pending_edits".equals(sMode)) && nSampleId == 0)	// Only use reserved camp ID for Final or single campaign
				bUseReservedCampId = true;
//			System.out.println("in sendCamp...busereservedCampId:"+bUseReservedCampId);

			sNewCampId = CampSetupUtil.prepareCamp4Setup(sCampId, nSampleId, bUseReservedCampId);
//			System.out.println("after Util.prepCamp4Setup...newCampID:"+sNewCampId+";'oldcampid:"+sCampId);

			// === === ===

			if(nSampleId != 0)
			{
				sSql =
					" UPDATE cque_campaign" +
					" SET" +
					"	sample_id = " + nSampleId + "," +
					"	camp_name = camp_name + '" + " - Sample " + nSampleId + "'" +
					" WHERE camp_id = " + sNewCampId;
				BriteUpdate.executeUpdate(sSql);
			}

			// === === ===

			CampEditInfo cei = new CampEditInfo(sNewCampId);
			cei.s_creator_id = sUserId;
			cei.s_modifier_id = sUserId;
			cei.save();
//			System.out.println("after cei save.");

			// === === ===

			if("test".equals(sMode))
			{
				// set type, mode info for test and calculation test.
				sSql =
					" UPDATE cque_campaign " +
					" SET type_id = " + CampaignType.TEST +
					" WHERE camp_id = " + sNewCampId;
				BriteUpdate.executeUpdate(sSql);

				// for test, if the user chose a specific filter to use for the test, assign the new filter to the new campaign
				// also assign the test list containing only the approver to the new campaign.
				if (sNewFilterId != null) {			   // assign new filter ID to new campaign
					sSql = " UPDATE cque_campaign " +
					" SET filter_id = " + sNewFilterId +
					" WHERE camp_id = " + sNewCampId;

					BriteUpdate.executeUpdate(sSql);
				}
				if ( sNewTestListId != null ) {	    // assign Approver test list to new campaign
					CampList clNew = new CampList(sNewCampId);
					clNew.s_test_list_id = sNewTestListId;
					clNew.save();

					EmailList el = new EmailList(sNewTestListId);
					if (el.s_type_id.equals("7") && sDynamicRecipQty != null) {
//						System.out.println("created dynamic list...assigning Qty to campsendparams.");
						CampSendParam cspNew = new CampSendParam(sNewCampId);
						cspNew.s_test_recip_qty_limit = sDynamicRecipQty;
						cspNew.save();
					}
				}
				//System.out.println("after test-specific filter and test list ID mods.");

			}
			else if ("calc_only".equals(sMode))
			{
				sSql =
					" UPDATE cque_campaign " +
					" SET type_id = " + CampaignType.TEST + ", " +
					" mode_id = " + CampaignMode.CALC_ONLY +
					" WHERE camp_id = " + sNewCampId;
				BriteUpdate.executeUpdate(sSql);

			}
			//		System.out.println("after db update of campaign type");

			if ("test".equals(sMode) || "calc_only".equals(sMode)) {
				sSql =
					" UPDATE cque_schedule SET " +
					" start_date=getdate()," +
					" end_date = null," +
					" start_daily_time = null," +
					" end_daily_time = null," +
					" start_daily_weekday_mask = null" +
					" WHERE camp_id = " + sNewCampId;

				BriteUpdate.executeUpdate(sSql);

				sSql =
					" UPDATE cque_camp_send_param SET" +
					" delay=0," +
					" queue_date=getdate()," +
					" queue_daily_flag = null," +
					" queue_daily_time = null," +
					" queue_daily_weekday_mask = null" +
					" WHERE camp_id = " + sNewCampId;

				BriteUpdate.executeUpdate(sSql);
			}
			else
			{

				sSql =
					" UPDATE cque_schedule SET start_date=ISNULL(start_date, getdate())" +
					" WHERE camp_id = " + sNewCampId;

				BriteUpdate.executeUpdate(sSql);

				sSql =
					" UPDATE cque_camp_send_param SET" +
					" queue_date=ISNULL(queue_date, getdate()), delay=ISNULL(delay,0)" +
					" WHERE camp_id = " + sNewCampId;

				BriteUpdate.executeUpdate(sSql);
			}

			//System.out.println("after sched and csp db stuff.");

			// === === ===

			LinkedCamp lc = new LinkedCamp(sCampId);
			if(lc.s_form_id != null)
			{
				String sFilterId = createCampFormFilter(sCustId, lc);
				sSql =
					" UPDATE cque_campaign SET filter_id=" + sFilterId +
					" WHERE camp_id = " + sNewCampId;

				BriteUpdate.executeUpdate(sSql);
			}
//			System.out.println("after linked camp stuff.");

			// === === ===

			createReadLink(sNewCampId);

//			// === === ===

//			createExportSetup(sNewCampId, sExportName, sView, sDelimiter);

//			// === === ===

			try
			{

				if ("set_pending".equals(sMode)) {
					sSql =
						" UPDATE cque_campaign SET" +
						" status_id = " + CampaignStatus.PENDING_APPROVAL +
						//					", approval_flag = 0 " +
						" WHERE camp_id = " + sNewCampId;
				} else {
					sSql =
						" UPDATE cque_campaign SET" +
						" status_id = " + CampaignStatus.SENT_TO_RCP +
						((!"send_pending_edits".equals(sMode))?", approval_flag = 1 ":", approval_flag = "+ sApprovalFlag) +	// approval flag = 1 for test modes.
						" WHERE camp_id = " + sNewCampId;
				}

				BriteUpdate.executeUpdate(sSql);
//				System.out.println("after status setting.");

				if (!"set_pending".equals(sMode))  // only send test, calculate-only test, and send_pending_edits to RCP
					CampSetupUtil.doRcpSetup(sNewCampId);
				else
					if (nSampleId == 0) lockCampAssets(sCampId);

			}
			catch(Exception ex)
			{
				throw ex;
			}
		}
		catch(Exception ex)
		{
			sSql =
				" UPDATE cque_campaign" +
				" SET status_id = " + CampaignStatus.ERROR +
				" WHERE camp_id = " + sNewCampId;
			BriteUpdate.executeUpdate(sSql);
			throw ex;
		}

		return sNewCampId;
	}

	private static String createCampFormFilter(String sCustId, LinkedCamp lc) throws Exception
	{
		String sFilterId = null;

		if(lc.s_form_id == null) return sFilterId;
		if(lc.s_camp_id == null) return sFilterId;

		// === === ===

		FilterParam fpCamp = new FilterParam();
		fpCamp.s_param_id = "0";
		fpCamp.s_param_name = "camp_id";
		fpCamp.s_integer_value = lc.s_camp_id;

		FilterParam fpForm = new FilterParam();
		fpForm.s_param_id = "1";
		fpForm.s_param_name = "form_id";
		fpForm.s_integer_value = lc.s_form_id;

		FilterParams params = new FilterParams();
		params.add(fpCamp);
		params.add(fpForm);

		String sFilterName =
			"Campaign Form Filter for camp_id=" + lc.s_camp_id + " form_id=" + lc.s_form_id;

		com.britemoon.cps.tgt.Filter fCampForm = new com.britemoon.cps.tgt.Filter();
		fCampForm.s_filter_name = sFilterName;
		fCampForm.s_type_id = String.valueOf(FilterType.CAMPAIGN_FORM);
		fCampForm.s_status_id = String.valueOf(FilterStatus.NEW);
		fCampForm.s_cust_id = sCustId;

		fCampForm.m_FilterParams = params;

		FilterPart fp = new FilterPart();
		fp.m_ChildFilter = fCampForm;

		FilterParts parts = new FilterParts();
		parts.add(fp);

		com.britemoon.cps.tgt.Filter fTop = new com.britemoon.cps.tgt.Filter();
		fTop.s_filter_name = sFilterName;
		fTop.s_type_id = String.valueOf(FilterType.MULTIPART);
		fTop.s_cust_id = sCustId;
		fTop.s_status_id = String.valueOf(FilterStatus.NEW);

		fTop.m_FilterParts = parts;

		fTop.save();

		sFilterId = fTop.s_filter_id;

		// just to hide filter from ui
		String sSql =
			" UPDATE ctgt_filter" +
			" SET origin_filter_id = filter_id, usage_type_id = " + FilterUsageType.HIDDEN +
			" WHERE filter_id = " + sFilterId;
		BriteUpdate.executeUpdate(sSql);

		return sFilterId;
	}

	private static void createReadLink(String sCampId) throws Exception
	{
		Campaign camp = new Campaign(sCampId);

		Link link = new Link();
		link.s_link_name = "read_link";
		link.s_cont_id = camp.s_cont_id;
		link.s_camp_id = camp.s_camp_id;
		link.s_cust_id = camp.s_cust_id;
		link.s_href = null;
		link.s_origin_link_id = null;
		link.save();
	}

	private static void createExportSetup(String sCampId, String sExportName, String sView, String sDelimiter) throws Exception
	{
		if (sView == null) return;

		Campaign camp = new Campaign(sCampId);
		if (!camp.s_type_id.equals("5"))
		{
			if (camp.s_media_type_id == null || camp.s_media_type_id.equals("1"))
			{
				return;
			}
		}
		/* store export params for non-email campaign export */
		/* insert into cque_camp_export */
		String sSql = "DELETE FROM cque_camp_export_attr WHERE camp_id = " + camp.s_origin_camp_id;
		BriteUpdate.executeUpdate(sSql);

		sSql = "DELETE FROM cque_camp_export WHERE camp_id = " + camp.s_origin_camp_id;
		BriteUpdate.executeUpdate(sSql);

		sSql = "INSERT cque_camp_export (camp_id, export_name, delimiter) VALUES (" + camp.s_origin_camp_id + ",'" + sExportName + "','" + sDelimiter + "')";
		BriteUpdate.executeUpdate(sSql);

		/* insert into cque_camp_export_attr */
		StringTokenizer st = new StringTokenizer(sView, ",");
		int n=0;
		while (st.hasMoreTokens())
		{
			n++;
			sSql =
				" INSERT cque_camp_export_attr (camp_id, seq, attr_id)" +
				" VALUES (" + camp.s_origin_camp_id + "," + n + "," + st.nextToken() + ")";
			BriteUpdate.executeUpdate(sSql);
		}
	}

	public static String getCustCPSHost(String sCustId) throws Exception
	{
		String sCpsHost = null;

		// get the CPS host for this customer
		Vector vSvcs = Services.getByCust(ServiceType.CCPS_CUST_LOGIN, sCustId);
		com.britemoon.cps.imc.Service svc = (com.britemoon.cps.imc.Service)vSvcs.get(0);
		sCpsHost = svc.s_host;

		return sCpsHost;
	}

	public static String getApprovalUrl
	(int iObjectType, String sObjectId, String sCustId, boolean bAbsoluteRef)
	throws Exception
	{
		String sReturnUrl = null;
		String tempURL = null;

		// get the CPS host for this customer
		String sCpsHost = "http://" + getCustCPSHost(sCustId);

		switch (iObjectType)
		{
		case ObjectType.CAMPAIGN:
		{
			Campaign camp = new Campaign(sObjectId);

			String sOriginCampId = camp.s_origin_camp_id;;
			if (sOriginCampId == null) sOriginCampId = camp.s_camp_id;

			tempURL = "camp/camp_edit.jsp?camp_id="+ sOriginCampId + "&type_id=" + camp.s_type_id;
			if (bAbsoluteRef)
			{
				sReturnUrl = sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Camp&sec=1&url=" + URLEncoder.encode(tempURL, "UTF-8");
			}
			else
			{
				sReturnUrl = URLEncoder.encode(sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Camp&sec=1&url=" + URLEncoder.encode(tempURL, "UTF-8"), "UTF-8");
			}
			break;
		}
		case ObjectType.CONTENT:
		{
			tempURL = "cont/cont_edit.jsp?cont_id="+ sObjectId;
			if (bAbsoluteRef)
			{
				sReturnUrl =
					sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Cont&sec=1&url=" +
					URLEncoder.encode(tempURL, "UTF-8");
			}
			else
			{
				sReturnUrl = URLEncoder.encode(sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Cont&sec=1&url=" + URLEncoder.encode(tempURL, "UTF-8"), "UTF-8");
			}
			break;
		}
		case ObjectType.FILTER:
		{
			tempURL = "filter/filter_edit.jsp?filter_id="+sObjectId;
			if (bAbsoluteRef)
			{
				sReturnUrl = sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Data&sec=2&url=" + URLEncoder.encode(tempURL, "UTF-8");
			}
			else
			{
				sReturnUrl = URLEncoder.encode(sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Data&sec=2&url=" + URLEncoder.encode(tempURL, "UTF-8"), "UTF-8");
			}
			break;
		}
		case ObjectType.IMPORT:
		{
			tempURL = "import/import_details.jsp?import_id="+sObjectId;
			if (bAbsoluteRef)
			{
				sReturnUrl = sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Data&sec=1&url=" + URLEncoder.encode(tempURL, "UTF-8");
			}
			else
			{
				sReturnUrl = URLEncoder.encode(sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Data&sec=1&url=" + URLEncoder.encode(tempURL, "UTF-8"), "UTF-8");
			}
			break;
		}
		case ObjectType.USER:
		{
			tempURL = "setup/users/user_edit.jsp?user_id="+sObjectId;
			if (bAbsoluteRef)
			{
				sReturnUrl = sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Admn&sec=1&url=" + URLEncoder.encode(tempURL, "UTF-8");
			}
			else
			{
				sReturnUrl = URLEncoder.encode(sCpsHost + "/ccps/ui/jsp/index.jsp?tab=Admn&sec=1&url=" + URLEncoder.encode(tempURL, "UTF-8"), "UTF-8");
			}
			break;
		}
		}

		return sReturnUrl;
	}

	public static String getObjectName(int iObjectType, String sObjectId) throws Exception
	{
		String sObjectName = null;

		switch (iObjectType)
		{
		case ObjectType.CAMPAIGN:
		{
			Campaign camp = new Campaign(sObjectId);
			sObjectName = camp.s_camp_name;

			CampSampleset cSet = new CampSampleset();
			cSet.s_camp_id = camp.s_origin_camp_id;
			if (cSet.retrieve() > 0)
			{	    // sampleset campaign
				if (camp.s_sample_id == null)
					sObjectName += " (final campaign)";
				else
					sObjectName += " (all samples)";
			}
			break;
		}
		case ObjectType.CONTENT:
		{
			Content cont = new Content(sObjectId);
			sObjectName = cont.s_cont_name;
			break;
		}
		case ObjectType.FILTER:
		{
			Filter filt = new Filter(sObjectId);
			sObjectName = filt.s_filter_name;
			break;
		}
		case ObjectType.IMPORT:
		{
			ImportBean imp = new ImportBean(sObjectId);
			sObjectName = imp.getImportName();
			break;
		}
		case ObjectType.USER:
		{
			User user = new User(sObjectId);
			sObjectName = user.s_user_name + " " + user.s_last_name;
			break;
		}
		}

		return sObjectName;
	}

	public static int getImportDisposition(String sObjectId) throws Exception
	{
		int iDisposition = 0;
		ApprovalRequest arRequest = null;

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("WorkflowUtil.getImportDisposition()");

			PreparedStatement pstmt = null;
			ResultSet rs = null;

			try
			{
				String sSql =
					" SELECT ar.approval_request_id " +
					" FROM ccps_aprvl_request ar, ccps_aprvl_task at " +
					" WHERE at.object_type = ? AND " +
					" at.object_id = ? AND " +
					" ar.aprvl_id = at.approval_id AND " +
					" ar.active_flag = 1 AND " +
					" at.active_flag = 1";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setInt(1, ObjectType.IMPORT);
				pstmt.setString(2, sObjectId);

				rs = pstmt.executeQuery();
				if (rs.next())
				{
					String sAprvlRequestId = rs.getString(1);
					if (sAprvlRequestId != null)
					{
						arRequest = new ApprovalRequest(sAprvlRequestId);
					}
				}
				if (arRequest != null)
				{
					// check disposition
					if (arRequest.s_disposition_id != null)
						iDisposition = Integer.parseInt(arRequest.s_disposition_id);
				}
			}
			catch (Exception ex) { throw ex; }
			finally { if (pstmt!=null) pstmt.close(); }
		}
		catch (Exception ex) { throw ex; }
		finally { if ( conn != null ) cp.free(conn); }

		return iDisposition;
	}

	public static boolean isImportPending(String sObjectId) throws Exception
	{
		return (getImportDisposition(sObjectId) == 0);
	}

	public static void lockCampAssets (String sCampId) throws Exception
	{
		Campaign camp = new Campaign(sCampId);

		Filter filter = new Filter(camp.s_filter_id);
		filter.s_aprvl_status_flag = "-1";
		filter.save();

		Content cont = new Content(camp.s_cont_id);
		cont.s_status_id = String.valueOf(ContStatus.PENDING_CAMP);
		cont.save();

		ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
		if (cei.s_wizard_id != null)
		{
			//Lock the Template
			/*String sDetailXML =
				"<template>" +
					"<cust_id>"+ cont.s_cust_id +"</cust_id>" +
					"<content_id>"+cei.s_wizard_id+"</content_id>" +
					"<action>lock</action>" +
				"</template>";*/

			String sStatus = "'locked'";

			String sSql = 
				"UPDATE ctm_pages" +
				" SET status = " + sStatus +
				" WHERE content_id = " + cei.s_wizard_id +
				" AND customer_id = " + cont.s_cust_id;
			BriteUpdate.executeUpdate(sSql);

		}
	}

	public static void unlockCampAssets (String sCampId) throws Exception
	{
		Campaign camp = new Campaign(sCampId);

		Filter filter = new Filter(camp.s_filter_id);
		filter.s_aprvl_status_flag = "1";
		filter.save();

		Content cont = new Content(camp.s_cont_id);
		cont.s_status_id = String.valueOf(ContStatus.READY);
		cont.save();

		ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
		if (cei.s_wizard_id != null)
		{
			//UnLock the Template
			/*String sDetailXML =
				"<template>" +
					"<cust_id>"+ cont.s_cust_id +"</cust_id>" +
					"<content_id>"+cei.s_wizard_id+"</content_id>" +
					"<action>unlock</action>" +
				"</template>";*/

			String sStatus = "'committed'";
			String sSql = 
				"UPDATE ctm_pages" +
				" SET status = " + sStatus +
				" WHERE content_id = " + cei.s_wizard_id +
				" AND customer_id = " + cont.s_cust_id;
			BriteUpdate.executeUpdate(sSql);

		}
	}

	public static boolean getTemplateAppovalFlag(String sCampId) throws Exception {
		boolean templateRequiresApproval = false;
		String templateApprovalFlag = null;
		Campaign camp = new Campaign(sCampId);
		Content cont = new Content(camp.s_cont_id);
		ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
		if (cei.s_wizard_id != null) {
			ConnectionPool cp = ConnectionPool.getInstance();
			Connection conn = null;
			try
			{
				conn = cp.getConnection("WorkflowUtil.getTemplateApprovalFlag");
				Statement stmt = null;
				try
				{

					stmt = conn.createStatement();

					String sSql =
						" SELECT tpl.approval_flag FROM ctm_templates tpl " + 
						" INNER JOIN ctm_pages pgs ON pgs.template_id = tpl.template_id " + 
						"	INNER JOIN ccnt_cont_edit_info cei ON pgs.content_id = cei.wizard_id " + 
						" where cei.wizard_id = " + cei.s_wizard_id; 

					ResultSet rs = stmt.executeQuery(sSql);
					while (rs.next())
					{
						templateApprovalFlag = rs.getString(1);
					}
				} catch (SQLException sqle) {
				} finally { if (stmt!=null) stmt.close(); }
			}
			catch(SQLException ex) { 
				logger.error(ex.getMessage(), ex);
			} catch (Exception ex) {
				logger.error(ex.getMessage(), ex);
			}
			finally { if (conn!=null) cp.free(conn); }

			if ((templateApprovalFlag == null) || (templateApprovalFlag.equals("0"))) {
				templateRequiresApproval = false;
			} else {
				templateRequiresApproval = true;
			}

		} else {
			// The content didn't come from a template if the wizard_id flag = null;
			templateRequiresApproval = false;
		}

		return templateRequiresApproval;
	}

	/**
	 * Returns the offers whose last send date is before the campaign start date.
	 * @param sCampId - the campaign id whose schedule is to be tested against the offers' last send date
	 * @return Vector of Hashmaps describing the offers whose last send date is earlier than the campaign schedule.
	 * @throws Exception
	 */
	public static Vector getOffersLastSendDate(String sCampId) throws Exception {
		Vector offers = new Vector();
		Vector cantSendOffers = new Vector();
		
		Campaign camp = new Campaign(sCampId);
		Content cont = new Content(camp.s_cont_id);
		ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
		if (cei.s_wizard_id != null) {
			ConnectionPool cp = ConnectionPool.getInstance();
			Connection conn = null;
			try
			{
				conn = cp.getConnection("WorkflowUtil.getOffersLastSendDate");
				Statement stmt = null;
				try
				{

					stmt = conn.createStatement();
					// get the offers associated with this content via the content's wizard_id.
					String sSql =
						" select ofr.offer_id, ofr.cust_id, ofr.name, ofr.last_send_date from ctm_offer ofr " +
						" inner join ctm_page_values pgv on (pgv.n_value = ofr.offer_id) " +
						" inner join ctm_inputs inp on pgv.input_id = inp.input_id " + 
						" inner join ctm_pages pgs on pgs.content_id = pgv.content_id " + 
						"	inner join ccnt_cont_edit_info cei on pgs.content_id = cei.wizard_id " + 
						" where inp.type in ('bigoffer', 'smalloffer') and cei.wizard_id = " + cei.s_wizard_id;

					ResultSet rs = stmt.executeQuery(sSql);
					while (rs.next())
					{
						HashMap offer = new HashMap();
						offer.put("offer_id", rs.getString(1));
						offer.put("cust_id", rs.getString(2));
						offer.put("offer_name", rs.getString(3));
						String offerDate = rs.getString(4);
						offer.put("last_send_date", offerDate);
						offers.add(offer);								
					}
				} catch (SQLException sqle) {
				} finally { if (stmt!=null) stmt.close(); }
			}
			catch(SQLException ex) { 
				logger.error(ex.getMessage(), ex);
			} catch (Exception ex) {
				logger.error(ex.getMessage(), ex);
			}
			finally { if (conn!=null) cp.free(conn); }
			
			// go through each offer and see if the offer's last_send_date 
			// is less than or equal to the campaign's send date.
			
			DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			Date dToday = new Date();
			Date dCampStartDate = new Date();
			Schedule campSchedule = new Schedule(sCampId);

			if (campSchedule.s_start_date != null ) {
				dCampStartDate = sdf.parse(campSchedule.s_start_date);
			} else {
				String sCampStartDate = new String(sdf.format(dToday));	
				dCampStartDate = sdf.parse(sCampStartDate);
			}
			
			Iterator it = offers.iterator();
			while (it.hasNext()) {
				HashMap offer = (HashMap) it.next();
				Date offerLastSendDate = sdf.parse((String) offer.get("last_send_date"));
				if (offerLastSendDate.before(dCampStartDate)) {
					cantSendOffers.add(offer);
				}
			}
			return cantSendOffers;	

		} else {
			// The content didn't come from a template if the wizard_id flag = null;
			return cantSendOffers;
		}
	}
}
