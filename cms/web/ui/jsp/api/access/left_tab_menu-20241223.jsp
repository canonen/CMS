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
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header/left_tab_menu_header.jsp" %>
<%
  boolean bIsValid = false;

  Customer cust = null;
  User user = null;
  UIEnvironment ui = null;

  if ( (session != null) && (request.isRequestedSessionIdValid()))
  {
    cust = (Customer) session.getAttribute("cust");
    user = (User) session.getAttribute("user");
    ui = (UIEnvironment) session.getAttribute("ui");

    if ((cust != null) && ( user != null )) bIsValid = true;
    else
    {
      try { session.invalidate(); }
      catch(Exception ex){}
    }
  }

  if (!bIsValid)
  {
    return;
  }

  SessionMonitor.update(session, request.getRequestURI());
%>
<%
  Service service = null;
  Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
  service = (Service) services.get(0);
  String rcpData = service.getURL().getHost();

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
  boolean iHome = false;
  boolean iCamp = false;
  boolean iData = false;
  boolean iCont = false;
  boolean iRept = false;
  boolean iAdmn = false;
  boolean iHelp = false;

  //Performance center
  boolean iPerf = true;


  //set default values to show or hide tabs
  boolean showHome = true;
  boolean showCamp = true;
  boolean showData = true;
  boolean showCont = true;
  boolean showRept = true;
  boolean showAdmn = true;
  boolean showHelp = true;
  boolean showRecommendation = true;
  boolean showSmartWidget = true;
  boolean showCrmAds = true;
  boolean showPersonalSearch = true;
  boolean showWebPush = true;
  boolean showCustomerJourney = true;
  boolean showPerformanceHub = true;
  boolean showStore = true;
  boolean showEcommerceTracking = true;
  boolean showProducts = true;
  boolean showSMTP = true;
  boolean showIYS = true;
  boolean showContactSupport = true;
  boolean showReports= true;
  boolean showAppPush = true;
  boolean showMobilDevIvt = true;
  boolean showMobilDevIvtLite = true;
  boolean showFigensoft = true;
  boolean showSmartwidget = true;
  boolean showStickyBar = true;
  boolean showPopupGrow = true;
  boolean showPopupLoyalty = true;
  boolean showPopupReco = true;
  boolean showDrawer = true;
  boolean showRecentlyView = true;
  boolean showBlockedWebpush = true;
  boolean showExitIntent = true;
  boolean showNotificationCenter = true;
  boolean showStickyBarCounter = true;
  boolean showProductAlert = true;
  boolean showDrawerDiscount = true;
  boolean showCountdown = true;
  boolean showDealBox = true;
  boolean showDealDay = true;
  boolean showUpsellProgress = true;
  boolean showCartUpsell = true;
  boolean showRevotag = true;
  boolean showIntastory = true;
  boolean showSocialProof = true;
  boolean showPages = true;
  boolean showRecominder = true;
  boolean showWhatsapp = true;
  boolean showScript = true;
  boolean showAbTest = true;
  boolean showScratchOff = true;
  boolean showBackinStock = true;
  
  boolean showEmailEcommerce= true;

  //default sec for tabs
  String defHome = "1";
  String defCamp = "1";
  String defData = "1";
  String defCont = "1";
  String defRept = "1";
  String defAdmn = "1";
  String defHelp = "1";

  //set default values to show or hide sections
  boolean showHome1 = true;
  boolean showHome2 = true;
  boolean showHome3 = true;
  boolean showHome4 = true;

  boolean showCamp1 = true;
  boolean showCamp2 = true;
  boolean showCamp3 = true;
  boolean showCamp4 = true;
  boolean showCamp5 = true;
  boolean showCamp6 = true;

  boolean showData1 = true;
  boolean showData2 = true;
  boolean showData3 = true;
  boolean showData4 = true;
  boolean showData5 = false;

  boolean showCont1 = true;
  boolean showCont2 = true;
  boolean showCont3 = true;
  boolean showCont4 = true;
  boolean showCont5 = true;
  boolean showCont6 = true;

  boolean showRept1 = true;
  boolean showRept2 = true;
  boolean showRept3 = true;
  boolean showRept4 = true;
  boolean showRept5 = true;
  boolean showRept6 = true;
  boolean showRept7 = true;

  boolean showAdmn1 = true;
  boolean showAdmn2 = true;
  boolean showAdmn3 = true;
  boolean showAdmn4 = true;
  boolean showAdmn5 = true;
  boolean showAdmn6 = true;
  boolean showAdmn7 = true;
  //Release 6.1: Direct control over unsubscribe messages.
  boolean showAdmn8 = true;

  boolean showHelp1 = true;
  boolean showHelp2 = true;
  boolean showHelp3 = true;
  boolean showHelp4 = true;

  JsonObject accessData = new JsonObject();

  //check access levels per section
  AccessPermission can;
  //==================
  //HOME
  //==================
  can = user.getAccessPermission(ObjectType.USER_NOTES);
  if (!can.bRead) showHome2 = false;
  if (!can.bRead) showHome3 = false;

  accessData.put("showHome2",showHome2);
  accessData.put("showHome3",showHome3);

  //out.println(user);
  //==================
  //CAMPAIGNS
  //==================
  //My Campaigns
  //--------------
  can = user.getAccessPermission(ObjectType.CAMPAIGN);
  if (!can.bRead) showCamp = false;

  accessData.put("showCamp",showCamp);
  //out.print(can.bRead);

  //Exclusion Lists
  //--------------
  bFeat = ui.getFeatureAccess(Feature.EXCLUSION_LIST);
  if (!bFeat) showCamp3 = false;
  accessData.put("exclusionLists",showCamp3);

  //Notification Lists
  //--------------
  bFeat = ui.getFeatureAccess(Feature.NOTIFICATION_LIST);
  if (!bFeat) showCamp4 = false;
  accessData.put("notificationLists",showCamp4);
  //Quick Campaign Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.QUICK_CAMPAIGN);
  if (!bFeat) showCamp5 = false;
  accessData.put("quickCampaignFeature",showCamp5);

  //Web Service Campaign Feature
  //--------------
  showCamp6 = false;

  //==================
  //DATABASE
  //==================
  //My Database (Imports)
  //--------------
  can = user.getAccessPermission(ObjectType.IMPORT);
  if (!can.bRead) showData1 = false;
  if ("1".equals(defData) && showData1 == false) defData = "2";

  accessData.put("myDatabase(Imports)",showData1);
  accessData.put("myDatabase(Imports)",defData);


  //My Database Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.MY_DATABASE);
  if (!bFeat) showData1 = false;
  if ("1".equals(defData) && showData1 == false) defData = "2";

  accessData.put("myDatabaseFeature",showData1);
  accessData.put("myDatabaseFeature",defData);
  //Target Groups
  //--------------
  can = user.getAccessPermission(ObjectType.FILTER);
  if (!can.bRead) showData2 = false;
  if ("2".equals(defData) && showData2 == false) defData = "3";

  accessData.put("targetGroups",showData2);
  accessData.put("targetGroups",defData);
  //Exports
  //--------------
  can = user.getAccessPermission(ObjectType.EXPORT);
  if (!can.bRead) showData3 = false;
  if ("3".equals(defData) && showData3 == false) defData = "4";

  accessData.put("exports",showData3);
  accessData.put("exports",defData);
  //Export Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.EXPORTS);
  if (!bFeat) showData3 = false;
  if ("3".equals(defData) && showData3 == false) defData = "4";

  accessData.put("exportFeature",showData3);
  accessData.put("exportFeature",defData);
  //Recipient Search
  //--------------
  can = user.getAccessPermission(ObjectType.RECIPIENT);
  if (!can.bRead) showData4 = false;
  if ("4".equals(defData) && showData4 == false) defData = "5";

  accessData.put("recipientSearch",showData4);
  accessData.put("recipientSearch",defData);
  //Recipient Search Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.RECIPIENT_SEARCH);
  if (!bFeat) showData4 = false;
  if ("4".equals(defData) && showData4 == false) defData = "5";

  accessData.put("recipientSearchFeature",showData4);
  accessData.put("recipientSearchFeature",defData);
  //BriteConnect Feature
  //--------------
  //bFeat = ui.getFeatureAccess(Feature.BRITE_CONNECT);
  //if (!bFeat) showData5 = 0;

  //Database Tab
  //--------------
  if (showData1 == false && showData2 == false && showData3 == false && showData4 == false && showData5 == false) showData = false;
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
  if (!can.bRead) showCont1 = false;

  accessData.put("myContent",showCont1);

  //My Content Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.MY_CONTENT);
  if (!bFeat) showCont1 = false;
  if ("1".equals(defCont) && showCont1 == false) defCont = "2";

  accessData.put("myContentFeature",showCont1);
  accessData.put("myContentFeature",defCont);

  //Dynamic Content Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);
  if (!bFeat) showCont2 = false;
  if ("2".equals(defCont) && showCont2 == false) defCont = "3";
  //out.print(showCont2);
  accessData.put("dynamicContentFeature",showCont2);
  accessData.put("dynamicContentFeature",defCont);

  //External Content Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.EXTERNAL_CONTENT);
  if (!bFeat) showCont4 = false;
  if ("4".equals(defCont) && showCont4 == false) defCont = "5";

  accessData.put("externalContentFeature",showCont4);
  accessData.put("externalContentFeature",defCont);

  //Auto Link Names Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.AUTO_LINK_NAMES);
  if (!bFeat) showCont5 = false;
  if ("5".equals(defCont) && showCont5 == false) defCont = "6";

  accessData.put("autoLinkNamesFeature",showCont5);
  accessData.put("autoLinkNamesFeature",defCont);

  //Image Library
  //--------------
  can = user.getAccessPermission(ObjectType.IMAGE);
  if (!can.bRead) showCont6 = false;
  accessData.put("imgeLibrary",showCont6);


  //Image Library Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.IMAGE_LIBRARY);
  if (!bFeat) showCont6 = false;

  accessData.put("imageLibraryFeature",showCont6);
  //Content Tab
  //--------------
  if (showCont1 == false && showCont2 == false && showCont6 == false) showCont = false;
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
  if (!can.bRead) showRept = false;
  accessData.put("myReports",showRept);

  //Super Reports Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.SUPER_REPORTS);
  if (!bFeat) showRept2 = false;
  accessData.put("superReportsFeature",showRept2);

  //Global Reports Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.GLOBAL_REPORTS);
  if (!bFeat) showRept3 = false;
  accessData.put("globalReportsFeature",showRept3);

  //Customize Reports Feature
  //--------------
  bFeat = ui.getFeatureAccess(Feature.CUSTOMIZE_REPORTS);
  if (!bFeat) showRept4 = false;
  accessData.put("customizeReportsFeature",showRept4);

  //Customize Delivery Auditing
  //--------------
  AccessPermission canUserPvDesignOptimizer = user.getAccessPermission(ObjectType.PV_DESIGN_OPTIMIZER);
  accessData.put("canUserPvDesignOptimizer",canUserPvDesignOptimizer);
  AccessPermission canUserPvContentScorer = user.getAccessPermission(ObjectType.PV_CONTENT_SCORER);
  accessData.put("canUserPvContentScorer",canUserPvContentScorer);
  AccessPermission canUserPvDeliveryTracker = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
  accessData.put("canUserPvDeliveryTracker",canUserPvDeliveryTracker);

  bFeat = ui.getFeatureAccess(Feature.PV_LOGIN) && (canUserPvDeliveryTracker.bRead || canUserPvContentScorer.bRead || canUserPvDesignOptimizer.bRead);
  if (!bFeat) showRept5 = false;
  //showRept5 = 1;
  accessData.put("customizeDeliveryAuditing",showRept5);
  //Delivery Auditing Usage
  //--------------
  bFeat = ((ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER) && canUserPvDeliveryTracker.bRead) ||
          (ui.getFeatureAccess(Feature.PV_CONTENT_SCORER) && canUserPvContentScorer.bRead) ||
          (ui.getFeatureAccess(Feature.PV_DESIGN_OPTIMIZER) && canUserPvDesignOptimizer.bRead));
  if (!bFeat) showRept6 = false;
  //showRept6 = 1;
  accessData.put("deliveryAuditingUsage",showRept6);
  //Report Filter
  //--------------
  bFeat = ui.getFeatureAccess(ObjectType.CAMPAIGN_REPORT);
  if (!bFeat) showRept7 = false;
  //showRept7 = 1;
  accessData.put("reportFilter",showRept7);

  //==================
  //ADMINISTRATION
  //==================
  //Account Setup (Users)
  //--------------
  can = user.getAccessPermission(ObjectType.USER);
  if (!can.bRead) showAdmn1 = false;
  if ("1".equals(defAdmn) && showAdmn1 == false) defAdmn = "2";

  accessData.put("accountSetup(Users)",defAdmn);
  //Subscription Form
  //--------------
  can = user.getAccessPermission(ObjectType.FORM);
  if (!can.bRead) showAdmn3 = false;
  if ("3".equals(defAdmn) && showAdmn3 == false) defAdmn = "4";

  accessData.put("subscriptionForm",defAdmn);
  //Custom Fields (Recipient Attributes)
  //--------------
  can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
  if (!can.bRead) showAdmn4 = false;
  if ("4".equals(defAdmn) && showAdmn4 == false) defAdmn = "5";

  accessData.put("customFields(Recipient Attributes)",defAdmn);
  //Categories
  //--------------
  can = user.getAccessPermission(ObjectType.CATEGORY);
  if (!can.bRead) showAdmn5 = false;
  if ("5".equals(defAdmn) && showAdmn5 == false) defAdmn = "6";

  accessData.put("categories",defAdmn);
  //Unsubscribe Messages
  //--------------
  can = user.getAccessPermission(ObjectType.UNSUB_EDIT);
  if (!can.bRead) showAdmn8 = false;
  if ("8".equals(defAdmn) && showAdmn8 == false) defAdmn = "7";

  accessData.put("unsubscribeMessage",defAdmn);
  //Feature Access to Unsubscribe Messages
  //--------------
  bFeat = ui.getFeatureAccess(Feature.UNSUB_EDIT);
  if (!bFeat) showAdmn8 = false;
  accessData.put("featureAccesstoUnsubscribeMessages",showAdmn8);
  //Administration Tab
  //--------------
  if (showAdmn1 == false && showAdmn3 == false && showAdmn4 == false && showAdmn5 == false) showAdmn = false;

  accessData.put("administrationTab",showAdmn);

  //PERFORMANCE CENTER

  //EmailEcommerce
  bFeat = ui.getFeatureAccess(Feature.BRITE_TRACK);
  if (!bFeat) showEmailEcommerce = false;

  accessData.put("emailEcommerce",showEmailEcommerce);
  //Recommendation
  bFeat = ui.getFeatureAccess(730);
  if (!bFeat) showRecommendation = false;

  accessData.put("recommendation",showRecommendation);
  //SmartWidget
  bFeat = ui.getFeatureAccess(740);
  if (!bFeat) showSmartWidget = false;
  accessData.put("smartWidget",showSmartWidget);
  //CrmAds
  bFeat = ui.getFeatureAccess(750);
  if (!bFeat) showCrmAds = false;
  accessData.put("crmAds",showCrmAds);
  //PersonalSearch
  bFeat = ui.getFeatureAccess(760);
  if (!bFeat) showPersonalSearch = false;
  accessData.put("personalSearch",showPersonalSearch);
  //WebPush
  wFeat = ui.getFeatureAccess(770);
  if (!wFeat) showWebPush = false;
  accessData.put("webPush",showWebPush);
  //CustomerJourney
  bFeat = ui.getFeatureAccess(780);
  if (!bFeat) showCustomerJourney = false;
  accessData.put("customerJourney",showCustomerJourney);
  //PerformanceHub
  bFeat = ui.getFeatureAccess(790);
  if (!bFeat) showPerformanceHub = false;
  accessData.put("performanceHub",showPerformanceHub);
  //Store
  bFeat = ui.getFeatureAccess(800);
  if (!bFeat) showStore = false;
  accessData.put("store",showStore);
  //EcommerceTracking
  bFeat = ui.getFeatureAccess(810);
  if (!bFeat) showEcommerceTracking = false;
  accessData.put("ecommerceTracking",showEcommerceTracking);
  //Products
  bFeat = ui.getFeatureAccess(820);
  if (!bFeat) showProducts = false;
  accessData.put("products",showProducts);
  //SMTP
  bFeat = ui.getFeatureAccess(830);
  if (!bFeat) showSMTP = false;
  accessData.put("sMTP",showSMTP);
  //IYS
  bFeat = ui.getFeatureAccess(840);
  if (!bFeat) showIYS = false;
  accessData.put("IYS",showIYS);
  //ContactSupport
  bFeat = ui.getFeatureAccess(850);
  if (!bFeat) showContactSupport = false;
  accessData.put("contactSupport",showContactSupport);
  //Reports
  bFeat = ui.getFeatureAccess(860);
  if (!bFeat) showReports = false;
  accessData.put("reports",showReports);
  
  bFeat = ui.getFeatureAccess(870);
  if (!bFeat) showAppPush = false;
  accessData.put("appPush", showAppPush);
  
  bFeat = ui.getFeatureAccess(880);
  if (!bFeat) showMobilDevIvt = false;
  accessData.put("mobilDevIvt", showMobilDevIvt);
  
  bFeat = ui.getFeatureAccess(890);
  if (!bFeat) showMobilDevIvtLite = false;
  accessData.put("mobilDevIvtLite", showMobilDevIvtLite);
  
  bFeat = ui.getFeatureAccess(900);
  if (!bFeat) showFigensoft = false;
  accessData.put("figensoft", showFigensoft);
  
  bFeat = ui.getFeatureAccess(1000);
  if (!bFeat) showSmartWidget = false;
  accessData.put("smartwidget", showSmartwidget);
  
  bFeat = ui.getFeatureAccess(1001);
  if (!bFeat) showStickyBar = false;
  accessData.put("stickyBar", showStickyBar);
  
  bFeat = ui.getFeatureAccess(1002);
  if (!bFeat) showPopupGrow = false;
  accessData.put("popupGrow", showPopupGrow);
  
  bFeat = ui.getFeatureAccess(1003);
  if (!bFeat) showPopupLoyalty = false;
  accessData.put("popupLoyalty", showPopupLoyalty);
  
  bFeat = ui.getFeatureAccess(1004);
  if (!bFeat) showPopupReco = false;
  accessData.put("popupReco", showPopupReco);
  
  bFeat = ui.getFeatureAccess(1005);
  if (!bFeat) showDrawer = false;
  accessData.put("drawer", showDrawer);
  
  bFeat = ui.getFeatureAccess(1006);
  if (!bFeat) showRecentlyView = false;
  accessData.put("recentlyView", showRecentlyView);
  
  bFeat = ui.getFeatureAccess(1007);
  if (!bFeat) showBlockedWebpush = false;
  accessData.put("blockedWebpush", showBlockedWebpush);
  
  bFeat = ui.getFeatureAccess(1008);
  if (!bFeat) showExitIntent = false;
  accessData.put("exitIntent", showExitIntent);
  
  bFeat = ui.getFeatureAccess(1009);
  if (!bFeat) showNotificationCenter = false;
  accessData.put("notificationCenter", showNotificationCenter);
  
  bFeat = ui.getFeatureAccess(1010);
  if (!bFeat) showStickyBarCounter = false;
  accessData.put("stickyBarCounter", showStickyBarCounter);
  
  bFeat = ui.getFeatureAccess(1011);
  if (!bFeat) showProductAlert = false;
  accessData.put("productAlert", showProductAlert);
  
  bFeat = ui.getFeatureAccess(1012);
  if (!bFeat) showDrawerDiscount = false;
  accessData.put("drawerDiscount", showDrawerDiscount);
  
  bFeat = ui.getFeatureAccess(1013);
  if (!bFeat) showCountdown = false;
  accessData.put("countdown", showCountdown);
  
  bFeat = ui.getFeatureAccess(1014);
  if (!bFeat) showDealBox = false;
  accessData.put("dealBox", showDealBox);
  
  bFeat = ui.getFeatureAccess(1015);
  if (!bFeat) showDealDay = false;
  accessData.put("dealDay", showDealDay);
  
  bFeat = ui.getFeatureAccess(1016);
  if (!bFeat) showUpsellProgress = false;
  accessData.put("upsellProgress", showUpsellProgress);
  
  bFeat = ui.getFeatureAccess(1017);
  if (!bFeat) showCartUpsell = false;
  accessData.put("cartUpsell", showCartUpsell);
  
  bFeat = ui.getFeatureAccess(1018);
  if (!bFeat) showRevotag = false;
  accessData.put("revotag", showRevotag);
  
  bFeat = ui.getFeatureAccess(1019);
  if (!bFeat) showIntastory = false;
  accessData.put("intastory", showIntastory);
  
  bFeat = ui.getFeatureAccess(1020);
  if (!bFeat) showSocialProof = false;
  accessData.put("socialProof", showSocialProof);
  
  bFeat = ui.getFeatureAccess(1021);
  if (!bFeat) showPages = false;
  accessData.put("pages", showPages);
  
  bFeat = ui.getFeatureAccess(1022);
  if (!bFeat) showRecominder = false;
  accessData.put("recominder", showRecominder);
  
  bFeat = ui.getFeatureAccess(1023);
  if (!bFeat) showWhatsapp = false;
  accessData.put("whatsapp", showWhatsapp);
  
  bFeat = ui.getFeatureAccess(1024);
  if (!bFeat) showScript = false;
  accessData.put("script", showScript);
  
  bFeat = ui.getFeatureAccess(1025);
  if (!bFeat) showAbTest = false;
  accessData.put("abTest", showAbTest);
  
  bFeat = ui.getFeatureAccess(1026);
  if (!bFeat) showScratchOff = false;
  accessData.put("scratchOff", showScratchOff);
  
  bFeat = ui.getFeatureAccess(1027);
  if (!bFeat) showBackinStock = false;
  accessData.put("backinStock", showBackinStock);

  bFeat = ui.getFeatureAccess(Feature.PRINT_ENABLED);
  boolean print_enabled=bFeat;
  accessData.put("print_enabled",print_enabled);

  //out.print(wFeat);
  //out.print(showWebPush);

  //==================
  //SUPPORT
  //==================
  //Help Doc
  //--------------
  bFeat = ui.getFeatureAccess(Feature.HELP_DOC);
  if (!bFeat) showHelp2 = false;
  accessData.put("helpDoc",showHelp2);
  //FAQs
  //--------------
  bFeat = ui.getFeatureAccess(Feature.FAQS);
  if (!bFeat) showHelp3 = false;
  accessData.put("fAQs",showHelp3);
  accessData.put("rcpData",rcpData);



  out.print(accessData.toString());

%>