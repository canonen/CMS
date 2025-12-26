package com.britemoon.cps;

import com.britemoon.cps.adm.CustFeature;
import org.apache.log4j.Logger;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.FileInputStream;
import java.util.Enumeration;
import java.util.Properties;

public class UIEnvironment {
    private User m_User = null;
    private Customer m_Customer = null;
    private Customer m_DestinationCustomer = null;
    private Customer m_ActiveCustomer = null;

    // === for Kevin to keep per session settings ===

    private Properties m_Props = null;

    public String getProp(String key) {
        return m_Props.getProperty(key);
    }

    public Object setProp(String key, String value) {
        return m_Props.setProperty(key, value);
    }

    public Properties getProps() {
        return m_Props;
    }

    // obsolete
    public String getSessionProperty(String key) {
        return getProp(key);
    }

    public Object setSessionProperty(String key, String value) {
        return setProp(key, value);
    }

    public Properties getSessionProperties() {
        return getProps();
    }

    // === === ===

    final public static int SINGLE_CUSTOMER = 1;
    final public static int MULTI_CUSTOMER = 2;
    private int m_nUIMode = SINGLE_CUSTOMER;
    private static Logger logger = Logger.getLogger(UIEnvironment.class.getName());

    public int getUIMode() {
        return m_nUIMode;
    }

    public void setUIMode(int nUIMode) {
        m_nUIMode = nUIMode;
    }

    // === Constructors ===

    public UIEnvironment(HttpSession session, User user, Customer cust) throws Exception {
        setup(session, user, cust);
        session.setAttribute("ui", this);
    }

    private void setup(HttpSession session, User user, Customer cust) throws Exception {
        m_User = user;
        m_Customer = cust;
        retriveCustTree(m_Customer);

        m_DestinationCustomer = m_Customer;
        m_ActiveCustomer = m_Customer;

        session.setAttribute("cust", cust);
        session.setAttribute("user", user);

        adjustCustUiSettings(session, cust.s_cust_id);
        adjustUserUiSettings(user.s_user_id);
    }

    // === === ===

    private static void retriveCustTree(Customer cust) throws Exception {
        Customers custs = new Customers();
        custs.s_parent_cust_id = cust.s_cust_id;
        custs.b_is_hyatt = getFeatureAccess(Feature.HYATT, cust.s_cust_id, UIType.ADVANCED);
        if (custs.retrieve() > 0) {
            for (Enumeration e = custs.elements(); e.hasMoreElements(); )
                retriveCustTree((Customer) e.nextElement());
            cust.m_Customers = custs;
        }
    }

    public Customer getSuperiorCustomer() {
        return m_Customer;
    }

    public Customer getDestinationCustomer() {
        return m_DestinationCustomer;
    }

    public Customer getActiveCustomer() {
        return m_ActiveCustomer;
    }

    public Customer setDestinationCustomer(HttpSession session, String sCustId) throws Exception {
        Customer cust = findCustomer(sCustId, m_Customer);
        if (cust == null)
            throw new Exception("Invalid customer to set as destination customer");
        m_DestinationCustomer = cust;
        return m_DestinationCustomer;
    }

    public Customer setActiveCustomer(HttpSession session, String sCustId) throws Exception {
        Customer cust = findCustomer(sCustId, m_Customer); //was m_DestinationCustomer
        if (cust == null)
            throw new Exception("Invalid customer to set as active customer");
        m_ActiveCustomer = cust;
        session.setAttribute("cust", m_ActiveCustomer);

        adjustCustUiSettings(session, sCustId);

        return m_ActiveCustomer;
    }

    private static Customer findCustomer(String sCustId, Customer cRootCustomer) {
        if (cRootCustomer.s_cust_id.equals(sCustId)) return cRootCustomer;

        Customers custs = cRootCustomer.m_Customers;
        if (custs == null) return null;

        Customer cust = null;
        for (Enumeration e = custs.elements(); e.hasMoreElements(); ) {
            cust = findCustomer(sCustId, (Customer) e.nextElement());
            if (cust != null) break;
        }

        return cust;
    }

    private void adjustCustUiSettings(HttpSession session, String sCustId) throws Exception {
        CustUiSettings cui = new CustUiSettings(sCustId);
        m_Props = loadProps(session, cui.s_config_file);

        // === === ===

        s_css_filename = getProp("css_filename");
        if (s_css_filename == null) s_css_filename = cui.s_css_filename;
        if (s_css_filename == null) s_css_filename = "/ccps/ui/css/style.css";

        s_frame_dir = getProp("frame_dir");
        if (s_frame_dir == null) s_frame_dir = cui.s_frame_dir;
        if (s_frame_dir == null) s_frame_dir = "/ccps/ui/nav/index.jsp";
    }

    private void adjustUserUiSettings(String sUserId) throws Exception {
        UserUiSettings uui = new UserUiSettings(sUserId);

        s_category_id = uui.s_category_id;
        s_recip_view_count = uui.s_recip_view_count;
        s_default_page_size = uui.s_default_page_size;
        s_ui_type_id = (uui.s_ui_type_id == null) ? String.valueOf(UIType.ADVANCED) : uui.s_ui_type_id;
        n_ui_type_id = Integer.parseInt(s_ui_type_id);
    }

    // === === ===

    private static Properties loadProps(HttpSession session, String sConfigFile) throws Exception {
        ServletContext context = session.getServletContext();
        return loadProps(context, sConfigFile);
    }

    public static Properties loadProps(ServletContext context, String sConfigFile) throws Exception {
        String sContextRoot = context.getRealPath("/");
        String sResourcesDir = sContextRoot + "\\WEB-INF\\resources";
        if (sConfigFile == null) sConfigFile = "default.conf";

        return loadProps(sResourcesDir, sConfigFile);
    }

    private static Properties loadProps(String sResourcesDir, String sPropsFileName) throws Exception {
        sPropsFileName = sResourcesDir + "\\" + sPropsFileName;
        Properties props = loadProps(sPropsFileName);

        String sDefaults = props.getProperty("defaults");

        Properties defprops = null;
        if (sDefaults == null) defprops = loadProps(sResourcesDir + "\\default.conf");
        else defprops = loadProps(sResourcesDir, sDefaults);

        defprops.putAll(props);

        return defprops;
    }

    private static Properties loadProps(String sPropsFileName) throws Exception {
        Properties props = new Properties();

        File fPropsFile = new File(sPropsFileName);
        if (!fPropsFile.exists()) return props;

        FileInputStream fisProps = null;
        try {
            fisProps = new FileInputStream(fPropsFile);
            props.load(fisProps);
        } catch (Exception ex) {
            logger.error("Exception: ", ex);
            throw ex;
        } finally {
            if (fisProps != null) fisProps.close();
        }

        return props;
    }

    // === Settings from user ===

    public String s_category_id = null;
    public String s_recip_view_count = null;
    public String s_default_page_size = null;

    public int n_ui_type_id = UIType.ADVANCED;
    public String s_ui_type_id = String.valueOf(UIType.ADVANCED);

    // === Settings from customer ===U

    public String s_css_filename = "/ccps/ui/css/style.css";
    public String s_frame_dir = "/ccps/ui/nav/index.jsp";
    public String s_config_file = "default.conf";

    // === === ===

    public boolean getFeatureAccess(int i_feature_id) throws Exception {
        return getFeatureAccess(i_feature_id, m_User.s_cust_id, n_ui_type_id);
    }

    public static boolean getFeatureAccess(int i_feature_id, String s_cust_id, int nUITypeID) throws Exception {
        boolean bReturn = true;
        boolean bFeat = CustFeature.exists(s_cust_id, i_feature_id);


        switch (i_feature_id) {
            case Feature.BRITE_CONNECT:
                if (!bFeat) bReturn = false;
                break;

            case Feature.BRITE_TRACK:
                if (!bFeat) bReturn = false;
                break;

            case Feature.MS_CRM:
                if (!bFeat) bReturn = false;
                break;

            case Feature.CHAPTER_SCRAPES:
                if (!bFeat) bReturn = false;
                break;

            case Feature.QUICK_CAMPAIGN:
                if (!bFeat) bReturn = false;
                break;

            case Feature.IMAGE_LIBRARY:
                if (!bFeat) bReturn = false;
                break;

            case Feature.TEMPLATE_ADMIN:
                if (!bFeat) bReturn = false;
                break;

            case Feature.GLOBAL_REPORTS:
                if (!bFeat) bReturn = false;
                break;

            case Feature.SUPER_REPORTS:
                if (!bFeat) bReturn = false;
                break;

            case Feature.CUSTOMIZE_REPORTS:
                if (!bFeat) bReturn = false;
                break;

            case Feature.SUBSCRIPTION_ADMIN:
                if (!bFeat) bReturn = false;
                break;

            case Feature.AUTO_LINK_SCAN_TEMPLATES:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PRINT_ENABLED:
                if (!bFeat) bReturn = false;
                break;

            case Feature.HYATT:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PRINT_DEMO:
                if (!bFeat) bReturn = false;
                break;

            case Feature.RECIP_OWNERSHIP:
                if (!bFeat) bReturn = false;
                break;

            case Feature.EXCLUSION_LIST:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.NOTIFICATION_LIST:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.S2F_CAMP:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.AUTO_CAMP:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.WEB_DM_CALL:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;

                if (!bFeat) bReturn = false;
                break;

            case Feature.FROM_ADDR_PERS:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.FROM_NAME_PERS:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.SUBJECT_PERS:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.FILTER_PREVIEW:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.SAMPLE_SET:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.CAMP_STEP_2:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.CAMP_STEP_3:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.SEED_LIST:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.LINKED_CAMPAIGN:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.FREQ_EXCLUSION:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.SUBSET_SEND_OUT:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.RECIP_THROTTLE:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.QUEUE_STEP:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.SPECIFIED_TEST:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.TESTING_HELP:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.MY_DATABASE:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.EXPORTS:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;

                if (!bFeat) bReturn = false;
                break;

            case Feature.RECIPIENT_SEARCH:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;

                if (!bFeat) bReturn = false;
                break;

            case Feature.MY_CONTENT:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.DYNAMIC_CONTENT:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;

                if (!bFeat) bReturn = false;
                break;

            case Feature.EXTERNAL_CONTENT:
                if (nUITypeID == UIType.STANDARD) bReturn = false;
                else if (nUITypeID == UIType.HYATT_USER) bReturn = false;

                if (!bFeat) bReturn = false;
                break;

            case Feature.AUTO_LINK_NAMES:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.HELP_DOC:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.FAQS:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.SUPPORT_REQUEST:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            case Feature.HELP_SEARCH:
                if (nUITypeID == UIType.HYATT_USER) bReturn = false;
                else bReturn = true;
                break;

            // added for release 5.9 , reporting changes
            case Feature.PV_DELIVERY_TRACKER:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PV_LOGIN:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PV_DESIGN_OPTIMIZER:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PV_CONTENT_SCORER:
                if (!bFeat) bReturn = false;
                break;

            case Feature.UPDATE_AUTO_REPORT:
                if (!bFeat) bReturn = false;
                break;
            // end release 5.9 changes

            // added for release 6.0 , resubscribe reciepient
            case Feature.RECIP_RESUBSCRIBE:
                if (!bFeat) bReturn = false;
                break;

            // added for release 6.1 , unsubscribe message
            case Feature.UNSUB_EDIT:
                if (!bFeat) bReturn = false;
                break;

            case Feature.DYNAMIC_CONTENT_REPORTING:
                if (!bFeat) bReturn = false;
                break;

            case Feature.WS_CAMPAIGN:
                if (!bFeat) bReturn = false;
                break;

            case Feature.RECOMMENDATION:
                if (!bFeat) bReturn = false;
                break;

            case Feature.SMART_WIDGET:
                if (!bFeat) bReturn = false;
                break;

            case Feature.WEB_PUSH:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PERSONAL_SEARCH:
                if (!bFeat) bReturn = false;
                break;

            case Feature.CRM_ADS:
                if (!bFeat) bReturn = false;
                break;

            case Feature.CUSTOMER_JOURNEY:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PERFORMANCE_HUB:
                if (!bFeat) bReturn = false;
                break;

            case Feature.STORE:
                if (!bFeat) bReturn = false;
                break;

            case Feature.ECOMMERCE_TRACKING:
                if (!bFeat) bReturn = false;
                break;

            case Feature.PRODUCTS:
                if (!bFeat) bReturn = false;
                break;

            case Feature.SMTP:
                if (!bFeat) bReturn = false;
                break;

            case Feature.IYS:
                if (!bFeat) bReturn = false;
                break;

            case Feature.CONTACT_SUPPORT:
                if (!bFeat) bReturn = false;
                break;

            case Feature.REPORTS:
                if (!bFeat) bReturn = false;
                break;
			case Feature.APP_PUSH:
				if (!bFeat) bReturn = false;
                break;
			case Feature.MOBIL_DEV_IVT:
				if (!bFeat) bReturn = false;
				break;
			case Feature.MOBIL_DEV_IVT_LITE:
				if (!bFeat) bReturn = false;
				break;
			case Feature.FIGENSOFT:
				if (!bFeat) bReturn = false;
				break;
			case Feature.SMARTWIDGET:
				if (!bFeat) bReturn = false;
				break;
			case Feature.STICKY_BAR:
				if (!bFeat) bReturn = false;
				break;
			case Feature.POPUP_GROW:
				if (!bFeat) bReturn = false;
				break;
			case Feature.POPUP_LOYALTY:
				if (!bFeat) bReturn = false;
				break;
			case Feature.POPUP_RECO:
				if (!bFeat) bReturn = false;
				break;
			case Feature.DRAWER:
				if (!bFeat) bReturn = false;
				break;
			case Feature.RECENTLY_VIEW:
				if (!bFeat) bReturn = false;
				break;
			case Feature.BLOCKED_WEBPUSH:
				if (!bFeat) bReturn = false;
				break;
			case Feature.EXIT_INTENT:
				if (!bFeat) bReturn = false;
				break;
			case Feature.NOTIFICATION_CENTER:
				if (!bFeat) bReturn = false;
				break;
			case Feature.STICKY_BAR_COUNTER:
				if (!bFeat) bReturn = false;
				break;
			case Feature.PRODUCT_ALERT:
				if (!bFeat) bReturn = false;
				break;
			case Feature.DRAWER_DISCOUNT:
				if (!bFeat) bReturn = false;
				break;
			case Feature.COUNTDOWN:
				if (!bFeat) bReturn = false;
				break;
			case Feature.DEAL_BOX:
				if (!bFeat) bReturn = false;
				break;
			case Feature.DEAL_DAY:
				if (!bFeat) bReturn = false;
				break;
			case Feature.UPSELL_PROGRESS:
				if (!bFeat) bReturn = false;
				break;
			case Feature.CART_UPSELL:
				if (!bFeat) bReturn = false;
				break;
			case Feature.REVOTAG:
				if (!bFeat) bReturn = false;
				break;
			case Feature.INTASTORY:
				if (!bFeat) bReturn = false;
				break;
			case Feature.SOCIAL_PROOF:
				if (!bFeat) bReturn = false;
				break;
			case Feature.PAGES:
				if (!bFeat) bReturn = false;
				break;
			case Feature.RECOMINDER:
				if (!bFeat) bReturn = false;
				break;
			case Feature.WHATSAPP:
				if (!bFeat) bReturn = false;
				break;
			case Feature.SCRIPT:
				if (!bFeat) bReturn = false;
				break;
			case Feature.AB_TEST:
				if (!bFeat) bReturn = false;
				break;
			case Feature.SCRATCH_OFF:
				if (!bFeat) bReturn = false;
				break;
			case Feature.BACKINSTOCK:
				if (!bFeat) bReturn = false;
				break;
        }
        return bReturn;
    }
}
