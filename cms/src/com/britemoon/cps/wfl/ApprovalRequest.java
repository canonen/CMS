package com.britemoon.cps.wfl;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ApprovalRequest extends BriteObject
{
	// === Properties ===

	public String s_approval_request_id = null;
	public String s_aprvl_id = null;
	public String s_disposition_id = null;
	public String s_requestor_id = null;
	public String s_approver_id = null;
	public String s_request_date = null;
	public String s_disposition_date = null;
	public String s_active_flag = null;
	public String s_request_comment = null;
	public String s_aprvl_comment = null;
	public String s_cust_id = null;
	public String s_email_sent_date = null;
    private static Logger logger = Logger.getLogger(ApprovalRequest.class.getName());	


	// === Constructors ===

	public ApprovalRequest()
	{
	}

     public ApprovalRequest(String sApprovalRequestId) throws Exception {
          s_approval_request_id = sApprovalRequestId;
          retrieve();
     }
	
	public ApprovalRequest(Element e) throws Exception
	{
		fromXml(e);
	}



	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT " +
          " approval_request_id, " +
          " aprvl_id, " +
          " disposition_id, " +
          " requestor_id, " +
          " approver_id, " +
          " request_date, " +
          " disposition_date, " +
          " active_flag, " +
          " request_comment, " +
          " aprvl_comment, " +
          " cust_id, " +
          " email_sent_date " +
          " FROM  ccps_aprvl_request " +
               " WHERE approval_request_id = ?";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_approval_request_id);

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
          s_approval_request_id = rs.getString(1);
          s_aprvl_id = rs.getString(2);
          s_disposition_id = rs.getString(3);
          s_requestor_id = rs.getString(4);
          s_approver_id = rs.getString(5);
          s_request_date = rs.getString(6);
          s_disposition_date = rs.getString(7);
          s_active_flag = rs.getString(8);
          s_request_comment = rs.getString(9);
          s_aprvl_comment = rs.getString(10);
          s_cust_id = rs.getString(11);
          s_email_sent_date = rs.getString(12);
	}
	
	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_approval_request_save" +
		" @approval_request_id=?, @aprvl_id=?, @disposition_id=?, @requestor_id=?, @approver_id=?, " +
          " @request_date=?, @disposition_date=?, @active_flag=?, @request_comment=?, @aprvl_comment=?, " +
          " @cust_id=?, @email_sent_date=?";

	public String getSaveSql() { return m_sSaveSql; }


	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_approval_request_id);
		pstmt.setString(2, s_aprvl_id);
		pstmt.setString(3, s_disposition_id);
		pstmt.setString(4, s_requestor_id);
		pstmt.setString(5, s_approver_id);
		pstmt.setString(6, s_request_date);
		pstmt.setString(7, s_disposition_date);
		pstmt.setString(8, s_active_flag);
		pstmt.setString(9, s_request_comment);
		pstmt.setString(10, s_aprvl_comment);
		pstmt.setString(11, s_cust_id);
		pstmt.setString(12, s_email_sent_date);

		ResultSet rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_approval_request_id = rs.getString(1);
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
		" DELETE FROM ccps_approval_request" +
		" WHERE" +
		"	(approval_request_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_approval_request_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "approval_request";
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


