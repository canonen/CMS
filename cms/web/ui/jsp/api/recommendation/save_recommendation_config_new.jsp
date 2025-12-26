<%@  page language="java"
          import="java.net.*,
            com.britemoon.*,
            com.britemoon.cps.*, 
			java.sql.*,
			java.io.*,
			org.json.JSONObject,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
          contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%!
    private static final Logger log = Logger.getLogger("save_recommendation_config_new.jsp");
%>
<%

        String cust_id = request.getParameter("cust_id");
        String camp_id = request.getParameter("camp_id");
        String camp_type = request.getParameter("camp_type");
        String fallback_camp_type = request.getParameter("fallback_camp_type");
        String template_id = request.getParameter("template_id");
        String status = request.getParameter("status");
        String productsNumBlock = request.getParameter("products_num_block");
        String containerSize = request.getParameter("container_size");
        String rcpLink = request.getParameter("rcp_link");
        String cartAddToCart = request.getParameter("camp_add_to_cart");
        String filterId = request.getParameter("filter_id");
        String appendUTM = request.getParameter("append_utm");
        String excludeRecentlyViewed = request.getParameter("exclude_recently_viewed");
        String excludeRecentlyPurchased = request.getParameter("exclude_recently_purchased");

        // {"config_param":{"camp_name":"Buy Also","camp_title":"Kasa Önü Fırsatları","add_to_cart_script":"0","product_script":"...","currency_config":"..."}}
        String campName =  null;
        String campTitle = null;
        String productScript =  null;
        String addToCartScript= null;
        String currencyConfig= null;
        ConnectionPool cp = null;
        Connection conn = null;
        PreparedStatement	pstmt = null;
        ResultSet	rs = null;




    try {
        StringBuilder sb = new StringBuilder();
        String line;
        try {
            BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            String body = sb.toString();
            JSONObject requestBody = new JSONObject(body); // tüm gelen body
            JSONObject configBody = requestBody.getJSONObject("config_param");

            campName = fixTurkishCharacters(configBody.optString("camp_name", ""));
            campTitle = fixTurkishCharacters(configBody.optString("camp_title", ""));
            productScript = fixTurkishCharacters(configBody.optString("product_script", ""));
            addToCartScript = fixTurkishCharacters(configBody.optString("add_to_cart_script", ""));
            currencyConfig  = fixTurkishCharacters(configBody.optString("currency_config", ""));
        } catch (Exception e) {
            out.println("JSON body parse hatası: " + e.getMessage());
        }

        if (productScript.length()>8000|| addToCartScript.length()>500|| currencyConfig.length()>8000){
            out.print("Body deki karakter sayilari cok fazla. DB yi kontrol ediniz: productScript.length()>4000|| addToCartScript.length()>500|| currencyConfig.length()>5000 ");
        }


        if(filterId==null) {
            filterId = "0";
        }
        if(appendUTM==null) {
            appendUTM = "1";
        }

        if(excludeRecentlyViewed==null) {
            excludeRecentlyViewed = "0";
        }

        if(excludeRecentlyPurchased==null) {
            excludeRecentlyPurchased = "0";
        }

        String recoConfigCampId = null;
        Integer recoConfigId = null;
        Integer recoId = null;

        if(cust_id == null || camp_id == null || campName == null)
            return;



            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);

            String sql = "IF (NOT EXISTS(SELECT id FROM c_recommendation_config WHERE cust_id = ? and camp_id = ?)) " +
                    "BEGIN " +
                    "INSERT INTO c_recommendation_config (cust_id,camp_id,camp_name,camp_title,camp_type,fallback_camp_type,template_id,status,products_num_block,container_size,rcp_link,currency_config,camp_add_to_cart,add_to_cart_script,product_script,filter_id,append_utm,exclude_recently_viewed,exclude_recently_purchased,create_date,modify_date)  OUTPUT inserted.id AS newId  VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,getdate(),getdate())" +
                    "END " +
                    "ELSE " +
                    "BEGIN " +
                    "UPDATE c_recommendation_config SET camp_name = ?, camp_title = ?, camp_type = ?, fallback_camp_type = ?, template_id = ?, status = ?, products_num_block = ?, container_size = ?, rcp_link = ?, currency_config = ?, camp_add_to_cart = ?, add_to_cart_script = ?, product_script = ?, filter_id = ?, append_utm = ?, exclude_recently_viewed = ?, exclude_recently_purchased = ?, modify_date = getdate()   OUTPUT inserted.id AS newId  WHERE cust_id = ? and camp_id = ? " +
                    "END ";


            pstmt = conn.prepareStatement(sql);
            int x=1;

            pstmt.setLong(x++,Long.parseLong(cust_id));
            pstmt.setString(x++,camp_id);

            pstmt.setLong(x++,Long.parseLong(cust_id));
            pstmt.setString(x++,camp_id);
            pstmt.setString(x++,campName);
            pstmt.setString(x++,campTitle);
            pstmt.setString(x++,camp_type);
            pstmt.setString(x++,fallback_camp_type);
            pstmt.setLong(x++,Long.parseLong(template_id));
            pstmt.setLong(x++,Long.parseLong(status));
            pstmt.setLong(x++,Long.parseLong(productsNumBlock==null||productsNumBlock.trim().isEmpty()? "0": productsNumBlock ));
            pstmt.setLong(x++,Long.parseLong(containerSize));
            pstmt.setString(x++,rcpLink);
            pstmt.setString(x++,currencyConfig);
            pstmt.setString(x++,cartAddToCart);
            pstmt.setString(x++,addToCartScript);
            pstmt.setString(x++,productScript);
            pstmt.setLong(x++,Long.parseLong(filterId));
            pstmt.setLong(x++,Long.parseLong(appendUTM));
            pstmt.setLong(x++,Long.parseLong(excludeRecentlyViewed));
            pstmt.setLong(x++,Long.parseLong(excludeRecentlyPurchased));

            pstmt.setString(x++,campName);
            pstmt.setString(x++,campTitle);
            pstmt.setString(x++,camp_type);
            pstmt.setString(x++,fallback_camp_type);
            pstmt.setLong(x++,Long.parseLong(template_id));
            pstmt.setLong(x++,Long.parseLong(status));
            pstmt.setLong(x++,Long.parseLong(productsNumBlock==null||productsNumBlock.trim().isEmpty()? "0": productsNumBlock ));
            pstmt.setLong(x++,Long.parseLong(containerSize));
            pstmt.setString(x++,rcpLink);
            pstmt.setString(x++,currencyConfig);
            pstmt.setString(x++,cartAddToCart);
            pstmt.setString(x++,addToCartScript);
            pstmt.setString(x++,productScript);
            pstmt.setLong(x++,Long.parseLong(filterId));
            pstmt.setLong(x++,Long.parseLong(appendUTM));
            pstmt.setLong(x++,Long.parseLong(excludeRecentlyViewed));
            pstmt.setLong(x++,Long.parseLong(excludeRecentlyPurchased));
            recoConfigCampId = camp_id;

            pstmt.setLong(x++,Long.parseLong(cust_id));
            pstmt.setString(x++,camp_id);

            boolean hasResult = pstmt.execute();

            if (hasResult) {
                try {
                    ResultSet rs1 = pstmt.getResultSet();
                    if (rs1.next()) {
                        recoId = rs1.getInt("newId");
                    }
                    rs1.close();
                } catch (Exception e){
                    log.error("Error while getting returned ID", e);
                }

            }

//            int recoEditId = -1;
//            if(recoId != null && recoId != 0){
//                String sqlhistory = "SELECT recommendation_id FROM c_recommendation_edit_info WHERE recommendation_id = ?";
//                pstmt = conn.prepareStatement(sqlhistory);
//                pstmt.setInt(1, recoId);
//                rs = pstmt.executeQuery();
//                if (rs.next()) {
//                    recoEditId = rs.getInt(1);
//                }
//                pstmt.close();
//                rs.close();
//                if(recoEditId == -1){
//                    String insertSql = "INSERT INTO c_recommendation_edit_info " +
//                            "(recommendation_id,camp_id,creator_id,create_date) " +
//                            "VALUES (?,?,?,getdate())";
//                    pstmt = conn.prepareStatement(insertSql);
//                    pstmt.setInt(1, recoId);
//                    pstmt.setString(2, recoConfigCampId);
//                    pstmt.setInt(3, Integer.parseInt(user.s_user_id));
//                    pstmt.executeUpdate();
//                    pstmt.close();
//                    rs.close();
//                }else {
//                    String updateSql = "UPDATE c_recommendation_edit_info SET modify_date = getdate(), modifier_id = ? WHERE recommendation_id = ? AND camp_id = ?";
//                    pstmt = conn.prepareStatement(updateSql);
//                    pstmt.setInt(1, Integer.parseInt(user.s_user_id));
//                    pstmt.setInt(2, recoEditId);
//                    pstmt.setString(3, recoConfigCampId);
//                    pstmt.executeUpdate();
//                    pstmt.close();
//                    rs.close();
//                }
//
//            }

            out.print("200");
        } catch(Exception e){
            System.out.println("CustID :"+cust_id+"->Save recommendation config error :"+e);
            throw e;
        }
        finally{

            try { if ( pstmt != null ) pstmt.close(); }
            catch (Exception ignore) { }

            if ( conn != null ) {
                cp.free(conn);
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
        s = s.replace("Ã…Åž", "Ş");
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
        s = s.replace("Å\\u009f", "ş");
        s = s.replace("Åž", "Ş");
        s = s.replace("Ã¼", "ü");
        s = s.replace("Ãœ", "Ü");
        s = s.replace("Ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã¶", "ö");
        s = s.replace("Ã–", "Ö");
        s = s.replace("Ã§", "ç");
        s = s.replace("Ã‡", "Ç");
        s = s.replace("Ã„ÂŸ", "ğ");
        s = s.replace("Ã„Âž", "Ğ");
        s = s.replace("Ã…ÅŸ", "ş");
        s = s.replace("Ã…Åž", "Ş");
        s = s.replace("ÃƒÂ¼", "ü");
        s = s.replace("ÃƒÂœ", "Ü");
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
        s = s.replace("Ã\u0096", "Ö");
        s = s.replace("Ã\u0087", "Ç");
        return s;
    }
%>