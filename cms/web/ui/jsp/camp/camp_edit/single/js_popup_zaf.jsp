function pers_popup()
{
	URL = 'camp_pers.jsp';
	windowName = '';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=120, width=670';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function dynamic_popup(contID)
{
    if (contID == "") {
        alert("please select content to preview");
        return;
    }
	URL = '/cms/ui/jsp/cont/cont_preview_frame.jsp?cont_id=' + contID;
	windowName = 'preview_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function mapper_popup()
{
	campID = document.all.item('camp_id').value;
	printFlag = <%= (isPrintCampaign?"1":"0") %>
    contID = document.all.item('cont_id')[document.all.item('cont_id').selectedIndex].value;
    attrID = ':';
	for (var i=0; i < FT.target.options.length; i++) {
		attrID += FT.target.options[i].value + ':';
	}
	URL = '/cms/ui/jsp/camp/camp_attr_mapper.jsp?camp_id=' + campID + '&print_flag=' + printFlag + '&cont_id_list=' + contID  + '&attr_id_list=' + attrID;
	windowName = 'attribute_mapper';
	windowFeatures = 'dependent=yes, scrollbars=no, resizable=no, toolbar=no, height=450, width=600';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function score_popup(contID)
{
    if (contID == "") {
        alert("please select content to score");
        return;
    }
    from_name = document.all.item('from_name').value;
    if (document.all.item('fa2').checked) {
        from_address = document.all.item('from_address').value;
    }
    else {
        from_address = document.all.item('from_address_id')[document.all.item('from_address_id').selectedIndex].text;
    }
    from = from_name + ' <' + from_address + '>';
    


    subj_html = document.all.item('subj_html').value;
    subj_text = subj_html;
    subj_aol = subj_html;

	URL = '/cms/ui/jsp/cont/cont_score_frame.jsp?cont_id=' + contID + '&from=' + from + '&subjText=' + subj_text + '&subjHtml=' + subj_html + '&subjAol=' + subj_aol;
	windowName = 'score_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function targetgroup_popup(filterID)
{
	URL = '/cms/ui/jsp/filter/filter_preview.jsp?filter_id=' + filterID;
	windowName = 'targetgroup_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function pv_tracker_popup(contID)
{
	originCampID = document.all.item('camp_id').value;
    if (contID == "") {
        alert("please select content");
        return;
    }
    if (!are_settings_valid(1.1)) return;
    from_name = document.all.item('from_name').value;
    if (document.all.item('fa2').checked) {
        from_address = document.all.item('from_address').value;
    }
    else {
        from_address = document.all.item('from_address_id')[document.all.item('from_address_id').selectedIndex].text;
    }
    from = escape('"' + from_name + '" <' + from_address + '>');

    subj = escape(document.all.item('subj_html').value);

	URL = '/cms/ui/jsp/pv/pv_test_config.jsp?pv_test_type_id=1&origin_camp_id=' + originCampID + '&cont_id=' + contID + '&from=' + from + '&subj=' + subj;
	windowName = 'score_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function pv_scorer_popup(contID)
{
	originCampID = document.all.item('camp_id').value;
    if (contID == "") {
        alert("please select content");
        return;
    }
    if (!are_settings_valid(1.1)) return;
    from_name = document.all.item('from_name').value;
    if (document.all.item('fa2').checked) {
        from_address = document.all.item('from_address').value;
    }
    else {
        from_address = document.all.item('from_address_id')[document.all.item('from_address_id').selectedIndex].text;
    }
    from = escape('"' + from_name + '" <' + from_address + '>');

    subj = escape(document.all.item('subj_html').value);

	URL = '/cms/ui/jsp/pv/pv_test_config.jsp?pv_test_type_id=2&origin_camp_id=' + originCampID + '&cont_id=' + contID + '&from=' + from + '&subj=' + subj;
	windowName = 'score_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function pv_optimizer_popup(contID)
{
	originCampID = document.all.item('camp_id').value;
    if (contID == "") {
        alert("please select content");
        return;
    }
    if (!are_settings_valid(1.1)) return;
    from_name = document.all.item('from_name').value;
    if (document.all.item('fa2').checked) {
        from_address = document.all.item('from_address').value;
    }
    else {
        from_address = document.all.item('from_address_id')[document.all.item('from_address_id').selectedIndex].text;
    }
    from = escape('"' + from_name + '" <' + from_address + '>');

    subj = escape(document.all.item('subj_html').value);

	URL = '/cms/ui/jsp/pv/pv_test_config.jsp?pv_test_type_id=3&origin_camp_id=' + originCampID + '&cont_id=' + contID + '&from=' + from + '&subj=' + subj;
	windowName = 'score_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function pv_report_popup(pv_test_type_id, pv_iq)
{
	URL = '/cms/ui/jsp/report/pv_report_iframe.jsp?pv_test_type_id='+pv_test_type_id+'&pv_iq=' + pv_iq;
	windowName = 'pv_report_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}
