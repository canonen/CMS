package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class CampSampleBean implements Serializable {

	// === Properties ===

	private String sCampId = null;
	private String sSampleId = null;
	private String sFromName = null;
	private String sFromAddressId = null;
     private String sFromAddress = null;
	private String sSubjectHtml = null;
	private String sSubjectText = null;
	private String sSubjectAol = null;
	private String sContId = null;
     private String sContName = null;
	private String sSendDate = null;
	private String sTestListId = null;
     private String sTestListName = null;
     private boolean bTested = false;
     private String sLastTestDate = null;
 	private String sReplyTo = null;
	private String sFilterId = null;
	private String sPriority = null;
     private static Logger logger = Logger.getLogger(CampSampleBean.class.getName());


	// === Constructors ===

	public CampSampleBean()
	{
	}
	
	public CampSampleBean(String sCampId, String sSampleId) throws Exception
	{
		setCampId(sCampId);
		setSampleId(sSampleId);
		retrieve();
	}

     // === Getters ===

     public String getCampId () {
          return sCampId;
     }

     public String getSampleId () {
          return sSampleId;
     }

     public String getFromName () {
          return sFromName;
     }

     public String getFromAddressId () {
          return sFromAddressId;
     }

     public String getFromAddress () {
          return sFromAddress;
     }

     public String getSubjectHtml () {
          return sSubjectHtml;
     }

     public String getSubjectText () {
          return sSubjectText;
     }

     public String getSubjectAol () {
          return sSubjectAol;
     }

     public String getContId () {
          return sContId;
     }

     public String getContName () {
          return sContName;
     }

     public String getSendDate () {
          return sSendDate;
     }

     public String getTestListId () {
          return sTestListId;
     }

     public String getTestListName () {
          return sTestListName;
     }

     public boolean getTested () {
          return bTested;
     }

     public String getLastTestDate () {
          return sLastTestDate;
     }
     
     public String getReplyTo () {
         return sReplyTo;
     }
     
     public String getFilterId () {
         return sFilterId;
     }
     
     public String getPriority () {
         return sPriority;
     }

     // === Setters ===
     public void setCampId (String aCampId ) {
          sCampId = aCampId;
     }

     public void setSampleId (String aSampleId ) {
          sSampleId = aSampleId;
     }

     public void setFromName (String aFromName) {
          sFromName = aFromName;
     }

     public void setFromAddressId (String aFromAddressId ) {
          sFromAddressId = aFromAddressId;
     }

     public void setFromAddress (String aFromAddress ) {
          sFromAddress = aFromAddress;
     }

     public void setSubjectHtml (String aSubjectHtml ) {
          sSubjectHtml = aSubjectHtml;
     }

     public void setSubjectText (String aSubjectText) {
          sSubjectText = aSubjectText;
     }

     public void setSubjectAol (String aSubjectAol ) {
          sSubjectAol = aSubjectAol;
     }

     public void setContId (String aContId ) {
          sContId = aContId;
     }

     public void setContName (String aContName ) {
          sContName = aContName;
     }

     public void setSendDate (String aSendDate) {
          sSendDate = aSendDate;
     }

     public void setTestListId (String aTestListId ) {
          sTestListId = aTestListId;
     }

     public void setTestListName (String aTestListName ) {
          sTestListName = aTestListName;
     }

     public void setTested (boolean aTested) {
          bTested = aTested;
     }

     public void setLastTestDate (String aLastTestDate) {
          sLastTestDate = aLastTestDate;
     }

     public void setReplyTo (String aReplyTo) {
         sReplyTo = aReplyTo;
     }
     
     public void setFilterId (String aFilterId) {
         sFilterId = aFilterId;
     }
     
     public void setPriority (String aPriority) {
         sPriority = aPriority;
     }
	
     private void setAll (ResultSet rs) throws SQLException {

          String sTmpSampAddr = null;
          String sTmpAddrAddr = null;

          if (rs != null) {
               /* System.out.println("ResultSet columns.");
               ResultSetMetaData rsmdTmp = rs.getMetaData();
               System.out.println("Number of columns:"+String.valueOf(rsmdTmp.getColumnCount()));
               for (int i = 1;i <= rsmdTmp.getColumnCount();i++) {
                    System.out.println(rsmdTmp.getColumnName(i));
               }
               */
               setCampId(String.valueOf(rs.getInt("camp_id")));
               setSampleId(String.valueOf(rs.getInt("sample_id")));
               setFromName(rs.getString("from_name")  );
               setFromAddressId(String.valueOf(rs.getInt("from_address_id")) );
               sTmpSampAddr = rs.getString("samp_from_addr");
               sTmpAddrAddr = rs.getString("addr_from_addr");
               if (sTmpSampAddr == null || sTmpSampAddr.equals("")) {
                    setFromAddress(sTmpAddrAddr);
               } else {
                    setFromAddress(sTmpSampAddr);
               }
               setContId(String.valueOf(rs.getInt("cont_id")));
               setContName(rs.getString("cont_name"));
               setSubjectHtml(rs.getString("subject_html")  );
               setSubjectText(rs.getString("subject_text")  );
               setSubjectAol(rs.getString("subject_aol") );
               setSendDate(rs.getString("send_date") );
               setTestListId(String.valueOf(rs.getInt("test_list_id")) );
               setTestListName(rs.getString("test_list_name") );
               setReplyTo(rs.getString("reply_to") );
               setFilterId(rs.getString("filter_id") );
               setPriority(rs.getString("priority") );

          }
     }
	// === DB Methods ===
	private String sRetrieveSql = "SELECT samp.camp_id as camp_id, " +
         "samp.sample_id as sample_id, " +
         "samp.from_name as from_name, " +
         "ISNULL(samp.from_address_id,0) as from_address_id, " +
         "ISNULL(samp.from_address,'') as samp_from_addr, " +
         "ISNULL(frm_addr.prefix,'') + '@' + ISNULL(frm_addr.[domain],'') AS addr_from_addr, " +
         "ISNULL(samp.cont_id,0) as cont_id, " +
         "ISNULL(cnt.cont_name,'') as cont_name, " +
         "samp.subject_html as subject_html, " +
         "samp.subject_text as subject_text, " +
         "samp.subject_aol as subject_aol, " +
         "samp.send_date as send_date, " +
         "ISNULL(samp.test_list_id,0) as test_list_id, " +
         "ISNULL(tlist.list_name,'') as test_list_name," +
         "samp.reply_to as reply_to," +
         "ISNULL(samp.filter_id,0) as filter_id," +
         "ISNULL(samp.priority,0) as priority" +
         " FROM  cque_camp_sample samp LEFT OUTER JOIN " +
         "ccnt_content cnt ON samp.cont_id = cnt.cont_id LEFT OUTER JOIN " +
         "ccps_from_address frm_addr ON frm_addr.from_address_id = samp.from_address_id LEFT OUTER JOIN " +
         "cque_email_list tlist ON samp.test_list_id = tlist.list_id " +
         " WHERE samp.camp_id = ? AND " +
         "samp.sample_id = ?";

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
               conn = cp.getConnection("CampSampleBean");

               //System.out.println("SQL to retrieve Sample info:");
               //System.out.println(sRetrieveSql);

               pstmt = conn.prepareStatement(sRetrieveSql);
               pstmt.setString(1, sCampId);
               pstmt.setString(2, sSampleId);

               rs = pstmt.executeQuery();
               if (rs.next())
               {
                    setAll(rs);
               }
               rs.close();
               
               String sTestHistorySql = "SELECT ISNULL(stat.start_date, '1/1/00') AS start,  camp.camp_name " +
                    " FROM  cque_campaign camp " +
                    " INNER JOIN cque_camp_sample samp ON " +
                    " camp.origin_camp_id = samp.camp_id AND " +
                    " camp.sample_id = samp.sample_id " +
                    " INNER JOIN cque_camp_type type ON " +
                    " camp.type_id = type.type_id " +
                    " INNER JOIN cque_camp_statistic stat ON" +
                    " camp.camp_id = stat.camp_id " +
                    " WHERE (samp.camp_id = ?) " +
                    " AND (samp.sample_id = ?) " +
                    " AND (UPPER(type.type_name) = 'TEST')"; 
               pstmt = conn.prepareStatement(sTestHistorySql);
               pstmt.setString(1,sCampId);
               pstmt.setString(2,sSampleId);
               rs = pstmt.executeQuery();
               if (rs.next()) {
                    this.setTested(true);
                    setLastTestDate(rs.getString("start"));
               }
          } catch (SQLException sqle) {
               logger.error("SQL Exception thrown while attempting to retrieve Sample Bean.", sqle);
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
