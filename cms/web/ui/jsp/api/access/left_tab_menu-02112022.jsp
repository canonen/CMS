<%@page import="com.britemoon.*" %>
<%@page import="com.britemoon.cps.*" %>
<%@page import="com.britemoon.cps.imc.*" %>
<%@page import="com.britemoon.cps.rpt.*" %>
<%@page import="com.britemoon.cps.User" %>
<%@page import="com.britemoon.cps.Customer" %>
<%@page import="com.britemoon.cps.UIEnvironment" %>
<%@page import="com.britemoon.cps.SessionMonitor" %>
<%@ page import="java.util.*, java.net.*, java.io.*" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%
    //CY 08/04/2013
    //Is it the standard ui?
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    boolean isPrintCampaign = false;

    //grab query strings
    String sNavTab = request.getParameter("tab");
    String sNavSection = request.getParameter("sec");

    //set default values for querystrings
    if ((null == sNavTab) || ("" == sNavTab)) sNavTab = "Home";
    if ((null == sNavSection) || ("" == sNavSection)) sNavSection = "1";

    boolean bFeat = false;
    boolean wFeat = false;

    //set default values for selected Tab
    int iHome = 0;
    int iCamp = 0;
    int iData = 0;
    int iCont = 0;
    int iRept = 0;
    int iAdmn = 0;
    int iHelp = 0;

    //Performance center
    int iPerf = 1;


    //set default values to show or hide tabs
    int showHome = 1;
    int showCamp = 1;
    int showData = 1;
    int showCont = 1;
    int showRept = 1;
    int showAdmn = 1;
    int showHelp = 1;
    int showRecommendation = 1;
    int showSmartWidget = 1;
    int showCrmAds = 1;
    int showPersonalSearch = 1;
    int showWebPush = 1;
    int showCustomerJourney = 1;
    int showPerformanceHub = 1;
    int showStore = 1;
    int showEcommerceTracking = 1;
    int showProducts = 1;
    int showSMTP = 1;
    int showIYS = 1;
    int showContactSupport = 1;
    int showReports= 1;
    int showEmailEcommerce= 1;

    //default sec for tabs
    String defHome = "1";
    String defCamp = "1";
    String defData = "1";
    String defCont = "1";
    String defRept = "1";
    String defAdmn = "1";
    String defHelp = "1";

    //set default values to show or hide sections
    int showHome1 = 1;
    int showHome2 = 1;
    int showHome3 = 1;
    int showHome4 = 1;

    int showCamp1 = 1;
    int showCamp2 = 1;
    int showCamp3 = 1;
    int showCamp4 = 1;
    int showCamp5 = 1;
    int showCamp6 = 1;

    int showData1 = 1;
    int showData2 = 1;
    int showData3 = 1;
    int showData4 = 1;
    int showData5 = 0;

    int showCont1 = 1;
    int showCont2 = 1;
    int showCont3 = 1;
    int showCont4 = 1;
    int showCont5 = 1;
    int showCont6 = 1;

    int showRept1 = 1;
    int showRept2 = 1;
    int showRept3 = 1;
    int showRept4 = 1;
    int showRept5 = 1;
    int showRept6 = 1;
    int showRept7 = 1;

    int showAdmn1 = 1;
    int showAdmn2 = 1;
    int showAdmn3 = 1;
    int showAdmn4 = 1;
    int showAdmn5 = 1;
    int showAdmn6 = 1;
    int showAdmn7 = 1;
    //Release 6.1: Direct control over unsubscribe messages.
    int showAdmn8 = 1;

    int showHelp1 = 1;
    int showHelp2 = 1;
    int showHelp3 = 1;
    int showHelp4 = 1;

    JsonObject accessData = new JsonObject();

    //check access levels per section
    AccessPermission can;

    //==================
    //HOME
    //==================
    can = user.getAccessPermission(ObjectType.USER_NOTES);

    if (!can.bRead) showHome2 = 0;
    if (!can.bRead) showHome3 = 0;

    accessData.put("showHome2",showHome2);
    accessData.put("showHome3",showHome3);
    //==================
    //CAMPAIGNS
    //==================
    //My Campaigns
    //--------------
    can = user.getAccessPermission(ObjectType.CAMPAIGN);
    if (!can.bRead) showCamp = 0;
    accessData.put("showCamp",showCamp);
    //out.print(can.bRead);

    //Exclusion Lists
    //--------------
    bFeat = ui.getFeatureAccess(Feature.EXCLUSION_LIST);
    if (!bFeat) showCamp3 = 0;
    accessData.put("exclusionLists",showCamp3);

    //Notification Lists
    //--------------
    bFeat = ui.getFeatureAccess(Feature.NOTIFICATION_LIST);
    if (!bFeat) showCamp4 = 0;
    accessData.put("notificationLists",showCamp4);
    //Quick Campaign Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.QUICK_CAMPAIGN);
    if (!bFeat) showCamp5 = 0;
   accessData.put("quickCampaignFeature",showCamp5);


    //Web Service Campaign Feature
    //--------------
    showCamp6 = 0;

    //==================
    //DATABASE
    //==================
    //My Database (Imports)
    //--------------
    can = user.getAccessPermission(ObjectType.IMPORT);
    if (!can.bRead) showData1 = 0;
    if ("1".equals(defData) && showData1 == 0) defData = "2";

    accessData.put("myDatabase(Imports)",showData1);
    accessData.put("myDatabase(Imports)",defData);


    //My Database Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.MY_DATABASE);
    if (!bFeat) showData1 = 0;
    if ("1".equals(defData) && showData1 == 0) defData = "2";

    accessData.put("myDatabaseFeature",showData1);
    accessData.put("myDatabaseFeature",defData);

    //Target Groups
    //--------------
    can = user.getAccessPermission(ObjectType.FILTER);
    if (!can.bRead) showData2 = 0;
    if ("2".equals(defData) && showData2 == 0) defData = "3";

    accessData.put("targetGroups",showData2);
    accessData.put("targetGroups",defData);

    //Exports
    //--------------
    can = user.getAccessPermission(ObjectType.EXPORT);
    if (!can.bRead) showData3 = 0;
    if ("3".equals(defData) && showData3 == 0) defData = "4";

    accessData.put("exports",showData3);
    accessData.put("exports",defData);

    //Export Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.EXPORTS);
    if (!bFeat) showData3 = 0;
    if ("3".equals(defData) && showData3 == 0) defData = "4";

    accessData.put("exportFeature",showData3);
    accessData.put("exportFeature",defData);

    //Recipient Search
    //--------------
    can = user.getAccessPermission(ObjectType.RECIPIENT);
    if (!can.bRead) showData4 = 0;
    if ("4".equals(defData) && showData4 == 0) defData = "5";

    accessData.put("recipientSearch",showData4);
    accessData.put("recipientSearch",defData);

    //Recipient Search Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.RECIPIENT_SEARCH);
    if (!bFeat) showData4 = 0;
    if ("4".equals(defData) && showData4 == 0) defData = "5";

    accessData.put("recipientSearchFeature",showData4);
    accessData.put("recipientSearchFeature",defData);

    //BriteConnect Feature
    //--------------
    //bFeat = ui.getFeatureAccess(Feature.BRITE_CONNECT);
    //if (!bFeat) showData5 = 0;

    //Database Tab
    //--------------
    if (showData1 == 0 && showData2 == 0 && showData3 == 0 && showData4 == 0 && showData5 == 0) showData = 0;
    accessData.put("databaseTab",showData);
    //out.print(showData1);
    //out.print(showData2);
    //out.print(showData3);
    //out.print(showData4);
    //out.print(showData5);

    //==================
    //CONTENT
    //==================
    //My Content
    //--------------
    can = user.getAccessPermission(ObjectType.CONTENT);
    if (!can.bRead) showCont1 = 0;

    accessData.put("myContent",showCont1);

    //My Content Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.MY_CONTENT);
    if (!bFeat) showCont1 = 0;
    if ("1".equals(defCont) && showCont1 == 0) defCont = "2";

    accessData.put("myContentFeature",showCont1);
    accessData.put("myContentFeature",defCont);

    //Dynamic Content Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);
    if (!bFeat) showCont2 = 0;
    if ("2".equals(defCont) && showCont2 == 0) defCont = "3";
    //out.print(showCont2);
    accessData.put("dynamicContentFeature",showCont2);
    accessData.put("dynamicContentFeature",defCont);

    //External Content Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.EXTERNAL_CONTENT);
    if (!bFeat) showCont4 = 0;
    if ("4".equals(defCont) && showCont4 == 0) defCont = "5";

    accessData.put("externalContentFeature",showCont4);
    accessData.put("externalContentFeature",defCont);

    //Auto Link Names Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.AUTO_LINK_NAMES);
    if (!bFeat) showCont5 = 0;
    if ("5".equals(defCont) && showCont5 == 0) defCont = "6";

    accessData.put("autoLinkNamesFeature",showCont5);
    accessData.put("autoLinkNamesFeature",defCont);

    //Image Library
    //--------------
    can = user.getAccessPermission(ObjectType.IMAGE);
    if (!can.bRead) showCont6 = 0;
    accessData.put("imgeLibrary",showCont6);


    //Image Library Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.IMAGE_LIBRARY);
    if (!bFeat) showCont6 = 0;

    accessData.put("imageLibraryFeature",showCont6);

    //Content Tab
    //--------------
    if (showCont1 == 0 && showCont2 == 0 && showCont6 == 0) showCont = 0;
    //out.print(showCont1);
    //out.print(showCont2);
    //out.print(showCont6);
    //out.print(showCont);
    accessData.put("contentTab",showCont);

    //==================
    //REPORTING
    //==================
    //My Reports
    //--------------
    can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
    if (!can.bRead) showRept = 0;
    accessData.put("myReports",showRept);

    //Super Reports Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.SUPER_REPORTS);
    if (!bFeat) showRept2 = 0;
    accessData.put("superReportsFeature",showRept2);

    //Global Reports Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.GLOBAL_REPORTS);
    if (!bFeat) showRept3 = 0;
    accessData.put("globalReportsFeature",showRept3);

    //Customize Reports Feature
    //--------------
    bFeat = ui.getFeatureAccess(Feature.CUSTOMIZE_REPORTS);
    if (!bFeat) showRept4 = 0;
    accessData.put("customizeReportsFeature",showRept4);

    //Customize Delivery Auditing
    //--------------
    AccessPermission canUserPvDesignOptimizer = user.getAccessPermission(ObjectType.PV_DESIGN_OPTIMIZER);
    AccessPermission canUserPvContentScorer = user.getAccessPermission(ObjectType.PV_CONTENT_SCORER);
    AccessPermission canUserPvDeliveryTracker = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
    bFeat = ui.getFeatureAccess(Feature.PV_LOGIN) && (canUserPvDeliveryTracker.bRead || canUserPvContentScorer.bRead || canUserPvDesignOptimizer.bRead);
    if (!bFeat) showRept5 = 0;
    //showRept5 = 1;
    accessData.put("customizeDeliveryAuditing",showRept5);
    //Delivery Auditing Usage
    //--------------
    bFeat = ((ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER) && canUserPvDeliveryTracker.bRead) ||
            (ui.getFeatureAccess(Feature.PV_CONTENT_SCORER) && canUserPvContentScorer.bRead) ||
            (ui.getFeatureAccess(Feature.PV_DESIGN_OPTIMIZER) && canUserPvDesignOptimizer.bRead));
    if (!bFeat) showRept6 = 0;
    //showRept6 = 1;
    accessData.put("deliveryAuditingUsage",showRept6);
    //Report Filter
    //--------------
    bFeat = ui.getFeatureAccess(ObjectType.CAMPAIGN_REPORT);
    if (!bFeat) showRept7 = 0;
    //showRept7 = 1;
    accessData.put("reportFilter",showRept7);

    //==================
    //ADMINISTRATION
    //==================
    //Account Setup (Users)
    //--------------
    can = user.getAccessPermission(ObjectType.USER);
    if (!can.bRead) showAdmn1 = 0;
    if ("1".equals(defAdmn) && showAdmn1 == 0) defAdmn = "2";

    accessData.put("accountSetup(Users)",defAdmn);
    //Subscription Form
    //--------------
    can = user.getAccessPermission(ObjectType.FORM);
    if (!can.bRead) showAdmn3 = 0;
    if ("3".equals(defAdmn) && showAdmn3 == 0) defAdmn = "4";

    accessData.put("subscriptionForm",defAdmn);
    //Custom Fields (Recipient Attributes)
    //--------------
    can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
    if (!can.bRead) showAdmn4 = 0;
    if ("4".equals(defAdmn) && showAdmn4 == 0) defAdmn = "5";

    accessData.put("customFields(Recipient Attributes)",defAdmn);
    //Categories
    //--------------
    can = user.getAccessPermission(ObjectType.CATEGORY);
    if (!can.bRead) showAdmn5 = 0;
    if ("5".equals(defAdmn) && showAdmn5 == 0) defAdmn = "6";

    accessData.put("categories",defAdmn);
    //Unsubscribe Messages
    //--------------
    can = user.getAccessPermission(ObjectType.UNSUB_EDIT);
    if (!can.bRead) showAdmn8 = 0;
    if ("8".equals(defAdmn) && showAdmn8 == 0) defAdmn = "7";

    accessData.put("unsubscribeMessage",defAdmn);
    //Feature Access to Unsubscribe Messages
    //--------------
    bFeat = ui.getFeatureAccess(Feature.UNSUB_EDIT);
    if (!bFeat) showAdmn8 = 0;
    accessData.put("featureAccesstoUnsubscribeMessages",showAdmn8);
    //Administration Tab
    //--------------
    if (showAdmn1 == 0 && showAdmn3 == 0 && showAdmn4 == 0 && showAdmn5 == 0) showAdmn = 0;

    accessData.put("administrationTab",showAdmn);

    //PERFORMANCE CENTER

    //EmailEcommerce
    bFeat = ui.getFeatureAccess(Feature.BRITE_TRACK);
    if (!bFeat) showEmailEcommerce = 0;

    accessData.put("emailEcommerce",showEmailEcommerce);
    //Recommendation
    bFeat = ui.getFeatureAccess(730);
    if (!bFeat) showRecommendation = 0;

    accessData.put("recommendation",showRecommendation);
    //SmartWidget
    bFeat = ui.getFeatureAccess(740);
    if (!bFeat) showSmartWidget = 0;
    accessData.put("smartWidget",showSmartWidget);
    //CrmAds
    bFeat = ui.getFeatureAccess(750);
    if (!bFeat) showCrmAds = 0;
    accessData.put("crmAds",showCrmAds);
    //PersonalSearch
    bFeat = ui.getFeatureAccess(760);
    if (!bFeat) showPersonalSearch = 0;
    accessData.put("personalSearch",showPersonalSearch);
    //WebPush
    wFeat = ui.getFeatureAccess(770);
    if (!wFeat) showWebPush = 0;
    accessData.put("webPush",showWebPush);
    //CustomerJourney
    bFeat = ui.getFeatureAccess(780);
    if (!bFeat) showCustomerJourney = 0;
    accessData.put("customerJourney",showCustomerJourney);
    //PerformanceHub
    bFeat = ui.getFeatureAccess(790);
    if (!bFeat) showPerformanceHub = 0;
    accessData.put("performanceHub",showPerformanceHub);
    //Store
    bFeat = ui.getFeatureAccess(800);
    if (!bFeat) showStore = 0;
    accessData.put("store",showStore);
    //EcommerceTracking
    bFeat = ui.getFeatureAccess(810);
    if (!bFeat) showEcommerceTracking = 0;
    accessData.put("ecommerceTracking",showEcommerceTracking);
    //Products
    bFeat = ui.getFeatureAccess(820);
    if (!bFeat) showProducts = 0;
    accessData.put("products",showProducts);
    //SMTP
    bFeat = ui.getFeatureAccess(830);
    if (!bFeat) showSMTP = 0;
    accessData.put("sMTP",showSMTP);
    //IYS
    bFeat = ui.getFeatureAccess(840);
    if (!bFeat) showIYS = 0;
    accessData.put("IYS",showIYS);
    //ContactSupport
    bFeat = ui.getFeatureAccess(850);
    if (!bFeat) showContactSupport = 0;
    accessData.put("contactSupport",showContactSupport);
    //Reports
    bFeat = ui.getFeatureAccess(860);
    if (!bFeat) showReports = 0;
    accessData.put("reports",showReports);
    //out.print(wFeat);
    //out.print(showWebPush);

    //==================
    //SUPPORT
    //==================
    //Help Doc
    //--------------
    bFeat = ui.getFeatureAccess(Feature.HELP_DOC);
    if (!bFeat) showHelp2 = 0;
    accessData.put("helpDoc",showHelp2);
    //FAQs
    //--------------
    bFeat = ui.getFeatureAccess(Feature.FAQS);
    if (!bFeat) showHelp3 = 0;
    accessData.put("fAQs",showHelp3);

   out.print(accessData.toString());

%>