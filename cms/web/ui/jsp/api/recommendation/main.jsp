<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                java.sql.*,
                java.net.*,
                java.util.Calendar,
                java.io.*,
                java.util.*,
                java.text.DateFormat,
                org.apache.log4j.*,
                com.restfb.json.JsonObject"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.text.DecimalFormat" %>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%

    String cust_id = request.getParameter("cust_id");
    String camp_id = request.getParameter("camp_id");
    String tarih_aralik = request.getParameter("tarih_aralik");
    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust_id);
    service = (Service) services.get(0);
    String rcpUrl = service.getURL().getHost();

    Calendar calendar = Calendar.getInstance();


    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;

    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH);


    if (camp_id != null) {
        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("recommendation_main.jsp");
            JsonObject jsonObject = new JsonObject();
            JsonArray array =new JsonArray();
            
            String sql = "select camp_name, camp_title, camp_type, template_id, status, products_num_block, container_size, rcp_link, currency_config, camp_add_to_cart, add_to_cart_script, product_script, filter_id, append_utm, exclude_recently_viewed, exclude_recently_purchased, fallback_camp_type from "
                    + "c_recommendation_config where camp_id = ? and cust_id = ?";

            pstmt = conn.prepareStatement(sql);
            int x = 1;
            pstmt.setString(x++, camp_id);
            pstmt.setLong(x++, Long.parseLong(cust_id));
            rs = pstmt.executeQuery();
            String camp_name = "";
            String camp_title = "";
            String camp_type = "";
            String fallback_camp_type = "";
            String template_id = "";
            String status = "";
            String products_num_block = "";
            String container_size = "";
            String rcp_link = "";
            String currency_config = "";
            String camp_add_to_cart = "";
            String add_to_cart_script = "";
            String product_script = "";
            String filter_id = "";
            String append_utm = "";
            String exclude_recently_viewed = "";
            String exclude_recently_purchased = "";
            if (rs.next()) {
                camp_name = rs.getString(1);
                camp_title = rs.getString(2);
                camp_type = rs.getString(3);
                template_id = rs.getString(4);
                status = rs.getString(5);
                products_num_block = rs.getString(6);
                container_size = rs.getString(7);
                rcp_link = rs.getString(8);
                currency_config = rs.getString(9);
                camp_add_to_cart = rs.getString(10);
                add_to_cart_script = rs.getString(11);
                product_script = rs.getString(12);
                filter_id = rs.getString(13);
                append_utm = rs.getString(14);
                exclude_recently_viewed = rs.getString(15);
                exclude_recently_purchased = rs.getString(16);
                fallback_camp_type = rs.getString(17);
            }
            rs.close();

            jsonObject.put("camp_name", fixTurkishCharacters(camp_name));
            jsonObject.put("camp_id", camp_id);
            jsonObject.put("camp_title", fixTurkishCharacters(camp_title));
            jsonObject.put("camp_type", camp_type);
            jsonObject.put("fallback_camp_type", fallback_camp_type);
            jsonObject.put("template_id", template_id);
            jsonObject.put("filter_id", filter_id);
            jsonObject.put("append_utm", append_utm);
            jsonObject.put("exclude_recently_viewed", exclude_recently_viewed);
            jsonObject.put("exclude_recently_purchased", exclude_recently_purchased);
            jsonObject.put("status", status);
            jsonObject.put("products_num_block", products_num_block);
            jsonObject.put("container_size", container_size);
            jsonObject.put("rcp_link", rcp_link);
            jsonObject.put("camp_add_to_cart", camp_add_to_cart);
            jsonObject.put("add_to_cart_script", add_to_cart_script);
            jsonObject.put("product_script", product_script);
            jsonObject.put("currency_config", currency_config);
            array.put(jsonObject);
            out.print(array.toString());
        } catch (Exception e) {
            out.print(e);
        } finally {
            try {
                if (pstmt != null) pstmt.close();
            } catch (Exception ignore) {
            }

            if (conn != null) {
                cp.free(conn);
            }

        }
    }
%>


<%!
     public String fixTurkishCharacters(String input) {
        if (input == null) {
            return null;
        }
        String s = input;
        s = s.replace("Ã„Â±", "ı");
        s = s.replace("Ã„Â°", "İ");
        s = s.replace("Ã„ÂŸ", "ğ");
        s = s.replace("Ã„Âž", "Ğ");
        s = s.replace("Ã…ÅŸ", "ş");
        s = s.replace("Å\u009F", "ş");
        s = s.replace("Ã…Åž", "Ş");
        s = s.replace("Å\u009E", "Ş");
        s = s.replace("ÃƒÂ¼", "ü");
        s = s.replace("ÃƒÂ–", "Ö");
        s = s.replace("ÃƒÂœ", "Ü");
        s = s.replace("Ãœ", "Ü");
        s = s.replace("ÃƒÂ§", "ç");
        s = s.replace("Ãƒâ€¹", "Ç");
        s = s.replace("Ã\\u2021", "Ç");
        s = s.replace("ÃƒÂ¶", "ö");
        s = s.replace("Ä±", "ı");
        s = s.replace("Ä°", "İ");
        s = s.replace("ÄŸ", "ğ");
        s = s.replace("Äž", "Ğ");
        s = s.replace("ÅŸ", "ş");
        s = s.replace("Åž", "Ş");
        s = s.replace("Ã¼", "ü");
        s = s.replace("Ãœ", "Ü");
        s = s.replace("Ã§", "ç");
        s = s.replace("ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã¶", "ö");
        s = s.replace("Ã–", "Ö");
        s = s.replace("Ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã\u0087", "Ç");
        s = s.replace("Ã„ÂŸ", "ğ");
        s = s.replace("Ä\u009F", "ğ");
        s = s.replace("Ã„Âž", "Ğ");
        s = s.replace("Ä\u009E", "Ğ");
        s = s.replace("Ã…ÅŸ", "ş");
        s = s.replace("Ã…Åž", "Ş");
        s = s.replace("ÃƒÂ¼", "ü");
        s = s.replace("ã¼", "ü");
        s = s.replace("ÃƒÂœ", "Ü");
        s = s.replace("Ã\u009C", "Ü");
        s = s.replace("ÃƒÂ¶", "ö");
        s = s.replace("ÃƒÂ–", "Ö");
        s = s.replace("Ã„Â±", "ı");
        s = s.replace("Ã„Â°", "İ");
        // Bozuk yer tutucu karakter (replacement char)
        s = s.replace("�", "ö"); // ! Dikkat: hangi harfe denk geldiğine göre ayarlayın
        // Diğer sık gözüken ikili bozulmalar
        s = s.replace("Â±", "ı");
        s = s.replace("Â§", "Ş");
        s = s.replace("Âş", "ş");
        return s;
    }
%>





