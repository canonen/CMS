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
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
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
String unsubID="",unsubPosition="",textFlag="",htmlFlag="",aolFlag="";

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

JsonObject data=null;
JsonObject data2=null;
JsonObject data3=null;
JsonObject data4=null;
JsonObject data5=null;
JsonObject data6=null;
JsonObject data7=null;
JsonObject data8=null;
JsonArray array = new JsonArray();
try
{
     cp = ConnectionPool.getInstance();
     conn = cp.getConnection("cont_load_manual.jsp");
     stmt = conn.createStatement();

     //Unsubscribes
     unsubID = "-1";
     unsubPosition = "1";
     String tmpUnsubID = "";
		
     sSql = 
          " SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
          " FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
							   
     rs = stmt.executeQuery(sSql);
     while (rs.next())
     {
          tmpUnsubID = rs.getString(1);
          if (unsubID.equals(tmpUnsubID))
          {
               htmlUnsubs += "<option selected value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";

               data = new JsonObject();
               data.put("htmlUnsubs",htmlUnsubs);
          }
          else
          {
               htmlUnsubs += "<option value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";

               data2 = new JsonObject();
               data2.put("htmlUnsubs",htmlUnsubs);

          }
			
          htmlUnsubContent +=
               "<textarea style=display:none name=UnsubContentHTML"+tmpUnsubID+">"+
               new String(rs.getBytes(3),"UTF-8")+"</textarea>\n";

			data3 = new JsonObject();
            data3.put("htmlUnsubContent",htmlUnsubContent);	

          textUnsubContent +=
               "<textarea style=display:none name=UnsubContentText"+tmpUnsubID+">"+
               new String(rs.getBytes(4),"UTF-8")+"</textarea>\n";

			data4 = new JsonObject();
            data4.put("textUnsubContent",textUnsubContent);	

          aolUnsubContent +=
               "<textarea style=display:none name=UnsubContentAOL"+tmpUnsubID+">"+
               new String(rs.getBytes(5),"UTF-8")+"</textarea>\n";
            
            data5 = new JsonObject();
            data5.put("aolUnsubContent",aolUnsubContent);	

          jsUnsubs += "if (document.all.unsubID.value == "+tmpUnsubID+") {\n" +
                         "	if (act=='1') unTxt = document.all.UnsubContentText"+tmpUnsubID+".value;\n" +
                         "	if (act=='2') unTxt = document.all.UnsubContentHTML"+tmpUnsubID+".value;\n" +
                         "	if (act=='3') unTxt = document.all.UnsubContentAOL"+tmpUnsubID+".value;\n" +
                         "}\n";

            data6 = new JsonObject();
            data6.put("jsUnsubs",jsUnsubs);	             
     }
     rs.close();

     //Charsets
     String tmpCharsetID = "";
     rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
     while (rs.next())
     {
          tmpCharsetID = rs.getString(1);			
          if (sendType.equals(tmpCharsetID))
            {
                htmlCharsets += "<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";

                data7 = new JsonObject();
                data7.put("htmlCharsets",htmlCharsets);	

            }
          else
            {
                htmlCharsets += "<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
                data8 = new JsonObject();
                data8.put("htmlCharsets",htmlCharsets);	 

            }
              			
     }
     rs.close();

     array.put(data);
     array.put(data2);
     array.put(data3);
     array.put(data4);
     array.put(data5);
     array.put(data6);
     array.put(data7);
     array.put(data8);
     

} catch(Exception ex) { 

	ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);

} finally {
	if ( stmt != null ) stmt.close ();	
	if ( conn != null ) cp.free(conn);


    out.print(array);
}

%>