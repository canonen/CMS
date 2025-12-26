var previewSelector = 'preview_container';
var previewSelector2 = 'preview_container2';
var campaignName='Top Sellers';
var campaignTitle='Top Sellers';
var campaignType = 50;
var containerSize = '';
var productLimit = '';
var campaignStatus = '1';
var campaignId = '';
var styleList = [];
var templateOption = document.getElementById('template-list');
var templateOption2 = document.getElementById('template-list2');
var presetOption = document.getElementById('preset-list');
var cssArea = document.getElementById('cssArea');
var templateName = document.getElementById('templateName');
var createTemplateName = document.getElementById('createTemplateName');
var templateSaving = document.getElementById('templateSaving');
var templateCreating = document.getElementById('templateCreating');
var saveSuccess = document.getElementById('saveSuccess');
var saveError = document.getElementById('saveError');
var createSuccess = document.getElementById('createSuccess');
var createError = document.getElementById('createError');
var deleteSuccess = document.getElementById('deleteSuccess');
var deleteError = document.getElementById('deleteError');
var saveButton = document.getElementById('saveCss');
var deleteButton = document.getElementById('deleteTemplate');
var campaignHtmlCode = document.getElementById('campaignHtmlCode');

if(editMode) {
    campaignName = configObj.camp_name;
    campaignTitle = configObj.camp_title;
    campaignType = configObj.camp_type;
    containerSize = configObj.container_size == 0 ? '' : configObj.container_size;
    productLimit = configObj.products_num_block == 0 ? '' : configObj.products_num_block;
    campaignStatus = configObj.status;
    campaignId = configObj.camp_id;
} else {
    campaignId = generateSessionId();
}

var divString = '<div class="<recommendation_selector>" campaign_id="'+campaignId+'"></div>';

campaignHtmlCode.addEventListener('click', function() {
    this.setSelectionRange(0,-1);
});

document.getElementById('campaignStatus').value=campaignStatus;
document.getElementById('containerSize').value=containerSize;
document.getElementById('productLimit').value=productLimit;
document.getElementById('campaignName').value=campaignName;
document.getElementById('campaignTitle').value=campaignTitle;
document.getElementById('campaignType').value=campaignType;
document.getElementById('campaignType').addEventListener('change',function(e) {
    campaignHtmlCode.value = divString.split('<recommendation_selector>').join(queryList[e.target.value]);
    campaignType=e.target.value;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit);
});
document.getElementById('campaignName').addEventListener('change',function(e) {campaignName=e.target.value;});
document.getElementById('campaignTitle').addEventListener('change',function(e)  {campaignTitle=e.target.value;renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit);});
document.getElementById('containerSize').addEventListener('change',function(e) {
    containerSize=e.target.value;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit);
    renderRecoPreview(previewSelector2,templateOption2.value);
});
document.getElementById('productLimit').addEventListener('change',function(e) {
    productLimit=e.target.value;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit);
    renderRecoPreview(previewSelector2,templateOption2.value);
})
document.getElementById('campaignStatus').addEventListener('change',function(e) {
    campaignStatus=e.target.value;
})

campaignHtmlCode.value = divString.split('<recommendation_selector>').join(queryList[campaignType]);


function renderRecoPreview(selector,css,contSize,limit) {
    css=css.split('<rvts_recommendation_selector>').join(selector);
    var mainDiv = document.querySelector('.' + selector);
    mainDiv.innerHTML = '';
    var newStyle = document.createElement('style');
    newStyle.innerHTML = css;
    document.head.appendChild(newStyle);
    styleList = styleList.filter(function(style) {
        if(style[selector]) {
            style[selector].remove();
            return false;
        } else
            return true;
    })
    styleList.push({[selector]:newStyle});

    fetch('https://'+rcpLink+'/rrcp/imc/recommendation/get_recommendation.jsp?cust_id='+custId+'&type='+campaignType)
    .then(function(resp) {return resp.json();})
    .then(function(resp) {
        currencyFetched.then(()=>{
            resp = resp.filter(function(element) {return element!=null;})
            resp = resp.map(function(element) {return element[0];});
            if(limit)resp = resp.filter(function(element, index) {return index<limit;});
            if(resp.length>0)fillContainer(mainDiv, resp, campaignTitle, campaignType, contSize, selector,null,currencyConfigs);
        });
    });
}


function fetchTemplates () {
    templateOption.innerHTML = '';
    templateOption2.innerHTML = '';
    fetch('https://f.revotas.com/frm/recommendation/get_recommendation_template.jsp?cust_id='+custId)
    .then(function(resp) {return resp.json();})
    .then(function(templates) {
        templates.forEach(function(template, index) {
            var temp = document.createElement('option');
            temp.id = template.templateId;
            if(editMode && temp.id == configObj.template_id)temp.selected = true;
            try {
                temp.value = decodeURIComponent(template.templateCss);
            } catch(e) {
                temp.value = template.templateCss;
            }
            temp.innerText = template.templateName;
            templateOption.appendChild(temp);
            templateOption2.appendChild(temp.cloneNode(true));
            if((editMode && temp.id == configObj.template_id) || (!editMode && index === 0)) {
                renderRecoPreview(previewSelector,temp.value,containerSize,productLimit);
                renderRecoPreview(previewSelector2,temp.value);
                cssArea.value = temp.value;
                document.getElementById('templateName').value = temp.innerText;
            }
        });
    })
}

function fetchPresets() {
    fetch('./csspresets/default.css').then(function(resp) {return resp.text();}).then(function(resp) {
        var temp = document.createElement('option');
        temp.value = resp;
        temp.innerText = "Default";
        presetOption.appendChild(temp);
        fetch('./csspresets/discount.css').then(function(resp) {return resp.text();}).then(function(resp) {
            var temp = document.createElement('option');
            temp.value = resp;
            temp.innerText = "Discount percent";
            presetOption.appendChild(temp);
        });
    });
}

templateOption.addEventListener('change', function(e) {
    renderRecoPreview(previewSelector,e.target.value,containerSize,productLimit);
});

templateOption2.addEventListener('change', function(e) {
    cssArea.value = e.target.value;
    templateName.value = e.target.querySelector('option:checked').innerText;
    renderRecoPreview(previewSelector2,e.target.value);
});

presetOption.addEventListener('change', function(e) {
    renderRecoPreview(previewSelector2,e.target.value);
});

cssArea.addEventListener('change', function(e) {
    renderRecoPreview(previewSelector2,e.target.value);
});

document.getElementById('deleteTemplate').addEventListener('click', function() {
    var answer = confirm('Are you sure?');
    if(!answer)
        return;
    var selectedOption = templateOption2.querySelector('option:checked');
    var id = selectedOption.id;
    var btn = this;
    this.setAttribute('disabled','true');
    this.style.marginTop = '-14px';
    saveButton.setAttribute('disabled','true');
    saveButton.style.marginTop = '-14px';
    templateSaving.style.display = 'inline-block';
    saveSuccess.style.display = 'none';
    deleteSuccess.style.display = 'none';
    fetch('https://f.revotas.com/frm/recommendation/save_recommendation_template.jsp?delete=true&id='+id+'&cust_id='+custId,
    {
        method:'POST',
        headers: {
            'Content-Type':'application/json'
        }
    }).then(function() {
        btn.removeAttribute('disabled');
        btn.style.marginTop = '8px';
        saveButton.removeAttribute('disabled');
        saveButton.style.marginTop = '8px';
        templateSaving.style.display = 'none';
        deleteSuccess.style.display = 'inline';
        fetchTemplates();
    }).catch(function() {
        btn.removeAttribute('disabled');
        btn.style.marginTop = '8px';
        saveButton.removeAttribute('disabled');
        saveButton.style.marginTop = '8px';
        templateSaving.style.display = 'none';
        deleteError.style.display = 'inline';
    });
});

document.getElementById('saveCss').addEventListener('click', function(e) {
    var selectedOption = templateOption2.querySelector('option:checked');
    var id = selectedOption.id;
    var css = cssArea.value;
    var name = templateName.value;
    var btn = this;
    this.setAttribute('disabled','true');
    this.style.marginTop = '-14px';
    deleteButton.setAttribute('disabled','true');
    deleteButton.style.marginTop = '-14px';
    templateSaving.style.display = 'inline-block';
    saveSuccess.style.display = 'none';
    deleteSuccess.style.display = 'none';
    fetch('https://f.revotas.com/frm/recommendation/save_recommendation_template.jsp?id='+id+'&cust_id='+custId+'&name='+name,
          {
            method:'POST',
            headers: {
				'Content-Type':'application/json'
			},
			body: encodeURIComponent(css)
    }).then(function() {
        btn.removeAttribute('disabled');
        btn.style.marginTop = '8px';
        deleteButton.removeAttribute('disabled');
        deleteButton.style.marginTop = '8px';
        templateSaving.style.display = 'none';
        saveSuccess.style.display = 'inline';
        selectedOption.value = css;
        selectedOption.innerText = name;
        Array.from(templateOption.children).forEach(function(option) {
            if(option.id == id) {
                option.value = css;
                option.innerText = name;
            }
        });
        if(templateOption.querySelector('option:checked').id == id) {
            renderRecoPreview(previewSelector, css, containerSize,productLimit);
        }
    }).catch(function() {
        btn.removeAttribute('disabled');
        btn.style.marginTop = '8px';
        deleteButton.removeAttribute('disabled');
        deleteButton.style.marginTop = '8px';
        templateSaving.style.display = 'none';
        saveError.style.display = 'inline';
    });


});

document.getElementById('createCss').addEventListener('click', function() {
    if(createTemplateName.value.trim() === '') {
        alert('Please enter a template name');
        createTemplateName.focus();
        return;
    }
    var selectedOption = presetOption.querySelector('option:checked');
    var css = selectedOption.value;
    var name = createTemplateName.value;
    var btn = this;
    this.setAttribute('disabled','true');
    this.style.marginTop = '-14px';
    templateCreating.style.display = 'inline-block';
    createSuccess.style.display = 'none';

    fetch('https://f.revotas.com/frm/recommendation/save_recommendation_template.jsp?cust_id='+custId+'&name='+name,
          {
            method:'POST',
            headers: {
				'Content-Type':'application/json'
			},
			body: encodeURIComponent(css)
    }).then(function() {
        btn.removeAttribute('disabled');
        btn.style.marginTop = '8px';
        templateCreating.style.display = 'none';
        createSuccess.style.display = 'inline';
        fetchTemplates();
    }).catch(function() {
        btn.removeAttribute('disabled');
        btn.style.marginTop = '8px';
        templateCreating.style.display = 'none';
        createError.style.display = 'inline';
    });

});

fetchTemplates();
fetchPresets();

document.getElementById('saveCampaign').addEventListener('click', function() {
    var params = '';
    params+='cust_id='+custId;
    params+='&camp_name='+document.getElementById('campaignName').value;
    params+='&camp_title='+document.getElementById('campaignTitle').value;
    params+='&camp_type='+document.getElementById('campaignType').value;
    params+='&template_id='+templateOption.querySelector('option:checked').id;
    params+='&container_size='+(containerSize ? containerSize : '0');
    params+='&products_num_block='+(productLimit ? productLimit : '0');
    params+='&status='+document.getElementById('campaignStatus').value;
    params+='&rcp_link='+rcpLink;
    params+='&camp_id='+campaignId;
    var btn=this;
    btn.setAttribute('disabled','true');
    fetch('http://cms.revotas.com/cms/ui/recommendation/save_recommendation_config_new.jsp?'+params,{
            method:'POST',
            headers: {
				'Content-Type':'application/json'
			},
            body: document.getElementById('campaignName').value + '<|>' + document.getElementById('campaignTitle').value + '<|>' + JSON.stringify(currencyConfigs)
    })
    .then(function() {
        fetch('https://f.revotas.com/frm/recommendation/save_recommendation_config_new.jsp?'+params,{
            method:'POST',
            headers: {
				'Content-Type':'application/json'
			},
			body: document.getElementById('campaignName').value + '<|>' + document.getElementById('campaignTitle').value + '<|>' + JSON.stringify(currencyConfigs)
    })
        .then(function() {
            fetch('https://'+rcpLink+'/rrcp/imc/recommendation/save_recommendation_config.jsp?'+params,{
                method:'POST',
                headers: {
                    'Content-Type':'application/json'
                },
                body: document.getElementById('campaignName').value + '<|>' + document.getElementById('campaignTitle').value
            }).then(function() {
                btn.removeAttribute('disabled');
                navLinks[3].click();
                alert('Campaign saved successfully');
            }).catch(function() {
                btn.removeAttribute('disabled');
                alert('An error has been occurred');
            })
        }).catch(function() {
            btn.removeAttribute('disabled');
            alert('An error has been occurred');
        });
    }).catch(function() {
        btn.removeAttribute('disabled');
        alert('An error has been occurred');
    })
});