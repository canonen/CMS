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
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="sun.nio.ch.IOUtil" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="org.xml.sax.SAXException" %>
<%@ page import="org.xml.sax.SAXParseException" %>
<%@ page import="org.apache.axis.ConfigurationException" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="com.britemoon.cps.imc.Service" %>  //???????????????



<%
   class CustomAttr{
      int attrId;
      String attrName;
      String attrTagName;
      int attrType;

       public int getAttrId() {
           return attrId;
       }                  public void setAttrId(int attrId) {
           this.attrId = attrId;
       }
       public String getAttrName() {
           return attrName;
       }           public void setAttrName(String attrName) {
           this.attrName = attrName;
       }
       public String getAttrTagName() {return attrTagName;}     public void setAttrTagName(String attrTagName) {this.attrTagName = attrTagName;}
       public int getAttrType() {return attrType;}                public void setAttrType(int attrType) {this.attrType = attrType;}
   }
%>

<%
            response.setHeader("Access-Control-Allow-Origin", "*");
            response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
            response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");


    System.out.println("SaveAttr Loading...");
            PreparedStatement preparedStatement=null;
            Statement statement=null;

            String custId =request.getParameter("custId");
            ResultSet resultSet =null;
            ConnectionPool connectionPool =null;
            Connection connection =null;
            Statement statement2 =null;
            ConnectionPool connectionPool2 =null;
            Connection connection2 =null;

            List<CustomAttr> customAttrs = new ArrayList<CustomAttr>();

            try{
                 connectionPool2 =ConnectionPool.getInstance();
                 connection2 = connectionPool2.getConnection(this);
                 statement2 = connection2.createStatement();

                String isExist=("SELECT attr_id,attr_name,attr_tag_name,type_id FROM ccps_product_attribute where attr_id>37 and  custId ="+ custId +" order by attr_id");

                resultSet = statement2.executeQuery(isExist);
                while(resultSet.next()){

                    CustomAttr customAttr = new CustomAttr();
                    customAttr.setAttrId(resultSet.getInt(1));
                    customAttr.setAttrName(resultSet.getString(2));
                    customAttr.setAttrTagName(resultSet.getString(3));
                    customAttr.setAttrType(resultSet.getInt(4));


                    if(!customAttr.getAttrTagName().equals(null) || !customAttr.getAttrTagName().equals(""))
                        {
                          customAttrs.add(customAttr);
                        }
                    }
                resultSet.close();

            }catch (Exception e)
            {
                System.out.println("hata custom"+e.getMessage());
            }finally{
                statement2.close();
                connection2.close();
            }






               try{

                    custId = request.getParameter("custId").equals("null") ? null : request.getParameter("custId");
                    String xmlLink = request.getParameter("xml_link").equals("null") ? null : request.getParameter("xml_link");
                    String productSeperator = request.getParameter("product_seperator").equals("null") ? null : request.getParameter("product_seperator");
                    String productId = request.getParameter("product_id").equals("null") ? null : request.getParameter("product_id");
                    String productName = request.getParameter("product_name").equals("null") ? null : request.getParameter("product_name");
                    String productColor = request.getParameter("product_color").equals("null") ? null : request.getParameter("product_color");
                    String productPrice = request.getParameter("product_price").equals("null") ? null : request.getParameter("product_price");
                    String productSalePrice = request.getParameter("product_sale_price").equals("null") ? null : request.getParameter("product_sale_price");
                    String productCurrency = request.getParameter("product_currency").equals("null") ? null : request.getParameter("product_currency");
                    String productStockCount = request.getParameter("product_stock_count").equals("null") ? null : request.getParameter("product_stock_count");
                    String productStockStatus = request.getParameter("product_stock_status").equals("null") ? null : request.getParameter("product_stock_status");
                    String productBrand = request.getParameter("product_brand").equals("null") ? null : request.getParameter("product_brand");
                    String productCategories = request.getParameter("product_categories").equals("null") ? null : request.getParameter("product_categories");
                    String productLink = request.getParameter("product_link").equals("null") ? null : request.getParameter("product_link");
                    String productImageLink = request.getParameter("product_image_link").equals("null") ? null : request.getParameter("product_image_link");
                    String productRate = request.getParameter("product_rate").equals("null") ? null : request.getParameter("product_rate");
                    String productGender = request.getParameter("product_gender").equals("null") ? null : request.getParameter("product_gender");
                    String productSize = request.getParameter("product_size").equals("null") ? null : request.getParameter("product_size");
                    String productModel = request.getParameter("product_model").equals("null") ? null : request.getParameter("product_model");
                    String productSkuCode = request.getParameter("product_sku_code").equals("null") ? null : request.getParameter("product_sku_code");

                    String ssl ="";
                    StringWriter stringWriter = new StringWriter();

                   try{

                       ssl = !request.getParameter("ssl").equals(null) ? request.getParameter("ssl") :"off";

                   }
                   catch (Exception e)
                   {}


                   String attr = "custom_field_name"+1;
                   String attrName = request.getParameter(attr);
                    for(int i =1;attrName!=null;)
                    {
                            try{

                                CustomAttr att = new CustomAttr();
                                att.setAttrName(attrName);
                                att.setAttrTagName(request.getParameter("custom_field_tag"+i));

                                String type =request.getParameter("custom_field_type"+i);
                                if(type.equals("Text")){
                                    att.setAttrType(1);}
                                else if(type.equals("Number")){
                                    att.setAttrType(2);}
                                else if(type.equals("Date")){
                                    att.setAttrType(3);}
                                else if(type.equals("String")){
                                    att.setAttrType(4);}
                                else if(type.equals("Money")){
                                    att.setAttrType(5);}

                                customAttrs.add(att);

                                i++;

                                attr = "custom_field_name"+i;
                                attrName = request.getParameter(attr);
                                }
                            catch (Exception e)
                            {
                                    System.out.println("hata2"+e);
                                    break;
                            }
                    }

                   stringWriter.write("<root>");
                   stringWriter.write("<ccps_product_dashboard_report>\r\n");

                   stringWriter.write("<custId><![CDATA[" + custId + "]]></custId>\r\n");
                   stringWriter.write("<xml_link><![CDATA[" + xmlLink + "]]></xml_link>\r\n");
                   stringWriter.write("<product_seperator><![CDATA[" + productSeperator + "]]></product_seperator>\r\n");
                   stringWriter.write("<product_id><![CDATA[" + productId + "]]></product_id>\r\n");
                   stringWriter.write("<product_name><![CDATA[" + productName + "]]></product_name>\r\n");
                   stringWriter.write("<product_color><![CDATA[" + productColor + "]]></product_color>\r\n");
                   stringWriter.write("<product_price><![CDATA[" + productPrice + "]]></product_price>\r\n");
                   stringWriter.write("<product_sale_price><![CDATA[" + productSalePrice + "]]></product_sale_price>\r\n");
                   stringWriter.write("<product_currency><![CDATA[" + productCurrency + "]]></product_currency>\r\n");
                   stringWriter.write("<product_stock_count><![CDATA[" + productStockCount + "]]></product_stock_count>\r\n");
                   stringWriter.write("<product_stock_status><![CDATA[" + productStockStatus + "]]></product_stock_status>\r\n");
                   stringWriter.write("<product_brand><![CDATA[" + productBrand + "]]></product_brand>\r\n");
                   stringWriter.write("<product_categories><![CDATA[" + productCategories + "]]></product_categories>\r\n");
                   stringWriter.write("<product_link><![CDATA[" + productLink + "]]></product_link>\r\n");
                   stringWriter.write("<product_image_link><![CDATA[" + productImageLink + "]]></product_image_link>\r\n");
                   stringWriter.write("<product_rate><![CDATA[" + productRate + "]]></product_rate>\r\n");
                   stringWriter.write("<product_gender><![CDATA[" + productGender + "]]></product_gender>\r\n");
                   stringWriter.write("<product_size><![CDATA[" + productSize + "]]></product_size>\r\n");
                   stringWriter.write("<product_model><![CDATA[" + productModel + "]]></product_model>\r\n");
                   stringWriter.write("<product_sku_code><![CDATA[" + productSkuCode + "]]></product_sku_code>\r\n");
                   stringWriter.write("<ssl><![CDATA[" + ssl + "]]></ssl>\r\n");

                   stringWriter.write("</ccps_product_dashboard_report>\r\n");

                   if(customAttrs.size()>0) {
                       for (int i = 0; customAttrs.size() >= i+1; i++) {
                           //+++ add costum_attr
                           stringWriter.write("<atteached_attr>\r\n");

                           stringWriter.write("<attr_id><![CDATA[" + customAttrs.get(i).attr_id + "]]></attr_id>\r\\n");
                           stringWriter.write("<attr_name><![CDATA[" + customAttrs.get(i).attr_name + "]]></attr_name>\r\\n");
                           stringWriter.write("<attr_tag_name><![CDATA[" + customAttrs.get(i).attr_tag_name + "]]></attr_tag_name>\r\\n");
                           stringWriter.write("<attr_type><![CDATA[" + customAttrs.get(i).attr_type + "]]></attr_type>\r\\n");

                           stringWriter.write("</atteached_attr>\r\n");
                       }
                   }

                   stringWriter.write("</root>");

                    //+++ add ServiceType
                   Service.notify(125, custId, stringWriter.toString());



                   connectionPool =ConnectionPool.getInstance();

                     if(connectionPool ==null){
                         out.println("Cust ID Bulunmamadi");
                                        return;
                     }

                     connection = connectionPool.getConnection("SaveAttributes.jsp");

                     statement= connection.createStatement();


                   String deleteFromTable = " DELETE FROM ccps_product_attribute WHERE custId = "+ custId;


                     statement.executeUpdate(deleteFromTable);
                     statement.close();


                     String insertAttr =" INSERT INTO ccps_product_attribute(attr_name,attr_tag_name,type_id,custId,is_list,attr_id)"
                                        +" VALUES(?,?,?,?,?,?); ";


                     int i =1;
                     preparedStatement = connection.prepareStatement(insertAttr);

                     preparedStatement.setString(1,"id");preparedStatement.setString(2,"");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_id");preparedStatement.setString(2,productId);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_status");preparedStatement.setString(2,"");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_name");preparedStatement.setString(2,productName );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_color");preparedStatement.setString(2,productColor );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_sales_price");preparedStatement.setString(2,productSalePrice );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"int_sales_price");preparedStatement.setString(2,productSalePrice );preparedStatement.setInt(3,5);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_price");preparedStatement.setString(2,productPrice );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"int_price");preparedStatement.setString(2,productPrice );preparedStatement.setInt(3,5);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"discount_flag");preparedStatement.setString(2,"");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"xml_discount");preparedStatement.setString(2,"");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"discount_rate");preparedStatement.setString(2,"");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"stock_count");preparedStatement.setString(2,productStockCount);preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"stock_status");preparedStatement.setString(2,productStockStatus);preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"brand");preparedStatement.setString(2,productBrand);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id");preparedStatement.setString(2, productCategories);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"top_category_id");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_2");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_3");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_4");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_5");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_6");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"visible");preparedStatement.setString(2, "");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_post_date");preparedStatement.setString(2, "");preparedStatement.setInt(3,3);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"update_date");preparedStatement.setString(2, "");preparedStatement.setInt(3,3);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"custom_label");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"link");preparedStatement.setString(2, productLink);preparedStatement.setInt(3,1);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"image_link");preparedStatement.setString(2, productImageLink);preparedStatement.setInt(3,1);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"rating");preparedStatement.setString(2, productRate);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"gender");preparedStatement.setString(2, productGender);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"size");preparedStatement.setString(2, productSize);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"model");preparedStatement.setString(2, productModel);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"sku_code");preparedStatement.setString(2, productSkuCode);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"cust_xml_url");preparedStatement.setString(2, xmlLink);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_seperator");preparedStatement.setString(2, productSeperator);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"ssl");preparedStatement.setString(2, ssl.equals("on")?"1":"0");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_currency");preparedStatement.setString(2,productCurrency );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();

                   if(customAttrs.size()>0){
                     for(CustomAttr attrr:customAttrs)
                         {
                             preparedStatement.setString(1,attrr.attrName);preparedStatement.setString(2,attrr.getAttrTagName());preparedStatement.setInt(3,attrr.getAttrType());preparedStatement.setInt(4,Integer.valueOf(custId));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                         }
                     }

                     int[] result = preparedStatement.executeBatch();

                     if(result[0] == 1)
                         {
                         %>

                        <table cellspacing="0" cellpadding="0" align="center" width="600" >
                        <tr>
                        <td align="center" style="font-size:16px; font-family: Verdana,Arial,Tahoma;"><a href="<%response.sendRedirect(request.getContextPath()+"/ui/jsp/api/product/productDashboard.jsp");%>">onceki sayfaya don </a> </td>
                        </tr>
                        </table>
                            <%
                         }
                     else{
                          out.println("ISLEM BASARISIZ");
                     }

            }catch (Exception e)
            {
                response.sendRedirect(request.getContextPath()+"/ui/jsp/api/product/productDashboard.jsp");
                    System.out.println("ISLEM BASARISIZ,  hata mesaji: "+e);
            }
           finally{

               if(!(connection ==null))
                   {
                       connection.close();
                   }
           }

        %>
