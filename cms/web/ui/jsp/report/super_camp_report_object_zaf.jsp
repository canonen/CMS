<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%!
	static Logger logger = null;
	private String CreateXML (String sCampID, HttpServletRequest request, Customer cust) throws Exception {
		String Result="";

		ConnectionPool cp = null;
		Connection conn = null;
		Connection conn2 = null;
		Statement stmt =null;			
		Statement stmt2 =null;			
		ResultSet rs=null;
		ResultSet rs2=null;

		byte[] bVal = new byte[255];

		try {
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("report_object.jsp");
			stmt = conn.createStatement();
			conn2 = cp.getConnection("report_object.jsp 2");
			stmt2 = conn2.createStatement();

			if (sCampID!=null) {			
				Result += "<Row>\n";		

// Fields description for (already sent campaign) stored procedure:
//
// <Id>            - Campaign Id
// <Name>          - Campaign Name
// <Size>          - Number of recipients for that campaign
// <BBacks>        - Number of Bounce Backs
// <BBackPrc>      - % of Bounce Backs = (<BBacks> / <Size>) * 100
// <Reaching>      - Number of received = (<Size> - <BBacks>)
// <ReachingPrc>   - % of received = (<Reaching> / <Size>) * 100
// <TotalReads>    - Number of times HTML docs read (from jump tracking)
// <DistinctReads> - Number of recipients who read (from jump tracking)
// <DistinctReadPrc> - % of recipients who read (from jump tracking) = (<DistinctReads> / <Size>) * 100
// <MultiReaders>  - Number of recipients who read multiple times
// <Unsubs>        - Number of unsubscribers
// <UnsubPrc>      - % of unsubscribers = (<Unsubs> / <Size>) * 100
// <TotalLinks>    - Number of Links
// <TotalClicks>   - Total Number of Click Thrus
// <DistinctClicks> - Number of Distinct Click Thrus
// <DistinctClickPrc> - % of Click Thrus = (<DistinctClicks> / <Size>) * 100
// <TotalText>     - Number of TEXT Clicks
// <TotalTextPrc>  - % of TEXT Clicks = (<TotalText> / <TotalClicks>) * 100
// <TotalHTML>     - Number of HTML Clicks
// <TotalHTMLPrc>  - % of HTML Clicks = (<TotalHTML> / <TotalClicks>) * 100
// <TotalAOL>      - Number of AOL Clicks
// <TotalAOLPrc>   - % of AOL Clicks = (<TotalAOL> / <TotalClicks>) * 100
// <DistinctText>     - Number of TEXT Clicks
// <DistinctTextPrc>  - % of TEXT Clicks = (<DistinctText> / <DistinctClicks>) * 100
// <DistinctHTML>     - Number of HTML Clicks
// <DistinctHTMLPrc>  - % of HTML Clicks = (<DistinctHTML> / <DistinctClicks>) * 100
// <DistinctAOL>      - Number of AOL Clicks
// <DistinctAOLPrc>   - % of AOL Clicks = (<DistinctAOL> / <DistinctClicks>) * 100
// <OneLinkMultiClickers> - Number of recipients who clicked a link multiple times
// <MultiLinkClickers> - Number of recipients who clicked multiple links
//

				rs=stmt.executeQuery("Exec usp_crpt_super_camp_list @super_camp_id="+sCampID+", @cust_id="+cust.s_cust_id);
				while( rs.next() ) {
					Result+="<Id>"+rs.getString("Id")+"</Id>\n";
					bVal = rs.getBytes("CampName");
					Result+="<Name><![CDATA["+(bVal!=null?new String(bVal, "UTF-8"):"")+"]]></Name>\n";
					Result+="<Size>"+rs.getString("Sent")+"</Size>\n";
					Result+="<BBacks>"+rs.getString("BBacks")+"</BBacks>\n";
					Result+="<Reaching>"+rs.getString("Reaching")+"</Reaching>\n";
					Result+="<DistinctReads>"+rs.getString("DistinctReads")+"</DistinctReads>\n";
					Result+="<TotalReads>"+rs.getString("TotalReads")+"</TotalReads>\n";
					Result+="<MultiReaders>"+rs.getString("MultiReaders")+"</MultiReaders>\n";
					Result+="<Unsubs>"+rs.getString("Unsubs")+"</Unsubs>\n";
					Result+="<TotalLinks>"+rs.getString("TotalLinks")+"</TotalLinks>\n";
					Result+="<TotalClicks>"+rs.getString("TotalClicks")+"</TotalClicks>\n";
					Result+="<TotalText>"+rs.getString("TotalText")+"</TotalText>\n";
					Result+="<TotalHTML>"+rs.getString("TotalHTML")+"</TotalHTML>\n";
					Result+="<TotalAOL>"+rs.getString("TotalAOL")+"</TotalAOL>\n";
					Result+="<DistinctClicks>"+rs.getString("DistinctClicks")+"</DistinctClicks>\n";
					Result+="<DistinctText>"+rs.getString("DistinctText")+"</DistinctText>\n";
					Result+="<DistinctHTML>"+rs.getString("DistinctHTML")+"</DistinctHTML>\n";
					Result+="<DistinctAOL>"+rs.getString("DistinctAOL")+"</DistinctAOL>\n";
					Result+="<OneLinkMultiClickers>"+rs.getString("OneLinkMultiClickers")+"</OneLinkMultiClickers>\n";
					Result+="<MultiLinkClickers>"+rs.getString("MultiLinkClickers")+"</MultiLinkClickers>\n";

					Result+="<BBackPrc>"+rs.getString("BBackPrc")+"</BBackPrc>\n";
					Result+="<ReachingPrc>"+rs.getString("ReachingPrc")+"</ReachingPrc>\n";
					Result+="<DistinctReadPrc>"+rs.getString("DistinctReadPrc")+"</DistinctReadPrc>\n";
					Result+="<UnsubPrc>"+rs.getString("UnsubPrc")+"</UnsubPrc>\n";
					Result+="<DistinctClickPrc>"+rs.getString("DistinctClickPrc")+"</DistinctClickPrc>\n";
					Result+="<TotalTextPrc>"+rs.getString("TotalTextPrc")+"</TotalTextPrc>\n";
					Result+="<TotalHTMLPrc>"+rs.getString("TotalHTMLPrc")+"</TotalHTMLPrc>\n";
					Result+="<TotalAOLPrc>"+rs.getString("TotalAOLPrc")+"</TotalAOLPrc>\n";
					Result+="<DistinctTextPrc>"+rs.getString("DistinctTextPrc")+"</DistinctTextPrc>\n";
					Result+="<DistinctHTMLPrc>"+rs.getString("DistinctHTMLPrc")+"</DistinctHTMLPrc>\n";
					Result+="<DistinctAOLPrc>"+rs.getString("DistinctAOLPrc")+"</DistinctAOLPrc>\n";
				}
				rs.close();

// Fields description for (links) stored procedure:
//
// <CampID>           - Campaign ID
// <HrefID>           - Href ID for the link
// <LinkName>         - Name of the link
// <TotalClicks>      - Total Number of Click Thrus on Link
// <DistinctClicks>   - Number of Distinct Click Thrus on Link
// <TotalText>        - Number of TEXT Clicks
// <TotalTextPrc>     - % of TEXT Clicks = (<TotalText> / <TotalClicks>) * 100
// <TotalHTML>        - Number of HTML Clicks
// <TotalHTMLPrc>     - % of HTML Clicks = (<TotalHTML> / <TotalClicks>) * 100
// <TotalAOL>         - Number of AOL Clicks
// <TotalAOLPrc>      - % of AOL Clicks = (<TotalAOL> / <TotalClicks>) * 100
// <DistinctText>     - Number of TEXT Clicks
// <DistinctTextPrc>  - % of TEXT Clicks = (<DistinctText> / <DistinctClicks>) * 100
// <DistinctHTML>     - Number of HTML Clicks
// <DistinctHTMLPrc>  - % of HTML Clicks = (<DistinctHTML> / <DistinctClicks>) * 100
// <DistinctAOL>      - Number of AOL Clicks
// <DistinctAOLPrc>   - % of AOL Clicks = (<DistinctAOL> / <DistinctClicks>) * 100
// <MultiClickers> 	  - Number of recipients who clicked link multiple times
	 

				rs=stmt.executeQuery("Exec usp_crpt_super_camp_links @super_camp_id="+sCampID);
				while( rs.next() ) {
					Result+="<SuperLinks>\n";
					Result+="<SuperCampID>"+sCampID+"</SuperCampID>\n";
					String superLinkID = rs.getString("Id");
					Result+="<SuperLinkID>"+superLinkID+"</SuperLinkID>\n";
					bVal = rs.getBytes("SuperLinkName");
					Result+="<SuperLinkName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></SuperLinkName>\n";
					Result+="<TotalClicks>"+rs.getString("TotalClicks")+"</TotalClicks>\n";
					Result+="<TotalText>"+rs.getString("TotalText")+"</TotalText>\n";
					Result+="<TotalHTML>"+rs.getString("TotalHTML")+"</TotalHTML>\n";
					Result+="<TotalAOL>"+rs.getString("TotalAOL")+"</TotalAOL>\n";
					Result+="<DistinctClicks>"+rs.getString("DistinctClicks")+"</DistinctClicks>\n";
					Result+="<DistinctText>"+rs.getString("DistinctText")+"</DistinctText>\n";
					Result+="<DistinctHTML>"+rs.getString("DistinctHTML")+"</DistinctHTML>\n";
					Result+="<DistinctAOL>"+rs.getString("DistinctAOL")+"</DistinctAOL>\n";

					Result+="<TotalClickPrc>"+rs.getString("TotalClickPrc")+"</TotalClickPrc>\n";
					Result+="<TotalTextPrc>"+rs.getString("TotalTextPrc")+"</TotalTextPrc>\n";
					Result+="<TotalHTMLPrc>"+rs.getString("TotalHTMLPrc")+"</TotalHTMLPrc>\n";
					Result+="<TotalAOLPrc>"+rs.getString("TotalAOLPrc")+"</TotalAOLPrc>\n";
					
					Result+="<DistinctClickPrc>"+rs.getString("DistinctClickPrc")+"</DistinctClickPrc>\n";
					Result+="<DistinctTextPrc>"+rs.getString("DistinctTextPrc")+"</DistinctTextPrc>\n";
					Result+="<DistinctHTMLPrc>"+rs.getString("DistinctHTMLPrc")+"</DistinctHTMLPrc>\n";
					Result+="<DistinctAOLPrc>"+rs.getString("DistinctAOLPrc")+"</DistinctAOLPrc>\n";

					int nNonLinkCamps = 0;
					rs2 = stmt2.executeQuery("SELECT count(c.camp_id) FROM cque_campaign c, cque_super_camp_camp s"
						+ " WHERE c.origin_camp_id = s.camp_id"
						+ " AND c.type_id > "+CampaignType.TEST
						+ " AND s.super_camp_id = "+sCampID
						+ " AND c.camp_id NOT IN (SELECT cc.camp_id"
							+ " FROM cque_campaign cc, cjtk_link l, crpt_super_link_link sl"
							+ " WHERE cc.cont_id = l.cont_id AND l.link_id = sl.link_id"
							+ " AND sl.super_link_id = "+superLinkID+" AND sl.super_camp_id = "+sCampID+")");
					if (rs2.next()) {
						nNonLinkCamps = rs2.getInt(1);
					}
					rs2.close();
					Result+="<NonLinkCamps>"+nNonLinkCamps+"</NonLinkCamps>\n";

					Result += "</SuperLinks>\n";
				}
				rs.close();

// Fields description for (links) stored procedure:
//
// <CampID>           - Campaign ID
// <CampName>         - Name of the link
 
	            String subCampID = null;
				rs=stmt.executeQuery("Exec usp_crpt_super_camp_camp_list @super_camp_id="+sCampID);
				while( rs.next() ) {
					Result+="<SubCampaigns>\n";
					subCampID = rs.getString("CampID");
					Result+="<CampID>"+subCampID+"</CampID>\n";
					bVal = rs.getBytes("CampName");
					Result+="<CampName><![CDATA["+(bVal!=null?new String(bVal, "UTF-8"):"")+"]]></CampName>\n";
					rs2=stmt2.executeQuery("Exec usp_crpt_camp_list @camp_id="+subCampID+", @cust_id="+cust.s_cust_id);
					if ( rs2.next() ) {
						Result+="<StartDate>"+rs2.getString("StartDate")+"</StartDate>\n";
						Result+="<Size>"+rs2.getString("Sent")+"</Size>\n";
						Result+="<BBacks>"+rs2.getString("BBacks")+"</BBacks>\n";
						Result+="<Unsubs>"+rs2.getString("Unsubs")+"</Unsubs>\n";
						Result+="<Clicks>"+rs2.getString("DistinctClicks")+"</Clicks>\n";
						Result+="<BBackPrc>"+rs2.getString("BBackPrc")+"</BBackPrc>\n";
						Result+="<UnsubPrc>"+rs2.getString("UnsubPrc")+"</UnsubPrc>\n";
						Result+="<ClickPrc>"+rs2.getString("DistinctClickPrc")+"</ClickPrc>\n";
					}
					rs2.close();
					Result += "</SubCampaigns>\n";
				}
				rs.close();

//				// Get list of sent campaigns from super camp's campaigns
//				String sCampList = "";
//				sSql = "SELECT c.camp_id FROM cque_campaign c, cque_super_camp_camp s"
//					+ " WHERE c.origin_camp_id = s.camp_id"
//					+ " AND c.type_id > "+CampaignType.TEST
//					+ " AND s.super_camp_id = "+superCampID;
//				rs = stmt.executeQuery(sSql);
//				while (rs.next()) {
//					sCampList += ((sCampList.length() > 0)?",":"")+rs.getString(1);
//				}
//				sSql = "SELECT count(s.camp_id) FROM cque_super_camp_camp s"
//					+ " WHERE s.super_camp_id = "+superCampID
//					+ " AND s.camp_id NOT IN (SELECT c.origin_camp_id FROM cque_campaign c"
//						+" WHERE c.camp_id IN (SELECT cc.camp_id FROM cque_campaign cc, cque_super_camp_camp ss"
//						+ " WHERE cc.origin_camp_id = ss.camp_id"
//						+ " AND cc.type_id > "+CampaignType.TEST
//						+ " AND ss.super_camp_id = "+superCampID+"))";
//	
//				int nCampsNotSent = 0;
//				rs = stmt.executeQuery(sSql);
//				if (rs.next())
//					nCampsNotSent = rs.getInt(1);
//	
//				bAllCampsSent = (nCampsNotSent == 0);

				Result += "</Row>\n";
			}
		} catch (Exception ex) {
			throw ex;								
		} finally {
			try {
				if (stmt2!=null) stmt2.close();
			} catch (Exception ignore) { }
			if (conn2!=null) cp.free(conn2);
			try {
				if (stmt!=null) stmt.close();
			} catch (Exception ignore) { }
			if (conn!=null) cp.free(conn);
		}
		return Result;
	}
%>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
	response.setContentType("text/html; charset=UTF-8");
%>
<%@ include file="../validator.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
try
{
	String XSLDir = Registry.getKey("report_xsl_dir");

//	String XSLDir = "c:/Work/Britemoon_5.0/cms_500/web/ui/jsp/report/xsl/";
	String XSLFile = "";
	String sCampList=null;

	XSLFile=XSLDir+"SuperCampReportView_zaf.xsl";
	
	String sXML="<?xml version=\"1.0\"?>\n\n <CampaignList>\n";			
	sXML+="<CampaignView>super_camp_report_object.jsp</CampaignView>\n";
	sXML+="<SubCampaignView>report_object.jsp</SubCampaignView>\n";
	sXML+="<StyleSheet>"+ui.s_css_filename+"</StyleSheet>\n";
	
	if (request.getParameter("id")!=null){

		sCampList = request.getParameter("id");
		sXML+="<Ids>" + sCampList + "</Ids>\n";	

		if (sCampList.indexOf(",") == -1) sXML+="<OnlyOne>1</OnlyOne>\n";	

		sXML+="<Campaigns>\n";	

		while (sCampList.indexOf(",") != -1){
			sXML+=CreateXML(sCampList.substring(0,sCampList.indexOf(",")), request, cust);
			sCampList = sCampList.substring(sCampList.indexOf(",") + 1);					
		}

		sXML+=CreateXML(sCampList, request, cust);

		sXML+="</Campaigns>\n";
	};
	
	sXML+="</CampaignList>\n";

	File fxsl=new File(XSLFile);

	TransformerFactory tfactory = TransformerFactory.newInstance();
	Templates templates = tfactory.newTemplates(new StreamSource(fxsl));
	Transformer transformer = templates.newTransformer();
	StringReader srXML = new StringReader(sXML);
	transformer.transform(new StreamSource(srXML), new StreamResult(out));

	srXML.close();
	srXML = null;
}
catch(Exception ex)
{
	ErrLog.put(this,ex,"Error: "+ex.getMessage(),out,1);
}
finally
{
	out.flush();
}
%>
