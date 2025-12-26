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
        PreparedStatement   ps = null;
        ResultSet   rs = null;

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
        Integer recoId = null;

        if(cust_id == null || camp_id == null || campName == null)
            return;

        CampConfig campConfig = new CampConfig(campName,  campTitle,  productScript,  addToCartScript,  currencyConfig,  camp_type,  fallback_camp_type,
                 template_id,  status,  productsNumBlock,  containerSize,  rcpLink,  cartAddToCart,  filterId,  appendUTM,  excludeRecentlyViewed,
                 excludeRecentlyPurchased);


        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        // 1️⃣ Kayıt var mı kontrol et
        String checkSql = "SELECT id FROM c_recommendation_config WHERE cust_id = ? AND camp_id = ?";
        ps = conn.prepareStatement(checkSql);
        ps.setLong(1, Long.parseLong(cust_id));
        ps.setString(2, camp_id);
        rs = ps.executeQuery();

        boolean exists = rs.next();
        rs.close();
        ps.close();

        if (!exists) {
            // 2️⃣ INSERT
            String insertSql =
                    "INSERT INTO c_recommendation_config (" +
                            "cust_id, camp_id, camp_name, camp_title, camp_type, fallback_camp_type, template_id, status, " +
                            "products_num_block, container_size, rcp_link, currency_config, camp_add_to_cart, add_to_cart_script, " +
                            "product_script, filter_id, append_utm, exclude_recently_viewed, exclude_recently_purchased, create_date, modify_date" +
                            ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,GETDATE(),GETDATE())";

            ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            int i = 1;
            ps.setLong(i++, Long.parseLong(cust_id));
            ps.setString(i++, camp_id);
            i = setCommonParameters(ps, i,campConfig);

            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                recoId = keys.getInt(1);
            }
            keys.close();
        } else {
            // 3️⃣ UPDATE
            String updateSql =
                    "UPDATE c_recommendation_config SET " +
                            "camp_name=?, camp_title=?, camp_type=?, fallback_camp_type=?, template_id=?, status=?, " +
                            "products_num_block=?, container_size=?, rcp_link=?, currency_config=?, camp_add_to_cart=?, " +
                            "add_to_cart_script=?, product_script=?, filter_id=?, append_utm=?, exclude_recently_viewed=?, " +
                            "exclude_recently_purchased=?, modify_date=GETDATE() " +
                            "WHERE cust_id=? AND camp_id=?";

            ps = conn.prepareStatement(updateSql);
            int i = 1;
            i = setCommonParameters(ps, i,campConfig);
            ps.setLong(i++, Long.parseLong(cust_id));
            ps.setString(i++, camp_id);

            ps.executeUpdate();
            recoId = Integer.parseInt(camp_id);
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

            out.print("200 - RecoId: "+recoId);
        } catch(Exception e){
            System.out.println("CustID :"+cust_id+"->Save recommendation config error :"+e);
            throw e;
        }
        finally{

            try { if ( ps != null ) ps.close(); }
            catch (Exception ignore) { }

            if ( conn != null ) {
                cp.free(conn);
            }

        }

%>
<%!

    private int setCommonParameters(PreparedStatement ps, int i, CampConfig config) throws SQLException {
        ps.setString(i++, config.campName);
        ps.setString(i++, config.campTitle);
        ps.setString(i++,config.camp_type);
        ps.setString(i++, config.fallback_camp_type);
        ps.setLong(i++, Long.parseLong(config.template_id));
        ps.setLong(i++, Long.parseLong(config.status));
        ps.setLong(i++, Long.parseLong(config.productsNumBlock == null || config.productsNumBlock.trim().isEmpty() ? "0" : config.productsNumBlock));
        ps.setLong(i++, Long.parseLong(config.containerSize));
        ps.setString(i++, config.rcpLink);
        ps.setString(i++, config.currencyConfig);
        ps.setString(i++, config.cartAddToCart);
        ps.setString(i++, config.addToCartScript);
        ps.setString(i++, config.productScript);
        ps.setLong(i++, Long.parseLong(config.filterId));
        ps.setLong(i++, Long.parseLong(config.appendUTM));
        ps.setLong(i++, Long.parseLong(config.excludeRecentlyViewed));
        ps.setLong(i++, Long.parseLong(config.excludeRecentlyPurchased));
        return i;
    }


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
<%!
    public class CampConfig {
        public String campName;
        public String campTitle;
        public String productScript;
        public String addToCartScript;
        public String currencyConfig;
        public String camp_type;
        public String fallback_camp_type;
        public String template_id;
        public String status;
        public String productsNumBlock;
        public String containerSize;
        public String rcpLink;
        public String cartAddToCart;
        public String filterId;
        public String appendUTM;
        public String excludeRecentlyViewed;
        public String excludeRecentlyPurchased;

        public CampConfig(String campName, String campTitle, String productScript, String addToCartScript, String currencyConfig, String camp_type, String fallback_camp_type, String template_id, String status, String productsNumBlock, String containerSize, String rcpLink, String cartAddToCart, String filterId, String appendUTM, String excludeRecentlyViewed, String excludeRecentlyPurchased) {
            this.campName = campName;
            this.campTitle = campTitle;
            this.productScript = productScript;
            this.addToCartScript = addToCartScript;
            this.currencyConfig = currencyConfig;
            this.camp_type = camp_type;
            this.fallback_camp_type = fallback_camp_type;
            this.template_id = template_id;
            this.status = status;
            this.productsNumBlock = productsNumBlock;
            this.containerSize = containerSize;
            this.rcpLink = rcpLink;
            this.cartAddToCart = cartAddToCart;
            this.filterId = filterId;
            this.appendUTM = appendUTM;
            this.excludeRecentlyViewed = excludeRecentlyViewed;
            this.excludeRecentlyPurchased = excludeRecentlyPurchased;
        }
    }
%>