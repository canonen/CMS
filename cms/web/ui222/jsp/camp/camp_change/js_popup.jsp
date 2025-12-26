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
    from = escape('"' + from_name + '" ' + from_address);

    subj_html = escape(document.all.item('subj_html').value);
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
