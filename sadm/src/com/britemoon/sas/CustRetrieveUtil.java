package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.EmailListType;
import com.britemoon.cps.Feature;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class CustRetrieveUtil
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustRetrieveUtil.class.getName());
	public static void retrieveFull(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		if(customer.retrieve() < 1) return;
		
		retrieveCustAddr(customer);
		retrieveCustUiSettings(customer);
		retrieveCustSendParam(customer);		
		retrieveCustModInsts(customer);
		retrieveCustAttrs(customer);
		retrieveCustPartners(customer);
		retrieveCustUniqueIds(customer);
		retrieveCustFeatures(customer);		
		retrieveFromAddresses(customer);
		retrieveUnsubMsgs(customer);
		retrieveUsers(customer);
		retrieveAprvlCusts(customer);
		retrieveImgCustFileExtensions(customer);
		retrieveImgCustRefreshInfo(customer);
		retrieveEntities(customer);
	}
        
        public static void retrieve4cps(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		if(customer.retrieve() < 1) return;
		
		retrieveCustAddr(customer);
		retrieveCustUiSettings(customer);
		retrieveCustSendParam(customer);		
		retrieveCustModInsts(customer);
		retrieveCustAttrs(customer);
		retrieveCustPartners(customer);
		retrieveCustUniqueIds(customer);
		retrieveCustFeatures(customer);		
		retrieveFromAddresses(customer);
		retrieveUnsubMsgs(customer);
		retrieveUsers(customer);
		retrieveAprvlCusts(customer);
		retrieveImgCustFileExtensions(customer);
		retrieveImgCustRefreshInfo(customer);
		retrieveEntities(customer);
        retrieveEmailLists(customer);
        retrieveCustomerSettings(customer);
	}

    private static void retrieveCustomerSettings(Customer customer) throws Exception {
        if (customer.s_cust_id == null) return;

        CustomerSettings settings = new CustomerSettings();
        settings.s_cust_id = customer.s_cust_id;
        settings.retrieve();
        customer.m_CustomerSettings = settings;
    }

    public static void retrieve4inb(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		if(customer.retrieve() < 1) return;
		
		retrieveUsers(customer);
		retrieveFromAddresses(customer);
		retrieveCustUniqueIds(customer);
	}
	
	// === === ===

	private static void retrieveUsers(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		Users us = new	Users();
		us.s_cust_id = customer.s_cust_id;
		if(us.retrieve() > 0) retrieveUsers(us);
		customer.m_Users = us;
	}

	private static void retrieveUsers(Users us) throws Exception
	{
		User u = null;
		for (Enumeration e = us.elements() ; e.hasMoreElements() ;)
		{
			u = (User)e.nextElement();
			retrieveUser(u);
		}
	}	

	private static void retrieveUser(User u) throws Exception
	{
		retrieveAccessMasks(u);
		retrieveUserUiSettings(u);
	}

	private static void retrieveAccessMasks(User u) throws Exception
	{
		if(u.s_user_id == null) return;
		AccessMasks ams = new AccessMasks();
		ams.s_user_id = u.s_user_id;
		ams.retrieve();
		u.m_AccessMasks = ams;
	}
				
	private static void retrieveUserUiSettings(User u) throws Exception
	{
		if(u.s_user_id == null) return;
		u.m_UserUiSettings = new UserUiSettings(u.s_user_id);
	}

	// === === ===
	
	private static void retrieveUnsubMsgs(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
			
		UnsubMsgs um = new UnsubMsgs();
		um.s_cust_id = customer.s_cust_id;
		um.retrieve();
		customer.m_UnsubMsgs = um;
	}

	// === === ===
	
	private static void retrieveFromAddresses(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
			
		FromAddresses fas = new FromAddresses();
		fas.s_cust_id = customer.s_cust_id;
		fas.retrieve();
		customer.m_FromAddresses = fas;
	}

	// === === ===

	private static void retrieveCustFeatures(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
			
		CustFeatures cfs = new CustFeatures();
		cfs.s_cust_id = customer.s_cust_id;
		cfs.retrieve();
		customer.m_CustFeatures = cfs;
	}

	// === === ===
	
	private static void retrieveCustUniqueIds(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
			
		CustUniqueIds cuis = new CustUniqueIds();
		cuis.s_cust_id = customer.s_cust_id;
		cuis.retrieve();
		customer.m_CustUniqueIds = cuis;
	}
		
	// === === ===
	
	private static void retrieveCustPartners(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		CustPartners cps = new CustPartners();
		cps.s_cust_id = customer.s_cust_id;
		if(cps.retrieve() > 0) retrieveCustPartners(cps);
		customer.m_CustPartners = cps;
	}

	private static void retrieveCustPartners(CustPartners cps) throws Exception
	{
		CustPartner cp = null;
		for (Enumeration e = cps.elements() ; e.hasMoreElements() ;)
		{
			cp = (CustPartner)e.nextElement();
			retrieveCustPartner(cp);
		}
	}

	private static void retrieveCustPartner(CustPartner cp) throws Exception
	{
		retrievePartner(cp);
	}

	private static void retrievePartner(CustPartner cp) throws Exception
	{
		if(cp.s_partner_id == null) return;
		cp.m_Partner = new Partner(cp.s_partner_id);
	}

	// === === ===

	private static void retrieveCustAttrs(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		CustAttrs cas = new	CustAttrs();
		cas.s_cust_id = customer.s_cust_id;
		if(cas.retrieve() > 0) retrieveCustAttrs(cas);
		customer.m_CustAttrs = cas;
	}

	private static void retrieveCustAttrs(CustAttrs cas) throws Exception
	{
		CustAttr ca = null;
		for (Enumeration e = cas.elements() ; e.hasMoreElements() ;)
		{
			ca = (CustAttr)e.nextElement();
			retrieveCustAttr(ca);
		}
	}	

	private static void retrieveCustAttr(CustAttr ca) throws Exception
	{
		retrieveAttribute(ca);
	}

	private static void retrieveAttribute(CustAttr ca) throws Exception
	{
		if(ca.s_attr_id == null) return;
		ca.m_Attribute = new Attribute(ca.s_attr_id);
	}
				
	// === === ===	

	private static void retrieveCustModInsts(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		
		CustModInsts cmis = new CustModInsts();
		cmis.s_cust_id = customer.s_cust_id;
		if ( cmis.retrieve() > 0 ) retrieveCustModInsts(cmis);
		customer.m_CustModInsts = cmis;
	}

	private static void retrieveCustModInsts(CustModInsts cmis) throws Exception
	{
		CustModInst cmi = null;
		for (Enumeration e = cmis.elements() ; e.hasMoreElements() ;)
		{
			cmi = (CustModInst)e.nextElement();
			retrieveCustModInst(cmi);
		}
	}
	
	private static void retrieveCustModInst(CustModInst cmi) throws Exception
	{
		retrieveModInst(cmi);		
		retrieveCustModInstServices(cmi);
		retrieveVanityDomains(cmi);
	}

	private static void retrieveModInst(CustModInst cmi) throws Exception
	{
		if(cmi.s_mod_inst_id == null) return;
		
		ModInst mi = new ModInst(cmi.s_mod_inst_id);
		retrieveModInst(mi);
		cmi.m_ModInst = mi;	
	}

	private static void retrieveCustModInstServices(CustModInst cmi) throws Exception
	{
		if(cmi.s_cust_id == null) return;
		if(cmi.s_mod_inst_id == null) return;
			
		CustModInstServices cmiss = new CustModInstServices();
		cmiss.s_cust_id = cmi.s_cust_id;
		cmiss.s_mod_inst_id = cmi.s_mod_inst_id;
		cmiss.retrieve();
		cmi.m_CustModInstServices = cmiss;
	}

	private static void retrieveVanityDomains(CustModInst cmi) throws Exception
	{
		if(cmi.s_cust_id == null) return;
		if(cmi.s_mod_inst_id == null) return;
			
		VanityDomains vds = new VanityDomains();
		vds.s_cust_id = cmi.s_cust_id;
		vds.s_mod_inst_id = cmi.s_mod_inst_id;
		vds.retrieve();
		cmi.m_VanityDomains = vds;
	}

	private static void retrieveModInst(ModInst mi) throws Exception
	{
		retrieveMachine(mi);
		retrieveModInstServices(mi);
	}

	private static void retrieveMachine(ModInst mi) throws Exception
	{
		if (mi.s_machine_id == null) return;
		mi.m_Machine = new Machine(mi.s_machine_id);	
	}

	private static void retrieveModInstServices(ModInst mi) throws Exception
	{
		if(mi.s_mod_inst_id == null) return;	
		ModInstServices miss = new ModInstServices();
		miss.s_mod_inst_id = mi.s_mod_inst_id;
		miss.retrieve();
		mi.m_ModInstServices = miss;
	}

	// === === ===

	private static void retrieveCustSendParam(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		customer.m_CustSendParam = new CustSendParam(customer.s_cust_id);
	}

	private static void retrieveCustUiSettings(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		customer.m_CustUiSettings = new CustUiSettings(customer.s_cust_id);
	}

	private static void retrieveCustAddr(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		customer.m_CustAddr = new CustAddr(customer.s_cust_id);
	}
	
	// === === ===

	private static void retrieveAprvlCusts(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		
		AprvlCusts acs = new AprvlCusts();
		acs.s_cust_id = customer.s_cust_id;
		acs.retrieve();
		customer.m_AprvlCusts = acs;
	}

	private static void retrieveImgCustFileExtensions(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		
		ImgCustFileExtensions icfes = new ImgCustFileExtensions();
		icfes.s_cust_id = customer.s_cust_id;
		icfes.retrieve();
		customer.m_ImgCustFileExtensions = icfes;
	}

	private static void retrieveImgCustRefreshInfo(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		
		ImgCustRefreshInfo icri = new ImgCustRefreshInfo();
		icri.s_cust_id = customer.s_cust_id;
		if(icri.retrieve() > 0)	customer.m_ImgCustRefreshInfo = icri;
	}
	
	// === === ===
	
	private static void retrieveEntities(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;

		Entities es = new Entities();
		es.s_cust_id = customer.s_cust_id;
		if(es.retrieve() > 0) retrieveEntities(es);

		customer.m_Entities = es;
	}

	private static void retrieveEntities(Entities es) throws Exception
	{
		Entity e = null;
		for (Enumeration en = es.elements() ; en.hasMoreElements() ;)
		{
			e = (Entity)en.nextElement();
			retrieveEntity(e);
		}
	}	

	private static void retrieveEntity(Entity e) throws Exception
	{
		retrieveEntityAttrs(e);
	}
	
	private static void retrieveEntityAttrs(Entity e) throws Exception
	{
		if(e.s_entity_id == null) return;
		
		EntityAttrs eas = new EntityAttrs();
		eas.s_entity_id = e.s_entity_id;
		eas.retrieve();
		
		e.m_EntityAttrs = eas;
	}	
        
       private static void retrieveEmailLists(Customer customer) throws Exception
	{
		if(customer.s_cust_id == null) return;
		EmailLists es = new EmailLists();
                retrieveEmailList(customer, es);
                  
              // Email lists to by synchronized must be under the Customer.s_cust_id.
                es.s_cust_id = customer.s_cust_id;
		customer.m_EmailLists = es;
	}


        /**
         * Retrieves only Pivotal Veracity seed lists for a customer.  
         * The PV email lists are stored in ADM under customer 0.  So the list is retrieved where cust_id = 0 and list type is equal
         * to the list type that the customer has the CustFeature for the PV List types.  
         * Once the list is retrieved it is stored in the customer's EmailLists object with a new list_id and item_id for synchronization with CPS and RCP.
         * @param customer  The customer who is to by synched between ADM and CPS/RCP
         * @param es The EmailLists associated with the customer.
         * @return void
         **/
	private static void retrieveEmailList(Customer customer, EmailLists es) throws Exception
	{	
                int numEmailListItems = 0;
                int numEmailListPVInfo = 0;
           
                if(customer.s_cust_id == null) return;
                               
                if  (CustFeature.exists(customer.s_cust_id, Feature.PV_CONTENT_SCORER)){
                    
                    EmailList el = new EmailList();
                    EmailListItems elis = new EmailListItems();
                    EmailListPVInfo elpv = new EmailListPVInfo();
                    String scorer_list_id = "";
                    
                    el.s_cust_id = "0";  // Pivatol Veracity lists in adm are under customer 0.
                    el.s_type_id = new Integer(EmailListType.PV_SCORER_LIST).toString();
                    el.retrieve();
                    scorer_list_id = el.s_list_id;
                    el.s_cust_id = customer.s_cust_id;  // change customer id to the customer who is receiving the list.
                    elpv.s_list_id = el.s_list_id;
                    numEmailListPVInfo = elpv.retrieve();
                    if (numEmailListPVInfo > 0) el.m_EmailListPVInfo = elpv;
                    es.add(el);
                    
                    elis.s_list_id = el.s_list_id;
                    numEmailListItems = elis.retrieve();
                    // make the list_id = blank becauuse CPS will store the list using it's latest list_id identity field
                    if (numEmailListItems > 0) {
                        EmailListItems changedLists = changeListIdInEmailListItems(elis);
                        el.m_EmailListItems = changedLists;
                    }
                    el.s_list_id = "";  
                    elpv.s_list_id = ""; 
  
 
                }
                
                if (CustFeature.exists(customer.s_cust_id, Feature.PV_DELIVERY_TRACKER_SEED_LIST)) {
                    EmailList elSeed = new EmailList();
                    EmailListItems elisSeed = new EmailListItems();
                    EmailListPVInfo elpvSeed = new EmailListPVInfo();
                    
                    elSeed.s_cust_id = "0";  // PV lists in adm are under customer 0.
                    elSeed.s_type_id = new Integer(EmailListType.PV_SEED_LIST).toString();
                    elSeed.retrieve();
                    elSeed.s_cust_id = customer.s_cust_id;  // change customer id to the customer who is receiving the list.
                    elpvSeed.s_list_id = elSeed.s_list_id;
                    numEmailListPVInfo = elpvSeed.retrieve();
                    if (numEmailListPVInfo > 0) elSeed.m_EmailListPVInfo = elpvSeed;
                    es.add(elSeed);
                    elisSeed.s_list_id = elSeed.s_list_id;
                    numEmailListItems = elisSeed.retrieve();
                    // make the list_id = blank becauuse CPS will store the list using it's latest list_id identity field
                    if (numEmailListItems > 0) 
                    {
                        EmailListItems changedLists = changeListIdInEmailListItems(elisSeed);
                        elSeed.m_EmailListItems = changedLists;
                    }
                    elSeed.s_list_id = "";  
                    elpvSeed.s_list_id = ""; 
                }
                    
                    
                if (CustFeature.exists(customer.s_cust_id, Feature.PV_DELIVERY_TRACKER_B2B)) {  
                    EmailList elB2B = new EmailList();
                    EmailListItems elisB2B= new EmailListItems();
                    EmailListPVInfo elpvB2B = new EmailListPVInfo();
                    
                    elB2B.s_cust_id = "0";  // PV lists in adm are under customer 0.
                    elB2B.s_type_id = new Integer(EmailListType.PV_SEED_LIST_B2B).toString();
                    elB2B.retrieve();
                    elB2B.s_cust_id = customer.s_cust_id;  // change customer id to the customer who is receiving the list.
                    elpvB2B.s_list_id = elB2B.s_list_id;
                    numEmailListPVInfo = elpvB2B.retrieve();
                    if (numEmailListPVInfo > 0) elB2B.m_EmailListPVInfo = elpvB2B;
                    es.add(elB2B);
                    elisB2B.s_list_id = elB2B.s_list_id;
                    numEmailListItems = elisB2B.retrieve();
                    // make the list_id = blank becauuse CPS will store the list using it's latest list_id identity field
                    if (numEmailListItems > 0) {
                        EmailListItems changedLists = changeListIdInEmailListItems(elisB2B);
                        elB2B.m_EmailListItems = changedLists;
                    }
                    elB2B.s_list_id = "";  
                    elpvB2B.s_list_id = ""; 
                }
                    
                    
                if(CustFeature.exists(customer.s_cust_id, Feature.PV_DELIVERY_TRACKER_CANADIAN)) {    
                    EmailList elCan = new EmailList();
                    EmailListItems elisCan= new EmailListItems();
                    EmailListPVInfo elpvCan = new EmailListPVInfo();
                    
                    elCan.s_cust_id = "0";  // PV lists in adm are under customer 0.
                    elCan.s_type_id = new Integer(EmailListType.PV_SEED_LIST_CANADIAN).toString();
                    elCan.retrieve();
                    elCan.s_cust_id = customer.s_cust_id;  // change customer id to the customer who is receiving the list.
                    elpvCan.s_list_id = elCan.s_list_id;
                    numEmailListPVInfo = elpvCan.retrieve();
                    if (numEmailListPVInfo > 0) elCan.m_EmailListPVInfo = elpvCan;
                    es.add(elCan);
                    elisCan.s_list_id = elCan.s_list_id;
                    numEmailListItems = elisCan.retrieve();
                    // make the list_id = blank becauuse CPS will store the list using it's latest list_id identity field
                    if (numEmailListItems > 0) {
                        EmailListItems changedLists = changeListIdInEmailListItems(elisCan);
                        elCan.m_EmailListItems = changedLists;
                    }
                    elCan.s_list_id = "";  
                    elpvCan.s_list_id = ""; 
                    
                } 
                
                if (CustFeature.exists(customer.s_cust_id, Feature.PV_DELIVERY_TRACKER_INTERNATIONAL)) {
                    EmailList elIntn = new EmailList();
                    EmailListItems elisIntn= new EmailListItems();
                    EmailListPVInfo elpvIntn = new EmailListPVInfo();
                    
                    elIntn.s_cust_id = "0";  // PV lists in adm are under customer 0.
                    elIntn.s_type_id = new Integer(EmailListType.PV_SEED_LIST_INTERNATIONAL).toString();
                    elIntn.retrieve();
                    elIntn.s_cust_id = customer.s_cust_id;  // change customer id to the customer who is receiving the list.
                    elpvIntn.s_list_id = elIntn.s_list_id;
                    numEmailListPVInfo = elpvIntn.retrieve();
                    if (numEmailListPVInfo > 0) elIntn.m_EmailListPVInfo = elpvIntn;
                    es.add(elIntn);
                    elisIntn.s_list_id = elIntn.s_list_id;
                    numEmailListItems = elisIntn.retrieve();
                    // make the list_id = blank becauuse CPS will store the list using it's latest list_id identity field
                    if (numEmailListItems > 0) {
                        EmailListItems changedLists = changeListIdInEmailListItems(elisIntn);
                        elIntn.m_EmailListItems = changedLists;
                    }
                    elIntn.s_list_id = "";  
                    elpvIntn.s_list_id = ""; 
                } 
                    
                if (CustFeature.exists(customer.s_cust_id, Feature.PV_DELIVERY_TRACKER_CUSTOM)) {    
                    EmailList elCust = new EmailList();
                    EmailListItems elisCust= new EmailListItems();
                    EmailListPVInfo elpvCust = new EmailListPVInfo();
                    
                    elCust.s_cust_id = "0";  // PV lists in adm are under customer 0.
                    elCust.s_type_id = new Integer(EmailListType.PV_SEED_LIST_CUSTOM).toString();
                    elCust.retrieve();
                    elCust.s_cust_id = customer.s_cust_id;  // change customer id to the customer who is receiving the list.
                    elpvCust.s_list_id = elCust.s_list_id;
                    numEmailListPVInfo = elpvCust.retrieve();
                    if (numEmailListPVInfo > 0) elCust.m_EmailListPVInfo = elpvCust;
                    es.add(elCust);
                    elisCust.s_list_id = elCust.s_list_id;
                    numEmailListItems = elisCust.retrieve();
                     // make the list_id = blank becauuse CPS will store the list using it's latest list_id identity field
                    if (numEmailListItems > 0) {
                        EmailListItems changedLists = changeListIdInEmailListItems(elisCust);
                        elCust.m_EmailListItems = changedLists;
                    }
                    elCust.s_list_id = "";  
                    elpvCust.s_list_id = ""; 
                }
                   
                if (CustFeature.exists(customer.s_cust_id, Feature.PV_DESIGN_OPTIMIZER)) {
                    EmailList elOpt = new EmailList();
                    EmailListItems elisOpt = new EmailListItems();
                    EmailListPVInfo elpvOpt = new EmailListPVInfo();
                    
                    elOpt.s_cust_id = "0";  // PV lists in adm are under customer 0.
                    elOpt.s_type_id = new Integer(EmailListType.PV_OPTIMIZER_LIST).toString();
                    elOpt.retrieve();
                    elOpt.s_cust_id = customer.s_cust_id;  // change customer id to the customer who is receiving the list.
                    elpvOpt.s_list_id = elOpt.s_list_id;
                    numEmailListPVInfo = elpvOpt.retrieve();
                    if (numEmailListPVInfo > 0) elOpt.m_EmailListPVInfo = elpvOpt;
                    es.add(elOpt);
                    elisOpt.s_list_id = elOpt.s_list_id;
                    numEmailListItems = elisOpt.retrieve();
                     // make the list_id = blank becauuse CPS will store the list using it's latest list_id identity field
                    if (numEmailListItems > 0) {
                        EmailListItems changedLists = changeListIdInEmailListItems(elisOpt);
                        elOpt.m_EmailListItems = changedLists;
                    }
                    elOpt.s_list_id = "";  
                    elpvOpt.s_list_id = ""; 
                }
                               
	}
        
        
        private static EmailListItems changeListIdInEmailListItems (EmailListItems emailListItems){
            
            // prepares the EmailListItem to be inserted into CPS and RCP.  Since the ADM copy of this table has list_id and item_id not
            // equal to null, the insert on the CPS and RCP sides will fail. So change the xml to have a blank in it so CPS and RCP will
            // store the lists with ids that are unique to CPS.

		EmailListItems returnItems = new EmailListItems();
                EmailListItem item = null;
		for (Enumeration e = emailListItems.elements() ; e.hasMoreElements() ;)
		{
			item = (EmailListItem)e.nextElement();
			item.s_list_id = "";
                        item.s_item_id = "";
                        returnItems.add(item);
                        
		}
                return returnItems;
	}	
            

	// === === ===
		
	public static Customer retrieve4clone
		(
			String sCustId,
			boolean bCloneCustAddr,
			boolean bCloneCustUiSettings,
			boolean bCloneCustPartner,
			boolean bCloneCustModInst,
			boolean bCloneVanityDomain,
			boolean bCloneUniqueIds,
			boolean bCloneUser,
			boolean bCloneAccessMask,
			boolean bCloneCustAttr,
			boolean bCloneUnsubMsg,
			boolean bCloneFromAddress,
			boolean bCloneSendParam,
			boolean bCloneCustFeature,
			boolean bAprvlCusts
		) throws Exception
	{
		Customer cust = new Customer();
		cust.s_cust_id = sCustId;
		if(cust.retrieve() < 1) return null;

		// === === ===

		if (bCloneCustAddr)
		{
			CustAddr ca = new CustAddr();
			ca.s_cust_id = sCustId;
			if(ca.retrieve() > 0) cust.m_CustAddr = ca;
		}
		
		// === === ===
				
		if(bCloneCustUiSettings)
		{
			CustUiSettings cus = new CustUiSettings();
			cus.s_cust_id = sCustId;
			if(cus.retrieve() > 0) cust.m_CustUiSettings = cus;
		}
		
		// === === ===
				
		if (bCloneCustPartner)
		{
			CustPartners cp = new CustPartners();
			cp.s_cust_id = sCustId;
			if(cp.retrieve() > 0 ) cust.m_CustPartners = cp;
		}
		
		// === === ===
				
		if (bCloneCustModInst)
		{
			CustModInsts cmis = new CustModInsts();
			cmis.s_cust_id = sCustId;
			if (cmis.retrieve() > 0)
			{
				if (bCloneVanityDomain)
				{
					CustModInst cmi = null;
					for (Enumeration e = cmis.elements() ; e.hasMoreElements() ;)
					{
						cmi = (CustModInst)e.nextElement();
						VanityDomains vds = new VanityDomains();
						vds.s_cust_id = cmi.s_cust_id;
						vds.s_mod_inst_id = cmi.s_mod_inst_id;
						if(vds.retrieve() > 0) cmi.m_VanityDomains = vds;
					}
				}
				cust.m_CustModInsts = cmis;
			}
		}

		// === === ===
		
		if (bCloneUniqueIds)
		{
			CustUniqueIds cuis = new CustUniqueIds();
			cuis.s_cust_id = sCustId;
			if(cuis.retrieve() > 0) cust.m_CustUniqueIds = cuis;
		}

		// === === ===
		
		if (bCloneUser)
		{
			Users us = new Users();
			us.s_cust_id = sCustId;
			if (us.retrieve() > 0)
			{
				User u = null;
				for (Enumeration e = us.elements() ; e.hasMoreElements() ;)
				{
					u = (User)e.nextElement();
					
					UserUiSettings uus = new UserUiSettings();
					uus.s_user_id = u.s_user_id;
					if(uus.retrieve() > 0) u.m_UserUiSettings = uus;

					if (bCloneAccessMask)
					{
						AccessMasks ams = new AccessMasks();
						ams.s_user_id = u.s_user_id;
						if(ams.retrieve() > 0) u.m_AccessMasks = ams;
					}
				}
				cust.m_Users = us;
			}
		}

		// === === ===

		{
			String sSql =
				" SELECT" +
				"	ca.cust_id," +
				"	ca.attr_id," +
				"	ca.display_name," +
				"	ca.display_seq," +
				"	ca.fingerprint_seq," +
				"	ca.sync_flag," +
				"	ca.hist_flag," +
				"	ca.newsletter_flag," +
                    "	ca.recip_view_seq " +
				" FROM sadm_cust_attr ca, sadm_attribute a" +
				" WHERE ca.cust_id = " + sCustId +
				" AND ca.attr_id = a.attr_id" +
				" AND " + ((!bCloneCustAttr)?("a.cust_id=0"):("a.cust_id!=" + sCustId)) +
				" ORDER BY a.cust_id, a.attr_id ";

			CustAttrs cas = new CustAttrs();			
			cas.m_sRetrieveSql = sSql;
			if(cas.retrieve() > 0) cust.m_CustAttrs = cas;
		}
		
		// === === ===
				
		if (bCloneUnsubMsg)
		{
			UnsubMsgs ums = new UnsubMsgs();
			ums.s_cust_id = sCustId;
			if(ums.retrieve() > 0 ) cust.m_UnsubMsgs = ums;
		}
		
		// === === ===

		if (bCloneFromAddress)
		{
			FromAddresses fas = new FromAddresses();
			fas.s_cust_id = sCustId;
			if(fas.retrieve() > 0 ) cust.m_FromAddresses = fas;
		}

		// === === ===

		if (bCloneSendParam)
		{
			CustSendParam csp = new CustSendParam();
			csp.s_cust_id = sCustId;
			if(csp.retrieve() > 0 ) cust.m_CustSendParam = csp;
		}
		
		// === === ===
		
		if (bCloneCustFeature)
		{
			CustFeatures cfs = new CustFeatures();
			cfs.s_cust_id = sCustId;
			if(cfs.retrieve() > 0 ) cust.m_CustFeatures = cfs;
		}

		// === === ===
		
		if (bAprvlCusts)
		{
			AprvlCusts acs = new AprvlCusts();
			acs.s_cust_id = sCustId;
			if(acs.retrieve() > 0 ) cust.m_AprvlCusts = acs;
		}
	
		return cust;
	}
}
