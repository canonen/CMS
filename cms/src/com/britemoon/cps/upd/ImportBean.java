package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImportBean implements Serializable {

	// === Properties ===

	private String sImportId = null;
	private String sBatchId = null;
	private String sImportName = null;
	private String sStatusId = null;
	private String sImportDate = null;
	private String sFieldSeparator = null;
	private String sFirstRow = null;
	private String sImportFile = null;
	private String sUpdRuleId = null;
	private String sImportUrl = null;
	private String sFullNameFlag = null;
	private String sEmailTypeFlag = null;
	private String sTypeId = null;
	private String sUpdHierarchyId = null;
	private String sAutoCommitFlag = null;
	private String sMultiValueFieldSeparator = null;
	private String sBatchName = null;

	private String sTotRows = null;
	private String sBadRows = null;
	private String sTotFileRecips = null;
	private String sBadEmails = null;
	private String sWarningRecips = null;
	private String sFileDups = null;
	private String sTotRecips = null;
	private String sNewRecips = null;
	private String sDupRecips = null;
	private String sNumCommitted = null;
	private String sLeftToCommit = null;
	private String sErrorMessage = null;
	private static Logger logger = Logger.getLogger(ImportBean.class.getName());	

	// === Constructors ===

	public ImportBean()
	{
	}
	
	public ImportBean(String sImportId) throws Exception
	{
		setImportId(sImportId);
		retrieve();
	}

     // === Getters ===

     public String getImportId () {
          return sImportId;
     }

     public String getBatchId () {
          return sBatchId;
     }

     public String getImportName () {
          return sImportName;
     }

     public String getStatusId () {
          return sStatusId;
     }

     public String getImportDate () {
          return sImportDate;
     }

     public String getFieldSeparator () {
          return sFieldSeparator;
     }

     public String getFirstRow () {
          return sFirstRow;
     }

     public String getImportFile () {
          return sImportFile;
     }

     public String getUpdRuleId () {
          return sUpdRuleId;
     }

     public String getImportUrl () {
          return sImportUrl;
     }

     public String getFullNameFlag () {
          return sFullNameFlag;
     }

     public String getEmailTypeFlag () {
          return sEmailTypeFlag;
     }

     public String getTypeId () {
          return sTypeId;
     }

     public String getUpdHierarchyId () {
          return sUpdHierarchyId;
     }

     public String getAutoCommitFlag () {
          return sAutoCommitFlag;
     }

     public String getMultiValueFieldSeparator () {
          return sMultiValueFieldSeparator;
     }

     public String getBatchName () {
          return sBatchName;
     }


     public String getTotRows () {
          return sTotRows;
     }
     public String getBadRows () {
          return sBadRows;
     }
     public String getTotFileRecips () {
          return sTotFileRecips;
     }
     public String getBadEmails () {
          return sBadEmails;
     }
     public String getWarningRecips () {
          return sWarningRecips;
     }
     public String getFileDups () {
          return sFileDups;
     }
     public String getTotRecips () {
          return sTotRecips;
     }
     public String getNewRecips () {
          return sNewRecips;
     }
     public String getDupRecips () {
          return sDupRecips;
     }
     public String getNumCommitted () {
          return sNumCommitted;
     }
     public String getLeftToCommit () {
          return sLeftToCommit;
     }
     public String getErrorMessage () {
          return sErrorMessage;
     }




     // === Setters ===
     public void setImportId (String aImportId ) {
          sImportId = aImportId;
     }

     public void setBatchId (String aBatchId ) {
          sBatchId = aBatchId;
     }

     public void setImportName (String aImportName ) {
          sImportName = aImportName;
     }

     public void setStatusId (String aStatusId ) {
          sStatusId = aStatusId;
     }

     public void setImportDate (String aImportDate ) {
          sImportDate = aImportDate;
     }

     public void setFieldSeparator (String aFieldSeparator ) {
          sFieldSeparator = aFieldSeparator;
     }

     public void setFirstRow (String aFirstRow ) {
          sFirstRow = aFirstRow;
     }

     public void setImportFile (String aImportFile ) {
          sImportFile = aImportFile;
     }

     public void setUpdRuleId (String aUpdRuleId ) {
          sUpdRuleId = aUpdRuleId;
     }

     public void setImportUrl (String aImportUrl ) {
          sImportUrl = aImportUrl;
     }
     

     public void setFullNameFlag (String aFullNameFlag ) {
          sFullNameFlag = aFullNameFlag;
     }

     public void setEmailTypeFlag (String aEmailTypeFlag ) {
          sEmailTypeFlag = aEmailTypeFlag;
     }

     public void setTypeId (String aTypeId ) {
          sTypeId = aTypeId;
     }

     public void setUpdHierarchyId (String aUpdHierarchyId ) {
          sUpdHierarchyId = aUpdHierarchyId;
     }

     public void setAutoCommitFlag (String aAutoCommitFlag ) {
          sAutoCommitFlag = aAutoCommitFlag;
     }

     public void setMultiValueFieldSeparator (String aMultiValueFieldSeparator ) {
          sMultiValueFieldSeparator = aMultiValueFieldSeparator;
     }

     public void setBatchName (String aBatchName ) {
          sBatchName = aBatchName;
     }

     public void setTotRows (String aTotRows ) {
          sTotRows = aTotRows;
     }
     public void setBadRows (String aBadRows ) {
          sBadRows = aBadRows;
     }
     public void setTotFileRecips (String aTotFileRecips ) {
          sTotFileRecips = aTotFileRecips;
     }
     public void setBadEmails (String aBadEmails ) {
          sBadEmails = aBadEmails;
     }
     public void setWarningRecips (String aWarningRecips ) {
          sWarningRecips = aWarningRecips;
     }
     public void setFileDups (String aFileDups ) {
          sFileDups = aFileDups;
     }
     public void setTotRecips (String aTotRecips ) {
          sTotRecips = aTotRecips;
     }
     public void setNewRecips (String aNewRecips ) {
          sNewRecips = aNewRecips;
     }
     public void setDupRecips (String aDupRecips ) {
          sDupRecips = aDupRecips;
     }
     public void setNumCommitted (String aNumCommitted ) {
          sNumCommitted = aNumCommitted;
     }
     public void setLeftToCommit (String aLeftToCommit ) {
          sLeftToCommit = aLeftToCommit;
     }
     public void setErrorMessage (String aErrorMessage ) {
          sErrorMessage = aErrorMessage;
     }


     private void setAll (ResultSet rs) throws SQLException {

          if (rs != null) {
               setImportId(rs.getString(1));
               setBatchId (rs.getString(2) );
               setImportName (rs.getString(3) );
               setStatusId (rs.getString(4) );
               setImportDate (rs.getString(5) );
               setFieldSeparator (rs.getString(6) );
               setFirstRow (rs.getString(7) );
               setImportFile (rs.getString(8) );
               setUpdRuleId (rs.getString(9) );
               setImportUrl (rs.getString(10) );
               setFullNameFlag (rs.getString(11) );
               setEmailTypeFlag (rs.getString(12) );
               setTypeId (rs.getString(13) );
               setUpdHierarchyId (rs.getString(14) );
               setAutoCommitFlag (rs.getString(15) );
               setMultiValueFieldSeparator (rs.getString(16) );
               setBatchName (rs.getString(17) );
               setTotRows (rs.getString(18) );
               setBadRows (rs.getString(19) );
               setTotFileRecips (rs.getString(20) );
               setBadEmails (rs.getString(21) );
               setWarningRecips (rs.getString(22) );
               setFileDups (rs.getString(23) );
               setTotRecips (rs.getString(24) );
               setNewRecips (rs.getString(25) );
               setDupRecips (rs.getString(26) );
               setNumCommitted (rs.getString(27) );
               setLeftToCommit (rs.getString(28) );
               setErrorMessage (rs.getString(29) );
          }
     }

	// === DB Methods ===
	private String sRetrieveSql = "SELECT " +
                    "i.import_id , " +
	               "i.batch_id , " +
	               "i.import_name , " +
	               "i.status_id , " +
	               "i.import_date , " +
	               "i.field_separator , " +
	               "i.first_row, " +
	               "i.import_file , " +
	               "i.upd_rule_id , " +
	               "i.import_url, " +
	               "i.full_name_flag , " +
	               "i.email_type_flag , " +
	               "i.type_id , " +
	               "i.upd_hierarchy_id , " +
	               "i.auto_commit_flag , " +
	               "i.multi_value_field_separator, " +
                    "b.batch_name, " +
                    "s.tot_rows, s.bad_rows, s.tot_file_recips, s.bad_emails, s.warning_recips, s.file_dups," +
                    "s.tot_recips, s.new_recips, s.dup_recips, s.num_committed, s.left_to_commit, s.error_message " +
          " FROM cupd_import i " +
          " INNER JOIN cupd_batch b ON i.batch_id = b.batch_id " +
          " LEFT OUTER JOIN cupd_import_statistics s ON i.import_id = s.import_id " +
         " WHERE i.import_id = ? ";

	private void retrieve() throws Exception
	{
          PreparedStatement	pstmt			= null;
          ResultSet			rs				= null; 
          ConnectionPool		cp				= null;
          Connection			conn 			= null;
		int nReturnCode = 0;
          //CampSample campSample = new CampSample(sCampId, sSampleId);

          try {

               cp = ConnectionPool.getInstance();
               conn = cp.getConnection("ImportBean");

               //System.out.println("SQL to retrieve Import info:");
               //System.out.println(sRetrieveSql);

               pstmt = conn.prepareStatement(sRetrieveSql);
               pstmt.setString(1, sImportId);

               rs = pstmt.executeQuery();
               if (rs.next())
               {
                    setAll(rs);
               }
               rs.close();
               
          } catch (SQLException sqle) 
		  {
          	   logger.error("SQL Exception thrown while attempting to retrieve Sample Bean.", sqle);
//             ("SQL Exception thrown while attempting to retrieve Sample Bean.");
               throw sqle;
          } finally {
               if (pstmt != null) {
                    pstmt.close();
               }
               cp.free(conn);
          }
		
	}


	// === Other Methods ===
}
