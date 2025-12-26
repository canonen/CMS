package com.britemoon.cps.wfl;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.jtk.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ApprovalPath extends BriteObject
{
	// === Properties ===

	public String s_approval_path_id = null;
	public String s_cust_id = null;
	public String s_group_id = null;
	public String s_next_tier_cust_id = null;
	public String s_next_tier_group_id = null;

     public Vector m_vCusts = null;
     public Vector m_vGroups = null;
     private static Logger logger = Logger.getLogger(ApprovalPath.class.getName());


	// === Constructors ===

	public ApprovalPath()
	{
	}

     public ApprovalPath(String sApprovalPathId) throws Exception {
          s_approval_path_id = sApprovalPathId;
          retrieve();
     }
	
	public ApprovalPath(Element e) throws Exception
	{
		fromXml(e);
	}



	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT " +
               " approval_path_id, " +
               " cust_id, " +
               " group_id,  " +
               " next_tier_cust_id,  " +
               " next_tier_grp_id " +
               " FROM  ccps_aprvl_path " +
               " WHERE approval_path_id = ?";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_approval_path_id);

		ResultSet rs = pstmt.executeQuery();
		if (rs.next())
		{
			getPropsFromResultSetRow(rs);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public void getPropsFromResultSetRow(ResultSet rs) throws Exception
	{
          s_approval_path_id = rs.getString(1);
          s_cust_id = rs.getString(2);
          s_group_id = rs.getString(3);
          s_next_tier_cust_id = rs.getString(4);
          s_next_tier_group_id = rs.getString(5);
	}
	
	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_approval_path_save " +
		" @approval_path_id=?, @cust_id=?, @group_id=?, @next_tier_cust_id=?,  @next_tier_group_id=?";

	public String getSaveSql() { return m_sSaveSql; }


	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_approval_path_id);
		pstmt.setString(2, s_cust_id);
		pstmt.setString(3, s_group_id);
		pstmt.setString(4, s_next_tier_cust_id);
		pstmt.setString(5, s_next_tier_group_id);

		ResultSet rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_approval_path_id = rs.getString(1);
               nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	 public int saveChildren(Connection conn) throws Exception
	 {
		return 1;
	 }

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_approval_path" +
		" WHERE" +
		"	(approval_path_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_approval_path_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "approval_path";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
	}
	
	public void appendChildrenToXml(Element e)
	{
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
	}

	public void getChildrenFromXml(Element e) throws Exception
	{

	}

	// === Other Methods ===

     public void getCustPath () throws Exception {

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ApprovalPath.getCustPath()");

			PreparedStatement pstmt = null;

               String sCurCustId =  null;
               String sNextCustId =  null;

			try 
			{
				ResultSet rs = null;

				String sSql = "SELECT cust_id, next_tier_cust_id " +
                                             " FROM  ccps_aprvl_path  " +
                                             " WHERE cust_id = ? ";
				pstmt = conn.prepareStatement(sSql);
                    pstmt.setString(1,s_cust_id);

				rs = pstmt.executeQuery();

				if (rs.next())
				{
                         m_vCusts = new Vector();
                         sCurCustId = rs.getString(1);
                         sNextCustId = rs.getString(2);
                         m_vCusts.add(sCurCustId);
                         while (sNextCustId != null) {
                              sCurCustId = sNextCustId;
                              m_vCusts.add(sCurCustId);
                              pstmt.setString(1,sCurCustId);
                              rs = pstmt.executeQuery();
                              if (rs.next()) {
                                   sCurCustId = rs.getString(1);
                                   sNextCustId = rs.getString(2);
                              }
                         }
				}
			}
			catch (Exception ex) {
				throw ex;
			}
			finally {
				if (pstmt!=null) pstmt.close();
			}
		}
		catch (Exception ex) {
			throw ex;
		}
		finally {
			if (conn != null ) cp.free(conn);
		}

     }

     public void getGroupPath () throws Exception {

		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ApprovalPath.getGroupPath()");

			PreparedStatement pstmt = null;

               String sCurGroupId =  null;
               String sNextGroupId =  null;

			try 
			{
				ResultSet rs = null;

				String sSql = "SELECT group_id, next_tier_group_id " +
                                             " FROM  ccps_aprvl_path  " +
                                             " WHERE group_id = ? ";
				pstmt = conn.prepareStatement(sSql);
                    pstmt.setString(1,s_group_id);

				rs = pstmt.executeQuery();

				if (rs.next())
				{
                         m_vGroups = new Vector();
                         sCurGroupId = rs.getString(1);
                         sNextGroupId = rs.getString(2);
                         m_vGroups.add(sCurGroupId);
                         while (sNextGroupId != null) {
                              sCurGroupId = sNextGroupId;
                              m_vGroups.add(sCurGroupId);
                              pstmt.setString(1,sCurGroupId);
                              rs = pstmt.executeQuery();
                              if (rs.next()) {
                                   sCurGroupId = rs.getString(1);
                                   sNextGroupId = rs.getString(2);
                              }
                         }
				}
			}
			catch (Exception ex) {
				throw ex;
			}
			finally {
				if (pstmt!=null) pstmt.close();
			}
		}
		catch (Exception ex) {
			throw ex;
		}
		finally {
			if (conn != null ) cp.free(conn);
		}

     }


}


