package com.britemoon.cps;

final public class ServiceType
{
/*
	final public static int SADM_CUST_CENTRAL_LOGIN = 1;
*/
	final public static int CCPS_CUST_LOGIN = 2;

	final public static int RTGT_FILTER_SETUP = 3;
	final public static int RQUE_CAMPAIGN_SETUP = 4;
	
	final public static int AINB_UNSUB_ACTIVITY = 5;
	final public static int AINB_BBACK_ACTIVITY = 6;

	final public static int ASBS_UPLOAD_SUBSCRIPTION_RESULT = 7;
	final public static int ASBS_SUBSCRIPTION_CONFIRMATION = 8;

	final public static int CUST_SETUP = 9;	

	final public static int AJTK_ACTIVITY_1_CUSTGET = 10;
	final public static int RUPD_IMPORT_SETUP = 11;
	final public static int CUPD_IMPORT_STATUS_UPDATE = 12;
	final public static int RRCP_RECIP_VIEW = 13;
	final public static int RUPD_MANUAL_IMPORT_SETUP = 14;
	final public static int RSBS_HIGH_PRIORITY_ACTIVITY_RECEIVE = 15;
	final public static int ASBS_FORM_SETUP = 16;
	final public static int RUPD_IMPORT_RESULT_FILE_VIEW = 17;
	final public static int AINB_CAMPAIGN_NOTIFY = 18;
	final public static int AJTK_CONTENT_LINK_SETUP = 19;
	final public static int CQUE_CAMPAIGN_STATUS_UPDATE = 21;
	final public static int RQUE_LIST_SETUP = 22;
	final public static int RQUE_CHUNK_REQUEST = 23;
	
	final public static int SADM_USER_SETUP = 24;
	final public static int SADM_ACCESS_MASKS_SETUP = 25;

	final public static int SADM_CUST_ATTR_SETUP = 26;
	final public static int RRCP_CUST_ATTR_SETUP = 27;

	final public static int RRCP_FILTER_STATISTIC_GET = 28;
	final public static int REXP_EXPORT_SETUP = 29;
	final public static int RRPT_CAMPAIGN_REPORT_QUEUE = 30;
	final public static int CRPT_CAMPAIGN_REPORT_UPDATE = 31;
	final public static int RUPD_IMPORT_ACTION = 32;

	final public static int CCTM_LOGIN_HANDSHAKE = 33;
	final public static int CCTM_CONTENT_SETUP = 34;

	final public static int RRPT_CUST_REPORT_QUEUE = 35;
	final public static int CRPT_CUST_REPORT_UPDATE = 36;
	final public static int RSBS_PREFILL_RESPONDER = 37;
	final public static int RSBS_FORM_SETUP = 38;
	final public static int RJTK_CAMP_LINK_SETUP = 39;
	
	final public static int SADM_FROM_ADDRESS_SETUP = 40;	
/*
	final public static int AINB_UPLOAD_SUBSCRIPTION_RESULT = 41;
*/
	final public static int RRCP_RECIP_CAMP_HISTORY_GET = 42;
	final public static int REXP_CUSTOM_EXPORT_START = 43;

	final public static int RQUE_CAMP_MONITOR = 44;
	
	final public static int CUST_UNIQUE_ID_MONITOR = 45;
/*	
	final public static int RQUE_CHUNK_ACTIVITY = 46;
	final public static int RQUE_CHUNK_CONFIRMATION = 47;
	final public static int RQUE_MESSAGE_XML_TRANSFER = 48;
	final public static int RQUE_CAMPAIGN_STATUS_UPDATE = 49;
*/	
	final public static int RSYN_UPDATE_BRITEMOON = 50;
	final public static int RSYN_UPDATE_CUSTOMER = 51;

	final public static int AINB_FROM_ADDRESS_SETUP = 52;

	final public static int CCPS_ATTR_VALUES_UPDATE = 53;
	final public static int RRCP_ATTR_VALUES_UPDATE = 54;

	final public static int RQUE_CAMP_RECIP_ADD_SETUP = 55;
	final public static int RQUE_CAMP_RECIP_ADD_DELETE = 56;
	final public static int RRPT_CAMP_REPORT_SYNC = 57;
/*
	final public static int RRCP_PULL_UNSUBS_FROM_QUEUE = 58;
*/
	final public static int CEXP_EXPORT_UPDATE = 59;
	final public static int RQUE_LIST_IMPORT_SETUP = 60;
/*
	final public static int RQUE_CAMP_STAT_GET = 61;
*/
	final public static int RQUE_CAMP_NONEMAIL_IMPORT_SETUP = 62;
	final public static int RRPT_CAMPAIGN_REPORT_CACHE = 63;

    final public static int RQUE_CAMP_CANCEL = 64;

    final public static int CSYN_ADD_ATTR = 65;

	final public static int RRPT_CUST_DOMAINS_SETUP = 66;

	final public static int CCPS_BRITECONNECT_CAMP_INFO = 67;

	final public static int RRCP_BRITECONNECT_SYNC_STATUS = 68;
	final public static int RRCP_BRITECONNECT_CHUNK_STATUS = 69;
	final public static int RRCP_BRITECONNECT_ITEM_STATUS = 70;
	final public static int RRCP_BRITECONNECT_DAILY_STATUS = 71;

    final public static int RXCS_ACTIVITY_DATA_REQUEST = 72;
    final public static int CXCS_SEND_CUST_ORDER_STATUS = 73;

	final public static int SADM_SYSTEM_NOTE_INFO = 74;

	final public static int RRCP_BILLING_CAMP_REPORT = 75;
	final public static int RRCP_BILLING_CLIENT_REPORT = 76;

	final public static int SADM_CUST_BBACK_SETUP = 77;
	final public static int RRCP_CUST_BBACK_SETUP = 78;

	final public static int SADM_HELP_DOC_INFO = 79;

	final public static int RQUE_CAMP_DELETE = 80;

	final public static int RRCP_RECIP_HISTORY_GET = 81;
	final public static int CCPS_RECIP_HISTORY_GET = 82;
	final public static int CCPS_RECIP_CAMP_HISTORY_GET = 83;

	final public static int CCTM_TEMPLATE_LOCK = 84;
	
	final public static int CXCS_CONT_LOGIN = 85;	
	final public static int CXCS_CONT_DOCUMENT_UPDATE = 86;	

	final public static int CXCS_ORDER_DELIVERY = 87;	
	final public static int CXCS_CONT_DOCUMENT_ATTRIBUTES = 88;	
	
	final public static int RRCP_CUST_DBNAME = 89;	

	final public static int CXCS_PV_LOGIN = 90;

	final public static int CXCS_PV_DELIVERY_REPORT = 91;
	final public static int CXCS_PV_DELIVERY_REPORT_XML = 92;
	final public static int CXCS_PV_DESIGN_REPORT = 93;
	final public static int CXCS_PV_CONTENT_SCORE_REPORT = 94;
	
	final public static int CCPS_CAMP_CACHE_REPORT_UPDATE = 95;
	
	final public static int CCPS_CAMP_MONITOR_REPORT = 96;
	
	final public static int CCPS_SESSION_MONITOR_REPORT = 97;
	
	final public static int CQUE_CAMP_STATUS_SET = 98;

	final public static int RQUE_CAMP_STATUS_SET = 99;
	
	final public static int CCPS_DELIVERY_CAMP_INFO = 100;
	
	final public static int AINB_TIFFANY_UNSUB_ACTIVITY = 101;
	final public static int SADM_UNSUB_MESSAGE_UPDATE = 102;
	
}
