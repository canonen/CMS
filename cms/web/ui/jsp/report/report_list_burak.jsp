<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
	response.setContentType("text/html; charset=UTF-8");
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

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);
// release 5.9 Auto-Update Report Controls
boolean isUpdateRptEnabled = ui.getFeatureAccess(Feature.UPDATE_AUTO_REPORT);
System.out.println("isUpdateRptEnabled = " + isUpdateRptEnabled);

boolean canRecipView = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
String sRecipView = "0";
if (canRecipView) sRecipView = "1";


// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list.jsp");
	stmt = conn.createStatement();

	String sSQL=null;
	
	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");
	
	int			curPage			= 1;
	int			amount			= 0;
	
	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

	if (samount == null) samount = ui.getSessionProperty("rept_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("rept_list_page_size", samount);
	
	String sSelectedCategoryID = request.getParameter("category_id");
	if ((sSelectedCategoryID == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryID = ui.s_category_id;

	String XSLDir = Registry.getKey("report_xsl_dir");
	String XSLFile= XSLDir + "ReportList.xsl";
		
	String sXML="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	sXML+="<CampaignList>\n";
	sXML+="<StyleSheet>" + ui.s_css_filename + "</StyleSheet>\n";
	sXML+="<PageAmount>" + samount + "</PageAmount>\n";
	sXML+="<CurrentPage>" + String.valueOf(curPage) + "</CurrentPage>\n";
	sXML+="<PrevPage>" + String.valueOf(curPage - 1) + "</PrevPage>\n";
	sXML+="<NextPage>" + String.valueOf(curPage + 1) + "</NextPage>\n";
	sXML+="<RecipView>" + sRecipView + "</RecipView>\n";
	sXML+="<RecipOwner>" + user.s_recip_owner + "</RecipOwner>\n";
//	sXML+="<CampaignView>report_object.jsp</CampaignView>\n";
	sXML+="<CampaignView>report_redirect.jsp</CampaignView>\n";
	sXML+="<CampaignUpdate>report_update.jsp</CampaignUpdate>\n";
	sXML+="<PrintEnabled>" + String.valueOf(isPrintEnabled) + "</PrintEnabled>";
	sXML+="<UpdateAutoReportEnabled>" + String.valueOf(isUpdateRptEnabled) + "</UpdateAutoReportEnabled>";	
	
	if(sSelectedCategoryID!= null)
		sXML+="<CurrentCategoryID>" +sSelectedCategoryID+ "</CurrentCategoryID>\n";
	if(!canCat.bExecute)
		sXML+="<CategoryDisable>1</CategoryDisable>\n";
	if(!canCat.bRead)
		sXML+="<CategoryReadDisable>1</CategoryReadDisable>\n";

	sSQL = "SELECT category_id, category_name"
		+ " FROM ccps_category"
		+ " WHERE cust_id = "+cust.s_cust_id
		+ " ORDER BY category_name";
	rs = stmt.executeQuery(sSQL);
	
	sXML+="<Categories>\n";
	sXML += "<Category>\r\n <CategoryID>0</CategoryID>\r\n";
	sXML += " <CategoryName>All</CategoryName>\r\n</Category>\r\n";
	String sCategoryID = null;
	String sCategoryName = null;
	
	while (rs.next())
	{
		sCategoryID = rs.getString(1);
		sCategoryName = new String(rs.getBytes(2), "UTF-8");
		sXML += "<Category>\r\n <CategoryID>" + sCategoryID + "</CategoryID>\r\n";
		sXML += " <CategoryName><![CDATA[" + sCategoryName + "]]></CategoryName>\r\n</Category>\r\n";
	}
	rs.close();
	sXML+="</Categories>\n";
	
	// ********* KU
	int iCount = 0;
	String sClassAppend = "_other";


	// Fields description for (already sent campaign) stored procedure: ????
	//
	// <Id>          - Campaign Id
	// <Name>        - Campaign Name
	// <TypeId>      - Campaign Type Id
	// <StartDate>   - Date when the campaign started
	// <Size>        - Number of recipients for that campaign
	// <BBacks>      - Number of Bounce Backs
	// <BBackPrc>    - % of Bounce Backs = (<BBacks> / <Size>) * 100
	// <Clicks>      - Number of Click Throughs
	// <ClickPrc>    - % of Click Throughs = (<CThrough> / <Size>) * 100
	// <Unsubs>      - Number of unsubscribers
	// <UnsubsPrc>   - % of unsubscribers = (<Unsubscr> / <Size>) * 100
	// <UpdateDate>     - date when report last updated
	// <UpdateStatusId> - status of report update
	// <UpdateStatus>   - status of report update
	//

	sSQL="EXEC usp_crpt_camp_list @cust_id="+cust.s_cust_id;

	if (sSelectedCategoryID!=null)
		sSQL +=",@category_id=" + sSelectedCategoryID;

	if (stmt.execute(sSQL))
	{
		rs=stmt.getResultSet();
		sXML+="<Campaigns>\n";	
		StringWriter swRow=new StringWriter();
		
		while (rs.next())
		{
			if (iCount % 2 != 0)
			{
				sClassAppend = "_other";
			}
			else
			{
				sClassAppend = "";
			}
			
			iCount++;
			
			//Page logic
			if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
		
			swRow.write("<Row>\n");
			swRow.write("<Id>"+rs.getString(1)+"</Id>\n");
			swRow.write("<Name><![CDATA["+new String(rs.getBytes(2), "UTF-8")+"]]></Name>\n");
			swRow.write("<TypeId>"+rs.getString(3)+"</TypeId>\n");
			swRow.write("<MediaTypeId>"+rs.getString(4)+"</MediaTypeId>\n");
			swRow.write("<StartDate>"+rs.getString(5).replace("AM"," AM").replace("PM"," PM")+"</StartDate>\n");
			swRow.write("<Size>"+rs.getString(6)+"</Size>\n");
			swRow.write("<TReads>"+rs.getString(17)+"</TReads>\n");
			swRow.write("<TReadsPrc>"+rs.getString(18)+"</TReadsPrc>\n");
			swRow.write("<BBacks>"+rs.getString(7)+"</BBacks>\n");
			swRow.write("<Clicks>"+rs.getString(8)+"</Clicks>\n");
			swRow.write("<Unsubs>"+rs.getString(9)+"</Unsubs>\n");
			swRow.write("<UpdateDate>"+rs.getString(10)+"</UpdateDate>\n");
			swRow.write("<UpdateStatusId>"+rs.getString(11)+"</UpdateStatusId>\n");
			swRow.write("<UpdateStatus>"+rs.getString(12)+"</UpdateStatus>\n");
			swRow.write("<BBackPrc>"+rs.getString(13)+"</BBackPrc>\n");
			swRow.write("<ClickPrc>"+rs.getString(14)+"</ClickPrc>\n");
			swRow.write("<UnsubPrc>"+rs.getString(15)+"</UnsubPrc>\n");
			swRow.write("<Cache>"+rs.getString(16)+"</Cache>\n");
			swRow.write("<StyleClass>"+sClassAppend+"</StyleClass>\n");
			swRow.write("</Row>\n");
		}
		sXML+=swRow.toString()+"</Campaigns>\n";
	}
						
	sXML+="<CampRowCount>" + iCount + "</CampRowCount>\n";
							
	sXML+="</CampaignList>\n";

	//System.out.println(sXML);

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
	if (stmt!=null) stmt.close();
	if (conn!=null) cp.free(conn);
	out.flush();
}

%>
