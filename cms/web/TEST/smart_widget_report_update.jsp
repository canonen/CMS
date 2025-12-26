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
			org.xml.sax.*,
			org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%!
    public class SmartWidgetReport{
        private Element s_smartWidgetReport=null;

        public String cust_id=null;
        public String popup_id = null;
        public String popup_name = null;
        public String form_id = null;
        public String impression = null;
        public String activity = null;
        public String contribution = null;
        public String revenue = null;
        public String type_name = null;
        public String activity_date=null;
        public String last_update_date=null;
        public String total_order=null;
        public String total_revenue=null;
        public String total_qty = null;

        public SmartWidgetReport(Element element){

            cust_id	= 		Deger(element.getElementsByTagName("cust_id"));
            popup_id=		Deger(element.getElementsByTagName("popup_id"));
            popup_name=	  	Deger(element.getElementsByTagName("popup_name"));
            form_id=	  	Deger(element.getElementsByTagName("form_id"));
            impression=  	Deger(element.getElementsByTagName("impression"));
            activity =      Deger(element.getElementsByTagName("activity"));
            contribution= 	Deger(element.getElementsByTagName("contribution"));
            revenue=    	Deger(element.getElementsByTagName("revenue"));
            type_name=   	Deger(element.getElementsByTagName("type_name"));
            activity_date= 	Deger(element.getElementsByTagName("activity_date"));
            last_update_date= Deger(element.getElementsByTagName("last_update_date"));
            total_order=	Deger(element.getElementsByTagName("total_order"));
            total_revenue=	Deger(element.getElementsByTagName("total_revenue"));
            total_qty=		Deger(element.getElementsByTagName("total_qty"));
        }

        public void save()throws Exception{
            ConnectionPool connectionPool=null;
            Connection connection=null;
            PreparedStatement statement=null;

            try {
                System.out.println("custId: " + cust_id);
                connectionPool=ConnectionPool.getInstance();
                connection=connectionPool.getConnection(this);

                String sql = "INSERT INTO ccps_smart_widget_activity_day (cust_id,popup_id,popup_name,form_id,impression," +
                        "activity,contribution,revenue,type_name,activity_date,last_update_date,total_order,total_revenue,total_qty) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                statement=connection.prepareStatement(sql);
                int x=1;

                statement.setString(x++,cust_id);
                statement.setString(x++,popup_id);
                statement.setString(x++,popup_name);
                statement.setString(x++,form_id);
                statement.setString(x++,impression);
                statement.setString(x++,activity);
                statement.setString(x++,contribution);
                if (!revenue.equals("null")) {statement.setDouble(x++, Double.parseDouble(revenue));}
                else{statement.setDouble(x++,0);}
                statement.setString(x++,type_name);
                statement.setString(x++,activity_date);
                statement.setString(x++,last_update_date);
                statement.setString(x++,total_order);
                if (!total_revenue.equals("null")) {statement.setDouble(x++, Double.parseDouble(total_revenue));}
                else{statement.setDouble(x++,0);}
                statement.setString(x++,total_qty);
                statement.executeUpdate();

            }
            catch (Exception exception){
                System.out.println("Save Function: "+cust_id);
                System.out.println("Save Function:"+exception);
                throw exception;
            }finally {
                if (statement != null) statement.close();
                if(connection!=null)connectionPool.free(connection);
            }
        }

        public String Deger(NodeList g1){

            String deger=null;

            if(g1.getLength()>0){
                Element g1_Element		= (Element)g1.item(0);
                NodeList text_g1 		= g1_Element.getChildNodes();
                if(text_g1.item(0) != null ){
                    deger					=((Node)text_g1.item(0)).getNodeValue().trim();
                }
                //System.out.println("DOLU : " +deger );
            }else{
                //System.out.println("BOS : " +deger );
            }

            return MysqlRealScapeString(deger)  ;
        }

        public String MysqlRealScapeString(String str){
            String data = "";
            if (str != null && str.length() > 0) {
                str = str.replace("\\", "\\\\");
                str = str.replace("'", "");
                str = str.replace("\0", "\\0");
                str = str.replace("\n", "\\n");
                str = str.replace("\r", "\\r");
                str = str.replace("\"", "\\\"");
                str = str.replace("\\x1a", "\\Z");
                data = str;
            }
            return data;
        }
    }
%>
<%@ include file="header.jsp" %>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    try
    {
        System.out.println("SmartWidgetReport is loading...");
        BufferedReader bufferedReader         = new BufferedReader(new InputStreamReader((request.getInputStream()),"UTF-8"));
        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder               = builderFactory.newDocumentBuilder();
        Document document                     = builder.parse(new InputSource(bufferedReader));
        System.out.println("itemmmmmm -2");

        try{
            System.out.println("itemmmmmm -1");
            NodeList nodeList = document.getElementsByTagName("smart_widget_report");
            System.out.println("itemmmmmm nodeList");
            System.out.println("lengggggg: ");
            for (int i=0;i<nodeList.getLength();i++){
                System.out.println("itemmmmmm nodeList forrr");

                SmartWidgetReport report1 = new SmartWidgetReport((Element) nodeList.item(i));
                System.out.println("itemmmmmmm");
                System.out.println(nodeList.getLength());
                System.out.println(nodeList.toString());
                System.out.println(nodeList);
                System.out.println(nodeList.item(i));
                report1.save();
            }
            System.out.println("itemmmmmm nodeList forrr exit");


        }catch (Exception e){
            System.out.println("Nodelist initialize error"+e);
        }

    }
    catch (Exception ex) {
        logger.error("Smart Widget Report Update Error!\r\n", ex);
    }
%>