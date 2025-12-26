<%@ page
        language="java"
        import="com.britemoon.*,
                  com.britemoon.rcp.*,
                  com.britemoon.rcp.imc.*,
                  com.britemoon.rcp.que.*,
                  java.sql.*,java.io.*,
                  java.math.BigDecimal,
                  java.text.NumberFormat,
                  java.io.*,
                  java.net.SocketException,
                  org.apache.log4j.Logger,
                  java.util.AbstractMap.SimpleEntry,
                  javax.xml.parsers.*,
                  org.w3c.dom.*,
                  org.xml.sax.*,
                  java.net.*"

        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.apache.lucene.index.IndexWriter" %>
<%@ page import="java.util.concurrent.TimeUnit" %>
<%@ page import="com.britemoon.rcp.lucene.Product" %>
<%@ page import="org.apache.lucene.store.FSDirectory" %>
<%@ page import="org.apache.lucene.index.IndexWriterConfig" %>
<%@ page import="org.apache.lucene.analysis.standard.StandardAnalyzer" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="org.apache.lucene.index.CorruptIndexException" %>
<%@ page import="org.apache.lucene.store.LockObtainFailedException" %>
<%@ page import="org.apache.lucene.document.*" %>
<%@ page import="org.apache.lucene.document.Document" %>
<%@ page import="org.apache.lucene.util.BytesRef" %>
 <%
 response.setHeader("Access-Control-Allow-Origin", "*");
 response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
 response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
  %>
<%

    String custid = request.getParameter("cust_id");
    final String INDEX_DIR = "C:\\SearchIndex\\"+custid+"\\product";


    int toplamKayit=0;

    Statement         stmt  = null;
	PreparedStatement pstmt = null;
    ResultSet         rs    = null;
    ConnectionPool    cp    = null;
    Connection        conn  = null;

    try {

        long start = System.currentTimeMillis();

        cp = ConnectionPool.getInstance(custid);
        if(cp==null){
            out.println("Cust ID Bulunmamadi");
            return;
        }
        conn = cp.getConnection(custid+"-xmlSave.jsp");
        stmt = conn.createStatement();
        List<Product> productList = new ArrayList<Product>();
        Map<String, Product> mapForSimilarProduct = new HashMap<String, Product>(); //BEDEN FARKLILIKLARINDA AYNI PRODUCTLARIN GELMESINI ONLEMEK ICIN KULLANDIGIMIZ MAP


        String getCustomersSQL = "EXEC z_parse_index";

        rs = stmt.executeQuery(getCustomersSQL);
        while (rs.next()){
            Product product = new Product(new Integer(rs.getInt(1)), getStringParameter(rs.getString(2)),new String(rs.getBytes(3), "UTF-8"), getStringParameter(rs.getString(4)),getStringParameter(rs.getString(5)),
                    new String(rs.getBytes(6), "UTF-8"),new String(rs.getBytes(7), "UTF-8"),new String(rs.getBytes(8), "UTF-8"),new String(rs.getBytes(9), "UTF-8"),new String(rs.getBytes(10), "UTF-8"),new String(rs.getBytes(11), "UTF-8"), getStringParameter(rs.getString(12)), getStringParameter(rs.getString(13).replace("-","")),
                    convertMoneyToInt(rs.getString(14)), convertMoneyToInt(rs.getString(15)), new String(rs.getBytes(16), "UTF-8"), getStringParameter(rs.getString(17)), getStringParameter(rs.getString(18)), getStringParameter(rs.getString(19)), getStringParameter(rs.getString(20)));


            product.setImageLink(new String(product.getImageLink().getBytes(), "UTF-8"));
            product.setLink(new String(product.getLink().getBytes(), "UTF-8"));

            productList.add(product);
        }
		/****************************************************************/
		/***********************Product Filtering************************/
		/****************************************************************/
		String filter_id = null;
		
		rs.close();
		rs = stmt.executeQuery("select filter_id from rrcp_personal_search_config");
		
		if(rs.next()) {
			filter_id = rs.getString(1);
		}	
		
		String sql = null;
		int isFilterExcluded = 0;
		int filterFound = 0;

		ArrayList<String> filteredProductIdList = new ArrayList<String>();
   
   
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
		
		if(filteredProductIdList.size()>0) {
		for(int i = productList.size() - 1; i >= 0; --i) 
		{
			if(isFilterExcluded==1) {
				if(filteredProductIdList.contains(productList.get(i).getProductID())) {
					productList.remove(i);
				}
			} else {
				if(!filteredProductIdList.contains(productList.get(i).getProductID())) {
					productList.remove(i);
				}
			}
		}
		}
		
		/****************************************************************/
		/***********************Product Filtering************************/
		/****************************************************************/
		

        Collections.sort(productList,new Product());
        Collections.reverse(productList);

        for (Product product:productList)
        {
            mapForSimilarProduct.put(product.getImageLink(),product);
        }


        for(Product product : productList){
            String getOrderCount = "select count(*) from rque_cust_order with(nolock) where product_id = '" + product.getProductID() +"'";
            rs = stmt.executeQuery(getOrderCount);
            while (rs.next()){
                product.setTotalSell(rs.getInt(1));
            }
			rs.close();
        }
        stmt.close();
        File dir = new File(INDEX_DIR);
        if (!dir.exists()) dir.mkdirs();


        IndexWriter writer = createWriter(INDEX_DIR);

        List<Document> documents = new ArrayList<Document>();

        for(Map.Entry<String, Product> map : mapForSimilarProduct.entrySet()){

            Document document = createDocument(map.getValue());
            documents.add(document);
        }



        writer.deleteAll();
        writer.addDocuments(documents);
        writer.commit();
        writer.close();
        long end = System.currentTimeMillis();
        Long seconds = TimeUnit.MILLISECONDS.toSeconds(end-start);
        out.println("Run Time : " + seconds);
        out.println("Done");

    } catch (SQLException e) {

        out.println("There is a problem check it");
        e.printStackTrace();

    }




%>
<%!
    private static IndexWriter createWriter(String indexDIR)
    {
        FSDirectory dir = null;
        try {
            dir = FSDirectory.open(Paths.get(indexDIR));
            IndexWriterConfig config = new IndexWriterConfig(new StandardAnalyzer());
            config.setOpenMode(IndexWriterConfig.OpenMode.CREATE);
            IndexWriter writer = new IndexWriter(dir, config);
            return writer;
        } catch (CorruptIndexException e) {
            e.printStackTrace();
        } catch (LockObtainFailedException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    private static String getStringParameter(String value){
        if(value == null)
            return "";
        else {
            return value;
        }
    }

    private static int convertMoneyToInt(String money){
        if(money == null || money.equalsIgnoreCase("")){
            return Integer.MIN_VALUE;
        }else {

            if(money.contains(",")){
                money = money.replace(",",".");
            }
            Double d = Double.parseDouble(money);
            int result=0;
            if(d == 0){
                result = Integer.MIN_VALUE;
            }else
                result = (int) Math.round(d);
            return result;
        }
    }

    private static Document createDocument(Product product)
    {
        Document document = new Document();
        document.add(new StringField("id", product.getId()+"" , Field.Store.YES));

        document.add(new TextField("productID", product.getProductID() , Field.Store.YES));
        document.add(new TextField("productName", product.getProductName(), Field.Store.YES));
        document.add(new TextField("productSalesPrice", product.getProductSalesPrice() , Field.Store.YES));
        document.add(new TextField("productPrice", product.getProductPrice() , Field.Store.YES));
        document.add(new TextField("link", product.getLink() , Field.Store.YES));
        document.add(new TextField("imageLink", product.getImageLink() , Field.Store.YES));
        if(product.getTopCategory() != null && !product.getTopCategory().equalsIgnoreCase("")){
            document.add(new SortedDocValuesField("topCategory", new BytesRef(product.getTopCategory() )));
            document.add(new TextField("top_category_id", product.getTopCategory() , Field.Store.YES));
        }
        else{
            document.add(new TextField("top_category_id", "--" , Field.Store.YES));
            document.add(new SortedDocValuesField ("topCategory", new BytesRef("--" )));
        }
        if(product.getCategory2() != null && !product.getCategory2().equalsIgnoreCase("")){
            document.add(new TextField("category_id_2",product.getCategory2(), Field.Store.YES));
            document.add(new SortedDocValuesField ("category2",new BytesRef(product.getCategory2())));
        }
        else{
            document.add(new TextField("category_id_2","--", Field.Store.YES));
            document.add(new SortedDocValuesField ("category2",new BytesRef("--")));
        }
        if(product.getCategory3() != null && !product.getCategory3().equalsIgnoreCase("")){
            document.add(new TextField("category_id_3",product.getCategory3(), Field.Store.YES));
            document.add(new SortedDocValuesField("category3",new BytesRef(product.getCategory3())));
        }
        else{
            document.add(new TextField("category_id_3","--", Field.Store.YES));
            document.add(new SortedDocValuesField ("category3",new BytesRef("--")));
        }
        if(product.getCategory4() != null && !product.getCategory4().equalsIgnoreCase("")){
            document.add(new TextField("category_id_4",product.getCategory4(), Field.Store.YES));
            document.add(new SortedDocValuesField ("category4",new BytesRef(product.getCategory4())));
        }
        else{
            document.add(new TextField("category_id_4","--", Field.Store.YES));
            document.add(new SortedDocValuesField ("category4",new BytesRef("--")));
        }
        document.add(new NumericDocValuesField("totalOrder", product.getTotalSell()));
        document.add(new StoredField("orderCount", product.getTotalSell()));

        if(product.getPostDate() != null && !product.getPostDate().equalsIgnoreCase("")){
            document.add(new SortedDocValuesField("postDate", new BytesRef(product.getPostDate())));
            document.add(new StoredField("saveDate", product.getPostDate()));
        }else{
            document.add(new SortedDocValuesField("postDate", new BytesRef("--")));
            document.add(new StoredField("saveDate", "--"));
        }
        if(product.getSkuCode() != null && !product.getSkuCode().equalsIgnoreCase(""))
            document.add(new TextField("skuCode", product.getSkuCode() , Field.Store.YES));

        else{
            document.add(new TextField("skuCode", "--" , Field.Store.YES));
        }
        document.add(new IntPoint("rangePrice",product.getPrice()));
        document.add(new IntPoint("rangeSalePrice",product.getSalePrice()));
        if(product.getBrand() != null && !product.getBrand().equalsIgnoreCase(""))
            document.add(new TextField("brand", product.getBrand() , Field.Store.YES));

        else{
            document.add(new TextField("brand", "--" , Field.Store.YES));
        }
        if(product.getGender() != null && !product.getGender().equalsIgnoreCase(""))
            document.add(new TextField("gender", product.getGender() , Field.Store.YES));

        else{
            document.add(new TextField("gender", "--" , Field.Store.YES));
        }
        if(product.getSize() != null && !product.getSize().equalsIgnoreCase(""))
            document.add(new TextField("size", product.getSize() , Field.Store.YES));

        else{
            document.add(new TextField("size", "--" , Field.Store.YES));
        }

        if(product.getVisible() != null && !product.getVisible().equalsIgnoreCase(""))
            document.add(new TextField("visible", product.getVisible() , Field.Store.YES));

        else{
            document.add(new TextField("visible", "--" , Field.Store.YES));
        }

        if(product.getColor() != null && !product.getColor().equalsIgnoreCase(""))
            document.add(new TextField("color", product.getColor() , Field.Store.YES));

        else{
            document.add(new TextField("color", "--" , Field.Store.YES));
        }
        return document;
    }

%>



</BODY>
</HTML>
