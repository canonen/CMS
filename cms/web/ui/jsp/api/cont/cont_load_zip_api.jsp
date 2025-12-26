<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		java.sql.*,java.io.*,
		java.util.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp" %>
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

	//Is it the standard ui?
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	String contID = request.getParameter("cont_id"); 
	if (!can.bWrite && contID == null)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;


String sErrors = BriteRequest.getParameter(request,"errors");

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

// Connection
Image image = null;

String htmlCategories = CategortiesControl.toHtmlOptions(cust.s_cust_id, sSelectedCategoryId);

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
JsonObject unsubObj= new JsonObject();
JsonArray unsubObjArray= new JsonArray();
JsonObject contentInfo= new JsonObject();
JsonArray contentInfoArray= new JsonArray();
JsonObject unSubMessage= new JsonObject();
JsonArray unSubMessageArray= new JsonArray();
JsonObject positionUnsubMessage= new JsonObject();
JsonArray positionUnsubMessageArray= new JsonArray();
JsonObject selectlinkScanOptions= new JsonObject();
JsonArray  selectlinkScanOptionsArray= new JsonArray();
JsonArray totalContentArray= new JsonArray();
JsonObject jsonObject= new JsonObject();
JsonArray jsonArray = new JsonArray();
try
{
     cp = ConnectionPool.getInstance();
     conn = cp.getConnection(this);
     stmt = conn.createStatement();

     //Unsubscribes
     unsubID = "-1";
     
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
        generalInfo.put("CategoryId",htmlCategories);
        generalInfoArray.put(generalInfo);

		
     sSql = 
          " SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
          " FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
							   
     rs = stmt.executeQuery(sSql);

     while (rs.next())
     {
         unsubObj = new JsonObject();
        tmpUnsubID = rs.getString(1);
        if (unsubID.equals(tmpUnsubID))
        {
               //htmlUnsubs += "<option selected value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
            unsubObj.put("id",tmpUnsubID);
            unsubObj.put("htmlUnsubs",new String(rs.getBytes(2),"UTF-8"));
        }
        else
        {
               //htmlUnsubs += "<option value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
            unsubObj.put("id",tmpUnsubID);
            unsubObj.put("htmlUnsubs",new String(rs.getBytes(2),"UTF-8"));
        }
			
        //  htmlUnsubContent +=
          //     "<textarea style=display:none name=UnsubContentHTML"+tmpUnsubID+">"+
           //    new String(rs.getBytes(3),"UTF-8")+"</textarea>\n";

         unsubObj.put("id",tmpUnsubID);
         unsubObj.put("htmlUnsubContent",new String(rs.getBytes(3),"UTF-8"));
				
          //textUnsubContent +=
          //     "<textarea style=display:none name=UnsubContentText"+tmpUnsubID+">"+
          //     new String(rs.getBytes(4),"UTF-8")+"</textarea>\n";
               unsubObj.put("id",tmpUnsubID);
               unsubObj.put("textUnsubContent",  new String(rs.getBytes(4),"UTF-8"));
				
          aolUnsubContent +=
               "<textarea style=display:none name=UnsubContentAOL"+tmpUnsubID+">"+
               new String(rs.getBytes(5),"UTF-8")+"</textarea>\n";
            unsubObj.put("id",tmpUnsubID);
            unsubObj.put("aolUnsubContent",new String(rs.getBytes(5),"UTF-8"));   

        /*  jsUnsubs += "if (document.all.unsubID.value == "+tmpUnsubID+") {\n" +
            "	if (act=='1') unTxt = document.all.UnsubContentText"+tmpUnsubID+".value;\n" +
            "	if (act=='2') unTxt = document.all.UnsubContentHTML"+tmpUnsubID+".value;\n" +
            "	if (act=='3') unTxt = document.all.UnsubContentAOL"+tmpUnsubID+".value;\n" +
            "}\n";
        */
        unsubObjArray.put(unsubObj);
     }
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
            //  htmlCharsets += "<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
              contentInfo.put("id",tmpCharsetID);
              contentInfo.put("htmlCharsets",rs.getString(2));
        }             
        else
        {
            //htmlCharsets += "<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
            contentInfo.put("id",tmpCharsetID);
            contentInfo.put("htmlCharsets",rs.getString(2));		
        }
        contentInfoArray.put(contentInfo);		
     }
     rs.close();
     
    boolean linkTrackingOptions = true;

    selectlinkScanOptions.put("linkTrackingOptions1",linkTrackingOptions);
    selectlinkScanOptions.put("linkTrackingOptions2",linkTrackingOptions);
    selectlinkScanOptions.put("linkTrackingOptions3",linkTrackingOptions);
    selectlinkScanOptions.put("linkTrackingOptions4",linkTrackingOptions);

    selectlinkScanOptionsArray.put(selectlinkScanOptions);

    jsonObject.put("generalInfoArray",generalInfoArray);
    jsonObject.put("contentInfoArray",contentInfoArray);
    //totalContentArray.put(unSubMessageArray);
    jsonObject.put("positionUnsubMessageArray",positionUnsubMessageArray);
    jsonObject.put("selectlinkScanOptionsArray",selectlinkScanOptionsArray);
    jsonObject.put("unsubObjArray",unsubObjArray);

    jsonArray.put(jsonObject);
    out.print(jsonArray);

} catch(Exception ex) { 

	ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);

} finally {
	if ( stmt != null ) stmt.close ();	
	if ( conn != null ) cp.free(conn);
}

%>
