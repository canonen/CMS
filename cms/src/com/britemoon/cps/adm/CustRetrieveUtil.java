package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustRetrieveUtil
{
	private static Logger logger = Logger.getLogger(CustRetrieveUtil.class.getName());
	public static void retrieveFull(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		if(customer.retrieve() < 1) return;
		
		retrieveCustAddr(customer);
		retrieveCustModInsts(customer);
		retrieveCustAttrs(customer);
		retrieveCustPartners(customer);
		retrieveCustUniqueIds(customer);
		retrieveFromAddresses(customer);
		retrieveUnsubMsgs(customer);
		retrieveUsers(customer);
                retrieveEmailLists(customer);
	}
	
	// === === ===

	public static void retrieveUsers(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		Users us = new	Users();
		us.s_cust_id = customer.s_cust_id;
		if(us.retrieve() > 0) retrieveUsers(us);
		customer.m_Users = us;
	}

	public static void retrieveUsers(Users us) throws Exception
	{
		User u = null;
		for (Enumeration e = us.elements() ; e.hasMoreElements() ;)
		{
			u = (User)e.nextElement();
			retrieveUser(u);
		}
	}	

	public static void retrieveUser(User u) throws Exception
	{
		retrieveAccessMasks(u);
		retrieveUserUiSettings(u);
	}

	public static void retrieveAccessMasks(User u) throws Exception
	{
		if(u.s_user_id == null) return;
		AccessMasks ams = new AccessMasks();
		ams.s_user_id = u.s_user_id;
		ams.retrieve();
		u.m_AccessMasks = ams;
	}
				
	public static void retrieveUserUiSettings(User u) throws Exception
	{
		if(u.s_user_id == null) return;
		u.m_UserUiSettings = new UserUiSettings(u.s_user_id);
	}

	// === === ===
	
	public static void retrieveUnsubMsgs(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
			
		UnsubMsgs um = new UnsubMsgs();
		um.s_cust_id = customer.s_cust_id;
		um.retrieve();
		customer.m_UnsubMsgs = um;
	}

	// === === ===
	
	public static void retrieveFromAddresses(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
			
		FromAddresses fas = new FromAddresses();
		fas.s_cust_id = customer.s_cust_id;
		fas.retrieve();
		customer.m_FromAddresses = fas;
	}

	// === === ===
	
	public static void retrieveCustUniqueIds(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
			
		CustUniqueIds cuis = new CustUniqueIds();
		cuis.s_cust_id = customer.s_cust_id;
		cuis.retrieve();
		customer.m_CustUniqueIds = cuis;
	}
		
	// === === ===
	
	public static void retrieveCustPartners(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		CustPartners cps = new CustPartners();
		cps.s_cust_id = customer.s_cust_id;
		if(cps.retrieve() > 0) retrieveCustPartners(cps);
		customer.m_CustPartners = cps;
	}

	public static void retrieveCustPartners(CustPartners cps) throws Exception
	{
		CustPartner cp = null;
		for (Enumeration e = cps.elements() ; e.hasMoreElements() ;)
		{
			cp = (CustPartner)e.nextElement();
			retrieveCustPartner(cp);
		}
	}

	public static void retrieveCustPartner(CustPartner cp) throws Exception
	{
		retrievePartner(cp);
	}

	public static void retrievePartner(CustPartner cp) throws Exception
	{
		if(cp.s_partner_id == null) return;
		cp.m_Partner = new Partner(cp.s_partner_id);
	}

	// === === ===

	public static void retrieveCustAttrs(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		CustAttrs cas = new	CustAttrs();
		cas.s_cust_id = customer.s_cust_id;
		if(cas.retrieve() > 0) retrieveCustAttrs(cas);
		customer.m_CustAttrs = cas;
	}

	public static void retrieveCustAttrs(CustAttrs cas) throws Exception
	{
		CustAttr ca = null;
		for (Enumeration e = cas.elements() ; e.hasMoreElements() ;)
		{
			ca = (CustAttr)e.nextElement();
			retrieveCustAttr(ca);
		}
	}	

	public static void retrieveCustAttr(CustAttr ca) throws Exception
	{
		retrieveAttribute(ca);
	}

	public static void retrieveAttribute(CustAttr ca) throws Exception
	{
		if(ca.s_attr_id == null) return;
		ca.m_Attribute = new Attribute(ca.s_attr_id);
	}
				
	// === === ===	

	public static void retrieveCustModInsts(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		
		CustModInsts cmis = new CustModInsts();
		cmis.s_cust_id = customer.s_cust_id;
		if ( cmis.retrieve() > 0 ) retrieveCustModInsts(cmis);
		customer.m_CustModInsts = cmis;
	}

	public static void retrieveCustModInsts(CustModInsts cmis) throws Exception
	{
		CustModInst cmi = null;
		for (Enumeration e = cmis.elements() ; e.hasMoreElements() ;)
		{
			cmi = (CustModInst)e.nextElement();
			retrieveCustModInst(cmi);
		}
	}
	
	public static void retrieveCustModInst(CustModInst cmi) throws Exception
	{
		retrieveModInst(cmi);		
		retrieveCustModInstServices(cmi);
		retrieveVanityDomains(cmi);
	}

	public static void retrieveModInst(CustModInst cmi) throws Exception
	{
		if(cmi.s_mod_inst_id == null) return;
		
		ModInst mi = new ModInst(cmi.s_mod_inst_id);
		retrieveModInst(mi);
		cmi.m_ModInst = mi;	
	}

	public static void retrieveCustModInstServices(CustModInst cmi) throws Exception
	{
		if(cmi.s_cust_id == null) return;
		if(cmi.s_mod_inst_id == null) return;
			
		CustModInstServices cmiss = new CustModInstServices();
		cmiss.s_cust_id = cmi.s_cust_id;
		cmiss.s_mod_inst_id = cmi.s_mod_inst_id;
		cmiss.retrieve();
		cmi.m_CustModInstServices = cmiss;
	}

	public static void retrieveVanityDomains(CustModInst cmi) throws Exception
	{
		if(cmi.s_cust_id == null) return;
		if(cmi.s_mod_inst_id == null) return;
			
		VanityDomains vds = new VanityDomains();
		vds.s_cust_id = cmi.s_cust_id;
		vds.s_mod_inst_id = cmi.s_mod_inst_id;
		vds.retrieve();
		cmi.m_VanityDomains = vds;
	}

	public static void retrieveModInst(ModInst mi) throws Exception
	{
		retrieveMachine(mi);
		retrieveModInstServices(mi);
	}

	public static void retrieveMachine(ModInst mi) throws Exception
	{
		if (mi.s_machine_id == null) return;
		mi.m_Machine = new Machine(mi.s_machine_id);	
	}

	public static void retrieveModInstServices(ModInst mi) throws Exception
	{
		if(mi.s_mod_inst_id == null) return;	
		ModInstServices miss = new ModInstServices();
		miss.s_mod_inst_id = mi.s_mod_inst_id;
		miss.retrieve();
		mi.m_ModInstServices = miss;
	}

	// === === ===

	public static void retrieveCustAddr(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		customer.m_CustAddr = new CustAddr(customer.s_cust_id);
	}
        

         private static void retrieveEmailLists(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		EmailLists es = new EmailLists();
                EmailLists returnLists = new EmailLists();
  
  		es.s_cust_id = customer.s_cust_id;
                es.s_status_id = new Integer(EmailListStatus.ACTIVE).toString();
 
		if(es.retrieve() > 0) {
                    returnLists = retrieveEmailList(customer, es);
                }

              // Email lists to be synchronized must be under the Customer.s_cust_id.
                returnLists.s_cust_id = customer.s_cust_id;
		customer.m_EmailLists = returnLists;
	}


        /**
         * Retrieves only Pivotal Veracity seed lists for a customer.  
         * Once the list is retrieved and it is active and it has Pivotal Veracity List Types, it is stored in the customer's EmailLists object for synchronization with CPS and RCP.
         * @param customer  The customer who is to by synched between ADM and CPS/RCP
         * @param es The EmailLists associated with the customer.
         * @return void
         **/
	private static EmailLists retrieveEmailList(Customer customer, EmailLists es) throws Exception
	{	
                int numEmailListItems = 0;
                int numEmailListPVInfo = 0;
                EmailList el = null;
                EmailListItems elis = null;
                EmailListPVInfo elpv = null;
                EmailLists returnLists = new EmailLists();
                
                String scorer_type = new Integer(EmailListType.PV_SCORER_LIST).toString();
                String seed_type = new Integer(EmailListType.PV_SEED_LIST).toString();
                String b2b_type = new Integer(EmailListType.PV_SEED_LIST_B2B).toString();
                String can_type = new Integer(EmailListType.PV_SEED_LIST_CANADIAN).toString();
                String intn_type = new Integer(EmailListType.PV_SEED_LIST_INTERNATIONAL).toString();
                String cust_type = new Integer(EmailListType.PV_SEED_LIST_CUSTOM).toString();
                String opt_type = new Integer(EmailListType.PV_OPTIMIZER_LIST).toString();
           
		for (Enumeration e = es.elements() ; e.hasMoreElements() ;)
		{
                    
                    el = new EmailList();
                    elis = new EmailListItems();
                    elpv = new EmailListPVInfo();
                    
                    el = (EmailList)e.nextElement();
                    if ((el.s_type_id.equals(scorer_type)) || (el.s_type_id.equals(seed_type)) || (el.s_type_id.equals(b2b_type)) ||
                        (el.s_type_id.equals(can_type)) || (el.s_type_id.equals(intn_type)) || (el.s_type_id.equals(cust_type)) || 
                        (el.s_type_id.equals(opt_type)) ) {
                            elpv.s_list_id = el.s_list_id;
                            numEmailListPVInfo = elpv.retrieve();
                            if (numEmailListPVInfo > 0) el.m_EmailListPVInfo = elpv;
                            returnLists.add(el);
                            elis.s_list_id = el.s_list_id;
                            numEmailListItems = elis.retrieve();
                            if (numEmailListItems > 0) el.m_EmailListItems = elis;
                    }
                                     
                }
  
                return returnLists;
                               
	}
        
}