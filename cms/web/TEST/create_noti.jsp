<%@ page language="java"
         import="java.net.*,
         		java.text.SimpleDateFormat,
         		com.britemoon.*,
         		com.britemoon.rcp.*,
         		com.britemoon.rcp.imc.*,
         		com.britemoon.rcp.que.*,
         		java.sql.*,
         		java.io.*,
         		java.math.BigDecimal,
         		java.text.NumberFormat,
         		java.io.*,
         		org.apache.log4j.Logger,
         				com.britemoon.cps.que.*,

         		org.w3c.dom.*"
         contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="javax.script.ScriptEngine" %>
<%@ page import="javax.script.ScriptEngineManager" %>
<%@ page import="org.json.JSONObject" %>
<%


    String custid = request.getParameter("cust_id");
    String campType = request.getParameter("camp_type");

    if (custid == null || campType == null)
        return;


    Statement stmt = null;
    ResultSet rs = null;
    ResultSet dr = null;
    ResultSet pr = null;
    ResultSet psc = null;
    ResultSet icn = null;
    ConnectionPool cp = null;
    Connection connm = null;

    StringBuilder bulkfilter = new StringBuilder();
    StringBuilder personBuilder = new StringBuilder();
    StringBuilder mailfilter = new StringBuilder();
    Map<String, String> persOptionMap = new HashMap<String, String>();
    String varr = null;
    String oldIcon = "";
    boolean canBePersonalized = false;
    try {
        cp = ConnectionPool.getInstance(custid);
        connm = cp.getConnection(this);
        stmt = connm.createStatement();


        String getFilter = " SELECT  f.filter_id,f.filter_name"
                + " FROM rtgt_webpush_filter  as f "
                + " INNER JOIN rtgt_webpush_filter_statistic as s "
                + " ON f.filter_id=s.filter_id "
                + " WHERE  f.status_id!=900 ";
        rs = stmt.executeQuery(getFilter);

        while (rs.next()) {
            String fltr_name = rs.getString(2);
            if (fltr_name.contains("'")) {
                fltr_name = fltr_name.replace("'", "&#39");
            }
            String opr = "<option value=\"" + rs.getString(1) + "\">" + fltr_name + "</option>";
            bulkfilter.append(opr);

        }


//			KY update

        String checkPersonalizeSQL = "";
        if (campType.equalsIgnoreCase("trgr_basket")) {
            checkPersonalizeSQL = "SELECT top 2 * from rque_push_cart  with (nolock) where img is not null and img != '' ";
        } else if (campType.equalsIgnoreCase("trgr_order")) {
            checkPersonalizeSQL = "select top 2 * from rque_cust_order with (nolock) where img is not null and img != ''";
        } else if (campType.equalsIgnoreCase("visit")) {
            checkPersonalizeSQL = "select top 2 * from rjtk_web_link_activity with (nolock) where img is not null and img != '' ";
        }

        if (!checkPersonalizeSQL.equalsIgnoreCase("")) {
            psc = stmt.executeQuery(checkPersonalizeSQL);

            while (psc.next()) {
                canBePersonalized = true;
            }
        }
//


        String getPersonalizationAttr = " SELECT attr_id, attr_name, column_name"
                + " from rque_push_personalization_attr with (nolock) where camp_type = '" + campType + "'";

        pr = stmt.executeQuery(getPersonalizationAttr);

        while (pr.next()) {
            String persShowNames = pr.getString(2);
            String options = "<option value=\"" + pr.getString(1) + "\">" + persShowNames + "</option>";
            persOptionMap.put(pr.getString(1), pr.getString(3));
            personBuilder.append(options);

        }


        ScriptEngineManager factory = new ScriptEngineManager();
        ScriptEngine engine = factory.getEngineByName("javascript");
        JSONObject jsonObject = new JSONObject(persOptionMap);
        varr = jsonObject.toString();
        engine.put("deneme", jsonObject.toString());


        String getMailFilter = ""
                + " SELECT  f.filter_id,f.filter_name,f.status_id, fsc.start_date,fsc.finish_date,fsc.recip_count "
                + "FROM "
                + " rtgt_filter f WITH(NOLOCK) "
                + " LEFT OUTER JOIN	rque_push_filter_statistic fsc WITH(NOLOCK) ON f.filter_id = fsc.filter_id "
                + "  WHERE f.filter_name IS NOT NULL "
                + "  	AND f.status_id!=900  "
                + "  	AND f.filter_name!='' "
                + "	AND f.origin_filter_id IS NULL "
                + "	AND f.type_id = 0 --FilterType.MULTIPART "
                + "	AND ISNULL(f.usage_type_id,500) = 500"
                + "	AND f.cust_id = @cust_id "
                + "	AND f.filter_name not like 'Dynamic Campaign%' "
                + " ORDER BY  ISNULL(fsc.finish_date, getdate()) DESC, f.filter_name";

        dr = stmt.executeQuery(getMailFilter);

        while (dr.next()) {
            String fltr_name = dr.getString(2);
            if (fltr_name.contains("'")) {
                fltr_name = fltr_name.replace("'", "&#39");
            }

            String opr = "<option value=\"" + dr.getString(1) + "\">" + fltr_name + "</option>";
            mailfilter.append(opr);

        }


        String getIcon = "select top(1) icon from rque_push_campaign order by camp_id desc";

        icn = stmt.executeQuery(getIcon);

        while (icn.next()) {
            oldIcon = icn.getString(1);

        }


    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {

            if (rs != null)
                rs.close();
            if (stmt != null)
                stmt.close();
            if (connm != null) {

                connm.close();
                cp.free(connm);
            }
            if (pr != null)
                pr.close();
        } catch (SQLException e) { /* ignored */}
    }




%>

<%!
    private static String getHourOptionsHtml(int nSelectedHour)
    {
        StringWriter sw = new StringWriter();
        sw.write("<OPTION value=0" + (nSelectedHour != 0 ? "" : " selected") + ">Midnight</OPTION>\r\n");
        sw.write("<OPTION value=1" + (nSelectedHour != 1 ? "" : " selected") + ">1:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=2" + (nSelectedHour != 2 ? "" : " selected") + ">2:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=3" + (nSelectedHour != 3 ? "" : " selected") + ">3:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=4" + (nSelectedHour != 4 ? "" : " selected") + ">4:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=5" + (nSelectedHour != 5 ? "" : " selected") + ">5:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=6" + (nSelectedHour != 6 ? "" : " selected") + ">6:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=7" + (nSelectedHour != 7 ? "" : " selected") + ">7:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=8" + (nSelectedHour != 8 ? "" : " selected") + ">8:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=9" + (nSelectedHour != 9 ? "" : " selected") + ">9:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=10" + (nSelectedHour != 10 ? "" : " selected") + ">10:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=11" + (nSelectedHour != 11 ? "" : " selected") + ">11:00 AM</OPTION>\r\n");
        sw.write("<OPTION value=12" + (nSelectedHour != 12 ? "" : " selected") + ">Noon</OPTION>\r\n");
        sw.write("<OPTION value=13" + (nSelectedHour != 13 ? "" : " selected") + ">1:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=14" + (nSelectedHour != 14 ? "" : " selected") + ">2:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=15" + (nSelectedHour != 15 ? "" : " selected") + ">3:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=16" + (nSelectedHour != 16 ? "" : " selected") + ">4:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=17" + (nSelectedHour != 17 ? "" : " selected") + ">5:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=18" + (nSelectedHour != 18 ? "" : " selected") + ">6:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=19" + (nSelectedHour != 19 ? "" : " selected") + ">7:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=20" + (nSelectedHour != 20 ? "" : " selected") + ">8:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=21" + (nSelectedHour != 21 ? "" : " selected") + ">9:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=22" + (nSelectedHour != 22 ? "" : " selected") + ">10:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=23" + (nSelectedHour != 23 ? "" : " selected") + ">11:00 PM</OPTION>\r\n");
        sw.write("<OPTION value=24" + (nSelectedHour != 24 ? "" : " selected") + ">any time</OPTION>\r\n");
        sw.write("<OPTION value=25" + (nSelectedHour != 25 ? "" : " selected") + ">end of the day</OPTION>\r\n");
        return sw.toString();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Webpush | Create Campaign</title>
    <!-- Tell the browser to be responsive to screen width -->
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">

    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/font-awesome.min.css">

    <link rel="stylesheet" href="assets/css/ionicons.min.css">

    <link rel="stylesheet" href="assets/css/AdminLTE.css">

    <link rel="stylesheet" href="assets/css/Style.css">

    <link rel="stylesheet" href="assets/css/skin-blue.min.css">


    <link rel="stylesheet" href="assets/css/datatimepicker.css">

    <link rel="stylesheet" href="assets/css/bootstrap-toggle.min.css">

    <!-- Emoji CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

    <link href="assets/emoji/css/emoji.css" rel="stylesheet">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <!-- Google Font -->
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">

    <link rel="stylesheet" href="./css/all.min.css">
    <link rel="stylesheet" href="preview-style.css">

    <style>
        .table_status {
            font-size: 12px;
            line-height: 32px;
            text-align: center;
            color: #59C8E6;
        }

        td {
            font-size: 12px;
            vertical-align: middle !important;
            border: 1px solid #f2f2f2 !important;
        }

        .preview_table td {
            border: none !important;
        }


        th {
            font-size: 12px;
            background-color: #f2f2f2;
            border: 1px solid #ddd !important;
            vertical-align: middle !important;
        }

        .shadows {
            -webkit-box-shadow: 0px 10px 15px -9px rgba(0, 0, 0, 0.53);
            -moz-box-shadow: 0px 10px 15px -9px rgba(0, 0, 0, 0.53);
            box-shadow: 0px 10px 15px -9px rgba(0, 0, 0, 0.53);

        }

        .form-control {
            border-color: #a1a1a1;
        }

        .image_container {
            position: relative;

        }

        #buttondelete {
            position: absolute;
            bottom: 0px;
            left: 0px;

        }

        .preview_container {
            width: 240px;
            margin-top: 20px;
        }

        .pre_icon_content {
            width: 52px !important;
            height: 52px !important;
        }

        .pre_icon_content img {
            margin: 0 auto;
            width: 52px !important;
        }

        .pre_title_content {
            font-size: 9px;
            font-family: Tahoma, Arial, sans-serif;
            width: 188px;
            line-height: 18px;
            padding-left: 5px;

        }

        .pre_title {
            color: #333333;
            font-weight: bold;
        }

        .pre_link {
            color: #7f7f7f;
        }

        .pre_body_img {
            text-align: center;
        }


        /* Style the tab */
        .tab {
            overflow: hidden;
            border: 1px solid #ccc;
        }

        /* Style the buttons inside the tab */
        .tab button {
            background-color: inherit;
            float: left;
            border: none;
            outline: none;
            cursor: pointer;
            padding: 14px 16px;
            transition: 0.3s;
            font-size: 17px;
        }

        /* Change background color of buttons on hover */
        .tab button:hover {
            background-color: #ddd;
        }

        /* Create an active/current tablink class */
        .tab button.active {
            background-color: #e8e7e7;
        }

        /* Style the tab content */
        .tabcontent {
            display: none;
            padding: 6px 12px;
            border: 1px solid #ccc;
            border-top: none;
        }

    </style>
</head>


<body class="hold-transition" style="background-color:#ecf0f5;">

<section class="content-header" style="margin-left:10px;margin-right:10px;">
    <div class="box box-primary">
        <div class="box-header with-border">
            <div class="col-md-6">
                <h3>Create Campaign</h3>
            </div>
        </div>
    </div>

</section>

<section class="content-header" style="margin-left:20px;margin-right:20px;">

    <div class="row">


        <div style="padding-left:10px">
            <button type="button" onclick="create_campaign('0','0')" class="btn b_turuncu c_beyaz ">Save</button>

            <button style="margin-left:5px" type="button" onclick="create_campaign('10','0')" class="btn b_yesil c_beyaz">Start</button>

            <button type="button" onclick="sendTestPush()" id="send_test" class="btn b_mavi c_beyaz " style="display: none; margin-left:5px">Send Test</button>
            <button type="button"  onclick="getPermission()" id = "request_permission"class="btn b_mavi c_beyaz " style="display: none; margin-left:5px">Permission for Test</button>
        </div>
    </div>


    <%--		Kursat Modal--%>
    <div class="modal fade" id="personalizeModal" role="dialog">
        <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content" style="border-radius: 20px">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Personalization</h4>
                </div>


                <div class="modal-body">
                    <div class="form-group">
                        <label>Personalization Field</label>&nbsp;&nbsp;
                        <select class="form-control" id="personalization_select" onchange="updateMergeSymbol()">
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Default Value</label>&nbsp;&nbsp;
                        <input style="width:100%" ; type="text" id="pers_def_id" size="5" value=""
                               onchange="updateMergeSymbol();" onkeyup="this.onchange();" onpaste="this.onchange();"
                               oninput="this.onchange();">
                    </div>
                    <div class="form-group">
                        <label>Merge Symbol</label>&nbsp;&nbsp;
                        <input style="width:100%" ; type="text" id="pers_merge_id" size="5" value="" readonly>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button"
                            style="background-color: #00c0ef; border-radius: 10px; color: white; width: 20%;"
                            class="btn btn-default" data-dismiss="modal" id="pers_modal_save">Save
                    </button>
                    <button type="button"
                            style="background-color: #faa926; border-radius: 10px; color: white; width: 20%;"
                            class="btn btn-default" data-dismiss="modal" id="pers_modal_close">Close
                    </button>
                </div>
            </div>

        </div>
    </div>

    <div class="row">

        <div class="col-md-4 margin" style="border:1px solid #ccc;  background-color:#fff;padding-top:20px;">
            <form>
                <div class="form-group">
                    <label for="titleid">Campaign Name</label>
                    <input type="text" value=''
                           class="form-control" id="nname" placeholder="Enter Name">
                </div>

                <%--					<div class="form-group">--%>
                <%--						<button type="button" class="btn btn-info btn-lg" id="myBtn">Open Modal</button>--%>
                <%--					</div>--%>


                <div class="form-group">
                    <label for="titleid">Campaign Type</label>&nbsp;&nbsp;
                    <select class="form-control" id="ctype_select">

                    </select>
                </div>


                <div class="form-group">
                    <label for="titleid">Title</label>
                    <div class="input-group"><p id="rvts_emoji_title"  class="lead emoji-picker-container">
                        <input type="text" value='' class="form-control" id="ntitle" data-emojiable="true"
                               data-emoji-input="unicode" placeholder="Enter Title"></p>
                        <span class="input-group-btn">
								<button class="btn btn-info btn-flat" id="myBtn-title" style="display:none"
                                        type="button">Personalize</button>
							</span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="bodyid">Body</label>
                    <div class="input-group" id="test1"><p id="rvts_emoji_body" class="lead emoji-picker-container">
                        <input type="text" value='' class="form-control" id="nbody" data-emoji-input="unicode"
                               placeholder="Enter Body" data-emojiable="true"></p>
                        <span class="input-group-btn">
								<button class="btn btn-info btn-flat" id="myBtn-body" style="display:none"
                                        type="button">Personalize</button>
							</span>
                    </div>
                </div>

                <div class="form-group">
                    <div style="display: inline-block">
                        <label for="urlid">URL</label>
                        <span type="button" class="fa fa-info-circle" style="color:#9b9b9b" data-toggle="tooltip" data-placement="top" title="URL the user is taken to after clicking on the notification"/>
                    </div>

                    <div class="input-group">
                        <input type="text" value='' class="form-control" id="nurl" placeholder="Enter URL">

                        <span class="input-group-btn">
									<button class="btn btn-info btn-flat" id="myBtn-url" style="display:none"
                                            type="button">Personalize</button>
	<%--								<button type="button" id="myBtn" class="btn b_mavi c_beyaz btn-lg">Open Modal</button>--%>
								</span>
                    </div>
                </div>

                <div id="button-div" class="row" >
                    <div class="form-group col-sm-6 col-md-6 col-lg-6">
                        <label class="col-sm-8 col-md-8 col-lg-8">Add Button    <span type="button" class="fa fa-info-circle" style="color:#9b9b9b" data-toggle="tooltip" data-placement="top" title="Add buttons to notification to make it actionable. Works on Chrome, Opera, Edge."/></label>
                        <input class="pull-right col-sm-4 col-md-4 col-lg-4" type="checkbox" id="add-button-toggle" data-toggle="toggle" data-size="mini" data-offstyle="warning"  data-onstyle="success" data-on="On" data-off="Off">

                    </div>

                </div>

                <div id="button-define-div" style="display: none">
                    <table class="table table-bordered" style="padding-bottom:0px">
                        <tbody>
                        <tr>
                            <td style="width:108px;padding-top: 0px;">First Button Title</td>
                            <td>
                                <input id="first_button_title" type="text" onchange="addButtons()">
                            </td>
                            <td style="width:108px;padding-top: 0px;">Button URL</td>
                            <td>
                                <input id="first-button-url" type="text">
                            </td>
                        </tr>
                        <tr>
                            <td style="width:108px;padding-top: 0px;">Second Button Title</td>
                            <td>
                                <input id="second_button_title" type="text" onchange="addButtons()">
                            </td>
                            <td style="width:108px;padding-top: 0px;">Button URL</td>
                            <td>
                                <input id="second-button-url" type="text">
                            </td>
                        </tr>
                        </tbody>
                    </table>

                </div>

                <div id="UTM" class="row">
                    <div class="form-group col-sm-6 col-md-6 col-lg-6">
                        <label class="col-sm-8 col-md-8 col-lg-8">Add UTM</label>
                        <input class="pull-right col-sm-4 col-md-4 col-lg-4" type="checkbox" id="toggle"
                               data-toggle="toggle" data-size="mini" data-offstyle="warning" data-onstyle="success"
                               data-on="On" data-off="Off">

                    </div>

                </div>

                <div id="UTM_container" class="row" style="padding-top:15px;display:none">

                    <div class="col-md-6">
                        <div class="form-group">
                            <label>UTM Campaign</label>
                            <input type="text"
                                   value=''
                                   class="form-control"
                                   id="utmname">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>UTM Source</label>
                            <input type="text"
                                   value=""
                                   id="utmsource"
                                   class="form-control">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>UTM Medium</label>
                            <input type="text"
                                   value=''
                                   id="utmmedium"
                                   class="form-control">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>UTM Term</label>
                            <input type="text"
                                   value=''
                                   id="utmterm"
                                   class="form-control">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>UTM Content</label>
                            <input type="text"
                                   value=''
                                   id="utmcontent"
                                   class="form-control">
                        </div>
                    </div>
                </div>


            </form>
        </div>

        <div class="col-md-4 margin"
             style="border:1px solid #ccc;  background-color:#fff;padding:10px;min-height:430px">


            <table class="table table-bordered" id="NewImgTable">
                <tbody>
                <tr>

                    <td style="width:100px;">

                        <div style="display:inline-block">
                            <span> Image &nbsp; </span>
                            <span type="button" class="fa fa-info-circle" style="color:#9b9b9b" data-toggle="tooltip" data-placement="top" title="Use featured image of the landing page here. Works on Chrome, Opera, Edge. Recommended aspect ratio 2:1. Jpg, Jpeg, PNG file types only."/>
                        </div>
                    </td>
                    <td>

                        <div class="input-group margin">
                            <input class="form-control" type="file" name="submitfile" id="submitfile"
                                   enctype="multipart/form-data"/>
                            <span class="input-group-btn">
												  <button type="button" class="btn btn-info btn-flat"
                                                          onClick="imgupload();">Upload</button>
												</span>
                        </div>
                        <div name="url_display" id="url_display" style="display:none; margin-left:30px"></div>

                    </td>
                    <td id="pers-image" style="display:none">

                        <div class="form-group col-sm-12 col-md-12 col-lg-12" style="margin-bottom: 0px !important;">
                            <span class="col-sm-8 col-md-8 col-lg-8">Personalize Image</span>
                            <input class="pull-right col-sm-4 col-md-4 col-lg-4" type="checkbox"
                                   id="img-customize-toggle" data-toggle="toggle" data-size="mini"
                                   data-offstyle="warning" data-onstyle="success" data-on="On" data-off="Off">
                        </div>

                    </td>

                </tr>
                </tbody>
            </table>

            <table class="table table-bordered" id="DraftImgTable" style="display:none;">
                <tr>
                    <td style="width:100px;">İmage</td>
                    <td>
                        <div class="image_container">
                            <img class="img-thumbnail" width="150px;" src=""/>
                            <button id="buttondelete" class="btn btn-danger btn-xs " onClick="delete_img('img')">Sil
                            </button>
                        </div>
                    </td>
                </tr>
            </table>

            <table class="table table-bordered" id="NewIconTable">
                <tbody>
                <tr>

                    <td style="width:100px;">
                        <div style="display: inline-block">
                            <span>Icon &nbsp;</span>
                            <span type="button" class="fa fa-info-circle" style="color:#9b9b9b" data-toggle="tooltip" data-placement="top" title="A small image that shows up next to the title and the body text. Works on Chrome, Firefox, Opera, Edge. Recommended size 192x192 px or above. Jpg, Jpeg, PNG file types only."/>
                        </div>
                    </td>
                    <td>
                        <div class="input-group margin">
                            <input class="form-control" type="file" name="iconsubmitfile" id="iconsubmitfile"
                                   enctype="multipart/form-data"/>
                            <span class="input-group-btn">
												  <button type="button" class="btn btn-info btn-flat"
                                                          onClick="iconupload();">Upload</button>
												</span>
                        </div>
                        <div name="ucl_display" id="ucl_display" style="display:none, margin-left:30px"></div>
                    </td>

                </tr>
                </tbody>
            </table>

            <table class="table table-bordered" id="DraftIconTable" style="display:none;">
                <tr>
                    <td style="width:100px;">
                        <div style="display: inline-block">
                            <span>Icon &nbsp;</span>
                            <span type="button" class="fa fa-info-circle" style="color:#9b9b9b" data-toggle="tooltip" data-placement="top" title="A small image that shows up next to the title and the body text. Works on Chrome, Firefox, Opera, Edge. Recommended size 192x192 px or above. Jpg, Jpeg, PNG file types only."/>
                        </div>
                    </td>
                    <td id="icon-display">
                        <div class="image_container">
                            <img class="img-thumbnail" width="100px;" src=""/>
                            <button id="buttondelete" class="btn btn-danger btn-xs " onClick="delete_img('icn')">Sil
                            </button>
                        </div>
                    </td>
                    <td id="pers-icon" style="display:none">

                        <div class="form-group col-sm-12 col-md-12 col-lg-12" style="margin-bottom: 0px !important;">
                            <span class="col-sm-8 col-md-8 col-lg-8">Personalize Icon</span>
                            <input class="pull-right col-sm-4 col-md-4 col-lg-4" type="checkbox"
                                   id="icon-customize-toggle" data-toggle="toggle" data-size="mini"
                                   data-offstyle="warning" data-onstyle="success" data-on="On" data-off="Off">
                        </div>
                    </td>
                </tr>
            </table>


            <table class="table table-bordered" id="SegmentType">
                <tbody>
                <tr>

                    <td style="width:100px;">Send Type</td>
                    <td>
                        <div class="input-group col-md-11 margin">
                            <select class="form-control" id="segment_select_type">

                            </select>
                        </div>
                    </td>

                </tr>


                </tbody>
            </table>

            <table class="table table-bordered" id="SegmentTable">
                <tbody>
                <tr>

                    <td style="width:100px;">Send To</td>
                    <td>
                        <div class="input-group col-md-11 margin">
                            <select class="form-control" id="segment_select">

                            </select>
                        </div>
                    </td>

                </tr>


                </tbody>
            </table>


            <div class="tab">
                <button class="tablinks" onclick="openOptions(event, 'start_date')" id="defaultOpen">Send Date</button>
                <button class="tablinks" onclick="openOptions(event, 'advenced_options')">Advanced Options</button>
            </div>



            <div id="start_date" class="tabcontent">
                <div id="timefield" style="display:none">
                    <table class="table table-bordered" style="padding-bottom:0px">
                        <tbody>
                        <tr>

                            <td style="width:100px;padding-top: 0px;">Start Date</td>
                            <td>
                                <div class="row">

                                    <div class="input-group col-md-8 col-md-offset-2 ">
                                        <div class="form-group  ">


                                            <input type="radio" id="snow" name="snow"
                                                   onclick="snextdate('now')" checked/> <label for="snow">Now</label>
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <input type="radio" id="snext"
                                                   name="snow" onclick="snextdate('specific')"/> <label
                                                for="snext">Specific Date</label>

                                        </div>
                                    </div>
                                </div>
                            </td>

                        </tr>


                        </tbody>
                    </table>
                    <div class="row">
                        <div class="form-group col-md-8 col-md-offset-3" id="choosetime" style="display:none">


                            <div class="input-group date">
                                <div class="input-group-addon">
                                    <i class="fa fa-calendar"></i>
                                </div>
                                <input type="text" class="form-control pull-right"
                                       id="datepicker">
                            </div>
                            <!-- /.input group -->
                        </div>
                    </div>

                </div>
            </div>

            <div id="advenced_options" class="tabcontent">
                <div id="timefield2" style="display:block">
                    <table class="table table-bordered" style="padding-bottom:0px">
                        <tbody>
                        <tr>

                            <td style="width:100px;padding-top: 0px;">Queue Start Date</td>
                            <td>
                                <div class="row">

                                    <div class="input-group col-md-8 col-md-offset-2 ">
                                        <div class="form-group  ">


                                            <input type="radio" id="snowQ" name="snowQ"
                                                   onclick="snextdateQueue('now')" checked/> <label for="snowQ">Now</label>
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <input type="radio" id="snextQ"
                                                   name="snowQ" onclick="snextdateQueue('specific')"/> <label
                                                for="snextQ">Specific Date</label>

                                        </div>
                                    </div>
                                </div>
                            </td>

                        </tr>

                        </tbody>
                    </table>
                    <div class="row">
                        <div class="form-group col-md-8 col-md-offset-3" id="choosetimeQueue" style="display:none">
                            <div class="input-group date">
                                <div class="input-group-addon">
                                    <i class="fa fa-calendar"></i>
                                </div>
                                <input type="text" class="form-control pull-right"
                                       id="datepickerQueue">
                            </div>
                            <!-- /.input group -->
                        </div>
                    </div>
                </div>
                <table class="table table-bordered" style="padding-bottom:0px">
                    <tbody>
                <tr>
                    <td style="width:100px;padding-top: 0px;">When sending:</td>

                    <%--<td width="150" align="left" valign="middle" class="campaign_header" nowrap>--%>

                    <td>
                        <input name="start_daily_weekday_mask" type="hidden" value="0">
                        <table cellspacing="0" cellpadding="1" border="0">
                            <tr>
                                <td class="campaign_header">
                                    start at:
                                    <select name=start_daily_hour>
                                        <%=getHourOptionsHtml(24)%>
                                    </select>&nbsp;
                                    <a href="javascript:void(0);" onclick="toggleSection(this, 'start_adv');" class="button_res">Additional Options</a>
                                </td>
                            </tr>

                            <tr id="start_adv" style="display:none;">
                                <td>
                                    <table cellspacing="0" cellpadding="1" border="0" width="400">
                                        <tr>
                                            <td align="left" valign="middle" nowrap rowspan="2">send only on:</td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_mon">Mon</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_tue">Tue</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_wed">Wed</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_thu">Thu</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_fri">Fri</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_sat">Sat</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_sun">Sun</label></td>
                                        </tr>
                                        <tr>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_mon" type="checkbox" value="2"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_tue" type="checkbox" value="4"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_wed" type="checkbox" value="8"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_thu" type="checkbox" value="16"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_fri" type="checkbox" value="32"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_sat" type="checkbox" value="64"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_sun" type="checkbox" value="1"></td>
                                        </tr>
                                        <tr>
                                            <td align="left" valign="middle" nowrap>and only send until: </td>
                                            <td colspan="7" width="100%">
                                                <select name=end_daily_hour>
                                                    <%=getHourOptionsHtml(25)%>
                                                </select>
                                                <input name="start_daily_time" type="hidden" value="">
                                                <input name="end_daily_time" type="hidden" value="">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%--<tr>
                    <td align="left" class="campaign_header" valign="middle">
                        Stop sending:
                    </td>
                    <td align="left" valign="middle">
                        <table cellspacing="0" cellpadding="1" border="0">
                            <tr>
                                <td class="campaign_header">
                                    <input name="end_date_switch" value="never" id="end_date_switch_never" type="radio">
                                    <label for="end_date_switch_never">When All Messages Are Sent</label>
                                </td>
                            </tr>
                            <tr>
                                <td class="campaign_header">
                                    <input name="end_date_switch" value="" id="end_date_switch_specified" type="radio">
                                    <label for="end_date_switch_specified">End on a Specific Date:</label>
                                    <select name=end_date_year onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    <select name=end_date_month onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    <select name=end_date_day onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    <select name=end_date_hour onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    (EST)
                                    <input name="end_date" type="hidden" value="">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td align="left" valign="middle">
                        <input type="checkbox" id="msg_per_recip_limit" name="msg_per_recip_limit">
                        <label for="msg_per_recip_limit">Allow recipients to participate many times in the campaign</label>
                    </td>
                </tr>

                <input type="hidden" size="8" name="limit_per_hour" value="0">

                <tr>
                    <td>&nbsp;</td>
                    <td class="campaign_header">
                        Maximum Sent Out Per Hour
                        &nbsp;&nbsp;
                        <input type="text" size="8" name="limit_per_hour" value="">
                        (0 for no limit)
                    </td>
                </tr>--%>
                    </tbody>
                </table>
            </div>




            <div id="basket_order" style="display:none">
                <table class="table table-bordered" style="padding-bottom:0px">
                    <tbody>
                    <tr>

                        <td style="width:108px;padding-top: 0px;">Delay Time</td>
                        <td>
                            <input id="trigger_time" type="text">
                        </td>
                        <td>
                            <select id="trgr-prm_type">
                                <option selected value="minute">Minute</option>
                                <option value="hour">Hour</option>
                                <option value="day">Day</option>
                                <option value="week">Week</option>
                            </select>
                        </td>

                    </tr>


                    </tbody>
                </table>

            </div>

            <!-- kaç defa gideceği -->

            <div id="exclude_recip" style="display:none">
                <table class="table table-bordered" style="padding-bottom:0px">
                    <tbody>
                    <tr>
                        <td>
                            Exclude recipients who have received a campaign in the previous
                            <input style="width:30px" type="text" id="camp_frequency" size="5" value=""> days.
                        </td>
                    </tr>
                    </tbody>
                </table>

            </div>






            <!-- kaç defa gideceği son -->

        </div>
        <div class="col-md-3 margin"
             style="border:1px solid #ccc;  background-color:#fff;min-height:430px;padding-bottom:20px;">


            <div style="display: inline-block">
                <span>Previews Web Push &nbsp;</span>
                <span type="button" class="fa fa-info-circle" style="color:#9b9b9b" data-toggle="tooltip" data-placement="top" title="The notification preview is for reference only. Appearance of actual notification may differ slightly"/>
            </div>            <div class="preview_container">
            <table cellpadding="0" cellspacing="0" class="table table-bordered">
                <tr>
                    <td>
                        <div class="input-group col-md-9 margin">
                            <select class="form-control" id="preview_select_type">
                                <option value="1">Chrome Windows 10</option>
                                <option value="2">Chrome Windows 7-8</option>
                                <option value="3">Firefox Windows</option>
                                <option value="4">Chrome Mac OS</option>
                                <option value="5">Chrome Android</option>
                            </select>
                        </div>
                    </td>

                </tr>
                <!--<tr>
                    <td align="center" colspan="2">
                        <div class="pre_body_img" style="text-align: left">
                            <img width="240" src="http://revotas.com/webpush/image.jpg"/>
                        </div>

                    </td>
                </tr>-->
                <%--						<tr valign="top">--%>

                <%--							<td  style="padding-left: 5px; padding-right: 0px;">--%>
                <%--								<div class="pre_icon_content pull-left" style="width: 50px" >--%>
                <%--									<img width="52" src="http://revotas.com/webpush/icon.jpg" />--%>
                <%--								</div>--%>


                <%--							</td>--%>
                <%--							<td style="padding-left: 0px; width: 100px">--%>
                <%--								<div class="pre_title_content pull-left" style="width: 200px" >--%>
                <%--									<span class="pre_title"></span><br/>--%>
                <%--									<span class="pre_body"></span><br/>--%>
                <%--									<!--<span class="pre_link">www.lulucandle.com</span><br/>-->--%>
                <%--								</div>--%>


                <%--							</td>--%>
                <%--						</tr>--%>
                <!--<tr valign="top">

                    <td>
                        <div class="pre_icon_content">
                            <img width="52" src="http://revotas.com/webpush/icon.jpg"/>
                        </div>


                    </td>
                    <td>
                        <div class="pre_title_content">
                            <span class="pre_title"></span><br/>
                            <span class="pre_body"></span><br/>
                            <!--<span class="pre_link">www.lulucandle.com</span><br/>-->
                <!--</div>


            </td>
        </tr>

        <tr id="preview-two-button" style="display:none">
            <td style="padding-bottom: 15px" align="center" colspan="2">
                <div style="float:left; width: 100%">

                    <div style="float:right; width: 50%">
                        <button style="background-color: #333333; display: inline; color: white; width: 90% "
                                type="button" class="btn" disabled id="second-button">Button 2
                        </button>
                    </div>
                    <div style="float: right; width: 50%">
                        <button style="background-color: #333333; display: inline; color: white; width: 90%"
                                type="button" class="btn" disabled id="first-button">Button 1
                        </button>
                    </div>
                </div>
            </td>
        </tr>

        <tr id="preview-one-button" style="display:none">
            <td align="center" colspan="2" style="padding-bottom: 15px">
                <button style="background-color: #333333; color: white; width: 90%" type="button"
                        class="btn" disabled id="first-button1">Button 1
                </button>
            </td>
        </tr>-->

                <tr><td>
                    <div class="preview-div">
                        <div id="chrome-windows-10" class="preview-1 sample_notification" style="background-color: rgb(96, 102, 112); width: 280px; display: flex; flex-flow: row wrap; word-break: break-all; border-radius: 3px 3px 0px 0px;">
                            <div class="big-image" style="box-shadow: none;">
                                <img class="sample-big-image" src="https://www.pushengage.com/assets/img/placeholder_big_img.jpg" style="display: block; width: 280px; background-color: rgb(255, 255, 255);">
                            </div>
                            <div style="display:flex">
                                <div class="sample_notification_icon">
                                    <img src="" id="sample_notification_logo" style="max-width: 70px; max-height: 47px;    margin-top: -8px;">
                                </div>

                                <div class="notification_body" style="color:#f2f6fc;margin-left:0px">
                                    <div class="sample_notification_title pre_title">
                                        Notification Title</div>
                                    <div class="text-muted sample_notification_message pre_body" style="color:#ced4dd;">This is the Notification Message</div>
                                    <div class="text-muted sample_notification_url_style wordbreak" style="color:#ced4dd; "><span style="display: block;">Google Chrome.</span>revotas.com</div>
                                </div>
                            </div>

                            <div class="multiaction_button" style="margin-top:0px;padding-top:0px;">
                                <div class="first-action-button windows10-multi-action1" style="width: 126px;background-color: rgb(136, 137, 137);color: white;margin: 3px 3px 8px;border-top: none;box-shadow: none;float: left;padding-left: 0px;text-align: center;display: block;border-radius: 0px;"><div class="windows10-multi-action1-img"><img id="windows10-first-action-button-img" src=""></div><span id="first-action-button-title" style="">Button 1 Title</span>
                                </div>
                                <div class="second-action-button  windows10-multi-action2" style="width: 126px; background-color: rgb(136, 137, 137); color: white; margin: 3px 3px 8px; border-top: none; box-shadow: none; float: right; padding-left: 0px; text-align: center; display: block; border-radius: 0px 0px 3px 3px;"><div class="windows10-multi-action2-img"><img id="windows10-second-action-button-img" src=""></div><span id="second-action-button-title" style="">Button 2 Title</span></div>
                                <button id="close_btn" style="display: none;">Close</button>
                            </div>
                            <!-- adding of button starts here-->

                            <!-- adding of button ends here-->
                        </div>

                        <!----------------------------------------------------------------------------------------------------------------->

                        <div class="preview-2" style="display:none;">
                            <div class="sample_notification" style="border-radius: 3px 3px 0px 0px;">
                                <div style="display: flex; padding-top: 4px;">
                                    <div class="window7_sample_notification_url" style="order: 1;">
                                        <span style="margin-left: 10px;">revotas.com</span>
                                    </div>
                                    <div class="window7_sample_notification_icons" style="order: 2;width: 93px;">
                                        <i aria-hidden="true">×</i>
                                        <i class="fa fa-cog"></i>
                                    </div>
                                </div>
                                <div class="window7_sample_notification_body" style="display: flex">
                                    <div style="order: 1;width: 233px">
                                        <p class="sample_notification_title pre_title">
                                            Notification Title			</p>
                                        <p class="text-muted sample_notification_message pre_body">This is the Notification Message			</p>
                                    </div>
                                    <div style="order: 2;width: 75px">
                                        <img src="" id="sample_notification_logo">
                                    </div>
                                </div>
                            </div>
                            <div class="big-image">
                                <img class="sample-big-image" src="https://www.pushengage.com/assets/img/placeholder_big_img.jpg" style="display: block; width: 280px; background-color: rgb(255, 255, 255);">
                            </div>
                            <div class="first-action-button" style="display: block; border-radius: 0px;"><img id="first-action-button-img" src=""><span id="first-action-button-title-win8">Button 1 Title</span></div>
                            <div class="second-action-button" style="display: block; border-radius: 0px 0px 3px 3px;"><img id="second-action-button-img" src=""><span id="second-action-button-title-win8">Button 2 Title</span></div>
                        </div>

                        <!--------------------------------------------------------------------------------------------------------------------->


                        <div class="preview-3 sample_notification" style="display: none; width: 280px; overflow-wrap: break-word; border-radius: 3px 3px 0px 0px;">
                            <div><button type="button" class="close pull-right" aria-label="Close" style="padding:3px;"><span aria-hidden="true">×</span></button></div>
                            <div class="sample_notification_title pre_title" style="margin: 5px;font-weight: bold;">
                                Notification Title</div>
                            <div>
                                <img src="" class="pull-left" id="sample_notification_logo" style="max-width: 70px;max-height :47px; margin-left: 12px;">
                            </div>
                            <div class="notification_body" style="margin-left: 72px;padding:0px;">
                                <div class="text-muted sample_notification_message pre_body" style="">This is the Notification Message</div>
                                <div class="text-muted sample_notification_url_style wordbreak" style="">revotas.com</div>
                            </div>
                        </div>

                        <!-------------------------------------------------------------------------------------------------------------------->

                        <div class="preview-4 sample_notification" style="display: none; min-height: 65px; background-color: rgb(222, 223, 224); width: 280px; display: flex; overflow-wrap: break-word; border-radius: 3px 3px 0px 0px;">
                            <div class="sample_notification_icon2" style="display: block;width: 60px;height: auto;text-align: center;">
                                <div id="sample_notification_logo" style="max-width: 50px; max-height: 47px;background-color: #dedfe0;order:1;" src="">
                                    <img src="img/chrome.png" style="height: 40px;width:40px;margin-top: 10px;">
                                </div>
                            </div>
                            <div class="notification_body" style="padding: 9px;width: calc(100% - 110px);order:2;margin-left:0px;">
                                <div class="sample_notification_title pre_title" style="font-weight: bold;">
                                    Notification Title</div>
                                <div class="text-muted sample_notification_message pre_body" style="">This is the Notification Message</div>
                            </div>


                            <div class="sample_notification_icon2" style="width: 60px;height: auto;text-align: center;order:3;">
                                <div class="sample_notification_icon" style="max-width: 50px; max-height: 50px;background-color: #dedfe0;">
                                    <img src="" id="sample_notification_logo" style="height: 40px;width:40px;margin-top: -10px;">
                                </div>
                            </div>
                        </div>

                        <!---------------------------------------------------------------------------------------------------------------------->


                        <div class="preview-5 mobile-sample" style="display:none;">
                            <div class="notification-box">
                                <div class="mobile-sample-notification">
                                    <div class="img-container">
                                        <div id="element">
                                            <img src="" class="pull-left" id="mobile-sample-notification-logo" style="max-width: 50px;max-height:50px"> </div>
                                    </div>
                                    <div class="mobile-sample-notification-title pre_title">Notification Title</div>
                                    <div class="text-muted mobile-sample-notification-message pre_body">This is the Notification Message</div>
                                    <div class="mobile-big-image">
                                        <img id="mobile-sample-big-image" src="" style="display: none; width: 264px; background-color: rgb(255, 255, 255);">
                                    </div>
                                    <div class="mobile-botton-box" style="display: block;">
                                        <div class="mobile-first-action-button">Button 1</div>
                                        <div class="mobile-second-action-button" style="display: inline-block;">Button 2</div>
                                    </div>
                                    <div class="text-muted mobile-sample-notification-url-style " style="word-break: break-all; margin-left: 70px; padding-bottom: 7px;"><i class="fa fa-cog"></i>revotas.com</div>
                                </div>
                            </div>
                        </div>

                    </div>
                </td></tr>

            </table>

        </div>
        </div>


    </div>
</section>


<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
<!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>


<script src="assets/js/datatimepicker.js"></script>
<script src="assets/js/daterangepicker/moment.min.js"></script>
<script src="assets/js/daterangepicker/daterangepicker.js"></script>

<script src="assets/js/bootstrap-toggle.min.js"></script>

<script>

    function toggleButtons(number) {
        if(number == 0) {
            Array.from(document.querySelectorAll('.first-action-button,.mobile-first-action-button,.second-action-button,.mobile-second-action-button')).forEach(function(element) {element.style.display='none';});
            document.getElementById('close_btn').style.display = 'block';
            document.querySelector('.mobile-botton-box').style.borderBottom = 'none';
        } else if(number == 1) {
            Array.from(document.querySelectorAll('.first-action-button,.mobile-first-action-button')).forEach(function(element) {element.style.display='block';});
            Array.from(document.querySelectorAll('.second-action-button,.mobile-second-action-button')).forEach(function(element) {element.style.display='none';});
            document.getElementById('close_btn').style.display = 'none';
            document.querySelector('.mobile-botton-box').style.borderBottom = '1px solid #d2d0d0';
        } else if(number == 2) {
            Array.from(document.querySelectorAll('.first-action-button,.mobile-first-action-button,.second-action-button,.mobile-second-action-button')).forEach(function(element) {element.style.display='block';});
            document.getElementById('close_btn').style.display = 'none';
            document.querySelector('.mobile-botton-box').style.borderBottom = '1px solid #d2d0d0';
        }
    }

    function toggleImage(number) {
        if(number == 0) {
            Array.from(document.querySelectorAll('.sample-big-image,#mobile-sample-big-image')).forEach(function(element) {element.style.display = 'none'});
        } else if(number == 1) {
            Array.from(document.querySelectorAll('.sample-big-image,#mobile-sample-big-image')).forEach(function(element) {element.style.display = 'block'});
        }
    }

    function changeButtonText(config) {
        if(config.button1) {
            document.getElementById('first-action-button-title').innerText = config.button1;
            document.getElementById('first-action-button-title-win8').innerText = config.button1;
            document.querySelector('.mobile-first-action-button').innerText = config.button1;
        }
        if(config.button2) {
            document.getElementById('second-action-button-title').innerText = config.button2;
            document.getElementById('second-action-button-title-win8').innerText = config.button2;
            document.querySelector('.mobile-second-action-button').innerText = config.button2;
        }
    }

    function changeTitle(title) {
        Array.from(document.querySelectorAll('.sample_notification_title,.mobile-sample-notification-title')).forEach(function(element) {
            element.innerHTML = title;
        });
    }

    function changeMessage(message) {
        Array.from(document.querySelectorAll('.sample_notification_message,.mobile-sample-notification-message')).forEach(function(element) {
            element.innerHTML = message;
        });
    }

    function changeIcon(src) {
        Array.from(document.querySelectorAll('img#sample_notification_logo,img#mobile-sample-notification-logo')).forEach(function(element) {
            element.src = src;
        })
    }

    function changePicture(src) {
        Array.from(document.querySelectorAll('.sample-big-image,#mobile-sample-big-image')).forEach(function(element) {
            element.src = src;
        })
    }

    function showPreview(index) {
        for(var i=1;i<=5;i++) {
            if(i==index) {
                Array.from(document.querySelectorAll('.preview-' + i)).forEach(function(element) {element.style.display=(index==4?'flex':'block')});
            } else {
                Array.from(document.querySelectorAll('.preview-' + i)).forEach(function(element) {element.style.display='none'});
            }
        }
    }
    showPreview(1);
    toggleButtons(0);
    toggleImage(0);

    document.getElementById('preview_select_type').addEventListener('change',function(e) {
        showPreview(e.target.value);
    });
</script>

<script>
    var converted = "";
    var utmcontrol = false;
    $(function () {

        $('#toggle').change(function () {
            var UTMDurum = $(this).prop('checked');


            if (UTMDurum) {

                $("#UTM_container").show();
                utmcontrol = true;

                ConvertToEnglish(document.getElementById('nname').value);

                document.getElementById('utmname').value = converted;
                document.getElementById('utmsource').value = "Revotas";
                document.getElementById('utmmedium').value = "WebPush";

            } else {
                $("#UTM_container").hide();
                utmcontrol = false;

            }

        })
    });

    var personalizeHeight = $("#nbody").height();
    $("#myBtn-title").height(personalizeHeight);
    $("#myBtn-body").height(personalizeHeight);


    // personalization modal operations
    var canBePersonalize = '<%=canBePersonalized%>';
    // console.log('can be person  '+canBePersonalize)
    var pers_area_type = "";
    $(document).ready(function () {

        $("#myBtn-title").click(function () {
            pers_area_type = "title";
            $("#personalizeModal").modal();
        });
    });
    $(document).ready(function () {
        $("#myBtn-body").click(function () {
            pers_area_type = "body";
            $("#personalizeModal").modal();
        });
    });
    $(document).ready(function () {
        $("#myBtn-url").click(function () {
            pers_area_type = "url";
            $("#personalizeModal").modal();
        });
    });
    //kursat

    $(document).ready(function () {
        $("#pers_modal_save").click(function () {
            if (pers_area_type == "title") {
                var merged_value = "";
                if ($("#ntitle").val() == "")
                    merged_value = document.getElementById('pers_merge_id').value;
                else
                    merged_value = $("#ntitle").val() + ' ' + $("#pers_merge_id").val();
                $("#ntitle").next("div").html(merged_value);
                $("#ntitle").val(merged_value);
                clearModalVariables();
            } else if (pers_area_type == "body") {
                var merged_value = "";
                if ($("#nbody").val() == "")
                    merged_value = document.getElementById('pers_merge_id').value;
                else
                    merged_value = $("#nbody").val() + ' ' + $("#pers_merge_id").val();
                $("#nbody").next("div").html(merged_value);
                $("#nbody").val(merged_value);
                clearModalVariables();
            } else if (pers_area_type == "url") {
                $("#nurl").val(document.getElementById('pers_merge_id').value);
                clearModalVariables();
            }
        });
    });

    function clearModalVariables() {
        $("#pers_def_id").val("");
        updateMergeSymbol();
    }

    //
    var generalPersonalization = false;
    var img_customization;
    var img_cust_campaign = false;

    var icon_cust_campaign = false;
    var icon_customization;
    $(function () {

        $('#icon-customize-toggle').change(function () {
            var icon_customization = $(this).prop('checked');


            if (icon_customization) {
                icon_cust_campaign = true;
                generalPersonalization = true;
            } else {
                icon_cust_campaign = false;
                if (img_cust_campaign !== true)
                    generalPersonalization = false;
            }

        })
    });

    $(function () {

        $('#img-customize-toggle').change(function () {
            var img_customization = $(this).prop('checked');


            if (img_customization) {
                img_cust_campaign = true;
                generalPersonalization = true;
            } else {
                img_cust_campaign = false;
                if (icon_cust_campaign !== true)
                    generalPersonalization = false;
            }

        })
    });

    var button_customization = false;
    var button_number = 0;

    $(function() {

        $('#add-button-toggle').change(function() {
            var button_toggle_value=$(this).prop('checked');
            if(button_toggle_value){
                $("#button-define-div").show();
                button_customization=true;
            }
            else{
                $("#button-define-div").hide();
                button_customization=false;
            }
        })
    });

    var url_customization;
    var url_cust_campaign = false;
    $(function () {

        $('#url-customize-toggle').change(function () {
            var url_customization = $(this).prop('checked');

            if (url_customization) {
                url_cust_campaign = true;
            } else {
                url_cust_campaign = false;
            }

        })
    });

    $(function () {
        var generalWidth = $("#nname").width();
        // if (camptype != "trgr_basket" && camptype != "trgr_order" && camptype != "visit" && canBePersonalize) {
        if ( canBePersonalize==='false') {
            // var buttonWidth = $("#myBtn-body").width();
            $("#nurl").width(generalWidth);
            $("#ntitle").width(generalWidth);
            $("#rvts_emoji_body").width(generalWidth + 25);
            $("#rvts_emoji_title").width(generalWidth + 25);
        }
    });


    function addButtons() {
        var firstButtonTitle = document.getElementById('first_button_title').value;
        var secondButtonTitle = document.getElementById('second_button_title').value;
        if (firstButtonTitle !== '' && secondButtonTitle === '') {
            //document.getElementById("first-button1").innerHTML = firstButtonTitle;
            button_customization = true;
            button_number = 1;
            //$("#preview-one-button").show();
            //$("#preview-two-button").hide();
            changeButtonText({button1: firstButtonTitle});
            toggleButtons(1);
        } else if (firstButtonTitle !== '' && secondButtonTitle !== '') {
            //document.getElementById("first-button").innerHTML = firstButtonTitle;
            //document.getElementById("second-button").innerHTML = secondButtonTitle;
            button_number = 2;
            //$("#preview-two-button").show();
            //$("#preview-one-button").hide();
            button_customization = true;
            changeButtonText({button1: firstButtonTitle, button2: secondButtonTitle});
            toggleButtons(2);
        } else {
            //$("#preview-two-button").hide();
            //$("#preview-one-button").hide();
            button_customization = false;
            button_number = 0;
            toggleButtons(0);
        }

    }

    function check_button_customization() {
        if (button_customization && button_number !== 0) {
            var button1_url = document.getElementById('first-button-url').value;
            var button2_url = document.getElementById('second-button-url').value;

            if (button_number === 1) {
                if (document.getElementById('first_button_title').value !== '' && button1_url !== '')
                    return false;
                else return true;
            } else if (button_number === 2) {
                if (document.getElementById('first_button_title').value !== '' && button1_url !== '' &&
                    document.getElementById('second_button_title').value !== '' && button2_url!== '')
                    return false;
                else return true;
            }
        } else
            return false;
    }


    function updateMergeSymbol() {
        var options2 = personalization_select.options;
        var value2 = options2[options2.selectedIndex].value;

        $("#pers_merge_id").val('!*' + pers_map[value2] + ';' + document.getElementById('pers_def_id').value + '*!');
    }


    $('#datepicker').datetimepicker({
        dateFormat: "yy-mm-dd",
        timeFormat: "hh:mm:ss"
    });

    $('#datepickerQueue').datetimepicker({
        dateFormat: "yy-mm-dd",
        timeFormat: "hh:mm:ss"
    });


    function ConvertToEnglish(str) {
        var maxLength = 100;
        var returnString = str.toLowerCase();
        returnString = returnString.replace(/ö/g, 'o');
        returnString = returnString.replace(/ç/g, 'c');
        returnString = returnString.replace(/ş/g, 's');
        returnString = returnString.replace(/ı/g, 'i');
        returnString = returnString.replace(/ğ/g, 'g');
        returnString = returnString.replace(/ü/g, 'u');
        returnString = returnString.replace(/[^a-z0-9\s-]/g, "");
        returnString = returnString.replace(/[\s-]+/g, " ");
        returnString = returnString.replace(/^\s+|\s+$/g, "");
        if (returnString.length > maxLength)
            returnString = returnString.substring(0, maxLength);
        returnString = returnString.replace(/\s/g, "");
        converted = returnString;

    }

    // jQuery.getScript('https://www.gstatic.com/firebasejs/5.0.2/firebase.js');

</script>

<script type="text/javascript">


    $(document).ready(function () {

        var ntitle = $("#ntitle").val();
        var nbody = $("#nbody").val();


        if ($.trim(ntitle) != "") {
            $(".pre_title").html(ntitle);
            changeTitle(ntitle);
        } else {
            $(".pre_title").html("Notification Title");
        }
        /*	$('#ntitle').keyup(function() {
                $(".pre_title").html($("#ntitle").val());
            });
    */
        if ($.trim(nbody) != "") {
            $(".pre_body").html(nbody);
        } else {
            $(".pre_body").html("Notification Message");
        }
        /*$('#nbody').keyup(function() {

              var nbodykey =$(this).val();
              var max = 35;
              var len = $(this).val().length;
              if (len >= max) {

                  var res = nbodykey.substring(1, 35);
                  $(".pre_body").html(res+"...");

              } else {
                  $(".pre_body").html(nbodykey);
              }


        });
        */


    });


</script>


<script type="text/javascript">
    var test_token = '';
    var current_rcp = '';
    var icn_url = "";
    var oldIcon = '<%=oldIcon.trim()%>';
    if (oldIcon != "") {
        $("#NewIconTable").hide();
        $("#DraftIconTable").show();

        $("#DraftIconTable").find('img').attr('src', oldIcon);
        $(".pre_icon_content").find('img').attr('src', oldIcon);
        $("#DraftIconTable").show();
        $(".pre_icon_content").show();
        icn_url = oldIcon;

        changeIcon(oldIcon);
    }
    var value ='';
    var options='';
    var controluser=getCookie('revotas_web_push_test_user');
    var choosefilterbulk = '<%=bulkfilter%>';
    var choosefiltermail = '<%=mailfilter%>';
    var personalizationfilter = '<%=personBuilder%>';
    var personalizationMap = '<%=persOptionMap%>';
    <%--var deneme =  '<%=deneme%>';--%>
    var pers_map = JSON.parse('<%=varr%>');

    if(controluser ==''){
        document.getElementById("request_permission").style.display = "inline-block";
    }else
        document.getElementById("send_test").style.display = "inline-block";
    var filter_type = "";

    var camptype = '<%=campType%>';

    var cmp_type = false;

    if (camptype == "std_bulk") {
        document.getElementById('segment_select_type').innerHTML = "<option selected value=\"bulk\">Bulk</option>";
        document.getElementById('segment_select').innerHTML = "<option>----- Choose target group -----</option> ";
        document.getElementById('segment_select').innerHTML += choosefilterbulk;
        filter_type = "blk";
        document.getElementById("timefield").style.display = "block";
        document.getElementById("ctype_select").innerHTML = "<option selected value=\"2\">Standart</option>";
    }

    if (camptype == "std_email") {
        document.getElementById('segment_select_type').innerHTML = "<option selected value=\"mailentegration\">Email</option>";
        document.getElementById('segment_select').innerHTML = "<option>----- Choose target group -----</option> ";
        document.getElementById('segment_select').innerHTML += choosefiltermail;

        filter_type = "mail";
        document.getElementById("timefield").style.display = "block";
        document.getElementById("ctype_select").innerHTML = "<option selected value=\"2\">Standart</option>";
    }

    if (camptype == "trgr_basket") {
        document.getElementById('segment_select_type').innerHTML = "<option selected value=\"trgr_basket\">Shopping Cart</option>";
        document.getElementById('segment_select').innerHTML = "<option>----- Choose target group -----</option> ";
        document.getElementById('segment_select').innerHTML += "<option value=\"100\">ALL</option> ";
        /*document.getElementById("ctype_select").innerHTML = "<option selected value=\"2\">Trigger</option>";

        document.getElementById("basket_order").style.display = "block";
        document.getElementById("exclude_recip").style.display = "block";*/

        // console.log(canBePersonalize);
        // console.log(canBePersonalize==='true');
        if (canBePersonalize==='true') {
            document.getElementById('myBtn-url').style.display = "block";
            document.getElementById('myBtn-title').style.display = "block";
            document.getElementById('myBtn-body').style.display = "block";
            document.getElementById('pers-image').style.display = "table-cell";
            document.getElementById('pers-icon').style.display = "table-cell";
            $("#pers-icon").width($("#pers-image").width() + 20);
            //ky update
            document.getElementById("personalization_select").innerHTML = personalizationfilter;
            options = personalization_select.options;
            value = options[options.selectedIndex].value;
            $("#pers_merge_id").val('!*' + pers_map[value] + ';*!');
            //
        }



        filter_type = "trgr_basket";
        document.getElementById("basket_order").style.display = "block";
        document.getElementById("exclude_recip").style.display = "block";
        document.getElementById("ctype_select").innerHTML = "<option selected value=\"4\">Trigger</option>";

        cmp_type = true;

    }

    if (camptype == "trgr_order") {
        document.getElementById('segment_select_type').innerHTML = "<option selected value=\"trgr_order\">Order</option>";
        document.getElementById('segment_select').innerHTML = "<option>----- Choose target group -----</option> ";
        document.getElementById('segment_select').innerHTML += "<option value=\"50\">ALL</option> ";

        filter_type = "trgr_order";
        document.getElementById("basket_order").style.display = "block";
        document.getElementById("ctype_select").innerHTML = "<option selected value=\"4\">Trigger</option>";
        cmp_type = true;
        console.log(canBePersonalize);
        if (canBePersonalize==='true') {
            document.getElementById('myBtn-url').style.display = "block";
            document.getElementById('myBtn-title').style.display = "block";
            document.getElementById('myBtn-body').style.display = "block";
            document.getElementById('pers-image').style.display = "table-cell";
            document.getElementById('pers-icon').style.display = "table-cell";
            $("#pers-icon").width($("#pers-image").width() + 20);

            //ky update
            document.getElementById("personalization_select").innerHTML = personalizationfilter;
            options = personalization_select.options;
            value = options[options.selectedIndex].value;
            $("#pers_merge_id").val('!*' + pers_map[value] + ';*!');
            //
        }



    }


    if (camptype == "visit") {

        document.getElementById('segment_select_type').innerHTML = "<option selected value=\"visit\">Visit</option>";
        document.getElementById('segment_select').innerHTML = "<option>----- Choose target group -----</option> ";
        document.getElementById('segment_select').innerHTML += "<option value=\"80\">ALL</option> ";

        filter_type = "visit";
        document.getElementById("basket_order").style.display = "block";
        document.getElementById("exclude_recip").style.display = "block";
        document.getElementById("ctype_select").innerHTML = "<option selected value=\"4\">Trigger</option>";
        cmp_type = true;
        if (canBePersonalize==='true') {
            document.getElementById('myBtn-url').style.display = "block";
            document.getElementById('myBtn-title').style.display = "block";
            document.getElementById('myBtn-body').style.display = "block";
            document.getElementById('pers-image').style.display = "table-cell";
            document.getElementById('pers-icon').style.display = "table-cell";
            $("#pers-icon").width($("#pers-image").width() + 20);
            document.getElementById("personalization_select").innerHTML = personalizationfilter;
            options = personalization_select.options;
            value = options[options.selectedIndex].value;
            $("#pers_merge_id").val('!*' + pers_map[value] + ';*!');

        }

    }

    if (camptype == "create_date") {

        document.getElementById('segment_select_type').innerHTML = "<option selected value=\"create_date\">Create_date</option>";
        document.getElementById('segment_select').innerHTML = "<option>----- Choose target group -----</option> ";
        document.getElementById('segment_select').innerHTML += "<option value=\"60\">ALL</option> ";
        document.getElementById("basket_order").style.display = "block";
        filter_type = "create_date";
        document.getElementById("ctype_select").innerHTML = "<option selected value=\"4\">Trigger</option>";
        cmp_type = true;
    }


    var utmparam = document.getElementById('utmparameters');
    var create_date = "";
    var create_date_queue = "";
    var bln = false;


    getnowtime();
    function getnowtime() {

        var d = new Date();
        var year = d.getFullYear();
        var month = d.getMonth() + 1;
        var date = d.getDate();
        var hour = d.getHours();
        var min = d.getMinutes();
        if (month < 10)
            month = '0' + month;
        if (date < 10)
            date = '0' + date;
        if (hour < 10)
            hour = '0' + hour;
        if (min < 10)
            min = '0' + min;

        create_date = year + '/' + month + '/' + date + ' ' + hour + ':' + min;
        create_date_queue = year + '/' + month + '/' + date + ' ' + hour + ':' + min;



    }


    function getRCPDomain() {

        $.ajax({ type: "GET",
            url: "http://cms.revotas.com/cms/ui/jsp/getRcp/getRcp.jsp?cust_id=" + customer_id,
            async: false,
            success : function(text)
            {
                response = text;
                if(response.trim() != ''){
                    console.log(response.trim());
                    rcp_domain = response.trim();

                }
            }
        });
    }






    var dmn = 'https://rcp9.revotas.com/rrcp/imc/testpush/revotas_test_push.jsp?';
    var customer_id = <%=custid%>;
    var rcp_domain = '';
    getRCPDomain();
    // console.log('rcp domain : ' + rcp_domain);
    var cookie_domain = 'revotas.com';
    function  getPermission() {
        var uuid;
        if(controluser=="")
        {
            uuid = uuidv4();
            setCookie('revotas_web_push_test_user',uuid,1000,cookie_domain);
            var newWindow = window.open('','_blank','left=400px,top=50px,location=yes,height=400,width=400,scrollbars=yes,status=yes');
            newWindow.location.href = dmn+'userid='+uuid+'&custid='+customer_id;
            setCookie('revotas_web_push_test','true',90,cookie_domain);
            controluser=getCookie('revotas_web_push_test_user');
            console.log(dmn+'&userid='+uuid+'&custid='+customer_id);
            setTimeout(() => {
                document.getElementById("send_test").style.display = "inline-block";
                document.getElementById("request_permission").style.display = "none";
            }, 2000);


            // location.reload();
            //todo update;
            // SendValue(cstid);
        }
        else{
            uuid = uuidv4();
            setCookie('revotas_web_push_test_user',uuid,1000,cookie_domain);
            var newWindow = window.open('','_blank','left=400px,top=50px,location=yes,height=400,width=400,scrollbars=yes,status=yes');
            newWindow.location.href = dmn+'userid='+uuid+'&custid='+customer_id;
            setCookie('revotas_web_push_test','true',90,cookie_domain);
            controluser=getCookie('revotas_web_push_test_user');
            console.log(dmn+'&userid='+uuid+'&custid='+customer_id);
            setTimeout(() => {
                document.getElementById("send_test").style.display = "inline-block";
                document.getElementById("request_permission").style.display = "none";
            }, 2000);
        }
    }

    function sendTestPush(){

        var uuid;
        if(controluser=="")
        {
            uuid = uuidv4();
            setCookie('revotas_web_push_test_user',uuid,1000,cookie_domain);
            var newWindow = window.open('','_blank','left=400px,top=50px,location=yes,height=400,width=400,scrollbars=yes,status=yes');
            newWindow.location.href = dmn+'userid='+uuid+'&cust_key='+customer_id;
            setCookie('revotas_web_push_test','true',90,cookie_domain);
            controluser=getCookie('revotas_web_push_test_user');
        }else{
            getUserRcp();
            getUserTestToken();
            sendTestPushParameters();
        }
    }

    function getUserTestToken() {
        var user_test_id = getCookie('revotas_web_push_test_user');
        console.log(user_test_id);
        if(user_test_id !='' && typeof user_test_id != undefined){
            $.ajax({ type: "GET",
                url: "https://rcp9.revotas.com/rrcp/imc/testpush/get_user_token.jsp?userid=" + user_test_id,
                async: false,
                success : function(text)
                {
                    response = text;
                    if(response.trim() != '' && response.trim() != '500' && response.trim() != '100'){
                        test_token = response.trim();
                        console.log(test_token);
                    }else {
                        alert('Clear Your Cookies');
                    }
                }
            });
        }
        else {
            // alert('Contact with Your Customer Representative');
            getPermission();
        }
    }

    function getUserRcp() {

        $.ajax({ type: "GET",
            url: "http://cms.revotas.com/cms/ui/jsp/getRcp/getRcp.jsp?cust_id=" + customer_id,
            async: false,
            success : function(text)
            {
                response = text;
                if(response.trim() != ''){
                    current_rcp = 'https://'+response.trim();
                    console.log(current_rcp);
                }
            }
        });

    }

    function sendTestPushParameters(){
        var cname = document.getElementById('nname').value;
        var title = document.getElementById('ntitle').value;
        var body = document.getElementById('nbody').value;
        var urll = document.getElementById('nurl').value;
        var cust_id =<%=custid%>;
        var segment = "1"; //segmentler oluştuğunda değişecek
        var campaign_type = document.getElementById('ctype_select').value;
        var segment_filter = document.getElementById('segment_select').value;
        var exclude_time = document.getElementById('camp_frequency').value;
        var first_button_t = document.getElementById('first_button_title').value;
        var second_button_t = document.getElementById('second_button_title').value;
        var first_button_u = document.getElementById('first-button-url').value;
        var second_button_u = document.getElementById('second_button_title').value;



        if (cname == "")
            alert("Please,Enter Campaign Name");
        else if (title == "")
            alert("Please,Enter Title");
        else if (body == "")
            alert("Please,Enter Body");
        else if (urll == "")
            alert("Please,Enter URL");
        else if (check_button_customization()) {
            alert("Please, Fill Related Areas For Buttons");
        } else if (!urll.includes("https") && !urll.includes("http")) {
            alert("Attention! URL does not include http or https");
        }

        else if (segment_filter == "" || typeof segment_filter == "undefined" || segment_filter == null)
            alert("Please,Choose Segment");
        else if (cmp_type && (document.getElementById("trigger_time").value).trim() == "")
            alert("please,Enter Time Schedule");
        else {

            var triger_time_type = document.getElementById("trgr-prm_type").value;
            var triger_time_parameter = (document.getElementById("trigger_time").value).trim();
            var slct_time = "nowtime";
            if (bln) {
                create_date = document.getElementById('datepicker').value;
                create_date_queue = document.getElementById('datepickerQueue').value;
                slct_time = "spesifictime";
            }
            segment = segment_filter;

            ConvertToEnglish(cname);

            var ucampaign = converted;
            var usource = "Revotas";
            var umedium = "WebPush";
            var uterm = "";
            var ucontent = "";

            if (utmcontrol) {
                ConvertToEnglish(document.getElementById('utmname').value);
                ucampaign = converted;
                ConvertToEnglish(document.getElementById('utmsource').value);
                usource = converted;
                ConvertToEnglish(document.getElementById('utmmedium').value);
                umedium = converted;
                ConvertToEnglish(document.getElementById('utmterm').value);
                uterm = converted;
                ConvertToEnglish(document.getElementById('utmcontent').value);
                ucontent = converted;

            }

            var personalize_campaign = 0;
            var personalize_img = 0;
            var personalize_icon = 0;
            var button_count = 0;
            var first_button_title = '';
            var second_button_title = '';
            var first_button_url = '';
            var second_button_url = '';
            // var personalize_url =0;
            if (generalPersonalization) {
                personalize_campaign = 1;
                if (img_cust_campaign)
                    personalize_img = 1;
                if (icon_cust_campaign)
                    personalize_icon = 1;
            } else {
                if (title.includes('!*') || body.includes('!*') || urll.includes('!*')) {
                    personalize_campaign = 1;
                }
            }

            if(button_customization){
                if(button_number == 1){
                    button_count = 1;
                    first_button_title = document.getElementById('first_button_title').value;
                    first_button_url = document.getElementById('first-button-url').value;
                }
                else if(button_number==2){
                    button_count = 2;
                    first_button_title = document.getElementById('first_button_title').value;
                    first_button_url = document.getElementById('first-button-url').value;
                    second_button_title = document.getElementById('second_button_title').value;
                    second_button_url = document.getElementById('second-button-url').value;
                }
                else{
                    button_count=0;
                    first_button_title = '';
                    first_button_url = '';
                    second_button_title = '';
                    second_button_url = '';
                }
            }


            var http = new XMLHttpRequest();
            current_rcp = current_rcp.replace('https','http');
            var url = current_rcp + '/rrcp/imc/testpush/send_test_push.jsp?'; //canlıya alındığında adres değişecek
            var params = "title="
                + encodeURIComponent(title).replace(/%20/g, '*--*')
                + "&body="
                + encodeURIComponent(body).replace(/%20/g, '*--*')
                + "&url=" + encodeURIComponent(urll)
                + "&img=" + img_url  + "&custid=" + cust_id
                + "&icn=" + icn_url
                + "&campaign_type=" + campaign_type + "&campaign_name="
                + encodeURIComponent(cname).replace(/%20/g, '*--*')
                + "&utmcampaign="
                + encodeURIComponent(ucampaign).replace(/%20/g, '*--*')
                + "&utmsource="
                + encodeURIComponent(usource).replace(/%20/g, '*--*')
                + "&utmmedium="
                + encodeURIComponent(umedium).replace(/%20/g, '*--*')
                + "&utmterm="
                + encodeURIComponent(uterm).replace(/%20/g, '*--*')
                + "&utmcontent="
                + encodeURIComponent(ucontent).replace(/%20/g, '*--*')
                + "&personalize=" + personalize_campaign
                + "&personalize_img=" + personalize_img
                + "&personalize_icon=" + personalize_icon
                + "&button_count=" + button_count
                + "&first_button_title=" + encodeURIComponent(first_button_title).replace(/%20/g, '*--*')
                + "&first_button_url=" + first_button_url
                + "&cookie_id=" + getCookie('revotas_web_push_test_user')
                + "&test_token=" + test_token
                + "&camp_type=" + camptype
                + "&second_button_title=" + encodeURIComponent(second_button_title).replace(/%20/g, '*--*')
                + "&second_button_url=" + second_button_url;

            http.open("POST", url, true);

            //Send the proper header information along with the request
            http.setRequestHeader("Content-type",
                "application/x-www-form-urlencoded; charset=UTF-8");

            http.onreadystatechange = function () {//Call a function when the state changes.
                if (http.readyState == 4 && http.status == 200) {
                    var serverResponse = http.responseText;
                    if (serverResponse == 200) {
                        alert("Check Your WebPushes");

                        <%--window.location.href = "campaign_list.jsp?cust_id=" +<%=custid%>;--%>

                    } else{
                        setCookie('revotas_web_push_test_user','',1000,cookie_domain);
                        // alert("Failed Please Clean Your Cookies");
                        // getPermission();
                        controluser=getCookie('revotas_web_push_test_user');
                        getPermission();
                        // location.reload();
                        //    todo update

                    }

                }
            };

            http.send(params);

        }
    }

    function setCookie(name,value,days,ckie_dmn) {
        var expires = "";
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days*24*60*60*1000));
            expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "")  + expires +";domain="+ckie_dmn+ "; path=/";
    }

    function getCookie(cname) {
        var b = document.cookie.match('(^|[^;]+)\\s*' + cname + '\\s*=\\s*([^;]+)');
        return b ? b.pop() : '';
    }



    function uuidv4() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }


    function create_campaign(st, appr) {

        var chckk = document.getElementById('utmid');

        var cname = document.getElementById('nname').value;
        var title = document.getElementById('ntitle').value;
        var body = document.getElementById('nbody').value;
        var urll = document.getElementById('nurl').value;
        var cust_id =<%=custid%>;
        var segment = "1"; //segmentler oluştuğunda değişecek
        var campaign_type = document.getElementById('ctype_select').value;
        var segment_filter = document.getElementById('segment_select').value;
        var exclude_time = document.getElementById('camp_frequency').value;
        var first_button_t = document.getElementById('first_button_title').value;
        var second_button_t = document.getElementById('second_button_title').value;
        var first_button_u = document.getElementById('first-button-url').value;
        var second_button_u = document.getElementById('second_button_title').value;


        if (cname == "")
            alert("Please,Enter Campaign Name");
        else if (title == "")
            alert("Please,Enter Title");
        else if (body == "")
            alert("Please,Enter Body");
        else if (urll == "")
            alert("Please,Enter URL");
        else if (check_button_customization()) {
            alert("Please, Fill Related Areas For Buttons");
        } else if (!urll.includes("https") && !urll.includes("http")) {
            alert("Attention! URL does not include http or https");
        }
        /*
        else if (img_url == "")
            alert("Please,Choose Image");

        else if (icn_url == "")
            alert("Please,Choose Icon");
        */
        else if (segment_filter == "" || typeof segment_filter == "undefined" || segment_filter == "----- Choose target group -----")
            alert("Please,Choose Segment");
        else if (cmp_type && (document.getElementById("trigger_time").value).trim() == "")
            alert("please,Enter Time Schedule");
        else {

            var triger_time_type = document.getElementById("trgr-prm_type").value;
            var triger_time_parameter = (document.getElementById("trigger_time").value).trim();
            var slct_time = "nowtime";
            if (bln) {
                create_date = document.getElementById('datepicker').value;
                create_date_queue = document.getElementById('datepickerQueue').value;
                slct_time = "spesifictime";
            }
            segment = segment_filter;

            ConvertToEnglish(cname);

            var ucampaign = converted;
            var usource = "Revotas";
            var umedium = "WebPush";
            var uterm = "";
            var ucontent = "";

            if (utmcontrol) {
                ConvertToEnglish(document.getElementById('utmname').value);
                ucampaign = converted;
                ConvertToEnglish(document.getElementById('utmsource').value);
                usource = converted;
                ConvertToEnglish(document.getElementById('utmmedium').value);
                umedium = converted;
                ConvertToEnglish(document.getElementById('utmterm').value);
                uterm = converted;
                ConvertToEnglish(document.getElementById('utmcontent').value);
                ucontent = converted;

            }

            var personalize_campaign = 0;
            var personalize_img = 0;
            var personalize_icon = 0;
            var button_count = 0;
            var first_button_title = '';
            var second_button_title = '';
            var first_button_url = '';
            var second_button_url = '';
            // var personalize_url =0;
            if (generalPersonalization) {
                personalize_campaign = 1;
                if (img_cust_campaign)
                    personalize_img = 1;
                if (icon_cust_campaign)
                    personalize_icon = 1;
            } else {
                if (title.includes('!*') || body.includes('!*') || urll.includes('!*')) {
                    personalize_campaign = 1;
                }
            }

            if(button_customization){
                if(button_number == 1){
                    button_count = 1;
                    first_button_title = document.getElementById('first_button_title').value;
                    first_button_url = document.getElementById('first-button-url').value;
                }
                else if(button_number==2){
                    button_count = 2;
                    first_button_title = document.getElementById('first_button_title').value;
                    first_button_url = document.getElementById('first-button-url').value;
                    second_button_title = document.getElementById('second_button_title').value;
                    second_button_url = document.getElementById('second-button-url').value;
                }
                else{
                    button_count=0;
                    first_button_title = '';
                    first_button_url = '';
                    second_button_title = '';
                    second_button_url = '';
                }
            }
            // $("#nbody").val().includes('!**')
            <%--var cname = document.getElementById('nname').value;--%>
            <%--var title = document.getElementById('ntitle').value;--%>
            <%--var body = document.getElementById('nbody').value;--%>
            <%--var urll = document.getElementById('nurl').value;--%>
            <%--var cust_id =<%=custid%>;--%>
            <%--var segment = "1"; //segmentler oluştuğunda değişecek--%>
            <%--var campaign_type = document.getElementById('ctype_select').value;--%>
            <%--var segment_filter=document.getElementById('segment_select').value;--%>
            <%--var exclude_time=document.getElementById('camp_frequency').value;--%>





            if(create_date == null){
                getnowtime();
            }
            if(create_date_queue == null){
                getnowtime();
            }
            var http = new XMLHttpRequest();
            var url = "insert_campaign.jsp"; //canlıya alındığında adres değişecek
            var statu = st;
            var approvel_id = appr;
            var params = "title="
                + encodeURIComponent(title).replace(/%20/g, '*--*')
                + "&body="
                + encodeURIComponent(body).replace(/%20/g, '*--*')
                + "&url=" + encodeURIComponent(urll)
                + "&img=" + img_url + "&segment="
                + segment + "&custid=" + cust_id + "&statuid=" + statu
                + "&approvelid=" + approvel_id + "&icn=" + icn_url
                + "&campaign_type=" + campaign_type + "&campaign_name="
                + encodeURIComponent(cname).replace(/%20/g, '*--*')
                + "&utmcampaign="
                + encodeURIComponent(ucampaign).replace(/%20/g, '*--*')
                + "&utmsource="
                + encodeURIComponent(usource).replace(/%20/g, '*--*')
                + "&utmmedium="
                + encodeURIComponent(umedium).replace(/%20/g, '*--*')
                + "&utmterm="
                + encodeURIComponent(uterm).replace(/%20/g, '*--*')
                + "&utmcontent="
                + encodeURIComponent(ucontent).replace(/%20/g, '*--*')
                + "&send_date=" + create_date
                + "&queued_date=" + create_date_queue
                + "&filter_type=" + filter_type
                + "&triger_time_type=" + triger_time_type
                + "&triger_time_parameter=" + triger_time_parameter
                + "&start_time_type=" + slct_time
                + "&exclude_time=" + exclude_time
                + "&personalize=" + personalize_campaign
                + "&personalize_img=" + personalize_img
                + "&personalize_icon=" + personalize_icon
                + "&button_count=" + button_count
                + "&first_button_title=" + encodeURIComponent(first_button_title).replace(/%20/g, '*--*')
                + "&first_button_url=" + first_button_url
                + "&second_button_title=" + encodeURIComponent(second_button_title).replace(/%20/g, '*--*')
                + "&second_button_url=" + second_button_url;



            http.open("POST", url, true);

            //Send the proper header information along with the request
            http.setRequestHeader("Content-type",
                "application/x-www-form-urlencoded; charset=UTF-8");

            http.onreadystatechange = function () {//Call a function when the state changes.
                if (http.readyState == 4 && http.status == 200) {
                    var serverResponse = http.responseText;

                    if (serverResponse == 200)  {
                        alert("Create campaign is successful");

                        window.location.href = "campaign_list.jsp?cust_id=" +<%=custid%>;

                    } else
                        alert("Campaign Failed");
                }
            }
            http.send(params);

        }

    }

    var img_url = "";

    function imgupload() {


        var img = document.getElementById('submitfile').value;
        if (img != "") {
            var formData = new FormData();

            formData.append('cust_id', <%=custid%>);//canlıya alındığında değişecek
            formData.append('file', $('#submitfile')[0].files[0]);
            $.ajax({
                url: 'https://revotrack.revotas.com/trc/webpush/fileupload.jsp',//canlıya alındığında adres değiştirilecek
                type: 'POST',
                data: formData,
                processData: false, // tell jQuery not to process the data
                contentType: false, // tell jQuery not to set contentType
                success: function (data) {
                    img_url = data.data.img_url;
                    /*
                    document.getElementById('imgupload').style.display = "none";
                    document.getElementById('url_display').innerHTML = "Image <br>"
                            + "<img src=\""+img_url+"\" width=150 heigh=150> &nbsp;&nbsp;&nbsp;&nbsp;<button onclick=\"delete_img('img')\">X</button>";
                    document
                            .getElementById("url_display")
                            .setAttribute("style",
                                    "display: block; margin-left:30px");
                    */

                    $("#NewImgTable").hide();
                    $("#DraftImgTable").find('img').attr('src', img_url);
                    $(".pre_body_img").find('img').attr('src', img_url);
                    changePicture(img_url);
                    toggleImage(1);
                    $("#DraftImgTable").show();
                    $(".pre_body_img").show();
                }
            });

        } else
            alert("Please,Choose File");
    }


    function iconupload() {
        var icg = document.getElementById('iconsubmitfile').value;
        if (icg != "") {
            var formData = new FormData();

            formData.append('cust_id', <%=custid%>);//canlıya alındığında değişecek
            formData.append('file', $('#iconsubmitfile')[0].files[0]);
            $.ajax({
                url: 'https://revotrack.revotas.com/trc/webpush/iconupload.jsp',//canlıya alındığında adres değiştirilecek
                type: 'POST',
                data: formData,
                processData: false, // tell jQuery not to process the data
                contentType: false, // tell jQuery not to set contentType
                success: function (data) {
                    icn_url = data.data.img_url;
                    /*
                    document.getElementById('iconupload').style.display = "none";
                    document.getElementById('ucl_display').innerHTML = "Icon <br>"
                            + "<img src=\""+icn_url+"\" width=75 heigh=75> &nbsp;&nbsp;&nbsp;&nbsp;<button onclick=\"delete_img('icn')\">X</button>";
                    document
                        .getElementById("ucl_display")
                        .setAttribute("style",
                                "display: block; margin-left:30px");
                    */

                    $("#NewIconTable").hide();
                    $("#DraftIconTable").show();
                    $("#DraftIconTable").find('img').attr('src', icn_url);
                    $(".pre_icon_content").find('img').attr('src', icn_url);
                    $("#DraftIconTable").show();
                    $(".pre_icon_content").show();
                    changeIcon(icn_url);
                }
            });
        } else
            alert("Please,Choose File");
    }

    function delete_img(deg) {
        var result = confirm("Are you sure,deleted it");
        if (result) {
            var adr = "";
            if (deg == 'icn')
                adr = icn_url;
            else {
                adr = img_url;
            }
            var http = new XMLHttpRequest();
            var url = "delete_img.jsp"; //canlıya alındığında adres değişecek
            var params = "adress=" + adr;

            http.open("POST", url, true);

            //Send the proper header information along with the request
            http.setRequestHeader("Content-type",
                "application/x-www-form-urlencoded");

            http.onreadystatechange = function () {//Call a function when the state changes.
                if (http.readyState == 4 && http.status == 200) {
                    var serverResponse = http.responseText;

                    if (serverResponse == 200) {
                        /*
                        if (deg == 'img') {
                            document.getElementById('submitfile').value = "";
                            img_url = "";
                            document.getElementById('imgupload').style.display = "block";
                            document.getElementById('url_display').style.display = "none";
                        } else {

                            document.getElementById('iconsubmitfile').value = "";
                            icn_url = "";
                            document.getElementById('iconupload').style.display = "block";
                            document.getElementById('ucl_display').style.display = "none";
                        }
                        */
                        if (deg == 'img') {
                            $("#DraftImgTable").hide();
                            $("#NewImgTable").show();
                            $(".pre_body_img").find('img').attr('src', "");
                            changePicture('');
                            toggleImage(0);
                        } else {

                            $("#DraftIconTable").hide();
                            $("#NewIconTable").show();
                            $(".pre_icon_content").find('img').attr('src', "");
                            changeIcon('');
                        }


                    }

                }
            }

            http.send(params);

        }

    }

    function snextdate(txt) {

        if (txt == "now") {

            var d = new Date();
            var year = d.getFullYear();
            var month = d.getMonth() + 1;
            var date = d.getDate();
            var hour = d.getHours();
            var min = d.getMinutes();
            if (month < 10)
                month = '0' + month;
            if (date < 10)
                date = '0' + date;
            if (hour < 10)
                hour = '0' + hour;
            if (min < 10)
                min = '0' + min;

            create_date = year + '/' + month + '/' + date + ' ' + hour + ':' + min;


            document.getElementById('choosetime').style.display = "none";
            bln = false;

        } else {

            document.getElementById('choosetime').style.display = "block";
            bln = true;

        }

    }

    function snextdateQueue(txt) {

        if (txt == "now") {

            var d = new Date();
            var year = d.getFullYear();
            var month = d.getMonth() + 1;
            var date = d.getDate();
            var hour = d.getHours();
            var min = d.getMinutes();
            if (month < 10)
                month = '0' + month;
            if (date < 10)
                date = '0' + date;
            if (hour < 10)
                hour = '0' + hour;
            if (min < 10)
                min = '0' + min;

            create_date_queue = year + '/' + month + '/' + date + ' ' + hour + ':' + min;

            document.getElementById('choosetimeQueue').style.display = "none";
            bln = false;

        } else {

            document.getElementById('choosetimeQueue').style.display = "block";
            bln = true;

        }
    }

    function KeyPressed(e) {
        console.log('keypressed');
        $(".pre_title").html(document.getElementById('rvts_emoji_title').childNodes[2].innerHTML);
        changeTitle(document.getElementById('rvts_emoji_title').childNodes[2].innerHTML);
        $(".pre_body").html(document.getElementById('rvts_emoji_body').childNodes[2].innerHTML);
        changeMessage(document.getElementById('rvts_emoji_body').childNodes[2].innerHTML);
    }

</script>

<!-- Begin emoji-picker JavaScript -->
<script src="assets/emoji/js/config.js"></script>
<script src="assets/emoji/js/util.js"></script>
<script src="assets/emoji/js/jquery.emojiarea.js"></script>
<script src="assets/emoji/js/emoji-picker.js"></script>
<script src="assets/emoji/js/unicode_emoji.js"></script>
<!-- End emoji-picker JavaScript -->
<script type="text/javascript">
    $(function () {
        // Initializes and creates emoji set from sprite sheet
        window.emojiPicker = new EmojiPicker({
            emojiable_selector: '[data-emojiable=true]',
            assetsPath: 'assets/emoji/img/',
            popupButtonClasses: 'fa fa-smile-o'
        });
        window.emojiPicker.discover();
    });
</script>
<script>
    function openOptions(evt, cityName) {
        var i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("tabcontent");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].style.display = "none";
        }
        tablinks = document.getElementsByClassName("tablinks");
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].className = tablinks[i].className.replace(" active", "");
        }
        document.getElementById(cityName).style.display = "block";
        evt.currentTarget.className += " active";
    }
    // Get the element with id="defaultOpen" and click on it
    document.getElementById("defaultOpen").click();

    function toggleSection(obj, sec)
    {
        var tItem = document.getElementById(sec);
        if (tItem.style.display == "none")
        {
            tItem.style.display = "";
            obj.innerText = "Hide Additional Options";
        }
        else
        {
            tItem.style.display = "none";
            obj.innerText = "Additional Options";
        }
    }
</script>



</body>
</html>

