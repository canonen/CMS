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
    public class NewWebPushActivityDay {

        private Element s_newWebPushActivityDay = null;
        public String cust_id = null;
        public String camp_id = null;
        public String camp_name = null;
        public String sent = null;
        public String activity = null;
        public String conversion = null;
        public String revenue = null;
        public String total_order = null;
        public String total_revenue = null;
        public String total_qty = null;
        public String activity_date = null;
        public String last_update_date = null;

        public NewWebPushActivityDay(Element newWebPushActivityDay){
            s_newWebPushActivityDay = newWebPushActivityDay;
            cust_id = Deger(s_newWebPushActivityDay.getElementsByTagName("cust_id"));
            camp_id = Deger(s_newWebPushActivityDay.getElementsByTagName("camp_id"));
            camp_name = Deger(s_newWebPushActivityDay.getElementsByTagName("camp_name"));
            sent = Deger(s_newWebPushActivityDay.getElementsByTagName("sent"));
            conversion = Deger(s_newWebPushActivityDay.getElementsByTagName("conversion"));
            activity = Deger(s_newWebPushActivityDay.getElementsByTagName("activity"));
            revenue = Deger(s_newWebPushActivityDay.getElementsByTagName("revenue"));
            total_order = Deger(s_newWebPushActivityDay.getElementsByTagName("total_order"));
            total_revenue = Deger(s_newWebPushActivityDay.getElementsByTagName("total_revenue")); //
            total_qty = Deger(s_newWebPushActivityDay.getElementsByTagName("total_qty"));      
            activity_date = Deger(s_newWebPushActivityDay.getElementsByTagName("activity_date"));
            last_update_date = Deger(s_newWebPushActivityDay.getElementsByTagName("last_update_date"));

        }
        public void save() throws Exception {
            ConnectionPool connectionPool=null;
            Connection connection=null;
            PreparedStatement statement=null;

            try {
                connectionPool=ConnectionPool.getInstance();
                connection=connectionPool.getConnection(this);
                String sql = " INSERT INTO ccps_webpush_activity_day(cust_id,camp_id,camp_name,sent,activity,conversion,revenue,total_order,total_revenue,total_qty,activity_date,last_update_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                statement = connection.prepareStatement(sql);
                int x=1;
                System.out.println("WebPush Activity Day is loading... Customer Id : " + cust_id);
                statement.setString(x++,cust_id);
                statement.setString(x++,camp_id);
                statement.setString(x++,camp_name);
                statement.setInt(x++,"null".equals(sent) ? 0 : Integer.parseInt(sent));
                statement.setInt(x++,"null".equals(activity) ? 0 : Integer.parseInt(activity));
                statement.setInt(x++,"null".equals(conversion) ? 0 : Integer.parseInt(conversion));
                if (!revenue.equals("null")) {statement.setDouble(x++, Double.parseDouble(revenue));}
				else{statement.setDouble(x++,0);}
                if (!total_order.equals("null")) {statement.setDouble(x++, Double.parseDouble(total_order));}
				else{statement.setDouble(x++,0);}
                 if (!total_revenue.equals("null")) {statement.setDouble(x++, Double.parseDouble(total_revenue));}
				else{statement.setDouble(x++,0);}
                if (!total_qty.equals("null")) {statement.setDouble(x++, Double.parseDouble(total_qty));}
				else{statement.setDouble(x++,0);}
                statement.setString(x++,activity_date);
                statement.setString(x++,last_update_date);
                statement.executeUpdate();
  
           }
             
            catch (Exception exception) {
                System.out.println("Save Function : WebPush Activity Day " + exception);
                throw new Exception(exception);
            }
            finally {
				if (statement != null) statement.close();
				if(connection!=null)connectionPool.free(connection);
		   }
    }
      public String Deger(NodeList g1){

            String deger=null;

            if(g1.getLength()>0){
                Element g1_Element = (Element)g1.item(0);
                NodeList text_g1 = g1_Element.getChildNodes();
                if(text_g1.item(0) != null ){
                    deger=((Node)text_g1.item(0)).getNodeValue().trim();
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
     if(logger == null){
		logger = Logger.getLogger(this.getClass().getName());
	}
    try {
            System.out.println("WebPush Activity Day is loading...");
            BufferedReader bufferedReader         = new BufferedReader(new InputStreamReader((request.getInputStream()),"UTF-8"));
            DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder               = builderFactory.newDocumentBuilder();
            Document document                     = builder.parse(new InputSource(bufferedReader));
        
        try {
            NodeList nodeList = document.getElementsByTagName("webpush_activity_day");

            for (int i=0;i<nodeList.getLength();i++){
				NewWebPushActivityDay report1 = new NewWebPushActivityDay((Element) nodeList.item(i));
				report1.save();
			}

        }
        catch (Exception e){
			System.out.println("Nodelist initialize error"+e);
		}
    }
    catch (Exception ex) {
		logger.error("Webpush Activity Day Update Error!\r\n", ex);
	}
%>
