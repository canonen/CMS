package com.britemoon.cps.xcs.cti;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

import com.britemoon.cps.xcs.cti.*;
import com.britemoon.cps.imc.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.*;
import com.britemoon.*;

//import javax.xml.namespace.QName;
//import javax.xml.rpc.ParameterMode;
import java.net.*;

public class ContentClient
{
	private com.britemoon.cps.xcs.cti.Content m_service;
	private ContentSoap m_port;
	private static Logger logger = Logger.getLogger(ContentClient.class.getName());

	public ContentClient()
	{
          m_service = null;
          m_port = null;
	}

	private DocumentOutput saveDocument(String sGroupID, String sDocumentID, String sDocumentName) throws Exception
	{
		DocumentOutput doReturn = null;

		if (m_port != null) {
			doReturn = m_port.saveDocumentName(sGroupID, sDocumentID, sDocumentName);
		} else {
			throw new Exception("Error attempting to connect to customer Web Service.  ServicePort is NULL.");
		}
		return doReturn;

	}

	private DocumentOutput cloneDocument(String sGroupID, String sDocumentID, String sDocumentName) throws Exception
	{
		DocumentOutput doReturn = null;

		if (m_port != null) {
			doReturn = m_port.cloneExistingDocument(sGroupID, sDocumentID, sDocumentName);
		} else {
			throw new Exception("Error attempting to connect to customer Web Service.  ServicePort is NULL.");
		}
		return doReturn;

	}

	private DocumentOutput deleteDocument(String sGroupID, String sDocumentID) throws Exception
	{
		DocumentOutput doReturn = null;

		if (m_port != null) {
			doReturn = m_port.deleteExistingDocument(sGroupID, sDocumentID);
		} else {
			throw new Exception("Error attempting to connect to customer Web Service.  ServicePort is NULL.");
		}
		return doReturn;

	}

	public String saveContentDocument(com.britemoon.cps.cnt.Content cont, int iAction) throws Exception 
	{
		int SAVE_TO_DEST=0, SAVE=1, SAVE_AS_NEW=2, SAVE_RETURN=3;
		int SAVE_LINKS=4, DYNAMIC_PREVIEW=5, SAVE_LOGIC=6;
		int SAVE_AND_REQUEST_APPROVAL=7;

		Customer cust = new Customer(cont.s_cust_id);
		getServicePort(cust.s_cust_id);
		
		DocumentOutput out = null;

		if (iAction==SAVE_AS_NEW || iAction==SAVE_TO_DEST)
		{
			out = cloneDocument(cust.s_cti_group_id, cont.s_cti_doc_id, cont.s_cont_name);
		}
		else 
		{
			out = saveDocument(cust.s_cti_group_id, cont.s_cti_doc_id, cont.s_cont_name);
		}

		ErrorStatus err = out.getErrorStatus();
		if (err != ErrorStatus.None) 
			throw new Exception (out.getErrorMessage());
		
		cont.s_cti_doc_id = out.getDocumentID();
		
		return cont.s_cti_doc_id;
	}


	public boolean deleteContentDocument(String sContID, String sCustID, String sUserID) throws Exception 
	{
		com.britemoon.cps.cnt.Content cont = new com.britemoon.cps.cnt.Content();
		cont.s_cont_id = sContID;
		if(cont.retrieve() < 1) throw new Exception("Cont ID = " + sContID + "does not exist");
		
		Customer cust = new Customer(sCustID);
		getServicePort(cust.s_cust_id);
		
		DocumentOutput out = deleteDocument(cust.s_cti_group_id, cont.s_cti_doc_id);
		
		ErrorStatus err = out.getErrorStatus();
		if (err != ErrorStatus.None) 
			throw new Exception (out.getErrorMessage());
		
		cont.s_status_id = String.valueOf(ContStatus.DELETED);
		
		ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
		cei.s_modifier_id = sUserID;
		cei.s_modify_date = null;	// setting s_modify_date to null will cause the content_edit_info_save stored procedure
									// to automatically set modify_date to the current date.
		
		cont.m_ContEditInfo = cei;

		cont.save();
		return true;
	}


	private void getServicePort(String sCustId) throws Exception 
	{
		if (sCustId == null)
			throw new Exception("Cannot connect to customer Web Service--Customer information could not be determined.");

		m_service = new ContentLocator();
		Vector vSvcs = Services.getByCust(ServiceType.CXCS_CONT_DOCUMENT_UPDATE, sCustId);
		com.britemoon.cps.imc.Service svc = (com.britemoon.cps.imc.Service) vSvcs.get(0);
		URL uServiceUrl = svc.getURL();
		logger.info("*** ContentClient \n  URL to customer Web Service is:"+uServiceUrl.toString() + "\n*** ContentClient");
		if (uServiceUrl != null) {
			m_port = m_service.getContentSoap(uServiceUrl);
		} else {
			throw new Exception("Cannot connect to customer Web Service--URL information could not be found.");
		}


	}

}
