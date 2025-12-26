<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>

<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
Customer cust = new Customer(sCustId);

// === === ===

CustFeatures cfs = new CustFeatures();
CustFeature cf = null;

String[] sFeatureIds = BriteRequest.getParameterValues(request, "feature_id");

int l = ( sFeatureIds == null )?0:sFeatureIds.length;
boolean pvDeliveryTrackerOn = false;
boolean pvDeliveryTrackerOtherFeatures = false;

for (int i = 0; i < l; i++)
{
	cf = new CustFeature();
	cf.s_cust_id = cust.s_cust_id;
	cf.s_feature_id = sFeatureIds[i];
	
        // add the feature except if the feature is PV_DELIVERY_TRACKER.  
        // Only add PV_DELIVERY_TRACKER if any of the DELIVERY_TRACKER seed lists are checked.
        // add each DELIVERY_TRACKER feature (such as International, or Custom) as it is checked off.
        int feature_id = Integer.parseInt(cf.s_feature_id);
        if (feature_id == Feature.PV_DELIVERY_TRACKER){
            pvDeliveryTrackerOn = true;
        } else {
            cfs.add(cf);
        }
        
        if((feature_id == Feature.PV_DELIVERY_TRACKER_SEED_LIST) || 
           (feature_id == Feature.PV_DELIVERY_TRACKER_B2B) ||
           (feature_id == Feature.PV_DELIVERY_TRACKER_CANADIAN) ||
           (feature_id == Feature.PV_DELIVERY_TRACKER_INTERNATIONAL) ||
           (feature_id == Feature.PV_DELIVERY_TRACKER_CUSTOM)) {
            pvDeliveryTrackerOtherFeatures = true;
        }
	
	if(Feature.MS_CRM == Integer.parseInt(sFeatureIds[i]))
	{
		cf = new CustFeature();
		cf.s_cust_id = cust.s_cust_id;
		cf.s_feature_id = String.valueOf(Feature.BRITE_CONNECT);
		cfs.add(cf);
	}
        // if any of the other delivery tracker features is on, then turn on PV_DELIVERY_TRACKER.
        if (pvDeliveryTrackerOtherFeatures == true)
	{
		cf = new CustFeature();
		cf.s_cust_id = cust.s_cust_id;
		cf.s_feature_id = String.valueOf(Feature.PV_DELIVERY_TRACKER);
		cfs.add(cf);
	}
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

	// === === ===

	CustFeatures cfs_old = new CustFeatures();
	cfs_old.s_cust_id = cust.s_cust_id;
	cfs_old.retrieve(conn);
	cfs_old.delete(conn);
	cfs.save(conn);

	// === === ===	

	conn.commit();
}
catch(Exception ex)
{
	if (conn != null)
	{
		try { conn.rollback(); }
		catch(Exception exx) { logger.error("Exception: ", exx); }
	}
	throw ex;
}
finally
{
	if (conn != null)
	{
		try { conn.setAutoCommit(bAutoCommit); }
		catch(Exception ex) { logger.error("Exception: ", ex); }
		cp.free(conn);
	}
}
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_features.jsp?cust_id=<%=cust.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
