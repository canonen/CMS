<%@ page
	language="java"
	import="com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.adm.*,
		com.britemoon.*,
		java.util.*,java.sql.*,
		java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {	
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    if(!can.bRead)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
    String sSelectedCategoryId = request.getParameter("category_id"); // data.put("categories")
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
    {
        sSelectedCategoryId = ui.s_category_id;
    }
    String sErrors = BriteRequest.getParameter(request,"errors");
    boolean bCanExecute = can.bExecute;
    boolean bCanWrite = (can.bWrite || bCanExecute);
    boolean bCanImageWrite = false;
    // featureid 110 = image library
    if (CustFeature.exists(cust.s_cust_id,110)) {
        bCanImageWrite = true;
    }

    //UI Type
    boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

    Image image = null;
    String htmlCategories = CategortiesControl.toHtmlOptions(cust.s_cust_id, sSelectedCategoryId); 
    //String subStringhtmlCategories=htmlCategories.substring(20,24);
    String contStatus="",sendType="",contHTML="",contText="";
    String unsubID="",textFlag="",htmlFlag="",aolFlag="";
    String htmlTracking = "";
    String htmlPersonals = "";
    String htmlStatuses = "";
    String htmlCharsets = "";
    String htmlCurPers = "";
    String jsPersonals = "";
    String jsSubmitPers = "";
    String htmlLogicBlocks = "";
    String htmlUnsubs = "";
    String htmlUnsubContent = "";
    String textUnsubContent = "";
    String aolUnsubContent = "";
    String jsUnsubs = "";

    ConnectionPool cp	= null;
    Connection conn		= null;
    Statement stmt		= null;
    ResultSet rs		= null;

    String sSql = null;
    byte[] b = null;

    JsonObject generalInfo= new JsonObject();
    JsonArray generalInfoArray= new JsonArray(); 

    JsonObject contentInfo= new JsonObject();
    JsonArray contentInfoArray= new JsonArray();

    JsonObject positionUnsubMessage= new JsonObject();
    //JsonObject positionUnsubMessage2= new JsonObject();
    //JsonObject positionUnsubMessage3= new JsonObject();
    JsonArray positionUnsubMessageArray= new JsonArray();

    JsonObject unSubMessage= new JsonObject();
    JsonArray unSubMessageArray= new JsonArray();

    JsonObject selectFiles= new JsonObject();
    JsonArray selectFilesArray= new JsonArray();

    JsonObject selectlinkScanOptions= new JsonObject();
    JsonArray  selectlinkScanOptionsArray= new JsonArray();

    JsonArray totalContentArray= new JsonArray();
    
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

     // dosyalarin load edildigi kisim
		/*var tImageTable = document.getElementById("imageFileTable");
          var sContentName = "";  sContentName = FT.contentName.value;
          var fTextFile = ""; fTextFile = FT.cont_text_file.value;
          var fHtmlFile = ""; fHtmlFile = FT.cont_html_file.value;
          var fImageFile = ""; fImageFile = FT.cont_image_file.value;
          */
    try
    {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        //Unsubscribes
        unsubID = "-1"; // UnsubScribe Message data.put()

         // data.put bottom    // data.put Top and Bottom -1 i?in  // data.put Top 0 i?in
        String tmpUnsubID = "";
        /*
        if(unsubID =="-1")
        {
            unSubMessage.put("UnsubscribeMessage","Unsubscribe Message");
           
        }
         unSubMessageArray.put(unSubMessage);
        */
        for(int unsubPosition=-1; unsubPosition<2;unsubPosition++)
        {
            positionUnsubMessage = new JsonObject();
            if(unsubPosition==-1)
            {
            positionUnsubMessage.put("id",-1);
            positionUnsubMessage.put("PositionOfUnsubscribeMessage","Top and Bottom");
            }
            else if(unsubPosition==0)
            {
                positionUnsubMessage.put("id",0);
                positionUnsubMessage.put("PositionOfUnsubscribeMessage","Top");
            }

            else if (unsubPosition==1)
            {
                positionUnsubMessage.put("id",1);
                positionUnsubMessage.put("PositionOfUnsubscribeMessage","bottom");
            }
            positionUnsubMessageArray.put(positionUnsubMessage);
        }
        jsonObject.put("positionUnsubMessageArray",positionUnsubMessageArray);
        generalInfo.put("CategoryId",htmlCategories);
        generalInfoArray.put(generalInfo);
        
        jsonObject.put("generalInfoArray",generalInfoArray);
        
        sSql = 
            " SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
            " FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
                                
        rs = stmt.executeQuery(sSql);
        while (rs.next())
        {
			selectFiles = new JsonObject();
            tmpUnsubID = rs.getString(1);
            if (unsubID.equals(tmpUnsubID))
            {
               // htmlUnsubs =tmpUnsubID +new String(rs.getBytes(2),"UTF-8")";
               // selectFiles.put("selectHtmlFile",htmlUnsubs);
               selectFiles.put("htmlUnsubs",new String(rs.getBytes(2),"UTF-8"));
				selectFiles.put("id",tmpUnsubID);
            }
            else
            {
                //htmlUnsubs =tmpUnsubID+new String(rs.getBytes(2),"UTF-8");
                selectFiles.put("id",tmpUnsubID);
                selectFiles.put("htmlUnsubs",new String(rs.getBytes(2),"UTF-8"));		
            }
                
              //  "<textarea style=display:none name=UnsubContentHTML"+tmpUnsubID+">"+
              selectFiles.put("id",tmpUnsubID);
              selectFiles.put("UnsubContentHTML",new String(rs.getBytes(3),"UTF-8"));
               // new String(rs.getBytes(3),"UTF-8")+"</textarea>\n";
                    
            //textUnsubContent =  tmpUnsubID+ new String(rs.getBytes(4),"UTF-8");
            selectFiles.put("id",tmpUnsubID);
            selectFiles.put("textUnsubContent",new String(rs.getBytes(4),"UTF-8"));
            
                
                    
          //  aolUnsubContent +=
            //    "<textarea style=display:none name=UnsubContentAOL"+tmpUnsubID+">"+
            //    new String(rs.getBytes(5),"UTF-8")+"</textarea>\n";
            selectFiles.put("id",tmpUnsubID);
            selectFiles.put("aolUnsubContent",new String(rs.getBytes(5),"UTF-8"));
            selectFilesArray.put(selectFiles);    
        }
        jsonObject.put("selectFilesArray", selectFilesArray);
        rs.close();

        //Charsets
        String tmpCharsetID = "";
        rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
        while (rs.next())
        {   
            contentInfo = new JsonObject();
            tmpCharsetID = rs.getString(1);			
            if (sendType.equals(tmpCharsetID))
            {
                    //htmlCharsets =tmpCharsetID+">"+rs.getString(2);
                    contentInfo.put("id",tmpCharsetID);
                    contentInfo.put("sendType",rs.getString(2));
            }
            else
            {
                //htmlCharsets =tmpCharsetID+rs.getString(2);
                contentInfo.put("id",tmpCharsetID);
                contentInfo.put("sendType",rs.getString(2));		
            }
        contentInfoArray.put(contentInfo);
        }
        jsonObject.put("contentInfoArray", contentInfoArray);
        rs.close();
         /* Auto Scan For Links olan kisim 4 madde var 1 2 3 ve 4 
   //var dDiv1 = document.getElementById("linkTrackingOptions1");
     var dDiv2 = document.getElementById("linkTrackingOptions2");
     var dDiv3 = document.getElementById("linkTrackingOptions3");
     */
      boolean linkTrackingOptions = true;

        selectlinkScanOptions.put("linkTrackingOptions1",linkTrackingOptions);
        selectlinkScanOptions.put("linkTrackingOptions2",linkTrackingOptions);
        selectlinkScanOptions.put("linkTrackingOptions3",linkTrackingOptions);
        selectlinkScanOptions.put("linkTrackingOptions4",linkTrackingOptions);

        selectlinkScanOptionsArray.put(selectlinkScanOptions);
        jsonObject.put("selectlinkScanOptionsArray", selectlinkScanOptionsArray);

        jsonArray.put(jsonObject);

       out.print(jsonArray);
    }

    catch(Exception ex) { 

        ErrLog.put(this,ex, "Exception thrown while attempting to upload content.",out,1);

    } finally {
        if ( stmt != null ) stmt.close ();	
        if ( conn != null ) cp.free(conn);
    }
%>