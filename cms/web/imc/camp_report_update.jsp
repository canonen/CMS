<%@ page
	language="java"
	import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String sCampID = null;
try
{
	Element e = XmlUtil.getRootElement(request);
	if(e == null) throw new Exception("Malformed Campaign Report xml.");
	sCampID = XmlUtil.getChildTextValue(e, "camp_id");
	if (sCampID != null) 
	{
	CampReport report = new CampReport(e);
		Campaign camp = new Campaign(sCampID);
		if ( ReportUtil.isDynamicContentReportCustomer(camp.s_cust_id) &&
			!ContUtil.isContSimple(camp.s_cont_id) &&
			 ReportUtil.isNewReport(camp.s_camp_id) )
		{
			report.save();
			System.out.println("creating report cache for logic blocks");
			Vector vec = ContUtil.getContLogicBlockContentElements(camp.s_cont_id);
			for (int n=0; n < vec.size(); n++) {
				String sContentBlockID = (String) vec.get(n);
				System.out.println("creating report cache for content block => " + sContentBlockID);
				Content cont = new Content(sContentBlockID);
				com.britemoon.cps.tgt.Filter reportFilter = FilterUtil.createCampContReportFilter(camp.s_cust_id, camp.s_origin_camp_id,  camp.s_camp_name, cont.s_cont_id, cont.s_cont_name);
				ReportUtil.setupReportCache(camp.s_cust_id, camp.s_camp_id, reportFilter.s_filter_id);
			}
		}
		else
		{
	report.save();
}
	}
}
catch (Exception ex)
{
	String sSql = 
		"UPDATE crpt_camp_summary" +
		" SET status_id = "+ReportStatus.ERROR +
		" WHERE camp_id = "+sCampID;
		
	if (sCampID != null) BriteUpdate.executeUpdate(sSql);
	logger.error("Campaign Report Update Error!\r\n", ex);
}
%>
