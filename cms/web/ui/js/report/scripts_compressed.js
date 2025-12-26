function pop_up_win(url) {
    windowName = 'report_results_window';
    windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=700';
    ReportWin = window.open(url, windowName, windowFeatures)
}
function toggleContentBox(container) {
    var doc = document.getElementById(container);
    if (doc.style.display != "block") {
        doc.style.display = 'block';
        document.getElementById(container + '_excol').src = 'http://www.revotas.com/v5/samplereport/images/b_1.png'
    } else {
        doc.style.display = 'none';
        document.getElementById(container + '_excol').src = 'http://www.revotas.com/v5/samplereport/images/b_2.png'
    }
}
function switchGraphTab(t) {
    var i;
    for (i = 1; i <= 4; i++) {
        if (i == t) {
            document.getElementById('sumGraph' + i).style.display = 'block';
            document.getElementById('sumGraphLink' + i).setAttribute("class", "summaryTabsActive")
        } else {
            document.getElementById('sumGraph' + i).style.display = 'none';
            document.getElementById('sumGraphLink' + i).setAttribute("class", "summaryTabsPassive")
        }
    }
}
function toggleClickThrue(className, container, boxsize) {
    if (className == 'lessmoreContentMore') {
        document.getElementById(container).className = 'hasNoClass';
        document.getElementById('lessMoreContent' + container).className = 'hasNoClass'
    } else {
        document.getElementById('lessMoreContent' + container).className = 'lessmoreContentLess';
        document.getElementById(container).className = boxsize
    }
}
$(function () {
    $(".droptrue").sortable({
        connectWith: ".moveObj",
        handle: '.sectionSheaders',
        dropOnEmpty: true
    })
});
$(document).ready(function () {
    var bubbleKeepLiveTimer = null;
    var bubbleKeepLive = 0;
    var shown = false;
    $('.hovercontent').mouseenter(function () {
        var showItemId = $(this).parent().attr('class');
        var showItemHref = $(this).children(':first-child').attr("href");
        showItemHref = showItemHref.replace(/'/g, "\"");
        if (bubbleKeepLiveTimer) clearTimeout(bubbleKeepLiveTimer);
        if (shown) {
            return
        } else {
            $(this).append("<div class='hideme' style='color:#FFFFFF;top:0;left:35px;position:absolute;width:180px;'><div style='float:left;display:block;width:14px;height:14px;'><img src='http://www.revotas.com/v5/samplereport/dasdadas.png'/></div><table class='bubbleContainer' cellpadding='0' cellspacing='0' width='166' border='0'><tr><td><img src='http://www.revotas.com/v5/samplereport/document-export-icon.png'/></td><td><a style='text-decoration:none;color:#666666;' href='" + showItemHref + "'>Export</a></td></tr><tr><td><img src='http://www.revotas.com/v5/samplereport/Download-Database-icon.png'/></td><td><a style='text-decoration:none;color:#666666;' href='" + showItemHref + "'>Create Target Group</a></td></tr></table></div>");
            shown = true
        }
        return false
    }).mouseleave(function () {
        if (bubbleKeepLiveTimer) clearTimeout(bubbleKeepLiveTimer);
        bubbleKeepLiveTimer = setTimeout(function () {
            bubbleKeepLiveTimer = null;
            $('.hideme').remove();
            shown = false
        }, bubbleKeepLive);
        return false
    })
});