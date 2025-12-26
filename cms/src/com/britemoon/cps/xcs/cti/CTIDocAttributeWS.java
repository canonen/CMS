package com.britemoon.cps.xcs.cti;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.io.*;
import java.util.*;
import java.util.zip.*;
import java.net.*;
import java.sql.*;

import org.apache.axis.attachments.Attachments;
import org.apache.axis.attachments.AttachmentPart;
import org.apache.axis.AxisFault;
import org.apache.axis.MessageContext;
import org.apache.axis.client.*;

import javax.xml.soap.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import javax.activation.FileDataSource;
import javax.activation.DataHandler;
import org.apache.log4j.*;

public class CTIDocAttributeWS
{
	private static Logger logger = Logger.getLogger(CTIDocAttributeWS.class.getName());
	public void getDocAttributes(String sCustId, String sContId) throws Exception
    {
		
		ArrayOfVariablePair avpAttributes = null;
          VariablePair[] vpAttributes = null;
          ConnectionPool cp = null;
          Connection conn = null;
          PreparedStatement pstmt = null;
          PreparedStatement pstmtInsert = null;
          ResultSet rs = null;
          String sSql = null;
          String sSqlInsert = null;

          String sDocId = null;
          String sGroupId = null;
          String sAttrId = null;
          String sCtiVarId = null;
          String sAttrName = null;
		
		logger.info("Calling web services to get document attributes..");
		try {

               com.britemoon.cps.cnt.Content cont = new com.britemoon.cps.cnt.Content(sContId);
               sDocId = cont.s_cti_doc_id;
               Customer cust = new Customer(sCustId);
               sGroupId = cust.s_cti_group_id;

               if (sDocId == null) {
                    throw new Exception("Error attempting to update print document attributes.  Document ID could not be found for Content ID:" + sContId + "; cust:" + sCustId);
               }
               if (sGroupId == null) {
                    throw new Exception("Error attempting to update print document attributes.  Group ID could not be found for Customer:" + sCustId);
               }
               else {
                    logger.info("Getting attributes for ContentID:" + cont.s_cont_id + "; DOC ID:" + sDocId + "; Group ID:" + sGroupId);
               }
			
			logger.info("Getting Web Service info.");

			//    ALL of the following will change for the REAL service
               com.britemoon.cps.xcs.cti.Content service = new ContentLocator();
               Vector vSvcs = Services.getByCust(ServiceType.CXCS_CONT_DOCUMENT_ATTRIBUTES, sCustId);
               com.britemoon.cps.imc.Service svc = (com.britemoon.cps.imc.Service) vSvcs.get(0);
               URL uServiceUrl = svc.getURL();
               logger.info("***CTIDocAttributeWS***  \n  URL to customer Web Service is:"+uServiceUrl.toString() + "\n***CTIDocAttributeWS*** ");
          
               if (uServiceUrl != null) {
                    try {
                         logger.info("Call web services=> ");
                         ContentSoap port = service.getContentSoap(uServiceUrl);
                         avpAttributes = port.getBritemoonVariables(sGroupId,sDocId);
                    } catch (Exception e) {
                         logger.error("Exception thrown attempting to call Document Attribute service." , e);
                    }
                    if (avpAttributes != null) {
                         vpAttributes = avpAttributes.getVariablePair();
                    } else {
                         throw new Exception("Error attempting to update print document attributes.  No attributes were retrieved for Print content.  Null returned from DocAttribute WS.");
                    }
                    if (vpAttributes != null && vpAttributes.length != 0) {
                         try {
                              cp = ConnectionPool.getInstance();
                              conn = cp.getConnection("CTIDocAttributeWS");

							  sSql = "DELETE cxcs_cti_doc_attrs WHERE cont_id = "+sContId;
							  BriteUpdate.executeUpdate(sSql, conn);

                              sSql = "Select attr_id from ccps_attribute " +
                                        " Where attr_name = ? AND " +
                                        " (cust_id = ? or cust_id = 0) ";
                              pstmt = conn.prepareStatement(sSql);
                              sSqlInsert = "Insert cxcs_cti_doc_attrs (cont_id, cust_id, attr_id, cti_var_id) " +
                                                  " values (?, ?, ?, ?) ";
                              pstmtInsert = conn.prepareStatement(sSqlInsert);

                              int iAttrCount = 0;
                              for (int i = 0; i < vpAttributes.length; i++) {
                                   // 'filter out' null objects in the returned array
                                   if (vpAttributes[i] == null)
                                        continue;
                         
                                   // get CTI Var Id
                                   sCtiVarId = vpAttributes[i].getVariableID();

                                   // get Attribute Name
                                   sAttrName = vpAttributes[i].getBritemoonName();
                                   logger.info("**##!! Variable ID : Britemoon Attribute being returned from WebService... !!##**\n **##!! " + sCtiVarId + " : " + sAttrName + " !!##**");
                                   pstmt.setString(1,sAttrName);
                                   pstmt.setString(2,sCustId);
                                   rs = pstmt.executeQuery();
                                   if (rs.next()) {
                                        sAttrId = rs.getString(1);
                                   } else {
                                        sAttrId = null;
                                        throw new Exception("Error attempting to update print document attributes.  Attribute ID could not be found for Attribute name:" + sAttrName + "; cust:" + sCustId);
                                   }
                                   if (rs.next()) {
                                        sAttrId = null;
                                        throw new Exception("Error attempting to update print document attributes.  Multiple attribute IDs found for Attribute name:" + sAttrName + "; cust:" + sCustId);
                                   }

                                   if (sAttrId != null) {
                                        pstmtInsert.setString(1, sContId);
                                        pstmtInsert.setString(2, sCustId);
                                        pstmtInsert.setString(3, sAttrId);
                                        pstmtInsert.setString(4, sCtiVarId);

                                        pstmtInsert.executeUpdate();
                                   }
                                   rs.close();
                                   iAttrCount++;
                              }
                              logger.info("Successfully returned " + iAttrCount + " attributes for doc:" + sDocId);

                         }
                         catch (SQLException sqle) {
                              logger.error("SQL Exception while attempting to get/store print document attributes." , sqle);
                              throw sqle;
                         } finally {
                              if (pstmt != null) {
                                   try {
                                        pstmt.close();
                                   } catch (Exception ignore) { }
                              }
                              if (pstmtInsert != null) {
                                   try {
                                        pstmtInsert.close();
                                   } catch (Exception ignore) { }
                              }
                              cp.free(conn);
                         }
                    } else {
                         throw new Exception("Error attempting to update print document attributes.  No attributes were retrieved for Print content.  0 attributes were returned from DocAttribute WS.");
                    }
               
               } else {
                    throw new Exception("Cannot connect to customer Document Attribute Web Service--URL information could not be found.");
               }
			
		}
		catch (AxisFault af) {
			logger.info("AxisFault="+af.getMessage());
               throw new Exception(af.getMessage());
		}
		catch (Exception ex) {
			throw ex;
		}
		
    }

	public static void main(String[] args) throws Exception
	{
		CTIDocAttributeWS da = new CTIDocAttributeWS();   
		String sGroupId = "42910770-1C5F-4376-98FA-0868B924CB68";
		String sDocId = "3D25B986-6A26-4601-99CD-4C55269F2098";
//		String sDocId = "5ffee46c-a786-424b-a3f6-f91d9461fb8c";
          ArrayOfVariablePair avpAttributes = null;
          VariablePair[] vpAttributes = null;

          String sCtiVarId = null;
          String sAttrName = null;

          com.britemoon.cps.xcs.cti.Content service = new ContentLocator();
          URL uServiceUrl = new URL("http://69.15.102.6/stip/content.asmx");
          logger.info("***  \n  URL to customer Web Service is:"+uServiceUrl.toString() + "\n*** ");
          
          if (uServiceUrl != null) {
               ContentSoap port = service.getContentSoap(uServiceUrl);
               avpAttributes = port.getBritemoonVariables(sGroupId,sDocId);
               if (avpAttributes != null)
                    vpAttributes = avpAttributes.getVariablePair();
               if (vpAttributes != null && vpAttributes.length != 0) {
                    for (int i = 0; i < vpAttributes.length /*&& vpAttributes[i] != null*/; i++) {
                         if (vpAttributes[i] != null) {// get CTI Var Id
                         sCtiVarId = vpAttributes[i].getVariableID();

                         // get Attribute Name
                         sAttrName = vpAttributes[i].getBritemoonName();

                         logger.info("var:" + sCtiVarId);
                         logger.info("AttrName:" + sAttrName); }
                    }
               } else {
                    logger.info("vpAttributes is empty");
               }
          }

	}

    
}
