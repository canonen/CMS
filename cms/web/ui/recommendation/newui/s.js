var cssParsed = [];

function numberToFixed(number,toFixed) {
        number=number.toString();
        var indexOfDot = number.indexOf('.');
        if(indexOfDot !== -1) {
            if(toFixed==0) {
                number = number.substring(0,indexOfDot);
            } else {
                number = number.split('').filter((e,i)=>{
                    return (indexOfDot+toFixed)>=i;
                }).join('');
                var decimalCount = number.length - indexOfDot - 1;
                if(toFixed>decimalCount)number=number.concat(Array.apply(null, Array(toFixed-decimalCount)).map(Number.prototype.valueOf,0).join(''));
            }
        } else if(toFixed>0) {
            number=number.concat(['.']);
            number=number.concat(Array.apply(null, Array(toFixed)).map(Number.prototype.valueOf,0).join(''));
        }
        return number;
    }
    
    function formatCurrency(number,currencyConfig) {
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
            if(indexOfComma === -1 || indexOfDot === -1)thousandSeparator = '';
            var decimalCount = currencyConfig.format.length - currencyConfig.format.indexOf(decimalSeparator) - 1;
            number = numberToFixed(number,decimalCount);
            var parts = number.split('.').length === 2 ? number.split('.') : number.split(',');
            var normalPart = parts[0];
            var decimalPart = parts[1] ? parts[1] : '';
			normalPart = normalPart.split('').reverse();
            normalPart = normalPart.map((e,i)=>{
                if((i+1)%3===0 && normalPart.length>(i+1))return thousandSeparator+e;
                else return e;
            }).reverse().join('');
            var currency = normalPart + (decimalPart ? (decimalSeparator + decimalPart) : '');
            if(currencyConfig.language === 'EN') currency = currencyConfig.currency + currency;
            else currency = currency + ' ' + currencyConfig.currency;
            return currency;
        } catch(e) {
            return originalNumber;
        }
        
    }

var previewSelector = 'preview_container';
var previewSelector2 = 'preview_container2';
var campaignName='Top Sellers';
var campaignTitle='Top Sellers';
var campaignType = 50;
var fallbackCampaignType = 0;
var campaignAddToCart = '0';
var addToCartScript = '';
var productScript = '';
var containerSize = '';
var productLimit = '';
var campaignStatus = '1';
var appendUTM = '1';
var excludeRecentlyViewed = '0';
var excludeRecentlyPurchased = '0';
var campaignId = '';
var styleList = [];
var cssIndexes = document.getElementById('cssIndexes');
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
    fallbackCampaignType = configObj.fallback_camp_type;
    campaignAddToCart = configObj.camp_add_to_cart;
    addToCartScript = decodeURIComponent(configObj.add_to_cart_script);
    productScript = decodeURIComponent(configObj.product_script);
    containerSize = configObj.container_size == 0 ? '' : configObj.container_size;
    productLimit = configObj.products_num_block == 0 ? '' : configObj.products_num_block;
    campaignStatus = configObj.status;
    campaignId = configObj.camp_id;
    appendUTM = configObj.append_utm;
    excludeRecentlyViewed = configObj.exclude_recently_viewed;
    excludeRecentlyPurchased = configObj.exclude_recently_purchased;
    if(appendUTM=='null')appendUTM = '1';
    if(excludeRecentlyViewed=='null')excludeRecentlyViewed = '0';
    if(excludeRecentlyPurchased=='null')excludeRecentlyPurchased = '0';
} else {
    campaignId = generateSessionId();
}

if(campaignAddToCart == 'null') campaignAddToCart = 0;
if(addToCartScript == 'null') addToCartScript = '';
if(productScript == 'null') productScript = '';

var divString = '<div class="<recommendation_selector>" campaign_id="'+campaignId+'"></div>';
cssArea.innerText = cssArea.innerText + "testttt"
cssIndexes.addEventListener('change', function(e) {
    var option = e.target.children[e.target.selectedIndex];
    var selectionStart = option.getAttribute('start');
    var selectionEnd = option.getAttribute('end');
    var fullText = cssArea.value;
    cssArea.focus();
    cssArea.value = fullText.substring(0, selectionStart);
    var scrollTop = cssArea.scrollHeight;
    cssArea.value = fullText;
    cssArea.setSelectionRange(selectionStart, selectionEnd);
    const textareaHeight = cssArea.clientHeight;
    if (scrollTop > textareaHeight){
        scrollTop -= textareaHeight / 2;
    } else{
        scrollTop = 0;
    }
    cssArea.scrollTop = scrollTop;
})

campaignHtmlCode.addEventListener('click', function() {
    this.setSelectionRange(0,-1);
});

document.getElementById('campaignStatus').value=campaignStatus;
document.getElementById('containerSize').value=containerSize;
document.getElementById('productLimit').value=productLimit;
document.getElementById('campaignName').value=campaignName;
document.getElementById('campaignTitle').value=campaignTitle;
document.getElementById('campaignType').value=campaignType;
document.getElementById('fallbackCampaignType').value=fallbackCampaignType;
document.getElementById('campaignAddToCart').value=campaignAddToCart;
document.getElementById('addToCartScript').value=addToCartScript;
document.getElementById('productScript').value=productScript;
document.getElementById('appendUTM').checked = parseInt(appendUTM);
document.getElementById('excludeRecentlyViewed').checked = parseInt(excludeRecentlyViewed);
document.getElementById('excludeRecentlyPurchased').checked = parseInt(excludeRecentlyPurchased);
document.getElementById('campaignType').addEventListener('change',function(e) {
    campaignHtmlCode.value = divString.split('<recommendation_selector>').join(queryList[e.target.value]);
    campaignType=e.target.value;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
});
document.getElementById('fallbackCampaignType').addEventListener('change',function(e) {
    fallbackCampaignType=e.target.value;
});
document.getElementById('campaignAddToCart').addEventListener('change', function(e) {
    campaignAddToCart = e.target.value;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
    renderRecoPreview(previewSelector2,templateOption.value,null,null,campaignAddToCart,addToCartScript,productScript);
});
document.getElementById('addToCartScript').addEventListener('change', function(e) {
    addToCartScript = e.target.value;
});
document.getElementById('productScript').addEventListener('change', function(e) {
    productScript = e.target.value;
});
document.getElementById('appendUTM').addEventListener('change',function(e) {
    appendUTM = e.target.checked ? 1 : 0;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
});
document.getElementById('excludeRecentlyViewed').addEventListener('change',function(e) {
    excludeRecentlyViewed = e.target.checked ? '1' : '0';
});
document.getElementById('excludeRecentlyPurchased').addEventListener('change',function(e) {
    excludeRecentlyPurchased = e.target.checked ? '1' : '0';
});
document.getElementById('campaignName').addEventListener('change',function(e) {campaignName=e.target.value;});
document.getElementById('campaignTitle').addEventListener('change',function(e)  {campaignTitle=e.target.value;renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);});
document.getElementById('containerSize').addEventListener('change',function(e) {
    containerSize=e.target.value;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
    renderRecoPreview(previewSelector2,templateOption2.value,null,null,campaignAddToCart,addToCartScript,productScript);
});
document.getElementById('productLimit').addEventListener('change',function(e) {
    productLimit=e.target.value;
    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
    renderRecoPreview(previewSelector2,templateOption2.value,null,null,campaignAddToCart,addToCartScript,productScript);
})
document.getElementById('campaignStatus').addEventListener('change',function(e) {
    campaignStatus=e.target.value;
})

campaignHtmlCode.value = divString.split('<recommendation_selector>').join(queryList[campaignType]);

function parseCss() {
    cssParsed = [];
    var css = cssArea.value;
    var pattern = /([.|#|@].+?){/g;
    while(match = pattern.exec(css)) {
        cssParsed.push({
            text: css.substring(match.index,pattern.lastIndex-1).trim(),
            startIndex: match.index,
            endIndex: (pattern.lastIndex-1)
        });
    }
    cssIndexes.innerHTML = '';
    cssParsed.forEach(e=>{
        var option = document.createElement('option');
        option.textContent = e.text;
        option.setAttribute('start',e.startIndex);
        option.setAttribute('end',e.endIndex);
        cssIndexes.appendChild(option);
    });
}

function renderRecoPreview(selector,css,contSize,limit,campAddToCart,addToCartScript,productScript) {
    productFilterFetched.then(()=>{
        var filterId = document.getElementById('productFilters').value;
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

        fetch('https://'+rcpLink+'/rrcp/imc/recommendation/get_recommendation.jsp?cust_id='+custId+'&type='+campaignType+(filterId ? '&filter_id=' + filterId : '')+(excludeRecentlyViewed?('&exclude_recently_viewed='+excludeRecentlyViewed):'')+(excludeRecentlyPurchased?('&exclude_recently_purchased='+excludeRecentlyPurchased):''))
        .then(function(resp) {return resp.json();})
        .then(function(resp) {
            currencyFetched.then(()=>{
                resp = resp.filter(function(element) {return element!=null;})
                resp = resp.map(function(element) {return element[0];});
                if(limit)resp = resp.filter(function(element, index) {return index<limit;});
                if(resp.length>0)fillContainer(mainDiv, resp, campaignTitle, campaignType, fallbackCampaignType, contSize, selector,null,null,currencyConfigs,campAddToCart,addToCartScript,productScript,appendUTM);
            });
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
                renderRecoPreview(previewSelector,temp.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
                renderRecoPreview(previewSelector2,temp.value,null,null,campaignAddToCart,addToCartScript,productScript);
                cssArea.value = temp.value;
                parseCss();
                document.getElementById('templateName').value = temp.innerText;
            }
        });
        if(configObj.template_id)Array.from(templateOption2.children).filter(e=>e.id==configObj.template_id)[0].selected=true;
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
    renderRecoPreview(previewSelector,e.target.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
});

templateOption2.addEventListener('change', function(e) {
    cssArea.value = e.target.value;
    parseCss();
    templateName.value = e.target.querySelector('option:checked').innerText;
    renderRecoPreview(previewSelector2,e.target.value,null,null,campaignAddToCart,addToCartScript,productScript);
});

presetOption.addEventListener('change', function(e) {
    renderRecoPreview(previewSelector2,e.target.value,null,null,campaignAddToCart,addToCartScript,productScript);
});

cssArea.addEventListener('change', function(e) {
    parseCss();
    renderRecoPreview(previewSelector2,e.target.value,null,null,campaignAddToCart,addToCartScript,productScript);
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
            renderRecoPreview(previewSelector, css, containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
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

document.getElementById('apply-conditions-all').addEventListener('click', function() {
    var params = '';
    params+='cust_id='+custId;
    if(typeof productFilterConditionConfig !== 'undefined' && productFilterConditionConfig.filterId) {
        params+='&filter_id='+productFilterConditionConfig.filterId;
    } else {
        params+='&filter_id=0';
    }
    var btn=this;
    btn.setAttribute('disabled','true');
    fetch('https://cms.revotas.com/cms/ui/recommendation/save_recommendation_filter_all.jsp?'+params,{
            method:'POST',
            headers: {
				'Content-Type':'application/json'
			}
    })
    .then(function() {
        fetch('https://f.revotas.com/frm/recommendation/save_recommendation_filter_all.jsp?'+params,{
            method:'POST',
            headers: {
				'Content-Type':'application/json'
			}
        })
        .then(function() {
            fetch('https://'+rcpLink+'/rrcp/imc/recommendation/save_recommendation_filter_all.jsp?'+params,{
                method:'POST',
                headers: {
                    'Content-Type':'application/json'
                }
            }).then(function() {
                btn.removeAttribute('disabled');
                alert('Filters applied to all campaigns successfully');
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

document.getElementById('saveCampaign').addEventListener('click', function() {
    var params = '';
    params+='cust_id='+custId;
    params+='&camp_name='+document.getElementById('campaignName').value;
    params+='&camp_title='+document.getElementById('campaignTitle').value;
    params+='&camp_type='+document.getElementById('campaignType').value;
    params+='&fallback_camp_type='+document.getElementById('fallbackCampaignType').value;
    params+='&template_id='+templateOption.querySelector('option:checked').id;
    params+='&container_size='+(containerSize ? containerSize : '0');
    params+='&products_num_block='+(productLimit ? productLimit : '0');
    params+='&status='+document.getElementById('campaignStatus').value;
    params+='&rcp_link='+rcpLink;
    params+='&camp_add_to_cart='+campaignAddToCart;
    params+='&add_to_cart_script='+encodeURIComponent(encodeURIComponent(addToCartScript));
    params+='&product_script='+encodeURIComponent(encodeURIComponent(productScript));
    params+='&append_utm='+appendUTM;
    params+='&exclude_recently_viewed='+excludeRecentlyViewed;
    params+='&exclude_recently_purchased='+excludeRecentlyPurchased;
    params+='&camp_id='+campaignId;
    if(typeof productFilterConditionConfig !== 'undefined' && productFilterConditionConfig.filterId) {
        params+='&filter_id='+productFilterConditionConfig.filterId;
    }
    var btn=this;
    btn.setAttribute('disabled','true');
    fetch('https://cms.revotas.com/cms/ui/recommendation/save_recommendation_config_new.jsp?'+params,{
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

//product filtering section

var __productFilterFunctions__ = null
var productFilterConditionConfig = null;
var conditionSelect = null;
var productFilterConditionConfigs = null;
var productFilterResolver = null;
var productFilterFetched = new Promise((resolve,reject)=>{
    productFilterResolver = resolve;
});

productFilterFetched.then((result)=>{
    if(!result)return;
    document.getElementById('save-conditions').removeAttribute('disabled');
    document.getElementById('apply-conditions-all').removeAttribute('disabled');
    document.getElementById('delete-condition').removeAttribute('disabled');
});

(async function() {
    
try {

__productFilterFunctions__ = await fetch('https://'+rcpLink+'/rrcp/imc/recommendation/get_product_filter_attributes.jsp?cust_id=' + custId)
.then(resp=>resp.json());

productFilterConditionConfigs = await fetch('https://'+rcpLink+'/rrcp/imc/recommendation/get_recommendation_filter.jsp?cust_id='+custId)
.then(resp=>resp.json());

__productFilterFunctions__.sort((a,b)=>{
    if(a.name < b.name) { return -1; }
    if(a.name > b.name) { return 1; }
    return 0;
});

var filterSelect = document.getElementById('productFilters');
filterSelect.innerHTML = '<option value="-1">[NO FILTER]</option>';
productFilterConditionConfigs.forEach(function(filter) {
    var option = document.createElement('option');
    option.innerText = filter.filterName;
    option.value = filter.filterId;
    filterSelect.appendChild(option);
});

filterSelect.addEventListener('change', function(ev) {
    var index = productFilterConditionConfigs.findIndex(e=>e.filterId == ev.target.value);
    if(index != -1) {
        document.querySelector('.condition-configs').style.display = '';
        document.getElementById('save-conditions').style.display = '';
        document.getElementById('delete-condition').style.display = '';
        productFilterConditionConfig = productFilterConditionConfigs[index];
        document.getElementById('filterName').value = ev.target.children[ev.target.selectedIndex].innerText;
        fillGroupObject(productFilterConditionConfig);
        reRender();
        renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
    } else {
        productFilterConditionConfig = {filterId: 0};
        document.querySelector('.condition-configs').style.display = 'none';
        document.getElementById('save-conditions').style.display = 'none';
        document.getElementById('delete-condition').style.display = 'none';
        renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
    }
});

conditionSelect = document.createElement('select');
__productFilterFunctions__.forEach(function(element) {
    var option = document.createElement('option');
    option.value = element.name;
    option.innerText = element.name;
    option.params = element.params;
    conditionSelect.appendChild(option);
});
conditionSelect.classList.add('form-control');
conditionSelect.style.width = '200px';

var index = productFilterConditionConfigs.findIndex(e=>e.filterId == configObj.filter_id);
if(index == -1) {
    productFilterConditionConfig = {filterId: 0};
} else {
    productFilterConditionConfig = productFilterConditionConfigs[index];
}
if(configObj.filter_id!='null' && configObj.filter_id>0)filterSelect.value = configObj.filter_id;
    
if(productFilterConditionConfig && productFilterConditionConfig.filterId) {
    fillGroupObject(productFilterConditionConfig);
    reRender();
}
    
if(configObj.filter_id == 0 || configObj.filter_id == 'null') {
    document.querySelector('.condition-configs').style.display = 'none';
    document.getElementById('save-conditions').style.display = 'none';
    document.getElementById('delete-condition').style.display = 'none';
}

document.getElementById('save-conditions').addEventListener('click', function() {
    if(productFilterConditionConfig && productFilterConditionConfig.filterId) {
        var btn=this;
        btn.setAttribute('disabled','true');
        fetch('https://'+rcpLink+'/rrcp/imc/recommendation/save_recommendation_filter.jsp?cust_id='+custId,{
            method: 'POST',
            body: JSON.stringify(clearGroupObject(productFilterConditionConfig))
          }).then(resp=>resp.text()).then(resp=>{
            productFilterConditionConfig.filterId = resp.trim();
            filterSelect.children[filterSelect.selectedIndex].value = productFilterConditionConfig.filterId;
            fetch('https://'+rcpLink+'/rrcp/imc/recommendation/process_recommendation_filter.jsp?cust_id='+custId+'&filter_id=' + productFilterConditionConfig.filterId)
            .then(resp=>resp.json())
            .then(resp => {
                if(resp.status === 'error') {
                    alert(resp.message);
                } else {
                    renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
                    renderRecoPreview(previewSelector2,templateOption2.value,null,null,campaignAddToCart,addToCartScript,productScript);
                    btn.removeAttribute('disabled');
                    alert("Product filter saved & processed successfully");
                }
            }).catch(function() {
                btn.removeAttribute('disabled');
                alert('An error has been occurred');
            });
          });
    } else {
        alert('Please select a filter to save');
    }
});
    
document.getElementById('delete-condition').addEventListener('click', function() {
    var answer = confirm('Are you sure you want to delete selected filter?');
    if(answer) {
        var btn=this;
        btn.setAttribute('disabled','true');
        fetch('http://'+rcpLink+'/rrcp/imc/recommendation/delete_recommendation_filter.jsp?cust_id='+custId+'&filter_id='+productFilterConditionConfig.filterId).then(resp=>resp.json()).then(resp=>{
            alert(resp.message);
            btn.removeAttribute('disabled');
            filterSelect.children[filterSelect.selectedIndex].remove();
            filterSelect.children[0].selected = true;
            productFilterConditionConfig = {filterId: 0};
            document.querySelector('.condition-configs').style.display = 'none';
            document.getElementById('save-conditions').style.display = 'none';
            document.getElementById('delete-condition').style.display = 'none';
            renderRecoPreview(previewSelector,templateOption.value,containerSize,productLimit,campaignAddToCart,addToCartScript,productScript);
        });
    }
});

document.getElementById('new-condition').addEventListener('click', function() {
    if(document.getElementById('filterName').value.trim()=='') {
        alert('Please enter a valid name for filter');
        return;
    }
    var minFilterId = Array.from(document.querySelector("#productFilters").children).map(e=>parseInt(e.value)).sort((a,b)=>(a-b))[0] - 1;
    var newFilterObj = {elements:[],filterId:minFilterId,operator:'AND',flag:0,type:'group',filterName:document.getElementById('filterName').value};
    productFilterConditionConfigs.push(newFilterObj);
    var option = document.createElement('option');
    option.innerText = newFilterObj.filterName;
    option.value = newFilterObj.filterId;
    filterSelect.appendChild(option);
    document.querySelector("#productFilters").selectedIndex = document.querySelector("#productFilters").childElementCount-1;
    productFilterConditionConfig = newFilterObj;
    fillGroupObject(productFilterConditionConfig);
    reRender();
    document.querySelector('.condition-configs').style.display = '';
    document.getElementById('save-conditions').style.display = '';
});
    
productFilterResolver(true);
    
} catch(err) {
    productFilterResolver(false);
    console.warn(err);
}

})();

var productFilterConditionConfig = {};

var lastConditionElement = null;
function reRender() {
    if(productFilterConditionConfig.htmlElement)productFilterConditionConfig.htmlElement.remove();
    if(lastConditionElement)lastConditionElement.remove();
    lastConditionElement = renderGroup(productFilterConditionConfig);
    document.querySelector('.condition-panel').appendChild(lastConditionElement);
}

function generateId() {
    return 'i' + [...Array(20)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
}

function resetCheckInputs(id) {
    Array.from(document.querySelectorAll('input.condition-box:not(.'+id+'),input.group-box:not(.'+id+')')).forEach(function(element) {
        element.checked = false;
    });
}

var logicSelect = document.createElement('select');
logicSelect.innerHTML = '<option value="AND">AND</option>' +
    '<option value="OR">OR</option>'
logicSelect.classList.add('form-control');
logicSelect.style.width = 'auto';

/*var groupPositiveSelect = document.createElement('select');
groupPositiveSelect.innerHTML = '<option value="IS">IS</option>' +
    '<option value="IS NOT">IS NOT</option>'
groupPositiveSelect.classList.add('form-control');
groupPositiveSelect.style.width = 'auto';*/


var groupExcludeSwitch = document.createElement('div');
groupExcludeSwitch.classList.add("custom-control");
groupExcludeSwitch.classList.add("custom-switch");
groupExcludeSwitch.appendChild((()=>{
    var input = document.createElement('input');
    input.type = 'checkbox';
    input.classList.add("custom-control-input");
    return input;
})());
groupExcludeSwitch.appendChild((()=>{
    var label = document.createElement('label');
    label.classList.add("custom-control-label");
    label.textContent = 'Exclude';
    label.style.fontWeight = 'unset';
    return label;
})());



function condition(f,params) {
    this.type = 'condition';
    this.f = f;
    this.flag = 0;
    this.params = [];
    var thisRef = this;
    if(params) {
        params.forEach(function(param, index) {
            if(param.type === 'list') {
                thisRef.params[index] = param.elements[0].value;
            }
        });
    }
}

var addElement = function(e) {
    e.parent = this;
    this.elements.push(e);
}

var removeElement = function(e, keep) {
    this.elements = this.elements.filter(function(obj) {
        return obj !== e;
    });
    if(this.elements.length === 0) {
        if(this.parent && !keep)
            this.parent.removeElement(this);
    }
}

function group(operator,...e) {
    this.type = 'group';
    this.elements = [];
    for(var i=0;i<e.length;i++) {
        e[i].parent = this;
        this.elements.push(e[i]);
    }
    this.operator = operator;
    this.flag = 0;
    this.addElement = addElement;
    this.removeElement = removeElement;
}

function clearGroupObject(groupElement) {
    var newGroup = Object.assign({},groupElement);
    delete newGroup.parent;
    delete newGroup.htmlElement;
    delete newGroup.addElement;
    delete newGroup.removeElement;
    if(groupElement.elements) newGroup.elements = groupElement.elements.map(function(element) {
        var newElement = Object.assign({},element);
        delete newElement.parent;
        delete newElement.htmlElement;
        delete newElement.addElement;
        delete newElement.removeElement;
        return clearGroupObject(newElement);
    });
    return newGroup;
};

function fillGroupObject(group) {
    if(group.type === 'group') {
        group.addElement = addElement;
        group.removeElement = removeElement;
    }
    if(!group.elements)
        return group;
    else {
        group.elements.forEach(function(element) {
            element.parent = group;
            if(element.type === 'group') {
                element.addElement = addElement;
                element.removeElement = removeElement;
            }
            fillGroupObject(element);
        });
    }
}

function renderParams(selectElement, group, preserveValues) {
    var newSelectFunc = null;
    var params = selectElement.children[selectElement.selectedIndex].params;
    while(selectElement.nextSibling)
        selectElement.nextSibling.remove();
    if(params) {
        var x = __productFilterFunctions__[__productFilterFunctions__.findIndex(e=>e.name==group.f)].params[1].elements[7];
        if(x && x.name == 'BETWEEN' && x.value == 80 && group.params[1] == 80)x=1;
        else x=0;
        if(group.params.length > params.length + x)
            group.params.length -= group.params.length - params.length - x;
        params.forEach(function(param,index) {
            if(param.type === 'list') {
                var newSelect = document.createElement('select');
                newSelect.classList.add('form-control');
                newSelect.style.width = 'auto';
                param.elements.forEach(function(element) {
                    var newOption = document.createElement('option');
                    newOption.value = element.value;
                    newOption.innerText = element.name;
                    newSelect.appendChild(newOption);
                });
                var lastCreatedInput = null;
                newSelectFunc = function() {
                    var selectedOpt = newSelect.children[newSelect.selectedIndex];
                    if(selectedOpt.innerText == 'BETWEEN' && selectedOpt.value == 80) {
                        lastCreatedInput = lastCreatedInput ? lastCreatedInput : document.createElement('input');
                        lastCreatedInput.classList.add('form-control');
                        lastCreatedInput.style.width = 'auto';
                        lastCreatedInput.addEventListener('change', function(e) {
                            group.params[params.length] = e.target.value;
                        });
                        var elementToAdd = selectElement;
                        while(elementToAdd.nextSibling)
                            elementToAdd = elementToAdd.nextSibling;
                        if(elementToAdd.type == 'submit')elementToAdd=elementToAdd.previousSibling;
                        elementToAdd.insertAdjacentElement('afterend',lastCreatedInput);
                        if(group.params[params.length])lastCreatedInput.value = group.params[params.length];
                        else group.params[params.length] = lastCreatedInput.value;
                    } else if(lastCreatedInput) {
                        lastCreatedInput.remove();
                        lastCreatedInput = null;
                        group.params.length--;
                    }
                    group.params[index] = newSelect.value;
                }
                newSelect.addEventListener('change', newSelectFunc);
                var elementToAdd = selectElement;
                while(elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend',newSelect);

                if(preserveValues)newSelect.value = group.params[index];
                else {
                    group.params[index] = newSelect.children[0].value;
					newSelect.value = group.params[index];
                }
            } else if(param.type === 'text') {
                var newInput = document.createElement('input');
                newInput.classList.add('form-control');
                newInput.style.width = 'auto';
                if(group.params.length > index && preserveValues) newInput.value = group.params[index];
                newInput.addEventListener('change', function(e) {
                    group.params[index] = e.target.value;
                });
                var elementToAdd = selectElement;
                while(elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend',newInput);
                group.params[index] = newInput.value;
            } else if(param.type === 'multiline') {
                var textArea = document.createElement('textarea');
                textArea.classList.add('form-control');
                textArea.style.width = '500px';
                textArea.style.height = '100px';
                textArea.setAttribute('rows', 1);
                if(group.params.length > index && preserveValues) textArea.value = group.params[index];
                textArea.addEventListener('change', function(e) {
                    group.params[index] = e.target.value;
                });
                var elementToAdd = selectElement;
                while(elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend',textArea);
                group.params[index] = textArea.value;
            }
        });
        newSelectFunc();
    } else 
        group.params = [];
}

function renderGroup(group) {
    if(group.type === 'condition') {
        var divElement = document.createElement('div')
        var checkElement = document.createElement('input');
        var deleteButton = document.createElement('button');
        deleteButton.dataObj = group;
        deleteButton.innerText = 'X';
        deleteButton.addEventListener('click', function() {
            this.dataObj.parent.removeElement(this.dataObj);
            reRender();
        });
        deleteButton.classList.add('product-filtering-button');
        deleteButton.classList.add('button-red');
        deleteButton.style.margin = '5px';
        checkElement.type = 'checkbox';
        checkElement.dataObj = group;
        checkElement.classList.add("condition-box");
        
        
        var positiveSelectElement = groupExcludeSwitch.cloneNode(true);
        var groupId = generateId();
        positiveSelectElement.style.marginLeft = '8px';
        positiveSelectElement.style.marginRight = '8px';
        positiveSelectElement.querySelector('input').id = groupId;
        positiveSelectElement.querySelector('label').setAttribute('for',groupId);
        positiveSelectElement.querySelector('input').checked = parseInt(group.flag);
        positiveSelectElement.dataObj = group;
        
        
        var selectElement = conditionSelect.cloneNode(true);
        var originalOptions = Array.from(conditionSelect.children);
        var newOptions = Array.from(selectElement.children);
        for(var i=0;i<originalOptions.length;i++)
            newOptions[i].params = originalOptions[i].params;
        selectElement.value = group.f;
        selectElement.dataObj = group;
        divElement.appendChild(checkElement);
        divElement.appendChild(positiveSelectElement);
        divElement.appendChild(selectElement);
        renderParams(selectElement, group, true);
        divElement.appendChild(deleteButton);
        selectElement.addEventListener('change', function(e) {
            this.dataObj.f = selectElement.value;
            renderParams(selectElement, group);
            divElement.appendChild(deleteButton);
        })
        positiveSelectElement.addEventListener('change', function(evt) {
            this.dataObj.flag = evt.target.checked ? 1 : 0;
        })
        divElement.classList.add('condition-div');
        group.htmlElement = divElement;
        return divElement;
    } else if(group.type === 'group') {
        var arr = [];
        var segmentDiv = document.createElement('div');
        segmentDiv.style.display = 'flex';
        segmentDiv.classList.add('condition-segment');
        
        var addButton = document.createElement('button');
        addButton.dataObj = group;
        addButton.innerText = 'ADD';
        addButton.addEventListener('click', function() {
            this.dataObj.addElement(new condition(__productFilterFunctions__[0].name, __productFilterFunctions__[0].params));
            reRender();
        });
        addButton.classList.add('product-filtering-button');
        addButton.classList.add('btn');
        addButton.classList.add('btn-primary');
        
        var checkElement = document.createElement('input');
        checkElement.type = 'checkbox';
        checkElement.dataObj = group;
        checkElement.classList.add('group-box');
        var selectElement = logicSelect.cloneNode(true);
        selectElement.value = group.operator;
        selectElement.dataObj = group;
        var positiveSelectElement = groupExcludeSwitch.cloneNode(true);
        var groupId = generateId();
        positiveSelectElement.style.marginLeft = '8px';
        positiveSelectElement.querySelector('input').id = groupId;
        positiveSelectElement.querySelector('label').setAttribute('for',groupId);
        positiveSelectElement.querySelector('input').checked = parseInt(group.flag);
        positiveSelectElement.dataObj = group;
        var logicDiv = document.createElement('div');
        logicDiv.appendChild(checkElement);
        logicDiv.appendChild(selectElement);
        logicDiv.appendChild(positiveSelectElement);
        //logicDiv.appendChild(addButton);
        logicDiv.style.display = 'flex';
        logicDiv.style.alignItems = 'center';

        selectElement.addEventListener('change', function() {
            this.dataObj.operator = selectElement.value;
        })
        
        positiveSelectElement.addEventListener('change', function(evt) {
            this.dataObj.flag = evt.target.checked ? 1 : 0;
        })

        var groupDiv = document.createElement('div');
        groupDiv.classList.add('condition-group');
        var generatedID = generateId();
        groupDiv.appendChild(addButton);
        var tempButton = document.getElementById('group-conditions').cloneNode(true);tempButton.style.display = '';
        groupDiv.appendChild(tempButton);
        tempButton = document.getElementById('remove-group').cloneNode(true);tempButton.style.display = '';
        groupDiv.appendChild(tempButton);
        tempButton = document.getElementById('ungroup-conditions').cloneNode(true);tempButton.style.display = '';
        groupDiv.appendChild(tempButton);
        group.elements.forEach(function(element) {
            groupDiv.appendChild(renderGroup(element));
        });

        Array.from(groupDiv.children).forEach(function(element,idx) {
            if(idx<4)return;
            var childInput = element.querySelector("input");
            childInput.classList.add(generatedID);
            childInput.name = generatedID;
            childInput.addEventListener('click', function() {
                resetCheckInputs(childInput.name);
            });
        });

        segmentDiv.appendChild(logicDiv);
        segmentDiv.appendChild(groupDiv);

        group.htmlElement = segmentDiv;
        return segmentDiv;
    }
}

function groupConditions(curElement) {
    var parent;
    var render = false;
    var elements = Array.from(document.querySelectorAll('.condition-box:checked,.group-box:checked')).map(function(element) {
        parent = element.dataObj.parent;
        element.dataObj.parent.removeElement(element.dataObj, true);
        render = true;
        return element.dataObj;
    });
    if(!render)
        return;
    var newGroup = new group('OR',...elements);
    parent.addElement(newGroup);
    reRender();
}

function removeGroup(curElement) {
    Array.from(document.querySelectorAll('.group-box:checked')).forEach(function(element) {
        element.dataObj.parent.removeElement(element.dataObj);
    });
    reRender();
}

function ungroupConditions(curElement) {
    Array.from(document.querySelectorAll('.group-box:checked')).forEach(function(element) {
        element.dataObj.elements.forEach(function(el) {
            element.dataObj.parent.addElement(el);
        });
        element.dataObj.parent.removeElement(element.dataObj);
    });
    reRender();
}