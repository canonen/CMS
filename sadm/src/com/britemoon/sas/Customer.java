package com.britemoon.sas;

import com.britemoon.*;




import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class Customer extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_cust_name = null;
	public String s_level_id = null;
	public String s_login_name = null;
	public String s_status_id = null;
	public String s_max_bbacks = null;
	public String s_max_consec_bbacks = null;
	public String s_descrip = null;
	public String s_parent_cust_id = null;
	public String s_upd_rule_id = null;
	public String s_upd_hierarchy_id = null;
	public String s_unsub_hierarchy_id = null;
	public String s_auto_report_flag = null;
	public String s_max_bback_days = null;
	public String s_max_consec_bback_days = null;
	public String s_pass_expire_interval = null;
	public String s_pass_notify_days = null;
	public String s_cti_group_id = null;
	//release 5.9 auto report update feature
	public String s_auto_report_frequency = null;
	public String s_auto_report_std_duration = null;
	public String s_auto_report_auto_duration = null;
        public String s_max_domains_on_report = null;
	
	//log4j implementation
	private static Logger logger = Logger.getLogger(Customer.class.getName());
	// === Parents ===

	// === Children ===

	public CustAddr m_CustAddr = null;
	public CustUiSettings m_CustUiSettings = null;
	public CustSendParam m_CustSendParam = null;
	
	public CustAttrs m_CustAttrs = null;
	public CustModInsts m_CustModInsts = null;
	public CustPartners m_CustPartners = null;
	public CustUniqueIds m_CustUniqueIds = null;
	
	public CustFeatures m_CustFeatures = null;

	public FromAddresses m_FromAddresses = null;
	public UnsubMsgs m_UnsubMsgs = null;
	public Users m_Users = null;

	public AprvlCusts m_AprvlCusts = null;
	public ImgCustFileExtensions m_ImgCustFileExtensions = null;
	public ImgCustRefreshInfo m_ImgCustRefreshInfo = null;
        public EmailLists m_EmailLists = null;
       
	public Entities m_Entities = null;
	public CustomerSettings m_CustomerSettings = null;

	// === Constructors ===

	public Customer()
	{
	}
	
	public Customer(String sCustId) throws Exception
	{
		s_cust_id = sCustId;
		retrieve();
	}

	public Customer(String sCustId, String sLoginName) throws Exception
	{
		s_cust_id = sCustId;
		s_login_name = sLoginName;
		retrieve();
	}

	public Customer(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" EXEC usp_sadm_cust_retrieve @cust_id=?, @login_name=?";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);

		if(s_login_name == null) pstmt.setString(2, s_login_name);
		else pstmt.setBytes(2, s_login_name.getBytes("UTF-8"));

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
		byte[] b = null;

		s_cust_id = rs.getString(1);

		b = rs.getBytes(2);
		s_cust_name = (b == null)?null:new String(b,"UTF-8");

		s_level_id = rs.getString(3);

		b = rs.getBytes(4);
		s_login_name = (b == null)?null:new String(b,"UTF-8");

		s_status_id = rs.getString(5);
		s_max_bbacks = rs.getString(6);

		b = rs.getBytes(7);
		s_descrip = (b == null)?null:new String(b,"UTF-8");

		s_parent_cust_id = rs.getString(8);
		s_upd_rule_id = rs.getString(9);
		s_upd_hierarchy_id = rs.getString(10);
		s_unsub_hierarchy_id = rs.getString(11);
		s_auto_report_flag = rs.getString(12);
		s_max_bback_days = rs.getString(13);
		s_pass_expire_interval = rs.getString(14);
		s_pass_notify_days = rs.getString(15);
		s_cti_group_id = rs.getString(16);
		s_auto_report_frequency = rs.getString(17);
		s_auto_report_std_duration = rs.getString(18);
		s_auto_report_auto_duration = rs.getString(19);
		s_max_consec_bbacks = rs.getString(20);
		s_max_consec_bback_days = rs.getString(21);
                s_max_domains_on_report = rs.getString(22);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_customer_save" +
		"	@cust_id=?," +
		"	@cust_name=?," +
		"	@level_id=?," +
		"	@login_name=?," +
		"	@status_id=?," +
		"	@max_bbacks=?," +
		"	@descrip=?," +
		"	@parent_cust_id=?," +
		"	@upd_rule_id=?," +
		"	@upd_hierarchy_id=?," +
		"	@unsub_hierarchy_id=?," +
		"	@auto_report_flag=?," +
		"	@max_bback_days=?," +
		"	@pass_expire_interval=?," +
		"	@pass_notify_days=?," +
		"	@cti_group_id=?," +
		"	@auto_report_frequency=?," +
		"	@auto_report_std_duration=?," +
		"	@auto_report_auto_duration=?, " +
		"	@max_consec_bbacks=?," +
		"	@max_consec_bback_days=?,"+
                "       @max_domains_on_report=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		
		if(s_cust_name == null) pstmt.setString(2, s_cust_name);
		else pstmt.setBytes(2, s_cust_name.getBytes("UTF-8"));
		
		pstmt.setString(3, s_level_id);
		
		if(s_login_name == null) pstmt.setString(4, s_login_name);
		else pstmt.setBytes(4, s_login_name.getBytes("UTF-8"));
		
		pstmt.setString(5, s_status_id);
		pstmt.setString(6, s_max_bbacks);
		
		if(s_descrip == null) pstmt.setString(7, s_descrip);
		else pstmt.setBytes(7, s_descrip.getBytes("UTF-8"));
		
		pstmt.setString(8, s_parent_cust_id);
		pstmt.setString(9, s_upd_rule_id);
		pstmt.setString(10, s_upd_hierarchy_id);
		pstmt.setString(11, s_unsub_hierarchy_id);
		pstmt.setString(12, s_auto_report_flag);		
		pstmt.setString(13, s_max_bback_days);		
		pstmt.setString(14, s_pass_expire_interval);		
		pstmt.setString(15, s_pass_notify_days);		
		pstmt.setString(16, s_cti_group_id);
		pstmt.setString(17, s_auto_report_frequency);
		pstmt.setString(18, s_auto_report_std_duration);
		pstmt.setString(19, s_auto_report_auto_duration);
		pstmt.setString(20, s_max_consec_bbacks);
		pstmt.setString(21, s_max_consec_bback_days);
                pstmt.setString(22, s_max_domains_on_report);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_CustAddr!=null)
		{
			m_CustAddr.s_cust_id = s_cust_id;
			m_CustAddr.save(conn);
		}

		if (m_CustUiSettings!=null)
		{
			m_CustUiSettings.s_cust_id = s_cust_id;
			m_CustUiSettings.save(conn);
		}

		if (m_CustSendParam!=null)
		{
			m_CustSendParam.s_cust_id = s_cust_id;
			m_CustSendParam.save(conn);
		}

		if (m_CustAttrs!=null)
		{
			m_CustAttrs.s_cust_id = s_cust_id;
			m_CustAttrs.save(conn);
		}

		if (m_CustModInsts!=null)
		{
			m_CustModInsts.s_cust_id = s_cust_id;
			m_CustModInsts.save(conn);
		}

		if (m_CustPartners!=null)
		{
			m_CustPartners.s_cust_id = s_cust_id;
			m_CustPartners.save(conn);
		}

		if (m_CustUniqueIds!=null)
		{
			m_CustUniqueIds.s_cust_id = s_cust_id;
			m_CustUniqueIds.save(conn);
		}

		if (m_CustFeatures!=null)
		{
			m_CustFeatures.s_cust_id = s_cust_id;
			m_CustFeatures.save(conn);
		}

		if (m_FromAddresses!=null)
		{
			m_FromAddresses.s_cust_id = s_cust_id;
			m_FromAddresses.save(conn);
		}

		if (m_UnsubMsgs!=null)
		{
			m_UnsubMsgs.s_cust_id = s_cust_id;
			m_UnsubMsgs.save(conn);
		}

		if (m_Users!=null)
		{
			m_Users.s_cust_id = s_cust_id;
			m_Users.save(conn);
		}
                
                if (m_EmailLists!=null)
		{
			m_EmailLists.s_cust_id = s_cust_id;
			m_EmailLists.save(conn);
		}
                
 		if (m_AprvlCusts!=null)
		{
			m_AprvlCusts.s_cust_id = s_cust_id;
			m_AprvlCusts.save(conn);
		}

		if (m_ImgCustFileExtensions!=null)
		{
			m_ImgCustFileExtensions.s_cust_id = s_cust_id;
			m_ImgCustFileExtensions.save(conn);
		}

		if (m_ImgCustRefreshInfo!=null)
		{
			m_ImgCustRefreshInfo.s_cust_id = s_cust_id;
			m_ImgCustRefreshInfo.save(conn);
		}
		
		if (m_Entities!=null)
		{
			m_Entities.s_cust_id = s_cust_id;
			m_Entities.save(conn);
		}
        if (m_CustomerSettings != null) {
            m_CustomerSettings.s_cust_id = s_cust_id;
            m_CustomerSettings.save(conn);
        }
		
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_customer" +
		" WHERE" +
		"	(cust_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_CustAddr!=null) m_CustAddr.delete(conn);
		if(m_CustUiSettings!=null) m_CustUiSettings.delete(conn);
		if(m_CustSendParam!=null) m_CustSendParam.delete(conn);
		if(m_CustAttrs!=null) m_CustAttrs.delete(conn);
		if(m_CustModInsts!=null) m_CustModInsts.delete(conn);
		if(m_CustPartners!=null) m_CustPartners.delete(conn);
		if(m_CustUniqueIds!=null) m_CustUniqueIds.delete(conn);
		if(m_CustFeatures!=null) m_CustFeatures.delete(conn);		
		if(m_FromAddresses!=null) m_FromAddresses.delete(conn);
		if(m_UnsubMsgs!=null) m_UnsubMsgs.delete(conn);
		if(m_Users!=null) m_Users.delete(conn);
                if(m_EmailLists!=null) m_EmailLists.delete(conn);

		if(m_AprvlCusts!=null) m_AprvlCusts.delete(conn);
		if(m_ImgCustFileExtensions!=null) m_ImgCustFileExtensions.delete(conn);
		if(m_ImgCustRefreshInfo!=null) m_ImgCustRefreshInfo.delete(conn);		

		if(m_Entities!=null) m_Entities.delete(conn);
        if (m_CustomerSettings != null) m_CustomerSettings.delete(conn);
		
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "customer";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_cust_name != null ) XmlUtil.appendCDataChild(e, "cust_name", s_cust_name);
		if( s_level_id != null ) XmlUtil.appendTextChild(e, "level_id", s_level_id);
		if( s_login_name != null ) XmlUtil.appendCDataChild(e, "login_name", s_login_name);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_max_bbacks != null ) XmlUtil.appendTextChild(e, "max_bbacks", s_max_bbacks);
		if( s_descrip != null ) XmlUtil.appendCDataChild(e, "descrip", s_descrip);
		if( s_parent_cust_id != null ) XmlUtil.appendTextChild(e, "parent_cust_id", s_parent_cust_id);
		if( s_upd_rule_id != null ) XmlUtil.appendTextChild(e, "upd_rule_id", s_upd_rule_id);
		if( s_upd_hierarchy_id != null ) XmlUtil.appendTextChild(e, "upd_hierarchy_id", s_upd_hierarchy_id);
		if( s_unsub_hierarchy_id != null ) XmlUtil.appendTextChild(e, "unsub_hierarchy_id", s_unsub_hierarchy_id);
		if( s_auto_report_flag != null ) XmlUtil.appendTextChild(e, "auto_report_flag", s_auto_report_flag);
		if( s_max_bback_days != null ) XmlUtil.appendTextChild(e, "max_bback_days", s_max_bback_days);
		if( s_pass_expire_interval != null ) XmlUtil.appendTextChild(e, "pass_expire_interval", s_pass_expire_interval);
		if( s_pass_notify_days != null ) XmlUtil.appendTextChild(e, "pass_notify_days", s_pass_notify_days);
		if( s_cti_group_id != null ) XmlUtil.appendTextChild(e, "cti_group_id", s_cti_group_id);
		if( s_auto_report_frequency != null ) XmlUtil.appendTextChild(e, "auto_report_frequency", s_auto_report_frequency);
		if( s_auto_report_std_duration != null ) XmlUtil.appendTextChild(e, "auto_report_std_duration", s_auto_report_std_duration);
		if( s_auto_report_auto_duration != null ) XmlUtil.appendTextChild(e, "auto_report_auto_duration", s_auto_report_auto_duration);
		if( s_max_consec_bbacks != null ) XmlUtil.appendTextChild(e, "max_consec_bbacks", s_max_consec_bbacks);
		if( s_max_consec_bback_days != null ) XmlUtil.appendTextChild(e, "max_consec_bback_days", s_max_consec_bback_days);
                if( s_max_domains_on_report != null ) XmlUtil.appendTextChild(e, "max_domains_on_report", s_max_domains_on_report);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_CustAddr != null) appendChild(e, m_CustAddr);
		if (m_CustUiSettings != null) appendChild(e, m_CustUiSettings);
		if (m_CustSendParam != null) appendChild(e, m_CustSendParam);		
		if (m_CustAttrs != null) appendChild(e, m_CustAttrs);
		if (m_CustModInsts != null) appendChild(e, m_CustModInsts);
		if (m_CustPartners != null) appendChild(e, m_CustPartners);
		if (m_CustUniqueIds != null) appendChild(e, m_CustUniqueIds);
		if (m_CustFeatures != null) appendChild(e, m_CustFeatures);
		if (m_FromAddresses != null) appendChild(e, m_FromAddresses);
		if (m_UnsubMsgs != null) appendChild(e, m_UnsubMsgs);
		if (m_Users != null) appendChild(e, m_Users);
                if (m_EmailLists !=null) appendChild(e, m_EmailLists);
		
		if (m_AprvlCusts != null) appendChild(e, m_AprvlCusts);
		if (m_ImgCustFileExtensions != null) appendChild(e, m_ImgCustFileExtensions);
		if (m_ImgCustRefreshInfo != null) appendChild(e, m_ImgCustRefreshInfo);
		
		if (m_Entities != null) appendChild(e, m_Entities);
        if (m_CustomerSettings != null) appendChild(e, m_CustomerSettings);


    }
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_cust_name = XmlUtil.getChildCDataValue(e, "cust_name");
		s_level_id = XmlUtil.getChildTextValue(e, "level_id");
		s_login_name = XmlUtil.getChildCDataValue(e, "login_name");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_max_bbacks = XmlUtil.getChildTextValue(e, "max_bbacks");
		s_descrip = XmlUtil.getChildCDataValue(e, "descrip");
		s_parent_cust_id = XmlUtil.getChildTextValue(e, "parent_cust_id");
		s_upd_rule_id = XmlUtil.getChildTextValue(e, "upd_rule_id");
		s_upd_hierarchy_id = XmlUtil.getChildTextValue(e, "upd_hierarchy_id");
		s_unsub_hierarchy_id = XmlUtil.getChildTextValue(e, "unsub_hierarchy_id");
		s_auto_report_flag = XmlUtil.getChildTextValue(e, "auto_report_flag");
		s_max_bback_days = XmlUtil.getChildTextValue(e, "max_bback_days");
		s_pass_expire_interval = XmlUtil.getChildTextValue(e, "pass_expire_interval");
		s_pass_notify_days = XmlUtil.getChildTextValue(e, "pass_notify_days");
		s_cti_group_id = XmlUtil.getChildTextValue(e, "cti_group_id");
		s_auto_report_frequency = XmlUtil.getChildTextValue(e, "auto_report_frequency");
		s_auto_report_std_duration = XmlUtil.getChildTextValue(e, "auto_report_std_duration");
		s_auto_report_auto_duration = XmlUtil.getChildTextValue(e, "auto_report_auto_duration");
		s_max_consec_bbacks = XmlUtil.getChildTextValue(e, "max_consec_bbacks");
		s_max_consec_bback_days = XmlUtil.getChildTextValue(e, "max_consec_bback_days");
                s_max_domains_on_report = XmlUtil.getChildTextValue(e, "max_domains_on_report");

	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eCustAddr = XmlUtil.getChildByName(e, "cust_addr");
		if(eCustAddr != null) m_CustAddr = new CustAddr(eCustAddr);

		Element eCustUiSettings = XmlUtil.getChildByName(e, "cust_ui_settings");
		if(eCustUiSettings != null) m_CustUiSettings = new CustUiSettings(eCustUiSettings);

		Element eCustSendParam = XmlUtil.getChildByName(e, "cust_send_param");
		if(eCustSendParam != null) m_CustSendParam = new CustSendParam(eCustSendParam);

		Element eCustAttrs = XmlUtil.getChildByName(e, "cust_attrs");
		if(eCustAttrs != null) m_CustAttrs = new CustAttrs(eCustAttrs);

		Element eCustModInsts = XmlUtil.getChildByName(e, "cust_mod_insts");
		if(eCustModInsts != null) m_CustModInsts = new CustModInsts(eCustModInsts);

		Element eCustPartners = XmlUtil.getChildByName(e, "cust_partners");
		if(eCustPartners != null) m_CustPartners = new CustPartners(eCustPartners);

		Element eCustUniqueIds = XmlUtil.getChildByName(e, "cust_unique_ids");
		if(eCustUniqueIds != null) m_CustUniqueIds = new CustUniqueIds(eCustUniqueIds);

		Element eCustFeatures = XmlUtil.getChildByName(e, "cust_features");
		if(eCustFeatures != null) m_CustFeatures = new CustFeatures(eCustFeatures);

		Element eFromAddresses = XmlUtil.getChildByName(e, "from_addresses");
		if(eFromAddresses != null) m_FromAddresses = new FromAddresses(eFromAddresses);

		Element eUnsubMsgs = XmlUtil.getChildByName(e, "unsub_msgs");
		if(eUnsubMsgs != null) m_UnsubMsgs = new UnsubMsgs(eUnsubMsgs);

		Element eUsers = XmlUtil.getChildByName(e, "users");
		if(eUsers != null) m_Users = new Users(eUsers);
                
                Element eEmailLists = XmlUtil.getChildByName(e, "email_lists");
		if(eEmailLists != null) m_EmailLists = new EmailLists(eEmailLists);
		
		Element eAprvlCusts = XmlUtil.getChildByName(e, "aprvl_custs");
		if(eAprvlCusts != null) m_AprvlCusts = new AprvlCusts(eAprvlCusts);

		Element eImgCustFileExtensions = XmlUtil.getChildByName(e, "img_cust_file_extensions");
		if(eImgCustFileExtensions != null) m_ImgCustFileExtensions = new ImgCustFileExtensions(eImgCustFileExtensions);
		
		Element eImgCustRefreshInfo = XmlUtil.getChildByName(e, "img_cust_refresh_info");
		if(eImgCustRefreshInfo != null) m_ImgCustRefreshInfo = new ImgCustRefreshInfo(eImgCustRefreshInfo);

		Element eEntities = XmlUtil.getChildByName(e, "entities");
		if(eEntities != null) m_Entities = new Entities(eEntities);

        Element eCustomerSettings = XmlUtil.getChildByName(e, "customer_settings");
        if (eCustomerSettings != null) m_CustomerSettings = new CustomerSettings(eCustomerSettings);
	}

	// === Other Methods ===
}


