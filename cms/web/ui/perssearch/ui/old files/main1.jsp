<%@ page language="java" import="com.britemoon.*,
			com.britemoon.cps.*,
            com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.util.Calendar,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*" contentType="text/html;charset=UTF-8" %>
    <%@ include file="../../jsp/validator.jsp" %>

        <% Service service=null; Vector services=Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
            service=(Service) services.get(0); String rcpUrl=service.getURL().getHost(); ConnectionPool cp=null;
            Connection conn=null; Statement stmt=null; PreparedStatement pstmt=null; ResultSet rs=null; String
            tarih_aralik=request.getParameter("tarih_aralik"); String config_param=null; Long status=null; try {
            cp=ConnectionPool.getInstance(); conn=cp.getConnection("recommendation_main.jsp"); %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>Document</title>

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

                    button.btn-primary:not(.btn-danger),
                    label.btn-primary,
                    .nav-link.active {
                        background-color: #3c8dbc !important;
                        border-color: 367fa9 !important;
                    }

                    .rvts_personalized_search_main-filter-item:hover {
                        background-color: rgba(204, 204, 204, 0.1);
                    }

                    .rvts_personalized_search_main-filter>div:nth-child(1) {
                        font-family: Tahoma, Arial, sans-serif;
                        font-weight: 700;
                        font-size: 15px;
                        margin: 15px 0 5px 10px;
                        display: flex !important;
                        align-items: center;
                        cursor: pointer;
                        margin: 5px 0 5px 10px;
                    }

                    .rvts_personalized_search_main-filter {
                        height: 100%;
                        width: 100%;
                        box-shadow: 0px 2px 3px 0 rgba(0, 0, 0, 0.1), 0px -2px 3px 0px rgba(0, 1, 0, 0.1);
                        margin: 10px;
                    }

                    .rvts_personalized_search_main-filter>div:nth-child(1)>span {
                        width: 100%;
                    }

                    .rvts_personalized_search_main-filter-select {
                        display: flex;
                        flex-direction: column;
                        transition: height 250ms ease 0s;
                        overflow: hidden;
                    }

                    .rvts_personalized_search_main-filter-select>div:nth-child(1) {
                        text-align: center;
                    }

                    .rvts_personalized_search_main-filter-select>div:nth-child(2) {
                        overflow-y: scroll;
                    }

                    .rvts_personalized_search_main-filter-range {
                        display: flex;
                        justify-content: space-evenly;
                        align-items: center;
                        transition: height 250ms ease 0s;
                        overflow-y: scroll;
                    }

                    .rvts_personalized_search_main-filter-range>input {
                        width: 30%;
                        text-align: center;
                    }

                    .rvts_personalized_search_main-filter-item {
                        display: flex;
                        align-items: center;
                    }

                    .rvts_personalized_search_main-filter-item>label {
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
                    #popular_queries td,
                    #failed_queries td,
                    #top_performing_queries td,
                    #queries_without_purchase td {
                        padding: 0.3rem;
                    }

                    .table>thead>tr>th {
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
                    /*    width: 20px;*/
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
                        background-image: -webkit-gradient(linear, left bottom, left top, color-stop(0.44, rgb(5, 168, 207)), color-stop(0.72, rgb(54, 139, 160)), color-stop(0.86, rgb(47, 105, 119)))
                    }

                    #perssearch_report {
                        font-size: 13px;
                    }

                    .condition-group {
                        margin: 5px;
                        padding: 5px;
                        border: 1px solid #ced4da;
                        border-radius: 5px;
                    }

                    .condition-segment {
                        margin: 20px;
                    }

                    .condition-div {
                        display: flex;
                        align-items: center;
                    }

                    .condition-select {
                        width: auto;
                        height: 25px;
                        margin: 3px;
                        padding: 3px;
                    }

                    .condition-input {
                        width: 50px;
                        height: auto;
                        display: inline;
                    }

                    .product-filtering-button {
                        background-color: #59c8e6;
                        color: white;
                        border: 1px solid #59c8e6;
                        border-radius: 5px;
                        padding: 5px;
                        cursor: pointer;
                    }

                    .product-filtering-button:hover {
                        background-color: #286090;
                        border-color: #27557b;
                    }

                    .button-red {
                        background-color: #d9534f !important;
                        border: 1px solid #ac2925;
                        padding: 6px 12px;
                    }

                    .button-red:hover {
                        background-color: #c9302c !important;
                        border-color: #c62d28 !important;
                    }
                </style>
            </head>

            <body>
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header p-2">
                            <ul class="nav nav-pills">
                                <li class="nav-item"><a class="nav-link <%if(tarih_aralik == null){%>active<%}%>"
                                        href="#search" data-toggle="tab">Search</a></li>
                                <li class="nav-item"><a class="nav-link" href="#filters" data-toggle="tab">Filters</a>
                                </li>
                                <li class="nav-item"><a class="nav-link" href="#category" data-toggle="tab">Category</a>
                                </li>
                                <li class="nav-item"><a class="nav-link" href="#query" data-toggle="tab">Query</a></li>
                                <li class="nav-item"><a class="nav-link" href="#synonyms" data-toggle="tab">Synonyms</a>
                                </li>
                                <li class="nav-item"><a class="nav-link" href="#redirects"
                                        data-toggle="tab">Redirects</a></li>
                                <li class="nav-item"><a class="nav-link" href="#csstab" data-toggle="tab">CSS</a></li>
                                <li class="nav-item"><a class="nav-link" href="#product_filter"
                                        data-toggle="tab">Product Filtering</a></li>
                                <li class="nav-item"><a class="nav-link" href="#campaign_code"
                                        data-toggle="tab">Code</a></li>
                                <li class="nav-item"><a class="nav-link <%if(tarih_aralik != null){%>active<%}%>"
                                        href="#perssearch_report" data-toggle="tab">Report</a></li>
                                <button style="margin-left:auto;" id="save_button" type="submit" class="btn btn-primary"
                                    onclick="saveConfigurations(<%=cust.s_cust_id%>,this)" disabled>Save</button>

                            </ul>
                        </div><!-- /.card-header -->
                        <div class="card-body">
                            <div class="tab-content">
                                <div class="tab-pane <%if(tarih_aralik == null){%>active<%}%>" id="search">
                                    <form class="form-horizontal">
                                        <div class="form-group col-md-6 row">
                                            <div class="icheck-primary d-inline">
                                                <input type="checkbox" id="searchStatus">
                                                <label for="searchStatus">
                                                    Enabled
                                                </label>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-6 row">
                                            <div class="icheck-primary d-inline">
                                                <input type="checkbox" id="showLastSearch">
                                                <label for="showLastSearch">
                                                    Show Last Searches
                                                </label>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-6 row">
                                            <div class="icheck-primary d-inline">
                                                <input type="checkbox" id="appendUTM" checked>
                                                <label for="appendUTM">
                                                    Append UTM to links
                                                </label>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-6 row">
                                            <label>Sort Criteria</label>
                                            <select id="sortCriteria" class="form-control select2" style="width: 100%;">
                                                <option value="date">Date</option>
                                                <option value="order">Order</option>
                                            </select>
                                        </div>
                                        <div class="form-group col-md-6 row">
                                            <label>Fallback Scenario</label>
                                            <select id="fallbackScenario" class="form-control select2"
                                                style="width: 100%;">
                                                <option value="50">Top Seller</option>
                                                <option value="60">Price Drop</option>
                                                <option value="70">New Product</option>
                                                <option value="80">Back in Stock</option>
                                                <option value="90">Buy Also</option>
                                                <option value="100">Similar</option>
                                                <option value="110">You Might</option>
                                                <option value="120">View Also</option>
                                                <option value="140">Trending</option>
                                            </select>
                                        </div>
                                        <div class="form-group row">
                                            <label for="inputSelector" class="col-md-2 col-form-label">Input
                                                Selector</label>
                                            <div class="col-md-4">
                                                <input type="text" class="form-control" id="inputSelector"
                                                    placeholder="#input_selector|.input_selector">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="submitSelector" class="col-md-2 col-form-label">Submit
                                                Selector</label>
                                            <div class="col-md-4">
                                                <input type="text" class="form-control" id="submitSelector"
                                                    placeholder="querySelector(...)...">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="title" class="col-md-2 col-form-label">Title</label>
                                            <div class="col-md-4">
                                                <input type="text" class="form-control" id="title"
                                                    placeholder="Search results for you">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="resultLimit" class="col-md-2 col-form-label">Result
                                                Limit</label>
                                            <div class="col-md-4">
                                                <input onchange="handleChange(this)" type="number" class="form-control"
                                                    id="resultLimit" placeholder="Result Limit" value="6" min="1"
                                                    max="9">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="lastSearchTitle" class="col-md-2 col-form-label">Last Search
                                                Title</label>
                                            <div class="col-md-4">
                                                <input type="text" class="form-control" id="lastSearchTitle"
                                                    placeholder="Your last searches">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="recentlyViewedTitle" class="col-md-2 col-form-label">Recently
                                                Viewed Title</label>
                                            <div class="col-md-4">
                                                <input type="text" class="form-control" id="recentlyViewedTitle"
                                                    placeholder="Recently Viewed Products">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="placeholderItems" class="col-md-2 col-form-label">Placeholder Words</label>
                                            <div class="col-md-4">
                                                <input type="text" class="form-control" id="placeholderItems"
                                                    placeholder="Jean, Sweat, ...">
                                            </div>
                                        </div>
                                        <div class="col-md-12">
                                            <div class="form-group row">
                                                <label for="perSearch_image_link" class="col-form-label">Image
                                                    Link</label>
                                                <input type="text" class="form-control no-preview"
                                                    name="perSearch_image_link" id="perSearch_image_link"
                                                    placeholder="Image link">
                                                <input class="no-preview" type="file"
                                                    accept="image/png, image/jpeg, image/jpg, image/gif"
                                                    id="perSearchImageUpload" name="perSearchImageUpload">
                                                <button id="perSearchSelectImageUpload"
                                                    style="margin-left:auto;display:none;" class="btn btn-primary"
                                                    onclick="perSearchImageUpload(this)">Upload</button>
                                                <input type="button" id="deleteImage" name="deleteImage"
                                                    value="Delete"></input>

                                            </div>
                                        </div>
                                        <div class="col-md-12">
                                            <div class="form-group row">
                                                <label class="col-form-label" for="imageLink">Link (When click
                                                    image)</label>
                                                <input type="text" id="imageLink" name="imageLink"
                                                    class="form-control no-preview" placeholder="link"></input>
                                            </div>
                                        </div>
                                        <div class="col-md-12">
                                            <img id="search-image"></img>
                                        </div>

                                    </form>
                                </div>
                                <!-- /.tab-pane -->
                                <div class="tab-pane" id="filters">
                                    <div class="form-group row">
                                    </div>
                                </div>
                                <!-- /.tab-pane -->
                                <div class="tab-pane" id="category">
                                    <div class="form-group row">
                                        <label for="categoriesTitle" class="col-md-2 col-form-label">Categories
                                            Title</label>
                                        <div class="col-md-4">
                                            <input type="text" class="form-control" id="categoriesTitle"
                                                placeholder="Categories">
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label for="categoriesLimit" class="col-md-2 col-form-label">Categories
                                            Limit</label>
                                        <div class="col-md-4">
                                            <input onchange="handleChange(this)" type="number" class="form-control"
                                                id="categoriesLimit" placeholder="Result Limit" value="5" min="1"
                                                max="5">
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-md-2 col-form-label">Categories</label>
                                    </div>
                                    <div class="categories">
                                    </div>

                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addCategory()">+</button>
                                    </div>
                                </div>
                                <!-- /.tab-pane -->
                                <div class="tab-pane" id="query">
                                    <div class="form-group row">
                                        <label for="recommendedQueriesTitle" class="col-md-3 col-form-label">Recommended
                                            Queries Title</label>
                                        <div class="col-md-4">
                                            <input type="text" class="form-control" id="recommendedQueriesTitle"
                                                placeholder="Recommended searches">
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label for="queryPattern" class="col-md-3 col-form-label">QueryPattern</label>
                                        <div class="col-md-4">
                                            <input type="text" class="form-control" id="queryPattern"
                                                placeholder="search&keyword=<_Query_>">
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-md-3 col-form-label">Recommended Queries</label>
                                    </div>
                                    <div class="queries">
                                    </div>

                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addQuery()">+</button>
                                    </div>
                                </div>
                                <div class="tab-pane" id="synonyms">
                                    <div class="synonyms">
                                    </div>

                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addSynonym()">+</button>
                                    </div>
                                </div>
                                <div class="tab-pane" id="redirects">
                                    <div class="redirects">
                                    </div>

                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addRedirect()">+</button>
                                    </div>
                                </div>
                                <!-- /.tab-pane -->

                                <!-- /.tab-pane -->

                                <div class="tab-pane" id="csstab">
                                    <div class="form-group col-md-12">
                                        <label for="inputDescription">CSS</label>
                                        <textarea id="css" class="form-control" rows="15"></textarea>
                                    </div>
                                </div>
                                <div class="tab-pane" id="product_filter">
                                    <div class="form-group row">
                                        <label class="col-md-1 col-form-label">Filter List</label>
                                        <select id="productFilters" class="form-control select2 col-md-4"></select>
                                    </div>
                                    <div class="form-group row">
                                        <div class="col-md-1">
                                            <button id="new-condition" class="btn btn-primary">New</button>
                                        </div>
                                        <input class="form-control col-md-4" id="filterName" value="" />
                                    </div>
                                    <div class="input-group condition-configs">
                                        <div class="condition-panel">
                                            <button style="margin-left:5px;display:none;"
                                                class="product-filtering-button btn btn-primary"
                                                onclick="groupConditions(this)" id="group-conditions">Group
                                                Conditions</button>
                                            <button style="margin-left:5px;display:none;"
                                                class="product-filtering-button btn btn-primary"
                                                onclick="removeGroup(this)" id="remove-group">Remove Group</button>
                                            <button style="margin-left:5px;display:none;"
                                                class="product-filtering-button btn btn-primary"
                                                onclick="ungroupConditions(this)" id="ungroup-conditions">Ungroup
                                                conditions</button>
                                            <div class="condition-segment" style="display: flex;"></div>
                                        </div>
                                    </div>
                                    <button id="save-conditions" class="btn btn-primary" disabled>Save Filter</button>
                                    <button id="delete-condition" class="btn btn-primary" disabled>Delete</button>
                                    <div style="margin-top:10px;" class="form-group col-md-6 row">
                                        <div class="icheck-primary d-inline">
                                            <input type="checkbox" id="excludeRecentlyViewed">
                                            <label for="excludeRecentlyViewed">
                                                Exclude Recently Viewed Items
                                            </label>
                                        </div>
                                    </div>
                                    <div class="form-group col-md-6 row">
                                        <div class="icheck-primary d-inline">
                                            <input type="checkbox" id="excludeRecentlyPurchased">
                                            <label for="excludeRecentlyPurchased">
                                                Exclude Recently Purchased Items
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <!-- /.tab-pane -->
                                <div class="tab-pane" id="campaign_code">
                                    <div class="form-group col-md-12">
                                        <textarea onclick="selectAll(this)" id="jsCode" class="form-control" rows="13"
                                            readonly>
                                            
<script>
    if (!window['rvtsPersSearchArray'])
        window['rvtsPersSearchArray'] = [];
    rvtsPersSearchArray.push({ rvts_customer_id: '<%=cust.s_cust_id%>' });
    (function () {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://<%=cust.s_login_name%>.revotas.com/trc/perssearch/perssearch.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
</script></textarea>
                                    </div>
                                </div>

                                <!-- /.tab-pane -->
                                <div class="tab-pane <%if(tarih_aralik != null){%>active<%}%>" id="perssearch_report">
                                    <div class="row">
                                        <div class="col-12">
                                            <form method="post" action="main.jsp">
                                                <div class="row" style="justify-content: flex-end;">
                                                    <div class="col-xs-6">
                                                        <div class="form-group">
                                                            <div class="input-group">
                                                                <input type="text" name="tarih_aralik"
                                                                    class="form-control pull-right" id="tarih_aralik">
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-xs-4">
                                                        <button type="submit" class="btn btn-primary">Submit</button>
                                                    </div>

                                                </div>

                                            </form>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-12 col-sm-6 col-md-4">
                                            <div class="info-box">
                                                <span style="background-color: #e66eaa !important"
                                                    class="info-box-icon bg-info elevation-2"><i
                                                        class="fas fa-circle-notch"></i></span>

                                                <div class="info-box-content">
                                                    <span class="info-box-text">Total Count</span>
                                                    <span class="info-box-number" id="total-count">0</span>
                                                </div>
                                                <!-- /.info-box-content -->
                                            </div>
                                            <!-- /.info-box -->
                                        </div>
                                        <div class="col-12 col-sm-6 col-md-4">
                                            <div class="info-box">
                                                <span style="background-color:#f56954 !important"
                                                    class="info-box-icon bg-info elevation-2"><i
                                                        class="fas fa-shopping-bag"></i></span>

                                                <div class="info-box-content">
                                                    <span class="info-box-text">Total Conversion</span>
                                                    <span class="info-box-number" id="total-conversion">0</span>
                                                </div>
                                                <!-- /.info-box-content -->
                                            </div>
                                            <!-- /.info-box -->
                                        </div>
                                        <div class="col-12 col-sm-6 col-md-4">
                                            <div class="info-box">
                                                <span style="background-color:#faa926 !important"
                                                    class="info-box-icon bg-info elevation-2"><i
                                                        class="fas fa-cash-register"></i></span>

                                                <div class="info-box-content">
                                                    <span class="info-box-text">Total Revenue</span>
                                                    <span class="info-box-number" id="total-revenue">0</span>
                                                </div>
                                                <!-- /.info-box-content -->
                                            </div>
                                            <!-- /.info-box -->
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <div class="col-md-3 col-sm-6 col-xs-12">
                                            <div class="box box-info">
                                                <div class="box-header with-border">
                                                    <h3 class="box-title">Popular Queries</h3>
                                                </div>
                                                <!-- /.card-header -->
                                                <div class="box-body">
                                                    <div class="scrollbar" id="style-7">
                                                        <div class="force-overflow">
                                                            <div class="table-responsive">
                                                                <table id="popular_queries_table"
                                                                    class="table no-margin">
                                                                    <thead>
                                                                        <tr>
                                                                            <th onclick="sortTableString(0, 'popular_queries_table')"
                                                                                style="cursor:pointer">Query</th>
                                                                            <th onclick="sortTableInt(1, 'popular_queries_table')"
                                                                                style="cursor:pointer">Count</th>
                                                                            <th onclick="sortTableInt(2, 'popular_queries_table')"
                                                                                style="cursor:pointer">Conversion</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody id="popular_queries">
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-6 col-xs-12">
                                            <div class="box box-info">
                                                <div class="box-header with-border">
                                                    <h3 class="box-title">Failed Queries</h3>
                                                </div>
                                                <!-- /.card-header -->
                                                <div class="box-body">
                                                    <div class="scrollbar" id="style-7">
                                                        <div class="force-overflow">
                                                            <div class="table-responsive">
                                                                <table id="failed_queries_table"
                                                                    class="table no-margin">
                                                                    <thead>
                                                                        <tr>
                                                                            <th onclick="sortTableString(0, 'failed_queries_table')"
                                                                                style="cursor:pointer">Query</th>
                                                                            <th onclick="sortTableInt(1, 'failed_queries_table')"
                                                                                style="cursor:pointer">Count</th>
                                                                            <th>Synonym</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody id="failed_queries">
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-6 col-xs-12">
                                            <div class="box box-info">
                                                <div class="box-header with-border">
                                                    <h3 class="box-title">Top Performing Queries</h3>
                                                </div>
                                                <!-- /.card-header -->
                                                <div class="box-body">
                                                    <div class="scrollbar" id="style-7">
                                                        <div class="force-overflow">
                                                            <div class="table-responsive">
                                                                <table id="top_performing_queries_table"
                                                                    class="table no-margin">
                                                                    <thead>
                                                                        <tr>
                                                                            <th onclick="sortTableString(0, 'top_performing_queries_table')"
                                                                                style="cursor:pointer">Query</th>
                                                                            <th onclick="sortTableInt(1, 'top_performing_queries_table')"
                                                                                style="cursor:pointer">Count</th>
                                                                            <th onclick="sortTableCurrency(2, 'top_performing_queries_table')"
                                                                                style="cursor:pointer">Revenue</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody id="top_performing_queries">
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-6 col-xs-12">
                                            <div class="box box-info">
                                                <div class="box-header with-border">
                                                    <h3 class="box-title">Queries Without Purchases</h3>
                                                </div>
                                                <!-- /.card-header -->
                                                <div class="box-body">
                                                    <div class="scrollbar" id="style-7">
                                                        <div class="force-overflow">
                                                            <div class="table-responsive">
                                                                <table id="queries_without_purchase_table"
                                                                    class="table no-margin">
                                                                    <thead>
                                                                        <tr>
                                                                            <th onclick="sortTableString(0, 'queries_without_purchase_table')"
                                                                                style="cursor:pointer">Query</th>
                                                                            <th onclick="sortTableInt(1, 'queries_without_purchase_table')"
                                                                                style="cursor:pointer">Count</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody id="queries_without_purchase">
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>


                            </div>
                            <!-- /.tab-content -->
                        </div><!-- /.card-body -->
                    </div>

                    <!-- /.nav-tabs-custom -->
                </div>

                <% String sql="select config_param,status from " 
                + "c_personal_search_config where cust_id = ?" ;
                    pstmt=conn.prepareStatement(sql); 
                    int x=1; 
                    pstmt.setLong(x++,Long.parseLong(cust.s_cust_id));
                    rs=pstmt.executeQuery(); if(rs.next()) { config_param=rs.getString(1); status=rs.getLong(2); }
                    rs.close(); } catch(Exception e){ out.print(e); } finally{ try { if ( pstmt !=null ) pstmt.close();
                    } catch (Exception ignore) { } if ( conn !=null ) { cp.free(conn); } } %>




                    <script src="./dist/js/jquery.min.js"></script>
                    <script src="./dist/js/bootstrap.bundle.min.js"></script>
                    <script src="./dist/js/adminlte.min.js"></script>
                    <script src="./dist/js/select2.full.min.js"></script>
                    <script src="./assets/js/daterangepicker/moment.min.js"></script>
                    <script src="./assets/js/daterangepicker/daterangepicker.js"></script>

                    <script>

                        var custId = <%=cust.s_cust_id%>;

                        function numberToFixed(number, toFixed) {
                            number = number.toString();
                            var indexOfDot = number.indexOf('.');
                            if (indexOfDot !== -1) {
                                if (toFixed == 0) {
                                    number = number.substring(0, indexOfDot);
                                } else {
                                    number = number.split('').filter((e, i) => {
                                        return (indexOfDot + toFixed) >= i;
                                    }).join('');
                                    var decimalCount = number.length - indexOfDot - 1;
                                    if (toFixed > decimalCount) number = number.concat(Array.apply(null, Array(toFixed - decimalCount)).map(Number.prototype.valueOf, 0).join(''));
                                }
                            } else if (toFixed > 0) {
                                number = number.concat(['.']);
                                number = number.concat(Array.apply(null, Array(toFixed)).map(Number.prototype.valueOf, 0).join(''));
                            }
                            return number;
                        }

                        function formatCurrency(number, currencyConfig) {
                            var originalNumber = number;
                            try {
                                number = number.toString();
                                number = number.replace(/[^0-9.,]/g, '');
                                number = number.split(',').join('.');
                                number = parseFloat(number);
                                var indexOfComma = currencyConfig.format.indexOf(',');
                                var indexOfDot = currencyConfig.format.indexOf('.');
                                var thousandSeparator = indexOfComma < indexOfDot ? ',' : '.';
                                var decimalSeparator = indexOfComma < indexOfDot ? '.' : ',';
                                if (indexOfComma === -1 || indexOfDot === -1) thousandSeparator = '';
                                var decimalCount = currencyConfig.format.length - currencyConfig.format.indexOf(decimalSeparator) - 1;
                                number = numberToFixed(number, decimalCount);
                                var parts = number.split('.').length === 2 ? number.split('.') : number.split(',');
                                var normalPart = parts[0];
                                var decimalPart = parts[1] ? parts[1] : '';

                                normalPart = normalPart.split('').reverse().map((e, i, arr) => {
                                    if ((i + 1) % 3 === 0 && arr.length > (i + 1)) return thousandSeparator + e;
                                    else return e;
                                }).reverse().join('');
                                var currency = normalPart + (decimalPart ? (decimalSeparator + decimalPart) : '');
                                if (currencyConfig.language === 'EN') currency = currencyConfig.currency + currency;
                                else if (currencyConfig.language === 'TR') currency = currency + ' ' + currencyConfig.currency;
                                return currency;
                            } catch (e) {
                                return originalNumber;
                            }

                        }


                        var filterObj = {};
                        var configObj = JSON.parse(`<%=config_param%>`);
                        var status = <%=status%>;
                        console.log(configObj)

                        var greenTick = '<i class="fas fa-check-circle" style="color: green;"></i>';
                        var redCircle = '<i class="fas fa-times-circle" style="color: red;"></i>'

                        var excessPopularQueries = [];
                        var excessFailedQueries = [];
                        var excessTopPerformingQueries = [];
                        var excessQueriesWithoutPurchase = [];
                        var tarihAralik = '<%=tarih_aralik%>';
                        var tempStartDate = tarihAralik !== 'null' ? tarihAralik.split('-')[0].trim() : moment().startOf('month');
                        var tempEndDate = tarihAralik !== 'null' ? tarihAralik.split('-')[1].trim() : moment().endOf('month');
                        $('#tarih_aralik').daterangepicker({
                            ranges: {
                                'Today': [moment(), moment()],
                                'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                                'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                                'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                                'This Month': [moment().startOf('month'), moment().endOf('month')],
                                'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
                            },
                            startDate: tempStartDate,
                            endDate: tempEndDate,
                            locale: { format: 'YYYY/MM/DD' }
                        });


                        if (tarihAralik !== 'null') document.querySelector('input[name=tarih_aralik]').value = tarihAralik;

                        function showAll(element, arr) {
                            var table = element.parentNode.parentNode;
                            arr.forEach(e => {
                                table.appendChild(e);
                            });
                            element.remove();
                        }

                        function createSynonym(element) {
                            var original = element.parentNode.parentNode.children[0].innerText;
                            var synonym = prompt('Please enter synonym for "' + original + '"');
                            if (!synonym || synonym.trim() === '') return;
                            addSynonym(original, synonym.trim());
                            element.parentNode.style.textAlign = '';
                            element.parentNode.nextSibling.innerHTML = greenTick;
                            element.parentNode.textContent = synonym;
                        }

                        var rcpLink = '<%=rcpUrl%>';

                        fetch('https://' + rcpLink + '/rrcp/imc/perssearch/get_perssearch_data.jsp?cust_id=<%=cust.s_cust_id%>' + (tarihAralik != 'null' ? '&tarih_aralik=' + tarihAralik : ''))
                            .then(resp => resp.text())
                            .then(async function (response) {
                                var resp = JSON.parse(response.replace(/\t/g, ' '));
                                var totalCount = document.getElementById('total-count');
                                var totalConversion = document.getElementById('total-conversion');
                                var totalRevenue = document.getElementById('total-revenue');

                                totalCount.innerText = resp['Totals'][0].totalCount;
                                totalConversion.innerText = resp['Totals'][0].totalConversion;
                                await currencyPromise;
                                totalRevenue.innerText = formatCurrency(resp['Totals'][0].totalRevenue, currencyConfigs.filter(config => config.active == 1)[0]);

                                if (totalCount.innerText === 'null') totalCount.innerText = 0;
                                if (totalConversion.innerText === 'null') totalConversion.innerText = 0;
                                if (totalRevenue.innerText === 'null') totalRevenue.innerText = 0;

                                var popularQueries = document.getElementById('popular_queries');
                                var failedQueries = document.getElementById('failed_queries');
                                var topPerformingQueries = document.getElementById('top_performing_queries');
                                var queriesWithoutPurchase = document.getElementById('queries_without_purchase');
                                resp['Popular Queries'].forEach((entry, index) => {
                                    var newEntry = document.createElement('tr');
                                    newEntry.innerHTML = '<td></td><td>' + entry.count + '</td><td>' + entry.conversion + '</td>';
                                    newEntry.children[0].textContent = entry.query;
                                    if (index == 25) {
                                        var showAll = document.createElement('tr');
                                        showAll.innerHTML = '<button class="btn btn-primary" onclick="showAll(this, excessPopularQueries)" style="font-size: 12px;">Show All</button>';
                                        popularQueries.appendChild(showAll);
                                    }
                                    if (index >= 25) {
                                        excessPopularQueries.push(newEntry);
                                        return;
                                    }
                                    popularQueries.appendChild(newEntry);
                                });


                                var synonyms = configObj.synonyms;
                                var synonymList = {};
                                synonyms.forEach(synonym => {
                                    synonymList[decodeURIComponent(synonym.original).toLowerCase()] = decodeURIComponent(synonym.synonym);
                                });
                                resp['Failed Queries'] = resp['Failed Queries'].map(entry => {
                                    if (synonymList[entry.query.toLowerCase()]) {
                                        return { ...entry, synonym: synonymList[entry.query.toLowerCase()] };
                                    } else {
                                        return { ...entry, synonym: '' };
                                    }
                                })

                                resp['Failed Queries'].forEach((entry, index) => {
                                    var newEntry = document.createElement('tr');
                                    newEntry.innerHTML = '<td></td><td>' + entry.count + '</td><td ' + (entry.synonym == '' ? 'style="text-align:center"' : '') + '></td><td>' + (entry.synonym != '' ? greenTick : redCircle) + '</td>';
                                    newEntry.children[0].textContent = entry.query;
                                    if (entry.synonym) {
                                        newEntry.children[2].textContent = entry.synonym;
                                    } else {
                                        newEntry.children[2].innerHTML = '<a href="javascript:void(0);" onclick="createSynonym(this)">+</a>';
                                    }
                                    if (index == 25) {
                                        var showAll = document.createElement('tr');
                                        showAll.innerHTML = '<button class="btn btn-primary" onclick="showAll(this, excessFailedQueries)" style="font-size: 12px;">Show All</button>';
                                        failedQueries.appendChild(showAll);
                                    }
                                    if (index >= 25) {
                                        excessFailedQueries.push(newEntry);
                                        return;
                                    }
                                    failedQueries.appendChild(newEntry);
                                });
                                resp['Top Performing Queries'] = resp['Top Performing Queries'].filter(e => {
                                    return parseInt(e.revenue) > 0;
                                });
                                resp['Top Performing Queries'].forEach((entry, index) => {
                                    var newEntry = document.createElement('tr');
                                    newEntry.innerHTML = '<td></td><td>' + entry.count + '</td><td>' + formatCurrency(entry.revenue, currencyConfigs.filter(config => config.active == 1)[0]); +'</td>';
                                    newEntry.children[0].textContent = entry.query;
                                    if (index == 25) {
                                        var showAll = document.createElement('tr');
                                        showAll.innerHTML = '<button class="btn btn-primary" onclick="showAll(this, excessTopPerformingQueries)" style="font-size: 12px;">Show All</button>';
                                        topPerformingQueries.appendChild(showAll);
                                    }
                                    if (index >= 25) {
                                        excessTopPerformingQueries.push(newEntry);
                                        return;
                                    }
                                    topPerformingQueries.appendChild(newEntry);
                                });

                                resp['Queries Without Purchase'].forEach((entry, index) => {
                                    var newEntry = document.createElement('tr');
                                    newEntry.innerHTML = '<td></td><td>' + entry.count + '</td>';
                                    newEntry.children[0].textContent = entry.query;
                                    if (index == 25) {
                                        var showAll = document.createElement('tr');
                                        showAll.innerHTML = '<button class="btn btn-primary" onclick="showAll(this, excessQueriesWithoutPurchase)" style="font-size: 12px;">Show All</button>';
                                        queriesWithoutPurchase.appendChild(showAll);
                                    }
                                    if (index >= 25) {
                                        excessQueriesWithoutPurchase.push(newEntry);
                                        return;
                                    }
                                    queriesWithoutPurchase.appendChild(newEntry);
                                });
                            });
                    </script>
                    <%if(config_param!=null) {%>
                        <script>
                            var alreadyLoaded = true;
                        </script>
                        <%}%>
                            <script src="script2.js"></script>
                            <%if(config_param!=null) {%>
                                <script>
                                    renderConfigs(configObj, status);
                                </script>
                                <%}%>
                                    <script>

                                        var currencyFetched = null;
                                        var currencyFetchFailed = null;
                                        var filtersFetched = null;
                                        var filtersFetchFailed = null;
                                        var currencyConfigs = null;

                                        var currencyPromise = new Promise((resolve, reject) => {
                                            console.log(resolve)
                                            console.log(reject)
                                            currencyFetched = resolve;
                                            currencyFetchFailed = reject;
                                        });
                                        var filtersPromise = new Promise((resolve, reject) => {
                                            filtersFetched = resolve;
                                            filtersFetchFailed = reject;
                                        });
                                        let save_b_test = document.getElementById('save_button');
                                        if(configObj == null){
                                            configObj = {}
                                        }
                                        if(configObj !== null){
                                            Promise.all([currencyPromise, filtersPromise]).then(() => {
                                                save_b_test.removeAttribute('disabled');
                                        }).catch((error) => {
                                            console.error(error);
                                            alert('An error occurred while loading configurations!');
                                            location.reload();
                                        });
                                        }

                                        fetch('https://' + rcpLink + '/rrcp/imc/currency/get_currency_config.jsp?cust_id=<%=cust.s_cust_id%>')
                                            .then(resp => resp.json())
                                            .then(resp => {
                                                currencyConfigs = resp;
                                                currencyFetched();
                                            }).catch((error) => {
                                                currencyFetchFailed(error);
                                            });

                                        fetch('https://' + rcpLink + '/rrcp/imc/perssearch/get_perssearch_filters.jsp?cust_id=<%=cust.s_cust_id%>')
                                            .then(resp => resp.json())
                                            .then(resp => {

                                                var filterDiv = document.getElementById('filters').querySelector('div');
                                                var option = {
                                                    name: 'product_price',
                                                    title: 'Price',
                                                    type: 'range',
                                                    range: [0, 100]
                                                }
                                                var priceFilter = filterBox(option);
                                                priceFilter.toggle();
                                                priceFilter.element.classList.add('col-md-3');
                                                filterDiv.appendChild(priceFilter.element);
                                                filterObj['product_price'] = priceFilter;

                                                var categoryOption = {
                                                    title: 'Category',
                                                    type: 'select',
                                                    list: []
                                                }
                                                for (var key in resp) {
                                                    if (key === 'manufacturer_id' && resp[key].length > 0) {
                                                        var option = {
                                                            name: key,
                                                            title: 'Brand',
                                                            type: 'select',
                                                            list: []
                                                        }
                                                        resp[key].forEach(e => {
                                                            option.list.push({ string: e, meta: key });
                                                        });
                                                        var brandFilter = filterBox(option);
                                                        brandFilter.selectAll();
                                                        brandFilter.toggle();
                                                        brandFilter.element.classList.add('col-md-3');
                                                        filterDiv.appendChild(brandFilter.element);
                                                        filterObj[key] = brandFilter;
                                                    } else if (key === 'gender' && resp[key].length > 0) {
                                                        var option = {
                                                            name: key,
                                                            title: 'Gender',
                                                            type: 'select',
                                                            list: []
                                                        }
                                                        resp[key].forEach(e => {
                                                            option.list.push({ string: e, meta: key });
                                                        });
                                                        var genderFilter = filterBox(option);
                                                        genderFilter.selectAll();
                                                        genderFilter.toggle();
                                                        genderFilter.element.classList.add('col-md-3');
                                                        filterDiv.appendChild(genderFilter.element);
                                                        filterObj[key] = genderFilter;
                                                    } else if (key === 'product_color' && resp[key].length > 0) {
                                                        var option = {
                                                            name: key,
                                                            title: 'Color',
                                                            type: 'select',
                                                            list: []
                                                        }
                                                        resp[key].forEach(e => {
                                                            option.list.push({ string: e, meta: key });
                                                        });
                                                        var colorFilter = filterBox(option);
                                                        colorFilter.selectAll();
                                                        colorFilter.toggle();
                                                        colorFilter.element.classList.add('col-md-3');
                                                        filterDiv.appendChild(colorFilter.element);
                                                        filterObj[key] = colorFilter;
                                                    } else if (key === 'visible' && resp[key].length > 0) {
                                                        var option = {
                                                            name: key,
                                                            title: 'Stock Status',
                                                            type: 'select',
                                                            list: []
                                                        }
                                                        resp[key].forEach(e => {
                                                            option.list.push({ string: e, meta: key });
                                                        });
                                                        var stockStatus = filterBox(option);
                                                        stockStatus.selectAll();
                                                        stockStatus.toggle();
                                                        stockStatus.element.classList.add('col-md-3');
                                                        filterDiv.appendChild(stockStatus.element);
                                                        filterObj[key] = stockStatus;
                                                    } else if (key === 'size' && resp[key].length > 0) {
                                                        var option = {
                                                            name: key,
                                                            title: 'Size',
                                                            type: 'select',
                                                            list: []
                                                        }
                                                        resp[key].forEach(e => {
                                                            option.list.push({ string: e, meta: key });
                                                        });
                                                        var sizeFilter = filterBox(option);
                                                        sizeFilter.selectAll();
                                                        sizeFilter.toggle();
                                                        sizeFilter.element.classList.add('col-md-3');
                                                        filterDiv.appendChild(sizeFilter.element);
                                                        filterObj[key] = sizeFilter;
                                                    } else if (resp[key].length > 0 &&
                                                        (key === 'top_category_id' ||
                                                            key === 'category_id_2' ||
                                                            key === 'category_id_3' ||
                                                            key === 'category_id_4')) {
                                                        if (!categoryOption.name) categoryOption.name = key;
                                                        resp[key].forEach(e => {
                                                            categoryOption.list.push({ string: e, meta: key });
                                                        });
                                                    }
                                                }
                                                if (categoryOption.list.length > 0) {
                                                    var categoryFilter = filterBox(categoryOption);
                                                    categoryFilter.selectAll();
                                                    categoryFilter.toggle();
                                                    categoryFilter.element.classList.add('col-md-3');
                                                    filterDiv.appendChild(categoryFilter.element);
                                                    filterObj[categoryOption.name] = categoryFilter;
                                                }


                                                Array.from(document.querySelectorAll('.rvts_personalized_search_main-filter > div:nth-child(1)')).forEach(e => {
                                                    e.classList.add('icheck-primary');
                                                    e.classList.add('d-inline');
                                                    var editButton = document.createElement('i');
                                                    editButton.classList.add('fas');
                                                    editButton.classList.add('fa-edit');
                                                    editButton.style.marginLeft = '5px';
                                                    e.appendChild(editButton);
                                                    editButton.addEventListener('click', function () {
                                                        var oldValue = this.parentNode.querySelector('span').innerText;
                                                        var newValue = prompt('Please enter new title for "' + oldValue + '"');
                                                        if (newValue) {
                                                            this.parentNode.querySelector('span').innerText = newValue;
                                                        }
                                                    });

                                                });
                                                renderConfigs(configObj, status);
                                                filtersFetched();
                                            }).catch((error) => {
                                                filtersFetchFailed(error);
                                            });



                                    </script>

                                    <script>
                                        function sortTableInt(n, formId) {
                                            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
                                            table = document.getElementById(formId);
                                            switching = true;
                                            //Set the sorting direction to ascending:
                                            dir = "asc";
                                            /*Make a loop that will continue until
                                            no switching has been done:*/
                                            while (switching) {
                                                //start by saying: no switching is done:
                                                switching = false;
                                                rows = table.rows;
                                                /*Loop through all table rows (except the
                                                first, which contains table headers):*/
                                                for (i = 1; i < (rows.length - 1); i++) {
                                                    //start by saying there should be no switching:
                                                    shouldSwitch = false;
                                                    /*Get the two elements you want to compare,
                                                    one from current row and one from the next:*/
                                                    x = rows[i].getElementsByTagName("TD")[n];
                                                    y = rows[i + 1].getElementsByTagName("TD")[n];
                                                    /*check if the two rows should switch place,
                                                    based on the direction, asc or desc:*/

                                                    if (y == undefined) {
                                                        continue;
                                                    }
                                                    if (x == undefined) {
                                                        continue;
                                                    }
                                                    if (dir == "asc") {
                                                        if (parseInt(x.innerHTML) > parseInt(y.innerHTML)) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    } else if (dir == "desc") {
                                                        if (parseInt(x.innerHTML) < parseInt(y.innerHTML)) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    }
                                                }
                                                if (shouldSwitch) {
                                                    /*If a switch has been marked, make the switch
                                                    and mark that a switch has been done:*/
                                                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                                                    switching = true;
                                                    //Each time a switch is done, increase this count by 1:
                                                    switchcount++;
                                                } else {
                                                    /*If no switching has been done AND the direction is "asc",
                                                    set the direction to "desc" and run the while loop again.*/
                                                    if (switchcount == 0 && dir == "asc") {
                                                        dir = "desc";
                                                        switching = true;
                                                    }
                                                }
                                            }
                                        }


                                        function sortTableString(n, formId) {
                                            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
                                            table = document.getElementById(formId);
                                            switching = true;
                                            //Set the sorting direction to ascending:
                                            dir = "asc";
                                            /*Make a loop that will continue until
                                            no switching has been done:*/
                                            while (switching) {
                                                //start by saying: no switching is done:
                                                switching = false;
                                                rows = table.rows;
                                                /*Loop through all table rows (except the
                                                first, which contains table headers):*/
                                                for (i = 1; i < (rows.length - 1); i++) {
                                                    //start by saying there should be no switching:
                                                    shouldSwitch = false;
                                                    /*Get the two elements you want to compare,
                                                    one from current row and one from the next:*/
                                                    x = rows[i].getElementsByTagName("TD")[n];
                                                    y = rows[i + 1].getElementsByTagName("TD")[n];
                                                    /*check if the two rows should switch place,
                                                    based on the direction, asc or desc:*/
                                                    if (y == undefined) {
                                                        continue;
                                                    }
                                                    if (x == undefined) {
                                                        continue;
                                                    }
                                                    if (dir == "asc") {
                                                        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    } else if (dir == "desc") {
                                                        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    }
                                                }
                                                if (shouldSwitch) {
                                                    /*If a switch has been marked, make the switch
                                                    and mark that a switch has been done:*/
                                                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                                                    switching = true;
                                                    //Each time a switch is done, increase this count by 1:
                                                    switchcount++;
                                                } else {
                                                    /*If no switching has been done AND the direction is "asc",
                                                    set the direction to "desc" and run the while loop again.*/
                                                    if (switchcount == 0 && dir == "asc") {
                                                        dir = "desc";
                                                        switching = true;
                                                    }
                                                }
                                            }
                                        }

                                        function sortTableCurrency(n, formId) {
                                            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
                                            table = document.getElementById(formId);
                                            switching = true;
                                            //Set the sorting direction to ascending:
                                            dir = "asc";
                                            /*Make a loop that will continue until
                                            no switching has been done:*/
                                            while (switching) {
                                                //start by saying: no switching is done:
                                                switching = false;
                                                rows = table.rows;
                                                /*Loop through all table rows (except the
                                                first, which contains table headers):*/

                                                for (i = 1; i < (rows.length - 1); i++) {
                                                    //start by saying there should be no switching:
                                                    shouldSwitch = false;
                                                    /*Get the two elements you want to compare,
                                                    one from current row and one from the next:*/
                                                    x = rows[i].getElementsByTagName("td")[n];
                                                    y = rows[i + 1].getElementsByTagName("td")[n];
                                                    /*check if the two rows should switch place,
                                                    based on the direction, asc or desc:*/

                                                    if (y == undefined) {
                                                        continue;
                                                    }

                                                    if (x == undefined) {
                                                        continue;
                                                    }

                                                    var xtl = x.innerHTML
                                                    var xstlP = xtl.replace(".", "")
                                                    var xstlC = xstlP.replace(",", "")
                                                    var xtlS = xstlC.replace("TL", "")
                                                    var xInt = parseInt(xtlS);

                                                    var ytl = y.innerHTML
                                                    var ystlP = ytl.replace(".", "")
                                                    var ystlC = ystlP.replace(",", "")
                                                    var ytlS = ystlC.replace("TL", "")
                                                    var yInt = parseInt(ytlS);
                                                    if (dir == "asc") {

                                                        if (xInt > yInt) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    } else if (dir == "desc") {

                                                        if (xInt < yInt) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    }

                                                }
                                                if (shouldSwitch) {
                                                    /*If a switch has been marked, make the switch
                                                    and mark that a switch has been done:*/
                                                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                                                    switching = true;
                                                    //Each time a switch is done, increase this count by 1:
                                                    switchcount++;
                                                } else {
                                                    /*If no switching has been done AND the direction is "asc",
                                                    set the direction to "desc" and run the while loop again.*/
                                                    if (switchcount == 0 && dir == "asc") {
                                                        dir = "desc";
                                                        switching = true;
                                                    }
                                                }
                                            }
                                        }
                                    </script>

            </body>

            </html>