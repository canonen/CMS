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
   java.lang.Math.*,
   org.w3c.dom.*,
   org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="org.xml.sax.InputSource" %>

<%@ page import="com.britemoon.cps.imc.Service" %>

<%!
    public class ProductListReport{

        public String product_status 		  = null;
        public String product_name	          = null;
        public String link	                  = null;
        public String image_link	          = null;
        public String product_id	          = null;
        public String product_price	          = null;
        public String product_sales_price	  = null;
        public String top_category_id	      = null;
        public String category_id_2	          = null;
        public String sku_code	              = null;
        public String stock_status	          = null;
        public String stock_count	          = null;

        public ProductListReport(Element element){
            product_status 		  =  Deger(element.getElementsByTagName("product_status")).equals("null") ? null : Deger(element.getElementsByTagName("product_status"));
            product_name	      =  Deger(element.getElementsByTagName("product_name")).equals("null") ? null : Deger(element.getElementsByTagName("product_name"));
            link	              =  Deger(element.getElementsByTagName("link")).equals("null") ? null : Deger(element.getElementsByTagName("link"));
            image_link	          =  Deger(element.getElementsByTagName("image_link")).equals("null") ? null : Deger(element.getElementsByTagName("image_link"));
            product_id	          =  Deger(element.getElementsByTagName("product_id")).equals("null") ? null : Deger(element.getElementsByTagName("product_id"));
            product_price	      =  Deger(element.getElementsByTagName("product_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_price"));
            product_sales_price	  =  Deger(element.getElementsByTagName("product_sales_price")).equals("null") ? null : Deger(element.getElementsByTagName("product_sales_price"));
            top_category_id	  =  Deger(element.getElementsByTagName("top_category_id")).equals("null") ? null : Deger(element.getElementsByTagName("top_category_id"));
            category_id_2	  =  Deger(element.getElementsByTagName("category_id_2")).equals("null") ? null : Deger(element.getElementsByTagName("category_id_2"));
            sku_code	  =  Deger(element.getElementsByTagName("sku_code")).equals("null") ? null : Deger(element.getElementsByTagName("sku_code"));
            stock_status	  =  Deger(element.getElementsByTagName("stock_status")).equals("null") ? null : Deger(element.getElementsByTagName("stock_status"));
            stock_count	  =  Deger(element.getElementsByTagName("stock_count")).equals("null") ? null : Deger(element.getElementsByTagName("stock_count"));
        }

        public String Deger(NodeList g1) {
            JsonObject json = new JsonObject();

            if (g1.getLength() > 0) {
                Element g1_Element = (Element) g1.item(0);
                NodeList text_g1 = g1_Element.getChildNodes();
                if (text_g1.item(0) != null) {
                    String deger = ((Node) text_g1.item(0)).getNodeValue().trim();
                    json.put("", deger);
                }
            }

            return json.toString();
        }
    }
%>

<%!
    private boolean matchesFilter(ProductListReport report, Map<String, String> filters) {
        for (String key : filters.keySet()) {
            String filterValue = filters.get(key);
            if (filterValue == null || filterValue.trim().isEmpty()) {
                continue;
            }

            String fieldValue = getFieldValue(report, key);
            if (fieldValue == null) {
                return false;
            }

            fieldValue = fieldValue.replace("{\"\":\"", "").replace("\"}", "");

            if (!fieldValue.toLowerCase().contains(filterValue.toLowerCase())) {
                return false;
            }
        }
        return true;
    }

    private String getFieldValue(ProductListReport report, String fieldName) {
        if ("product_name".equals(fieldName)) {
            return report.product_name;
        } else if ("product_id".equals(fieldName)) {
            return report.product_id;
        } else if ("product_status".equals(fieldName)) {
            return report.product_status;
        } else if ("product_price".equals(fieldName)) {
            return report.product_price;
        } else if ("product_sales_price".equals(fieldName)) {
            return report.product_sales_price;
        } else if ("top_category_id".equals(fieldName)) {
            return report.top_category_id;
        } else if ("category_id_2".equals(fieldName)) {
            return report.category_id_2;
        } else if ("sku_code".equals(fieldName)) {
            return report.sku_code;
        } else if ("stock_status".equals(fieldName)) {
            return report.stock_status;
        } else if ("stock_count".equals(fieldName)) {
            return report.stock_count;
        } else if ("link".equals(fieldName)) {
            return report.link;
        } else if ("image_link".equals(fieldName)) {
            return report.image_link;
        } else {
            return null;
        }
    }

    private boolean isStringField(String fieldName) {
        return fieldName.equals("product_name") ||
                fieldName.equals("sku_code") ||
                fieldName.equals("link") ||
                fieldName.equals("image_link") ||
                fieldName.equals("top_category_id") ||
                fieldName.equals("category_id_2");
    }

    private JsonObject processProduct(Element element) {
        JsonObject productObject = new JsonObject();
        ProductListReport report = new ProductListReport(element);

        String link = report.link;
        link = link.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("link", fixTurkishCharacters(link));

        String image_link = report.image_link;
        image_link = image_link.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("image_link", fixTurkishCharacters(image_link));

        String product_name = report.product_name;
        product_name = product_name.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("product_name", fixTurkishCharacters(product_name));

        String product_id = report.product_id;
        product_id = product_id.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("product_id", product_id);

        String product_status = report.product_status;
        product_status = product_status.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("product_status", product_status);

        String product_price = report.product_price;
        product_price = product_price.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("product_price", product_price);

        String product_sales_price = report.product_sales_price;
        if(product_sales_price != null && !product_sales_price.isEmpty() && !product_sales_price.equals("{}")) {
            product_sales_price = product_sales_price.replace("{\"\":\"", "").replace("\"}", "");
        } else {
            product_sales_price = "";
        }
        productObject.put("product_sales_price", product_sales_price);

        String top_category_id = report.top_category_id;
        top_category_id = top_category_id.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("top_category_id", fixTurkishCharacters(top_category_id));

        String category_id_2 = report.category_id_2;
        category_id_2 = category_id_2.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("category_id_2", fixTurkishCharacters(category_id_2));

        String sku_code = report.sku_code;
        sku_code = sku_code.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("sku_code", fixTurkishCharacters(sku_code));

        String stock_status = report.stock_status;
        stock_status = stock_status.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("stock_status", stock_status);

        String stock_count = report.stock_count;
        stock_count = stock_count.replace("{\"\":\"", "").replace("\"}", "");
        productObject.put("stock_count", stock_count);

        return productObject;
    }
%>

<%!
    public String fixTurkishCharacters(String input) {
        if (input == null || input.isEmpty()) {
            return input;
        }

        if (!hasBrokenCharacters(input)) {
            return input;
        }

        try {
            byte[] bytes = input.getBytes("ISO-8859-1");
            String corrected = new String(bytes, "UTF-8");

            corrected = corrected
                    .replaceAll("Ä±", "ı")
                    .replaceAll("Ã„Â±", "ı")
                    .replaceAll("Â±", "ı")

                    .replaceAll("ÄŸ", "ğ")
                    .replaceAll("Ã„ÂŸ", "ğ")

                    .replaceAll("ÅŸ", "ş")
                    .replaceAll("Ã…ÅŸ", "ş")
                    .replaceAll("Âş", "ş")

                    .replaceAll("Ã¼", "ü")
                    .replaceAll("ÃƒÂ¼", "ü")

                    .replaceAll("Ã¶", "ö")
                    .replaceAll("ÃƒÂ¶", "ö")
                    .replaceAll("�", "ö")

                    .replaceAll("Ã§", "ç")
                    .replaceAll("ÃƒÂ§", "ç")

                    .replaceAll("Ä°", "İ")
                    .replaceAll("Ã„Â°", "İ")

                    .replaceAll("Äž", "Ğ")
                    .replaceAll("Ã„Âž", "Ğ")

                    .replaceAll("Åž", "Ş")
                    .replaceAll("Ã…Åž", "Ş")
                    .replaceAll("Ã\\u009F", "Ş")
                    .replaceAll("Â§", "Ş")

                    .replaceAll("Ãœ", "Ü")
                    .replaceAll("ÃƒÂœ", "Ü")
                    .replaceAll("Ã\\u009C", "Ü")
                    .replaceAll("Ä\\u009E", "Ü")

                    .replaceAll("Ã–", "Ö")
                    .replaceAll("ÃƒÂ–", "Ö")
                    .replaceAll("Ã\\u0096", "Ö")

                    .replaceAll("Ã‡", "Ç")
                    .replaceAll("ÃƒÂ‡", "Ç")
                    .replaceAll("Ã\\u0087", "Ç")
                    .replaceAll("ÃƒÂ‹", "Ç")
                    .replaceAll("Ã\\u2021", "Ç");

            return corrected;

        } catch (Exception e) {
            return input;
        }
    }

    private boolean hasBrokenCharacters(String input) {
        return input.contains("Ã") ||
                input.contains("Ä") ||
                input.contains("Å") ||
                input.contains("Â") ||
                input.contains("�") ||
                input.matches(".*[ÃÄÅ][\\u0080-\\u009F].*");
    }
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>

<%
    if(logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    String pageNo = request.getParameter("page_no");
    int pageNumber = 1;
    if (pageNo != null && !pageNo.isEmpty()) {
        pageNumber = Integer.parseInt(pageNo);
    }


    Map<String, String> filters = new HashMap<String, String>();
    String a = request.getParameter("product_name");
    String b = fixTurkishCharacters(request.getParameter("product_name"));
    System.out.println("a: " + a + " - b: " + b);
    filters.put("product_name", fixTurkishCharacters(request.getParameter("product_name")));
    filters.put("product_id", fixTurkishCharacters(request.getParameter("product_id")));
    filters.put("product_status", fixTurkishCharacters(request.getParameter("product_status")));
    filters.put("product_price", fixTurkishCharacters(request.getParameter("product_price")));
    filters.put("product_sales_price", fixTurkishCharacters(request.getParameter("product_sales_price")));
    filters.put("top_category_id", fixTurkishCharacters(request.getParameter("top_category_id")));
    filters.put("category_id_2", fixTurkishCharacters(request.getParameter("category_id_2")));
    filters.put("sku_code", fixTurkishCharacters(request.getParameter("sku_code")));
    filters.put("stock_status", fixTurkishCharacters(request.getParameter("stock_status")));
    filters.put("stock_count", fixTurkishCharacters(request.getParameter("stock_count")));
    filters.put("link", fixTurkishCharacters(request.getParameter("link")));
    filters.put("image_link", fixTurkishCharacters(request.getParameter("image_link")));

    Statement stmt = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    StringWriter sw = new StringWriter();
    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection("report_product_lists");
        String cust_id = cust.s_cust_id;

        sw.write("<root>");
        sw.write("<ccps_product_list>");
        sw.write("<cust_id><![CDATA[" + cust_id + "]]></cust_id>");
        sw.write("</ccps_product_list>");
        sw.write("</root>");

        String sResponse = Service.communicate(124, cust_id, sw.toString());
        sResponse = sResponse.substring(41);

        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));
        NodeList nodeList = document.getElementsByTagName("rrcp_product_list_report");

        if(nodeList != null) {
            JsonArray productArray = new JsonArray();

            if (pageNumber == 0) {
                for (int i = 0; i < nodeList.getLength(); i++) {
                    Element element = (Element) nodeList.item(i);
                    ProductListReport report = new ProductListReport(element);

                    if (matchesFilter(report, filters)) {
                        JsonObject productObject = processProduct(element);
                        productArray.put(productObject);
                    }
                }
            } else {
                int pageSize = 50;
                int startIndex = (pageNumber - 1) * pageSize;
                int endIndex = Math.min(startIndex + pageSize, nodeList.getLength());

                for (int i = startIndex; i < endIndex; i++) {
                    JsonObject productObject = processProduct((Element) nodeList.item(i));
                    productArray.put(productObject);
                }
            }

            jsonObject.put("data", productArray);
        }
        jsonArray.put(jsonObject);
        out.print(jsonArray);
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
