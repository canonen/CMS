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

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

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
JsonObject data=new JsonObject();
JsonArray array=new JsonArray();
JsonObject data2=new JsonObject();
JsonArray array2= new JsonArray();
JsonArray finalArray= new JsonArray();
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
		  data=new JsonObject();
          tmpUnsubID = rs.getString(1);
		  data.put("tmpUnsubID",tmpUnsubID);
          if (unsubID.equals(tmpUnsubID))
          {
               htmlUnsubs += tmpUnsubID+new String(rs.getBytes(2),"UTF-8");
			   data.put("htmlUnsubs",htmlUnsubs);
          }
          else
          {
				htmlUnsubs +=tmpUnsubID+new String(rs.getBytes(2),"UTF-8");
				data.put("htmlUnsubs",htmlUnsubs);
          }		
				htmlUnsubContent +=tmpUnsubID+ new String(rs.getBytes(3),"UTF-8");
				data.put("htmlUnsubContent",htmlUnsubContent);	

               textUnsubContent +=tmpUnsubID+ new String(rs.getBytes(4),"UTF-8");
			   data.put("textUnsubContent",textUnsubContent);

			   aolUnsubContent += tmpUnsubID+new String(rs.getBytes(5),"UTF-8");
			   data.put("aolUnsubContent",aolUnsubContent);

            
				/*jsUnsubs +="if (document.all.unsubID.value == "+tmpUnsubID+") {\n" +
								"	if (act=='1') unTxt = document.all.UnsubContentText"+tmpUnsubID+".value;\n" +
								"	if (act=='2') unTxt = document.all.UnsubContentHTML"+tmpUnsubID+".value;\n" +
								"	if (act=='3') unTxt = document.all.UnsubContentAOL"+tmpUnsubID+".value;\n" +
								"}\n";
                */
				array.put(data);
     }
     rs.close();
     //Charsets
     String tmpCharsetID = "";
     rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
     while (rs.next())
     {
		  data2 = new JsonObject();
          tmpCharsetID = rs.getString(1);
		  data2.put("tmpCharsetID",tmpCharsetID);			
			if (sendType.equals(tmpCharsetID))
			{
				htmlCharsets += tmpCharsetID+rs.getString(2);
				data2.put("htmlCharsets",htmlCharsets);
			}
			else{
				htmlCharsets +=tmpCharsetID+rs.getString(2);
				data2.put("htmlCharsets",htmlCharsets);			
				}
		array2.put(data2);		
	 }       
     rs.close();
	 finalArray.put(array);
	 finalArray.put(array2);
}
	catch(Exception ex)
	{ 
		//ErrLog.put(this,ex, "Exception thrown while attempting to upload content.",out,1);
	}
	finally
	{
		if ( stmt != null ) stmt.close ();	
		if ( conn != null ) cp.free(conn);
		out.print(finalArray);
	}
%>


























