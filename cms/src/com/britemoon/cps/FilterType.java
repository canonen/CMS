package com.britemoon.cps;

final public class FilterType
{
	final public static int MULTIPART_TOP_LEVEL = -1;
	final public static int MULTIPART = 0; 
	final public static int CAMPAIGN = 1;		// camp_id 
	final public static int CAMPAIGN_FORM = 2;	// camp_id, form_id
	final public static int BATCH = 3;			// batch_id
	final public static int LINK_CLICK = 5;		// link_id
	final public static int LINK_READ = 6;		// camp_id
	final public static int UPLOAD = 7;			// import_id
	final public static int CONTENT_BLOCK = 8;	// cont_id
	final public static int IMPORT = UPLOAD;	// import_id
	final public static int FORM_SUBMIT = 14;	// form_id
	final public static int BBACK_FROM_CAMPAIGN = 15; // camp_id
	final public static int MSG_COUNT_WITHIN_TIME_INTERVAL = 16;
	final public static int CLICK_COUNT_WITHIN_TIME_INTERVAL = 17;	
	final public static int READ_COUNT_WITHIN_TIME_INTERVAL = 18;
	final public static int BBACK_COUNT_WITHIN_TIME_INTERVAL = 19;
	
	final public static int FORM_SUBMIT_COUNT_WITHIN_TIME_INTERVAL = 20;
	
	final public static int DATE_ATTR_COMPARISON = 21;
	final public static int ATTR_HISTORY_AGGREGATION_WITHIN_TIME_INTERVAL = 22;
	final public static int CAMP_SENT_WITHIN_TIME_INTERVAL = 23;

	final public static int NEWSLETTER = 24;
	final public static int ENTITY = 25;	
	
	final public static int FORM_SUBMIT_DURING_TIME_INTERVAL = 26;
	final public static int CLICK_X_LINKS_IN_CAMPAIGNS_DURING_TIME_INTERVAL = 27;
	final public static int CLICK_X_PERCENT_LINKS_IN_CAMPAIGNS_DURING_TIME_INTERVAL=28;
	final public static int SUBMIT_X_FORMS_IN_CAMPAIGNS_DURING_TIME_INTERVAL = 60;
	final public static int SUBMIT_X_PERCENT_FORMS_IN_CAMPAIGNS_DURING_TIME_INTERVAL = 61;
	final public static int READ_X_MESSAGES_DURING_TIME_INTERVAL = 62;
	final public static int READ_X_PERCENT_MESSAGES_DURING_TIME_INTERVAL = 63;
	final public static int BRITETRACK_DID_ACTION = 64;
	final public static int BRITETRACK_DID_ACTION_WITH_PARAM = 65;
	final public static int BRITETRACK_DID_TWO_ACTIONS = 66;
	

	// === === ===

//	UNCOMMENT type you need
//	UPDATE filter_type table
//	PUT update sql into usp_4_to_5_step_950_other_upgrades in brite_rrcp_500_common database
//	CREATE PROCEDURE usp_rtgt_filter_run_xxx @filter_id int, @is_d_prefilled int
//	where xxx - fillter_type_id
//	In that procedure retrieve proper params from filter_param table
//	and call one fo appropriate procedures now (2003-10-30) listed in RecipList on RCP
//	In usp_rtgt_filter_run add reference to the above new procedure
//	Yep! Life is not easy.

	final public static int 	RLST_CAMP_BBACK = 31;
	final public static int 	RLST_CAMP_BBACK_WITH_CATEGORY = 32;
	final public static int 	RLST_CAMP_CLICK = 33;
	final public static int 	RLST_CAMP_CLICK_MULTI = 34;
	final public static int 	RLST_CAMP_FORM_SUBMIT = 35;
	final public static int 	RLST_CAMP_FORM_SUBMIT_MULTI = 36;
	final public static int 	RLST_CAMP_FORM_VIEW = 37;
	final public static int 	RLST_CAMP_MULTILINK = 38;
	final public static int 	RLST_CAMP_RCVD = 39;
	final public static int 	RLST_CAMP_READ = 40;
	final public static int 	RLST_CAMP_READ_MULTI = 41;
	final public static int 	RLST_CAMP_SENT = 42;
	final public static int 	RLST_CAMP_UNSUB = 43;
	final public static int 	RLST_CAMP_DOMAIN_SENT = 44;
	final public static int 	RLST_CAMP_DOMAIN_BBACK = 45;
	final public static int 	RLST_CAMP_OPTOUT = 46;
	final public static int 	RLST_CAMP_DOMAIN_READ = 47;
	final public static int 	RLST_CAMP_DOMAIN_CLICK = 48;
	final public static int 	RLST_CAMP_DOMAIN_UNSUB = 49;

//	final public static int 	RLST_EDT_DETAIL = 50;
//	final public static int 	RLST_EDT_LIST_EMAIL_821 = 51;
//	final public static int 	RLST_EDT_LIST_PNMFAMILY = 52;
//	final public static int 	RLST_EXP_BATCH = 53;
//	final public static int 	RLST_EXP_BBACK = 54;
//	final public static int 	RLST_EXP_UNSUB = 55;
//	final public static int 	RLST_TGT_PREVIEW = 56;
	//Release 6.0: Ability to export bounces and unsubs from a target group.
	final public static int		RLST_TGT_BBACK = 57;
	final public static int		RLST_TGT_UNSUB = 58;
	final public static int		RLST_TGT_INELIGIBLE = 59;
	
	// Release 6.1: Spam complaint
	
	final public static int 	RLST_CAMP_UNSUB_WITH_LEVEL = 68;
	final public static int 	RLST_CAMP_DOMAIN_SPAM_COMPLAINT = 69;
	final public static int 	CUSTOM_FORMULA = 999999;
	// === === ===

	// NOT IMPLEMENTED YET
	//final public static int STRAIGHT_SQL = 90;
	//	STRAIGHT_SQL TYPE. WHAT IS THIS?
	//	Requirements:
	//	1. SQL should populate #fr(recip int) table (created by external process)
	//	2. assuming #c(cust_id) table contains list of customers
	//		 whos' recips are considered as potential canditated 
	//	3. assuming #d(recip_id) table contains list of recips to be considered as potential canditated
	//	4. wether to take #d in consideration or not
	//		will be specified by adding ', @is_d_prefilled=X' to SQL (X > 0 means use #d)
	//	5. so SQL should look like
	//		"EXEC usp_my_proc @blah=123, @blah_blah=321";
	//	6. SQL should be saved to and will be taken from filter parameter (in filter_param table) like this:
	//		SELECT @SQL = string_value FROM rtgt_filter_param WHERE param_name='SQL' AND filter_id=??? 

	// === === ===

	final public static int FORMULA = 100;
}	




