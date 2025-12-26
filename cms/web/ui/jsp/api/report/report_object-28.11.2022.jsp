<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.*,
			javax.servlet.http.HttpSession,
			org.w3c.dom.Document,
			java.net.HttpURLConnection,
 			java.net.URL,
  			java.net.URLConnection,
			org.w3c.tidy.Tidy,
			org.xhtmlrenderer.pdf.ITextRenderer,
 			org.xhtmlrenderer.simple.extend.XhtmlNamespaceHandler,
 			org.xml.sax.SAXException"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%
  response.setHeader("Expires", "0");
  response.setHeader("Pragma", "no-cache");
  response.setHeader("Cache-Control", "no-cache");
  response.setHeader("Cache-Control", "max-age=0");
%>
<%
  String actionType = request.getParameter("act");
  String actionPrints = request.getParameter("prints");
  if (actionType != null && actionType.equals("PRNT"))
  {
    response.setContentType ("application/vnd.ms-excel");
    response.setHeader("Content-disposition","inline; filename=report_object.xls");

  }else if(actionType != null && actionType.equals("PDF")){

    HttpSession session2 = request.getSession();
    String sessionId = session2.getId();

    String urlString =  request.getHeader("Referer");

    URL url = new URL(urlString+"&prints=1");

    HttpURLConnection urlConn = null;
    urlConn = (HttpURLConnection)url.openConnection();

    urlConn.setRequestProperty("Content-Type", "application/pdf");
    urlConn.setRequestProperty("Cookie", "JSESSIONID=" + sessionId);

    response.setContentType("application/pdf");

    InputStream byteStream = urlConn.getInputStream();
    OutputStream os = response.getOutputStream();

    Tidy tidy = new Tidy();
    tidy.setXHTML(true);
    tidy.setQuiet(true);
    tidy.setHideComments(true);
    tidy.setInputEncoding("UTF-8");
    tidy.setOutputEncoding("UTF-8");
    tidy.setShowErrors(0);
    tidy.setShowWarnings(false);

    Document doc = tidy.parseDOM(byteStream, null);
    ITextRenderer renderer = new ITextRenderer();

    System.out.println("asd"+os);

    renderer.setDocument(doc, null, new XhtmlNamespaceHandler());
    renderer.layout();
    try
    {
      renderer.createPDF(os);
    } catch (Exception e) {
      response.getWriter().print("Unable to create your PDF file");
    }


  }else
    response.setContentType ("text/html");
%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>
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

//CY 08042013
//UI Type
  boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

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
    conn = cp.getConnection(this);
    stmt = conn.createStatement();

    String sCache = request.getParameter("Z");
    sCache = ("1".equals(sCache))?sCache:"0";

    String sCacheList = request.getParameter("C");
    if ( (sCacheList == null) || (sCacheList.equals("")) ) sCacheList = "0";
    if (("1".equals(user.s_recip_owner)) && ("0".equals(sCache))) sCache = "2";

    boolean lonely = false;

    actionPrints = ("1".equals(actionPrints))?actionPrints:"0";


    String sXML=
            "<?xml version=\"1.0\"?>\r\n\r\n <CampaignList>" +
                    "<CampaignView>report_object.jsp</CampaignView>" +
                    "<DetailView>report_detail.jsp</DetailView>" +
                    "<ReportCache>"+sCache+"</ReportCache>" +
                    "<actionPrints>"+actionPrints+"</actionPrints>" +
                    "<RecipOwner>"+user.s_recip_owner+"</RecipOwner>" +
                    "<StyleSheet>"+ui.s_css_filename+"</StyleSheet>" +
                    "<RecipView>" + sRecipView + "</RecipView>";

    String sCampList=null;
    if (request.getParameter("id")!=null)
    {
      sCampList = request.getParameter("id");


      if (sCampList.indexOf(",") == -1 && sCacheList.indexOf(",") == -1)
      {
        sXML+="<OnlyOne>1</OnlyOne>\n";
        lonely = true;
      }

      // added the tag to show Delivery tracker tab (part of release 5.9)
      int showTrackerRpt = 0;
      boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
      if (bFeat)
      {
        int nCount = 0;
        StringTokenizer st = new StringTokenizer(sCampList, ",");
        while (st.hasMoreTokens()) {
          String token = st.nextToken();
          nCount += getSeedListCount(stmt,cust.s_cust_id, token);
        }
        if (nCount > 0)
          showTrackerRpt = 1;
      }
      sXML+="<DeliveryTrackerRptFlag>"+showTrackerRpt+"</DeliveryTrackerRptFlag>\n";
      // end


      if (!bStandardUI) {
        int showstandardUIRpt = 1;
        sXML+="<StandardUIRptFlag>"+showstandardUIRpt+"</StandardUIRptFlag>\n";
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

      String[] sTempCampList = sCampList.split(",");
      String[] sTempCacheList = sCacheList.split(",");
      for (int i=0; i < sTempCampList.length; i++) {
        String sCampID = sTempCampList[i];
        for (int j=0; j < sTempCacheList.length; j++) {
          String sCacheID = sTempCacheList[j];
          String tmp = CreateXML(sCampID, sCacheID, request, cust, user, sCache, stmt);
          //logger.info("campaign = " + tmp);
          sXML+=tmp;
        }
      }

      sXML+="</Campaigns>\n";
    }

    sXML+="</CampaignList>\n";
    //logger.info("sXML = " + sXML);
    // determine which xsl to use
    String XSLDir = Registry.getKey("report_xsl_dir");
    String XSLFile = XSLDir+"ReportView.xsl";
    String sAction = request.getParameter("act");
    if ( (sAction !=null) && (sAction.equalsIgnoreCase("PRNT")) ) XSLFile=XSLDir+"ReportPrnt.xsl";

    // use different xsl for non-email campaigns
    if (lonely)
    {
      // it's probably faster to look up the database than create a campaign object
      rs = stmt.executeQuery(
              " SELECT 1 FROM cque_campaign" +
                      " WHERE camp_id = " + sCampList +
                      " AND ((type_id = 5) OR (media_type_id = 2))");
      if (rs.next())
      {
        XSLFile = XSLDir+"ReportViewNonEmail.xsl";
        if ( (sAction !=null) && (sAction.equalsIgnoreCase("PRNT")) )
        {
          XSLFile=XSLDir+"ReportPrntNonEmail.xsl";
        }
      }
      rs.close();
    }

    // === === ===




);
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
      boolean hasNone = true;
      while( rs.next() )
      {
        hasNone = false;
        Result+="<Id>"+rs.getString("Id")+"</Id>\n";
        Result+="<CacheId>"+sCacheID+"</CacheId>\n";
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
      if (hasNone) {
        // some xsl logic requires the camp id for navigation. so when we don't have any valid <Row>, we need to at least provide the camp id
        Result+="<Id>"+sCampID+"</Id>\n";
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


      rs=stmt.executeQuery("Exec usp_crpt_camp_links @camp_id="+sCampID+", @cache_id="+sCacheID+", @cache="+sCache);
      while( rs.next() )
      {
        // ********* KU
        if (iCount % 2 != 0) sClassAppend = "_other";
        else sClassAppend = "";

        iCount++;

        Result+="<Links>\n";
        Result+="<CampID>"+sCampID+"</CampID>\n";
        Result+="<HrefID>"+rs.getString("Id")+"</HrefID>\n";
        bVal = rs.getBytes("LinkName");
        Result+="<LinkName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></LinkName>\n";
        Result+="<TotalClicks>"+rs.getString("TotalClicks")+"</TotalClicks>\n";
        Result+="<TotalText>"+rs.getString("TotalText")+"</TotalText>\n";
        Result+="<TotalHTML>"+rs.getString("TotalHTML")+"</TotalHTML>\n";
        Result+="<TotalAOL>"+rs.getString("TotalAOL")+"</TotalAOL>\n";
        Result+="<DistinctClicks>"+rs.getString("DistinctClicks")+"</DistinctClicks>\n";
        Result+="<DistinctText>"+rs.getString("DistinctText")+"</DistinctText>\n";
        Result+="<DistinctHTML>"+rs.getString("DistinctHTML")+"</DistinctHTML>\n";
        Result+="<DistinctAOL>"+rs.getString("DistinctAOL")+"</DistinctAOL>\n";
        Result+="<MultiClickers>"+rs.getString("MultiClickers")+"</MultiClickers>\n";

        Result+="<TotalClickPrc>"+rs.getString("TotalClickPrc")+"</TotalClickPrc>\n";
        Result+="<TotalTextPrc>"+rs.getString("TotalTextPrc")+"</TotalTextPrc>\n";
        Result+="<TotalHTMLPrc>"+rs.getString("TotalHTMLPrc")+"</TotalHTMLPrc>\n";
        Result+="<TotalAOLPrc>"+rs.getString("TotalAOLPrc")+"</TotalAOLPrc>\n";

        Result+="<DistinctClickPrc>"+rs.getString("DistinctClickPrc")+"</DistinctClickPrc>\n";
        Result+="<DistinctTextPrc>"+rs.getString("DistinctTextPrc")+"</DistinctTextPrc>\n";
        Result+="<DistinctHTMLPrc>"+rs.getString("DistinctHTMLPrc")+"</DistinctHTMLPrc>\n";
        Result+="<DistinctAOLPrc>"+rs.getString("DistinctAOLPrc")+"</DistinctAOLPrc>\n";

        Result += "<StyleClass>"+sClassAppend+"</StyleClass>\n";
        Result += "</Links>\n";
      }
      rs.close();

      // ********* KU
      iCount = 0;
      sClassAppend = "_other";

// Fields description for (forms) stored procedure:
//
// <CampID>           - Campaign ID
// <FirstFormID>      - Form ID for the form
// <LastFormID>       - Href ID for the form
// <FirstFormName>    - Name of the form
// <LastFormName>     - Name of the form
// <TotalViews>       - Total Number of views on first form
// <TotalSubmits>     - Total Number of complete submits on form
// <TotalViewSubmitPrc>   - % submits of views = (<TotalSubmits> / <TotalViews>) * 100
// <DistinctViews>    - Number of Distinct views on first form
// <DistinctSubmits>  - Number of Distinct complete submits on form
// <DistinctViewSubmitPrc> - % submits of views = (<DistinctSubmits> / <DistinctViews>) * 100
// <MultiSubmitters>  - Number of recipients who submitted form multiple times


      rs=stmt.executeQuery("Exec usp_crpt_camp_forms @camp_id="+sCampID+", @cache_id="+sCacheID+", @cache="+sCache);
      while( rs.next() )
      {
        // ********* KU
        if (iCount % 2 != 0)
        {
          sClassAppend = "_other";
        }
        else
        {
          sClassAppend = "";
        }

        iCount++;

        Result+="<Forms>\n";
        Result+="<CampID>"+sCampID+"</CampID>\n";
        Result+="<FirstFormID>"+rs.getString("FirstFormID")+"</FirstFormID>\n";
        Result+="<LastFormID>"+rs.getString("LastFormID")+"</LastFormID>\n";
        bVal = rs.getBytes("FirstFormName");
        Result+="<FirstFormName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></FirstFormName>\n";
        bVal = rs.getBytes("LastFormName");
        Result+="<LastFormName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></LastFormName>\n";
        Result+="<TotalViews>"+rs.getString("TotalViews")+"</TotalViews>\n";
        Result+="<TotalSubmits>"+rs.getString("TotalSubmits")+"</TotalSubmits>\n";
        Result+="<DistinctViews>"+rs.getString("DistinctViews")+"</DistinctViews>\n";
        Result+="<DistinctSubmits>"+rs.getString("DistinctSubmits")+"</DistinctSubmits>\n";
        Result+="<MultiSubmitters>"+rs.getString("MultiSubmitters")+"</MultiSubmitters>\n";

        Result+="<TotalViewSubmitPrc>"+rs.getString("TotalViewSubmitPrc")+"</TotalViewSubmitPrc>\n";
        Result+="<DistinctViewSubmitPrc>"+rs.getString("DistinctViewSubmitPrc")+"</DistinctViewSubmitPrc>\n";

        Result += "<StyleClass>"+sClassAppend+"</StyleClass>\n";
        Result += "</Forms>\n";
      }
      rs.close();

      // ********* KU
      iCount = 0;
      sClassAppend = "_other";

// Fields description for (bbacks) stored procedure:
//
// <CampID>           - Campaign ID
// <CategoryID>       - Bounce Back Category ID
// <CategoryName>     - Bounce Back Category
// <BBacks>           - Number of Bounce Backs

      rs=stmt.executeQuery("Exec usp_crpt_camp_bbacks @camp_id="+sCampID+", @cache_id="+sCacheID+", @cache="+sCache);
      while( rs.next() )
      {
        // ********* KU
        if (iCount % 2 != 0)
        {
          sClassAppend = "_other";
        }
        else
        {
          sClassAppend = "";
        }

        iCount++;

        Result+="<BounceBacks>\n";
        Result+="<CampID>"+sCampID+"</CampID>\n";
        Result+="<CategoryID>"+rs.getString("CategoryID")+"</CategoryID>\n";
        bVal = rs.getBytes("CategoryName");
        Result+="<CategoryName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></CategoryName>\n";
        Result+="<BBacks>"+rs.getString("BBacks")+"</BBacks>\n";
        Result+="<BBackPrc>"+rs.getString("BBackPrc")+"</BBackPrc>\n";

        Result += "<StyleClass>"+sClassAppend+"</StyleClass>\n";
        Result += "</BounceBacks>\n";
      }
      rs.close();

      // ********* KU
      iCount = 0;
      sClassAppend = "_other";

// Fields description for (unsubs) stored procedure:
//
// <CampID>           - Campaign ID
// <LevelID>       	- Unsubscribe Level ID
// <Unsubs>           - Number of Unsubscribes

      rs=stmt.executeQuery("Exec usp_crpt_camp_unsubs @camp_id="+sCampID+", @cache_id="+sCacheID+", @cache="+sCache);

      while( rs.next() )
      {
        // ********* KU
        if (iCount % 2 != 0)
        {
          sClassAppend = "_other";
        }
        else
        {
          sClassAppend = "";
        }

        iCount++;

        Result+="<Unsub>\n";
        Result+="<CampID>"+sCampID+"</CampID>\n";
        String levelId = rs.getString("LevelID");
        System.out.println("Level:"+ levelId);
        Result+="<LevelID>"+levelId+"</LevelID>\n";
        String levelName = rs.getString("LevelName");
        Result+="<LevelName>"+levelName+"</LevelName>\n";
        Result+="<Unsubs>"+rs.getString("Unsubs")+"</Unsubs>\n";
        Result+="<UnsubsPrc>"+rs.getString("UnsubsPrc")+"</UnsubsPrc>\n";
        Result += "<StyleClass>"+sClassAppend+"</StyleClass>\n";
        Result += "</Unsub>\n";
      }
      rs.close();

      // ********* KU
      iCount = 0;
      sClassAppend = "_other";

// Fields description for (domains) stored procedure:
//
// <CampID>           - Campaign ID
// <Domain>       - Bounce Back Category ID
// <Sent>     - Bounce Back Category
// <BBacks>           - Number of Bounce Backs
// added for release 5.9 , Domain Deliverability
// <Reads>	 - Number of Reads
// <Clicks>  - Number of clicks
// <Unsubs>  - Number of unsubscribes
// added for release 6.1, spam complaints
// <UnsubsSpam>     - Number of spam complaints
// <UnsubsSpamPrc>     - Number of spam complaints


      rs=stmt.executeQuery("Exec usp_crpt_camp_domains @camp_id="+sCampID+", @cache_id="+sCacheID+", @cache="+sCache);

      while( rs.next() )
      {
        // ********* KU
        if (iCount % 2 != 0)
        {
          sClassAppend = "_other";
        }
        else
        {
          sClassAppend = "";
        }

        iCount++;

        Result+="<Domains>\n";
        Result+="<CampID>"+sCampID+"</CampID>\n";
        bVal = rs.getBytes("Domain");
        Result+="<Domain><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></Domain>\n";
        Result+="<Sent>"+rs.getString("Sent")+"</Sent>\n";
        Result+="<BBacks>"+rs.getString("BBacks")+"</BBacks>\n";
        Result+="<BBackPrc>"+rs.getString("BBackPrc")+"</BBackPrc>\n";

        // Added for release 5.9 changes, Domain Deliverability
        sVal = rs.getString("Reads");
        if (sVal==null) sVal = "0";
        Result+="<Reads>"+ sVal +"</Reads>\n";

        sVal = rs.getString("ReadPrc");
        if (sVal==null) sVal = "0";
        Result+="<ReadPrc>"+ sVal +"</ReadPrc>\n";

        sVal = rs.getString("Clicks");
        if (sVal==null) sVal = "0";
        Result+="<Clicks>"+ sVal +"</Clicks>\n";

        sVal = rs.getString("ClickPrc");
        if (sVal==null) sVal = "0";
        Result+="<ClickPrc>"+ sVal +"</ClickPrc>\n";

        sVal = rs.getString("Unsubs");
        if (sVal==null) sVal = "0";
        Result+="<Unsubs>"+ sVal +"</Unsubs>\n";

        sVal = rs.getString("UnsubPrc");
        if (sVal==null) sVal = "0";
        Result+="<UnsubPrc>"+ sVal +"</UnsubPrc>\n";
        // End for release 5.9 changes, Domain Deliverability

        // Added for release 6.1 changes, Spam Complaints

        sVal = rs.getString("Spam");
        if (sVal==null) sVal = "0";
        Result+="<UnsubsSpam>"+ sVal +"</UnsubsSpam>\n";


        sVal = rs.getString("SpamPrc");
        if (sVal==null) sVal = "0";
        Result+="<UnsubsSpamPrc>"+ sVal +"</UnsubsSpamPrc>\n";

        // End for release 6.1 changes, Spam complaints

        Result += "<StyleClass>"+sClassAppend+"</StyleClass>\n";
        Result += "</Domains>\n";
      }
      rs.close();

      // ********* KU
      iCount = 0;
      sClassAppend = "_other";

// Fields description for (optouts) stored procedure:
//
// <CampID>           - Campaign ID
// <AttrID>           - Newsletter Attr ID
// <AttrName>         - Newsletter Attr
// <Optouts>          - Number of Opt-outs

      rs=stmt.executeQuery("Exec usp_crpt_camp_optouts @camp_id="+sCampID+", @cache_id="+sCacheID+", @cache="+sCache);
      while( rs.next() )
      {
        // ********* KU
        if (iCount % 2 != 0)
        {
          sClassAppend = "_other";
        }
        else
        {
          sClassAppend = "";
        }

        iCount++;

        Result+="<Optouts>\n";
        Result+="<CampID>"+sCampID+"</CampID>\n";
        Result+="<AttrID>"+rs.getString("AttrID")+"</AttrID>\n";
        bVal = rs.getBytes("AttrName");
        Result+="<AttrName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></AttrName>\n";
        Result+="<Optouts>"+rs.getString("Optouts")+"</Optouts>\n";
        Result+="<OptoutPrc>"+rs.getString("OptoutPrc")+"</OptoutPrc>\n";

        Result += "<StyleClass>"+sClassAppend+"</StyleClass>\n";
        Result += "</Optouts>\n";
      }
      rs.close();

      // ********* KU
      iCount = 0;
      sClassAppend = "_other";
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
