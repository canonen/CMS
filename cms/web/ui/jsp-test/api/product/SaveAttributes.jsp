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

<%@ include file="../../utilities/validator.jsp"%>
<%@ include file="../header.jsp"%>

<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

   class CustomAttr{
      int attr_id;
      String attr_name;
      String attr_tag_name;
      int attr_type;

       public int getAttr_id() {
           return attr_id;
       }                  public void setAttr_id(int attr_id) {
           this.attr_id = attr_id;
       }
       public String getAttr_name() {
           return attr_name;
       }           public void setAttr_name(String attr_name) {
           this.attr_name = attr_name;
       }
       public String getAttr_tag_name() {return attr_tag_name;}     public void setAttr_tag_name(String attr_tag_name) {this.attr_tag_name = attr_tag_name;}
       public int getAttr_type() {return attr_type;}                public void setAttr_type(int attr_type) {this.attr_type = attr_type;}
   }
%>

<%
            

            response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
            response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");

        System.out.println("SaveAttr Loading...");
            PreparedStatement preparedStatement=null;
            Statement statement=null;

            String cust_id=request.getParameter("cust_id");
            ResultSet rs=null;
            ConnectionPool cp=null;
            Connection conn=null;
            Statement stmt=null;
            ConnectionPool cp2=null;
            Connection conn2=null;

            List<CustomAttr> customAttrs = new ArrayList<CustomAttr>();

            try{
                 cp2 =ConnectionPool.getInstance();
                 conn2=cp2.getConnection(this);
                 stmt=conn2.createStatement();

                String isExist=("SELECT attr_id,attr_name,attr_tag_name,type_id FROM ccps_product_attribute 		where attr_id>37 and  cust_id ="+ cust_id +" order by attr_id");

                rs=stmt.executeQuery(isExist);
                while(rs.next()){

                    CustomAttr att = new CustomAttr();
                    att.setAttr_id(rs.getInt(1));
                    att.setAttr_name(rs.getString(2));
                    att.setAttr_tag_name(rs.getString(3));
                    att.setAttr_type(rs.getInt(4));


                    if(!att.getAttr_tag_name().equals(null) || !att.getAttr_tag_name().equals(""))
                        {
                          customAttrs.add(att);
                        }
                    }
                rs.close();

            }catch (Exception e)
            {
                System.out.println("hata custom"+e.getMessage());
            }finally{
                stmt.close();
                conn2.close();
            }






               try{

                    cust_id = request.getParameter("cust_id").equals("null") ? null : request.getParameter("cust_id");
                    String xml_link = request.getParameter("xml_link").equals("null") ? null : request.getParameter("xml_link");
                    String product_seperator = request.getParameter("product_seperator").equals("null") ? null : request.getParameter("product_seperator");
                    String product_id = request.getParameter("product_id").equals("null") ? null : request.getParameter("product_id");
                    String product_name = request.getParameter("product_name").equals("null") ? null : request.getParameter("product_name");
                    String product_color = request.getParameter("product_color").equals("null") ? null : request.getParameter("product_color");
                    String product_price = request.getParameter("product_price").equals("null") ? null : request.getParameter("product_price");
                    String product_sale_price = request.getParameter("product_sale_price").equals("null") ? null : request.getParameter("product_sale_price");
                    String product_currency = request.getParameter("product_currency").equals("null") ? null : request.getParameter("product_currency");
                    String product_stock_count = request.getParameter("product_stock_count").equals("null") ? null : request.getParameter("product_stock_count");
                    String product_stock_status = request.getParameter("product_stock_status").equals("null") ? null : request.getParameter("product_stock_status");
                    String product_brand = request.getParameter("product_brand").equals("null") ? null : request.getParameter("product_brand");
                    String product_categories = request.getParameter("product_categories").equals("null") ? null : request.getParameter("product_categories");
                    String product_link = request.getParameter("product_link").equals("null") ? null : request.getParameter("product_link");
                    String product_image_link = request.getParameter("product_image_link").equals("null") ? null : request.getParameter("product_image_link");
                    String product_rate = request.getParameter("product_rate").equals("null") ? null : request.getParameter("product_rate");
                    String product_gender = request.getParameter("product_gender").equals("null") ? null : request.getParameter("product_gender");
                    String product_size = request.getParameter("product_size").equals("null") ? null : request.getParameter("product_size");
                    String product_model = request.getParameter("product_model").equals("null") ? null : request.getParameter("product_model");
                    String product_sku_code = request.getParameter("product_sku_code").equals("null") ? null : request.getParameter("product_sku_code");

                    String ssl ="";
                    StringWriter sw = new StringWriter();

                   try{

                       ssl = !request.getParameter("ssl").equals(null) ? request.getParameter("ssl") :"off";

                   }
                   catch (Exception e)
                   {}


                   String attr = "custom_field_name"+1;
                   String attr_name = request.getParameter(attr);
                    for(int i =1;attr_name!=null;)
                    {
                            try{

                                CustomAttr att = new CustomAttr();
                                att.setAttr_name(attr_name);
                                att.setAttr_tag_name(request.getParameter("custom_field_tag"+i));

                                String type =request.getParameter("custom_field_type"+i);
                                if(type.equals("Text")){
                                    att.setAttr_type(1);}
                                else if(type.equals("Number")){
                                    att.setAttr_type(2);}
                                else if(type.equals("Date")){
                                    att.setAttr_type(3);}
                                else if(type.equals("String")){
                                    att.setAttr_type(4);}
                                else if(type.equals("Money")){
                                    att.setAttr_type(5);}

                                customAttrs.add(att);

                                i++;

                                attr = "custom_field_name"+i;
                                attr_name = request.getParameter(attr);
                                }
                            catch (Exception e)
                            {
                                    System.out.println("hata2"+e);
                                    break;
                            }
                    }

                   sw.write("<root>");
                   sw.write("<ccps_product_dashboard_report>\r\n");

                   sw.write("<cust_id><![CDATA[" + cust_id + "]]></cust_id>\r\n");
                   sw.write("<xml_link><![CDATA[" + xml_link + "]]></xml_link>\r\n");
                   sw.write("<product_seperator><![CDATA[" + product_seperator + "]]></product_seperator>\r\n");
                   sw.write("<product_id><![CDATA[" + product_id + "]]></product_id>\r\n");
                   sw.write("<product_name><![CDATA[" + product_name + "]]></product_name>\r\n");
                   sw.write("<product_color><![CDATA[" + product_color + "]]></product_color>\r\n");
                   sw.write("<product_price><![CDATA[" + product_price + "]]></product_price>\r\n");
                   sw.write("<product_sale_price><![CDATA[" + product_sale_price + "]]></product_sale_price>\r\n");
                   sw.write("<product_currency><![CDATA[" + product_currency + "]]></product_currency>\r\n");
                   sw.write("<product_stock_count><![CDATA[" + product_stock_count + "]]></product_stock_count>\r\n");
                   sw.write("<product_stock_status><![CDATA[" + product_stock_status + "]]></product_stock_status>\r\n");
                   sw.write("<product_brand><![CDATA[" + product_brand + "]]></product_brand>\r\n");
                   sw.write("<product_categories><![CDATA[" + product_categories + "]]></product_categories>\r\n");
                   sw.write("<product_link><![CDATA[" + product_link + "]]></product_link>\r\n");
                   sw.write("<product_image_link><![CDATA[" + product_image_link + "]]></product_image_link>\r\n");
                   sw.write("<product_rate><![CDATA[" + product_rate + "]]></product_rate>\r\n");
                   sw.write("<product_gender><![CDATA[" + product_gender + "]]></product_gender>\r\n");
                   sw.write("<product_size><![CDATA[" + product_size + "]]></product_size>\r\n");
                   sw.write("<product_model><![CDATA[" + product_model + "]]></product_model>\r\n");
                   sw.write("<product_sku_code><![CDATA[" + product_sku_code + "]]></product_sku_code>\r\n");
                   sw.write("<ssl><![CDATA[" + ssl + "]]></ssl>\r\n");

                   sw.write("</ccps_product_dashboard_report>\r\n");

                   if(customAttrs.size()>0) {
                       for (int i = 0; customAttrs.size() >= i+1; i++) {
                           //+++ add costum_attr
                           sw.write("<atteached_attr>\r\n");

                           sw.write("<attr_id><![CDATA[" + customAttrs.get(i).attr_id + "]]></attr_id>\r\\n");
                           sw.write("<attr_name><![CDATA[" + customAttrs.get(i).attr_name + "]]></attr_name>\r\\n");
                           sw.write("<attr_tag_name><![CDATA[" + customAttrs.get(i).attr_tag_name + "]]></attr_tag_name>\r\\n");
                           sw.write("<attr_type><![CDATA[" + customAttrs.get(i).attr_type + "]]></attr_type>\r\\n");

                           sw.write("</atteached_attr>\r\n");
                       }
                   }

                   sw.write("</root>");

                    //+++ add ServiceType
                   Service.notify(125, cust_id, sw.toString());



                   cp=ConnectionPool.getInstance();

                     if(cp==null){
                         out.println("Cust ID Bulunmamadi");
                                        return;
                     }

                     conn=cp.getConnection("SaveAttributes.jsp");

                     statement=conn.createStatement();


                   String deleteFromTable = " DELETE FROM ccps_product_attribute WHERE cust_id = "+cust_id;


                     statement.executeUpdate(deleteFromTable);
                     statement.close();


                     String insertAttr =" INSERT INTO ccps_product_attribute(attr_name,attr_tag_name,type_id,cust_id,is_list,attr_id)"
                                        +" VALUES(?,?,?,?,?,?); ";


                     int i =1;
                     preparedStatement = conn.prepareStatement(insertAttr);

                     preparedStatement.setString(1,"id");preparedStatement.setString(2,"");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_id");preparedStatement.setString(2,product_id);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_status");preparedStatement.setString(2,"");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_name");preparedStatement.setString(2,product_name );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_color");preparedStatement.setString(2,product_color );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_sales_price");preparedStatement.setString(2,product_sale_price );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"int_sales_price");preparedStatement.setString(2,product_sale_price );preparedStatement.setInt(3,5);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_price");preparedStatement.setString(2,product_price );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"int_price");preparedStatement.setString(2,product_price );preparedStatement.setInt(3,5);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"discount_flag");preparedStatement.setString(2,"");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"xml_discount");preparedStatement.setString(2,"");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"discount_rate");preparedStatement.setString(2,"");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"stock_count");preparedStatement.setString(2,product_stock_count);preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"stock_status");preparedStatement.setString(2,product_stock_status);preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"brand");preparedStatement.setString(2,product_brand);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id");preparedStatement.setString(2, product_categories);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"top_category_id");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_2");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_3");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_4");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_5");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"category_id_6");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"visible");preparedStatement.setString(2, "");preparedStatement.setInt(3,2);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_post_date");preparedStatement.setString(2, "");preparedStatement.setInt(3,3);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"update_date");preparedStatement.setString(2, "");preparedStatement.setInt(3,3);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"custom_label");preparedStatement.setString(2, "");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"link");preparedStatement.setString(2, product_link);preparedStatement.setInt(3,1);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"image_link");preparedStatement.setString(2, product_image_link);preparedStatement.setInt(3,1);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"rating");preparedStatement.setString(2, product_rate);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"gender");preparedStatement.setString(2, product_gender);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"size");preparedStatement.setString(2, product_size);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"model");preparedStatement.setString(2, product_model);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"sku_code");preparedStatement.setString(2, product_sku_code);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"cust_xml_url");preparedStatement.setString(2, xml_link);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_seperator");preparedStatement.setString(2, product_seperator);preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"ssl");preparedStatement.setString(2, ssl.equals("on")?"1":"0");preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                     preparedStatement.setString(1,"product_currency");preparedStatement.setString(2,product_currency );preparedStatement.setInt(3,4);preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();

                   if(customAttrs.size()>0){
                     for(CustomAttr attrr:customAttrs)
                         {
                             preparedStatement.setString(1,attrr.attr_name);preparedStatement.setString(2,attrr.getAttr_tag_name());preparedStatement.setInt(3,attrr.getAttr_type());preparedStatement.setInt(4,Integer.valueOf(cust_id));preparedStatement.setInt(5,0);preparedStatement.setInt(6,i++);preparedStatement.addBatch();
                         }
                     }

                     int[] result = preparedStatement.executeBatch();

                     if(result[0] == 1)
                         {
                         %>

                        <table cellspacing="0" cellpadding="0" align="center" width="600" >
                        <tr>
                        <td align="center" style="font-size:16px; font-family: Verdana,Arial,Tahoma;"><a href="<%response.sendRedirect(request.getContextPath()+"/ui/jsp/report/ProductDashBoard.jsp");%>">onceki sayfaya don </a> </td>
                        </tr>
                        </table>
                            <%
                         }
                     else{
                          out.println("ISLEM BASARISIZ");
                     }

            }catch (Exception e)
            {
                response.sendRedirect(request.getContextPath()+"/ui/jsp/report/ProductDashBoard.jsp");
                    System.out.println("ISLEM BASARISIZ,  hata mesaji: "+e);
            }
           finally{

               if(!(conn==null))
                   {
                       conn.close();
                   }
           }

        %>
