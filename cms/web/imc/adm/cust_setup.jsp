<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
                        com.britemoon.cps.que.*,
                        com.britemoon.cps.imc.*,
			java.io.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
Customer cust = new Customer();
try
{
	Element eCust = XmlUtil.getRootElement(request);
	cust = new Customer(eCust);

	// === === ===

	CustModInsts cmis = new CustModInsts();
	cmis.s_cust_id = cust.s_cust_id;

	if(cmis.retrieve() < 1)
	{
		cust.save();
                retrieveEmailLists(cust);
		return;
	}

	// === === ===
	
	ConnectionPool cp = null;
	Connection conn = null;
	boolean bAutoCommit = true;
	try
	{
		cp = ConnectionPool.getInstance();			
		conn = cp.getConnection(this);
		bAutoCommit = conn.getAutoCommit();
		conn.setAutoCommit(false);
		
		String sSql = "DELETE cadm_vanity_domain WHERE cust_id=" + cust.s_cust_id;
		BriteUpdate.executeUpdate(sSql, conn);
		
		sSql = "DELETE cadm_cust_mod_inst_service WHERE cust_id=" + cust.s_cust_id;
		BriteUpdate.executeUpdate(sSql, conn);
					
		sSql = "DELETE cadm_cust_mod_inst WHERE cust_id=" + cust.s_cust_id;
		BriteUpdate.executeUpdate(sSql, conn);

		sSql = "DELETE ccps_cust_feature WHERE cust_id=" + cust.s_cust_id;
		BriteUpdate.executeUpdate(sSql, conn);

		sSql = "UPDATE ccps_aprvl_cust SET aprvl_workflow_flag=0 WHERE cust_id=" + cust.s_cust_id;
		BriteUpdate.executeUpdate(sSql, conn);

		sSql = "DELETE ccnt_img_cust_file_extension WHERE cust_id=" + cust.s_cust_id;
		BriteUpdate.executeUpdate(sSql, conn);
                
                // Delete all existing Pivotal Veracity email lists for this customer before saving the customer's latest copy of the
                // PV Email Lists.
                
                sSql = "EXEC usp_cque_clean_pv_lists " + cust.s_cust_id;
                BriteUpdate.executeUpdate(sSql, conn);
                
                cust.save(conn);
		
		sSql = "EXEC usp_ccps_cust_batch_init " + cust.s_cust_id;
		BriteUpdate.executeUpdate(sSql, conn);
                

		if (cust.s_parent_cust_id != null) {
			sSql = "EXEC usp_ccnt_img_cust_global_access_set @cust_id = " + cust.s_cust_id;
			BriteUpdate.executeUpdate(sSql, conn);
		}
                conn.commit();
                retrieveEmailLists(cust);
   
	}
	catch(SQLException sqlex)
	{
		if (conn != null) conn.rollback();
		throw sqlex;
	}
	finally
	{
		if (conn != null)
		{
			conn.setAutoCommit(bAutoCommit);
			cp.free(conn);
		}
	}
}
catch(Exception ex)
{ 
	logger.error("Exception: ", ex);
	out.flush();
	ex.printStackTrace(new PrintWriter(out));
}
finally
{
	String sCustId = new String(cust.s_cust_id);
	cust = new Customer(sCustId);
	try { CustRetrieveUtil.retrieveFull(cust); }
	catch(Exception ex) { ex.printStackTrace(new PrintWriter(out)); }
	out.println(cust.toXml());
}

%>
<%!
private void retrieveEmailLists (Customer customer) throws Exception {
		if(customer.s_cust_id == null) return;
		EmailLists els = new EmailLists();
                
		els.s_cust_id = customer.s_cust_id;
                els.s_status_id = new Integer(EmailListStatus.ACTIVE).toString();
 		if(els.retrieve() > 0) sychPVEmailLists(els, customer);
	}


void sychPVEmailLists(EmailLists els, Customer customer) throws Exception {
                EmailList el = null;
                EmailListItems elis = null;
		
                int numEmailListItems = 0;
		for (Enumeration e = els.elements() ; e.hasMoreElements() ;)
		{
                        el = new EmailList();
                        elis = new EmailListItems();
                        numEmailListItems = 0;
			el = (EmailList)e.nextElement();
                        if ((el.s_type_id.equals("8")) || (el.s_type_id.equals("9")) || (el.s_type_id.equals("10")) || (el.s_type_id.equals("11")) || 
                            (el.s_type_id.equals("12")) || (el.s_type_id.equals("13")) || (el.s_type_id.equals("14"))) {
                                elis.s_list_id = el.s_list_id;
                                numEmailListItems = elis.retrieve();
                                if (numEmailListItems > 0) {
                                    el.m_EmailListItems = elis;
                                    synchPVEmailList(el, customer);
                                }
                        }
		}
	}

void synchPVEmailList(EmailList el, Customer customer) throws Exception {
    try
	{
 		String sRequest = el.toXml();
 		String sResponse = Service.communicate(ServiceType.RQUE_LIST_SETUP, customer.s_cust_id, sRequest);
		XmlUtil.getRootElement(sResponse);
	}
	catch(Exception ex)
	{
		throw new Exception("Unable to Synchronize CPS Pivotal Veracity Lists with RCP.");
	}

}
%>

