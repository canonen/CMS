<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.sql.*,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URL" %>
<%@ page import="com.britemoon.cps.imc.Service" %>
<%@ page import="com.britemoon.cps.imc.Services" %>
<%! static Logger logger = null;%>
<%
    class AttributeModel {
        int attr_id;
        String attr_name;
        String attr_tag_name;
        int type_id;
        int cust_id;
        int is_list;

        public int getAttr_id() {
            return attr_id;
        }

        public void setAttr_id(int attr_id) {
            this.attr_id = attr_id;
        }

        public String getAttr_name() {
            return attr_name;
        }

        public void setAttr_name(String attr_name) {
            this.attr_name = attr_name;
        }

        public String getAttr_tag_name() {
            return attr_tag_name;
        }

        public void setAttr_tag_name(String attr_tag_name) {
            this.attr_tag_name = attr_tag_name;
        }

        public int getType_id() {
            return type_id;
        }

        public void setType_id(int type_id) {
            this.type_id = type_id;
        }

        public int getCust_id() {
            return cust_id;
        }

        public void setCust_id(int cust_id) {
            this.cust_id = cust_id;
        }

        public int getIs_list() {
            return is_list;
        }

        public void setIs_list(int is_list) {
            this.is_list = is_list;
        }
    }
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%

    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }



    String sCustId = cust.s_cust_id;


    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
    service = (Service) services.get(0);


    String refresh_url = "https://" + service.getURL().getHost() + "/rrcp/imc/xml/AttributeXMLParse.jsp?cust_id=" + sCustId;
    String refresh_search_url = "https://" + service.getURL().getHost() + "/rrcp/imc/perssearch/index.jsp?cust_id=" + sCustId;
    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;
    List<AttributeModel> attributeModelList = new ArrayList<AttributeModel>();
    String sslCheck = "";
    int i = 0;
    boolean isNotEmpty = true;

    try {
        System.out.println("ProductDashBoard is loading...");
        cp = ConnectionPool.getInstance();

        if (cp == null) {
            out.println("Cust ID Bulunmamadi");
        }

        conn = cp.getConnection(this);
        stmt = conn.createStatement();

            String isExist = ("SELECT attr_id,attr_name,attr_tag_name FROM ccps_product_attribute where cust_id = "+ sCustId +" order by attr_id");


        rs = stmt.executeQuery(isExist);
        while (rs.next()) {
            AttributeModel attr = new AttributeModel();
            attr.setAttr_id(rs.getInt(1));
            attr.setAttr_name(rs.getString(2));
            attr.setAttr_tag_name(rs.getString(3));

            attributeModelList.add(attr);

        }
        rs.close();

        isNotEmpty = attributeModelList.size()>0;

        sslCheck = isNotEmpty ? attributeModelList.get(35).getAttr_tag_name() : "";

    } catch (Exception e) {
        out.println("hata var" + e);
    } finally {
        stmt.close();
        conn.close();

    }

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Product Dashboard</title>

    <link rel="stylesheet" href="./dist/css/AdminLTEUpdated.css">
    <link rel="stylesheet" href="./dist/css/adminlte.min.css">
    <link rel="stylesheet" href="./dist/css/select2.min.css">
    <link rel="stylesheet" href="./dist/css/all.min.css">
    <link rel="stylesheet" href="./assets/css/daterangepicker/daterangepicker.css">
    <link rel="stylesheet" href="./dist/css/icheck-bootstrap.min.css">
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
    <style>
        body {
            font-family: 'Source Sans Pro', 'Helvetica Neue', Helvetica, Arial, sans-serif !important;
        }

        button.btn-primary:not(.btn-danger), label.btn-primary, .nav-link.active {
            background-color: #3c8dbc !important;
            border-color: #367fa9 !important;
        }

        .rvts_personalized_search_main-filter-item:hover {
            background-color: rgba(204, 204, 204, 0.1);
        }

        .rvts_personalized_search_main-filter > div:nth-child(1) {
            font-family: Tahoma, Arial, sans-serif;
            font-weight: 700;
            font-size: 15px;
            margin: 15px 0 5px 10px;
            display: flex !important;
            align-items: center;
            cursor: pointer;
            margin: 5px 0 5px 10px;
        }

        f
        .rvts_personalized_search_main-filter {
            height: 100%;
            width: 100%;
            box-shadow: 0px 2px 3px 0 rgba(0, 0, 0, 0.1), 0px -2px 3px 0px rgba(0, 1, 0, 0.1);
            margin: 10px;
        }

        .rvts_personalized_search_main-filter > div:nth-child(1) > span {
            width: 100%;
        }

        .rvts_personalized_search_main-filter-select {
            display: flex;
            flex-direction: column;
            transition: height 250ms ease 0s;
            overflow: hidden;
        }

        .rvts_personalized_search_main-filter-select > div:nth-child(1) {
            text-align: center;
        }

        .rvts_personalized_search_main-filter-select > div:nth-child(2) {
            overflow-y: scroll;
        }

        .rvts_personalized_search_main-filter-range {
            display: flex;
            justify-content: space-evenly;
            align-items: center;
            transition: height 250ms ease 0s;
            overflow-y: scroll;
        }

        .rvts_personalized_search_main-filter-range > input {
            width: 30%;
            text-align: center;
        }

        .rvts_personalized_search_main-filter-item {
            display: flex;
            align-items: center;
        }

        .rvts_personalized_search_main-filter-item > label {
            width: 100%;
            margin: 0;
            font-weight: 100 !important;
        }

        .rvts_personalized_search_main-filter-expand-select {
            height: 150px !important;
        }

        .rvts_personalized_search_main-filter-expand-range {
            height: 60px !important;
        }

    </style>
    <style>
        #popular_queries td, #failed_queries td, #top_performing_queries td, #queries_without_purchase td {
            padding: 0.3rem;
        }

        .table > thead > tr > th {
            padding: 0.3rem;
        }

        #chart-container-error {
            font-size: 16px;
            line-height: 32px;
            text-align: center;
            color: #fff;
            background-color: #FAA926;
        }

        .scroll {
            max-height: 400px;
            overflow-y: auto;
        }

        /*::-webkit-scrollbar {*/
        /* width: 20px;*/
        /*}*/

        .scrollbar {
            /*margin-left: 30px;*/
            float: left;
            height: 770px;
            width: 102%;
            background: white;
            overflow-y: scroll;
        }

        #wrapper {
            text-align: center;
            width: 500px;
            margin: auto;
        }

        #style-7::-webkit-scrollbar-track {
            -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
            background-color: #F5F5F5;
            border-radius: 10px;
        }

        #style-7::-webkit-scrollbar {
            width: 5px;
            background-color: #F5F5F5;
        }

        #style-7::-webkit-scrollbar-thumb {
            border-radius: 10px;
            background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.44, rgb(5, 168, 207)),
            color-stop(0.72, rgb(54, 139, 160)), color-stop(0.86, rgb(47, 105, 119)))
        }

        #perssearch_report {
            font-size: 13px;
        }


    </style>
</head>
<body>

<script>
    function addCustomField() {
        var custom_label = document.querySelector('.customLabel');
        var newDiv = document.createElement('div');
        newDiv.classList.add('row');
        newDiv.classList.add('col-md-8');
        newDiv.innerHTML = '<div class="form-group col-3"> <input type="text"  class="form-control custom_field_name " placeholder="Attribute Name"> </div> <div class="form-group col-6"> <input type="text" class="form-control custom_field_tag" placeholder="Attribute Tag Name"> </div> <div class="form-group col-2 form-group"><select class="form-control custom_field_type" id="sel1"><option>Text</option> <option>Number</option><option>Date</option><option>String</option><option>Money</option></select></div> <div class="form-group col-1"><button onclick="deleteCustomField(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button></div>';
        custom_label.appendChild(newDiv);

        var i = 1;
        $('.custom_field_name').each(function () {
            var customID = 'custom_field_name' + String(i);
            $(this).attr('id', customID);
            $(this).attr('name', customID);
            i++;
            console.log(this)
        });

        i = 1;

        $('.custom_field_tag').each(function () {
            var customID = 'custom_field_tag' + String(i);
            $(this).attr('id', customID);
            $(this).attr('name', customID);
            i++;
            console.log(this)
        });

        i = 1;

        $('.custom_field_type').each(function () {
            var customID = 'custom_field_type' + String(i);
            $(this).attr('id', customID);
            $(this).attr('name', customID);
            i++;
            console.log(this)
        });

    }

    function deleteCustomField(element) {
        element.parentNode.parentNode.remove();

        var i = 1;
        $('.custom_field_name').each(function () {
            var customID = 'custom_field_name' + String(i);
            $(this).attr('id', customID);
            $(this).attr('name', customID);
            i++;
            console.log(this)
        });

        i = 1;

        $('.custom_field_tag').each(function () {
            var customID = 'custom_field_tag' + String(i);
            $(this).attr('id', customID);
            $(this).attr('name', customID);
            i++;
            console.log(this)
        });

    }

    function disableAllButton() {
        $('.disButton').click(function (e) {
            e.preventDefault();
            //do other stuff when a click happens
        });
    }

</script>

<script src="./dist/js/jquery.min.js"></script>


<a href="<%=refresh_url%>" onclick="disableAllButton()"
   style="margin-top: 40px; margin-left:75px;margin-bottom:50px;" class="disButton btn btn-primary ">Refresh
    Products</a>

<a href="<%=refresh_search_url%>" onclick="disableAllButton()"
       style="margin-top: 40px; margin-left:120px;margin-bottom:50px;" class="disButton btn btn-primary ">Refresh Search</a>


<form action="SaveAttributes.jsp" method="POST" style="margin-left:75px">

    <input name="cust_id" value="<%=sCustId%>" hidden="hidden">

    <div class="tab-pane" id="xml_link">
        <div class="form-group row">
            <label for="xml_link_inp" class="col-md-2 col-form-label">Xml Link</label>
            <div class="col-md-4">
                <input name="xml_link"
                       value="<%= isNotEmpty? attributeModelList.get(33).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="xml_link_inp"
                       placeholder="example : http://www.revotas.com/xml/googleshopping.php">
            </div>
        </div>
    </div>

    <div class="tab-pane" id="product_seperator">
        <div class="form-group row">
            <label for="product_seperator_inp" class="col-md-2 col-form-label">Product Seperator</label>
            <div class="col-md-4">
                <input name="product_seperator"
                       value="<%=isNotEmpty?attributeModelList.get(34).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_seperator_inp" placeholder="example : item">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_id">
        <div class="form-group row">
            <label for="product_id_inp" class="col-md-2 col-form-label">Product ID</label>
            <div class="col-md-4">
                <input name="product_id"
                       value="<%=isNotEmpty?attributeModelList.get(1).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_id_inp" placeholder="example : g:id">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_name">
        <div class="form-group row">
            <label for="product_name_inp" class="col-md-2 col-form-label">Product Name</label>
            <div class="col-md-4">
                <input name="product_name"
                       value="<%=isNotEmpty?attributeModelList.get(3).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_name_inp" placeholder="example : g:title or title">
            </div>
        </div>
    </div>

    <div class="tab-pane" id="product_color">
        <div class="form-group row">
            <label for="product_color_inp" class="col-md-2 col-form-label">Product Color</label>
            <div class="col-md-4">
                <input name="product_color"
                       value="<%=isNotEmpty?attributeModelList.get(4).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_color_inp" placeholder="example : g:color">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_price">
        <div class="form-group row">
            <label for="product_price_inp" class="col-md-2 col-form-label">Product Price</label>
            <div class="col-md-4">
                <input name="product_price"
                       value="<%=isNotEmpty?attributeModelList.get(7).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_price_inp" placeholder="example : g:price">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_sale_price">
        <div class="form-group row">
            <label for="product_sale_price_inp" class="col-md-2 col-form-label">Product Sale Price</label>
            <div class="col-md-4">
                <input name="product_sale_price"
                       value="<%=isNotEmpty?attributeModelList.get(5).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_sale_price_inp" placeholder="example : g:sale_price">

            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_currency">
        <div class="form-group row">
            <label for="product_currency_inp" class="col-md-2 col-form-label">Product Currency</label>
            <div class="col-md-4">
                <input name="product_currency"
                       value="<%=attributeModelList.size() >= 36?attributeModelList.get(36).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_currency_inp" placeholder="example : g:currency">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_stock_count">
        <div class="form-group row">
            <label for="product_stock_count_inp" class="col-md-2 col-form-label">Product Stock Count</label>
            <div class="col-md-4">
                <input name="product_stock_count"
                       value="<%=isNotEmpty?attributeModelList.get(12).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_stock_count_inp" placeholder="example : g:stock_count">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_stock_status">
        <div class="form-group row">
            <label for="product_stock_status_inp" class="col-md-2 col-form-label">Product Stock Status</label>
            <div class="col-md-4">
                <input name="product_stock_status"
                       value="<%=isNotEmpty?attributeModelList.get(13).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_stock_status_inp" placeholder="example : g:availability">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_brand">
        <div class="form-group row">
            <label for="product_brand_inp" class="col-md-2 col-form-label"> Product Brand</label>
            <div class="col-md-4">
                <input name="product_brand"
                       value="<%=isNotEmpty?attributeModelList.get(14).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_brand_inp" placeholder="example : g:brand">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_categories">
        <div class="form-group row">
            <label for="product_categories_inp" class="col-md-2 col-form-label"> Product Categories</label>
            <div class="col-md-4">
                <input name="product_categories"
                       value="<%=isNotEmpty?attributeModelList.get(15).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_categories_inp" placeholder="example : g:product_type">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_link">
        <div class="form-group row">
            <label for="product_link_inp" class="col-md-2 col-form-label"> Product Link</label>
            <div class="col-md-4">
                <input name="product_link"
                       value="<%=isNotEmpty?attributeModelList.get(26).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_link_inp" placeholder="example : g:link">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_image_link">
        <div class="form-group row">
            <label for="product_image_link_inp" class="col-md-2 col-form-label"> Product Image Link</label>
            <div class="col-md-4">
                <input name="product_image_link"
                       value="<%=isNotEmpty?attributeModelList.get(27).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_image_link_inp" placeholder="example : g:image_link">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_rate">
        <div class="form-group row">
            <label for="product_rate_inp" class="col-md-2 col-form-label"> Product Rate</label>
            <div class="col-md-4">
                <input name="product_rate"
                       value="<%=isNotEmpty?attributeModelList.get(28).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_rate_inp" placeholder="example : g:product_rate">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_gender">
        <div class="form-group row">
            <label for="product_gender_inp" class="col-md-2 col-form-label"> Product Gender</label>
            <div class="col-md-4">
                <input name="product_gender"
                       value="<%=isNotEmpty?attributeModelList.get(29).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_gender_inp" placeholder="example : g:gender">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_size">
        <div class="form-group row">
            <label for="product_size_inp" class="col-md-2 col-form-label"> Product Size</label>
            <div class="col-md-4">
                <input name="product_size"
                       value="<%=isNotEmpty?attributeModelList.get(30).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_size_inp" placeholder="example : g:size">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_model">
        <div class="form-group row">
            <label for="product_model_inp" class="col-md-2 col-form-label"> Product Model</label>
            <div class="col-md-4">
                <input name="product_model"
                       value="<%=isNotEmpty?attributeModelList.get(31).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_model_inp" placeholder="example : g:model">
            </div>
        </div>
    </div>
    <div class="tab-pane" id="product_sku_code">
        <div class="form-group row">
            <label for="product_sku_code_inp" class="col-md-2 col-form-label"> Product Sku Code</label>
            <div class="col-md-4">
                <input name="product_sku_code"
                       value="<%=isNotEmpty?attributeModelList.get(32).getAttr_tag_name() : ""%>"
                       type="text"
                       class="form-control" id="product_sku_code_inp" placeholder="example : g:gtin or g:mpn">
            </div>
        </div>
    </div>

    <%
        if (attributeModelList.size() > 37) {
            for (int j = 37; j < attributeModelList.size(); j++) {
    %>
    <div class="tab-pane" id="<%=attributeModelList.get(j).getAttr_name()%>">
        <div class="form-group row">
            <label for="product_sku_code_inp"
                   class="col-md-2 col-form-label"><%=attributeModelList.get(j).getAttr_name() %>
            </label>
            <div class="col-md-4">
                <input name="<%=attributeModelList.get(j).getAttr_name()%>"
                       value="<%=attributeModelList.get(j).getAttr_tag_name()%>" type="text" class="form-control">
            </div>
            <div class=col-md-1">
                <button onclick="deleteCustomField(this)" style="display: flex; justify-content: center;" type="button"
                        class="btn btn-block btn-danger disButton ">X
                </button>
            </div>
        </div>
    </div>
    <%

            }
        }
    %>


    <div class="tab-pane" id="ssl">
        <div class="form-group row">
            <label for="ssl_inp" class="col-md-2 col-form-label"> SSL</label>

            <div class="col-md-3">
                <input name="ssl" <%= sslCheck.equals("1")?"checked":""%>
                       type="checkbox" id="ssl_inp">
            </div>
        </div>
    </div>
    <div class="customLabel">
    </div>


    <div class="form-group row" style="text-align:center">
        <button type="button" class="btn btn-primary disButton" onclick="addCustomField()">ADD CUSTOM FIELD</button>
        <button STYLE="margin-left: 50px" type="submit" onclick="disableAllButton()" class="btn btn-primary disButton">
            SAVE
        </button>
    </div>

</form>


</body>
</html>

