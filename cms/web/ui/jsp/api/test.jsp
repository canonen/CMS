<%@  page language="java"
          import="java.net.*,
            com.britemoon.*,
            com.britemoon.rcp.*,
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Date,java.io.*,
			java.util.ArrayList,
			java.math.BigDecimal,
			java.text.NumberFormat,
			org.json.JSONArray,
			org.json.JSONException,
			org.json.JSONObject,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
          contentType="text/html;charset=UTF-8"
%>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>
<%
    String cust_id = request.getParameter("cust_id");
    String type = request.getParameter("type");
    String user_id = request.getParameter("user_id");
    String limit = request.getParameter("limit");
    String product_id = request.getParameter("product_id");
    String filter_id = request.getParameter("filter_id");
    String exclude_recently_viewed = request.getParameter("exclude_recently_viewed");
    String exclude_recently_purchased = request.getParameter("exclude_recently_purchased");

    ServletInputStream sis = request.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(sis));

    String inbound = in.readLine();

    JSONObject requestBody = null;
    JSONArray excludeList = null;
    String cat_id = null;

    if(inbound != null) requestBody = new JSONObject(inbound);

    if(exclude_recently_viewed!=null && requestBody != null && requestBody.has("excludeList") && exclude_recently_viewed.equals("1")) {
        excludeList = requestBody.getJSONArray("excludeList");
    }

    if(requestBody != null && requestBody.has("categoryId")) {
        cat_id = requestBody.getString("categoryId");
    }

%>
<%
    if((cust_id == null || type == null))
        return;

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement	pstmt = null;
    ResultSet	rs = null;

    try{

        cp = ConnectionPool.getInstance(cust_id);
        conn = cp.getConnection("get_recommendation.jsp");
        String tableName = null;
        String sql = null;
        int isFilterExcluded = 0;
        int filterFound = 0;
        ArrayList<String> recentlyPurchasedList = new ArrayList<String>();

        ArrayList<String> filteredProductIdList = new ArrayList<String>();

        ArrayList<String> recentlyExcludeList = new ArrayList<String>();


        if(excludeList != null) {
            for(int k=0;k<excludeList.length();k++) {
                recentlyExcludeList.add(excludeList.getString(k));
            }
        }

        if(exclude_recently_purchased!=null && exclude_recently_purchased.equals("1")) {
            sql = "select product_id from rque_cust_order with(nolock) where userid = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,user_id);
            rs = pstmt.executeQuery();
            while(rs.next()) {
                recentlyPurchasedList.add(rs.getString(1));
            }
            rs.close();
            pstmt.close();
        }

        if(filter_id != null) {
            sql = "IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'rrcp_recommendation_filter')) ";
            sql += "begin ";
            sql += "select filter_id from rrcp_recommendation_filter with(nolock) where filter_id = ? and status_id not in(30,900) ";
            sql += "end ";
            sql += "else begin select 0 end";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1,Long.parseLong(filter_id));
            rs = pstmt.executeQuery();
            if(rs.next()) {
                String result = rs.getString(1);
                if(result.equals("0"))filterFound = 0;
                else filterFound = 1;
            }
            rs.close();
            pstmt.close();

            if(filterFound == 1) {
                sql = "select product_id from rrcp_recommendation_filter_product p left join rrcp_recommendation_filter f on p.filter_id = f.filter_id where f.filter_id = ? and f.status_id not in(30,900)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setLong(1,Long.parseLong(filter_id));
                rs = pstmt.executeQuery();
                while(rs.next()) {
                    filteredProductIdList.add(rs.getString(1));
                }
                rs.close();
                pstmt.close();

                sql = "select is_excluded from rrcp_recommendation_formula_group with(nolock) where filter_id = ? and parent_group_id is null";
                pstmt = conn.prepareStatement(sql);
                pstmt.setLong(1,Long.parseLong(filter_id));
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    isFilterExcluded = rs.getInt(1);
                }
                rs.close();
                pstmt.close();
            }
        }

        if(type.equals("50")) {
            if(cat_id != null) {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, product_id from z_product_topseller with(nolock) where cat_id = ? ";
            } else {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, product_id from z_product_topseller with(nolock) ";

            }
            if(filterFound == 1) {
                sql += (cat_id != null ? "and " : "where ") + "product_id " + (isFilterExcluded == 1 ? "not" : "") + " in (0";
                for(int k = 0; k < filteredProductIdList.size(); k++) {
                    sql+=",";
                    sql+="'" + filteredProductIdList.get(k) + "'";
                }
                sql += ")";
            }
            if(excludeList != null) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " product_id not in (";
                for(int k=0; k < excludeList.length(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + excludeList.getString(k) + "'";
                }
                sql += ")";
            }
            if(exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && recentlyPurchasedList.size()>0) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " product_id not in (";
                for(int k=0; k < recentlyPurchasedList.size(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + recentlyPurchasedList.get(k) + "'";
                }
                sql += ")";
            }

            pstmt = conn.prepareStatement(sql);
            if(cat_id != null) {
                pstmt.setString(1, cat_id);
            }
        }
        else if(type.equals("60")) {
            if(cat_id != null) {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, product_id from z_product_pricedrop with(nolock) where cat_id = ? ";
            } else {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, product_id from z_product_pricedrop with(nolock) ";
            }
            if(filterFound == 1) {
                sql += (cat_id != null ? "and " : "where ") + "product_id " + (isFilterExcluded == 1 ? "not" : "") + " in (0";
                for(int k = 0; k < filteredProductIdList.size(); k++) {
                    sql+=",";
                    sql+="'" + filteredProductIdList.get(k) + "'";
                }
                sql += ")";
            }
            if(excludeList != null) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " product_id not in (";
                for(int k=0; k < excludeList.length(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + excludeList.getString(k) + "'";
                }
                sql += ")";
            }
            if(exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && recentlyPurchasedList.size()>0) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " product_id not in (";
                for(int k=0; k < recentlyPurchasedList.size(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + recentlyPurchasedList.get(k) + "'";
                }
                sql += ")";
            }
            pstmt = conn.prepareStatement(sql);
            if(cat_id != null) {
                pstmt.setString(1,cat_id);
            }
        }
        else if(type.equals("70")) {
            if(cat_id != null) {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, product_id from z_product_new with(nolock) where cat_id = ? ";
            } else {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, product_id from z_product_new with(nolock) ";
            }
            if(filterFound == 1) {
                sql += (cat_id != null ? "and " : "where ") + "product_id " + (isFilterExcluded == 1 ? "not" : "") + " in (0";
                for(int k = 0; k < filteredProductIdList.size(); k++) {
                    sql+=",";
                    sql+="'" + filteredProductIdList.get(k) + "'";
                }
                sql += ")";
            }
            if(excludeList != null) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " product_id not in (";
                for(int k=0; k < excludeList.length(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + excludeList.getString(k) + "'";
                }
                sql += ")";
            }
            if(exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && recentlyPurchasedList.size()>0) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " product_id not in (";
                for(int k=0; k < recentlyPurchasedList.size(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + recentlyPurchasedList.get(k) + "'";
                }
                sql += ")";
            }

            pstmt = conn.prepareStatement(sql);

            if(cat_id != null) {
                pstmt.setString(1,cat_id);
            }
        }
        else if(type.equals("80")) {
            sql = "select top " + (limit != null ? limit : "10") + " json_data, product_id from z_product_back_in_stock with(nolock) ";
        }
        else if(type.equals("90")) {
            if(product_id != null) {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, rec_product_id from z_product_buy_also with(nolock) where product_id = ? ";
            } else {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, rec_product_id from z_product_buy_also with(nolock) ";
            }
            if(filterFound == 1) {
                sql += (product_id != null ? "and " : "where ") + "rec_product_id " + (isFilterExcluded == 1 ? "not" : "") + " in (0";
                for(int k = 0; k < filteredProductIdList.size(); k++) {
                    sql+=",";
                    sql+="'" + filteredProductIdList.get(k) + "'";
                }
                sql += ")";
            }
            if(excludeList != null) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " rec_product_id not in (";
                for(int k=0; k < excludeList.length(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + excludeList.getString(k) + "'";
                }
                sql += ")";
            }
            if(exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && recentlyPurchasedList.size()>0) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " rec_product_id not in (";
                for(int k=0; k < recentlyPurchasedList.size(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + recentlyPurchasedList.get(k) + "'";
                }
                sql += ")";
            }
            pstmt = conn.prepareStatement(sql);
            if(product_id != null) {
                pstmt.setString(1,product_id);
            }
        }
        else if(type.equals("100")) {
            sql = "select json_data, product_id from z_product_similar with(nolock) where product_id = ? ";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,product_id);
        }
        else if(type.equals("110")) {
            if(user_id != null && cat_id != null) {
                sql = "select json_data from z_product_you_might with(nolock) where user_id = ? and category_id = ? ";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1,user_id);
                pstmt.setString(2,cat_id);
            }
            else if(user_id != null) {
                sql = "select json_data from z_product_you_might with(nolock) where user_id = ? ";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1,user_id);
            }
        }
        else if(type.equals("120")) {
            if(product_id != null) {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, rec_product_id from z_product_view_also with(nolock) where product_id = ? ";
            } else {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, rec_product_id from z_product_view_also with(nolock) ";
            }
            if(filterFound == 1) {
                sql += (product_id != null ? "and " : "where ") + "rec_product_id " + (isFilterExcluded == 1 ? "not" : "") + " in (0";
                for(int k = 0; k < filteredProductIdList.size(); k++) {
                    sql+=",";
                    sql+="'" + filteredProductIdList.get(k) + "'";
                }
                sql += ")";
            }
            if(excludeList != null) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " rec_product_id not in (";
                for(int k=0; k < excludeList.length(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + excludeList.getString(k) + "'";
                }
                sql += ")";
            }
            if(exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && recentlyPurchasedList.size()>0) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " rec_product_id not in (";
                for(int k=0; k < recentlyPurchasedList.size(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + recentlyPurchasedList.get(k) + "'";
                }
                sql += ")";
            }
            pstmt = conn.prepareStatement(sql);
            if(product_id != null) {
                pstmt.setString(1,product_id);
            }
        }
        else if(type.equals("140")) {
            System.out.println("140 ICINDEYIM");
            StringBuilder sqlBuilder = new StringBuilder("select top ");
            sqlBuilder.append(limit != null ? limit : "10");
            sqlBuilder.append(" json_data, product_id from z_product_trending with(nolock) ");

            if (cat_id != null) {
                sqlBuilder.append("where cat_id = ?");
            }

            if (filterFound == 1) {
                if (cat_id != null) {
                    sqlBuilder.append(" and ");
                    System.out.println("AND ICI");
                } else {
                    sqlBuilder.append(" where ");
                    System.out.println("WHERE ICI");
                }
                sqlBuilder.append("product_id ").append(isFilterExcluded == 1 ? "not" : "").append(" in (");
                for (int k = 0; k < filteredProductIdList.size(); k++) {
                    System.out.println("FOR ICI");
                    if (k != 0) sqlBuilder.append(",");
                    sqlBuilder.append("'").append(filteredProductIdList.get(k)).append("'");
                }
                sqlBuilder.append(")");
            }

            if (excludeList != null) {
                System.out.println("EXCLUDE LIST ICI");
                if (sqlBuilder.toString().toLowerCase().contains("where")) {
                    sqlBuilder.append(" and ");
                } else {
                    sqlBuilder.append(" where ");
                }
                sqlBuilder.append("product_id not in (");
                for (int k = 0; k < excludeList.length(); k++) {
                    System.out.println("FOR EXCLUDE LIST");
                    if (k != 0) sqlBuilder.append(",");
                    sqlBuilder.append("'").append(excludeList.getString(k)).append("'");
                }
                sqlBuilder.append(")");
            }

            if (exclude_recently_purchased != null && exclude_recently_purchased.equals("1") && recentlyPurchasedList.size() > 0) {
                if (sqlBuilder.toString().toLowerCase().contains("where")) {
                    sqlBuilder.append(" and ");
                } else {
                    sqlBuilder.append(" where ");
                }
                sqlBuilder.append("product_id not in (");
                for (int k = 0; k < recentlyPurchasedList.size(); k++) {
                    if (k != 0) sqlBuilder.append(",");
                    sqlBuilder.append("'").append(recentlyPurchasedList.get(k)).append("'");
                }
                sqlBuilder.append(")");
            }

            sql = sqlBuilder.toString();
            System.out.println("SQL Query: " + sql);
            pstmt = conn.prepareStatement(sql);

            if (cat_id != null) {
                pstmt.setString(1, cat_id);
            }
        }


        else if(type.equals("150")) {
            if(product_id != null) {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, rec_product_id from z_product_bought_together with(nolock) where product_id = ? ";
            } else {
                sql = "select top " + (limit != null ? limit : "10") + " json_data, rec_product_id from z_product_bought_together with(nolock) ";
            }
            if(filterFound == 1) {
                sql += (product_id != null ? "and " : "where ") + "rec_product_id " + (isFilterExcluded == 1 ? "not" : "") + " in (0";
                for(int k = 0; k < filteredProductIdList.size(); k++) {
                    sql+=",";
                    sql+="'" + filteredProductIdList.get(k) + "'";
                }
                sql += ")";
            }
            if(excludeList != null) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " rec_product_id not in (";
                for(int k=0; k < excludeList.length(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + excludeList.getString(k) + "'";
                }
                sql += ")";
            }
            if(exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && recentlyPurchasedList.size()>0) {
                if(sql.toLowerCase().contains("where"))sql+=" and ";
                else sql+=" where ";
                sql += " rec_product_id not in (";
                for(int k=0; k < recentlyPurchasedList.size(); k++) {
                    if(k!=0)sql+=",";
                    sql+="'" + recentlyPurchasedList.get(k) + "'";
                }
                sql += ")";
            }
            pstmt = conn.prepareStatement(sql);
            if(product_id != null) {
                pstmt.setString(1,product_id);
            }
        }

        rs = pstmt.executeQuery();

        StringBuilder jsonSb = new StringBuilder();
        jsonSb.append("[");

        int i = 0;

        if(type.equals("110")) {
            if(limit==null)limit="10";
            JSONArray youMightProducts = new JSONArray();
            int counter = 0;

            while(rs.next()) {
                String jsonDataUtf8 = new String(rs.getBytes(1), "UTF-8");

                JSONArray tempArray = new JSONArray(jsonDataUtf8);

                for(int j=0;j<tempArray.length();j++) {
                    JSONArray youMightObjectHolder = new JSONArray();
                    JSONObject youMightObject = tempArray.getJSONObject(j);
                    youMightObjectHolder.put(youMightObject);
                    String productId = youMightObject.getString("p_id");
                    if(limit!=null && Integer.parseInt(limit)<=counter) {
                        break;
                    }
                    if(
                            (
                                    ((filter_id != null && filterFound == 1 && ((isFilterExcluded==1 && !filteredProductIdList.contains(productId)) || (isFilterExcluded==0 && filteredProductIdList.contains(productId)))) || (filter_id == null || filterFound == 0))
                                            &&
                                            ((exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && !recentlyPurchasedList.contains(productId)) || exclude_recently_purchased==null || exclude_recently_purchased.equals("0"))
                                            &&
                                            ((excludeList != null && !recentlyExcludeList.contains(productId)) || excludeList==null)
                            )
                    )
                    {
                        youMightProducts.put(youMightObjectHolder);
                        counter++;
                    }
                }
            }
            rs.close();
            pstmt.close();
            out.println(youMightProducts);
        } else if(type.equals("100")) {
            if(limit==null)limit="10";
            JSONArray similarProducts = new JSONArray();
            int counter = 0;
            while(rs.next()) {
                String jsonDataUtf8 = new String(rs.getBytes(1), "UTF-8");

                JSONArray tempArray = new JSONArray(jsonDataUtf8);
                for(int j=0;j<tempArray.length();j++) {
                    JSONObject similarObject = tempArray.getJSONObject(j);
                    String productId = similarObject.getString("p_id");
                    if(limit!=null && Integer.parseInt(limit)<=counter) {
                        break;
                    }
                    if(
                            (
                                    ((filter_id != null && filterFound == 1 && ((isFilterExcluded==1 && !filteredProductIdList.contains(productId)) || (isFilterExcluded==0 && filteredProductIdList.contains(productId)))) || (filter_id == null || filterFound == 0))
                                            &&
                                            ((exclude_recently_purchased!=null && exclude_recently_purchased.equals("1") && !recentlyPurchasedList.contains(productId)) || exclude_recently_purchased==null || exclude_recently_purchased.equals("0"))
                                            &&
                                            ((excludeList != null && !recentlyExcludeList.contains(productId)) || excludeList==null)
                            )
                    )
                    {
                        similarProducts.put(similarObject);
                        counter++;
                    }
                }
            }
            rs.close();
            pstmt.close();
            out.println(similarProducts);
        } else {

            while(rs.next()) {
                String jsonDataUtf8 = new String(rs.getBytes(1), "UTF-8");
                String productId = rs.getString(2);
                if(i!=0)jsonSb.append(",");
                jsonSb.append(jsonDataUtf8);
                i++;
            }

            jsonSb.append("]");
            rs.close();
            pstmt.close();

            out.println(jsonSb);

        }



    }
    catch(Exception e){
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