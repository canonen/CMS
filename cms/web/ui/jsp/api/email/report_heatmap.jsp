<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.rpt.*,
			java.sql.*,java.net.*,java.io.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../header.jsp"%>
<%@ include file="validator.jsp"%>
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

String	sCampID	= request.getParameter("Q");
String	sCache 	= request.getParameter("Z");
sCache = ("1".equals(sCache))?sCache:"0";

ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null;
	JsonArray array= new JsonArray();
	JsonObject data = new JsonObject();

boolean DURUM=false;
String ContentHTML="";
String Error="";
	 %>
<%
StringBuilder RETURN_Table = new StringBuilder();
	String reportName = "";
	String SubjectLine = "";
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	int nPos = 0;

	String reportDate = "";
	int numRecs = 0;

	JsonArray array1 = new JsonArray();

	//Customize deliveryTracker report Feature (part of release 5.9)
	int showTrackerRpt = 0;
	boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);

	if (bFeat)
	{
 		int nCount = getSeedListCount(stmt,cust.s_cust_id, sCampID);
		if (nCount > 0)
			showTrackerRpt = 1;
	}
	// end release 5.9
	JsonArray array2 = new JsonArray();
	if ((sCampID != null))
	{
		String sSql =
			" SELECT count(camp_id)" +
			" FROM cque_campaign c with(nolock)" +
			" WHERE c.cust_id = " + cust.s_cust_id +
			" AND c.camp_id = " + sCampID;

		rs = stmt.executeQuery(sSql);
		if(rs.next()) {
			data = new JsonObject();
			numRecs = rs.getInt(1);
			data.put("numRecs",numRecs);
			array2.put(data);
		}
		rs.close();





		sSql =
			" EXEC usp_crpt_camp_list" +
			"  @camp_id="+sCampID+
			", @cust_id="+cust.s_cust_id+
			", @cache=0";

		rs = stmt.executeQuery(sSql);

		while( rs.next() )
		{
			data = new JsonObject();
			byte[] bVal = rs.getBytes("CampName");
			reportName = (bVal!=null?new String(bVal,"UTF-8"):"");

			byte[] bVal2 = rs.getBytes("SubjectLine");
			SubjectLine = (bVal2!=null?new String(bVal2,"UTF-8"):"");

			reportDate = rs.getString("StartDate");
			data.put("reportName",reportName);
			data.put("SubjectLine",SubjectLine);
			data.put("reportDate",reportDate);
			array1.put(data);
		}

		rs.close();
	}






			String sSqlSinan ="";
			String Cont_ID="";
			int Link_ID=0;
			int Tot_Html_Clicks=0;
			String Link_Name ="";
			String Href ="";
			int  Toplam_Link_Sayisi=0;
			int  Toplam_Click_Sayisi=0;
			int  Ortalama=0;

            JsonArray array3 = new JsonArray();
            JsonObject obj3 = new JsonObject();

				sSqlSinan =
				"select   l.cont_id as Cont_ID, c.tot_html_clicks as Tot_Html_Clicks, l.href as Href,"+
			 	"(select count(*) from crpt_camp_link where camp_id="+ sCampID +" and tot_html_clicks!=0) Count1,"+
				"(select SUM(tot_html_clicks) from crpt_camp_link where   camp_id="+sCampID+"  and  tot_html_clicks!=0) Count2 "+
				"from crpt_camp_link c , cjtk_link l "+
			 	"where c.link_id=l.link_id and c.camp_id="+sCampID+" and c.tot_html_clicks!=0";


					rs = stmt.executeQuery(sSqlSinan);

					RETURN_Table.append("<table style='display:none'  width=100% class=listTable   id=sinan cellspacing=0 cellpadding=0>");
					while (rs.next()) {
						data = new JsonObject();
						Cont_ID = rs.getString(1);
                        Content cont = new Content();
                          cont.s_cont_id = Cont_ID;

                              					ContBody cont_body = new ContBody(Cont_ID);

                              					String htmlPart = cont_body.s_html_part;

                              					if(htmlPart == null) htmlPart = " ";


                              					ContentHTML=htmlPart;

						 data.put("cont_id",Cont_ID);
						 data.put("Tot_Html_Clicks",rs.getInt("Tot_Html_Clicks"));
						 data.put("Href",rs.getString("Href"));
						 data.put("Count1",rs.getInt("Count1"));
						 data.put("Count2",rs.getInt("Count2"));
						 array3.put(data);

					}

                    obj3.put("totalData",array3);

					rs.close();

			if (Cont_ID == null)
			{
				DURUM=true;
				Error="Enter formula values above and then select preview type.";

			}
    String html="\n" +
    			" \n" +
    			"\n" +
    			" <!DOCTYPE html>\n" +
    			"<html>\n" +
    			"<head>\n" +
    			"  <meta charset=\"utf-8\">\n" +
    			"  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n" +
    			"  <title> Report HeatMap</title> \n" +
    			"  <meta content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no\" name=\"viewport\">\n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/bootstrap.min.css\">\n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/font-awesome.min.css\">\n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/ionicons.min.css\">\n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/AdminLTE.css\">\n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/Style.css\">\n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/skin-blue.min.css\">\n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/DataTable/dataTables.bootstrap.min.css\"> \n" +
    			"  <link rel=\"stylesheet\" href=\"assets/css/daterangepicker/daterangepicker.css\">\n" +
    			"  <!--[if lt IE 9]>\n" +
    			"  <script src=\"https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js\"></script>\n" +
    			"  <script src=\"https://oss.maxcdn.com/respond/1.4.2/respond.min.js\"></script>\n" +
    			"  <![endif]-->\n" +
    			" \t \n" +
    			"  <link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic\">\n" +
    			"   \n" +
    			"</head>\n" +
    			"\n" +
    			"<body class=\"hold-transition\" style=\"background-color:none !important;\"  >\n" +
    			" \n" +
    			" if (DURUM) {\t\t \n" +
    			"\t\t\n" +
    			"\t<div class=\"wrapper\" style=\"margin-left:20px;margin-right:20px;\">\n" +
    			"\t\t\t<div class=\"row\">\n" +
    			"\t\t\t\t\t<div class=\"col-md-4\" ></div>\t\t\t\n" +
    			"\t\t\t\t\t<div class=\"col-md-4\" >\n" +
    			" \t\t\t\t\t\t\t<div align=\"center\" class=\"alert alert-warning alert-dismissible\">\n" +
    			"\t\t\t\t\t \t\t\t<h4 ><i class=\"icon fa fa-warning\"></i> Warning!</h4>\n" +
    			"\t\t\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t\t</div>\n" +
    			" \t \t\t\t\t</div>\n" +
    			"\t\t\t\t\t<div class=\"col-md-4\" ></div>\n" +
    			"\t\t\t</div>\n" +
    			"\t\t</div>\n" +
    			"\t } else { \n" +
    			" \n" +
    			" \n" +
    			" <section class=\"content\">\n" +
    			"<div class=\"row\">\n" +"\t"+

    			"<div class=\"col-md-12\">\n" +
    			"<div class=\"box box-primary\">\n" +
    			"\t\t\t\t\t\t\t"+
    			"<div class=\"box-header with-border\""+
    			">\n" +
    			"\t\t\t\t\t\t\t\t<h3 class=\"box-title\">HeatMap</h3>\n" +
    			"\t\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t\t"+
    			"</div>"+
    			"\n" +
    			"\t\t\t\t\t\t\t \n" +
    			"\t\t\t\t\t\t\t"+
    			"<div class=\"box-body\" style=\"font-family:"+
    			"'Source Sans Pro', sans-serif !important;font-weight: 400 !important;\">\n" +
    			"\t\t\t\t\t\t\t \n" +
    			"\t\t\t\t\t\t\t\t"+
    			"<table>\n" +
    			"\t\t\t\t\t\t\t\t\t \n" +
    			"\t\t\t\t\t\t\t\t\t"+
    			"<tr>\n" +
    			"\t\t\t\t\t\t\t\t\t\t"+
    			"<td>Campaign Name</td>"+
    			"\n" +
    			"\t\t\t\t\t\t\t\t\t\t"+
    			"<td>:<b>"+
    			"</b></td>"+
    			"\n" +
    			"\t\t\t\t\t\t\t\t\t"+
    			"</tr>"+
    			"\n" +
    			"\t\t\t\t\t\t\t\t\t"+
    			"<tr>\n" +
    			"\t\t\t\t\t\t\t\t\t\t"+
    			"<td>Subject Name</td>"+
    			"\n" +
    			"\t\t\t\t\t\t\t\t\t\t"+
    			"<td>:<b>"+
    			"</b></td>"+
    			"\n" +
    			"\t\t\t\t\t\t\t\t\t\t \n" +
    			"\t\t\t\t\t\t\t\t\t"+
    			"</tr>"+
    			"\n" +
    			"\t\t\t\t\t\t\t\t \t\n" +
    			"\t\t\t\t\t\t\t\t"+
    			"</table>"+
    			"\n" +
    			"\t\t\t\t\t\t\t"+
    			"</div>"+
    			"\n" +
    			"                </div><!-- /.box box-primary -->\n" +
    			"\t\t </div><!-- /.col-md-12 End -->\n" +
    			"\t\t \n" +
    			" <div class=\"col-md-12\">\n" +
    			"\t\t\t"+
    			"<div class=\"box box-primary\""+
    			">\n" +
    			"\t\t\t\t\t\t\t"+
    			"<div class=\"box-header with-border\""+
    			">\n" +
    			"\t\t\t\t\t\t\t\t<h3 class=\"box-title\">Report Summary</h3>\n" +
    			"\t\t\t\t\t\t\t"+
    			"</div>"+
    			"\n" +
    			"\t\t\t\t\t\t\t"+
    			"<div class=\"box-body\">\n" +
    			"\t\t\t\t\t\t\t\t"+
    			"<div class=\"row\">\n" +
    			"\t\t\t\t\t\t\t\t\t"+
    			"<div class=\"col-md-12\">\n" +
    			"\t\t\t\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t\t\t\t\t\t\t"+
    			"<div class=\"heatmap\" id=\"report_heatmap_main\">\n" +
    			"\n" +
    			 " " + ContentHTML +"" +
    			"\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t \t \n" +
    			"\n" +
    			"</div>"+
    			"\t\n" +
    			"\t\t\t\t\t\t\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t\t\t\t"+
    			"</div>"+
    			"\n" +
    			"\t\t\t\t\t\t\t\t"+
    			"</div>"+
    			"\n" +
    			"\t\t\t\t\t\t\t"+
    			"</div>"+
    			"\n" +
    			"\t\t\t</div><!-- /.box box-primary -->\n" +
    			"\t\t </div><!-- /.col-md-12 End -->\n" +
    			"\t\t \n" +
    			"\t\t \n" +
    			"      </div><!-- /.row END -->\n" +
    			"\n" +
    			" </section>"+"\n" +
    			" \n" +
    			"\n" +
    			" \n" +
    			" \n" +
    			" \n" +
    			" \n" +
    			" \n" +
    			" <style>\n"+


    			"\t \n" +

    			"\tbody {background-color: #fff !important;  }\n" +

    			"\n"
    			+

    			" </style>"+
    			"\n" +
    			" \n" +
    			"<script src=\"assets/js/jquery.min.js\"></script>\n" +
    			"<script src=\"assets/js/bootstrap.min.js\"></script>\n" +
    			"<script src=\"assets/js/adminlte.min.js\"></script>\n" +
    			" <!-- FastClick -->\n" +
    			"<script src=\"assets/js/fastclick.js\"></script>\n" +
    			"<!-- AdminLTE for demo purposes -->\n" +
    			"<script src=\"assets/js/demo.js\"></script>\n" +
    			"\n" +
    			"<script src=\"assets/js/DataTable/jquery.dataTables.min.js\"></script>\n" +
    			"<script src=\"assets/js/DataTable/dataTables.bootstrap.min.js\"></script>\n" +
    			"<script src=\"assets/js/DataTable/jquery.slimscroll.min.js\"></script>\n" +
    			"\n" +
    			"<script type=\"text/javascript\" src=\"heatmap-js/heatmap.js\"></script> \n" +
    			"\n" +
    			"<script language=\"javascript\">\n" +
    			"\t\n" +
    			"\t$( document ).ready(function() {\n" +
    			"\t\theatMap()\n" +
    			"\t});\n" +
    			"\t\n" +
    			"\t$( window ).resize(function() {\n" +
    			"\t\t\n" +
    			"\t\t$('canvas' ).each(function(){\n" +
    			"\t\t\tvar canvas=this;\n" +
    			"\t\t\t canvas.remove();\n" +
    			"\t\t});\n" +
    			"\t\t\n" +
    			"\t\t$('.tooltip' ).each(function(){\n" +
    			"\t\t\tvar tooltip=this;\n" +
    			"\t\t\t tooltip.remove();\n" +
    			"\t\t});\n" +
    			"\t\theatMap()\n" +
    			"\t});\n" +
    			"\t\n" +
    			"\tfunction heatMap(){\n" +
    			"\t\t \n" +
    			"\t\n" +
    			"\t\t$('#mobile').remove();\n" +
    			"\t\t$('#coupon').remove();\n" +
    			"\t \t\n" +
    			"\t\t//var newHTML = $('#report_heatmap_main').clone().find(\"body\").remove().end().html();\n" +
    			"\t\t\n" +
    			"\t\t//console.log(newHTML);\n" +
    			"\t\t//title.append('<meta http-equiv=\"X-UA-Compatible\" content=\"IE=EmulateIE10\">');\n" +
    			" \n" +
    			"\tvar sayac=0;\n" +
    			"\tvar toplam_clicks=0;\n" +
    			"\tvar href;\n" +
    			"\t \n" +
    			"\tvar ContentHeight = document.getElementById('report_heatmap_main');\n" +
    			"\t if(ContentHeight) {\n" +
    			"\t\t var ContentHeight=document.getElementsByTagName(\"html\")[0].scrollHeight\n" +
    			"\t\t \n" +
    			"\t } \n" +
    			"\t\n" +
    			"\t$('#report_heatmap_main a' ).each(function(){\t\n" +
    			"\t \n" +
    			"\t\t\n" +
    			"\t\t\tvar link=$(this);\n" +
    			"\t\t\tvar href = $(this).attr('href');\n" +
    			"\t\t\t$(this).click(false);\t \n" +
    			"\t\t\tvar Img=$(this).find('img').attr('src');\n" +
    			"\t\t\t\n" +
    			"\t\t\tif(Img){\n" +
    			"\t\t\t\t\n" +
    			"\t\t\t var height = $(this).parent().find(\"img\").height();\t\n" +
    			"\t\t\t var width = $(this).parent().find(\"img\").width(); \n" +
    			"\t\t\t var imgposition =$(this).find(\"img\").position();\n" +
    			"\t\t\t \n" +
    			"\t\t\t \t $('#sinan tr').each(function() {\n" +
    			"\t\t\t\t \t\t \n" +
    			"\t\t\t\t \t var urlKontrol = $(this).find(\"td\").eq(1).text();\n" +
    			"\t\t\t\t \t \n" +
    			"\t\t\t\t \t \n" +
    			"\t\t\t\t \t \tif(urlKontrol.trim()==href.trim()){\n" +
    			"\t\t\t\t \t \t \n" +
    			"\t\t\t\t \t \t\tvar sayi = $(this).find(\"td\").eq(0).text();\n" +
    			"\t\t\t\t\t\t\tvar toplamadet = $(this).find(\"td\").eq(2).text();\n" +
    			"\t\t\t\t\t\t\tvar toplamclicks = $(this).find(\"td\").eq(3).text();\n" +
    			"\t\t\t\t\t\t\tvar ort=Math.round(toplamclicks/toplamadet);\n" +
    			"\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t\tvar yuzde=(sayi*100)/toplamclicks;\n" +
    			"\n" +
    			"\t\t\t\t\t\t\tvar left_konum=Math.round(imgposition.left + (width/2)-30);\n" +
    			"\t\t\t\t\t\t\tvar top_konum=Math.round(imgposition.top + (height/2)-18);\n" +
    			"\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t link.append('<div class=\"tooltipheatmap\" style=\"padding:10px; font-size:14px;color:#fff;text-decoration:none; z-index: 10000001;position:absolute;left:'+left_konum+'px;top:'+top_konum+'px; \">%' + yuzde.toFixed(2) +' </div>');\n" +
    			"\n" +
    			"\t\t\t\t\t\t\t \n" +
    			"\t\t\t\t\t\t\tvar xx = h337.create({\n" +
    			"\t\t\t\t\t\t\t\t element: document.getElementById(\"report_heatmap_main\"),\n" +
    			"\t\t\t\t\t\t\t\t\"height\":ContentHeight,\n" +
    			"\t\t\t\t\t\t\t\t\"radius\":50,\n" +
    			"\t\t\t\t\t\t\t\t\"visible\":true\t\t\t\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t\t});\n" +
    			"\n" +
    			"\t\t\t\t\t\t\tvar database = {max:ort,\n" +
    			"\t\t\t\t\t\t\t\t data: [{x:imgposition.left + (width/2), y: imgposition.top + (height/2), count: sayi}]\n" +
    			"\t\t\t\t\t\t\t\t };\n" +
    			"\t\t\t\t\t\t\t\t\t\t\t\t\t\n" +
    			"\t\t\t\t\t\t\txx.store.setDataSet(database);\n" +
    			"\t\t\t\t\t\t \n" +
    			"\t\t\t\t \t \t \t\n" +
    			"\t\t\t\t\t\t \n" +
    			"\t\t\t\t\t}\n" +
    			"\t\t\t\t });\t\t\n" +
    			"\n" +
    			"\t\t\t\t \n" +
    			"\t\t\t\t\n" +
    			"\t\t\t}\n" +
    			" \t\n" +
    			"\t\t\n" +
    			"\t});\n" +
    			"\t \t\n" +
    			" \n" +
    			" \n" +
    			"\t\n" +
    			"\t}\n" +
    			"\t\n" +
    			" \n" +
    			" \n" +
    			"</script>\n" +
    			" }\n" +
    			"</body>\n" +
    			"</html>\n";




	JsonObject dataHtml = new JsonObject();
	JsonObject dataHtml1 = new JsonObject();
	JsonObject dataHtml2 = new JsonObject();
	JsonArray arrays = new JsonArray();
	data = new JsonObject();
	data.put("RETURN_Table",RETURN_Table);
	data.put("ReportName",reportName);
	data.put("SubjectLine",SubjectLine);
	data.put("ContentHTML",ContentHTML);
	data.put("html",html);
	array.put(data);
	dataHtml.put("dataHtml",array);
	dataHtml1.put("dataHtml1",array1);
	dataHtml2.put("dataHtml2",array2);
	arrays.put(dataHtml);
	arrays.put(dataHtml1);
	arrays.put(dataHtml2);
	arrays.put(obj3);
	out.println(arrays);
}
catch (Exception ex) { throw ex; }
finally
{
	try
	{   if (rs != null) rs.close();
		if( stmt  != null ) stmt.close();
		if( conn  != null ) cp.free(conn);
	}
	catch (SQLException ex) { }
}
%>










