<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.util.Date" %>
<%@ page import="net.sourceforge.jtds.jdbc.DateTime" %>
<%@ page import="java.time.DateTimeException" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp" %>
<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    String sCustId = user.s_cust_id;
    String firstDate =request.getParameter("firstDate");
    String lastDate =request.getParameter("lastDate");
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    System.out.println("Revotrack start for cust: "+sCustId);


    
    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;

    String date1 = null;
    String date4 = null;

    String sTotalClicks =null;
    Double sTotalClicksInt =null;

    String sPurchases		=null;
    BigDecimal sTotalSales =BigDecimal.ZERO;
    String zTotalSales =null;
    String date15 =null;
    String sTotalPurchasers =null;
    Double sTotalPurchasersInt =null;

    Double sAverageSales =null;
    String sCampCount =null;

    Double sConversionRate;

    String sConversionFormated = null;

    Double nConversion;
    String nConversionFormated = null;

    String sAverageSalesFormated = null;


    StringBuilder Revotrack_TR = new StringBuilder();


    Locale turkish = new Locale("tr", "TR");
    NumberFormat turkishFormat = NumberFormat.getCurrencyInstance(turkish);


   JsonObject totalCustomerTotalOrdersAvgOrders = new JsonObject();
   JsonObject totalClicks = new JsonObject();
   JsonObject purchases = new JsonObject();
   JsonObject totalPurchases = new JsonObject();
   JsonObject countCampId = new JsonObject();
   JsonObject campaignDetails = new JsonObject();
   JsonArray campaignDetailsArray = new JsonArray();


    Integer averageConversion = null ;
    String SQL = "";
    try {

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();



        // TODO -----PARAMETER DATE RANGE  count(orders),count(customers),avg(orders)  SQL
        String totalSql = "SELECT count(orders),count(customers),avg(orders) FROM  untt_mbs_order_date  with(nolock) where  cust_id = "+ sCustId +"  AND date >='"+ firstDate +"' and  date <= '"+ lastDate +"'";
        resultSet = statement.executeQuery(totalSql);
        while (resultSet.next()){

            totalCustomerTotalOrdersAvgOrders.put("totalOrder",resultSet.getInt(1));
            totalCustomerTotalOrdersAvgOrders.put("totalCustomer",resultSet.getInt(2));
            totalCustomerTotalOrdersAvgOrders.put("averageOrder",resultSet.getInt(3));

        }
        resultSet.close();


            SQL=   	" SELECT MIN(CONVERT(VARCHAR(10),DATEADD (day, -1,mbs.date), 111)) FROM untt_mbs_order_date as mbs WHERE cust_id = " +sCustId;


            resultSet = statement.executeQuery(SQL);

            while(resultSet.next()){
                date1=resultSet.getString(1);
            }
              resultSet.close();
            date4 = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));





        SQL=      " IF OBJECT_ID('tempdb..#camp_id') IS NOT NULL DROP TABLE #camp_id "
                +" 		SELECT camp_id into #camp_id FROM cque_campaign with(nolock) "
                +"			WHERE cust_id = " +sCustId+ " and  type_id in (2,4) and camp_id in ( "
                +"				SELECT DISTINCT camp_id FROM untt_mbs_order_date with(nolock) "
                +" 				WHERE cust_id = " +sCustId+" and  amount_sum is not null "
                +" 				and  date BETWEEN '"+firstDate+" 00:00:00' AND '"+date4+" 23:59:59' "
                +"		)  " ;



        statement.executeUpdate(SQL);


        SQL =    " IF OBJECT_ID('tempdb..#temp_activity') IS NOT NULL DROP TABLE #temp_activity " +
                " select rjtk.camp_id as camp_id, rjtk.rjtk_count as clicks  into #temp_activity from ccps_rjtk_link_activity as rjtk\n" +
                " where rjtk.camp_id in ( SELECT * FROM #camp_id )  and rjtk.type_id = 2 and rjtk.cust_id = " +sCustId +
                " and rjtk.click_time BETWEEN '"+firstDate+" 00:00:00' AND '"+date4+" 23:59:59'   " ;



        statement.executeUpdate(SQL);



        SQL = "SELECT sum(clicks) FROM  #temp_activity ";

        resultSet = statement.executeQuery(SQL);
        while(resultSet.next()){
            sTotalClicks = (resultSet.getString(1)==null) ? "0" : resultSet.getString(1);
            sTotalClicksInt = Double.parseDouble(sTotalClicks);

            totalClicks.put("totalClicks" , sTotalClicksInt);
        }
        resultSet.close();


        SQL=       " SELECT  sum(orders) as purchases FROM untt_mbs_order_date  with(nolock) "
                +" WHERE cust_id = " +sCustId+ " and camp_id in (select * from #camp_id)"
                +" AND  date BETWEEN '"+firstDate+" 00:00:00' AND '"+date4+" 23:59:59' " ;

        resultSet = statement.executeQuery(SQL);
        while(resultSet.next()){
            sPurchases		=(resultSet.getString(1)==null) ? "0" : resultSet.getString(1);
        }

        resultSet.close();





        SQL=	"  SELECT  sum(customers) as purchases "
                +" FROM untt_mbs_order_date "
                +" WHERE cust_id = " +sCustId+ " and camp_id in (select * from #camp_id)"
                +" AND  date BETWEEN '"+firstDate+" 00:00:00' AND '"+date4+" 23:59:59' " ;

        resultSet = statement.executeQuery(SQL);
        while(resultSet.next()){
            sTotalPurchasers = (resultSet.getString(1)==null) ? "0" : resultSet.getString(1);
            sTotalPurchasersInt = Double.parseDouble(sTotalPurchasers);
            totalPurchases.put("totalPurchases", sTotalPurchasersInt);
        }
        resultSet.close();


        SQL="select count(camp_id) FROM #camp_id";

        resultSet = statement.executeQuery(SQL);
        while(resultSet.next()){
            sCampCount =(resultSet.getString(1)==null) ? "0" : resultSet.getString(1);

            countCampId.put("countCampId", sCampCount);


        }
        resultSet.close();



        SQL= "SELECT cc.camp_name,sum(mbs.orders) as purchasers ,sum(mbs.customers) as purchases ,sum(mbs.amount_sum) total ,  "
                +"	mbs.camp_id, rs.start_date, "
                +"  (select CASE WHEN sum(clicks)>0 THEN sum(clicks) ELSE 1 END  from #temp_activity  where  camp_id=mbs.camp_id  )  as clicks ,"
                +"	cc.type_id,rcs.queue_daily_flag,cc.camp_code  "
                +" FROM untt_mbs_order_date as mbs with(nolock)\n"
                +"	INNER JOIN cque_campaign cc with(nolock) on mbs.camp_id=cc.camp_id\n"
                +"	INNER JOIN cque_schedule rs with(nolock) on mbs.camp_id=rs.camp_id\n"
                +"	INNER JOIN cque_camp_send_param rcs with(nolock) on mbs.camp_id=rcs.camp_id\n"

                +"WHERE "
                +"	mbs.amount_sum is not null "
                +"	and cc.type_id in (2,4) "
                +"	and cc.cust_id=" +sCustId
                +"	and mbs.camp_id in ( select * from #camp_id ) "
                +"	and mbs.date BETWEEN '"+date1+" 00:00:00' AND '"+date4+" 23:59:59'"

                +" GROUP BY  mbs.camp_id,cc.camp_name,rs.start_date,rcs.queue_daily_flag,cc.type_id,cc.camp_code  "
                +" ORDER by  mbs.camp_id desc";





        resultSet = statement.executeQuery(SQL);
        int iCount = 0;
        String sClassAppend = "_other";


        String sCamp_Name			=null;
        String sCamp_Purchasers		=null;
        String sCamp_Purchases		=null;
        BigDecimal sCamp_Sales		=BigDecimal.ZERO;
        String zCamp_Sales			=null;
        String sCamp_ID				=null;
        String zCamp_Start_Date		=null;
        String sClicks				=null;
        String sType_ID				=null;
        String sDaily_Flag			=null;
        String sDisplay_Type		=null;
        String sCamp_Code			=null;



        while(resultSet.next()){
            campaignDetails = new JsonObject();
            if (iCount % 2 != 0) sClassAppend = "_other";
            else sClassAppend = "";
            iCount++;

            sCamp_Name 	 			= new String(resultSet.getBytes(1),"UTF-8");
            sCamp_Purchasers		=(resultSet.getString(2)==null) ? "0.0" : resultSet.getString(2);
            sCamp_Purchases			= (resultSet.getString(3)==null) ? "0.0" : resultSet.getString(3);
            sCamp_Sales 			= resultSet.getBigDecimal(4).equals("null") ? BigDecimal.ZERO : resultSet.getBigDecimal(4);
            sCamp_Sales 			= sCamp_Sales.setScale(2, BigDecimal.ROUND_HALF_EVEN);
            zCamp_Sales				= turkishFormat.format(sCamp_Sales);
            sTotalSales = sTotalSales.add( sCamp_Sales);
            sCamp_ID	 			= resultSet.getString(5);
            zCamp_Start_Date	 	= resultSet.getString(6);
            sClicks	 				= resultSet.getString(7);
            sType_ID	 			= resultSet.getString(8);
            sDaily_Flag	 			= resultSet.getString(9);
            sCamp_Code	 			= resultSet.getString(10);



            


            int intPurchases = Integer.parseInt(sCamp_Purchases);
            int intClicks = Integer.parseInt(sClicks);

            nConversion=(100.0 * intPurchases) /  intClicks;
            nConversionFormated = String.format("%.2f", nConversion);

            if(sCamp_Code ==null){
                sCamp_Code ="-";
            }


            if(sType_ID.equals("4")){

                sDisplay_Type ="Automated";
            }

            if(sType_ID.equals("2")) {
                sDisplay_Type ="Standard";
            }


            //if(sType_ID.equals("2") && sDaily_Flag.equals("1")) {
            if (sType_ID.equals("2") ){
                if(sDaily_Flag !=null){
                    sDisplay_Type ="Check Daily";
                }
            }
             

            campaignDetails.put("campName", sCamp_Name);
            campaignDetails.put("campPurchasers",sCamp_Purchasers);
            campaignDetails.put("campPurchases",sCamp_Purchases);
            campaignDetails.put("campSales",sCamp_Sales);
            campaignDetails.put("sCampSales",sCamp_Sales);
            campaignDetails.put("zCampSales",zCamp_Sales);
            campaignDetails.put("sTotalSales", sTotalSales);
            campaignDetails.put("campId",sCamp_ID);
            campaignDetails.put("campStartDate",zCamp_Start_Date);
            campaignDetails.put("clicks",sClicks);
            campaignDetails.put("typeId",sType_ID);
            campaignDetails.put("dailyFlag",sDaily_Flag);
            campaignDetails.put("campCode",sCamp_Code);
            campaignDetails.put("nConversion", nConversionFormated);
            campaignDetailsArray.put(campaignDetails);


        }
       
        out.print(campaignDetailsArray);
        resultSet.close();

        SQL= "DROP TABLE #temp_activity  DROP TABLE #camp_id";
        statement.executeUpdate(SQL);


        int iPurchases = Integer.parseInt(sPurchases);
        if (iPurchases == 0){
            sAverageSales = 0.0;
            sAverageSalesFormated = "0.0";
        }else{
            sAverageSales = sTotalSales.doubleValue() / iPurchases ;
            sAverageSalesFormated = String.format("%.2f", sAverageSales);
        }

        if (sTotalClicksInt == 0){
            sConversionRate =0.0;
            sConversionFormated ="0.0";

        }else{
            sConversionRate = (100 * sTotalPurchasersInt)/ sTotalClicksInt;
            sConversionFormated = String.format("%.2f", sConversionRate);

        }

        zTotalSales = (turkishFormat.format(sTotalSales)==null)?"0,0TL":turkishFormat.format(sTotalSales);

        JsonObject jsonObject = new JsonObject();


        jsonObject.put("zTotalSales",sAverageSales);
        jsonObject.put("zTotalSales",sAverageSalesFormated);
        jsonObject.put("zTotalSales",sConversionFormated);
        jsonObject.put("zTotalSales",zTotalSales);

        //jsonObject.put("test",1);
        

        jsonObject.put("totalCustomerTotalOrdersAvgOrders",totalCustomerTotalOrdersAvgOrders);
        jsonObject.put("campaignDetails", campaignDetailsArray);
        jsonObject.put("totalClicks",totalClicks);
        jsonObject.put("purchases", purchases);
        jsonObject.put("totalPurchases",totalPurchases);
        jsonObject.put("countCampId",countCampId);
        jsonObject.put("totalSales", sTotalSales);




        out.print(date1);
        out.print("\n");
        out.print(date4);
        out.print(jsonObject);
        


    }catch (Exception exception){
        exception.printStackTrace();

        System.out.println(exception.getMessage());
    }


%>
