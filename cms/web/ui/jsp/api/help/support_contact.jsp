<%@  page language="java"
          import="java.net.*,
                  java.text.SimpleDateFormat,
                  com.britemoon.*,
                  com.britemoon.rcp.*,
                  com.britemoon.rcp.imc.*,
                  com.britemoon.rcp.que.*,
                  java.sql.*,
                  java.io.*,
                  java.math.BigDecimal,
                  java.text.NumberFormat,
                  java.io.*,
                  org.apache.log4j.Logger,
                  org.w3c.dom.*"
          contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%>
<%@ page import="static java.sql.JDBCType.NULL" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.ParseException" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>

<%!
    public String dateFormater(String dateValue, String newFormat, String oldFormat) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(oldFormat);
        Date date = null;
        String convertedDate = null;
        try {
            date = dateFormat.parse(dateValue);
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat(newFormat);
            convertedDate = simpleDateFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return convertedDate;
    }

%>

<%
    request.setCharacterEncoding("UTF-8");
    String title =new String(request.getParameter("title"));
    String body = new String(request.getParameter("body"));
    String name = new String(request.getParameter("campaign_name").getBytes("ISO-8859-1"), "UTF-8");
    String campaign_type = request.getParameter("campaign_type").replace("*--*", " ");
    String path = new String(request.getParameter("url").getBytes("ISO-8859-1"), "UTF-8");
    String image = request.getParameter("img").replace("*--*", " ");
    String icon = request.getParameter("icn").replace("*--*", " ");
    String segment = request.getParameter("segment").replace("*--*", " ");
    String custid = request.getParameter("custid").replace("*--*", " ");
    String status_id = request.getParameter("statuid").replace("*--*", " ");
    String approvel_id = request.getParameter("approvelid").replace("*--*", " ");
    String utmcampaign = new String(request.getParameter("utmcampaign").getBytes("ISO-8859-1"), "UTF-8");
    String utmsource = new String(request.getParameter("utmsource").getBytes("ISO-8859-1"), "UTF-8");
    String utmmedium = new String(request.getParameter("utmmedium").getBytes("ISO-8859-1"), "UTF-8");
    String utmterm = new String(request.getParameter("utmterm").getBytes("ISO-8859-1"), "UTF-8");
    String utmcontent = new String(request.getParameter("utmcontent").getBytes("ISO-8859-1"), "UTF-8");
    String send_date = request.getParameter("send_date").replace("*--*", " ");
    String filter_type= request.getParameter("filter_type").replace("*--*", " ");
    String queue_date = request.getParameter("queue_date");
    String camp_temp_type = request.getParameter("camp_temp_type").replace("*--*", " ");
    String triger_time_type = request.getParameter("triger_time_type").replace("*--*", " ");
    String triger_time_parameter = request.getParameter("triger_time_parameter").replace("*--*", " ");
    String start_time_type = request.getParameter("start_time_type").replace("*--*", " ");
    String exclude_time = request.getParameter("exclude_time").replace("*--*", " ");
    String personalize = request.getParameter("personalize").replace("*--*", " ");
    String personalize_img = request.getParameter("personalize_img").replace("*--*", " ");
    String personalize_icon = request.getParameter("personalize_icon").replace("*--*", " ");
    String button_count = request.getParameter("button_count").replace("*--*", " ");
    String first_button_title = new String(request.getParameter("first_button_title").getBytes("ISO-8859-1"), "UTF-8");
    String first_button_url = new String(request.getParameter("first_button_url").getBytes("ISO-8859-1"), "UTF-8");
    String second_button_title = new String(request.getParameter("second_button_title").getBytes("ISO-8859-1"), "UTF-8");
    String second_button_url = new String(request.getParameter("second_button_url").getBytes("ISO-8859-1"), "UTF-8");
    String daily_weekday_mask = request.getParameter("daily_weekday_mask").replace("*--*", " ");
    String queue_weekday_mask = request.getParameter("queue_weekday_mask").replace("*--*", " ");
    String start_daily_time = request.getParameter("start_daily_time").replace("*--*", " ");
    String q_start_daily_time = request.getParameter("q_start_daily_time");
    String all = request.getParameter("allow_recipients").replace("*--*", " ");
    String dEnd_date ;
    int  allow_recipients ;


    System.out.println("BU camp_temp_type " + camp_temp_type );

    System.out.println(" DATE"  + request.getParameter("end_date"));
    if(request.getParameter("end_date").equals("null")) {
        dEnd_date = "2099-04-18 13:27:00";
    }else {
        dEnd_date = request.getParameter("end_date");
    }

    System.out.println(dEnd_date);

    if(all.equals("true")||all.equals("1")) {
        allow_recipients = 1;
    }else{
        allow_recipients = 0;

    }
    String end_daily_time = request.getParameter("end_daily_time");

    System.out.println(allow_recipients);

    String dQueue_date = null;
    String dSend_date = send_date;
    String start_daily_weekday_mask = null;
    String queue_daily_weekday_mask = null;


    if (title.contains("'"))
    {
        title=  title.replace("'", "''");
        System.out.println(title);
    }
    if (body.contains("'"))
    {
        body=  body.replace("'", "''");
    }
    if(name.contains("'"))
    {
        name=name.replace("'", "''");
    }
    String a = first_button_title;
    String b = second_button_title;
    if (a.contains("'"))
    {
        first_button_title = a.replace("'","''");
        System.out.println(first_button_title);
    }
    if (b.contains("'"))
    {
        second_button_title = b.replace("'","''");
    }
    if (a.contains("`"))
    {
        first_button_title = a.replace("`","''");
        System.out.println(first_button_title);
    }
    if (b.contains("`"))
    {
        second_button_title = b.replace("`","''");
    }
    if (!send_date.equals("null")){
        dSend_date = send_date;
        System.out.println("dSend_date");
        System.out.println(dSend_date);
    }
    if (!queue_date.equals("null")){
        dQueue_date = queue_date;
        System.out.println("dQueue_date");
        System.out.println(dQueue_date);
    }

    if (!daily_weekday_mask.equals("null")){
        start_daily_weekday_mask = daily_weekday_mask;
    }

    if (!queue_weekday_mask.equals("null")){
        queue_daily_weekday_mask = queue_weekday_mask;
    }




     /*
      File file = new File("C:\\Revotas\\rrcp\\web\\imc\\campaign.txt");
      if (!file.exists()) {
          file.createNewFile();
      }

      FileWriter fileWriter = new FileWriter(file, false);
      BufferedWriter bWriter = new BufferedWriter(fileWriter);
      bWriter.write(title+"-"+body);
      bWriter.close();
      */

    // Get Connection
    Statement statement = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;
    ResultSet resultSet = null ;
    PreparedStatement preparedStatement1 ;

    try {
        System.out.println("*------*" + send_date + "*------*" + triger_time_type + "*------*" + triger_time_parameter + "*------*" + start_time_type + "*------*" + exclude_time);
        System.out.println(start_daily_time);
        cp = ConnectionPool.getInstance(custid);
        conn = cp.getConnection(this);
        statement = conn.createStatement();
        //canlıda statu ve type alanları değişecek
        String queryString = "INSERT INTO rque_push_campaign(type_id,status_id,cust_id,filter_id,img,url,title,msg,approvel_flag,icon,camp_name,utm_campaign,utm_source,utm_medium,utm_term,utm_content,filter_type,camp_temp_type,personalize,personalize_img,personalize_icon,button_count,first_button_title,first_button_url,second_button_title,second_button_url) " +
                "VALUES('" + campaign_type + "','" + status_id + "','" + custid + "','" + segment + "','" + image +
                "','" + path + "','" + title + "','" + body + "','" + approvel_id + "','" + icon + "','" + name +
                "','" + utmcampaign + "','" + utmsource + "','" + utmmedium + "','" + utmterm + "','" + utmcontent +
                "','" + filter_type + "','" + camp_temp_type + "','" + personalize + "','" + personalize_img + "','"
                + personalize_icon + "','" + button_count + "','" + first_button_title + "','" + first_button_url + "','" + second_button_title + "','" + second_button_url + "')";
        System.out.println(queryString);
        statement.executeUpdate(queryString, Statement.RETURN_GENERATED_KEYS);
        ResultSet sr = statement.getGeneratedKeys();
        int cmp_id = 0;
        boolean kontrol = false;
        String scheduleSave = "";

        if (sr.next()) {
            cmp_id = sr.getInt(1);
            System.out.println(cmp_id + "*------*" + send_date + "*------*" + triger_time_type + "*------*" + triger_time_parameter + "*------*" + start_time_type + "*------*" + exclude_time);
            scheduleSave = "EXEC [z_rque_push_schedule_save] @camp_id=?,@start_date=?, @end_date=?, @start_daily_time=?, @end_daily_time=?, @start_daily_weekday_mask=?, @trgr_time_type=?, @trgr_time_parameter=?, @start_time_type=?, @exclude_time=?";
            //scheduleSave = "EXEC [z_rque_push_schedule_save] " +cmp_id+", "+dSend_date +","+ dEnd_date+","+ start_daily_time+","+ end_daily_time+","+ daily_weekday_mask+","+ triger_time_type+","+ triger_time_parameter+","+ start_time_type+","+ exclude_time;
            kontrol = true;

            try{
                String queued = "INSERT INTO rque_push_camp_send_param (camp_id, recip_qty_limit, queue_date, queue_daily_weekday_mask, queue_daily_time) values(?, ?, ?, ?, ?)";
                PreparedStatement preparedStatement = conn.prepareStatement(queued);
                preparedStatement.setInt(1, cmp_id);
                preparedStatement.setInt(2, allow_recipients);
                preparedStatement.setString(3, queue_date);
                preparedStatement.setString(4, queue_daily_weekday_mask);
                if (q_start_daily_time.equals("null")){
                    preparedStatement.setNull(5, Types.INTEGER);
                }else {
                    preparedStatement.setInt(5, Integer.parseInt(q_start_daily_time));
                }
                preparedStatement.executeUpdate();
                preparedStatement.close();
            }catch (Exception e){
                System.out.println("rque_push_camp_send_param INSERT HATA: "+ e.getMessage());
            }
        }
        if (kontrol) {
            PreparedStatement psmt = conn.prepareStatement(scheduleSave);
            System.out.println("cmp_id"+cmp_id);
            System.out.println("dSend_date"+dSend_date);
            System.out.println("dEnd_date"+dEnd_date);
            System.out.println("start_daily_time"+start_daily_time);
            System.out.println("end_daily_time"+end_daily_time);
            System.out.println("start_daily_weekday_mask"+start_daily_weekday_mask);
            System.out.println("triger_time_type"+triger_time_type);
            System.out.println("triger_time_parameter"+triger_time_parameter);
            System.out.println("start_time_type"+start_time_type);
            System.out.println("exclude_time"+exclude_time);

            psmt.setInt(1,cmp_id);
            psmt.setString(2,dSend_date);
            psmt.setString(3,dEnd_date);
            psmt.setString(4,start_daily_time);
            psmt.setString(5,end_daily_time);
            psmt.setString(6,start_daily_weekday_mask);
            psmt.setString(7,triger_time_type);
            psmt.setString(8,triger_time_parameter);
            psmt.setString(9,start_time_type);
            psmt.setString(10,exclude_time);
            //Statement statement = conn.createStatement();
            int yaz = psmt.executeUpdate();
            if (yaz > 0)
                //System.out.println("exccc:  "+ yaz);
                out.println("200");

        }


    } catch (Exception e) {
        System.out.println("Insert Campaign: LINE 187: "+e.getMessage());
        e.printStackTrace();
        out.println(e.getMessage());
        out.println("500");
    } finally {
        try {

            if (rs != null)
                rs.close();
            if (statement != null)
                statement.close();
            if (conn != null) {

                conn.close();
                cp.free(conn);
            }
        } catch (SQLException e) { /* ignored */}
    }




%>
