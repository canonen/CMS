<%@ page
		language="java"
		import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			javax.xml.parsers.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.io.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.io.StringReader" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="sun.nio.ch.IOUtil" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="org.xml.sax.SAXException" %>
<%@ page import="org.xml.sax.SAXParseException" %>
<%@ page import="org.apache.axis.ConfigurationException" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="com.britemoon.cps.imc.Service" %>

<%!
	public class ProductListReport{		//++++

		public String product_status 		  = null;
		public String product_name	          = null;
		public String link	                  = null;
		public String image_link	          = null;
		public String product_id	          = null;
		public String product_price	          = null;
		public String product_sales_price	  = null;



		public ProductListReport(Element element){

			product_status 		  =  Deger(element.getElementsByTagName("product_status")).equals("null") ? null : Deger(element.getElementsByTagName("product_status"));
			product_name	      =  Deger(element.getElementsByTagName("product_name")).equals("null") ? null : Deger(element.getElementsByTagName("product_name"));
			link	              =  Deger(element.getElementsByTagName("link")).equals("null") ? null : Deger(element.getElementsByTagName("link"));
			image_link	          =  Deger(element.getElementsByTagName("image_link")).equals("null") ? null : Deger(element.getElementsByTagName("image_link"));
			product_id	          =  Deger(element.getElementsByTagName("product_id")).equals("null") ? null : Deger(element.getElementsByTagName("product_id"));
			product_price	      =  Deger(element.getElementsByTagName("product_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_price"));
			product_sales_price	  =  Deger(element.getElementsByTagName("product_sales_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_sales_price"));

		}


		public String Deger(NodeList g1){

			String deger=null;

			if(g1.getLength()>0){
				Element g1_Element		= (Element)g1.item(0);
				NodeList text_g1 		= g1_Element.getChildNodes();
				if(text_g1.item(0) != null ){
					deger					=((Node)text_g1.item(0)).getNodeValue().trim();
				}
			}

			return MysqlRealScapeString(deger)  ;
		}

		public String MysqlRealScapeString(String str){
			String data = "";
			if (str != null && str.length() > 0) {
				str = str.replace("\\", "\\\\");
				str = str.replace("'", "");
				str = str.replace("\0", "\\0");
				str = str.replace("\n", "\\n");
				str = str.replace("\r", "\\r");
				str = str.replace("\"", "\\\"");
				str = str.replace("\\x1a", "\\Z");
				data = str;
			}
			return data;
		}
	}
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	Statement stmt  = null;
	ConnectionPool connectionPool	=null;
	Connection connection			=null;

	StringBuilder TABLETR = new StringBuilder();

	StringWriter sw = new StringWriter();
	int iCount=0;
	try
	{
		System.out.println("ProductListReport is loading...");

		connectionPool	= ConnectionPool.getInstance();
		connection		= connectionPool.getConnection("report_product_lists");
		String cust_id	= cust.s_cust_id;

		NodeList nodeList = null;


//			BufferedReader bufferedReader = new BufferedReader(new InputStreamReader((request.getInputStream()), "UTF-8"));
//			DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
//			DocumentBuilder builder = builderFactory.newDocumentBuilder();
//			Document document = builder.parse(new InputSource(bufferedReader));

			sw.write("<root>");
			sw.write("<ccps_product_list>\r\n");
			sw.write("<cust_id><![CDATA[" + cust_id + "]]></cust_id>\r\n");
			sw.write("</ccps_product_list>\r\n");
			sw.write("</root>");

			System.out.println(sw.toString());


			String sResponse = Service.communicate(124, cust_id, sw.toString());


			sResponse = sResponse.substring(41);

			System.out.println("Response:"+sResponse);

			DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();


			Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));


			nodeList = document.getElementsByTagName("rrcp_product_list_report");
//		}
		if(nodeList !=null) {
			for (int i = 0; i < nodeList.getLength(); i++) {

				ProductListReport report = new ProductListReport((Element) nodeList.item(i));


				if (iCount != 0 && iCount % 5 == 0) TABLETR.append("</tr>\n    <tr>");

				String TD = "<td> "
						+ "      <ul class='users-list clearfix'> "
						+ "            <li> "
						+ "                  <a href='" + report.link + "' target='_blank'> "
						+ "                        <img src='" + report.image_link + "' > "
						+ "                  </a> "
						+ "                 <p style='position:relative;'> <button id='copyimg' type='button' class='btn btn-info btn-flat copybtn '>Copy IMG</button>"
						+ "                  <input type='hidden'  value='" + report.image_link + "'> <span style='display:none' class='tooltip_img'></span></p> "
						+ "                  <a class='users-list-name' target='_blank' href='" + report.link + "'>" + report.product_name + "</a> "
						+ "                  <span class='users-list-date'>ID: " + report.product_id + "</span> "
						+ "                  <span class='users-list-date'>Status: " + report.product_status + "</span> "
						+ "                  <span class='users-list-date'>" + report.product_sales_price + " - " + report.product_price + " </span> "
						+ "                  <div class='input-group input-group-sm' style='position:relative;'> "
						+ "                        <input type='text' class='form-control linkvalue' value='" + report.link + "'> "
						+ "                        <span class='input-group-btn'>"
						+ "                            <button id='copylink' type='button' class='btn btn-info btn-flat copybtn '>Copy URL</button></span> "
						+ "                        <span style='display:none' class='tooltip_link'></span> "
						+ "                  </div> "
						+ "            </li> "
						+ "      </ul> "
						+ " </td>";
				TABLETR.append(TD);

				iCount++;
			}
		}

			if (iCount % 5 == 1) {
				TABLETR.append("<td></td><td></td><td></td><td></td>");
			}
			if (iCount % 5 == 2) {
				TABLETR.append("<td></td><td></td><td></td>");
			}
			if (iCount % 5 == 3) {
				TABLETR.append("<td></td><td></td>");
			}
			if (iCount % 5 == 4) {
				TABLETR.append("<td></td>");
			}
		System.out.println("TABLETR:"+TABLETR);
	}
	catch (Exception e){
		logger.error("ProductListReport Update Error!\r\n", e);
		throw e;

	}finally {
		try {
			if (stmt!=null) stmt.close();
			if (connection!=null) connectionPool.free(connection);
		}catch (SQLException e){
			System.out.println(e);
		}
	}
%>


<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<title>Product Lists</title>
	<!-- Tell the browser to be responsive to screen width -->
	<meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">

	<link rel="stylesheet" href="assets/css/bootstrap.min.css">
	<link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
	<link rel="stylesheet" href="assets/css/font-awesome.min.css">

	<link rel="stylesheet" href="assets/css/ionicons.min.css">

	<link rel="stylesheet" href="assets/css/AdminLTE.css">
	<link rel="stylesheet" href="assets/css/Style.css">
	<link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css">
	<link rel="stylesheet" href="assets/css/skin-blue.min.css">

	<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
	<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
	<!--[if lt IE 9]>
	<script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
	<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
	<![endif]-->

	<!-- Google Font -->
	<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">

	<style>
		.tooltip_link{

			position: absolute;
			font-size: 10px;
			top: -3%;
			right:-24%;
			border: 1px solid #000;
			padding: 3px 7px;
			background-color: #000;
			color: #fff;
			border-radius: 4px;
		}

		.tooltip_img{
			position: absolute;
			font-size: 10px;
			right:28%;
			top: 5%;
			border: 1px solid #000;
			padding: 3px 7px;
			background-color: #000;
			color: #fff;
			border-radius: 4px;
		}

		.users-list >li img{
			width: 100px !important;
			border-radius: 0px !important;
		}

		.users-list > li {
			width: 100% !important;
			border:1px solid #ddd !important;
			position:relative;
		}

		.copybtn{
			padding:3px 5px !important;
			font-size:10px;

		}
		#copylink{
			padding: 3px 5px !important;
			height: 20px !important;
			border-radius: 0px !important;
			line-height: 12px !important;
			font-size:10px !important;
		}

		.linkvalue{
			padding:3px 5px !important;
			width: 100px;
			font-size:10px !important;
			padding: 4px !important;
			color:#444;
			height: 20px !important;

		}
		.users-list-name {
			white-space: inherit !important
		}
	</style>

</head>
<body class="hold-transition" style="background-color:#f1f1f1;">


<section class="content-header" >
	<div class="box box-solid">
		<div class="box-header with-border">
			<div class="col-md-6"><h3>Product Lists   </h3></div>

		</div>
	</div>

</section>


<section class="content" style="margin-left:20px;margin-right:20px;">


	<div class="row">

		<div class="box">
			<div class="box-header">
				<div class="col-md-6">
					<h3 class="box-title">Lists</h3>
				</div>

			</div>
			<div class="box-body">
				<table id="example1" class="table table-bordered table-striped">
					<thead>
					<tr>
						<th></th>
						<th></th>
						<th></th>
						<th></th>
						<th></th>
					</tr>
					</thead>
					<tbody>
					<tr>
						<%=TABLETR%>
					</tr>
					</tbody>




				</table>

			</div>
		</div>
	</div>
</section>


<script src="../rpt/assets/js/jquery.min.js"></script>
<script src="../rpt/assets/js/bootstrap.min.js"></script>
<script src="../rpt/assets/js/adminlte.min.js"></script>
<!-- FastClick -->
<script src="../rpt/assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="../rpt/assets/js/demo.js"></script>

<!-- DataTables -->
<script src="../rpt/assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="../rpt/assets/js/DataTable/dataTables.bootstrap.min.js"></script>

<script>

	$( document ).ready(function() {


		$('tbody').on("click","#copylink",function(){
			$('.tooltip_img').hide();
			$('.tooltip_link').hide();
			var btn=$(this);
			var linkvalue=btn.parent().parent().find('input').val();
			var tooltip=btn.parent().parent().find('.tooltip_link');

			var textArea = document.createElement("textarea");

			textArea.style.position = 'fixed';
			textArea.style.top = 0;
			textArea.style.left = 0;
			textArea.style.width = '2em';
			textArea.style.height = '2em';
			textArea.style.padding = 0;
			textArea.style.border = 'none';
			textArea.style.outline = 'none';
			textArea.style.boxShadow = 'none';
			textArea.style.background = 'transparent';

			textArea.value = linkvalue;
			document.getElementById("copylink").appendChild(textArea);
			textArea.select();

			try {
				var successful = document.execCommand('copy');
				var msg = successful ? 'successful' : 'unsuccessful';
				tooltip.text("Copy");
				tooltip.show();
				console.log('Copying text command was ' + msg);
			} catch (err) {
				console.log('Oops, unable to copy');
				tooltip.text("Error");
				tooltip.show();
			}
			document.getElementById("copylink").removeChild(textArea);


		})

		$('tbody').on("click","#copyimg",function(){

			$('.tooltip_link').hide();
			$('.tooltip_img').hide();
			var btn=$(this);
			var imgvalue=btn.parent().find('input').val();
			var tooltip=btn.parent().find('.tooltip_img');
			var textArea = document.createElement("textarea");

			textArea.style.position = 'fixed';
			textArea.style.top = 0;
			textArea.style.left = 0;
			textArea.style.width = '2em';
			textArea.style.height = '2em';
			textArea.style.padding = 0;
			textArea.style.border = 'none';
			textArea.style.outline = 'none';
			textArea.style.boxShadow = 'none';
			textArea.style.background = 'transparent';

			textArea.value = imgvalue;
			document.getElementById("copyimg").appendChild(textArea);
			textArea.select();

			try {
				var successful = document.execCommand('copy');
				var msg = successful ? 'successful' : 'unsuccessful';
				tooltip.text("Copy");
				tooltip.show();
				console.log('Copying text command was ' + msg);
			} catch (err) {
				console.log('Oops, unable to copy');
				tooltip.text("Error");
				tooltip.show();
			}
			document.getElementById("copyimg").removeChild(textArea);


		})

		$('#example1').DataTable({
			'paging'      : true,
			'lengthChange': true,
			'searching'   : true,
			'ordering'    : false,
			'info'        : true,
			'autoWidth'   : false,
			"lengthMenu": [ [5,10, 25, 50, -1], [5,10, 25, 50, "All"] ]


		})
	});
</script>

</body>
</html>


