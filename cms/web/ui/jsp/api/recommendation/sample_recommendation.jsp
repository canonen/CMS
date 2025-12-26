<%@  page language="java"
          import="java.net.*,
                  com.britemoon.*,
                  com.britemoon.rcp.*,
                  com.britemoon.rcp.imc.*,
                  com.britemoon.rcp.que.*,
                  java.sql.*,
                  java.util.Map,
                  java.util.HashMap,
                  java.util.HashSet,
                  java.util.Iterator,
                  org.json.JSONArray,
                  org.json.JSONException,
                  org.json.JSONObject,
                  java.util.Date,
                  java.io.*,
                  java.math.BigDecimal,
                  java.text.NumberFormat,
                  java.util.Locale,
                  java.io.*,
                  org.apache.log4j.Logger,
                  org.apache.poi.ss.usermodel.*,
                  org.apache.poi.xssf.usermodel.*,
		  java.io.*,
                  org.w3c.dom.*"
          contentType="text/html;charset=UTF-8"
%>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>
<%
    String cust_id = request.getParameter("cust_id");
%>

<%
    /*
     *
     *
    String filePath = "Bundle.xlsx";

    // Create a FileInputStream to read the file
    FileInputStream fileInputStream = new FileInputStream(filePath);

    // Create a Workbook object to represent the Excel file
    XSSFWorkbook workbook = new XSSFWorkbook(fileInputStream);

    // Get the first sheet in the workbook
    Sheet sheet = workbook.getSheetAt(0);

    // Iterate over the rows in the sheet
    for (Row row : sheet) {
        // Iterate over the cells in the row
        for (Cell cell : row) {
            // Get the cell value
            String cellValue = cell.getStringCellValue();

            if (cellValue == null || cellValue.trim().isEmpty()) {
                out.println(null + " ");
            } else {
                // Print the cell value
                out.println(cellValue + " ");
            }


        }
        System.out.println();
    }
    // Close the file input stream
    fileInputStream.close();
    *
    *
    */

    BufferedReader reader = new BufferedReader(new FileReader("C:\\Revotas\\cms\\web\\ui\\jsp\\api\\recommendation\\Products.txt"));
    
    String line = reader.readLine();
    
    JSONObject next = new JSONObject();
    JSONArray result = new JSONArray();
    String query = "INSERT INTO z_rec_products_bt_altinbas (product_id_original, product_id_1, product_id_2, product_id_3) VALUES ('1000', '2000', '3000');";
    FileWriter fileWriter = new FileWriter("C:\\output_file.txt"); 
    
    while (line != null) {
        String[] values = line.split(", ");

        for (int i = 0; i < values.length; i++) {
	    query = query.replaceAll(String.valueOf((i + 1) * 1000), values[i]);
        }
        fileWriter.write(query);
        query = "INSERT INTO z_rec_products_bt_altinbas (product_id_original, product_id_1, product_id_2, product_id_3) VALUES ('1000', '2000', '3000')";
        line = reader.readLine();
        result.put(next);
        next = new JSONObject();
    }
    fileWriter.close();
    
%>