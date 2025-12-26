<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="application/vnd.ms-excel;charset=UTF-8"
%>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
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

boolean canRecipView = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
String sRecipView = "0";
if (canRecipView) sRecipView = "1";
	
ConnectionPool cp = null;
Connection conn = null;
Statement stmt =null;			
ResultSet rs=null;
	
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_export.jsp");
	stmt = conn.createStatement();

	String sCache = request.getParameter("Z");	
	sCache = ("1".equals(sCache))?sCache:"0";
	
	String sCacheID = request.getParameter("C");
	if ( (sCacheID == null) || (sCacheID.equals("")) ) sCacheID = "0";
	if (("1".equals(user.s_recip_owner)) && ("0".equals(sCache))) sCache = "2";

	boolean lonely = false;

	String sXML=
		"<?xml version=\"1.0\"?>\r\n\r\n <CampaignList>" +
		"<CampaignView>report_object.jsp</CampaignView>" +
		"<DetailView>report_detail.jsp</DetailView>" +
		"<ReportCache>"+sCache+"</ReportCache>" +
		"<CacheID>"+sCacheID+"</CacheID>" +
		"<RecipOwner>"+user.s_recip_owner+"</RecipOwner>" +
		"<StyleSheet>"+ui.s_css_filename+"</StyleSheet>" +
		"<RecipView>" + sRecipView + "</RecipView>";
	
	String sCampList=null;
	if (request.getParameter("id")!=null)
	{
		sCampList = request.getParameter("id");
		sXML+="<Ids>" + sCampList + "</Ids>\n";	

		if (sCampList.indexOf(",") == -1)
		{
			sXML+="<OnlyOne>1</OnlyOne>\n";	
			lonely = true;
		}

		int nPos = 0;
		rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_pos WHERE camp_id IN ("+sCampList+")");
		if (rs.next())nPos = rs.getInt(1);
		rs.close();

		rs = stmt.executeQuery("SELECT count(*) FROM crpt_mbs_revenue_report WHERE camp_id IN ("+sCampList+")");
		if (rs.next())nPos += rs.getInt(1);
		rs.close();

		sXML+="<ReportPosFlag>"+nPos+"</ReportPosFlag>\n";

		rs = stmt.executeQuery("EXEC usp_crpt_report_settings_get @cust_id = "+cust.s_cust_id);
		if (rs.next())
		{
			sXML += "<TotalsSecFlag>"+rs.getString(1)+"</TotalsSecFlag>\n";
			sXML += "<GeneralSecFlag>"+rs.getString(2)+"</GeneralSecFlag>\n";
			sXML += "<BBackSecFlag>"+rs.getString(3)+"</BBackSecFlag>\n";
			sXML += "<ActionSecFlag>"+rs.getString(4)+"</ActionSecFlag>\n";
			sXML += "<DistClickSecFlag>"+rs.getString(5)+"</DistClickSecFlag>\n";
			sXML += "<TotClickSecFlag>"+rs.getString(6)+"</TotClickSecFlag>\n";
			sXML += "<FormSecFlag>"+rs.getString(7)+"</FormSecFlag>\n";
			sXML += "<TotReadFlag>"+rs.getString(8)+"</TotReadFlag>\n";
			sXML += "<MultiReadFlag>"+rs.getString(9)+"</MultiReadFlag>\n";
			sXML += "<TotClickFlag>"+rs.getString(10)+"</TotClickFlag>\n";
			sXML += "<MultiLinkClickFlag>"+rs.getString(11)+"</MultiLinkClickFlag>\n";
			sXML += "<LinkMultiClickFlag>"+rs.getString(12)+"</LinkMultiClickFlag>\n";
			sXML += "<DomainFlag>"+rs.getString(13)+"</DomainFlag>\n";
			sXML += "<OptoutFlag>"+rs.getString(14)+"</OptoutFlag>\n";
		}
		else
		{
			sXML += "<TotalsSecFlag>1</TotalsSecFlag>\n";
			sXML += "<GeneralSecFlag>1</GeneralSecFlag>\n";
			sXML += "<BBackSecFlag>1</BBackSecFlag>\n";
			sXML += "<ActionSecFlag>1</ActionSecFlag>\n";
			sXML += "<DistClickSecFlag>1</DistClickSecFlag>\n";
			sXML += "<TotClickSecFlag>0</TotClickSecFlag>\n";
			sXML += "<FormSecFlag>1</FormSecFlag>\n";
			sXML += "<TotReadFlag>0</TotReadFlag>\n";
			sXML += "<MultiReadFlag>1</MultiReadFlag>\n";
			sXML += "<TotClickFlag>1</TotClickFlag>\n";
			sXML += "<MultiLinkClickFlag>1</MultiLinkClickFlag>\n";
			sXML += "<LinkMultiClickFlag>1</LinkMultiClickFlag>\n";
			sXML += "<DomainFlag>1</DomainFlag>\n";
			sXML += "<OptoutFlag>0</OptoutFlag>\n";
		}

		sXML+="<Campaigns>\n";	

		while (sCampList.indexOf(",") != -1)
		{
			sXML+=CreateXML(sCampList.substring(0,sCampList.indexOf(",")), sCacheID, request, cust, user, sCache, stmt);
			sCampList = sCampList.substring(sCampList.indexOf(",") + 1);					
		}

		sXML+=CreateXML(sCampList, sCacheID, request, cust, user, sCache, stmt);

		sXML+="</Campaigns>\n";
	}
	
	sXML+="</CampaignList>\n";

	// determine which xsl to use
	String XSLDir = Registry.getKey("report_xsl_dir");
	String XSLFile = XSLDir+"ReportExport.xsl";
	
	// === === ===

	File fxsl=new File(XSLFile);

	TransformerFactory tfactory = TransformerFactory.newInstance();
	Templates templates = tfactory.newTemplates(new StreamSource(fxsl));
	Transformer transformer = templates.newTransformer();
	StringReader srXML = new StringReader(sXML);
	transformer.transform(new StreamSource(srXML), new StreamResult(out));

	srXML.close();
}
catch(Exception ex) { throw ex; }
finally
{
	try { if (stmt!=null) stmt.close(); }
	catch (Exception ignore) { }
	if (conn!=null) cp.free(conn);
	out.flush();
}
%>

<%!
private String CreateXML
	(String sCampID, String sCacheID, HttpServletRequest request,
		Customer cust, User user, String sCache, Statement stmt)
		throws Exception
{
	ResultSet rs=null;
	String Result="";

	byte[] bVal = new byte[255];
	String sVal = null;
	
	// ********* KU
	
	int iCount = 0;
	String sClassAppend = "_other";

	if (sCampID!=null)
	{			
		Result += "<Row>\n";		

// Fields description for (already sent campaign) stored procedure:
//
// <Id>            - Campaign Id
// <Name>          - Campaign Name
// <Date>          - Date when the campaign started
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

		rs=stmt.executeQuery("Exec usp_crpt_camp_list @camp_id="+sCampID+", @cache_id="+sCacheID+", @cust_id="+cust.s_cust_id+", @cache="+sCache);
		while( rs.next() )
		{
			Result+="<Id>"+rs.getString("Id")+"</Id>\n";
			bVal = rs.getBytes("CampName");
			Result+="<Name><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></Name>\n";
			Result+="<StartDate>"+rs.getString("StartDate")+"</StartDate>\n";
			Result+="<Size>"+rs.getString("Sent")+"</Size>\n";
			Result+="<BBacks>"+rs.getString("BBacks")+"</BBacks>\n";
			Result+="<Reaching>"+rs.getString("Reaching")+"</Reaching>\n";
			Result+="<DistinctReads>"+rs.getString("DistinctReads")+"</DistinctReads>\n";
			Result+="<TotalReads>"+rs.getString("TotalReads")+"</TotalReads>\n";
			Result+="<MultiReaders>"+rs.getString("MultiReaders")+"</MultiReaders>\n";
			Result+="<Unsubs>"+rs.getString("Unsubs")+"</Unsubs>\n";
			Result+="<TotalLinks>"+rs.getString("TotalLinks")+"</TotalLinks>\n";
			Result+="<TotalClicks>"+rs.getString("TotalClicks")+"</TotalClicks>\n";
			Result+="<DistinctClicks>"+rs.getString("DistinctClicks")+"</DistinctClicks>\n";

			Result+="<BBackPrc>"+rs.getString("BBackPrc")+"</BBackPrc>\n";
			Result+="<ReachingPrc>"+rs.getString("ReachingPrc")+"</ReachingPrc>\n";
			Result+="<DistinctReadPrc>"+rs.getString("DistinctReadPrc")+"</DistinctReadPrc>\n";
			Result+="<UnsubPrc>"+rs.getString("UnsubPrc")+"</UnsubPrc>\n";
			Result+="<DistinctClickPrc>"+rs.getString("DistinctClickPrc")+"</DistinctClickPrc>\n";
		}
		rs.close();
				
		if ("1".equals(sCache))
		{
			rs = stmt.executeQuery("SELECT distinct convert(varchar(30),c.cache_start_date,100), convert(varchar(30),c.cache_end_date,100),"
					+ " c.user_id, c.attr_id, a.display_name, c.attr_value1, c.attr_value2, o.sql_name"
					+ " FROM crpt_camp_summary_cache c"
					+ " LEFT OUTER JOIN ccps_cust_attr a ON a.attr_id = c.attr_id"
					+ " LEFT OUTER JOIN ctgt_compare_operation o ON o.operation_id = c.attr_operator"
					+ " WHERE c.camp_id = " + sCampID + " AND cache_id = " + sCacheID);
			while (rs.next())
			{
				Result+="<Cache>\n";
				Result+="<CampID>"+sCampID+"</CampID>\n";
				sVal = rs.getString(1);
				Result+="<StartDate>"+(sVal!=null?sVal:"")+"</StartDate>\n";
				sVal = rs.getString(2);
				Result+="<EndDate>"+(sVal!=null?sVal:"")+"</EndDate>\n";
				sVal = rs.getString(3);
				Result+="<UserID>"+(sVal!=null?sVal:"0")+"</UserID>\n";
				sVal = rs.getString(4);
				Result+="<AttrID>"+(sVal!=null?sVal:"")+"</AttrID>\n";
				bVal = rs.getBytes(5);
				Result+="<AttrName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></AttrName>\n";
				bVal = rs.getBytes(6);
				Result+="<AttrValue1><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></AttrValue1>\n";
				bVal = rs.getBytes(7);
				Result+="<AttrValue2><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></AttrValue2>\n";
				bVal = rs.getBytes(7);
				Result+="<AttrOperator><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></AttrOperator>\n";
				Result += "</Cache>\n";
				
				iCount++;
			}
			rs.close();
		}
		else if ("2".equals(sCache))
		{
			Result+="<Cache>\n";
			Result+="<CampID>"+sCampID+"</CampID>\n";
			Result+="<StartDate></StartDate>\n";
			Result+="<EndDate></EndDate>\n";
			Result+="<UserID>"+user.s_user_id+"</UserID>\n";
			Result+="<AttrID></AttrID>\n";
			Result+="<AttrName><![CDATA[]]></AttrName>\n";
			Result+="<AttrValue1><![CDATA[]]></AttrValue1>\n";
			Result+="<AttrValue2><![CDATA[]]></AttrValue2>\n";
			Result+="<AttrOperator><![CDATA[]]></AttrOperator>\n";
			Result += "</Cache>\n";
		}

		Result += "</Row>\n";
	}
	return Result;
}
%>
