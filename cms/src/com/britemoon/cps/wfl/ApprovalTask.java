package com.britemoon.cps.wfl;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.jtk.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ApprovalTask extends BriteObject
{
	// === Properties ===

	public String s_approval_id = null;
	public String s_object_id = null;
	public String s_next_tier_aprvl_id = null;
	public String s_object_type = null;
	public String s_cust_id = null;
	public String s_group_id = null;
	public String s_camp_sample_flag = null;
	public String s_active_flag = null;
	private static Logger logger = Logger.getLogger(ApprovalTask.class.getName());


	// === Constructors ===

	public ApprovalTask()
	{
	}

     public ApprovalTask(String sApprovalId) throws Exception {
          s_approval_id = sApprovalId;
          retrieve();
     }
	
	public ApprovalTask(Element e) throws Exception
	{
		fromXml(e);
	}



	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT " +
               " approval_id,  " +
               " object_id,  " +
               " next_tier_aprvl_id,  " +
               " object_type,  " +
               " cust_id,  " +
               " group_id,  " +
               " camp_sample_flag, " +
               " active_flag " +
               " FROM  ccps_aprvl_task " +
               " WHERE approval_id = ?";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_approval_id);

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
          s_approval_id = rs.getString(1);
          s_object_id = rs.getString(2);
          s_next_tier_aprvl_id = rs.getString(3);
          s_object_type = rs.getString(4);
          s_cust_id = rs.getString(5);
          s_group_id = rs.getString(6);
          s_camp_sample_flag = rs.getString(7);
          s_active_flag = rs.getString(8);
	}
	
	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_approval_task_save" +
		" @approval_id=?, @object_id=?, @next_tier_aprvl_id=?, @object_type=?, @cust_id=?,  @group_id=?, @camp_sample_flag=?, @active_flag=?";

	public String getSaveSql() { return m_sSaveSql; }


	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_approval_id);
		pstmt.setString(2, s_object_id);
		pstmt.setString(3, s_next_tier_aprvl_id);
		pstmt.setString(4, s_object_type);
		pstmt.setString(5, s_cust_id);
		pstmt.setString(6, s_group_id);
		pstmt.setString(7, s_camp_sample_flag);
		pstmt.setString(8, s_active_flag);

		ResultSet rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_approval_id = rs.getString(1);
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
		" DELETE FROM ccps_aprvl_task" +
		" WHERE" +
		"	(approval_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_approval_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "approval_task";
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



}


